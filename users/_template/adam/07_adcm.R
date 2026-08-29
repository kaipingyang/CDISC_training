# =============================================================================
# 数据集名称：ADCM（Concomitant Medications Analysis Dataset，合并用药分析数据集）
# =============================================================================
# 功能说明：
#   在 SDTM CM 域基础上构建 ADCM（OCCDS 结构），添加分析所需的派生变量：
#   分析日期（ASTDT/AENDT）、研究日（ASTDY/AENDY）、治疗期标志（ONTRTFL）、
#   用药阶段三态（APHASE：Pre-Treatment / On-Treatment / Follow-Up）、
#   治疗期用药发生标志（AOCCPFL）、分析集标志（ANL01FL）。
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
# TODO 1: 派生用药开始/结束分析日期（ASTDT/AENDT）和研究日（ASTDY/AENDY）
#   AEN：derive_vars_dt(dtc=CMENDTC, date_imputation="last"（缺日填月末）,
#     highest_imputation="M", flag_imputation="auto")
#   AST：derive_vars_dt(dtc=CMSTDTC, date_imputation="first"（缺日填月初）, hM,
#     flag_imputation="auto", min_dates=exprs(TRTSDT), max_dates=exprs(AENDT))
#   然后 derive_vars_dy(reference_date=TRTSDT, source_vars=exprs(ASTDT, AENDT))
# 👉 在这里补两段 derive_vars_dt(...) + derive_vars_dy(...)
adcm <- adcm

## ----r------------------------------------------------------------------------
# TODO 2: 派生用药阶段 APHASE（三态）与标志（官方口径：按用药开始日期判定）
#   ASTDT < TRTSDT → "Pre-Treatment"；ASTDT > TRTEDT → "Follow-Up"；其余 → "On-Treatment"
#   ONTRTFL = ifelse(APHASE=="On-Treatment","Y",NA)；PREFL/FUPFL 同理
#   ANL01FL = 是否 On-Treatment（主要分析集 = 治疗期用药）
# 👉 在这里补一段 mutate(...)
adcm <- adcm %>%
  mutate(APHASE = NA_character_) # 占位：填好 TODO 后删除本行

## ----r------------------------------------------------------------------------
# TODO 3: APHASEN（三态数值编码）：1=Pre-Treatment / 2=On-Treatment / 3=Follow-Up
#   提示：as.numeric(factor(APHASE, levels = c(...)))
# 👉 在这里补一段 mutate(APHASEN = ...)
# 占位：填好 TODO 后删掉这行
identity()

## ----r------------------------------------------------------------------------
# 用药持续时间（天数）
adcm <- adcm %>%
  derive_vars_duration(
    new_var = ADURN,
    new_var_unit = ADURU,
    start_date = ASTDT,
    end_date = AENDT
  )

## ----r------------------------------------------------------------------------
# TODO 4: 派生治疗期用药"发生"标志 AOCCPFL
#   restrict_derivation + derive_var_extreme_flag：by_vars=(STUDYID,USUBJID,CMDECOD)、
#   order=(ASTDT,CMSEQ)、mode="first"、true_value="Y"、
#   filter=ONTRTFL=="Y" & !is.na(CMDECOD)
# 👉 在这里补一段 restrict_derivation(...)
identity() # 占位：填好 TODO 后删掉这行

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
dir <- "users/<STUDENT_NAME>/adam/output" # Specify the directory for saving the XPT file
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
