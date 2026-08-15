# =============================================================================
# 数据集名称：ADSL（Subject-Level Analysis Dataset，受试者级分析数据集）
# =============================================================================
# 功能说明：
#   从 SDTM 数据（DM、DS、EX、AE、VS）构建 ADSL，这是 ADaM 中最基础的数据集，
#   每个受试者一行，包含人口学信息、用药时间、试验结局、分析标志变量等。
#   其他 ADaM 数据集（ADAE、ADVS 等）都依赖 ADSL 中的变量。
#
# 使用的包：
#   - admiral      : pharmaverse 开发的 ADaM 构建核心工具包
#   - metacore     : 读取规格书（specifications），驱动变量派生
#   - metatools    : 配合 metacore 进行数据校验和变量创建
#   - xportr       : 将 R 数据框导出为 SAS 传输文件（.xpt）
#   - pharmaversesdtm : 提供示例 SDTM 数据
#   - dplyr/tidyr/lubridate/stringr : 通用数据操作
#
# 输入数据来源：
#   - pharmaversesdtm::dm      : SDTM DM 域（人口学）
#   - pharmaversesdtm::ds      : SDTM DS 域（处置/结局）
#   - pharmaversesdtm::ex      : SDTM EX 域（暴露/用药记录）
#   - pharmaversesdtm::ae      : SDTM AE 域（不良事件，用于死亡原因）
#   - pharmaversesdtm::vs      : SDTM VS 域（生命体征）
#   - pharmaversesdtm::suppdm  : SDTM SUPPDM 补充域
#   - metadata/safety_specs.xlsx : ADaM 规格书（定义变量、受控术语、排序等）
#
# 输出文件：
#   - adsl.xpt（SAS 传输文件，写入 tempdir()）
#
# 关键概念说明：
#   ADSL 是所有 ADaM 分析的起点，包含以下关键变量类别：
#   - 人口学变量：AGE、SEX、RACE、ETHNIC 等（来自 DM）
#   - 治疗变量：TRT01P（计划治疗）、TRT01A（实际治疗）、TRTSDTM（开始时间）
#   - 结局标志：SAFFL（安全性人群）、RANDFL（随机化人群）、EOSSTT（研究完成状态）
#   - 分组变量：AGEGR1（年龄组）、REGION1（地区分组）等
#   metacore：将规格书（Excel）加载为 R 对象，确保派生结果与规格一致
# =============================================================================

## ----r setup, message=FALSE, warning=FALSE, results='hold'--------------------
library(metacore)
library(metatools)
library(pharmaversesdtm)
library(admiral)
library(xportr)
library(dplyr)
library(tidyr)
library(lubridate)
library(stringr)

# Read in input SDTM data
dm <- pharmaversesdtm::dm
ds <- pharmaversesdtm::ds
ex <- pharmaversesdtm::ex
ae <- pharmaversesdtm::ae
vs <- pharmaversesdtm::vs
suppdm <- pharmaversesdtm::suppdm

# When SAS datasets are imported into R using haven::read_sas(), missing
# character values from SAS appear as "" characters in R, instead of appearing
# as NA values. Further details can be obtained via the following link:
# https://pharmaverse.github.io/admiral/articles/admiral.html#handling-of-missing-values
# 将 SAS 导入时产生的空字符串（""）统一替换为 R 的缺失值 NA，保持一致性
dm <- convert_blanks_to_na(dm)
ds <- convert_blanks_to_na(ds)
ex <- convert_blanks_to_na(ex)
ae <- convert_blanks_to_na(ae)
vs <- convert_blanks_to_na(vs)
suppdm <- convert_blanks_to_na(suppdm)

## ----r combine, message=FALSE, warning=FALSE, results='hold'------------------
# Combine Parent and Supp - very handy! ----
# 将 DM 主域和 SUPPDM 补充域合并（SUPPDM 存放 DM 中不标准的额外变量）
dm_suppdm <- combine_supp(dm, suppdm)

## ----r metacore, warning=FALSE, results='hold'--------------------------------
# Read in metacore object
# 从 Excel 规格书读取 ADSL 的变量定义、受控术语、排序规则
# select_dataset 筛选出专属于 ADSL 的规格部分
metacore <- spec_to_metacore(
  path = "./metadata/safety_specs.xlsx",
  # All datasets are described in the same sheet
  where_sep_sheet = FALSE
) %>%
  select_dataset("ADSL")

## ----r demographics-----------------------------------------------------------
# 利用规格书中定义的"前身变量"（predecessor）自动从 SDTM 变量映射到 ADaM 变量
# 例如 DM.AGE → ADSL.AGE，DM.SEX → ADSL.SEX，避免手动 rename
adsl_preds <- build_from_derived(metacore,
  ds_list = list("dm" = dm_suppdm, "suppdm" = dm_suppdm),
  predecessor_only = FALSE, keep = FALSE
)

## ----r grouping_option_1------------------------------------------------------
# 方法一：使用 derive_vars_cat 按条件查找表创建年龄分组
# 查找表定义了 AGE 到 AGEGR1/AGEGR1N 的映射规则，类似 SAS 的 IF-THEN-ELSE 格式
agegr1_lookup <- exprs(
  ~condition,            ~AGEGR1, ~AGEGR1N,
  is.na(AGE),          "Missing",        4,
  AGE < 18,                "<18",        1,
  between(AGE, 18, 64),  "18-64",        2,
  !is.na(AGE),             ">64",        3
)

adsl_cat <- derive_vars_cat(
  dataset = adsl_preds,
  definition = agegr1_lookup
)

## ----r------------------------------------------------------------------------
# 查看规格书中 AGEGR1 的受控术语（用于验证分组值是否符合规格要求）
get_control_term(metacore, variable = AGEGR1)

## ----r grouping_option_2------------------------------------------------------
# 方法二：create_cat_var 直接读取规格书中的受控术语定义来创建分组变量
# 优点：分组边界由规格书控制，减少硬编码
adsl_ct <- adsl_preds %>%
  create_cat_var(metacore,
    ref_var = AGE,
    grp_var = AGEGR1, num_grp_var = AGEGR1N
  )

## ----r grouping_option_3------------------------------------------------------
# 方法三：用自定义函数手动创建分组（最灵活，适合复杂分组逻辑）
format_agegr1 <- function(age) {
  case_when(
    age < 18 ~ "<18",
    between(age, 18, 64) ~ "18-64",
    age > 64 ~ ">64",
    TRUE ~ "Missing"
  )
}

format_agegr1n <- function(age) {
  case_when(
    age < 18 ~ 1,
    between(age, 18, 64) ~ 2,
    age > 64 ~ 3,
    TRUE ~ 4
  )
}

adsl_cust <- adsl_preds %>%
  mutate(
    AGEGR1 = format_agegr1(AGE),
    AGEGR1N = format_agegr1n(AGE)
  )

## ----r codelist---------------------------------------------------------------
# 从规格书受控术语自动为 RACE 创建对应的数值编码 RACEN
# 避免手动维护代码值映射表，确保与规格书同步
adsl_ct <- adsl_ct %>%
  create_var_from_codelist(
    metacore = metacore,
    input_var = RACE,
    out_var = RACEN
  )

## ----r exposure---------------------------------------------------------------
# 将 EX 域的日期字符串转换为 datetime 格式（含日期+时间）
# derive_vars_dtm 处理不完整日期/时间（部分缺失时进行填补）
ex_ext <- ex %>%
  derive_vars_dtm(
    dtc = EXSTDTC,
    new_vars_prefix = "EXST"
  ) %>%
  derive_vars_dtm(
    dtc = EXENDTC,
    new_vars_prefix = "EXEN",
    time_imputation = "last"  # 末次用药时间缺失时填补为当天末尾（23:59:59）
  )

adsl_raw <- adsl_ct %>%
  # Treatment Start Datetime
  # 取该受试者所有用药记录中最早的实际用药开始时间（排除安慰剂0剂量记录）
  derive_vars_merged(
    dataset_add = ex_ext,
    filter_add = (EXDOSE > 0 |
      (EXDOSE == 0 &
        str_detect(EXTRT, "PLACEBO"))) & !is.na(EXSTDTM),
    new_vars = exprs(TRTSDTM = EXSTDTM, TRTSTMF = EXSTTMF),
    order = exprs(EXSTDTM, EXSEQ),
    mode = "first",
    by_vars = exprs(STUDYID, USUBJID)
  ) %>%
  # Treatment End Datetime
  # 取最晚的实际用药结束时间
  derive_vars_merged(
    dataset_add = ex_ext,
    filter_add = (EXDOSE > 0 |
      (EXDOSE == 0 &
        str_detect(EXTRT, "PLACEBO"))) & !is.na(EXENDTM),
    new_vars = exprs(TRTEDTM = EXENDTM, TRTETMF = EXENTMF),
    order = exprs(EXENDTM, EXSEQ),
    mode = "last",
    by_vars = exprs(STUDYID, USUBJID)
  ) %>%
  # Treatment Start and End Date
  derive_vars_dtm_to_dt(source_vars = exprs(TRTSDTM, TRTEDTM)) %>% # Convert Datetime variables to date
  # Treatment Start Time
  derive_vars_dtm_to_tm(source_vars = exprs(TRTSDTM)) %>%
  # Treatment Duration
  # 计算治疗持续天数（末次用药日 - 首次用药日 + 1）
  derive_var_trtdurd() %>%
  # Safety Population Flag
  # 安全性人群：至少有一次实际用药记录（EXDOSE>0 或 PLACEBO）
  derive_var_merged_exist_flag(
    dataset_add = ex,
    by_vars = exprs(STUDYID, USUBJID),
    new_var = SAFFL,
    false_value = "N",
    missing_value = "N",
    condition = (EXDOSE > 0 | (EXDOSE == 0 & str_detect(EXTRT, "PLACEBO")))
  )

## ----r treatment_char, eval=TRUE----------------------------------------------
# 构建计划治疗和实际治疗变量：筛查失败、未分配、未治疗的受试者标为"No Treatment"
adsl <- adsl_raw %>%
  mutate(
    TRT01P = if_else(ARM %in% c("Screen Failure", "Not Assigned", "Not Treated"), "No Treatment", ARM),
    TRT01A = if_else(ACTARM %in% c("Screen Failure", "Not Assigned", "Not Treated"), "No Treatment", ACTARM)
  )

## ----r treatment_num, eval=TRUE-----------------------------------------------
# 从规格书受控术语为 TRT01P/TRT01A 创建对应数值编码，用于统计分析中的分组排序
adsl <- adsl %>%
  create_var_from_codelist(metacore, input_var = TRT01P, out_var = TRT01PN) %>%
  create_var_from_codelist(metacore, input_var = TRT01A, out_var = TRT01AN)

## ----r disposition, eval=TRUE-------------------------------------------------
# Convert character date to numeric date without imputation
# 将 DS 域的处置日期字符串转换为 R 日期对象（不做缺失填补）
ds_ext <- derive_vars_dt(
  ds,
  dtc = DSSTDTC,
  new_vars_prefix = "DSST"
)

# 从 DS 域提取研究结束日期（排除筛查失败事件）
adsl <- adsl %>%
  derive_vars_merged(
    dataset_add = ds_ext,
    by_vars = exprs(STUDYID, USUBJID),
    new_vars = exprs(EOSDT = DSSTDT),
    filter_add = DSCAT == "DISPOSITION EVENT" & DSDECOD != "SCREEN FAILURE"
  )

## ----r eval=TRUE--------------------------------------------------------------
# 定义研究完成状态函数：完成→"COMPLETED"，筛查失败→缺失，其他→"DISCONTINUED"
format_eosstt <- function(x) {
  case_when(
    x %in% c("COMPLETED") ~ "COMPLETED",
    x %in% c("SCREEN FAILURE") ~ NA_character_,
    TRUE ~ "DISCONTINUED"
  )
}

## ----r eval=TRUE--------------------------------------------------------------
# 从 DS 域映射研究完成状态 EOSSTT
# missing_values = "ONGOING" 表示：如果该受试者在 DS 中没有处置事件记录，则标为"ONGOING"
adsl <- adsl %>%
  derive_vars_merged(
    dataset_add = ds,
    by_vars = exprs(STUDYID, USUBJID),
    filter_add = DSCAT == "DISPOSITION EVENT",
    new_vars = exprs(EOSSTT = format_eosstt(DSDECOD)),
    missing_values = exprs(EOSSTT = "ONGOING")
  )

## ----r eval=TRUE--------------------------------------------------------------
# 派生死亡日期 DTHDT：highest_imputation = "M" 允许对月份缺失的日期进行填补
# date_imputation = "first" 表示月份缺失时填补为该月第1天（保守估计）
adsl <- adsl %>%
  derive_vars_dt(
    new_vars_prefix = "DTH",
    dtc = DTHDTC,
    highest_imputation = "M",
    date_imputation = "first"
  )

## ----r eval=TRUE--------------------------------------------------------------
# 从 DS 域提取随机化日期、筛查失败日期、末次随访日期
adsl <- adsl %>%
  derive_vars_merged(
    dataset_add = ds_ext,
    by_vars = exprs(STUDYID, USUBJID),
    new_vars = exprs(RANDDT = DSSTDT),
    filter_add = DSDECOD == "RANDOMIZED",
  ) %>%
  derive_vars_merged(
    dataset_add = ds_ext,
    by_vars = exprs(STUDYID, USUBJID),
    new_vars = exprs(SCRFDT = DSSTDT),
    filter_add = DSCAT == "DISPOSITION EVENT" & DSDECOD == "SCREEN FAILURE"
  ) %>%
  derive_vars_merged(
    dataset_add = ds_ext,
    by_vars = exprs(STUDYID, USUBJID),
    new_vars = exprs(FRVDT = DSSTDT),
    filter_add = DSCAT == "OTHER EVENT" & DSDECOD == "FINAL RETRIEVAL VISIT"
  )

## ----r eval=TRUE--------------------------------------------------------------
# 计算死亡相关天数：
# DTHADY：从首次用药到死亡的天数（反映治疗暴露期）
# LDDTHELD：从末次用药到死亡的天数（add_one = FALSE 不加1，表示间隔天数）
adsl <- adsl %>%
  derive_vars_duration(
    new_var = DTHADY,
    start_date = TRTSDT,
    end_date = DTHDT
  ) %>%
  derive_vars_duration(
    new_var = LDDTHELD,
    start_date = TRTEDT,
    end_date = DTHDT,
    add_one = FALSE
  )

## ----r eval=TRUE--------------------------------------------------------------
# 随机化标志：有随机化日期则标"Y"，否则缺失
assign_randfl <- function(x) {
  if_else(!is.na(x), "Y", NA_character_)
}

adsl <- adsl %>%
  mutate(
    RANDFL = assign_randfl(RANDDT)
  )

## ----r death, eval=TRUE-------------------------------------------------------
# 派生死亡原因（DTHCAUS）和死亡来源域（DTHDOM）
# 优先从 AE 域找（AEOUT=="FATAL"），其次从 DS 域找（"DEATH DUE TO..."）
# event_nr 决定优先级：数字小的 event 先匹配
adsl <- adsl %>%
  derive_vars_extreme_event(
    by_vars = exprs(STUDYID, USUBJID),
    events = list(
      event(
        dataset_name = "ae",
        condition = AEOUT == "FATAL",
        set_values_to = exprs(DTHCAUS = AEDECOD, DTHDOM = "AE"),
      ),
      event(
        dataset_name = "ds",
        condition = DSDECOD == "DEATH" & grepl("DEATH DUE TO", DSTERM),
        set_values_to = exprs(DTHCAUS = DSTERM, DTHDOM = "DS"),
      )
    ),
    source_datasets = list(ae = ae, ds = ds),
    tmp_event_nr_var = event_nr,
    order = exprs(event_nr),
    mode = "first",
    new_vars = exprs(DTHCAUS, DTHDOM)
  )

## ----r grouping, eval=TRUE----------------------------------------------------
# 创建地区分组（北美 vs 世界其他地区）、种族分组、死亡原因分组
# 使用 exprs() 格式的查找表，与前面 AGEGR1 的方法一致
region1_lookup <- exprs(
  ~condition,                              ~REGION1, ~REGION1N,
  COUNTRY %in% c("CAN", "USA"),     "North America",         1,
  !is.na(COUNTRY),              "Rest of the World",         2,
  is.na(COUNTRY),                         "Missing",         3
)

racegr1_lookup <- exprs(
  ~condition, ~RACEGR1, ~RACEGR1N,
  RACE %in% c("WHITE"), "White", 1,
  RACE != "WHITE", "Non-white", 2,
  is.na(RACE), "Missing", 3
)

dthcgr1_lookup <- exprs(
  ~condition,                                                                                 ~DTHCGR1, ~DTHCGR1N,
  DTHDOM == "AE",                                                                      "ADVERSE EVENT",         1,
  !is.na(DTHDOM) & str_detect(DTHCAUS, "(PROGRESSIVE DISEASE|DISEASE RELAPSE)"), "PROGRESSIVE DISEASE",         2,
  !is.na(DTHDOM) & !is.na(DTHCAUS),                                                            "OTHER",         3,
  is.na(DTHDOM),                                                                         NA_character_,        NA
)


adsl <- adsl %>%
  derive_vars_cat(
    definition = region1_lookup
  ) %>%
  derive_vars_cat(
    definition = racegr1_lookup
  ) %>%
  derive_vars_cat(
    definition = dthcgr1_lookup
  )

## ----r checks, warning=FALSE, message=FALSE-----------------------------------
# 最终质控和导出：
# check_variables : 确认所有规格变量都存在且无多余变量
# check_ct_data   : 验证受控术语变量的值均在允许范围内
# order_cols      : 按规格书定义的变量顺序排列列
# sort_by_key     : 按规格书定义的排序键排列行
# xportr_*        : 设置 SAS 格式（类型、长度、标签）并导出为 .xpt 文件
dir <- "adam/output" # Specify the directory for saving the XPT file
dir.create(dir, showWarnings = FALSE, recursive = TRUE)

adsl %>%
  check_variables(metacore) %>% # Check all variables specified are present and no more
  check_ct_data(metacore, na_acceptable = TRUE) %>% # Checks all variables with CT only contain values within the CT
  order_cols(metacore) %>% # Orders the columns according to the spec
  sort_by_key(metacore) %>% # Sorts the rows by the sort keys
  xportr_type(metacore, domain = "ADSL") %>% # Coerce variable type to match spec
  xportr_length(metacore) %>% # Assigns SAS length from a variable level metadata
  xportr_label(metacore) %>% # Assigns variable label from metacore specifications
  xportr_df_label(metacore) %>% # Assigns dataset label from metacore specifications
  xportr_write(file.path(dir, "adsl.xpt"), metadata = metacore, domain = "ADSL")
