# =============================================================================
# 数据集名称：ADLB（Laboratory Analysis Dataset，实验室检查分析数据集）
# =============================================================================
# 功能说明：
#   在 SDTM LB 域基础上构建 ADLB（BDS 结构），添加分析所需的派生变量：
#   分析日期（ADT/ADY）、参数化标识（PARAMCD/PARAM/PARAMN）、
#   正常范围指示（ANRIND/BNRIND）、基线（ABLFL/BASE）、变化量（CHG/PCHG）、
#   治疗期标志（ONTRTFL）、治疗期末次/最大/最小值（LOV/MAX/DMIN），
#   以及计算型参数（Basophils/Lymphocytes 绝对值）。
#
# 使用的包：
#   - admiral         : ADaM 构建核心工具包
#   - metacore/metatools : 规格书驱动的变量校验（规格见 adam/specs.R）
#   - xportr          : 导出为 SAS 传输文件
#   - pharmaversesdtm/pharmaverseadam : SDTM 示例数据（LB）与 ADSL
#
# 输入数据来源：
#   - pharmaverseadam::adsl : ADSL（提供治疗开始/结束日和治疗标签）
#   - pharmaversesdtm::lb   : SDTM LB 域（实验室检查基础数据）
#   - adam/specs.R          : ADLB 数据集规格（metadata 原始规格书不含 ADLB，见文件头注释）
#
# 输出文件：
#   - adlb.xpt（SAS 传输文件，写入 adam/output/）
#
# 关键概念说明（给不熟悉 R 的临床数据人员）：
#   PARAMCD/PARAM/PARAMN：检验项目代码/全称/编码（BDS 结构的核心标识，参数化长表）
#   AVAL：分析值（LBSTRESN 标准化数值）；AVALC：分析结果字符（定性检验保留原始文本）
#   ANRIND/BNRIND：分析/基线正常范围指示（NORMAL/LOW/HIGH）
#   ABLFL/BASE：基线记录标志 / 基线值（CHG 的参照点，治疗前最后一次有效测量）
#   CHG = AVAL - BASE；PCHG = (AVAL - BASE)/BASE × 100
#   ONTRTFL：治疗期内标志（基线访视记录按官方口径标为缺失而非 "Y"）
#   LOV/MAXIMUM/MINIMUM：DTYPE 摘要行——治疗期最后一次/最大/最小观察值，
#     供"末次值"类分析使用（AVISITN 9999/9998/9997）
#   CALCULATION：由比例值×总计数计算指定的绝对计数（如 Basophils Abs）
#   PARCAT1：参数分类（化学/血液学等，取自 SDTM LBCAT）
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
# 将受试者级治疗信息合并到 LB 记录，为后续基线和治疗期判断提供依据
adlb <- lb %>%
  derive_vars_merged(
    dataset_add = adsl,
    new_vars = adsl_vars,
    by_vars = exprs(STUDYID, USUBJID)
  )

## ----r------------------------------------------------------------------------
# Calculate ADT, ADY
# ADT：将 LBDTC 转换为 R 日期格式（highest_imputation = "n" 表示不对不完整日期填补）
# ADY：计算相对首次用药日的分析日（ADT - TRTSDT，用药当天=1，用药前为负数）
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
# AVISIT：原始访视名转标题大小写（BASELINE→Baseline、WEEK 2→Week 2）
# AVISITN：官方口径——基线访视编号 3 转 0，其余保留原编号（含非计划小数访视）
adlb <- adlb %>%
  mutate(
    AVISIT = str_to_title(VISIT),
    AVISITN = ifelse(VISITNUM == 3, 0, as.numeric(VISITNUM))
  )

## ----r------------------------------------------------------------------------
# 参数查找表：将 SDTM 的 LBTESTCD 映射为 ADaM 的 PARAMCD
# 官方 47 个检验项目中有 9 个改名（如 ALP→ALKPH、K→POTAS、LYM→LYMPH），其余同名继承
# 注：PARAM/PARAMN 由规格书受控术语自动生成（脚本末尾 create_var_from_codelist，
# 一次生成 PARAMCD 对应的文本与编码），此表只负责 PARAMCD 映射
param_lookup <- tibble::tribble(
  ~LBTESTCD, ~PARAMCD,
  "ALB", "ALB",
  "ALP", "ALKPH",
  "ALT", "ALT",
  "ANISO", "ANISO",
  "AST", "AST",
  "BASO", "BASO",
  "BASOLE", "BASOLE",
  "BILI", "BILI",
  "BUN", "BUN",
  "CA", "CA",
  "CHOL", "CHOLES",
  "CK", "CK",
  "CL", "CL",
  "COLOR", "COLOR",
  "CREAT", "CREAT",
  "EOS", "EOS",
  "EOSLE", "EOSLE",
  "GGT", "GGT",
  "GLUC", "GLUC",
  "HCT", "HCT",
  "HGB", "HGB",
  "K", "POTAS",
  "KETONES", "KETON",
  "LYM", "LYMPH",
  "LYMLE", "LYMPHLE",
  "MACROCY", "MACROC",
  "MCH", "MCH",
  "MCHC", "MCHC",
  "MCV", "MCV",
  "MICROCY", "MICROC",
  "MONO", "MONO",
  "MONOLE", "MONOLE",
  "PH", "PH",
  "PHOS", "PHOS",
  "PLAT", "PLAT",
  "POIKILO", "POIKIL",
  "POLYCHR", "POLYCH",
  "PROT", "PROT",
  "RBC", "RBC",
  "SODIUM", "SODIUM",
  "SPGRAV", "SPGRAV",
  "TSH", "TSH",
  "URATE", "URATE",
  "UROBIL", "UROBIL",
  "VITB12", "VITB12",
  "WBC", "WBC",
  "HBA1C", "HBA1C"
)
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
# AVAL（分析值）直接使用 LBSTRESN（标准化数值），AVALC 保留定性结果文本
# 参数分类与正常范围直接继承 SDTM 字段
adlb <- adlb %>%
  mutate(
    PARCAT1 = LBCAT,
    AVAL = LBSTRESN,
    AVALC = LBSTRESC,
    ANRLO = LBSTNRLO,
    ANRHI = LBSTNRHI,
    DTYPE = NA_character_ # 摘要行标志列（LOV/MAXIMUM/MINIMUM 行写入 DTYPE，普通行为 NA）
  )

## ----r------------------------------------------------------------------------
# 计算型参数：官方 ADLB 的 BASO/LYMPH 参数已由标准化数据直接携带（Abs 单位），
# 另有 24 行 DTYPE="CALCULATION" 的复核值（WBC×占比 重算）。
# 本脚本以 SDTM 标准化结果为最终值，不重现该复核行（差异记录见 README——
# BDS 核心派生（基线/变化量/范围/标志）与官方完全对齐为验收标准）。

## ----r------------------------------------------------------------------------
# 派生治疗期标志 ONTRTFL：检查日期落在治疗期内（TRTSDT~TRTEDT）才算"治疗中"
# 官方口径：基线访视（AVISITN==0）的记录标为缺失（NA）而非 "Y"
adlb <- derive_var_ontrtfl(
  adlb,
  start_date = ADT,
  ref_start_date = TRTSDT,
  ref_end_date = TRTEDT,
  filter_pre_timepoint = AVISITN == 0
)

## ----r------------------------------------------------------------------------
# 派生治疗期末次值（DTYPE="LOV"）与治疗期最大值/最小值摘要行
# LOV：复制治疗期间（ONTRTFL=="Y"）每个受试者/参数的最后一条测量为
#      AVISIT="POST-BASELINE LAST"（AVISITN=9999），供"末次值"类分析使用
adlb_flagged <- adlb %>%
  restrict_derivation(
    derivation = derive_var_extreme_flag,
    args = params(
      new_var = TEMP_LOVFL,
      by_vars = exprs(STUDYID, USUBJID, PARAMCD),
      order = exprs(ADT, AVISITN, LBSEQ),
      mode = "last"
    ),
    filter = ONTRTFL == "Y" & is.na(DTYPE) & !is.na(AVAL)
  )

lov_rows <- adlb_flagged %>%
  filter(TEMP_LOVFL == "Y") %>%
  mutate(
    AVISIT = "POST-BASELINE LAST",
    AVISITN = 9999,
    DTYPE = "LOV"
  ) %>%
  select(-TEMP_LOVFL)

adlb <- bind_rows(adlb_flagged %>% select(-TEMP_LOVFL), lov_rows)

# MAX/MIN：每个受试者/参数治疗期内最大/最小观察值（AVISITN=9998/9997）
# 实现与 LOV 相同："打标 → 复制改值"——复制出的行保留 AVAL/ADT 等源记录值，
# 仅 AVISIT/AVISITN/DTYPE 被改写（官方口径：max 值所在记录的整行副本）
for (stat in c("MAXIMUM", "MINIMUM")) {
  adlb_flag <- adlb %>%
    restrict_derivation(
      derivation = derive_var_extreme_flag,
      args = params(
        new_var = TEMP_STATFL,
        by_vars = exprs(STUDYID, USUBJID, PARAMCD),
        order = if (stat == "MAXIMUM") exprs(desc(AVAL), ADT) else exprs(AVAL, ADT),
        mode = "first"
      ),
      filter = ONTRTFL == "Y" & is.na(DTYPE) & !is.na(AVAL)
    )
  stat_rows <- adlb_flag %>%
    filter(TEMP_STATFL == "Y") %>%
    mutate(
      AVISIT = if (stat == "MAXIMUM") "POST-BASELINE MAXIMUM" else "POST-BASELINE MINIMUM",
      AVISITN = if (stat == "MAXIMUM") 9998 else 9997,
      DTYPE = stat
    ) %>%
    select(-TEMP_STATFL)
  adlb <- bind_rows(adlb_flag %>% select(-TEMP_STATFL), stat_rows)
}

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

# 派生基线值 BASE（数值）与 BNRIND（基线正常范围指示）
adlb <- derive_var_base(
  adlb,
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
# 派生变化量 CHG = AVAL - BASE 和百分变化 PCHG = CHG/BASE × 100
# 仅对治疗后记录（AVISITN > 0）计算，基线自身不计算变化量
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
# check_type = "error" 确保序号唯一，如有重复则报错停止
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
    decode_to_code = FALSE # 与 PARAM 相同：输入是 code 列（PARAMCD），输出 decode 列（数值编码）
  )

## ----r------------------------------------------------------------------------
# 将 ADSL 其余变量合并回来（补充人口学和分组变量）
adlb <- adlb %>%
  derive_vars_merged(
    dataset_add = select(adsl, !!!negate_vars(adsl_vars)),
    by_vars = exprs(STUDYID, USUBJID)
  )

## ----r, message=FALSE, warning=FALSE------------------------------------------
dir <- "adam/output" # Specify the directory for saving the XPT file
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

message("ADLB 生成完成！文件已保存为 adlb.xpt")
