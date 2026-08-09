# =============================================================================
# 域名称：VS（Vital Signs，生命体征数据集）
# =============================================================================
# 功能说明：
#   将原始生命体征数据（vs_raw）按 CDISC SDTM 标准整理成 VS 域数据集，
#   处理多个生命体征指标（收缩压、舒张压、脉搏、体温、身高、体重），
#   并进行单位换算（华氏→摄氏、英寸→厘米、磅→公斤）。
#
# 使用的包：
#   - sdtm.oak       : SDTM 映射核心工具包（Roche/pharmaverse）
#   - pharmaverseraw : 提供示例原始数据
#   - dplyr          : 数据操作
#   - xportr         : 导出为 SAS 传输文件（.xpt）
#
# 输入数据来源：
#   - pharmaverseraw::vs_raw   : 生命体征原始数据（含多个测量指标列）
#   - pharmaversesdtm::dm      : DM 域数据（提供 RFXSTDTC 用于计算研究日）
#   - metadata/sdtm_ct.csv     : CDISC 受控术语对照表
#
# 输出文件：
#   - vs.xpt（SAS 传输文件，写入 tempdir()）
#
# 关键概念说明：
#   VS 域采用"竖式"（tall/narrow）数据结构：每行一个测量指标，而非横式（每行一次访视）
#   VSORRES：原始结果值（原始单位，如"98.6 F"）
#   VSSTRESC：标准化结果值（字符型，统一换算后，如"37.00"°C）
#   VSSTRESN：标准化结果值（数值型，用于统计分析）
#   hardcode_ct：用于给所有记录赋相同的固定值（如所有收缩压记录 VSTESTCD 均为"SYSBP"）
# =============================================================================

## ----r setup, message=FALSE, warning=FALSE, results='hold'--------------------
library(sdtm.oak)
library(pharmaverseraw)
library(dplyr)
library(xportr)

# Read in input data
vs_raw <- pharmaverseraw::vs_raw
dm <- pharmaversesdtm::dm

## ----r------------------------------------------------------------------------
# 生成追踪 ID，pat_var 指定受试者编号字段，raw_src 标记数据来源（便于调试溯源）
vs_raw <- vs_raw %>%
  generate_oak_id_vars(
    pat_var = "PATNUM",
    raw_src = "vitals"
  )

## ----r, echo = TRUE-----------------------------------------------------------
# 读入受控术语对照表
study_ct <- read.csv("metadata/sdtm_ct.csv")

## ----r------------------------------------------------------------------------
# VS 域处理策略：每个指标分别建立子数据框，最后 bind_rows 合并
# 原因：同一受试者同一访视可能有多个生命体征测量值，必须分行存储

# 映射收缩压（SYSBP）：先用 hardcode_ct 确定主题变量 VSTESTCD
# filter 过滤非空记录：只有实际测量了该指标的行才需要填入限定变量
vs_sysbp <-
  hardcode_ct(
    raw_dat = vs_raw,
    raw_var = "SYS_BP",
    tgt_var = "VSTESTCD",
    tgt_val = "SYSBP",
    ct_spec = study_ct,
    ct_clst = "C66741"
  ) %>%
  # Filter for records where VSTESTCD is not empty.
  # Only these records need qualifier mappings.
  dplyr::filter(!is.na(.data$VSTESTCD))

## ----r------------------------------------------------------------------------
## Map Rest of the Variables
vs_sysbp <- vs_sysbp %>%
  # Map VSTEST using hardcode_ct algorithm
  hardcode_ct(
    raw_dat = vs_raw,
    raw_var = "SYS_BP",
    tgt_var = "VSTEST",
    tgt_val = "Systolic Blood Pressure",
    ct_spec = study_ct,
    ct_clst = "C67153",
    id_vars = oak_id_vars()
  ) %>%
  # Map VSORRES using assign_no_ct algorithm
  assign_no_ct(
    raw_dat = vs_raw,
    raw_var = "SYS_BP",
    tgt_var = "VSORRES",
    id_vars = oak_id_vars()
  ) %>%
  # Map VSORRESU using hardcode_ct algorithm
  hardcode_ct(
    raw_dat = vs_raw,
    raw_var = "SYS_BP",
    tgt_var = "VSORRESU",
    tgt_val = "mmHg",
    ct_spec = study_ct,
    ct_clst = "C66770",
    id_vars = oak_id_vars()
  ) %>%
  # Map VSPOS using assign_ct algorithm
  assign_ct(
    raw_dat = vs_raw,
    raw_var = "SUBPOS",
    tgt_var = "VSPOS",
    ct_spec = study_ct,
    ct_clst = "C71148",
    id_vars = oak_id_vars()
  )

## ----r------------------------------------------------------------------------
# 舒张压（DIABP）：与收缩压结构相同，换用对应的原始变量 DIA_BP
# 每个指标独立建立子数据框，保持代码可读性和可维护性
vs_diabp <-
  hardcode_ct(
    raw_dat = vs_raw,
    raw_var = "DIA_BP",
    tgt_var = "VSTESTCD",
    tgt_val = "DIABP",
    ct_spec = study_ct,
    ct_clst = "C66741"
  ) %>%
  dplyr::filter(!is.na(.data$VSTESTCD)) %>%
  # Map VSTEST using hardcode_ct algorithm
  hardcode_ct(
    raw_dat = vs_raw,
    raw_var = "DIA_BP",
    tgt_var = "VSTEST",
    tgt_val = "Diastolic Blood Pressure",
    ct_spec = study_ct,
    ct_clst = "C67153",
    id_vars = oak_id_vars()
  ) %>%
  # Map VSORRES using assign_no_ct algorithm
  assign_no_ct(
    raw_dat = vs_raw,
    raw_var = "DIA_BP",
    tgt_var = "VSORRES",
    id_vars = oak_id_vars()
  ) %>%
  # Map VSORRESU using hardcode_ct algorithm
  hardcode_ct(
    raw_dat = vs_raw,
    raw_var = "DIA_BP",
    tgt_var = "VSORRESU",
    tgt_val = "mmHg",
    ct_spec = study_ct,
    ct_clst = "C66770",
    id_vars = oak_id_vars()
  ) %>%
  # Map VSPOS using assign_ct algorithm
  assign_ct(
    raw_dat = vs_raw,
    raw_var = "SUBPOS",
    tgt_var = "VSPOS",
    ct_spec = study_ct,
    ct_clst = "C71148",
    id_vars = oak_id_vars()
  )

# Map topic variable PULSE and its qualifiers.
vs_pulse <-
  hardcode_ct(
    raw_dat = vs_raw,
    raw_var = "PULSE",
    tgt_var = "VSTESTCD",
    tgt_val = "PULSE",
    ct_spec = study_ct,
    ct_clst = "C66741"
  ) %>%
  dplyr::filter(!is.na(.data$VSTESTCD)) %>%
  # Map VSTEST using hardcode_ct algorithm
  hardcode_ct(
    raw_dat = vs_raw,
    raw_var = "PULSE",
    tgt_var = "VSTEST",
    tgt_val = "Pulse Rate",
    ct_spec = study_ct,
    ct_clst = "C67153",
    id_vars = oak_id_vars()
  ) %>%
  # Map VSORRES using assign_no_ct algorithm
  assign_no_ct(
    raw_dat = vs_raw,
    raw_var = "PULSE",
    tgt_var = "VSORRES",
    id_vars = oak_id_vars()
  ) %>%
  # Map VSORRESU using hardcode_ct algorithm
  hardcode_ct(
    raw_dat = vs_raw,
    raw_var = "PULSE",
    tgt_var = "VSORRESU",
    tgt_val = "beats/min",
    ct_spec = study_ct,
    ct_clst = "C66770",
    id_vars = oak_id_vars()
  ) %>%
  # Map VSPOS using assign_ct algorithm
  assign_ct(
    raw_dat = vs_raw,
    raw_var = "SUBPOS",
    tgt_var = "VSPOS",
    ct_spec = study_ct,
    ct_clst = "C71148",
    id_vars = oak_id_vars()
  )

# Map topic variable TEMP from raw variable TEMP and its qualifiers.
# 体温需要单位换算（华氏→摄氏），VSORRES 保留原始华氏值，VSSTRESC 存储换算后的摄氏值
vs_temp <-
  hardcode_ct(
    raw_dat = vs_raw,
    raw_var = "IT.TEMP",
    tgt_var = "VSTESTCD",
    tgt_val = "TEMP",
    ct_spec = study_ct,
    ct_clst = "C66741"
  ) %>%
  dplyr::filter(!is.na(.data$VSTESTCD)) %>%
  # Map VSTEST using hardcode_ct algorithm
  hardcode_ct(
    raw_dat = vs_raw,
    raw_var = "IT.TEMP",
    tgt_var = "VSTEST",
    tgt_val = "Temperature",
    ct_spec = study_ct,
    ct_clst = "C67153",
    id_vars = oak_id_vars()
  ) %>%
  # Map VSORRES using assign_no_ct algorithm
  assign_no_ct(
    raw_dat = vs_raw,
    raw_var = "IT.TEMP",
    tgt_var = "VSORRES",
    id_vars = oak_id_vars()
  ) %>%
  # Map VSORRESU using hardcode_ct algorithm
  hardcode_ct(
    raw_dat = vs_raw,
    raw_var = "IT.TEMP",
    tgt_var = "VSORRESU",
    tgt_val = "F",
    ct_spec = study_ct,
    ct_clst = "C66770",
    id_vars = oak_id_vars()
  ) %>%
  # Map VSLOC from TEMPLOC using assign_ct
  assign_ct(
    raw_dat = vs_raw,
    raw_var = "IT.TEMP_LOC",
    tgt_var = "VSLOC",
    ct_spec = study_ct,
    ct_clst = "C74456",
    id_vars = oak_id_vars()
  ) %>%
  # Create VSSTRESC by converting VSORRES from F to C
  # 华氏转摄氏公式：°C = (°F - 32) × 5/9，保留2位小数便于统计
  mutate(VSSTRESC = as.character(sprintf("%.2f", (as.numeric(VSORRES) - 32) * 5 / 9))) %>%
  # Map VSSTRESU using hardcode_ct algorithm
  hardcode_ct(
    raw_dat = vs_raw,
    raw_var = "IT.TEMP",
    tgt_var = "VSSTRESU",
    tgt_val = "C",
    ct_spec = study_ct,
    ct_clst = "C66770",
    id_vars = oak_id_vars()
  )

# Map topic variable HEIGHT from raw variable IT.HEIGHT_VSORRRES and its qualifiers.
# 身高需要单位换算（英寸→厘米），VSORRES 保留英寸，VSSTRESC 存储厘米值
vs_height <-
  hardcode_ct(
    raw_dat = vs_raw,
    raw_var = "IT.HEIGHT_VSORRES",
    tgt_var = "VSTESTCD",
    tgt_val = "HEIGHT",
    ct_spec = study_ct,
    ct_clst = "C66741"
  ) %>%
  dplyr::filter(!is.na(.data$VSTESTCD)) %>%
  # Map VSTEST using hardcode_ct algorithm
  hardcode_ct(
    raw_dat = vs_raw,
    raw_var = "IT.HEIGHT_VSORRES",
    tgt_var = "VSTEST",
    tgt_val = "Height",
    ct_spec = study_ct,
    ct_clst = "C67153",
    id_vars = oak_id_vars()
  ) %>%
  # Map VSORRES using assign_no_ct algorithm
  assign_no_ct(
    raw_dat = vs_raw,
    raw_var = "IT.HEIGHT_VSORRES",
    tgt_var = "VSORRES",
    id_vars = oak_id_vars()
  ) %>%
  # Map VSORRESU using hardcode_ct algorithm
  hardcode_ct(
    raw_dat = vs_raw,
    raw_var = "IT.HEIGHT_VSORRES",
    tgt_var = "VSORRESU",
    tgt_val = "in",
    ct_spec = study_ct,
    ct_clst = "C66770",
    id_vars = oak_id_vars()
  ) %>%
  # Create VSSRESC by converting VSORRES from in to cm
  # 英寸转厘米：1英寸 = 2.54厘米
  mutate(VSSTRESC = as.character(sprintf("%.2f", as.numeric(VSORRES) * 2.54))) %>%
  # Map VSSTRESU using hardcode_ct algorithm
  hardcode_ct(
    raw_dat = vs_raw,
    raw_var = "IT.HEIGHT_VSORRES",
    tgt_var = "VSSTRESU",
    tgt_val = "cm",
    ct_spec = study_ct,
    ct_clst = "C66770",
    id_vars = oak_id_vars()
  )

# Map topic variable WEIGHT from raw variable IT.WEIGHT and its qualifiers.
# 体重需要单位换算（磅→公斤），VSORRES 保留磅值，VSSTRESC 存储公斤值
vs_weight <-
  hardcode_ct(
    raw_dat = vs_raw,
    raw_var = "IT.WEIGHT",
    tgt_var = "VSTESTCD",
    tgt_val = "WEIGHT",
    ct_spec = study_ct,
    ct_clst = "C66741"
  ) %>%
  dplyr::filter(!is.na(.data$VSTESTCD)) %>%
  # Map VSTEST using hardcode_ct algorithm
  hardcode_ct(
    raw_dat = vs_raw,
    raw_var = "IT.WEIGHT",
    tgt_var = "VSTEST",
    tgt_val = "Weight",
    ct_spec = study_ct,
    ct_clst = "C67153",
    id_vars = oak_id_vars()
  ) %>%
  # Map VSORRES using assign_no_ct algorithm
  assign_no_ct(
    raw_dat = vs_raw,
    raw_var = "IT.WEIGHT",
    tgt_var = "VSORRES",
    id_vars = oak_id_vars()
  ) %>%
  # Map VSORRESU using hardcode_ct algorithm
  hardcode_ct(
    raw_dat = vs_raw,
    raw_var = "IT.WEIGHT",
    tgt_var = "VSORRESU",
    tgt_val = "LB",
    ct_spec = study_ct,
    ct_clst = "C66770",
    id_vars = oak_id_vars()
  ) %>%
  # Create VSSTRESC by converting VSORRES from LB to KG
  # 磅转公斤：1磅 ≈ 0.453592公斤（= 1/2.20462）
  mutate(VSSTRESC = as.character(sprintf("%.2f", as.numeric(VSORRES) / 2.20462))) %>%
  # Map VSSTRESU using hardcode_ct algorithm
  hardcode_ct(
    raw_dat = vs_raw,
    raw_var = "IT.WEIGHT",
    tgt_var = "VSSTRESU",
    tgt_val = "kg",
    ct_spec = study_ct,
    ct_clst = "C66770",
    id_vars = oak_id_vars()
  )

## ----r------------------------------------------------------------------------
# 将六个生命体征子数据框纵向合并为一个数据框
# bind_rows 等效于 SAS 的 SET 语句，列名不匹配时自动填 NA
vs_combined <- dplyr::bind_rows(
  vs_diabp, vs_height, vs_pulse,
  vs_sysbp, vs_temp, vs_weight
)

## ----r------------------------------------------------------------------------
# Map qualifiers common to all topic variables
# 映射所有指标共用的限定变量：采集时间、时间点、访视信息
vs <- vs_combined %>%
  # Map VSDTC using assign_ct algorithm
  assign_datetime(
    raw_dat = vs_raw,
    raw_var = c("VTLD"),
    tgt_var = "VSDTC",
    raw_fmt = c(list(c("d-m-y", "dd-mmm-yyyy")))
  ) %>%
  # Map VSTPT from TMPTC using assign_ct
  assign_ct(
    raw_dat = vs_raw,
    raw_var = "TMPTC",
    tgt_var = "VSTPT",
    ct_spec = study_ct,
    ct_clst = "TPT",
    id_vars = oak_id_vars()
  ) %>%
  # Map VSTPTNUM from TMPTC using assign_ct
  assign_ct(
    raw_dat = vs_raw,
    raw_var = "TMPTC",
    tgt_var = "VSTPTNUM",
    ct_spec = study_ct,
    ct_clst = "TPTNUM",
    id_vars = oak_id_vars()
  ) %>%
  # Map VISIT from INSTANCE using assign_ct
  assign_ct(
    raw_dat = vs_raw,
    raw_var = "INSTANCE",
    tgt_var = "VISIT",
    ct_spec = study_ct,
    ct_clst = "VISIT",
    id_vars = oak_id_vars()
  ) %>%
  # Map VISITNUM from INSTANCE using assign_ct
  assign_ct(
    raw_dat = vs_raw,
    raw_var = "INSTANCE",
    tgt_var = "VISITNUM",
    ct_spec = study_ct,
    ct_clst = "VISITNUM",
    id_vars = oak_id_vars()
  )

## ----r------------------------------------------------------------------------
# 补充固定变量并做最终整理：
# VSSTRESC：如已有换算值则保留，否则直接使用原始值（对于不需换算的指标如血压）
# VSELTM：从时间点标签中提取分钟数（如"5 MIN"→"PT5M"，ISO 8601 格式）
# VSTPTREF：根据体位（VSPOS）构造时间点参照描述
vs <- vs %>%
  dplyr::mutate(
    STUDYID = "CDISCPILOT01",
    DOMAIN = "VS",
    VSCAT = "VITAL SIGNS",
    USUBJID = paste0("01", "-", .data$patient_number),
    VSSTRESC = ifelse(is.na(VSSTRESC), VSORRES, VSSTRESC),
    VSSTRESN = as.numeric(VSSTRESC),
    VSSTRESU = ifelse(is.na(VSSTRESU), VSORRESU, VSSTRESU),
    VSELTM = ifelse(is.na(VSTPT), NA, paste0("PT", readr::parse_number(VSTPT), "M")),
    VSTPTREF = ifelse(is.na(VSPOS), NA, paste("PATIENT", VSPOS))
  ) %>%
  # 按受试者、指标、访视、时间点排序，确保输出顺序符合 SDTM 习惯
  arrange(USUBJID, VSTESTCD, as.numeric(VISITNUM), as.numeric(VSTPTNUM)) %>%
  derive_seq(
    tgt_var = "VSSEQ",
    rec_vars = c("USUBJID", "VSTESTCD")
  ) %>%
  derive_study_day(
    sdtm_in = .,
    dm_domain = dm,
    tgdt = "VSDTC",
    refdt = "RFXSTDTC",
    study_day_var = "VSDY"
  ) %>%
  dplyr::select("STUDYID", "DOMAIN", "USUBJID", "VSSEQ", "VSTESTCD", "VSTEST", "VSPOS", "VSORRES", "VSORRESU", "VSSTRESC", "VSSTRESN", "VSSTRESU", "VSLOC", "VISITNUM", "VISIT", "VSDTC", "VSDY", "VSTPT", "VSTPTNUM", "VSELTM", "VSTPTREF")

## ----r export--------------------------------------------------------------
# 导出为 SAS 传输文件（.xpt），供下游 ADaM 或电子提交使用
dir <- tempdir()
vs %>%
  xportr_write(file.path(dir, "vs.xpt"), domain = "VS")
