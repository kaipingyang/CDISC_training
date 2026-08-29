# =============================================================================
# 域名称：EX（Exposure，研究药物暴露数据集）
# =============================================================================
# 功能说明：
#   将原始暴露/用药数据（ec_raw，EDC 采集）按 CDISC SDTM 标准整理成 EX 域数据集，
#   记录每个受试者的研究药物给药情况：药物名称、剂量、单位、剂型、频率、途径、
#   给药起止日期。
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
# 映射 EX 域变量（EXDOSU/EXDOSFRQ 用受控术语；EXDOSFRM/EXROUTE 因 CT 表无对应条目
# 用原样复制 + 大写）
ex <- ec_raw %>%
  # 骨架：先只保留 OAK 追踪列；VISITNAME（访视名）后续 mutate 直接用，提前带出
  select(oak_id, raw_source, patient_number, VISITNAME) %>%
  assign_no_ct(
    raw_dat = ec_raw,
    raw_var = "DRUGAD",
    tgt_var = "EXTRT",
    id_vars = oak_id_vars()
  ) %>%
  # EXDOSE：原始剂量文本（如 "0"）转数值型（原始列从外层 ec_raw 取）
  mutate(EXDOSE = as.numeric(ec_raw[["IT.ECDSTXT"]])) %>%
  # EXDOSU：受控术语（C71620：mg 等剂量单位）
  assign_ct(
    raw_dat = ec_raw,
    raw_var = "IT.ECDOSU",
    tgt_var = "EXDOSU",
    ct_spec = study_ct,
    ct_clst = "C71620",
    id_vars = oak_id_vars()
  ) %>%
  # EXDOSFRM：原样复制（CT 表无 PATCH 剂型条目）
  assign_no_ct(
    raw_dat = ec_raw,
    raw_var = "DOSFM",
    tgt_var = "EXDOSFRM",
    id_vars = oak_id_vars()
  ) %>%
  # EXDOSFRQ：受控术语（C71113：QD 等给药频率）
  assign_ct(
    raw_dat = ec_raw,
    raw_var = "DOSFRQ",
    tgt_var = "EXDOSFRQ",
    ct_spec = study_ct,
    ct_clst = "C71113",
    id_vars = oak_id_vars()
  ) %>%
  # EXROUTE：原样复制（CT 表无 Transdermal 条目）
  assign_no_ct(
    raw_dat = ec_raw,
    raw_var = "IT.ECROUTE",
    tgt_var = "EXROUTE",
    id_vars = oak_id_vars()
  ) %>%
  # EXSTDTC / EXENDTC：原始日期格式 dd-mmm-yyyy
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
  # TODO 1: 大写规范——EXTRT/EXDOSFRM/EXROUTE 统一为大写（官方口径），
  #   访视名 VISIT 直接取原始 VISITNAME 大写（toupper(VISITNAME)）
  #   提示：EXDOSFRM/EXROUTE 因 metadata CT 表无对应条目（PATCH 剂型/Transdermal 途径），
  #   不能用 assign_ct，只能原样复制后大写
  # 👉 在这里补一段 mutate(...)
  identity() %>%
  # TODO 2: 派生 VISITNUM 与 VISITDY（官方口径）
  #   查表：BASELINE=3、WEEK 2=4…WEEK 26=13、AMBUL ECG REMOVAL=6、RETRIEVAL=201、
  #   UNSCHEDULED 1.1=1.1（后缀小数）；VISITDY：BASELINE=1，Week N = N×7
  #   （本练习 EX 数据只有 BASELINE / WEEK 2 / WEEK 24，查表务必覆盖 WEEK 24=12）
  #   （metadata 的 VISITNUM 对照表整体错位，勿用 assign_ct——与 ds.R 同一查表）
  #   提示：c("BASELINE"=3, "WEEK 2"=4, ...)[VISIT] 查表 + if_else + sub("^WEEK ",...)
  # 👉 在这里补一段 mutate(...)；⚠️ 注意：这是本段管道的最后一步，结尾不要写 %>%（否则
  #   管道悬空会把下面第二段的 `ex <- ex %>%` 吞进本链，运行报 "object 'ex' not found"）
  identity()
  # EXDOSE 等原始列注意：assign_* 会丢弃未用原始列，需要的外层列从 ec_raw 取

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
  # TODO 3: 派生 EXENDY（用药结束日相对首次用药研究日）
  #   参考上方 EXSTDY 的 derive_study_day 写法，只换 tgdt/study_day_var 两个参数
  # 👉 在这里补一段 derive_study_day(...)
  identity() %>%
  dplyr::select("STUDYID", "DOMAIN", "USUBJID", "EXSEQ", "EXTRT", "EXDOSE", "EXDOSU",
                "EXDOSFRM", "EXDOSFRQ", "EXROUTE", "VISITNUM", "VISIT",
                "VISITDY", "EXSTDTC", "EXENDTC", "EXSTDY", "EXENDY")

## ----r export----------------------------------------------------------------
# 导出为 SAS 传输文件（.xpt），供下游 ADaM 或电子提交使用
dir <- "users/<STUDENT_NAME>/sdtm/output"
dir.create(dir, showWarnings = FALSE, recursive = TRUE)
ex %>%
  xportr_write(file.path(dir, "ex.xpt"), domain = "EX")
