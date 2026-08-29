# =============================================================================
# 数据集名称：ADLB（Laboratory Analysis Dataset，实验室检查分析数据集）
# =============================================================================
# 功能说明：
#   在 SDTM LB 域基础上构建 ADLB（BDS 结构），添加分析所需的派生变量：
#   分析日期（ADT/ADY）、参数化标识（PARAMCD/PARAM/PARAMN）、
#   正常范围指示（ANRIND/BNRIND）、基线（ABLFL/BASE）、变化量（CHG/PCHG）、
#   治疗期标志（ONTRTFL）、治疗期末次/最大/最小值（LOV/MAX/MIN）。
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

# 读入 ADLB 规格（specs.R 中定义；metadata 原始规格书只含 ADSL/ADVS/ADAE）
source("adam/specs.R")

# 读入输入数据
adsl <- pharmaverseadam::adsl
lb <- pharmaversesdtm::lb

# 将 SAS 空字符串转为 NA，确保缺失值判断的一致性
lb <- convert_blanks_to_na(lb)

# 加载 ADLB 规格（metacore 对象）
metacore <- load_dataset_spec("ADLB")

## ----r------------------------------------------------------------------------
# Select required ADSL variables
# 只从 ADSL 提取 ADLB 需要的受试者级变量（治疗日期和治疗标签）
adsl_vars <- exprs(TRTSDT, TRTEDT, TRT01A, TRT01P)

# Join ADSL variables with LB
adlb <- lb %>%
  derive_vars_merged(
    dataset_add = adsl,
    new_vars = adsl_vars,
    by_vars = exprs(STUDYID, USUBJID)
  )

## ----r------------------------------------------------------------------------
# Calculate ADT, ADY
# ADT：将 LBDTC 转换为 R 日期格式（highest_imputation = "n" 不填补不完整日期）
adlb <- adlb %>%
  derive_vars_dt(
    new_vars_prefix = "A",
    dtc = LBDTC,
    highest_imputation = "n",
    flag_imputation = "auto"
  ) %>%
  derive_vars_dy(
    reference_date = TRTSDT,
    source_vars = exprs(ADT)
  )

## ----r------------------------------------------------------------------------
# 创建分析访视变量 AVISIT/AVISITN
# AVISIT：原始访视名转标题大小写；AVISITN：基线访视编号 3 转 0，其余保留
adlb <- adlb %>%
  mutate(
    AVISIT = str_to_title(VISIT),
    AVISITN = ifelse(VISITNUM == 3, 0, as.numeric(VISITNUM))
  )

## ----r------------------------------------------------------------------------
# TODO 1: 补全参数查找表（LBTESTCD → PARAMCD）
#   官方 47 个检验项目中有 9 个改名（ALP→ALKPH、K→POTAS、LYM→LYMPH、CHOL→CHOLES、
#   KETONES→KETON、MACROCY→MACROC、MICROCY→MICROC、POLYCHR→POLYCH、LYMLE→LYMPHLE），
#   其余同名继承。提示：`Rscript -e 'pharmaverseadam::adlb |> dplyr::distinct(LBTESTCD, PARAMCD)'`
# 👉 在这里补 param_lookup <- tibble::tribble(...) 完整 47 项映射
param_lookup_placeholder <- tibble::tribble(
  ~LBTESTCD, ~PARAMCD
)

param_lookup <- param_lookup_placeholder # 占位：填好 TODO 后删掉该行与占位表
attr(param_lookup$LBTESTCD, "label") <- "Laboratory Test Short Name"

# 通过查找表为每条记录赋予 PARAMCD（含 LBTESTCD→PARAMCD 的 9 个改名项）
adlb <- adlb %>%
  derive_vars_merged_lookup(
    dataset_add = param_lookup,
    new_vars = exprs(PARAMCD),
    by_vars = exprs(LBTESTCD),
    print_not_mapped = TRUE
  )

## ----r------------------------------------------------------------------------
# TODO 2: 派生 PARCAT1/AVAL/AVALC/ANRLO/ANRHI 并初始化 DTYPE 列
#   PARCAT1 = LBCAT（参数分类）；AVAL = LBSTRESN（标准化数值）；AVALC = LBSTRESC（定性文本）
#   ANRLO/ANRHI = LBSTNRLO/LBSTNRHI（正常范围）；DTYPE 初始化为 NA（摘要行标志列）
# 👉 在这里补一段 adlb <- adlb %>% mutate(...)
adlb <- adlb %>%
  mutate(PARCAT1 = NA_character_) # 占位：填好 TODO 后删除本行

## ----r------------------------------------------------------------------------
# TODO 3: 派生治疗期标志 ONTRTFL
#   用 derive_var_ontrtfl(adlb, start_date=ADT, ref_start_date=TRTSDT, ref_end_date=TRTEDT)
#   官方口径补充：基线访视（AVISITN==0）记录标为缺失 → filter_pre_timepoint = AVISITN == 0
# 👉 在这里补一段 derive_var_ontrtfl(...)
# 占位：填好 TODO 后删掉这行
identity()

## ----r------------------------------------------------------------------------
# TODO 4: 派生治疗期末次值（DTYPE="LOV"）
#   两步：① restrict_derivation + derive_var_extreme_flag 打标（TEMP_LOVFL，
#   by_vars=STUDYID,USUBJID,PARAMCD；order=ADT,AVISITN,LBSEQ；mode="last"；
#   filter=ONTRTFL=="Y" & is.na(DTYPE) & !is.na(AVAL)）
#   ② 复制打标行为 AVISIT="POST-BASELINE LAST"/AVISITN=9999/DTYPE="LOV" 后 bind_rows
# 👉 在这里补两段代码（参考 TODO 5 下 MAXIMUM 的手工模式）
# 占位：填好 TODO 后删掉这行
identity()

## ----r------------------------------------------------------------------------
# TODO 5: 派生治疗期最大/最小值（DTYPE="MAXIMUM"/"MINIMUM"）——与 LOV 相同的手工模式
#   提示：order 用 exprs(desc(AVAL), ADT)（MAXIMUM）/ exprs(AVAL, ADT)（MINIMUM），mode="first"，
#   打标行复制后改 AVISIT="POST-BASELINE MAXIMUM"/"MINIMUM"（AVISITN=9998/9997）
# 👉 在这里补一段 for 循环（参考 TODO 4 的两步模式）
# 占位：填好 TODO 后删掉这行
identity()

## ----r------------------------------------------------------------------------
# 派生正常范围指示变量 ANRIND（"NORMAL"/"LOW"/"HIGH"）
adlb <- derive_var_anrind(
  adlb,
  signif_dig = get_admiral_option("signif_digits"),
  use_a1hia1lo = FALSE
)

## ----r------------------------------------------------------------------------
# 基线类型（BASETYPE）：本数据集为单一基线类型 "LAST"
adlb <- derive_basetype_records(
  dataset = adlb,
  basetypes = exprs("LAST" = TRUE)
)

## ----r------------------------------------------------------------------------
# 标记基线记录（ABLFL="Y"）：每个受试者/参数/基线类型内，
# 取用药前（ADT≤TRTSDT）最后一条有效记录（排除 DTYPE 摘要行）
adlb <- restrict_derivation(
  adlb,
  derivation = derive_var_extreme_flag,
  args = params(
    by_vars = exprs(STUDYID, USUBJID, BASETYPE, PARAMCD),
    order = exprs(ADT, VISITNUM, LBSEQ),
    new_var = ABLFL,
    mode = "last",
    true_value = "Y"
  ),
  filter = (!is.na(AVAL) &
    ADT <= TRTSDT & !is.na(BASETYPE) & is.na(DTYPE)
  )
)

## ----r------------------------------------------------------------------------
# TODO 6: 派生基线值 BASE 与基线正常范围 BNRIND
#   参考上方 ABLFL 的模式：derive_var_base(adlb, by_vars=exprs(STUDYID,USUBJID,PARAMCD,BASETYPE),
#   source_var=AVAL, new_var=BASE, filter=ABLFL=="Y")；BNRIND 同理（source_var=ANRIND）
# 👉 在这里补两段 derive_var_base(...)
identity() # 占位：填好 TODO 后删掉这行

## ----r------------------------------------------------------------------------
# 派生变化量 CHG = AVAL - BASE 和百分变化 PCHG = CHG/BASE × 100
# 仅对治疗后记录（AVISITN > 0）计算
adlb <- restrict_derivation(
  adlb,
  derivation = derive_var_chg,
  filter = AVISITN > 0
)

adlb <- restrict_derivation(
  adlb,
  derivation = derive_var_pchg,
  filter = AVISITN > 0
)

## ----r------------------------------------------------------------------------
# 将计划治疗和实际治疗标签从 ADSL 的 TRT01P/TRT01A 复制为 TRTP/TRTA
adlb <- adlb %>%
  mutate(
    TRTP = TRT01P,
    TRTA = TRT01A
  )

## ----r------------------------------------------------------------------------
# 派生分析序号 ASEQ（每个受试者内的记录序号）
adlb <- derive_var_obs_number(
  adlb,
  new_var = ASEQ,
  by_vars = exprs(STUDYID, USUBJID),
  order = exprs(PARAMCD, ADT, AVISITN, VISITNUM, DTYPE),
  check_type = "error"
)

## ----r------------------------------------------------------------------------
# 从规格书受控术语为 PARAMCD 创建对应的 PARAM（文本）和 PARAMN（数值编码）
adlb <- adlb %>%
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
# 将 ADSL 其余变量合并回来（补充人口学和分组变量）
adlb <- adlb %>%
  derive_vars_merged(
    dataset_add = select(adsl, !!!negate_vars(adsl_vars)),
    by_vars = exprs(STUDYID, USUBJID)
  )

## ----r, message=FALSE, warning=FALSE------------------------------------------
dir <- "users/<STUDENT_NAME>/adam/output" # Specify the directory for saving the XPT file
dir.create(dir, showWarnings = FALSE, recursive = TRUE)

# 质控步骤：检查变量完整性和受控术语合规性，按规格排列列和行
adlb_prefinal <- adlb %>%
  drop_unspec_vars(metacore) %>%
  check_variables(metacore, dataset_name = "ADLB") %>%
  order_cols(metacore) %>%
  sort_by_key(metacore)

# 设置 SAS 格式属性（类型/长度/标签/格式/数据集标签）并导出
adlb_final <- adlb_prefinal %>%
  xportr_type(metacore) %>%
  xportr_length(metacore) %>%
  xportr_label(metacore) %>%
  xportr_format(metacore, domain = "ADLB") %>%
  xportr_df_label(metacore, domain = "ADLB") %>%
  xportr_write(file.path(dir, "adlb.xpt"), metadata = metacore, domain = "ADLB")
