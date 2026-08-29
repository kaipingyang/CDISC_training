# =============================================================================
# 域名称：EX（Exposure，研究药物暴露数据集）
# =============================================================================
# 功能说明：
#   将原始暴露/用药数据（ec_raw，EDC 采集）按 CDISC SDTM 标准整理成 EX 域数据集，
#   记录每个受试者的研究药物给药情况：药物名称、剂量、单位、剂型、频率、途径、
#   给药起止日期。
#
# 使用的包：
#   - sdtm.oak       : SDTM 映射核心工具包（Roche/pharmaverse）
#   - pharmaverseraw : 提供示例原始数据（模拟 EDC 采集数据）
#   - dplyr          : 数据操作
#   - xportr         : 导出为 SAS 传输文件（.xpt）
#
# 输入数据来源：
#   - pharmaverseraw::ec_raw  : 暴露采集原始数据（每条记录一次给药期）
#   - pharmaversesdtm::dm     : DM 域（提供 RFXSTDTC 用于计算研究日）
#   - metadata/sdtm_ct.csv    : CDISC 受控术语对照表
#
# 输出文件：
#   - ex.xpt（SAS 传输文件，写入 sdtm/output/）
#
# 关键概念说明（给不熟悉 R 的临床数据人员）：
#   EX 域记录"实际给了什么药"——与 DM 域的计划治疗不同，这里逐条记录每次给药
#   EXDOSE：给药剂量（数值）；EXDOSU：剂量单位（受控术语，如 mg）
#   EXDOSFRQ：给药频率（受控术语，如 QD=每日一次）
#   EXDOSFRM / EXROUTE：剂型 / 给药途径——metadata 对照表无对应条目（PATCH 剂型、
#     Transdermal 途经由采集文本原样复制），统一转大写（官方口径为大写）
#   VISITNUM / VISIT / VISITDY：给药发生的访视。VISIT=原始访视名大写；
#     VISITNUM 用内置查表（metadata 的 VISITNUM 对照表与官方口径有出入）；
#     VISITDY = 用药日相对首次用药日的天数（Baseline=1、Week N=N×7）
#   EXSTDTC/EXENDTC：给药开始/结束日期（ISO 8601）
#   EXSTDY/EXENDY：相对首次用药日的研究日；EXSEQ：受试者内给药记录序号
# =============================================================================

## ----r setup, message=FALSE, warning=FALSE------------------------------------
library(sdtm.oak)
library(pharmaverseraw)
library(dplyr)
library(xportr)

# 读入原始暴露数据（EC = Exposure as Collected，EDC 采集形态）
ec_raw <- pharmaverseraw::ec_raw

## ----r------------------------------------------------------------------------
# 生成 OAK 内部追踪 ID，确保后续映射时记录精确对应
ec_raw <- ec_raw %>%
  generate_oak_id_vars(
    pat_var = "PATNUM",
    raw_src = "ec_raw"
  )

## ----r, echo = TRUE-----------------------------------------------------------
# 读入受控术语对照表（仅 EXDOSU / EXDOSFRQ 的映射使用）
study_ct <- read.csv("metadata/sdtm_ct.csv")

## ----r------------------------------------------------------------------------
# 映射 EX 域变量：
#   EXTRT    - 药物名称（自由文本，原样复制 + 大写）
#   EXDOSE   - 给药剂量（原始剂量文本转数值）
#   EXDOSU   - 剂量单位（受控术语："Milligram" → mg）
#   EXDOSFRM - 剂型（CT 表无 patch 剂型条目，原样复制 + 大写）
#   EXDOSFRQ - 给药频率（受控术语："Daily" → QD）
#   EXROUTE  - 给药途径（CT 表无 Transdermal 条目，原样复制 + 大写）
ex <- ec_raw %>%
  # 骨架：先只保留 OAK 追踪列（assign_* 会把 raw_dat 的列并进来，
  # 若 tgt_dat 已含同名原始列会变成 x/y 后缀导致取不到值）；
  # VISITNAME（访视名）后续 mutate 直接用，提前带出
  select(oak_id, raw_source, patient_number, VISITNAME) %>%
  # Map EXTRT using assign_no_ct
  assign_no_ct(
    raw_dat = ec_raw,
    raw_var = "DRUGAD",
    tgt_var = "EXTRT",
    id_vars = oak_id_vars()
  ) %>%
  # Map EXDOSE：原始剂量文本（如 "0"）转数值型
  # 注意：assign_* 会把 tgt_dat 中未用到的原始列丢掉，原始列要从外层 ec_raw 取
  mutate(EXDOSE = as.numeric(ec_raw[["IT.ECDSTXT"]])) %>%
  # Map EXDOSU using assign_ct（同义词匹配 "Milligram" → mg）
  assign_ct(
    raw_dat = ec_raw,
    raw_var = "IT.ECDOSU",
    tgt_var = "EXDOSU",
    ct_spec = study_ct,
    ct_clst = "C71620",
    id_vars = oak_id_vars()
  ) %>%
  # Map EXDOSFRM using assign_no_ct（CT 表无 PATCH 剂型条目，原样复制）
  assign_no_ct(
    raw_dat = ec_raw,
    raw_var = "DOSFM",
    tgt_var = "EXDOSFRM",
    id_vars = oak_id_vars()
  ) %>%
  # Map EXDOSFRQ using assign_ct（同义词匹配 "Daily" → QD）
  assign_ct(
    raw_dat = ec_raw,
    raw_var = "DOSFRQ",
    tgt_var = "EXDOSFRQ",
    ct_spec = study_ct,
    ct_clst = "C71113",
    id_vars = oak_id_vars()
  ) %>%
  # Map EXROUTE using assign_no_ct（CT 表无 Transdermal 条目，原样复制）
  assign_no_ct(
    raw_dat = ec_raw,
    raw_var = "IT.ECROUTE",
    tgt_var = "EXROUTE",
    id_vars = oak_id_vars()
  ) %>%
  # Map EXSTDTC / EXENDTC using assign_datetime（原始日期格式：dd-mmm-yyyy）
  assign_datetime(
    raw_dat = ec_raw,
    raw_var = "IT.ECSTDAT",
    tgt_var = "EXSTDTC",
    raw_fmt = c("dd-mmm-yyyy"),
    id_vars = oak_id_vars()
  ) %>%
  assign_datetime(
    raw_dat = ec_raw,
    raw_var = "IT.ECENDAT",
    tgt_var = "EXENDTC",
    raw_fmt = c("dd-mmm-yyyy"),
    id_vars = oak_id_vars()
  ) %>%
  # 大写规范：EXTRT/EXDOSFRM/EXROUTE 大写（官方口径），访视名 VISIT 直接取原始大写
  mutate(
    EXTRT = toupper(EXTRT),
    EXDOSFRM = toupper(EXDOSFRM),
    EXROUTE = toupper(EXROUTE),
    VISIT = toupper(VISITNAME)
  ) %>%
  # VISITNUM：官方口径的访视序号（与 ds.R 同一查表——metadata 对照表错位，不用 assign_ct）
  mutate(VISITNUM = dplyr::if_else(
    grepl("^UNSCHEDULED ", VISIT),
    as.numeric(sub("^UNSCHEDULED ", "", VISIT)),
    unname(c("SCREENING 1" = 1, "SCREENING 2" = 2, "BASELINE" = 3,
             "AMBUL ECG PLACEMENT" = 3.5, "WEEK 2" = 4, "WEEK 4" = 5,
             "AMBUL ECG REMOVAL" = 6, "WEEK 6" = 7, "WEEK 8" = 8,
             "WEEK 12" = 9, "WEEK 16" = 10, "WEEK 20" = 11, "WEEK 24" = 12,
             "WEEK 26" = 13, "RETRIEVAL" = 201)[VISIT])
  )) %>%
  # VISITDY：用药日相对首次用药日（Baseline=1，Week N=N×7）
  mutate(VISITDY = dplyr::if_else(
    VISIT == "BASELINE", 1,
    as.numeric(sub("^WEEK ", "", VISIT)) * 7
  ))

## ----r------------------------------------------------------------------------
# 补充固定变量并做最终整理：
#   EXSEQ  - 受试者内给药记录序号
#   EXSTDY / EXENDY - 相对首次用药日的研究日（EXENDTC 缺失时 EXENDY 为 NA）
ex <- ex %>%
  dplyr::mutate(
    STUDYID = ec_raw$STUDY,
    DOMAIN = "EX",
    USUBJID = paste0("01-", ec_raw$PATNUM)
  ) %>%
  # 按受试者、访视、给药日期排序后生成序号
  arrange(USUBJID, VISITNUM, EXSTDTC) %>%
  derive_seq(
    tgt_var = "EXSEQ",
    rec_vars = c("USUBJID")
  ) %>%
  derive_study_day(
    sdtm_in = .,
    dm_domain = pharmaversesdtm::dm,
    tgdt = "EXSTDTC",
    refdt = "RFXSTDTC",
    study_day_var = "EXSTDY"
  ) %>%
  derive_study_day(
    sdtm_in = .,
    dm_domain = pharmaversesdtm::dm,
    tgdt = "EXENDTC",
    refdt = "RFXSTDTC",
    study_day_var = "EXENDY"
  ) %>%
  dplyr::select("STUDYID", "DOMAIN", "USUBJID", "EXSEQ", "EXTRT", "EXDOSE", "EXDOSU",
                "EXDOSFRM", "EXDOSFRQ", "EXROUTE", "VISITNUM", "VISIT",
                "VISITDY", "EXSTDTC", "EXENDTC", "EXSTDY", "EXENDY")

## ----r export----------------------------------------------------------------
# 导出为 SAS 传输文件（.xpt），供下游 ADaM 或电子提交使用
dir <- "sdtm/output"
dir.create(dir, showWarnings = FALSE, recursive = TRUE)
ex %>%
  xportr_write(file.path(dir, "ex.xpt"), domain = "EX")

message("EX 域生成完成！文件已保存为 ex.xpt")
