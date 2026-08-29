# =============================================================================
# 数据集名称：ADCM（Concomitant Medications Analysis Dataset，合并用药分析数据集）
# =============================================================================
# 功能说明：
#   在 SDTM CM 域基础上构建 ADCM（OCCDS 结构），添加分析所需的派生变量：
#   分析日期（ASTDT/AENDT）、研究日（ASTDY/AENDY）、治疗期标志（ONTRTFL）、
#   用药阶段三态（APHASE：Pre-Treatment / On-Treatment / Follow-Up）、
#   治疗期用药发生标志（AOCCPFL）、分析集标志（ANL01FL）。
#
# 使用的包：
#   - admiral         : ADaM 构建核心工具包
#   - metacore/metatools : 规格书驱动的变量校验（规格见 adam/specs.R）
#   - xportr          : 导出为 SAS 传输文件
#   - pharmaversesdtm/pharmaverseadam : SDTM 示例数据（CM）与 ADSL
#
# 输入数据来源：
#   - pharmaverseadam::adsl : ADSL（提供治疗开始/结束日和治疗标签）
#   - pharmaversesdtm::cm   : SDTM CM 域（合并用药基础数据）
#   - adam/specs.R          : ADCM 数据集规格
#
# 输出文件：
#   - adcm.xpt（SAS 传输文件，写入 adam/output/）
#
# 关键概念说明（给不熟悉 R 的临床数据人员）：
#   OCCDS（Occurrence Data Structure）：发生类数据，每行一次用药记录
#   ASTDT/AENDT：用药开始/结束分析日期（不完整日期填补：开始填月初/结束填月末）
#   ASTDY/AENDY：相对首次用药日的研究日
#   ONTRTFL：治疗期间用药标志——用药期与治疗期（TRTSDT~TRTEDT）重叠即"Y"
#   PREFL/FUPFL：用药完全发生在治疗前/后（Follow-Up）的标志
#   APHASE：用药阶段三态（Pre-Treatment/On-Treatment/Follow-Up），常用于合并用药表的分行
#   AOCCPFL：每个受试者 × 药物编码下治疗期内的"发生"标志（AOCC = Analysis of Occurrence
#     Child），供"至少一次治疗期用药"类统计使用
#   ANL01FL：主要分析集标志（与 ONTRTFL 相同——所有治疗期用药都属于主要分析集）
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

# 读入 ADCM 规格（specs.R 中定义；metadata 原始规格书只含 ADSL/ADVS/ADAE）
source("adam/specs.R")

# 读入输入数据
adsl <- pharmaverseadam::adsl
cm <- pharmaversesdtm::cm

# 将 SAS 空字符串转为 NA
cm <- convert_blanks_to_na(cm)

# 加载 ADCM 规格（metacore 对象）
metacore <- load_dataset_spec("ADCM")

## ----r------------------------------------------------------------------------
# Select required ADSL variables
adsl_vars <- exprs(TRTSDT, TRTEDT, TRT01A, TRT01P)

# Join ADSL variables with CM
adcm <- cm %>%
  derive_vars_merged(
    dataset_add = adsl,
    new_vars = adsl_vars,
    by_vars = exprs(STUDYID, USUBJID)
  )

## ----r------------------------------------------------------------------------
# 派生用药开始/结束分析日期（ASTDT/AENDT）和研究日（ASTDY/AENDY）
# 不完整日期允许填补：开始日填月初（保守），结束日填月末；ASTDT 填补以 AENDT 为上界
adcm <- adcm %>%
  derive_vars_dt(
    new_vars_prefix = "AEN",
    dtc = CMENDTC,
    date_imputation = "last",
    highest_imputation = "M",
    flag_imputation = "auto"
  ) %>%
  derive_vars_dt(
    new_vars_prefix = "AST",
    dtc = CMSTDTC,
    date_imputation = "first",
    highest_imputation = "M",
    flag_imputation = "auto",
    min_dates = exprs(TRTSDT),
    max_dates = exprs(AENDT)
  ) %>%
  derive_vars_dy(
    reference_date = TRTSDT,
    source_vars = exprs(ASTDT, AENDT)
  ) %>%
  # 用药持续时间（天数）
  derive_vars_duration(
    new_var = ADURN,
    new_var_unit = ADURU,
    start_date = ASTDT,
    end_date = AENDT
  )

## ----r------------------------------------------------------------------------
# 治疗期标志（官方三相口径）：
#   ONTRTFL：用药期与治疗期重叠（开始 ≤ 治疗结束 且（结束 ≥ 治疗开始 或 仍在用药））
#   PREFL  ：用药完全发生在治疗前（开始 < 治疗开始）
#   FUPFL  ：用药完全发生在治疗后（开始 > 治疗结束）
#   APHASE：三态阶段（用于合并用药表的分行列）
adcm <- adcm %>%
  mutate(
    # 官方口径：阶段按用药开始日期判定（治疗前开始=Pre-Treatment，
    # 治疗后开始=Follow-Up，其余=On-Treatment）；ONTRTFL 即"On-Treatment"
    APHASE = dplyr::case_when(
      ASTDT < TRTSDT ~ "Pre-Treatment",
      ASTDT > TRTEDT ~ "Follow-Up",
      TRUE ~ "On-Treatment"
    ),
    ONTRTFL = ifelse(APHASE == "On-Treatment", "Y", NA_character_),
    PREFL = ifelse(APHASE == "Pre-Treatment", "Y", NA_character_),
    FUPFL = ifelse(APHASE == "Follow-Up", "Y", NA_character_),
    APHASEN = as.numeric(factor(APHASE, levels = c("Pre-Treatment", "On-Treatment", "Follow-Up"))),
    # 主要分析集标志：治疗期用药即主要分析人群
    ANL01FL = ifelse(ONTRTFL == "Y", "Y", NA_character_)
  )

## ----r------------------------------------------------------------------------
# 治疗期用药发生标志 AOCCPFL：
# 每个受试者 × 药物编码（CMDECOD）下，治疗期内（ONTRTFL="Y"）最早一次用药记录标 "Y"
# （AOCC 类统计——"该受试者与该药物至少一次治疗期用药"）
adcm <- restrict_derivation(
  adcm,
  derivation = derive_var_extreme_flag,
  args = params(
    new_var = AOCCPFL,
    by_vars = exprs(STUDYID, USUBJID, CMDECOD),
    order = exprs(ASTDT, CMSEQ),
    mode = "first",
    true_value = "Y"
  ),
  filter = ONTRTFL == "Y" & !is.na(CMDECOD)
)

## ----r------------------------------------------------------------------------
# 将计划治疗和实际治疗标签从 ADSL 的 TRT01P/TRT01A 复制为 TRTP/TRTA
adcm <- adcm %>%
  mutate(
    TRTP = TRT01P,
    TRTA = TRT01A
  )

## ----r------------------------------------------------------------------------
# 派生分析序号 ASEQ（每个受试者内的记录序号）
adcm <- derive_var_obs_number(
  adcm,
  new_var = ASEQ,
  by_vars = exprs(STUDYID, USUBJID),
  order = exprs(ASTDT, CMSEQ),
  check_type = "error"
)

## ----r------------------------------------------------------------------------
# 将 ADSL 其余变量合并回来
adcm <- adcm %>%
  derive_vars_merged(
    dataset_add = select(adsl, !!!negate_vars(adsl_vars)),
    by_vars = exprs(STUDYID, USUBJID)
  )

## ----r, message=FALSE, warning=FALSE------------------------------------------
dir <- "adam/output" # Specify the directory for saving the XPT file
dir.create(dir, showWarnings = FALSE, recursive = TRUE)

# 质控步骤：检查变量完整性和受控术语合规性，按规格排列列和行
adcm_prefinal <- adcm %>%
  drop_unspec_vars(metacore) %>%
  check_variables(metacore, dataset_name = "ADCM") %>%
  order_cols(metacore) %>%
  sort_by_key(metacore)

# 设置 SAS 格式属性（类型/长度/标签/格式/数据集标签）并导出
adcm_final <- adcm_prefinal %>%
  xportr_type(metacore) %>%
  xportr_length(metacore) %>%
  xportr_label(metacore) %>%
  xportr_format(metacore, domain = "ADCM") %>%
  xportr_df_label(metacore, domain = "ADCM") %>%
  xportr_write(file.path(dir, "adcm.xpt"), metadata = metacore, domain = "ADCM")

message("ADCM 生成完成！文件已保存为 adcm.xpt")
