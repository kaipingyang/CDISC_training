# ADCM — Concomitant Medications Analysis Dataset

> 数据来源：CDISC ADaM IG v1.3（OCCDS 结构）+ pharmaverse `pharmaverseadam::adcm` 实际结构整理

## 数据集概览

| 项目 | 内容 |
|------|------|
| 数据集名称 | ADCM |
| 描述 | Concomitant Medications Analysis Dataset |
| Class | OCCDS（Occurrence Data Structure） |
| Structure | One record per subject per medication record（每条伴随用药一条记录） |
| 用途 | 支持伴随用药汇总分析，包括用药频次、药物分类、治疗期/前期/随访期用药、首次出现标志等 |
| 主键 | STUDYID, USUBJID, CMSEQ |
| 备注 | 基于 SDTM CM 域衍生，并合并 ADSL 的受试者级别变量。前 60 个变量来自 ADSL，其余为 CM 域派生变量。admiral 官方 vignette（`vignette("adcm")`）演示了用药期间标志、首次出现标志等标准派生。 |

---

## 变量列表（共 95 个变量，取自 `pharmaverseadam::adcm`）

> 注：前 60 个变量（STUDYID … DTHCGR1）来自 ADSL 合并，Origin 记为 `ADSL`。以下重点说明 CM 域特有变量。

### ADSL 合并变量（受试者级别）

| Variable | Label | Type | Origin | 说明 |
|----------|-------|------|--------|------|
| STUDYID | Study Identifier | char | ADSL | |
| USUBJID | Unique Subject Identifier | char | ADSL | |
| SUBJID | Subject Identifier for the Study | char | ADSL | |
| SITEID | Study Site Identifier | char | ADSL | |
| COUNTRY | Country | char | ADSL | |
| DOMAIN | Domain Abbreviation | char | Predecessor | CM.DOMAIN |
| RFSTDTC | Subject Reference Start Date/Time | char | ADSL | |
| RFENDTC | Subject Reference End Date/Time | char | ADSL | |
| RFXSTDTC | Date/Time of First Study Treatment | char | ADSL | |
| RFXENDTC | Date/Time of Last Study Treatment | char | ADSL | |
| RFPENDTC | Date/Time of End of Participation | char | ADSL | |
| SCRFDT | Screen Failure Date | num (Date) | ADSL | |
| FRVDT | Final Retrieval Visit Date | num (Date) | ADSL | |
| DTHDTC | Date/Time of Death | char | ADSL | |
| DTHADY | Relative Day of Death | num | ADSL | |
| DTHFL | Subject Death Flag | char | ADSL | |
| LDDTHELD | Elapsed Days from Last Dose to Death | num | ADSL | |
| LDDTHGR1 | Last Dose to Death - Days Elapsed Grp 1 | char | ADSL | |
| DTH30FL | Death Within 30 Days of Last Trt Flag | char | ADSL | |
| DTHA30FL | Death After 30 Days from Last Trt Flag | char | ADSL | |
| DTHDOM | Domain for Date of Death Collection | char | ADSL | |
| DTHB30FL | Death Within 30 Days of First Trt Flag | char | ADSL | |
| REGION1 | Geographic Region 1 | char | ADSL | |
| DMDTC | Date/Time of Collection | char | ADSL | |
| DMDY | Study Day of Collection | num | ADSL | |
| AGE | Age | num | ADSL | |
| AGEU | Age Units | char | ADSL | |
| AGEGR1 | Pooled Age Group 1 | char | ADSL | |
| SEX | Sex | char | ADSL | |
| RACE | Race | char | ADSL | |
| RACEGR1 | Pooled Race Group 1 | char | ADSL | |
| ETHNIC | Ethnicity | char | ADSL | |
| SAFFL | Safety Population Flag | char | ADSL | 安全性人群标志 |
| ARM | Description of Planned Arm | char | ADSL | |
| ARMCD | Planned Arm Code | char | ADSL | |
| ACTARM | Description of Actual Arm | char | ADSL | |
| ACTARMCD | Actual Arm Code | char | ADSL | |
| TRTP | Planned Treatment | char | Derived | 计划治疗，通常等于 TRT01P |
| TRTA | Actual Treatment | char | Derived | 实际治疗，通常等于 TRT01A，分析分组常用 |
| TRT01P | Planned Treatment for Period 01 | char | ADSL | |
| TRT01A | Actual Treatment for Period 01 | char | ADSL | |
| TRTSDT | Date of First Exposure to Treatment | num (Date) | ADSL | 首次给药日期，用药期间判定基准 |
| TRTSDTM | Datetime of First Exposure to Treatment | num (datetime) | ADSL | |
| TRTSTMF | Time of First Exposure Imput. Flag | char | ADSL | |
| TRTEDT | Date of Last Exposure to Treatment | num (Date) | ADSL | 末次给药日期 |
| TRTEDTM | Datetime of Last Exposure to Treatment | num (datetime) | ADSL | |
| TRTETMF | Treatment End Datetime Imput Flag | char | ADSL | |
| APHASE | Phase | char | Derived | 分析阶段（如 Screening/On Treatment/Follow-up），基于用药日期相对治疗窗划分 |
| APHASEN | Description of Phase N | num | Derived | APHASE 的数值编码 |
| EOSSTT | End of Study Status | char | ADSL | |
| EOSDT | End of Study Date | num (Date) | ADSL | |
| RFICDTC | Date/Time of Informed Consent | char | ADSL | |
| RANDDT | Date of Randomization | num (Date) | ADSL | |
| LSTALVDT | Date Last Known Alive | num (Date) | ADSL | |
| TRTDURD | Total Treatment Duration (Days) | num | ADSL | |
| DTHDT | Date of Death | num (Date) | ADSL | |
| DTHDTF | Date of Death Imputation Flag | char | ADSL | |
| DTHCAUS | Cause of Death | char | ADSL | |
| DTHCGR1 | Cause of Death Reason 1 | char | ADSL | |

### CM 域特有变量

| Variable | Label | Type | Origin | 说明 |
|----------|-------|------|--------|------|
| CMSEQ | Sequence Number | num | Predecessor | CM.CMSEQ，主键之一 |
| CMDECOD | Standardized Medication Name | char | Predecessor | CM.CMDECOD，WHO Drug 标准化药物名 |
| CMTRT | Reported Name of Drug, Med, or Therapy | char | Predecessor | CM.CMTRT，原始报告药物名 |
| CMCLAS | Medication Class | char | Predecessor | 药物分类（如 ATC 分类） |
| CMSTDTC | Start Date/Time of Medication | char | Predecessor | CM.CMSTDTC，用药开始日期（字符） |
| ASTDT | Analysis Start Date | num (Date) | Derived | `derive_vars_dt()` 解析 CMSTDTC，含部分日期插补 |
| ASTDTM | Analysis Start Date/Time | num (datetime) | Derived | 含时间部分 |
| ASTDTF | Analysis Start Date Imputation Flag | char | Derived | 日期插补标志（D/M/Y） |
| ASTTMF | Analysis Start Time Imputation Flag | char | Derived | 时间插补标志 |
| CMENDTC | End Date/Time of Medication | char | Predecessor | CM.CMENDTC，用药结束日期（字符） |
| AENDT | Analysis End Date | num (Date) | Derived | `derive_vars_dt()` 解析 CMENDTC |
| AENDTM | Analysis End Date/Time | num (datetime) | Derived | |
| AENDTF | Analysis End Date Imputation Flag | char | Derived | |
| AENTMF | Analysis End Time Imputation Flag | char | Derived | |
| ASTDY | Analysis Start Relative Day | num | Derived | `derive_vars_dy()`：ASTDT 相对 TRTSDT 的研究日 |
| CMSTDY | Study Day of Start of Medication | num | Predecessor | CM.CMSTDY |
| AENDY | Analysis End Relative Day | num | Derived | AENDT 相对 TRTSDT 的研究日 |
| CMENDY | Study Day of End of Medication | num | Predecessor | CM.CMENDY |
| ADURN | Analysis Duration (N) | num | Derived | AENDT - ASTDT + 1，用药持续天数 |
| ADURU | Analysis Duration Units | char | Derived | 持续时间单位（DAYS） |
| ANL01FL | Analysis Flag 01 | char | Derived | `derive_var_extreme_flag()` 等：标记纳入主要分析的记录（如去重后每受试者每药物首条），"Y" |
| ONTRTFL | On Treatment Record Flag | char | Derived | `derive_var_ontrtfl()`：用药期与治疗窗重叠则 "Y"（治疗期用药） |
| PREFL | Pre-treatment Flag | char | Derived | 用药开始早于 TRTSDT 则 "Y"（治疗前用药） |
| FUPFL | Follow-up Flag | char | Derived | 用药开始晚于 TRTEDT 则 "Y"（随访期用药） |
| AOCCPFL | 1st Occurrence of Preferred Term Flag | char | Derived | `derive_var_extreme_flag()`：受试者内某药物名首次出现记录标记 "Y" |
| CMINDC | Indication | char | Predecessor | CM.CMINDC，用药指征 |
| CMDOSE | Dose per Administration | num | Predecessor | 每次给药剂量 |
| CMDOSU | Dose Units | char | Predecessor | 剂量单位 |
| CMDOSFRQ | Dosing Frequency per Interval | char | Predecessor | 给药频次 |
| CMROUTE | Route of Administration | char | Predecessor | 给药途径 |
| CMSPID | Sponsor-Defined Identifier | char | Predecessor | CM.CMSPID |
| CMENRTPT | End Relative to Reference Time Point | char | Predecessor | 结束相对参考时间点（如 ONGOING） |
| VISITNUM | Visit Number | num | Predecessor | CM.VISITNUM |
| VISIT | Visit Name | char | Predecessor | CM.VISIT |
| VISITDY | Planned Study Day of Visit | num | Predecessor | CM.VISITDY |
| CMDTC | Date/Time of Collection | char | Predecessor | CM.CMDTC |

---

## Dummy 数据示例（R，取自 pharmaverseadam::adcm 真实样本）

```r
library(tibble)

adcm <- tibble(
  STUDYID  = "CDISCPILOT01",
  USUBJID  = "01-701-1015",
  CMSEQ    = c(1, 2, 3, 4),
  CMDECOD  = "HYDROCORTISONE",
  CMCLAS   = "SYSTEMIC HORMONAL PREPARATIONS, EXCL.",
  CMINDC   = NA_character_,
  ASTDT    = as.Date("2014-03-27"),
  AENDT    = as.Date(NA),
  ANL01FL  = c("Y", "Y", "Y", "Y"),
  AOCCPFL  = c("Y", NA, NA, NA),
  TRTA     = "Placebo"
)
```
