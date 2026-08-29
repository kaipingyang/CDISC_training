# =============================================================================
# 域名称：DS（Disposition，受试者处置数据集）
# =============================================================================
# 功能说明：
#   将原始处置数据（ds_raw，EDC 采集）按 CDISC SDTM 标准整理成 DS 域数据集，
#   记录每个受试者的关键处置事件：随机化、完成/退出研究、死亡等。
#
# =============================================================================
# 【练习版】按 # TODO 提示填空。填不出就问 Claude Code："帮我补全这个 TODO"——
# 练习模式只会给提示，不会直接读答案，也不会替你写完整版。
# 写完自查：跟 Claude Code 说"我写完了，帮我对照检查"，它会逐条说明差异。
# 项目根的 sdtm/ adam/ tfl/ 是完整答案脚本（供对照，勿改），练习时不要读/改它们。
# =============================================================================

## ----r setup, message=FALSE, warning=FALSE------------------------------------
library(sdtm.oak)
library(pharmaverseraw)
library(dplyr)
library(xportr)

# 读入原始处置数据
ds_raw <- pharmaverseraw::ds_raw

## ----r------------------------------------------------------------------------
# 生成 OAK 内部追踪 ID，确保后续映射时记录精确对应
ds_raw <- ds_raw %>%
  generate_oak_id_vars(
    pat_var = "PATNUM",
    raw_src = "ds_raw"
  )

## ----r, echo = TRUE-----------------------------------------------------------
# 读入受控术语对照表（本脚本 VISITNUM 不用 assign_ct，见下方注释）
study_ct <- read.csv("metadata/sdtm_ct.csv")

## ----r------------------------------------------------------------------------
# 映射处置事件名称/编码：
ds <- ds_raw %>%
  # 骨架：先只保留 OAK 追踪列（assign_* 会把 raw_dat 的列并进来，
  # 若 tgt_dat 已含同名原始列会变成 x/y 后缀导致取不到值）；
  # INSTANCE（访视名）/OTHERSP（兜底描述）/DSTMCOL（时间）后续 mutate 直接用，提前带出
  select(oak_id, raw_source, patient_number, INSTANCE, OTHERSP, DSTMCOL) %>%
  assign_no_ct(
    raw_dat = ds_raw,
    raw_var = "IT.DSTERM",
    tgt_var = "DSTERM",
    id_vars = oak_id_vars()
  ) %>%
  assign_no_ct(
    raw_dat = ds_raw,
    raw_var = "IT.DSDECOD",
    tgt_var = "DSDECOD",
    id_vars = oak_id_vars()
  ) %>%
  # TODO 1: 补全 DSTERM/DSDECOD —— 统一为大写，且缺失时用 OTHERSP 兜底
  #   提示：toupper(ifelse(is.na(DSTERM), OTHERSP, DSTERM))——DSTERM 列在上一步 assign_no_ct 已生成
  # 👉 在这里补一段 dplyr::mutate(...)，参考下面 DSCAT 的 case_when 写法
  identity() %>%
  # VISIT：直接取原始访视名大写（官方口径 = INSTANCE 大写）
  dplyr::mutate(VISIT = toupper(INSTANCE)) %>%
  # TODO 2: 派生 DSCAT（处置分类）——三分类 case_when：
  #   DSDECOD=="RANDOMIZED" → "PROTOCOL MILESTONE"
  #   DSTERM ∈ {"FINAL LAB VISIT","FINAL RETRIEVAL VISIT"} → "OTHER EVENT"
  #   其余 → "DISPOSITION EVENT"
  # 👉 在这里补一段 DSCAT = dplyr::case_when(...)
  dplyr::mutate(DSCAT = NA_character_) %>% # 占位：填好 TODO 后删除本行
  # TODO 3: 派生 VISITNUM。为什么不用 assign_ct？—— metadata 的 VISITNUM 对照表
  #   整体错位（WEEK 2 应为 4 而非 5），官方口径是内置查表：
  #   BASELINE=3、WEEK 2=4、WEEK 4=5…WEEK 26=13、AMBUL ECG PLACEMENT=3.5、RETRIEVAL=201、
  #   非计划访视（UNSCHEDULED 1.1 等）= 后缀小数
  #   提示：c("BASELINE"=3, "WEEK 2"=4, ...)[VISIT] 取值 + unname()；UNSCHEDULED 用 sub() 截小数
  # 👉 在这里补一段 dplyr::mutate(VISITNUM = dplyr::if_else(...))
  identity() %>%
  # TODO 4: 派生 DSDTC（处置记录日期，含时间部分）
  #   ① assign_datetime 把 DSDTCOL（mm-dd-yyyy）转为 ISO（tgt_var="TEMP_DSDTC"）
  #   ② OTHER EVENT（FINAL LAB/RETRIEVAL VISIT）且 DSTMCOL 非缺失的行拼上 "T" + 时间，
  #      其余仅日期——dplyr::mutate(DSDTC = dplyr::if_else(...))
  #   注意：assign_datetime 返回 iso8601 类，参与 if_else 前先 as.character()
  # 👉 在这里补两段（assign_datetime + mutate）
  identity() %>%
  # 死亡日期先单独转 ISO（供 DEATH 行 DSSTDTC 替换使用）
  assign_datetime(
    raw_dat = ds_raw,
    raw_var = "DEATHDT",
    tgt_var = "TEMP_DEATHDTC",
    raw_fmt = c("mm/dd/yyyy"),
    id_vars = oak_id_vars()
  ) %>%
  # DSSTDTC：处置事件日期（IT.DSSTDAT，mm-dd-yyyy 连字符格式）
  assign_datetime(
    raw_dat = ds_raw,
    raw_var = "IT.DSSTDAT",
    tgt_var = "DSSTDTC",
    raw_fmt = c("mm-dd-yyyy"),
    id_vars = oak_id_vars()
  ) %>%
  # TODO 5: 死亡行（DSDECOD == "DEATH"）的 DSSTDTC 改为取 DEATHDT（TEMP_DEATHDTC）
  #   用 dplyr::mutate(DSSTDTC = ifelse(...))
  # 👉 在这里补一段 dplyr::mutate(...)
  identity()

## ----r------------------------------------------------------------------------
# 补充固定变量并做最终整理：
#   DSSPID - 赞助商定义的处置标识（EDC 未采集，恒缺失）
#   DSSEQ  - 受试者内处置事件序号
#   DSSTDY - 相对首次用药日的研究日
ds <- ds %>%
  dplyr::mutate(
    STUDYID = ds_raw$STUDY,
    DOMAIN = "DS",
    USUBJID = paste0("01-", ds_raw$PATNUM),
    DSSPID = NA_character_ # 原始 EDC 无 DSSPID 字段，无法重建
  ) %>%
  # 按受试者、日期、类别排序后生成序号（同日多事件时按 DSCAT 字母序：
  # DISPOSITION EVENT 先于 OTHER EVENT，与官方口径一致）
  arrange(USUBJID, DSSTDTC, DSCAT, DSDECOD) %>%
  derive_seq(
    tgt_var = "DSSEQ",
    rec_vars = c("USUBJID")
  ) %>%
  derive_study_day(
    sdtm_in = .,
    dm_domain = pharmaversesdtm::dm,
    tgdt = "DSSTDTC",
    refdt = "RFXSTDTC",
    study_day_var = "DSSTDY"
  ) %>%
  dplyr::select("STUDYID", "DOMAIN", "USUBJID", "DSSEQ", "DSSPID", "DSTERM", "DSDECOD",
                "DSCAT", "VISITNUM", "VISIT", "DSDTC", "DSSTDTC", "DSSTDY")

## ----r export----------------------------------------------------------------
# 导出为 SAS 传输文件（.xpt），供下游 ADaM 或电子提交使用
dir <- "users/<STUDENT_NAME>/sdtm/output"
dir.create(dir, showWarnings = FALSE, recursive = TRUE)
ds %>%
  xportr_write(file.path(dir, "ds.xpt"), domain = "DS")
