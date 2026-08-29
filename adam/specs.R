# =============================================================================
# 数据集规格扩展：ADLB / ADEG / ADCM
# =============================================================================
# 功能说明：
#   metadata/safety_specs.xlsx 是从外部下载的原始规格资产（含 ADSL/ADVS/ADAE），
#   项目约定不改动它。本文件存放答案库中新增数据集的规格数据（ADLB/ADEG/ADCM），
#   以 R 数据框形式提供，结构与基线规格的 metacore 转换结果一致，
#   供答案脚本运行时构造 metacore 对象（metacore() -> select_dataset()）。
#
# 使用方式（答案脚本内）：
#   source("adam/specs.R")
#   metacore <- load_dataset_spec("ADLB")
#
# 设计说明：
#   1. 变量标签/类型/长度取自官方 pharmaverseadam 数据（attr label + class）；
#   2. PARAMCD/PARAM/PARAMN 受控术语来自官方参数全集（ADLB 47 项、ADEG 8 项）；
#   3. 本文件所有数据框为增量行，装配时与基线只读合并后构造 metacore 对象。
# =============================================================================

library(metacore)
library(metatools)
library(dplyr)

# ---- 数据集特有变量属性（var_spec 增量：variable/length/label/type/format/common） ----
adlb_var_spec <- data.frame(
  variable = c(c("STUDYID", "USUBJID", "SUBJID", "SITEID", "COUNTRY", "ETHNIC", "AGE", "AGEU", "SEX", "RACE", "ACTARM", "TRT01P", "TRT01A", "TRTSDT", "TRTEDT", "DOMAIN", "LBSEQ", "LBTESTCD", "LBTEST", "LBCAT", "LBORRES", "LBORRESU", "LBORNRLO", "LBORNRHI", "LBSTRESC", "LBSTRESN", "LBSTRESU", "LBSTNRLO", "LBSTNRHI", "LBNRIND", "LBBLFL", "VISITNUM", "VISIT", "VISITDY", "LBDTC", "LBDY", "ASEQ", "ADT", "ADY", "AVISIT", "AVISITN", "PARAM", "PARAMCD", "PARAMN", "PARCAT1", "AVAL", "AVALC", "BASE", "BASEC", "BASETYPE", "CHG", "PCHG", "SHIFT1", "DTYPE", "BNRIND", "ANRIND", "ANRLO", "ANRHI", "ABLFL", "ANL01FL", "ONTRTFL", "TRTP", "TRTA")),
  length = c(14, 13, 6, 5, 5, 24, 8, 7, 3, 34, 22, 22, 22, 8, 8, 4, 8, 9, 41, 12, 7, 10, 7, 7, 10, 8, 10, 8, 8, 10, 3, 8, 21, 8, 18, 8, 8, 8, 8, 23, 8, 50, 9, 8, 12, 8, 9, 8, 8, 6, 8, 8, 18, 13, 8, 8, 8, 8, 3, 3, 3, 22, 22),
  label = c(c("Study Identifier", "Unique Subject Identifier", "Subject Identifier for the Study", "Study Site Identifier", "Country", "Ethnicity", "Age", "Age Units", "Sex", "Race", "Description of Actual Arm", "Planned Treatment for Period 01", "Actual Treatment for Period 01", "Date of First Exposure to Treatment", "Date of Last Exposure to Treatment", "Domain Abbreviation", "Sequence Number", "Lab Test or Examination Short Name", "Lab Test or Examination Name", "Category for Lab Test", "Result or Finding in Original Units", "Original Units", "Reference Range Lower Limit in Orig Unit", "Reference Range Upper Limit in Orig Unit", "Character Result/Finding in Std Format", "Numeric Result/Finding in Standard Units", "Standard Units", "Reference Range Lower Limit-Std Units", "Reference Range Upper Limit-Std Units", "Reference Range Indicator", "Baseline Flag", "Visit Number", "Visit Name", "Planned Study Day of Visit", "Date/Time of Specimen Collection", "Study Day of Specimen Collection", "Analysis Sequence Number", "Analysis Date", "Analysis Relative Day", "Analysis Visit", "Analysis Visit (N)", "Parameter", "Parameter Code", "Parameter (N)", "Parameter Category 1", "Analysis Value", "Analysis Value (C)", "Baseline Value", "Baseline Value (C)", "Baseline Type", "Change from Baseline", "Percent Change from Baseline", "Shift from Baseline to Analysis Value", "Derivation Type", "Baseline Reference Range Indicator", "Analysis Reference Range Indicator", "Analysis Normal Range Lower Limit", "Analysis Normal Range Upper Limit", "Baseline Record Flag", "Analysis Flag 01", "On Treatment Record Flag", "Planned Treatment", "Actual Treatment")),
  type = c(c("text", "text", "text", "text", "text", "text", "float", "text", "text", "text", "text", "text", "text", "integer", "integer", "text", "float", "text", "text", "text", "text", "text", "text", "text", "text", "float", "text", "float", "float", "text", "text", "float", "text", "float", "text", "float", "integer", "integer", "float", "text", "float", "text", "text", "float", "text", "float", "text", "float", "text", "text", "float", "float", "text", "text", "text", "text", "float", "float", "text", "text", "text", "text", "text")),
  format = c(c(NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_)),
  common = c(c("TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE")),
  stringsAsFactors = FALSE)

adeg_var_spec <- data.frame(
  variable = c(c("STUDYID", "USUBJID", "SUBJID", "SITEID", "COUNTRY", "ETHNIC", "AGE", "AGEU", "SEX", "RACE", "ACTARM", "TRT01P", "TRT01A", "TRTSDT", "TRTEDT", "DOMAIN", "EGSEQ", "EGTESTCD", "EGTEST", "EGORRES", "EGORRESU", "EGSTRESC", "EGSTRESN", "EGSTRESU", "EGSTAT", "EGLOC", "EGBLFL", "VISITNUM", "VISIT", "VISITDY", "EGDTC", "EGDY", "EGTPT", "EGTPTNUM", "EGELTM", "EGTPTREF", "ASEQ", "ADT", "ADY", "ATPT", "ATPTN", "AVISIT", "AVISITN", "PARAM", "PARAMCD", "PARAMN", "AVAL", "AVALC", "AVALCAT1", "AVALCA1N", "BASE", "BASEC", "BASETYPE", "CHG", "CHGCAT1", "CHGCAT1N", "PCHG", "DTYPE", "ANRIND", "BNRIND", "ANRLO", "ANRHI", "ABLFL", "ANL01FL", "ONTRTFL", "TRTP", "TRTA")),
  length = c(14, 13, 6, 5, 5, 24, 8, 7, 3, 34, 22, 22, 22, 8, 8, 4, 8, 8, 20, 10, 11, 10, 8, 11, 8, 8, 3, 8, 21, 8, 12, 8, 32, 8, 6, 18, 8, 8, 8, 32, 8, 10, 8, 55, 8, 8, 8, 10, 14, 8, 8, 8, 16, 8, 12, 8, 8, 9, 8, 8, 8, 8, 3, 3, 3, 22, 22),
  label = c(c("Study Identifier", "Unique Subject Identifier", "Subject Identifier for the Study", "Study Site Identifier", "Country", "Ethnicity", "Age", "Age Units", "Sex", "Race", "Description of Actual Arm", "Planned Treatment for Period 01", "Actual Treatment for Period 01", "Date of First Exposure to Treatment", "Date of Last Exposure to Treatment", "Domain Abbreviation", "Sequence Number", "ECG Test or Examination Short Name", "ECG Test or Examination Name", "Result or Finding in Original Units", "Original Units", "Character Result/Finding in Std Format", "Numeric Result/Finding in Standard Units", "Standard Units", "Completion Status", "Lead Location Used for Measurement", "Baseline Flag", "Visit Number", "Visit Name", "Planned Study Day of Visit", "Date/Time of ECG", "Study Day of ECG", "Planned Time Point Name", "Planned Time Point Number", "Planned Elapsed Time from Time Point Ref", "Time Point Reference", "Analysis Sequence Number", "Analysis Date", "Analysis Relative Day", "Analysis Timepoint", "Analysis Timepoint (N)", "Analysis Visit", "Analysis Visit (N)", "Parameter", "Parameter Code", "Parameter (N)", "Analysis Value", "Analysis Value (C)", "Analysis Value Category 1", "Analysis Value Category 1 (N)", "Baseline Value", "Baseline Value (C)", "Baseline Type", "Change from Baseline", "Change from Baseline Category 1", "Change from Baseline Category 1 (N)", "Percent Change from Baseline", "Derivation Type", "Analysis Reference Range Indicator", "Baseline Reference Range Indicator", "Analysis Normal Range Lower Limit", "Analysis Normal Range Upper Limit", "Baseline Record Flag", "Analysis Flag 01", "On Treatment Record Flag", "Planned Treatment", "Actual Treatment")),
  type = c(c("text", "text", "text", "text", "text", "text", "float", "text", "text", "text", "text", "text", "text", "integer", "integer", "text", "float", "text", "text", "text", "text", "text", "float", "text", "text", "text", "text", "float", "text", "float", "text", "float", "text", "float", "text", "text", "integer", "integer", "float", "text", "float", "text", "float", "text", "text", "float", "float", "text", "text", "float", "float", "text", "text", "float", "text", "float", "float", "text", "text", "text", "float", "float", "text", "text", "text", "text", "text")),
  format = c(c(NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_)),
  common = c(c("TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE")),
  stringsAsFactors = FALSE)

adcm_var_spec <- data.frame(
  variable = c(c("STUDYID", "USUBJID", "SUBJID", "SITEID", "COUNTRY", "AGE", "SEX", "RACE", "ACTARM", "TRT01P", "TRT01A", "TRTSDT", "TRTEDT", "CMSEQ", "CMSPID", "CMTRT", "CMDECOD", "CMINDC", "CMCLAS", "CMDOSE", "CMDOSU", "CMDOSFRQ", "CMROUTE", "VISITNUM", "VISIT", "VISITDY", "CMDTC", "CMSTDTC", "CMENDTC", "CMSTDY", "CMENDY", "CMENRTPT", "ASTDT", "ASTDTF", "AENDT", "AENDTF", "ASTDY", "AENDY", "ADURN", "ADURU", "ONTRTFL", "PREFL", "FUPFL", "AOCCPFL", "ANL01FL", "APHASE", "APHASEN", "ASEQ", "TRTP", "TRTA")),
  length = c(14, 13, 6, 5, 5, 8, 3, 34, 22, 22, 22, 8, 8, 8, 4, 46, 26, 36, 44, 8, 9, 15, 26, 8, 19, 8, 12, 12, 12, 8, 8, 9, 8, 3, 8, 3, 8, 8, 8, 6, 3, 3, 3, 3, 3, 15, 8, 8, 22, 22),
  label = c(c("Study Identifier", "Unique Subject Identifier", "Subject Identifier for the Study", "Study Site Identifier", "Country", "Age", "Sex", "Race", "Description of Actual Arm", "Planned Treatment for Period 01", "Actual Treatment for Period 01", "Date of First Exposure to Treatment", "Date of Last Exposure to Treatment", "Sequence Number", "Sponsor-Defined Identifier", "Reported Name of Drug, Med, or Therapy", "Standardized Medication Name", "Indication", "Medication Class", "Dose per Administration", "Dose Units", "Dosing Frequency per Interval", "Route of Administration", "Visit Number", "Visit Name", "Planned Study Day of Visit", "Date/Time of Collection", "Start Date/Time of Medication", "End Date/Time of Medication", "Study Day of Start of Medication", "Study Day of End of Medication", "End Relative to Reference Time Point", "Analysis Start Date", "Analysis Start Date Imputation Flag", "Analysis End Date", "Analysis End Date Imputation Flag", "Analysis Start Relative Day", "Analysis End Relative Day", "Analysis Duration (N)", "Analysis Duration Units", "On Treatment Record Flag", "Pre-treatment Flag", "Follow-up Flag", "1st Occurrence of Preferred Term Flag", "Analysis Flag 01", "Phase", "Description of Phase N", NA, "Planned Treatment", "Actual Treatment")),
  type = c(c("text", "text", "text", "text", "text", "float", "text", "text", "text", "text", "text", "integer", "integer", "float", "text", "text", "text", "text", "text", "float", "text", "text", "text", "float", "text", "float", "text", "text", "text", "float", "float", "text", "integer", "text", "integer", "text", "float", "float", "float", "text", "text", "text", "text", "text", "text", "text", "float", "text", "text", "text")),
  format = c(c(NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, NA_character_)),
  common = c(c("TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE", "TRUE")),
  stringsAsFactors = FALSE)

# ---- ds_vars 增量（dataset/variable/order/mandatory/key_seq/core/supp_flag；key_seq 参照 ADVS/ADAE 模式） ----
new_ds_vars <- data.frame(
  dataset = c(c("ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADLB", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADEG", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM", "ADCM")),
  variable = c(c("STUDYID", "USUBJID", "SUBJID", "SITEID", "COUNTRY", "ETHNIC", "AGE", "AGEU", "SEX", "RACE", "ACTARM", "TRT01P", "TRT01A", "TRTSDT", "TRTEDT", "DOMAIN", "LBSEQ", "LBTESTCD", "LBTEST", "LBCAT", "LBORRES", "LBORRESU", "LBORNRLO", "LBORNRHI", "LBSTRESC", "LBSTRESN", "LBSTRESU", "LBSTNRLO", "LBSTNRHI", "LBNRIND", "LBBLFL", "VISITNUM", "VISIT", "VISITDY", "LBDTC", "LBDY", "ASEQ", "ADT", "ADY", "AVISIT", "AVISITN", "PARAM", "PARAMCD", "PARAMN", "PARCAT1", "AVAL", "AVALC", "BASE", "BASEC", "BASETYPE", "CHG", "PCHG", "SHIFT1", "DTYPE", "BNRIND", "ANRIND", "ANRLO", "ANRHI", "ABLFL", "ANL01FL", "ONTRTFL", "TRTP", "TRTA", "STUDYID", "USUBJID", "SUBJID", "SITEID", "COUNTRY", "ETHNIC", "AGE", "AGEU", "SEX", "RACE", "ACTARM", "TRT01P", "TRT01A", "TRTSDT", "TRTEDT", "DOMAIN", "EGSEQ", "EGTESTCD", "EGTEST", "EGORRES", "EGORRESU", "EGSTRESC", "EGSTRESN", "EGSTRESU", "EGSTAT", "EGLOC", "EGBLFL", "VISITNUM", "VISIT", "VISITDY", "EGDTC", "EGDY", "EGTPT", "EGTPTNUM", "EGELTM", "EGTPTREF", "ASEQ", "ADT", "ADY", "ATPT", "ATPTN", "AVISIT", "AVISITN", "PARAM", "PARAMCD", "PARAMN", "AVAL", "AVALC", "AVALCAT1", "AVALCA1N", "BASE", "BASEC", "BASETYPE", "CHG", "CHGCAT1", "CHGCAT1N", "PCHG", "DTYPE", "ANRIND", "BNRIND", "ANRLO", "ANRHI", "ABLFL", "ANL01FL", "ONTRTFL", "TRTP", "TRTA", "STUDYID", "USUBJID", "SUBJID", "SITEID", "COUNTRY", "AGE", "SEX", "RACE", "ACTARM", "TRT01P", "TRT01A", "TRTSDT", "TRTEDT", "CMSEQ", "CMSPID", "CMTRT", "CMDECOD", "CMINDC", "CMCLAS", "CMDOSE", "CMDOSU", "CMDOSFRQ", "CMROUTE", "VISITNUM", "VISIT", "VISITDY", "CMDTC", "CMSTDTC", "CMENDTC", "CMSTDY", "CMENDY", "CMENRTPT", "ASTDT", "ASTDTF", "AENDT", "AENDTF", "ASTDY", "AENDY", "ADURN", "ADURU", "ONTRTFL", "PREFL", "FUPFL", "AOCCPFL", "ANL01FL", "APHASE", "APHASEN", "ASEQ", "TRTP", "TRTA")),
  order = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50),
  mandatory = c(c(TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE)),
  key_seq = c(1, 2, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 9, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 5, NA, 3, NA, NA, NA, NA, NA, NA, 4, NA, NA, NA, 6, NA, NA, NA, NA, NA, NA, NA, NA, NA, 1, 2, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 9, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 5, NA, 6, NA, 3, NA, NA, NA, NA, NA, NA, NA, 4, NA, NA, NA, NA, 7, NA, NA, NA, NA, NA, NA, NA, NA, NA, 1, 2, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 9, NA, NA, 3, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 4, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA),
  core = NA_character_, supp_flag = NA,
  stringsAsFactors = FALSE)

# ---- 受控术语（code_decode）：PARAMCD -> PARAM / PARAMN ----
adlb_param_txt <- data.frame(
  code = c(structure(c("ALB", "ALKPH", "ALT", "ANISO", "AST", "BASO", "BASOLE", "BILI", "BUN", "CA", "CHOLES", "CK", "CL", "COLOR", "CREAT", "EOS", "EOSLE", "GGT", "GLUC", "HBA1C", "HCT", "HGB", "POTAS", "KETON", "LYMPH", "LYMPHLE", "MACROC", "MCH", "MCHC", "MCV", "MICROC", "MONO", "MONOLE", "PH", "PHOS", "PLAT", "POIKIL", "POLYCH", "PROT", "RBC", "SODIUM", "SPGRAV", "TSH", "URATE", "UROBIL", "VITB12", "WBC"), label = "Parameter Code")),
  decode = c(structure(c("Albumin (g/L)", "Alkaline Phosphatase (U/L)", "Alanine Aminotransferase (U/L)", "Anisocytes", "Aspartate Aminotransferase (U/L)", "Basophils Abs (10^9/L)", "Basophils/Leukocytes (FRACTION)", "Bilirubin (umol/L)", "Blood Urea Nitrogen (mmol/L)", "Calcium (mmol/L)", "Cholesterol (mmol/L)", "Creatinine Kinase (U/L)", "Chloride (mmol/L)", "Color", "Creatinine (umol/L)", "Eosinophils (10^9/L)", "Eosinophils/Leukocytes (FRACTION)", "Gamma Glutamyl Transferase (U/L)", "Glucose (mmol/L)", "Hemoglobin A1C (1)", "Hematocrit (1)", "Hemoglobin (mmol/L)", "Potassium (mmol/L)", "Ketones", "Lymphocytes Abs (10^9/L)", "Lymphocytes/Leukocytes (FRACTION)", "Macrocytes", "Ery. Mean Corpuscular Hemoglobin (fmol(Fe))", "Ery. Mean Corpuscular HGB Concentration (mmol/L)", "Ery. Mean Corpuscular Volume (f/L)", "Microcytes", "Monocytes (10^9/L)", "Monocytes/Leukocytes (FRACTION)", "pH", "Phosphate (mmol/L)", "Platelet (10^9/L)", "Poikilocytes", "Polychromasia", "Protein (g/L)", "Erythrocytes (TI/L)", "Sodium (mmol/L)", "Specific Gravity", "Thyrotropin (mU/L)", "Urate (umol/L)", "Urobilinogen", "Vitamin B12 (pmol/L)", "Leukocytes (10^9/L)"), label = "Parameter")),
  stringsAsFactors = FALSE)
adlb_paramn <- data.frame(
  code = c(structure(c("ALB", "ALKPH", "ALT", "ANISO", "AST", "BASO", "BASOLE", "BILI", "BUN", "CA", "CHOLES", "CK", "CL", "COLOR", "CREAT", "EOS", "EOSLE", "GGT", "GLUC", "HBA1C", "HCT", "HGB", "POTAS", "KETON", "LYMPH", "LYMPHLE", "MACROC", "MCH", "MCHC", "MCV", "MICROC", "MONO", "MONOLE", "PH", "PHOS", "PLAT", "POIKIL", "POLYCH", "PROT", "RBC", "SODIUM", "SPGRAV", "TSH", "URATE", "UROBIL", "VITB12", "WBC"), label = "Parameter Code")),
  decode = c(c("1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47")),
  stringsAsFactors = FALSE)
adeg_param_txt <- data.frame(
  code = c(structure(c("EGINTP", "HR", "RR", "RRR", "QT", "QTCBR", "QTCFR", "QTLCR"), label = "Parameter Code")),
  decode = c(structure(c("ECG Interpretation", "Heart Rate (beats/min)", "RR Duration (ms)", "RR Duration Rederived (ms)", "QT Duration (ms)", "QTcB - Bazett's Correction Formula Rederived (ms)", "QTcF - Fridericia's Correction Formula Rederived (ms)", "QTlc - Sagie's Correction Formula Rederived (ms)"), label = "Parameter")),
  stringsAsFactors = FALSE)
adeg_paramn <- data.frame(
  code = c(structure(c("EGINTP", "HR", "RR", "RRR", "QT", "QTCBR", "QTCFR", "QTLCR"), label = "Parameter Code")),
  decode = c(c("1", "2", "3", "4", "10", "11", "12", "13")),
  stringsAsFactors = FALSE)

# ---- ds_spec 增量（数据集级） ----
new_ds_spec <- data.frame(
  dataset = c(c("ADLB", "ADEG", "ADCM")),
  structure = c(c(NA_character_, NA_character_, NA_character_)),
  label = c(c("Laboratory Analysis Dataset", "ECG Analysis Dataset", "Concomitant Medications Analysis Dataset")),
  stringsAsFactors = FALSE)

# ---- 运行时装配：读基线（只读）-> 合并增量 -> metacore() 构造 ----
load_dataset_spec <- function(dataset) {
  baseline <- spec_to_metacore(path = "./metadata/safety_specs.xlsx", where_sep_sheet = FALSE)

  ds_vars <- new_ds_vars[new_ds_vars$dataset == dataset, ]
  var_spec <- switch(dataset, ADLB = adlb_var_spec, ADEG = adeg_var_spec, ADCM = adcm_var_spec)

  codelist <- baseline$codelist
  cl_extra <- switch(dataset,
    ADLB = list(ADLB_PARAMCD = adlb_param_txt[, c("code","decode")],
                ADLB_PARAM = adlb_param_txt, ADLB_PARAMN = adlb_paramn),
    ADEG = list(ADEG_PARAMCD = adeg_param_txt[, c("code","decode")],
                ADEG_PARAM = adeg_param_txt, ADEG_PARAMN = adeg_paramn),
    ADCM = list())
  for (cid in names(cl_extra)) {
    codelist <- dplyr::bind_rows(codelist,
      tibble::tibble(code_id = cid, name = cid, type = "code_decode",
        codes = list(cl_extra[[cid]])))
  }

  ds_spec <- baseline$ds_spec
  if (!any(ds_spec$dataset %in% c("ADLB","ADEG","ADCM"))) {
    ds_spec <- dplyr::bind_rows(ds_spec, new_ds_spec)
  }

  # value_spec：每个变量的值规格（origin / code_id），create_var_from_codelist 与
  # check_ct_data 依赖它定位受控术语；PARAM 三变量关联新增参数 codelist
  code_map <- switch(dataset,
    ADLB = c("PARAMCD" = "ADLB_PARAMCD", "PARAM" = "ADLB_PARAM", "PARAMN" = "ADLB_PARAMN"),
    ADEG = c("PARAMCD" = "ADEG_PARAMCD", "PARAM" = "ADEG_PARAM", "PARAMN" = "ADEG_PARAMN"),
    ADCM = character(0))
  value_spec <- ds_vars %>%
    dplyr::transmute(
      dataset = dataset,
      variable = variable,
      origin = ifelse(variable %in% names(code_map), "derived",
                      ifelse(variable %in% c("STUDYID","USUBJID","SUBJID","SITEID"), "predecessor", "derived")),
      type = var_spec$type[match(variable, var_spec$variable)],
      code_id = unname(code_map[variable]),
      sig_dig = NA,
      derivation_id = NA_character_,
      where = TRUE
    )

  metacore(ds_vars = ds_vars, var_spec = var_spec, codelist = codelist,
    value_spec = value_spec, ds_spec = ds_spec,
    derivations = baseline$derivations) %>%
    select_dataset(dataset)
}

# ---- 辅助：数据集列序（供答案脚本 select / 校验参考） ----
dataset_var_order <- function(dataset) {
  new_ds_vars$variable[new_ds_vars$dataset == dataset]
}
