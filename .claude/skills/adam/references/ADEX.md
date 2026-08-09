# ADEX — Exposure Analysis Dataset

> 数据来源：CDISC ADaM IG v1.3（BDS 结构）+ pharmaverse `pharmaverseadam::adex` 实际结构整理

## 数据集概览

| 项目 | 内容 |
|------|------|
| 数据集名称 | ADEX |
| 描述 | Exposure Analysis Dataset（暴露分析数据集） |
| Class | BDS（Basic Data Structure） |
| Structure | One record per subject per parameter per constant-dosing interval（每受试者每参数每恒定给药区间一条记录） |
| 用途 | 支持暴露量分析：给药天数、累计/平均剂量、剂量强度、剂量调整、暴露时长等 |
| 主键 | STUDYID, USUBJID, PARAMCD, ASTDT（或 ASEQ） |
| 输入 | SDTM EX 域 + ADSL；用 `admiral` 暴露衍生流程（`derive_param_exposure()` 等）生成 |
| 备注 | EX 原始记录派生为“恒定给药区间”，再按参数（DURD/DOSE/TDOSE 等）纵向展开为 BDS |

---

## 变量列表（共 92 个变量，取自 `pharmaverseadam::adex`）

说明：前段 STUDYID–DTHCGR1 为从 ADSL 合并的受试者级变量（简写为“合并自 ADSL”）；中段 EX* 为 SDTM EX 域 Predecessor；末段为 BDS 暴露分析变量。

| Variable | Label | Type | Origin | 说明 |
|----------|-------|------|--------|------|
| STUDYID | Study Identifier | char | Predecessor | ADSL.STUDYID |
| USUBJID | Unique Subject Identifier | char | Predecessor | ADSL.USUBJID |
| SUBJID | Subject Identifier for the Study | char | Predecessor | 合并自 ADSL |
| SITEID | Study Site Identifier | char | Predecessor | 合并自 ADSL |
| COUNTRY | Country | char | Predecessor | 合并自 ADSL |
| DOMAIN | Domain Abbreviation | char | Predecessor | EX.DOMAIN |
| RFSTDTC | Subject Reference Start Date/Time | char | Predecessor | 合并自 ADSL |
| RFENDTC | Subject Reference End Date/Time | char | Predecessor | 合并自 ADSL |
| RFXSTDTC | Date/Time of First Study Treatment | char | Predecessor | 合并自 ADSL |
| RFXENDTC | Date/Time of Last Study Treatment | char | Predecessor | 合并自 ADSL |
| RFPENDTC | Date/Time of End of Participation | char | Predecessor | 合并自 ADSL |
| SCRFDT | Screen Failure Date | num (Date) | Derived | 合并自 ADSL |
| FRVDT | Final Retrieval Visit Date | num (Date) | Derived | 合并自 ADSL |
| DTHDTC | Date/Time of Death | char | Predecessor | 合并自 ADSL |
| DTHADY | Relative Day of Death | num | Derived | 合并自 ADSL |
| DTHFL | Subject Death Flag | char | Predecessor | 合并自 ADSL |
| LDDTHELD | Elapsed Days from Last Dose to Death | num | Derived | 合并自 ADSL |
| LDDTHGR1 | Last Dose to Death - Days Elapsed Grp 1 | char | Derived | 合并自 ADSL |
| DTH30FL | Death Within 30 Days of Last Trt Flag | char | Derived | 合并自 ADSL |
| DTHA30FL | Death After 30 Days from Last Trt Flag | char | Derived | 合并自 ADSL |
| DTHDOM | Domain for Date of Death Collection | char | Derived | 合并自 ADSL |
| DTHB30FL | Death Within 30 Days of First Trt Flag | char | Derived | 合并自 ADSL |
| ASEQ | Analysis Sequence Number | num | Derived | 同一受试者内分析记录唯一序号 |
| REGION1 | Geographic Region 1 | char | Derived | 合并自 ADSL |
| DMDTC | Date/Time of Collection | char | Predecessor | 合并自 ADSL |
| DMDY | Study Day of Collection | num | Derived | 合并自 ADSL |
| AGE | Age | num | Predecessor | 合并自 ADSL |
| AGEU | Age Units | char | Predecessor | 合并自 ADSL |
| AGEGR1 | Pooled Age Group 1 | char | Derived | 合并自 ADSL |
| SEX | Sex | char | Predecessor | 合并自 ADSL |
| RACE | Race | char | Predecessor | 合并自 ADSL |
| RACEGR1 | Pooled Race Group 1 | char | Derived | 合并自 ADSL |
| ETHNIC | Ethnicity | char | Predecessor | 合并自 ADSL |
| SAFFL | Safety Population Flag | char | Derived | 合并自 ADSL |
| ARM | Description of Planned Arm | char | Predecessor | 合并自 ADSL |
| ARMCD | Planned Arm Code | char | Predecessor | 合并自 ADSL |
| ACTARM | Description of Actual Arm | char | Predecessor | 合并自 ADSL |
| ACTARMCD | Actual Arm Code | char | Predecessor | 合并自 ADSL |
| TRT01P | Planned Treatment for Period 01 | char | Derived | 合并自 ADSL |
| TRT01A | Actual Treatment for Period 01 | char | Derived | 合并自 ADSL |
| TRTSDT | Date of First Exposure to Treatment | num (Date) | Derived | 合并自 ADSL |
| TRTSDTM | Datetime of First Exposure to Treatment | num (dtm) | Derived | 合并自 ADSL |
| TRTSTMF | Time of First Exposure Imput. Flag | char | Derived | 合并自 ADSL |
| TRTEDT | Date of Last Exposure to Treatment | num (Date) | Derived | 合并自 ADSL |
| TRTEDTM | Datetime of Last Exposure to Treatment | num (dtm) | Derived | 合并自 ADSL |
| TRTETMF | Time of Last Exposure Imput. Flag | char | Derived | 合并自 ADSL |
| EOSSTT | End of Study Status | char | Derived | 合并自 ADSL |
| EOSDT | End of Study Date | num (Date) | Derived | 合并自 ADSL |
| RFICDTC | Date/Time of Informed Consent | char | Predecessor | 合并自 ADSL |
| RANDDT | Date of Randomization | num (Date) | Derived | 合并自 ADSL |
| LSTALVDT | Date Last Known Alive | num (Date) | Derived | 合并自 ADSL |
| TRTDURD | Total Treatment Duration (Days) | num | Derived | 合并自 ADSL |
| DTHDT | Date of Death | num (Date) | Derived | 合并自 ADSL |
| DTHDTF | Date of Death Imputation Flag | char | Derived | 合并自 ADSL |
| DTHCAUS | Cause of Death | char | Derived | 合并自 ADSL |
| DTHCGR1 | Cause of Death Reason 1 | char | Derived | 合并自 ADSL |
| EXTRT | Name of Treatment | char | Predecessor | EX.EXTRT |
| EXDOSE | Dose | num | Predecessor | EX.EXDOSE（单次给药剂量） |
| EXDOSFRM | Dose Form | char | Predecessor | EX.EXDOSFRM |
| EXDOSFRQ | Dosing Frequency per Interval | char | Predecessor | EX.EXDOSFRQ |
| EXROUTE | Route of Administration | char | Predecessor | EX.EXROUTE |
| EXADJ | Reason for Dose Adjustment | char | Predecessor | EX.EXADJ |
| EXSTDTC | Start Date/Time of Treatment | char | Predecessor | EX.EXSTDTC |
| EXENDTC | End Date/Time of Treatment | char | Predecessor | EX.EXENDTC |
| EXSTDY | Study Day of Start of Treatment | num | Predecessor | EX.EXSTDY |
| EXENDY | Study Day of End of Treatment | num | Predecessor | EX.EXENDY |
| EXSEQ | Sequence Number | num | Predecessor | EX.EXSEQ |
| ASTDT | Analysis Start Date | num (Date) | Derived | `derive_vars_dt()` 解析 EXSTDTC，给药区间开始日 |
| AENDT | Analysis End Date | num (Date) | Derived | `derive_vars_dt()` 解析 EXENDTC，给药区间结束日 |
| EXDURD | Duration of Treatment (Days) | num | Derived | AENDT - ASTDT + 1，本区间给药天数 |
| EXDOSU | Dose Units | char | Derived | 剂量单位，取自 EX.EXDOSU |
| VISITNUM | Visit Number | num | Predecessor | EX.VISITNUM |
| VISIT | Visit Name | char | Predecessor | EX.VISIT |
| VISITDY | Planned Study Day of Visit | num | Predecessor | EX.VISITDY |
| EXPLDOS | Planned Dose | num | Derived | 计划剂量，按方案/SCHEDULED 记录派生 |
| ASTDTM | Analysis Start Datetime | num (dtm) | Derived | `derive_vars_dtm()`，含时间部分 |
| ASTDTF | Analysis Start Date Imputation Flag | char | Derived | 开始日期插补标志（D/M/Y） |
| ASTTMF | Analysis Start Time Imputation Flag | char | Derived | 开始时间插补标志 |
| AENDTM | Analysis End Datetime | num (dtm) | Derived | 结束日期时间 |
| AENDTF | Analysis End Date Imputation Flag | char | Derived | 结束日期插补标志 |
| AENTMF | Analysis End Time Imputation Flag | char | Derived | 结束时间插补标志 |
| ASTDY | Analysis Start Relative Day | num | Derived | ASTDT 相对 TRTSDT 的研究日 |
| AENDY | Analysis End Relative Day | num | Derived | AENDT 相对 TRTSDT 的研究日 |
| DOSEO | Dose O | num | Derived | 原始/中间剂量派生量（暴露计算辅助） |
| PDOSEO | PDose O | num | Derived | 原始/中间计划剂量派生量 |
| PARAMCD | Parameter Code | char | Derived | 暴露参数短码：DURD（给药天数）、DOSE（区间剂量）、PLDOSE（计划剂量）、TDOSE（累计剂量）、TDURD（总给药天数）、AVDDSE（平均日剂量）、ADJ/ADJAE（剂量调整）等 |
| AVAL | Analysis Value | num | Derived | 参数分析值，`derive_param_exposure()` 汇总（如 sum(EXDOSE)、sum(EXDURD)） |
| AVALC | Analysis Value (C) | char | Derived | AVAL 的字符表示 |
| PARCAT1 | Parameter Category 1 | char | Derived | 参数分类（如 "OVERALL" / "PROTOCOL SPECIFIED"） |
| PARAM | Parameter | char | Derived | 参数全称，如 "Dose administered during constant dosing interval (mg)" |
| PARAMN | Parameter (N) | num | Derived | PARAM 的数值编码，供排序 |
| AVALCAT1 | Analysis Value Category 1 | char | Derived | AVAL 分组类别（如剂量强度区间） |

---

## Dummy 数据示例（R，取自 `pharmaverseadam::adex` 真实样本）

```r
library(tibble)

adex <- tibble(
  STUDYID  = "CDISCPILOT01",
  USUBJID  = "01-701-1015",
  EXTRT    = "PLACEBO",
  EXDOSE   = 0,
  PARAMCD  = c("DURD", "DOSE", "PLDOSE"),
  PARAM    = c("Study drug duration during constant dosing interval (days)",
               "Dose administered during constant dosing interval (mg)",
               "Planned dose during constant dosing interval (mg)"),
  ASTDT    = as.Date("2014-01-02"),
  AENDT    = as.Date("2014-01-16"),
  EXDURD   = 15,
  AVAL     = c(15, 0, 0)
)
```
