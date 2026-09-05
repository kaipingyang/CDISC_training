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
# 使用的包：
#   - admiral         : ADaM 构建核心工具包
#   - metacore/metatools : 规格书驱动的变量校验（规格见 adam/specs.R）
#   - xportr          : 导出为 SAS 传输文件
#   - pharmaversesdtm/pharmaverseadam : SDTM 示例数据（EG）与 ADSL
#
# 输入数据来源：
#   - pharmaverseadam::adsl : ADSL（提供治疗开始/结束日和治疗标签）
#   - pharmaversesdtm::eg   : SDTM EG 域（心电图基础数据）
#   - adam/specs.R          : ADEG 数据集规格
#
# 输出文件：
#   - adeg.xpt（SAS 传输文件，写入 adam/output/）
#
# 关键概念说明（给不熟悉 R 的临床数据人员）：
#   BDS（Basic Data Structure）：参数化长表，每行一个心电图指标的一次测量
#   PARAMCD/PARAM：指标代码/全称（QT/HR/RR + 衍生 QTCBR（Bazett 校正）、
#     QTCFR（Fridericia）、QTLCR（Sagie）、RRR（心率逆算））
#   AVAL：分析值（EGSTRESN）；EGINTP（心电图判读）行为定性结果（AVAL 为 NA，值在 AVALC）
#   ABLFL/BASE：基线标志 / 基线值（Day 1 用药前，变化量的参照点）
#   CHG = AVAL - BASE；PCHG = (AVAL - BASE)/BASE × 100
#   AVERAGE：单次访视多个时间点（ATPTN 815/816/817）的均值摘要行（DTYPE="AVERAGE"）
#   ANRLO/ANRHI：心率 40-100、QT 类 350-450、RR 类 600-1500（方案定义范围参照表）
#   AVALCAT1/CHGCAT1：QT 绝对值和变化量的安全分档（≤450 / 450-480 / 480-500 / >500；
#     CHG ≤30 / 30-60 / >60 ms）
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
# 创建分析访视与时间点变量：AVISIT/AVISITN（周数，Baseline→0）与 ATPT/ATPTN（时间点）
adeg <- adeg %>%
  mutate(
    ATPT = EGTPT,
    ATPTN = EGTPTNUM,
    AVISIT = str_to_title(VISIT),
    AVISITN = ifelse(VISITNUM == 3, 0,
      as.numeric(sub("^WEEK ", "", VISIT)))
  )

## ----r------------------------------------------------------------------------
# 参数查找表：SDTM 的 EGTESTCD → ADaM 的 PARAMCD（4 个原始指标）
param_lookup <- tibble::tribble(
  ~EGTESTCD, ~PARAMCD,
  "ECGINT", "EGINTP",
  "HR", "HR",
  "QT", "QT",
  "RR", "RR"
)
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
# 衍生参数：QT 校正（Bazett/Fridericia/Sagie）与呼吸周期 RRR（HR 逆算）
# 这些是 ECG 安全性分析的核心衍生指标
adeg <- adeg %>%
  derive_param_qtc(
    by_vars = exprs(STUDYID, USUBJID, !!!adsl_vars, VISIT, VISITNUM, ADT, ADY,
                    ATPT, ATPTN, AVISIT, AVISITN, EGTPTNUM),
    method = "Bazett",
    qt_code = "QT",
    rr_code = "RR",
    get_unit_expr = EGSTRESU
  ) %>%
  derive_param_qtc(
    by_vars = exprs(STUDYID, USUBJID, !!!adsl_vars, VISIT, VISITNUM, ADT, ADY,
                    ATPT, ATPTN, AVISIT, AVISITN, EGTPTNUM),
    method = "Fridericia",
    qt_code = "QT",
    rr_code = "RR",
    get_unit_expr = EGSTRESU
  ) %>%
  derive_param_qtc(
    by_vars = exprs(STUDYID, USUBJID, !!!adsl_vars, VISIT, VISITNUM, ADT, ADY,
                    ATPT, ATPTN, AVISIT, AVISITN, EGTPTNUM),
    method = "Sagie",
    qt_code = "QT",
    rr_code = "RR",
    get_unit_expr = EGSTRESU
  ) %>%
  derive_param_rr(
    by_vars = exprs(STUDYID, USUBJID, !!!adsl_vars, VISIT, VISITNUM, ADT, ADY,
                    ATPT, ATPTN, AVISIT, AVISITN, EGTPTNUM),
    get_unit_expr = EGSTRESU,
    hr_code = "HR"
  )

## ----r------------------------------------------------------------------------
# 派生析写（ADEG 无 LOV/MAX/MIN）——治疗期标志 ONTRTFL
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
# 同一访视内多个时间点（ATPTN 815/816/817）的心电图测量取均值
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
# 基线类型（BASETYPE）：单一基线类型，全行覆盖 "BASELINE DAY 1"
# ⚠ 要点 1：derive_basetype_records 的"无基线"分支会丢弃条件算出 NA 的行——条件必须
#   对每行都返回 TRUE/FALSE，直接写 TRUE 最稳（AVERAGE/非编号访视行一个都不会丢）。
# ⚠ 要点 2：BASETYPE 只负责把记录归入"基线参照组"（BASE 按 USUBJID/PARAMCD/BASETYPE 回填，
#   全行同组 Week 行才拿得到 BASE 派生 CHG）；真正的"哪条是基线"由下方 ABLFL 的
#   filter（用药前）+ order（最后一条）决定。若只把 AVISITN==0 行标为基线类型，
#   Week 等后续访视行的 BASE/CHG 将永远派生不出来。
adeg <- derive_basetype_records(
  dataset = adeg,
  basetypes = exprs("BASELINE DAY 1" = TRUE)
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

# 派生基线值 BASE 与基线正常范围指示 BNRIND
adeg <- adeg %>%
  derive_var_base(
    by_vars = exprs(STUDYID, USUBJID, PARAMCD, BASETYPE),
    source_var = AVAL,
    new_var = BASE,
    filter = ABLFL == "Y"
  ) %>%
  derive_var_base(
    by_vars = exprs(STUDYID, USUBJID, PARAMCD, BASETYPE),
    source_var = ANRIND,
    new_var = BNRIND
  )

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
# QT 分档（AVALCAT1）与变化量分档（CHGCAT1）：
# 安全性分析中常用的"QT 延长"阈值分类（>450/480/500ms；CHG >30/60ms）
adeg <- adeg %>%
  derive_vars_cat(
    definition = exprs(
      ~PARAMCD,   ~condition,        ~AVALCAT1,  ~AVALCA1N,
      "QT",   AVAL <= 450,        "<= 450 ms",       1,
      "QT",   AVAL > 450 & AVAL <= 480, ">450<=480 ms", 2,
      "QT",   AVAL > 480 & AVAL <= 500, ">480<=500 ms", 3,
      "QT",   AVAL > 500,        ">500 ms",          4
    ),
    by_vars = exprs(PARAMCD)
  ) %>%
  derive_vars_cat(
    definition = exprs(
      ~PARAMCD,   ~condition,          ~CHGCAT1,       ~CHGCAT1N,
      "QT",   CHG <= 30,           "<= 30 ms",         1,
      "QT",   CHG > 30 & CHG <= 60, ">30<=60 ms",       2,
      "QT",   CHG > 60,            ">60 ms",           3
    ),
    by_vars = exprs(PARAMCD)
  )

## ----r------------------------------------------------------------------------
# 将计划治疗和实际治疗标签从 ADSL 的 TRT01P/TRT01A 复制为 TRTP/TRTA
adeg <- adeg %>%
  mutate(
    TRTP = TRT01P,
    TRTA = TRT01A
  )

## ----r------------------------------------------------------------------------
# 派生分析序号 ASEQ（每个受试者内的记录序号）
# ⚠ order 列必须能逐行区分记录：同一受试者同一日期有多条 AVERAGE 均值行
#   （按体位时间点 ATPTN 区分，本数据每日期 3 条）；同一受试者同一天可能完成
#   多场访视（如 SCREENING 1 与 2 同日）——原始记录按 EGSEQ 区分，其派生参数行
#   （QTc/RRR 不携带 EGSEQ）按 VISIT 区分。order 缺区分列时 check_type="error"
#   会报 "duplicate records" 错误——补上 ATPTN、VISIT、EGSEQ 即可。
adeg <- derive_var_obs_number(
  adeg,
  new_var = ASEQ,
  by_vars = exprs(STUDYID, USUBJID),
  order = exprs(PARAMCD, ADT, VISIT, AVISITN, EGTPTNUM, DTYPE, ATPTN, EGSEQ),
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
dir <- "adam/output" # Specify the directory for saving the XPT file
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

message("ADEG 生成完成！文件已保存为 adeg.xpt")
