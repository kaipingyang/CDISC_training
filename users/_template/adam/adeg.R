# =============================================================================
# 数据集名称：ADEG（ECG Analysis Dataset，心电图分析数据集）
# =============================================================================
# 功能说明：
#   在 SDTM EG 域基础上构建 ADEG（BDS 结构），添加分析所需的派生变量：
#   分析日期（ADT/ADY）、参数化标识（PARAMCD/PARAM/PARAMN）、
#   心电图衍生参数（QTcBazett/QTcFridericia/QTCL/HR/RR 等）、
#   基线（ABLFL/BASE）、变化量（CHG/PCHG）、正常范围指示（ANRIND/BNRIND）、
#   治疗期标志（ONTRTFL）、QT 分档（AVALCAT1/CHGCAT1）。
#
# =============================================================================
# 【练习版】按 # TODO 提示填空。填不出就问 Claude Code："帮我补全这个 TODO"——
# 练习模式只会给提示，不会直接读答案，也不会替你写完整版。
# 写完自查：跟 Claude Code 说"我写完了，帮我对照检查"，它会逐条说明差异。
# 项目根的 sdtm/ adam/ tfl/ 是完整答案脚本（供对照，勿改），练习时不要读/改它们。
# =============================================================================

## ----r setup, message=FALSE, warning=FALSE, results='hold'--------------------
library(metacore)
library(metatools)
library(pharmaversesdtm)
library(pharmaverseadam)
library(admiral)
library(xportr)
library(dplyr)
library(tidyr)
library(lubridate)
library(stringr)

# 读入 ADEG 规格（specs.R 中定义；metadata 原始规格书只含 ADSL/ADVS/ADAE）
source("adam/specs.R")

# 读入输入数据
adsl <- pharmaverseadam::adsl
eg <- pharmaversesdtm::eg

# 将 SAS 空字符串转为 NA
eg <- convert_blanks_to_na(eg)

# 加载 ADEG 规格（metacore 对象）
metacore <- load_dataset_spec("ADEG")

## ----r------------------------------------------------------------------------
# Select required ADSL variables
adsl_vars <- exprs(TRTSDT, TRTEDT, TRT01A, TRT01P)

# Join ADSL variables with EG
adeg <- eg %>%
  derive_vars_merged(
    dataset_add = adsl,
    new_vars = adsl_vars,
    by_vars = exprs(STUDYID, USUBJID)
  )

## ----r------------------------------------------------------------------------
# Calculate ADT, ADY
adeg <- adeg %>%
  derive_vars_dt(
    new_vars_prefix = "A",
    dtc = EGDTC,
    highest_imputation = "n",
    flag_imputation = "auto"
  ) %>%
  derive_vars_dy(
    reference_date = TRTSDT,
    source_vars = exprs(ADT)
  )

## ----r------------------------------------------------------------------------
# 创建分析访视与时间点变量：AVISIT/AVISITN（周数，Baseline→0）与 ATPT/ATPTN
adeg <- adeg %>%
  mutate(
    ATPT = EGTPT,
    ATPTN = EGTPTNUM,
    AVISIT = str_to_title(VISIT),
    AVISITN = ifelse(VISITNUM == 3, 0,
      as.numeric(sub("^WEEK ", "", VISIT)))
  )

## ----r------------------------------------------------------------------------
# TODO 1: 补全参数查找表（EGTESTCD → PARAMCD）：4 个原始指标 ECGINT/HR/QT/RR
#   分别映射为 EGINTP/HR/QT/RR（EGINTP 是心电图判读，定性结果）
# 👉 在这里补 param_lookup <- tibble::tribble(...)
param_lookup_placeholder <- tibble::tribble(
  ~EGTESTCD, ~PARAMCD
)

param_lookup <- param_lookup_placeholder # 占位：填好 TODO 后删掉该行与占位表
attr(param_lookup$EGTESTCD, "label") <- "ECG Test Short Name"

adeg <- adeg %>%
  derive_vars_merged_lookup(
    dataset_add = param_lookup,
    new_vars = exprs(PARAMCD),
    by_vars = exprs(EGTESTCD),
    print_not_mapped = TRUE
  ) %>%
  # AVAL/AVALC：EGINTP（判读）行 AVAL 为 NA（定性结果），其余用标准化数值
  mutate(
    AVAL = ifelse(PARAMCD == "EGINTP", NA, as.numeric(EGSTRESN)),
    AVALC = EGSTRESC
  )

## ----r------------------------------------------------------------------------
# TODO 2: 派生 ECG 衍生参数 —— QT 校正（Bazett/Fridericia/Sagie）与 RRR（心率逆算）
#   derive_param_qtc（method 分别为 "Bazett"/"Fridericia"/"Sagie"，qt_code="QT"，
#   rr_code="RR"，get_unit_expr=EGSTRESU）+ derive_param_rr（hr_code="HR"）
#   注意 by_vars 要显式列全后续保留的变量（参考下方 AVISIT 一行）。四段派生接 pipe。
# 👉 在这里补四段派生
adeg <- adeg

## ----r------------------------------------------------------------------------
# 派生治疗期标志 ONTRTFL（基线访视记录标为缺失）
adeg <- derive_var_ontrtfl(
  adeg,
  start_date = ADT,
  ref_start_date = TRTSDT,
  ref_end_date = TRTEDT,
  filter_pre_timepoint = AVISITN == 0
)

## ----r------------------------------------------------------------------------
# 正常范围参照表：心率/ QT / RR 类参数（方案定义范围，SDTM 无此栏位）
range_lookup <- tibble::tribble(
  ~PARAMCD, ~ANRLO, ~ANRHI,
  "HR",        40,   100,
  "QT",       350,   450,
  "QTCBR",    350,   450,
  "QTCFR",    350,   450,
  "QTLCR",    350,   450,
  "RR",       600,  1500,
  "RRR",      600,  1500
)

adeg <- derive_vars_merged(
  adeg,
  dataset_add = range_lookup,
  by_vars = exprs(PARAMCD)
) %>%
  # 派生正常范围指示变量 ANRIND
  derive_var_anrind()

## ----r------------------------------------------------------------------------
# 派生摘要记录：每个受试者/参数/访视的均值行（DTYPE="AVERAGE"）
adeg <- derive_summary_records(
  dataset = adeg,
  dataset_add = adeg,
  by_vars = exprs(STUDYID, USUBJID, !!!adsl_vars, PARAMCD, ATPT, ATPTN, ADT, ADY),
  filter_add = !is.na(AVAL),
  set_values_to = exprs(
    AVAL = mean(AVAL),
    DTYPE = "AVERAGE"
  )
)

## ----r------------------------------------------------------------------------
# 基线类型（BASETYPE）：本数据集为 "BASELINE DAY 1"（基期访视 = 用药前 Day 1）
adeg <- derive_basetype_records(
  dataset = adeg,
  basetypes = exprs("BASELINE DAY 1" = AVISITN == 0)
)

## ----r------------------------------------------------------------------------
# 标记基线记录（ABLFL="Y"）：每个受试者/参数/基线类型内，
# 取用药前（ADT≤TRTSDT）最后一次有效记录
adeg <- restrict_derivation(
  adeg,
  derivation = derive_var_extreme_flag,
  args = params(
    by_vars = exprs(STUDYID, USUBJID, BASETYPE, PARAMCD),
    order = exprs(ADT, EGTPTNUM, EGSEQ),
    new_var = ABLFL,
    mode = "last",
    true_value = "Y"
  ),
  filter = (!is.na(AVAL) &
    ADT <= TRTSDT & !is.na(BASETYPE) & is.na(DTYPE)
  )
)

## ----r------------------------------------------------------------------------
# TODO 3: 派生基线值 BASE 与基线正常范围 BNRIND
#   derive_var_base 两次（source_var 分别为 AVAL / ANRIND，by_vars=exprs(STUDYID,USUBJID,PARAMCD,BASETYPE)，
#   第一次 filter=ABLFL=="Y"）
# 👉 在这里补两段 derive_var_base(...)
identity() # 占位：填好 TODO 后删掉这行

## ----r------------------------------------------------------------------------
# 派生变化量 CHG 和百分变化 PCHG（仅治疗后记录）
adeg <- restrict_derivation(
  adeg,
  derivation = derive_var_chg,
  filter = AVISITN > 0
)

adeg <- restrict_derivation(
  adeg,
  derivation = derive_var_pchg,
  filter = AVISITN > 0
)

## ----r------------------------------------------------------------------------
# TODO 4: 补全 QT 分档（AVALCAT1/AVALCA1N）与变化量分档（CHGCAT1/CHGCAT1N）
#   AVALCAT1：<= 450 / >450<=480 / >480<=500 / >500 ms（AVALCA1N=1/2/3/4）
#   CHGCAT1 ：<= 30 / >30<=60 / >60 ms（CHGCAT1N=1/2/3）
#   用 derive_vars_cat(definition = exprs(~PARAMCD, ~condition, ...), by_vars=exprs(PARAMCD))
#   注意 condition 中 AVAL 要用 PARAMCD=="QT" 限定
# 👉 在这里补两段 derive_vars_cat(...)
adeg <- adeg

## ----r------------------------------------------------------------------------
# 将计划治疗和实际治疗标签从 ADSL 的 TRT01P/TRT01A 复制为 TRTP/TRTA
adeg <- adeg %>%
  mutate(
    TRTP = TRT01P,
    TRTA = TRT01A
  )

## ----r------------------------------------------------------------------------
# 派生分析序号 ASEQ（每个受试者内的记录序号）
adeg <- derive_var_obs_number(
  adeg,
  new_var = ASEQ,
  by_vars = exprs(STUDYID, USUBJID),
  order = exprs(PARAMCD, ADT, AVISITN, EGTPTNUM, DTYPE),
  check_type = "error"
)

## ----r------------------------------------------------------------------------
# 从规格书受控术语为 PARAMCD 创建 PARAM（文本）和 PARAMN（数值编码）
adeg <- adeg %>%
  create_var_from_codelist(
    metacore,
    input_var = PARAMCD,
    out_var = PARAM,
    decode_to_code = FALSE
  ) %>%
  create_var_from_codelist(
    metacore,
    input_var = PARAMCD,
    out_var = PARAMN,
    decode_to_code = FALSE
  )

## ----r------------------------------------------------------------------------
# 将 ADSL 其余变量合并回来
adeg <- adeg %>%
  derive_vars_merged(
    dataset_add = select(adsl, !!!negate_vars(adsl_vars)),
    by_vars = exprs(STUDYID, USUBJID)
  )

## ----r, message=FALSE, warning=FALSE------------------------------------------
dir <- "users/<STUDENT_NAME>/adam/output" # Specify the directory for saving the XPT file
dir.create(dir, showWarnings = FALSE, recursive = TRUE)

# 质控步骤：检查变量完整性和受控术语合规性，按规格排列列和行
adeg_prefinal <- adeg %>%
  drop_unspec_vars(metacore) %>%
  check_variables(metacore, dataset_name = "ADEG") %>%
  order_cols(metacore) %>%
  sort_by_key(metacore)

# 设置 SAS 格式属性（类型/长度/标签/格式/数据集标签）并导出
adeg_final <- adeg_prefinal %>%
  xportr_type(metacore) %>%
  xportr_length(metacore) %>%
  xportr_label(metacore) %>%
  xportr_format(metacore, domain = "ADEG") %>%
  xportr_df_label(metacore, domain = "ADEG") %>%
  xportr_write(file.path(dir, "adeg.xpt"), metadata = metacore, domain = "ADEG")
