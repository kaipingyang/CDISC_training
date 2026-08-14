# =============================================================================
# 数据集名称：ADAE（Adverse Event Analysis Dataset，不良事件分析数据集）
# =============================================================================
# 功能说明：
#   在 SDTM AE 域基础上，添加 ADaM 分析所需的派生变量，包括：
#   分析日期（ASTDT/AENDT）、研究日（ASTDY/AENDY）、治疗期内标志（TRTEMFL）、
#   最严重事件标志（AOCCIFL）、医学查询变量（CQ01NAM/SMQ02NAM）等。
#
# 使用的包：
#   - admiral         : ADaM 构建核心工具包
#   - metacore/metatools : 规格书驱动的变量校验
#   - xportr          : 导出为 SAS 传输文件
#   - pharmaversesdtm : SDTM 示例数据
#   - pharmaverseadam : ADaM 示例数据（ADSL）
#
# 输入数据来源：
#   - pharmaverseadam::adsl    : ADSL（提供治疗开始/结束日期等受试者级变量）
#   - pharmaversesdtm::ae      : SDTM AE 域（不良事件基础数据）
#   - pharmaversesdtm::ex      : SDTM EX 域（用药记录，用于末次用药日期）
#   - metadata/safety_specs.xlsx : ADaM 规格书
#
# 输出文件：
#   - adae.xpt（SAS 传输文件，写入 tempdir()）
#
# 关键概念说明：
#   TRTEMFL：治疗期内发生的不良事件标志（"Treatment-Emergent"），是安全性分析的核心
#   ONTRTFL：与 TRTEMFL 类似，但定义稍宽松（结束日期后30天内也标记）
#   ASTDT/AENDT：分析用的开始/结束日期（可能与 AESTDTC/AEENDTC 不同，因为做了填补）
#   AESTDY/AEENDY：相对首次用药日的研究日（正数=用药后，负数=用药前）
#   MedDRA 查询（SMQ/CQ）：将相关不良事件归入预定义的医学术语集，支持信号检测
# =============================================================================

# =============================================================================
# 【练习版】按 # TODO 提示填空。填不出就问 Claude Code："帮我补全这个 TODO"。
# 参考答案：adam/adae.R（完整版，别改它）—— 先自己填，卡住再看。
# =============================================================================

## ----r setup, message=FALSE, warning=FALSE, results='hold'--------------------
library(metacore)
library(metatools)
library(pharmaversesdtm)
library(pharmaverseadam)
library(admiral)
library(xportr)
library(dplyr)
library(lubridate)
library(stringr)
library(reactable)

# Read in input data
adsl <- pharmaverseadam::adsl
ae <- pharmaversesdtm::ae
ex <- pharmaversesdtm::ex

# When SAS datasets are imported into R using haven::read_sas(), missing
# character values from SAS appear as "" characters in R, instead of appearing
# as NA values. Further details can be obtained via the following link:
# https://pharmaverse.github.io/admiral/articles/admiral.html#handling-of-missing-values
# 将 SAS 空字符串转为 NA，确保缺失值判断的一致性
ae <- convert_blanks_to_na(ae)
ex <- convert_blanks_to_na(ex)

## ----r echo=TRUE--------------------------------------------------------------
# ---- Load Specs for Metacore ----
# 读取 ADAE 的规格书，用于后续变量校验和格式设置
metacore <- spec_to_metacore(
  path = "./metadata/safety_specs.xlsx",
  # All datasets are described in the same sheet
  where_sep_sheet = FALSE
) %>%
  select_dataset("ADAE")

## ----r------------------------------------------------------------------------
# Select required ADSL variables
# 只从 ADSL 提取 ADAE 需要的变量（治疗开始/结束日和死亡日），减少数据冗余
adsl_vars <- exprs(TRTSDT, TRTEDT, DTHDT)

# Join ADSL variables with VS
# TODO 1: 把 ADSL 的受试者级治疗日期合并到每条 AE 记录上
#   用 derive_vars_merged，从 adsl 取 adsl_vars（TRTSDT/TRTEDT/DTHDT）横向合并到 ae。
#   后续 ASTDT 填补、TRTEMFL 判断都要用到这些基准日期。
#   要点：
#     - 起点是 ae（管道左侧已给出 ae %>%）
#     - dataset_add = adsl
#     - new_vars    = adsl_vars
#     - by_vars     = exprs(STUDYID, USUBJID)
# 👉 把下面的 identity() 换成 derive_vars_merged(...)
adae <- ae %>%
  identity()   # 占位：填好上面 TODO 后改成 derive_vars_merged(...)

## ----r------------------------------------------------------------------------
# Derive ASTDT/ASTDTF/ASTDY and AENDT/AENDTF/AENDY
# 先派生结束日期 AENDT（因为 ASTDT 填补时需要 AENDT 作为上限）
# highest_imputation = "M" 允许对缺失月份进行填补
# flag_imputation = "auto" 自动创建 AENDTF 变量记录填补标志
adae <- adae %>%
  derive_vars_dt(
    new_vars_prefix = "AEN",
    dtc = AEENDTC,
    date_imputation = "last",
    highest_imputation = "M", # imputation is performed on missing days or months
    flag_imputation = "auto" # to automatically create AENDTF variable
  ) %>%
  derive_vars_dt(
    new_vars_prefix = "AST",
    dtc = AESTDTC,
    highest_imputation = "M", # imputation is performed on missing days or months
    flag_imputation = "auto", # to automatically create ASTDTF variable
    min_dates = exprs(TRTSDT), # apply a minimum date for the imputation
    max_dates = exprs(AENDT) # apply a maximum date for the imputation
  ) %>%
  # 计算相对研究日：ASTDY（AE开始相对首次用药），AENDY（AE结束相对首次用药）
  derive_vars_dy(
    reference_date = TRTSDT,
    source_vars = exprs(ASTDT, AENDT)
  )

## ----r------------------------------------------------------------------------
# Derive ADURN/ADURU
# 计算不良事件持续时间（天数），提供给安全性统计使用
adae <- adae %>%
  derive_vars_duration(
    new_var = ADURN,
    new_var_unit = ADURU,
    start_date = ASTDT,
    end_date = AENDT
  )

## ----r------------------------------------------------------------------------
# Derive LDOSEDT
# In our ex data the EXDOSFRQ (frequency) is "QD" which stands for once daily
# If this was not the case then we would need to use the admiral::create_single_dose_dataset() function
# to generate single doses from aggregate dose information
# Refer to https://pharmaverse.github.io/admiral/reference/create_single_dose_dataset.html
# 将 EX 域的用药结束日期转换为日期格式，准备用于计算末次用药日期
ex <- ex %>%
  derive_vars_dt(
    dtc = EXENDTC,
    new_vars_prefix = "EXEN"
  )

# 找到每个 AE 开始前（≤ASTDT）最近的一次用药结束日期作为 LDOSEDT（末次给药日期）
# 这对判断"用药期间发生的AE"（TRTEMFL）至关重要
adae <- adae %>%
  derive_vars_joined(
    dataset_add = ex,
    by_vars = exprs(STUDYID, USUBJID),
    order = exprs(EXENDT),
    new_vars = exprs(LDOSEDT = EXENDT),
    join_vars = exprs(EXENDT),
    join_type = "all",
    filter_add = (EXDOSE > 0 | (EXDOSE == 0 & str_detect(EXTRT, "PLACEBO"))) & !is.na(EXENDT),
    filter_join = EXENDT <= ASTDT,
    mode = "last"
  )

## ----r------------------------------------------------------------------------
# Derive TRTEMFL and ONTRTFL
# TRTEMFL：治疗期内新发或加重的不良事件（首次用药后开始，或用药前存在但用药后加重）
# ONTRTFL：在治疗期间活跃的不良事件（ref_end_window=30表示末次用药后30天内也算）
adae <- adae %>%
  # TODO 2: 标记治疗期间不良事件 TRTEMFL（Treatment-Emergent AE Flag）
  #   用 derive_var_trtemfl，判断 AE 开始日 ASTDT 是否落在治疗期 TRTSDT~TRTEDT 内。
  #   要点：
  #     - start_date     = ASTDT，end_date = AENDT
  #     - trt_start_date = TRTSDT，trt_end_date = TRTEDT
  # 👉 在这里补一段 derive_var_trtemfl(...)
  identity() %>%   # 占位：填好上面 TODO 后删掉这行 identity() %>%
  derive_var_ontrtfl(
    start_date = ASTDT,
    ref_start_date = TRTSDT,
    ref_end_date = TRTEDT,
    ref_end_window = 30
  )

## ----r------------------------------------------------------------------------
# Derive AOCCIFL
# 为每个受试者找出其最严重的 AE 记录（按 AESEV 降序排列，严重程度：SEVERE>MODERATE>MILD）
# TEMP_AESEVN 是临时数值变量，用于排序（数值越小越严重），最后标记第一条为 AOCCIFL="Y"
adae <- adae %>%
  # create temporary numeric ASEVN for sorting purpose
  mutate(TEMP_AESEVN = as.integer(factor(AESEV, levels = c("SEVERE", "MODERATE", "MILD")))) %>%
  derive_var_extreme_flag(
    new_var = AOCCIFL,
    by_vars = exprs(STUDYID, USUBJID),
    order = exprs(TEMP_AESEVN, ASTDT, AESEQ),
    mode = "first"
  )

## ----r------------------------------------------------------------------------
# 读取预定义的 MedDRA 查询集合（admiral 包内置示例）
# 仅保留 CQ01（自定义查询1）和 SMQ02（标准化 MedDRA 查询2），用于信号检测分析
queries <- admiral::queries %>%
  filter(PREFIX %in% c("CQ01", "SMQ02"))

## ----r------------------------------------------------------------------------
# Derive CQ01NAM and SMQ02NAM
# 根据 MedDRA 查询条件为每条 AE 记录标注所属查询组名称
# SMQ 常用于聚合相关 AE 进行安全性信号检测（如肝毒性 SMQ）
adae <- adae %>%
  derive_vars_query(dataset_queries = queries)

## ----r eval=TRUE--------------------------------------------------------------
# 将 ADSL 其余变量合并回来（排除之前已合并的 TRTSDT/TRTEDT/DTHDT，避免重复）
# negate_vars 等价于 "ADSL 除了这几个变量以外的所有变量"
adae <- adae %>%
  derive_vars_merged(
    dataset_add = select(adsl, !!!negate_vars(adsl_vars)),
    by_vars = exprs(STUDYID, USUBJID)
  )

## ----r checks, warning=FALSE, message=FALSE-----------------------------------
# 最终质控和导出：
# drop_unspec_vars : 删除规格书中未定义的变量（保持提交数据集干净）
# check_variables  : 确认规格变量完整
# check_ct_data    : 验证受控术语值合规
# order_cols/sort_by_key : 按规格排列列和行
# xportr_* : 设置 SAS 格式属性并导出 .xpt
dir <- tempdir() # Specify the directory for saving the XPT file

adae %>%
  drop_unspec_vars(metacore) %>% # Drop unspecified variables from specs
  check_variables(metacore) %>% # Check all variables specified are present and no more
  check_ct_data(metacore, na_acceptable = TRUE) %>% # Checks all variables with CT only contain values within the CT
  order_cols(metacore) %>% # Orders the columns according to the spec
  sort_by_key(metacore) %>% # Sorts the rows by the sort keys
  xportr_type(metacore, domain = "ADAE") %>% # Coerce variable type to match spec
  xportr_length(metacore) %>% # Assigns SAS length from a variable level metadata
  xportr_label(metacore) %>% # Assigns variable label from metacore specifications
  xportr_df_label(metacore) %>% # Assigns dataset label from metacore specifications
  xportr_write(file.path(dir, "adae.xpt"), metadata = metacore, domain = "ADAE")
