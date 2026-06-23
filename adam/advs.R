# =============================================================================
# 数据集名称：ADVS（Vital Signs Analysis Dataset，生命体征分析数据集）
# =============================================================================
# 功能说明：
#   在 SDTM VS 域基础上构建 ADVS，添加分析所需的派生变量，包括：
#   分析日期（ADT/ADY）、参数化指标（PARAMCD/PARAM）、衍生参数（MAP均动脉压/BMI/BSA）、
#   基线值（BASE）、变化量（CHG）、百分变化（PCHG）、正常范围标志（ANRIND）等。
#
# 使用的包：
#   - admiral         : ADaM 构建核心工具包
#   - metacore/metatools : 规格书驱动的变量校验
#   - xportr          : 导出为 SAS 传输文件
#   - pharmaversesdtm : SDTM 示例数据（VS）
#   - dplyr/tidyr/lubridate/stringr : 数据操作
#
# 输入数据来源：
#   - pharmaverseadam::adsl    : ADSL（提供治疗开始/结束日和治疗标签）
#   - pharmaversesdtm::vs      : SDTM VS 域（生命体征基础数据）
#   - metadata/safety_specs.xlsx : ADaM 规格书
#
# 输出文件：
#   - advs.xpt（SAS 传输文件，写入 tempdir()）
#
# 关键概念说明：
#   PARAMCD/PARAM：ADaM 的参数化标识，将 VSTESTCD（如"SYSBP"）映射为分析参数
#   衍生参数：MAP（均动脉压）= 2/3×舒张压 + 1/3×收缩压；BMI=体重/身高²；BSA由Mosteller公式计算
#   基线（ABLFL/BASE）：治疗前最后一次有效测量值，所有变化量的参照点
#   CHG = AVAL - BASE（实际值与基线的差值）
#   PCHG = (AVAL - BASE) / BASE × 100（百分变化）
#   BASETYPE：区分不同体位的基线类型（如卧位/立位各有独立基线）
#   ANL01FL：每次访视每个参数的最终分析值标志（用于主要分析）
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

# Read in input data
adsl <- pharmaverseadam::adsl
vs <- pharmaversesdtm::vs

# 将 SAS 空字符串转为 NA
vs <- convert_blanks_to_na(vs)

## ----r echo=TRUE--------------------------------------------------------------
# ---- Load Specs for Metacore ----
# 读取 ADVS 的规格书定义
metacore <- spec_to_metacore(
  path = "./metadata/safety_specs.xlsx",
  # All datasets are described in the same sheet
  where_sep_sheet = FALSE
) %>%
  select_dataset("ADVS")

## ----r------------------------------------------------------------------------
# Select required ADSL variables
# 只从 ADSL 提取 ADVS 需要的变量，避免在后续合并时引入冗余变量
adsl_vars <- exprs(TRTSDT, TRTEDT, TRT01A, TRT01P)

# Join ADSL variables with VS
# 将受试者级治疗信息合并到 VS 记录，为后续基线和治疗期判断提供依据
advs <- vs %>%
  derive_vars_merged(
    dataset_add = adsl,
    new_vars = adsl_vars,
    by_vars = exprs(STUDYID, USUBJID)
  )

## ----r------------------------------------------------------------------------
# Calculate ADT, ADY
# ADT：将 VSDTC 转换为 R 日期格式（highest_imputation = "n" 表示不对不完整日期进行填补）
# ADY：计算相对首次用药日的分析日（ADT - TRTSDT，用药当天=1，用药前为负数）
advs <- advs %>%
  derive_vars_dt(
    new_vars_prefix = "A",
    dtc = VSDTC,
    # Below arguments are default values and not necessary to add in our case
    highest_imputation = "n", # means no imputation is performed on partial/missing dates
    flag_imputation = "auto" # To automatically create ADTF variable when highest_imputation is "Y", "M" or "D"
  ) %>%
  derive_vars_dy(
    reference_date = TRTSDT,
    source_vars = exprs(ADT)
  )

## ----r eval=TRUE, include=FALSE-----------------------------------------------
# 参数查找表：将 SDTM 的 VSTESTCD 映射为 ADaM 的 PARAMCD/PARAM/PARAMN
# 包含6个原始指标和3个衍生指标（MAP、BMI、BSA）
param_lookup <- tibble::tribble(
  ~VSTESTCD, ~PARAMCD, ~PARAM, ~PARAMN,
  "SYSBP", "SYSBP", " Systolic Blood Pressure (mmHg)", 1,
  "DIABP", "DIABP", "Diastolic Blood Pressure (mmHg)", 2,
  "PULSE", "PULSE", "Pulse Rate (beats/min)", 3,
  "WEIGHT", "WEIGHT", "Weight (kg)", 4,
  "HEIGHT", "HEIGHT", "Height (cm)", 5,
  "TEMP", "TEMP", "Temperature (C)", 6,
  "MAP", "MAP", "Mean Arterial Pressure (mmHg)", 7,
  "BMI", "BMI", "Body Mass Index(kg/m^2)", 8,
  "BSA", "BSA", "Body Surface Area(m^2)", 9
)
attr(param_lookup$VSTESTCD, "label") <- "Vital Signs Test Short Name"

## ----r------------------------------------------------------------------------
# 通过查找表为每条记录赋予 PARAMCD
# print_not_mapped = TRUE 会打印出没有匹配到的 VSTESTCD 值，便于核查
advs <- advs %>%
  # Add PARAMCD only - add PARAM etc later
  derive_vars_merged_lookup(
    dataset_add = param_lookup,
    new_vars = exprs(PARAMCD),
    by_vars = exprs(VSTESTCD),
    # Below arguments are default values and not necessary to add in our case
    print_not_mapped = TRUE # Printing whether some parameters are not mapped
  )

## ----r eval=TRUE--------------------------------------------------------------
# AVAL（分析值）直接使用 VSSTRESN（标准化数值），AVALU 使用标准单位
# SDTM VS 域已完成单位换算（如磅→公斤），ADVS 直接继承
advs <- advs %>%
  mutate(
    AVAL = VSSTRESN,
    AVALU = VSSTRESU
  )

## ----r eval=TRUE--------------------------------------------------------------
# 派生衍生参数1：MAP（均动脉压）
# 公式：MAP = 舒张压 + (收缩压-舒张压)/3 ≈ (2×舒张压 + 收缩压)/3
# derive_param_map 自动查找同一受试者同一时间点的 SYSBP 和 DIABP 记录来计算
advs <- advs %>%
  derive_param_map(
    by_vars = exprs(STUDYID, USUBJID, !!!adsl_vars, VISIT, VISITNUM, ADT, ADY, VSTPT, VSTPTNUM, AVALU), # Other variables than the defined ones here won't be populated
    set_values_to = exprs(PARAMCD = "MAP"),
    get_unit_expr = VSSTRESU,
    filter = VSSTAT != "NOT DONE" | is.na(VSSTAT),
    # Below arguments are default values and not necessary to add in our case
    sysbp_code = "SYSBP",
    diabp_code = "DIABP",
    hr_code = NULL
  )

## ----r eval=TRUE--------------------------------------------------------------
# 派生衍生参数2：BMI（体质指数）= 体重(kg) / 身高(m)²
# constant_parameters = "HEIGHT" 表示身高在同一受试者内视为常数（不随访视变化）
advs <- advs %>%
  derive_param_computed(
    by_vars = exprs(STUDYID, USUBJID, VISIT, VISITNUM, ADT, ADY, VSTPT, VSTPTNUM),
    parameters = "WEIGHT",
    set_values_to = exprs(
      AVAL = AVAL.WEIGHT / (AVAL.HEIGHT / 100)^2,
      PARAMCD = "BMI",
      AVALU = "kg/m^2"
    ),
    constant_parameters = c("HEIGHT"),
    constant_by_vars = exprs(USUBJID)
  )

## ----r eval=TRUE--------------------------------------------------------------
# 派生衍生参数3：BSA（体表面积）使用 Mosteller 公式
# BSA = sqrt(身高(cm) × 体重(kg) / 3600)，单位 m²
advs <- advs %>%
  derive_param_bsa(
    by_vars = exprs(STUDYID, USUBJID, !!!adsl_vars, VISIT, VISITNUM, ADT, ADY, VSTPT, VSTPTNUM),
    method = "Mosteller",
    set_values_to = exprs(
      PARAMCD = "BSA",
      AVALU = "m^2"
    ),
    get_unit_expr = VSSTRESU,
    filter = VSSTAT != "NOT DONE" | is.na(VSSTAT),
    constant_by_vars = exprs(USUBJID),
    # Below arguments are default values and not necessary to add in our case
    height_code = "HEIGHT",
    weight_code = "WEIGHT"
  )

## ----r eval=TRUE--------------------------------------------------------------
# 创建分析访视变量 AVISIT/AVISITN 和时间点变量 ATPT/ATPTN
# 筛查/非计划/随访访视不计入主要分析（设为 NA），只保留正式访视
advs <- advs %>%
  mutate(
    ATPTN = VSTPTNUM,
    ATPT = VSTPT,
    AVISIT = case_when(
      str_detect(VISIT, "SCREEN|UNSCHED|RETRIEVAL|AMBUL") ~ NA_character_,
      !is.na(VISIT) ~ str_to_title(VISIT),
      TRUE ~ NA_character_
    ),
    AVISITN = as.numeric(case_when(
      VISIT == "BASELINE" ~ "0",
      str_detect(VISIT, "WEEK") ~ str_trim(str_replace(VISIT, "WEEK", "")),
      TRUE ~ NA_character_
    ))
  )

## ----r eval=TRUE--------------------------------------------------------------
# 派生摘要记录：为每次访视计算各参数的均值（DTYPE="AVERAGE"）
# 这些新行被添加到数据集中，供某些分析使用（如多次重复测量取均值）
advs <- derive_summary_records(
  dataset = advs,
  dataset_add = advs, # Observations from the specified dataset are going to be used to calculate and added as new records to the input dataset.
  by_vars = exprs(STUDYID, USUBJID, !!!adsl_vars, PARAMCD, AVISITN, AVISIT, ADT, ADY, AVALU),
  filter_add = !is.na(AVAL),
  set_values_to = exprs(
    AVAL = mean(AVAL),
    DTYPE = "AVERAGE"
  )
)

## ----r eval=TRUE--------------------------------------------------------------
# 派生治疗期标志 ONTRTFL
# filter_pre_timepoint：基线访视（BASELINE）的记录不算"治疗期内"，即使日期在用药后
advs <- derive_var_ontrtfl(
  advs,
  start_date = ADT,
  ref_start_date = TRTSDT,
  ref_end_date = TRTEDT,
  filter_pre_timepoint = toupper(AVISIT) == "BASELINE" # Observations as not on-treatment
)

## ----r include=FALSE----------------------------------------------------------
# 正常值范围参照表：定义各参数的正常范围（ANRLO-ANRHI）和临床参考范围（A1LO-A1HI）
# 血压、脉搏、体温等指标各有不同的判断标准
range_lookup <- tibble::tribble(
  ~PARAMCD, ~ANRLO, ~ANRHI, ~A1LO, ~A1HI,
  "SYSBP",      90,    130,    70,   140,
  "DIABP",      60,     80,    40,    90,
  "PULSE",      60,    100,    40,   110,
  "TEMP",     36.5,   37.5,    35,    38
)

# 将正常范围合并到 advs（按 PARAMCD 匹配）
advs <- derive_vars_merged(
  advs,
  dataset_add = range_lookup,
  by_vars = exprs(PARAMCD)
)

## ----r eval=TRUE--------------------------------------------------------------
# 派生正常范围指示变量 ANRIND（"NORMAL"/"LOW"/"HIGH"）
# 与 SAS PROC FREQ 的范围判断逻辑等效
advs <- derive_var_anrind(
  advs,
  # Below arguments are default values and not necessary to add in our case
  signif_dig = get_admiral_option("signif_digits"),
  use_a1hia1lo = FALSE
)

## ----r eval=TRUE--------------------------------------------------------------
# 按体位（ATPTN）定义不同的基线类型（BASETYPE）
# 同一受试者同一指标可能有多个基线（如卧位基线和站位基线各自独立）
advs <- derive_basetype_records(
  dataset = advs,
  basetypes = exprs(
    "LAST: AFTER LYING DOWN FOR 5 MINUTES" = ATPTN == 815,
    "LAST: AFTER STANDING FOR 1 MINUTE" = ATPTN == 816,
    "LAST: AFTER STANDING FOR 3 MINUTES" = ATPTN == 817,
    "LAST" = is.na(ATPTN)
  )
)

count(advs, ATPT, ATPTN, BASETYPE)

## ----r eval=TRUE--------------------------------------------------------------
# 标记基线记录（ABLFL="Y"）：每个 BASETYPE 内，取用药前（ADT≤TRTSDT）最后一条有效记录
# restrict_derivation 确保只对非汇总记录（is.na(DTYPE)）进行基线标记
advs <- restrict_derivation(
  advs,
  derivation = derive_var_extreme_flag,
  args = params(
    by_vars = exprs(STUDYID, USUBJID, BASETYPE, PARAMCD),
    order = exprs(ADT, VISITNUM, VSSEQ),
    new_var = ABLFL,
    mode = "last", # Determines of the first or last observation is flagged
    # Below arguments are default values and not necessary to add in our case
    true_value = "Y"
  ),
  filter = (!is.na(AVAL) &
    ADT <= TRTSDT & !is.na(BASETYPE) & is.na(DTYPE)
  )
)

## ----r eval=TRUE--------------------------------------------------------------
# 派生基线值 BASE：将 ABLFL="Y" 的 AVAL 值横向填入同 BASETYPE 下所有记录
# BASE 是计算 CHG 和 PCHG 的基准
advs <- derive_var_base(
  advs,
  by_vars = exprs(STUDYID, USUBJID, PARAMCD, BASETYPE),
  source_var = AVAL,
  new_var = BASE,
  # Below arguments are default values and not necessary to add in our case
  filter = ABLFL == "Y"
)

# 同样方式派生基线正常范围指示 BNRIND
advs <- derive_var_base(
  advs,
  by_vars = exprs(STUDYID, USUBJID, PARAMCD, BASETYPE),
  source_var = ANRIND,
  new_var = BNRIND
)

## ----r eval=TRUE--------------------------------------------------------------
# 派生变化量 CHG = AVAL - BASE 和百分变化 PCHG = CHG/BASE × 100
# restrict_derivation 确保只对治疗后记录（AVISITN > 0）计算，基线自身不计算变化量
advs <- restrict_derivation(
  advs,
  derivation = derive_var_chg,
  filter = AVISITN > 0
)

advs <- restrict_derivation(
  advs,
  derivation = derive_var_pchg,
  filter = AVISITN > 0
)

## ----r eval=TRUE--------------------------------------------------------------
# 标记分析记录 ANL01FL：在治疗期内（ONTRTFL="Y"）每个访视/参数/时间点中取最后一条记录
# 这是主要分析表格中使用的标志，避免重复计数
advs <- restrict_derivation(
  advs,
  derivation = derive_var_extreme_flag,
  args = params(
    new_var = ANL01FL,
    by_vars = exprs(STUDYID, USUBJID, PARAMCD, AVISIT, ATPT, DTYPE),
    order = exprs(ADT, AVAL),
    mode = "last", # Determines of the first or last observation is flagged - As seen while deriving ABLFL
    # Below arguments are default values and not necessary to add in our case
    true_value = "Y"
  ),
  filter = !is.na(AVISITN) & ONTRTFL == "Y"
)

## ----r eval=TRUE--------------------------------------------------------------
# 将计划治疗和实际治疗标签从 ADSL 的 TRT01P/TRT01A 复制为 TRTP/TRTA
# ADaM 规范要求用 TRTP/TRTA 而不直接使用 TRT01P/TRT01A
advs <- advs %>%
  mutate(
    TRTP = TRT01P,
    TRTA = TRT01A
  )

count(advs, TRTP, TRTA, TRT01P, TRT01A)

## ----r eval=TRUE--------------------------------------------------------------
# 派生分析序号 ASEQ（每个受试者内的记录序号）
# check_type = "error" 确保序号唯一，如有重复则报错停止
advs <- derive_var_obs_number(
  advs,
  new_var = ASEQ,
  by_vars = exprs(STUDYID, USUBJID),
  order = exprs(PARAMCD, ADT, AVISITN, VISITNUM, ATPTN, DTYPE),
  check_type = "error"
)

## ----r eval=TRUE--------------------------------------------------------------
# 派生分析值分类变量 AVALCAT1：仅对身高（HEIGHT）进行分类
# 这类分类变量用于频数表分析（如>140cm vs ≤140cm的比例）
avalcat_lookup <- exprs(
  ~PARAMCD,  ~condition,   ~AVALCAT1, ~AVALCA1N,
  "HEIGHT",  AVAL > 140,   ">140 cm",         1,
  "HEIGHT", AVAL <= 140, "<= 140 cm",         2
)

advs <- advs %>%
  derive_vars_cat(
    definition = avalcat_lookup,
    by_vars = exprs(PARAMCD)
  )

## ----r------------------------------------------------------------------------
# 查看规格书中 PARAM 的受控术语（用于校验 PARAM 标签是否符合规格）
get_control_term(metacore, variable = PARAM)

## ----r eval=TRUE--------------------------------------------------------------
# 从规格书受控术语为 PARAMCD 创建对应的 PARAM（描述文本）和 PARAMN（数值编码）
# decode_to_code = FALSE 表示 input_var 是代码列，用于查找对应描述
advs <- advs %>%
  create_var_from_codelist(
    metacore,
    input_var = PARAMCD,
    out_var = PARAM,
    decode_to_code = FALSE # input_var is the code column of the codelist
  ) %>%
  create_var_from_codelist(
    metacore,
    input_var = PARAMCD,
    out_var = PARAMN
  )

## ----r eval=TRUE--------------------------------------------------------------
# 将 ADSL 其余变量合并回来（补充人口学和分组变量）
advs <- advs %>%
  derive_vars_merged(
    dataset_add = select(adsl, !!!negate_vars(adsl_vars)),
    by_vars = exprs(STUDYID, USUBJID)
  )

## ----r, message=FALSE, warning=FALSE------------------------------------------
dir <- tempdir() # Specify the directory for saving the XPT file

# Apply metadata and perform checks
# 质控步骤：检查变量完整性和受控术语合规性，按规格排列列和行
advs_prefinal <- advs %>%
  drop_unspec_vars(metacore) %>% # Drop unspecified variables from specs
  check_variables(metacore, dataset_name = "ADVS") %>% # Check all variables specified are present and no more
  order_cols(metacore) %>% # Orders the columns according to the spec
  sort_by_key(metacore) # Sorts the rows by the sort keys

# Apply apply labels, formats, and export the dataset to an XPT file.
# 设置 SAS 格式属性（类型/长度/标签/格式/数据集标签）并导出
advs_final <- advs_prefinal %>%
  xportr_type(metacore) %>%
  xportr_length(metacore) %>%
  xportr_label(metacore) %>%
  xportr_format(metacore, domain = "ADVS") %>%
  xportr_df_label(metacore, domain = "ADVS") %>%
  xportr_write(file.path(dir, "advs.xpt"), metadata = metacore, domain = "ADVS")
