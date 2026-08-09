# ADAE — Adverse Events Analysis Dataset

> 数据来源：CDISC ADaM IG v1.3（OCCDS 结构）+ pharmaverse `pharmaverseadam::adae` 实际结构整理

## 数据集概览

| 项目 | 内容 |
|------|------|
| 数据集名称 | ADAE |
| 描述 | Adverse Events Analysis Dataset |
| Class | OCCDS（Occurrence Data Structure） |
| Structure | One record per subject per adverse event（通常一条 AE 一条记录） |
| 用途 | 支持不良事件（AE）汇总分析，包括发生率、严重程度、因果关系、严重/致死事件、治疗期出现（TEAE）等 |
| 主键 | STUDYID, USUBJID, AESEQ |
| 备注 | 基于 SDTM AE 域衍生，并合并 ADSL 的受试者级别变量。前 56 个变量来自 ADSL（用 `derive_vars_merged()` 合并），其余为 AE 域派生变量。admiral 官方 vignette（`vignette("adae")`）演示了 TEAE 标志、发生率标志等标准派生。 |

---

## 变量列表（共 107 个变量，取自 `pharmaverseadam::adae`）

> 注：前 56 个变量（STUDYID … DTHCGR1）来自 ADSL 合并，与 ADSL 参考文档一致，此处 Origin 记为 `ADSL`，不再逐一展开派生逻辑。以下重点说明 AE 域特有变量。

### ADSL 合并变量（受试者级别）

| Variable | Label | Type | Origin | 说明 |
|----------|-------|------|--------|------|
| STUDYID | Study Identifier | char | ADSL | 研究标识 |
| USUBJID | Unique Subject Identifier | char | ADSL | 受试者唯一标识 |
| SUBJID | Subject Identifier for the Study | char | ADSL | |
| SITEID | Study Site Identifier | char | ADSL | |
| COUNTRY | Country | char | ADSL | |
| DOMAIN | Domain Abbreviation | char | Predecessor | AE.DOMAIN |
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
| SAFFL | Safety Population Flag | char | ADSL | 安全性人群标志，AE 分析主要人群 |
| ARM | Description of Planned Arm | char | ADSL | |
| ARMCD | Planned Arm Code | char | ADSL | |
| ACTARM | Description of Actual Arm | char | ADSL | |
| ACTARMCD | Actual Arm Code | char | ADSL | |
| TRT01P | Planned Treatment for Period 01 | char | ADSL | 计划治疗，分析分组常用 |
| TRT01A | Actual Treatment for Period 01 | char | ADSL | 实际治疗，安全性分析分组常用 |
| TRTSDT | Date of First Exposure to Treatment | num (Date) | ADSL | 首次给药日期，TEAE 判定基准 |
| TRTSDTM | Datetime of First Exposure to Treatment | num (datetime) | ADSL | |
| TRTSTMF | Time of First Exposure Imput. Flag | char | ADSL | |
| TRTEDT | Date of Last Exposure to Treatment | num (Date) | ADSL | 末次给药日期 |
| TRTEDTM | Datetime of Last Exposure to Treatment | num (datetime) | ADSL | |
| TRTETMF | Time of Last Exposure Imput. Flag | char | ADSL | |
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

### AE 域特有变量

| Variable | Label | Type | Origin | 说明 |
|----------|-------|------|--------|------|
| AESEQ | Sequence Number | num | Predecessor | AE.AESEQ，主键之一 |
| AETERM | Reported Term for the Adverse Event | char | Predecessor | AE.AETERM，原始报告术语 |
| AEDECOD | Dictionary-Derived Term | char | Predecessor | AE.AEDECOD，MedDRA PT（首选术语） |
| AEBODSYS | Body System or Organ Class | char | Predecessor | AE.AEBODSYS，SOC 系统器官分类 |
| AEBDSYCD | Body System or Organ Class Code | num | Predecessor | MedDRA SOC 编码 |
| AELLT | Lowest Level Term | char | Predecessor | MedDRA 最低级别术语 |
| AELLTCD | Lowest Level Term Code | num | Predecessor | LLT 编码 |
| AEPTCD | Preferred Term Code | num | Predecessor | PT 编码 |
| AEHLT | High Level Term | char | Predecessor | 高级别术语 |
| AEHLTCD | High Level Term Code | num | Predecessor | HLT 编码 |
| AEHLGT | High Level Group Term | char | Predecessor | 高级别组术语 |
| AEHLGTCD | High Level Group Term Code | num | Predecessor | HLGT 编码 |
| AESOC | Primary System Organ Class | char | Predecessor | 主要系统器官分类 |
| AESOCCD | Primary System Organ Class Code | num | Predecessor | 主要 SOC 编码 |
| AESTDTC | Start Date/Time of Adverse Event | char | Predecessor | AE.AESTDTC，AE 开始日期（ISO 8601 字符） |
| ASTDT | Analysis Start Date | num (Date) | Derived | `derive_vars_dt()` 解析 AESTDTC，含部分日期插补 |
| ASTDTM | Analysis Start Date/Time | num (datetime) | Derived | 含时间部分 |
| ASTDTF | Analysis Start Date Imputation Flag | char | Derived | ASTDT 日期插补标志（D/M/Y） |
| ASTTMF | Analysis Start Time Imputation Flag | char | Derived | 时间插补标志 |
| AEENDTC | End Date/Time of Adverse Event | char | Predecessor | AE.AEENDTC，AE 结束日期（字符） |
| AENDT | Analysis End Date | num (Date) | Derived | `derive_vars_dt()` 解析 AEENDTC |
| AENDTM | Analysis End Date/Time | num (datetime) | Derived | |
| AENDTF | Analysis End Date Imputation Flag | char | Derived | |
| AENTMF | Analysis End Time Imputation Flag | char | Derived | |
| ASTDY | Analysis Start Relative Day | num | Derived | `derive_vars_dy()`：ASTDT 相对 TRTSDT 的研究日 |
| AESTDY | Study Day of Start of Adverse Event | num | Predecessor | AE.AESTDY |
| AENDY | Analysis End Relative Day | num | Derived | AENDT 相对 TRTSDT 的研究日 |
| AEENDY | Study Day of End of Adverse Event | num | Predecessor | AE.AEENDY |
| ADURN | Analysis Duration (N) | num | Derived | AENDT - ASTDT + 1，AE 持续天数 |
| ADURU | Analysis Duration Units | char | Derived | 持续时间单位（DAYS） |
| TRTEMFL | Treatment Emergent Analysis Flag | char | Derived | `derive_var_trtemfl()`：ASTDT ≥ TRTSDT 且在治疗窗内则 "Y"，标记治疗期出现不良事件（TEAE） |
| AOCCIFL | 1st Max Sev./Int. Occurrence Flag | char | Derived | `derive_var_extreme_flag()`：受试者内按最大严重程度取首次发生记录标记 "Y" |
| AESER | Serious Event | char | Predecessor | AE.AESER，是否严重事件（Y/N） |
| AESDTH | Results in Death | char | Predecessor | 是否致死 |
| AESLIFE | Is Life Threatening | char | Predecessor | 是否危及生命 |
| AESHOSP | Requires or Prolongs Hospitalization | char | Predecessor | 是否导致或延长住院 |
| AESDISAB | Persist or Signif Disability/Incapacity | char | Predecessor | 是否导致残疾 |
| AESCONG | Congenital Anomaly or Birth Defect | char | Predecessor | 是否先天异常/出生缺陷 |
| AESEV | Severity/Intensity | char | Predecessor | AE.AESEV，严重程度（MILD/MODERATE/SEVERE） |
| ASEV | Analysis Severity/Intensity | char | Derived | 分析用严重程度，通常等于 AESEV |
| ASEVN | Analysis Severity/Intensity (N) | num | Derived | ASEV 的数值编码（1/2/3），用于排序取极值 |
| AEREL | Causality | char | Predecessor | AE.AEREL，与研究药物的因果关系 |
| AREL | Analysis Causality | char | Derived | 分析用因果关系，通常映射为相关/不相关 |
| AEACN | Action Taken with Study Treatment | char | Predecessor | 针对研究药物采取的措施 |
| AESPID | Sponsor-Defined Identifier | char | Predecessor | AE.AESPID |
| AEOUT | Outcome of Adverse Event | char | Predecessor | AE 转归 |
| AESCAN | Involves Cancer | char | Predecessor | 是否涉及癌症 |
| AESOD | Occurred with Overdose | char | Predecessor | 是否伴随过量用药 |
| AEDTC | Date/Time of Collection | char | Predecessor | AE.AEDTC |
| LDOSEDTM | End Date/Time of Last Dose | num (datetime) | Derived | 该 AE 之前末次给药日期时间，用于计算距末次给药天数 |
| DOSEON | Treatment Dose | num | Derived | AE 发生时的剂量 |
| DOSEU | Treatment Dose Unit | char | Derived | 剂量单位 |

---

## Dummy 数据示例（R，取自 pharmaverseadam::adae 真实样本）

```r
library(tibble)

adae <- tibble(
  STUDYID  = "CDISCPILOT01",
  USUBJID  = c("01-701-1015", "01-701-1015", "01-701-1015", "01-701-1023"),
  AESEQ    = c(1, 2, 3, 1),
  AEDECOD  = c("APPLICATION SITE ERYTHEMA", "APPLICATION SITE PRURITUS",
               "DIARRHOEA", "ERYTHEMA"),
  AEBODSYS = c("GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS",
               "GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS",
               "GASTROINTESTINAL DISORDERS",
               "SKIN AND SUBCUTANEOUS TISSUE DISORDERS"),
  AESEV    = c("MILD", "MILD", "MILD", "MODERATE"),
  ASEV     = c("MILD", "MILD", "MILD", "MODERATE"),
  AEREL    = c("PROBABLE", "PROBABLE", "REMOTE", "PROBABLE"),
  AESER    = c("N", "N", "N", "N"),
  TRTEMFL  = c("Y", "Y", "Y", "Y"),
  ASTDT    = as.Date(c("2014-01-03", "2014-01-03", "2014-01-09", "2012-08-07")),
  AENDT    = as.Date(c(NA, NA, "2014-01-11", NA)),
  TRT01A   = c("Placebo", "Placebo", "Placebo", "Placebo")
)
```
