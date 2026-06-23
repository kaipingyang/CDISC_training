# =============================================================================
# 域名称：AE（Adverse Events，不良事件数据集）
# =============================================================================
# 功能说明：
#   将原始不良事件数据（ae_raw）按 CDISC SDTM 标准规则整理成 AE 域数据集，
#   包括不良事件术语、严重程度、严重性、因果关系等关键字段的标准化处理。
#
# 使用的包：
#   - sdtm.oak       : SDTM 映射核心工具包（Roche/pharmaverse）
#   - pharmaverseraw : 提供示例原始数据（模拟 EDC 采集数据）
#   - dplyr          : 数据操作（管道、变量选择等）
#
# 输入数据来源：
#   - pharmaverseraw::ae_raw   : 不良事件原始数据（EDC 采集）
#   - pharmaversesdtm::dm      : 已完成映射的 DM 域数据（提供参照日期）
#   - metadata/sdtm_ct.csv     : CDISC 受控术语对照表
#
# 输出文件：
#   - ae（R 对象，包含 AESEQ、AETERM、AESTDTC、AEENDTC、AESTDY 等 SDTM 标准变量）
#
# 关键概念说明：
#   AE 域是临床试验中最重要的安全性数据集之一
#   MedDRA：国际医学用语词典，用于标准化不良事件术语（AE 域强制使用）
#   AESEQ：每个受试者内不良事件的序号，由程序自动生成
#   AESTDY/AEENDY：不良事件开始/结束相对于首次用药的研究日（正数=用药后）
# =============================================================================

## ----r setup, message=FALSE, warning=FALSE, results='hold'--------------------
library(sdtm.oak)
library(pharmaverseraw)
library(dplyr)

# 读入原始不良事件数据和已映射的 DM 域（DM 提供 RFXSTDTC 等参照日期用于计算研究日）
ae_raw <- pharmaverseraw::ae_raw

## ----r------------------------------------------------------------------------
# 引用已处理好的 DM 域数据，用于后续计算研究日（AESTDY/AEENDY）
dm <- pharmaversesdtm::dm

## ----r------------------------------------------------------------------------
# 生成 OAK 内部追踪 ID，确保多对一合并时记录精确匹配，防止行错位
ae_raw <- ae_raw %>%
  generate_oak_id_vars(
    pat_var = "PATNUM",
    raw_src = "ae_raw"
  )

## ----r, echo = TRUE-----------------------------------------------------------
# 读入受控术语对照表，用于 assign_ct 函数查值（如"MILD"→"Mild"等）
study_ct <- read.csv("metadata/sdtm_ct.csv")

## ----r------------------------------------------------------------------------
# 映射 AETERM（不良事件术语）：assign_no_ct 直接原样复制原始术语值
# 此处不做受控术语转换，因为 AETERM 接受自由文本，标准化由 MedDRA 编码完成
ae <-
  # Derive topic variable
  # Map AETERM using assign_no_ct, raw_var=IT.AETERM, tgt_var=AETERM
  assign_no_ct(
    raw_dat = ae_raw,
    raw_var = "IT.AETERM",
    tgt_var = "AETERM",
    id_vars = oak_id_vars()
  )

## ----r eval=TRUE--------------------------------------------------------------
# 逐一映射不良事件的限定变量：
# AEOUT（结局）、AESEV（严重程度）、AESER（严重性）等均使用 assign_ct 进行受控术语转换
# 使用 %>% 管道将多步映射串联，避免反复建立中间变量
ae <- ae %>%
  # Map AEOUT using assign_ct, raw_var=AEOUTCOME, tgt_var=AEOUT
  assign_ct(
    raw_dat = ae_raw,
    raw_var = "AEOUTCOME",
    tgt_var = "AEOUT",
    ct_spec = study_ct,
    ct_clst = "C66768",
    id_vars = oak_id_vars()
  ) %>%
  # Map AESEV using assign_no_ct, raw_var=IT.AESEV, tgt_var=AESEV
  assign_ct(
    raw_dat = ae_raw,
    raw_var = "IT.AESEV",
    tgt_var = "AESEV",
    ct_spec = study_ct,
    ct_clst = "C66769",
    id_vars = oak_id_vars()
  ) %>%
  # Map AESER using assign_no_ct, raw_var=IT.AESER, tgt_var=AESER
  assign_ct(
    raw_dat = ae_raw,
    raw_var = "IT.AESER",
    tgt_var = "AESER",
    ct_spec = study_ct,
    ct_clst = "C66742",
    id_vars = oak_id_vars()
  ) %>%
  # Map AEACN using assign_no_ct, raw_var=IT.AEACN, tgt_var=AEACN
  assign_no_ct(
    raw_dat = ae_raw,
    raw_var = "IT.AEACN",
    tgt_var = "AEACN",
    id_vars = oak_id_vars()
  ) %>%
  # Map AEREL using assign_ct, raw_var=IT.AEREL, tgt_var=AEREL
  # User-added codelist is in the ct,
  assign_ct(
    raw_dat = ae_raw,
    raw_var = "IT.AEREL",
    tgt_var = "AEREL",
    ct_spec = study_ct,
    ct_clst = "AEREL",
    id_vars = oak_id_vars()
  ) %>%
  # Map AESCAN using assign_ct, raw_var=AESCAN, tgt_var=AESCAN
  assign_ct(
    raw_dat = ae_raw,
    raw_var = "AESCAN",
    tgt_var = "AESCAN",
    ct_spec = study_ct,
    ct_clst = "C66742",
    id_vars = oak_id_vars()
  ) %>%
  # Map AESCNO using assign_ct, raw_var=AESCNO, tgt_var=AESCNO
  assign_ct(
    raw_dat = ae_raw,
    raw_var = "AESCNO",
    tgt_var = "AESCONG",
    ct_spec = study_ct,
    ct_clst = "C66742",
    id_vars = oak_id_vars()
  ) %>%
  # Map AEDIS using assign_ct, raw_var=AEDIS, tgt_var=AEDIS
  assign_ct(
    raw_dat = ae_raw,
    raw_var = "AEDIS",
    tgt_var = "AESDISAB",
    ct_spec = study_ct,
    ct_clst = "C66742",
    id_vars = oak_id_vars()
  ) %>%
  # Map AESDTH using assign_ct, raw_var=IT.AESDTH, tgt_var=AESDTH
  assign_ct(
    raw_dat = ae_raw,
    raw_var = "IT.AESDTH",
    tgt_var = "AESDTH",
    ct_spec = study_ct,
    ct_clst = "C66742",
    id_vars = oak_id_vars()
  ) %>%
  # Map AESHOSP using assign_ct, raw_var=IT.AESHOSP, tgt_var=AESHOSP
  assign_ct(
    raw_dat = ae_raw,
    raw_var = "IT.AESHOSP",
    tgt_var = "AESHOSP",
    ct_spec = study_ct,
    ct_clst = "C66742",
    id_vars = oak_id_vars()
  ) %>%
  # Map AESLIFE using assign_ct, raw_var=IT.AESLIFE, tgt_var=AESLIFE
  assign_ct(
    raw_dat = ae_raw,
    raw_var = "IT.AESLIFE",
    tgt_var = "AESLIFE",
    ct_spec = study_ct,
    ct_clst = "C66742",
    id_vars = oak_id_vars()
  ) %>%
  # Map AESOD using assign_ct, raw_var=AESOD, tgt_var=AESOD
  assign_ct(
    raw_dat = ae_raw,
    raw_var = "AESOD",
    tgt_var = "AESOD",
    ct_spec = study_ct,
    ct_clst = "C66742",
    id_vars = oak_id_vars()
  ) %>%
  # Map AEDTC using assign_datetime, raw_var=AEDTCOL
  # assign_datetime 将原始日期字符串解析并转换为 ISO 8601 格式（YYYY-MM-DD）
  assign_datetime(
    raw_dat = ae_raw,
    raw_var = "AEDTCOL",
    tgt_var = "AEDTC",
    raw_fmt = c("m/d/y")
  ) %>%
  # Map AESTDTC using assign_datetime, raw_var=IT.AESTDAT
  assign_datetime(
    raw_dat = ae_raw,
    raw_var = "IT.AESTDAT",
    tgt_var = "AESTDTC",
    raw_fmt = c("m/d/y"),
    id_vars = oak_id_vars()
  ) %>%
  # Map AEENDTC using assign_datetime, raw_var=IT.AEENDAT
  assign_datetime(
    raw_dat = ae_raw,
    raw_var = "IT.AEENDAT",
    tgt_var = "AEENDTC",
    raw_fmt = c("m/d/y"),
    id_vars = oak_id_vars()
  )

## ----r------------------------------------------------------------------------
# 补充固定变量（STUDYID、DOMAIN 等），
# 直接从 ae_raw 赋值 MedDRA 编码字段（已由第三方 MedDRA 编码供应商预填充）
# derive_seq 自动为每个受试者内的 AE 记录生成递增序号 AESEQ（SDTM 强制要求）
# derive_study_day 计算相对研究日（用药日为第1天，用药前为负数）
ae <- ae %>%
  dplyr::mutate(
    STUDYID = ae_raw$STUDY,
    DOMAIN = "AE",
    USUBJID = paste0("01-", ae_raw$PATNUM),
    AELLT = ae_raw$AELLT,
    AELLTCD = ae_raw$AELLTCD,
    AEDECOD = ae_raw$AEDECOD,
    AEPTCD = ae_raw$AEPTCD,
    AEHLT = ae_raw$AEHLT,
    AEHLTCD = ae_raw$AEHLTCD,
    AEHLGT = ae_raw$AEHLGT,
    AEHLGTCD = ae_raw$AEHLGTCD,
    AEBODSYS = ae_raw$AEBODSYS,
    AEBDSYCD = ae_raw$AEBDSYCD,
    AESOC = ae_raw$AESOC,
    AESOCCD = ae_raw$AESOCCD,
    AETERM = toupper(AETERM)  # SDTM 要求 AETERM 必须大写
  ) %>%
  derive_seq(
    tgt_var = "AESEQ",
    rec_vars = c("USUBJID", "AETERM")
  ) %>%
  derive_study_day(
    sdtm_in = .,
    dm_domain = dm,
    tgdt = "AESTDTC",
    refdt = "RFXSTDTC",
    study_day_var = "AESTDY"
  ) %>%
  derive_study_day(
    sdtm_in = .,
    dm_domain = dm,
    tgdt = "AEENDTC",
    refdt = "RFXENDTC",
    study_day_var = "AEENDY"
  ) %>%
  # 按 SDTM AE 域变量列表筛选并排序输出变量，确保符合提交规范
  select(
    "STUDYID", "DOMAIN", "USUBJID", "AESEQ", "AETERM", "AELLT", "AELLTCD", "AEDECOD", "AEPTCD", "AEHLT", "AEHLTCD", "AEHLGT",
    "AEHLGTCD", "AEBODSYS", "AEBDSYCD", "AESOC", "AESOCCD", "AESEV", "AESER", "AEACN", "AEREL", "AEOUT", "AESCAN", "AESCONG",
    "AESDISAB", "AESDTH", "AESHOSP", "AESLIFE", "AESOD", "AEDTC", "AESTDTC", "AEENDTC", "AESTDY", "AEENDY"
  )
