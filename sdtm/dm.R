# =============================================================================
# 域名称：DM（Demographics，人口学数据集）
# =============================================================================
# 功能说明：
#   将原始人口学数据（dm_raw）、处置数据（ds_raw）和暴露数据（ec_raw）
#   按 CDISC SDTM 标准规则整理成 DM 域数据集。
#
# 使用的包：
#   - sdtm.oak       : Roche/pharmaverse 开发的 SDTM 映射核心工具包
#   - pharmaverseraw : 提供示例原始数据（模拟 EDC 采集数据）
#   - dplyr          : 数据操作（管道、变量选择等）
#
# 输入数据来源：
#   - pharmaverseraw::dm_raw  : 受试者基本信息原始数据
#   - pharmaverseraw::ds_raw  : 处置/结局原始数据（含退出日期）
#   - pharmaverseraw::ec_raw  : 暴露/用药原始数据（含首次/末次用药日期）
#   - metadata/sdtm_ct.csv    : CDISC 受控术语对照表
#
# 输出文件：
#   - dm（R 对象，可进一步导出为 dm.xpt SAS 传输文件）
#
# 关键概念说明（给不熟悉R的临床数据人员）：
#   SDTM 映射：把 EDC 收集的原始变量名，按 CDISC 规定重命名并转换成标准格式
#   assign_no_ct : 原样复制原始值到目标变量（无需受控术语转换）
#   assign_ct    : 按受控术语对照表转换原始值（如"男"→"M"）
#   hardcode_ct  : 对目标变量写入固定常量值（如所有记录单位均为"Year"）
# =============================================================================

## ----r setup, message=FALSE, warning=FALSE, results='hold'--------------------
library(sdtm.oak)
library(pharmaverseraw)
library(dplyr)

# 读入原始数据：来自 pharmaverseraw 包（模拟 EDC 系统导出的原始数据）
dm_raw <- pharmaverseraw::dm_raw
ds_raw <- pharmaverseraw::ds_raw
ec_raw <- pharmaverseraw::ec_raw

## ----r------------------------------------------------------------------------
# 为每份原始数据生成 OAK 内部追踪 ID，确保后续跨域合并时记录可以精确对应
dm_raw <- dm_raw %>%
  generate_oak_id_vars(
    pat_var = "PATNUM",
    raw_src = "dm_raw"
  )

ds_raw <- ds_raw %>%
  generate_oak_id_vars(
    pat_var = "PATNUM",
    raw_src = "ds_raw"
  )

ec_raw <- ec_raw %>%
  generate_oak_id_vars(
    pat_var = "PATNUM",
    raw_src = "ec_raw"
  )

## ----r, echo = TRUE-----------------------------------------------------------
# 读入 CDISC 受控术语对照表，后续所有 assign_ct/hardcode_ct 都依赖它做值校验和转换
study_ct <- read.csv("metadata/sdtm_ct.csv")

## ----r------------------------------------------------------------------------
# 定义各参照日期的原始来源和格式配置
# 这张配置表告诉程序：哪个参照日期变量从哪个原始数据集的哪个字段计算而来
ref_date_conf_df <- tibble::tribble(
  ~raw_dataset_name, ~date_var,     ~time_var,      ~dformat,      ~tformat, ~sdtm_var_name,
  "ec_raw",       "IT.ECSTDAT", NA_character_, "dd-mmm-yyyy", NA_character_,     "RFXSTDTC",
  "ec_raw",       "IT.ECENDAT", NA_character_, "dd-mmm-yyyy", NA_character_,     "RFXENDTC",
  "ec_raw",       "IT.ECSTDAT", NA_character_, "dd-mmm-yyyy", NA_character_,      "RFSTDTC",
  "ec_raw",       "IT.ECENDAT", NA_character_, "dd-mmm-yyyy", NA_character_,      "RFENDTC",
  "dm_raw",            "IC_DT", NA_character_,  "mm/dd/yyyy", NA_character_,      "RFICDTC",
  "ds_raw",          "DSDTCOL",     "DSTMCOL",  "mm-dd-yyyy",         "H:M",     "RFPENDTC",
  "ds_raw",          "DEATHDT", NA_character_,  "mm/dd/yyyy", NA_character_,       "DTHDTC"
)

## ----r------------------------------------------------------------------------
# 初始化 dm 数据框：提取受试者编号 SUBJID（取 PATNUM 第5-8位），作为后续映射的骨架
dm <- dm_raw %>%
  mutate(
    SUBJID = substr(PATNUM, 5, 8)
  ) %>%
  select(oak_id, raw_source, patient_number, SUBJID)

## ----r------------------------------------------------------------------------
# 逐一映射人口学变量：AGE、AGEU、SEX、ETHNIC、RACE、ARM、ARMCD、ACTARM、ACTARMCD
# assign_no_ct 用于无需受控术语转换的变量（直接原样复制）
# assign_ct 用于需要按 CDISC 代码表转换的变量
# hardcode_ct 用于全体受试者值固定为同一常量的变量（如年龄单位均为"Year"）
dm <- dm %>%
  # Map AGE using assign_no_ct
  assign_no_ct(
    raw_dat = dm_raw,
    raw_var = "IT.AGE",
    tgt_var = "AGE",
    id_vars = oak_id_vars()
  ) %>%
  # Map AGEU using hardcode_ct
  hardcode_ct(
    raw_dat = dm_raw,
    raw_var = "IT.AGE",
    tgt_var = "AGEU",
    tgt_val = "Year",
    ct_spec = study_ct,
    ct_clst = "C66781",
    id_vars = oak_id_vars()
  ) %>%
  # Map SEX using assign_ct
  assign_ct(
    raw_dat = dm_raw,
    raw_var = "IT.SEX",
    tgt_var = "SEX",
    ct_spec = study_ct,
    ct_clst = "C66731",
    id_vars = oak_id_vars()
  ) %>%
  # Map ETHNIC using assign_ct
  assign_ct(
    raw_dat = dm_raw,
    raw_var = "IT.ETHNIC",
    tgt_var = "ETHNIC",
    ct_spec = study_ct,
    ct_clst = "C66790",
    id_vars = oak_id_vars()
  ) %>%
  # Map RACE using assign_ct
  assign_ct(
    raw_dat = dm_raw,
    raw_var = "IT.RACE",
    tgt_var = "RACE",
    ct_spec = study_ct,
    ct_clst = "C74457",
    id_vars = oak_id_vars()
  ) %>%
  # Map ARM using assign_ct
  assign_ct(
    raw_dat = dm_raw,
    raw_var = "PLANNED_ARM",
    tgt_var = "ARM",
    ct_spec = study_ct,
    ct_clst = "ARM",
    id_vars = oak_id_vars()
  ) %>%
  # Map ARMCD using assign_no_ct
  assign_no_ct(
    raw_dat = dm_raw,
    raw_var = "PLANNED_ARMCD",
    tgt_var = "ARMCD",
    id_vars = oak_id_vars()
  ) %>%
  # Map ACTARM using assign_ct
  assign_ct(
    raw_dat = dm_raw,
    raw_var = "ACTUAL_ARM",
    tgt_var = "ACTARM",
    ct_spec = study_ct,
    ct_clst = "ARM",
    id_vars = oak_id_vars()
  ) %>%
  # Map ACTARMCD using assign_no_ct
  assign_no_ct(
    raw_dat = dm_raw,
    raw_var = "ACTUAL_ARMCD",
    tgt_var = "ACTARMCD",
    id_vars = oak_id_vars()
  )

## ----r eval=TRUE--------------------------------------------------------------
# 计算 RFSTDTC（研究参考起始日期）：取 ec_raw 中最早的用药开始日期
# min_max = "min" 表示取最小值，适用于"首次"类时间点
dm <- dm %>%
  # Derive RFSTDTC using oak_cal_ref_dates
  oak_cal_ref_dates(
    ds_in = .,
    der_var = "RFSTDTC",
    min_max = "min",
    ref_date_config_df = ref_date_conf_df,
    raw_source = list(
      ec_raw = ec_raw,
      ds_raw = ds_raw,
      dm_raw = dm_raw
    )
  )

## ----r------------------------------------------------------------------------
# 计算 RFENDTC（研究参考结束日期）：取 ec_raw 中最晚的用药结束日期
# min_max = "max" 表示取最大值，适用于"末次"类时间点
dm <- dm %>%
  # Derive RFENDTC using oak_cal_ref_dates
  oak_cal_ref_dates(
    ds_in = .,
    der_var = "RFENDTC",
    min_max = "max",
    ref_date_config_df = ref_date_conf_df,
    raw_source = list(
      ec_raw = ec_raw,
      ds_raw = ds_raw,
      dm_raw = dm_raw
    )
  )

## ----r------------------------------------------------------------------------
# 同样方法衍生其余参照日期变量：RFXSTDTC/RFXENDTC（实际用药）、RFICDTC（知情同意）、
# RFPENDTC（末次随访）、DTHDTC（死亡日期）
dm <- dm %>%
  # Derive RFXSTDTC using oak_cal_ref_dates
  oak_cal_ref_dates(
    ds_in = .,
    der_var = "RFXSTDTC",
    min_max = "min",
    ref_date_config_df = ref_date_conf_df,
    raw_source = list(
      ec_raw = ec_raw,
      ds_raw = ds_raw,
      dm_raw = dm_raw
    )
  ) %>%
  # Derive RFXENDTC using oak_cal_ref_dates
  oak_cal_ref_dates(
    ds_in = .,
    der_var = "RFXENDTC",
    min_max = "max",
    ref_date_config_df = ref_date_conf_df,
    raw_source = list(
      ec_raw = ec_raw,
      ds_raw = ds_raw,
      dm_raw = dm_raw
    )
  ) %>%
  # Derive RFICDTC using oak_cal_ref_dates
  oak_cal_ref_dates(
    ds_in = .,
    der_var = "RFICDTC",
    min_max = "min",
    ref_date_config_df = ref_date_conf_df,
    raw_source = list(
      ec_raw = ec_raw,
      ds_raw = ds_raw,
      dm_raw = dm_raw
    )
  ) %>%
  # Derive RFPENDTC using oak_cal_ref_dates
  oak_cal_ref_dates(
    ds_in = .,
    der_var = "RFPENDTC",
    min_max = "max",
    ref_date_config_df = ref_date_conf_df,
    raw_source = list(
      ec_raw = ec_raw,
      ds_raw = ds_raw,
      dm_raw = dm_raw
    )
  ) %>%
  # Map DTHDTC using oak_cal_ref_dates
  oak_cal_ref_dates(
    ds_in = .,
    der_var = "DTHDTC",
    min_max = "min",
    ref_date_config_df = ref_date_conf_df,
    raw_source = list(
      ec_raw = ec_raw,
      ds_raw = ds_raw,
      dm_raw = dm_raw
    )
  )

## ----r------------------------------------------------------------------------
# 补充固定变量（STUDYID、DOMAIN、USUBJID、COUNTRY、DTHFL）并衍生采集日期 DMDTC 和研究日 DMDY
# DTHFL：只要 DTHDTC 不缺失就标"Y"，表示受试者死亡，符合 SDTM 二值标志规范
dm <- dm %>%
  mutate(
    STUDYID = dm_raw$STUDY,
    DOMAIN = "DM",
    USUBJID = paste0("01-", dm_raw$PATNUM),
    COUNTRY = dm_raw$COUNTRY,
    DTHFL = dplyr::if_else(is.na(DTHDTC), NA_character_, "Y")
  ) %>%
  # Map DMDTC using assign_datetime
  assign_datetime(
    raw_dat = dm_raw,
    raw_var = "COL_DT",
    tgt_var = "DMDTC",
    raw_fmt = c("m/d/y"),
    id_vars = oak_id_vars()
  ) %>%
  # Derive study day
  derive_study_day(
    sdtm_in = .,
    dm_domain = .,
    tgdt = "DMDTC",
    refdt = "RFXSTDTC",
    study_day_var = "DMDY"
  )
