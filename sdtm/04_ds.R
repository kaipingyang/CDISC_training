# =============================================================================
# 域名称：DS（Disposition，受试者处置数据集）
# =============================================================================
# 功能说明：
#   将原始处置数据（ds_raw，EDC 采集）按 CDISC SDTM 标准整理成 DS 域数据集，
#   记录每个受试者的关键处置事件：随机化、完成/退出研究、死亡等。
#   每个受试者可能有多条处置记录（随机化一条 + 完成/退出一条 + …）。
#
# 使用的包：
#   - sdtm.oak       : SDTM 映射核心工具包（Roche/pharmaverse）
#   - pharmaverseraw : 提供示例原始数据（模拟 EDC 采集数据）
#   - dplyr          : 数据操作
#   - xportr         : 导出为 SAS 传输文件（.xpt）
#
# 输入数据来源：
#   - pharmaverseraw::ds_raw  : 处置采集原始数据
#   - pharmaversesdtm::dm     : DM 域（提供 RFXSTDTC 用于计算研究日）
#   - metadata/sdtm_ct.csv    : CDISC 受控术语对照表
#
# 输出文件：
#   - ds.xpt（SAS 传输文件，写入 sdtm/output/）
#
# 关键概念说明（给不熟悉 R 的临床数据人员）：
#   DS 域记录"受试者在研究中发生了什么"（随机化/完成/退出/死亡）
#   DSTERM / DSDECOD：处置事件的原始描述 / 标准化编码（大写；DSDECOD 缺失时
#     用 OTHERSP 兜底——EDC 只填了"其他"字段的处置事件）
#   DSCAT：处置分类。本数据三类——随机化行=RANDOMIZED→PROTOCOL MILESTONE；
#     其他自由文本+"Deaths"类别→DISPOSITION EVENT；Final Lab/Retrieval Visit→OTHER EVENT
#   DSSTDTC：处置事件日期。死亡行按 SDTM 规范取死亡日期 DEATHDT（而非记录日期）
#   VISITNUM / VISIT：访视信息。VISIT 直接取原始 INSTANCE 大写（EDC 采集文本）；
#     VISITNUM 用内置查表（metadata 的 VISITNUM 对照表与官方口径有出入，不用 assign_ct）
#   DSSPID：赞助商定义的处置标识——原始 EDC 未采集该字段，本脚本恒为缺失（见 README）
#   DSSEQ：每个受试者内处置事件的序号；DSSTDY：相对首次用药日的研究日
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
# 读入受控术语对照表（仅 DSTEQ 序列/查找用；本脚本 VISITNUM 不用 assign_ct，见下方注释）
study_ct <- read.csv("metadata/sdtm_ct.csv")

## ----r------------------------------------------------------------------------
# 处置事件名称与编码的映射：
#   DSTERM / DSDECOD 原样复制原始值，再统一补缺失（OTHERSP 兜底）并转大写；
#   DSCAT 按处置类型分类（RANDOMIZED 行是方案里程碑而非处置事件）
ds <- ds_raw %>%
  # 骨架：先只保留 OAK 追踪列（assign_* 会把 raw_dat 的列并进来，
  # 若 tgt_dat 已含同名原始列会变成 x/y 后缀导致取不到值）；
  # INSTANCE（访视名）后续 mutate 直接用，提前带出（assign_* 会丢弃未用原始列）
  select(oak_id, raw_source, patient_number, INSTANCE, OTHERSP, DSTMCOL) %>%
  # Map DSTERM / DSDECOD using assign_no_ct
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
  # 统一大小写 + OTHERSP 兜底（EDC 只填"其他"时 DSTERM/DSDECOD 为 NA）
  dplyr::mutate(
    DSTERM  = toupper(ifelse(is.na(DSTERM),  OTHERSP, DSTERM)),
    DSDECOD = toupper(ifelse(is.na(DSDECOD), OTHERSP, DSDECOD)),
    # DSCAT：随机化行=方案里程碑；Final Lab/Retrieval Visit=其他事件；其余=处置事件
    DSCAT = dplyr::case_when(
      DSDECOD == "RANDOMIZED"                                ~ "PROTOCOL MILESTONE",
      toupper(DSTERM) %in% c("FINAL LAB VISIT", "FINAL RETRIEVAL VISIT") ~ "OTHER EVENT",
      TRUE                                                    ~ "DISPOSITION EVENT"
    )
  ) %>%
  # VISIT：直接取原始访视名大写（官方口径 = INSTANCE 大写；CT 对照表值与官方有出入）
  dplyr::mutate(VISIT = toupper(INSTANCE)) %>%
  # VISITNUM：官方口径的访视序号（BASELINE=3、WEEK 2=4、非计划访视=小数）。
  # 注意 metadata 的 VISITNUM 对照表整体错位（WEEK 2 应为 4 而非 5），故用内置查表：
  dplyr::mutate(VISITNUM = dplyr::if_else(
    grepl("^UNSCHEDULED ", VISIT),
    as.numeric(sub("^UNSCHEDULED ", "", VISIT)),
    unname(c("SCREENING 1" = 1, "SCREENING 2" = 2, "BASELINE" = 3,
             "AMBUL ECG PLACEMENT" = 3.5, "WEEK 2" = 4, "WEEK 4" = 5,
             "AMBUL ECG REMOVAL" = 6, "WEEK 6" = 7, "WEEK 8" = 8,
             "WEEK 12" = 9, "WEEK 16" = 10, "WEEK 20" = 11, "WEEK 24" = 12,
             "WEEK 26" = 13, "RETRIEVAL" = 201)[VISIT])
  )) %>%
  # DSDTC：处置记录日期。官方口径——只有 Final Lab / Retrieval Visit（OTHER EVENT）
  # 且 EDC 采集了时间（DSTMCOL 非缺失）才保留时间成分，其余仅日期
  assign_datetime(
    raw_dat = ds_raw,
    raw_var = "DSDTCOL",
    tgt_var = "TEMP_DSDTC",
    raw_fmt = c("mm-dd-yyyy"),
    id_vars = oak_id_vars()
  ) %>%
  dplyr::mutate(DSDTC = dplyr::if_else(
    toupper(DSTERM) %in% c("FINAL LAB VISIT", "FINAL RETRIEVAL VISIT") & !is.na(DSTMCOL),
    paste0(as.character(TEMP_DSDTC), "T", DSTMCOL),
    as.character(TEMP_DSDTC) # assign_datetime 返回 iso8601 类，需转普通字符再参与 if_else
  )) %>%
  # 死亡日期先单独转 ISO（供 DSSTDTC 死亡行替换使用）
  assign_datetime(
    raw_dat = ds_raw,
    raw_var = "DEATHDT",
    tgt_var = "TEMP_DEATHDTC",
    raw_fmt = c("mm/dd/yyyy"),
    id_vars = oak_id_vars()
  ) %>%
  # DSSTDTC：处置事件日期；死亡行按 SDTM 规范取死亡日期（DEATHDT）
  # 常规行用 EDC 采集的"事件日期"（IT.DSSTDAT，mm-dd-yyyy 连字符格式）
  assign_datetime(
    raw_dat = ds_raw,
    raw_var = "IT.DSSTDAT",
    tgt_var = "DSSTDTC",
    raw_fmt = c("mm-dd-yyyy"),
    id_vars = oak_id_vars()
  ) %>%
  dplyr::mutate(DSSTDTC = ifelse(DSDECOD == "DEATH", TEMP_DEATHDTC, DSSTDTC))

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
    DSSPID = NA_character_ # 原始 EDC 无 DSSPID 字段，无法重建（官方数据有 95 行，见 README）
  ) %>%
  # 按受试者、日期、类别、编码排序后生成序号（同日多事件时按 DSCAT 字母序：
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
dir <- "sdtm/output"
dir.create(dir, showWarnings = FALSE, recursive = TRUE)
ds %>%
  xportr_write(file.path(dir, "ds.xpt"), domain = "DS")

message("DS 域生成完成！文件已保存为 ds.xpt")
