# ADEG — ECG Analysis Dataset

> 数据来源：CDISC ADaM IG v1.3（BDS 结构）+ pharmaverse `pharmaverseadam::adeg` 实际结构整理

## 数据集概览

| 项目 | 内容 |
|------|------|
| 数据集名称 | ADEG |
| 描述 | ECG (Electrocardiogram) Analysis Dataset |
| Class | BDS（Basic Data Structure） |
| Structure | One record per subject per parameter per analysis visit (per timepoint)（每受试者每参数每分析访视一条记录） |
| 用途 | 支持心电图分析，包括 QT/QTc（QTcB/QTcF）等参数的基线、变化量、变化分类、参考范围指示、分析访视窗口等 |
| 主键 | STUDYID, USUBJID, PARAMCD, AVISIT（+ ATPT / ADT，视设计而定） |
| 备注 | 基于 SDTM EG 域衍生，并合并 ADSL 的受试者级别变量。前 57 个变量来自 ADSL，其余为 BDS 分析变量与 EG 域来源变量。QTc 参数（QTCBR/QTCFR）通常由 QT 与 RR 派生。 |

---

## 变量列表（共 108 个变量，取自 `pharmaverseadam::adeg`）

> 注：前 57 个变量（STUDYID … DTHCGR1）来自 ADSL 合并，Origin 记为 `ADSL`。以下重点说明 BDS 核心分析变量与 EG 域来源变量。

### ADSL 合并变量（受试者级别）

| Variable | Label | Type | Origin | 说明 |
|----------|-------|------|--------|------|
| STUDYID | Study Identifier | char | ADSL | |
| USUBJID | Unique Subject Identifier | char | ADSL | |
| SUBJID | Subject Identifier for the Study | char | ADSL | |
| SITEID | Study Site Identifier | char | ADSL | |
| COUNTRY | Country | char | ADSL | |
| DOMAIN | Domain Abbreviation | char | Predecessor | EG.DOMAIN |
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
| ASEQ | Analysis Sequence Number | num | Derived | 分析序号，保证记录唯一 |
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
| SAFFL | Safety Population Flag | char | ADSL | |
| ARM | Description of Planned Arm | char | ADSL | |
| ARMCD | Planned Arm Code | char | ADSL | |
| ACTARM | Description of Actual Arm | char | ADSL | |
| ACTARMCD | Actual Arm Code | char | ADSL | |
| TRTP | Planned Treatment | char | Derived | 计划治疗，通常等于 TRT01P |
| TRTA | Actual Treatment | char | Derived | 实际治疗，通常等于 TRT01A |
| TRT01P | Planned Treatment for Period 01 | char | ADSL | |
| TRT01A | Actual Treatment for Period 01 | char | ADSL | |
| TRTSDT | Date of First Exposure to Treatment | num (Date) | ADSL | 基线判定与研究日基准 |
| TRTSDTM | Datetime of First Exposure to Treatment | num (datetime) | ADSL | |
| TRTSTMF | Time of First Exposure Imput. Flag | char | ADSL | |
| TRTEDT | Date of Last Exposure to Treatment | num (Date) | ADSL | |
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

### BDS 核心分析变量

| Variable | Label | Type | Origin | 说明 |
|----------|-------|------|--------|------|
| ADT | Analysis Date | num (Date) | Derived | `derive_vars_dt()` 解析 EGDTC 得到的分析日期 |
| ADTM | Analysis Datetime | num (datetime) | Derived | 含时间部分的分析日期时间 |
| ADY | Analysis Relative Day | num | Derived | `derive_vars_dy()`：ADT 相对 TRTSDT 的研究日 |
| ATMF | Analysis Time Imputation Flag | char | Derived | ADTM 时间插补标志 |
| AVISIT | Analysis Visit | char | Derived | 分析访视，按访视窗口映射标准化标签（如 Baseline/Week 2） |
| AVISITN | Analysis Visit (N) | num | Derived | AVISIT 数值排序编码 |
| ATPT | Analysis Timepoint | char | Derived | 分析时间点，来自 EGTPT |
| ATPTN | Analysis Timepoint (N) | num | Derived | ATPT 数值编码 |
| PARAM | Parameter | char | Assigned | 参数完整描述（含单位），如 "QT Duration (ms)" |
| PARAMCD | Parameter Code | char | Assigned | 参数短代码（如 QT/RR/HR/QTCBR/QTCFR），BDS 核心分类键，通常映射自 EGTESTCD 或派生 |
| PARAMN | Parameter (N) | num | Assigned | PARAMCD 数值排序编码 |
| AVAL | Analysis Value | num | Derived | 分析数值，通常取 EGSTRESN；QTc 等派生参数按公式计算 |
| AVALC | Analysis Value (C) | char | Derived | 字符型分析值，用于分类型参数（如 EGINTP 心电图判读） |
| AVALCAT1 | Analysis Value Category 1 | char | Derived | AVAL 分类（如 QTc 阈值分组 ≤450/450-480/>480 ms） |
| AVALCA1N | Analysis Value Category 1 (N) | num | Derived | AVALCAT1 数值编码 |
| BASE | Baseline Value | num | Derived | `derive_var_base()`：取基线记录（ABLFL="Y"）的 AVAL |
| BASEC | Baseline Value (C) | char | Derived | 字符型基线值，对应 AVALC |
| BASETYPE | Baseline Type | char | Derived | 基线类型，多基线设计时区分 |
| CHG | Change from Baseline | num | Derived | `derive_var_chg()`：AVAL - BASE |
| CHGCAT1 | Change from Baseline Category 1 | char | Derived | CHG 分类（如 QTc 变化阈值 ≤30/30-60/>60 ms） |
| CHGCAT1N | Change from Baseline Category 1 (N) | num | Derived | CHGCAT1 数值编码 |
| PCHG | Percent Change from Baseline | num | Derived | `derive_var_pchg()`：(AVAL - BASE) / BASE * 100 |
| DTYPE | Derivation Type | char | Derived | 派生类型（如 AVERAGE/LOCF），原始观测为空 |
| ANRIND | Analysis Reference Range Indicator | char | Derived | AVAL 相对 ANRLO/ANRHI 的范围指示（LOW/NORMAL/HIGH） |
| BNRIND | Baseline Reference Range Indicator | char | Derived | 基线记录的 ANRIND |
| ANRLO | Analysis Normal Range Lower Limit | num | Predecessor | 正常范围下限 |
| ANRHI | Analysis Normal Range Upper Limit | num | Predecessor | 正常范围上限 |
| ABLFL | Baseline Record Flag | char | Derived | 标记每受试者每参数的基线记录（通常给药前末次），"Y" |
| ANL01FL | Analysis Flag 01 | char | Derived | 标记纳入主要分析的记录（如每访视窗口取一条），"Y" |
| ONTRTFL | On Treatment Record Flag | char | Derived | 测量日期落在治疗窗内则 "Y" |

### EG 域来源变量

| Variable | Label | Type | Origin | 说明 |
|----------|-------|------|--------|------|
| EGSEQ | Sequence Number | num | Predecessor | EG.EGSEQ |
| EGTESTCD | ECG Test or Examination Short Name | char | Predecessor | EG.EGTESTCD，映射 PARAMCD 的来源 |
| EGTEST | ECG Test or Examination Name | char | Predecessor | EG.EGTEST |
| EGORRES | Result or Finding in Original Units | char | Predecessor | 原始单位结果 |
| EGORRESU | Original Units | char | Predecessor | 原始单位 |
| EGSTRESC | Character Result/Finding in Std Format | char | Predecessor | 标准格式字符结果 |
| EGSTRESN | Numeric Result/Finding in Standard Units | num | Predecessor | 标准单位数值结果，AVAL 主要来源 |
| EGSTRESU | Standard Units | char | Predecessor | 标准单位 |
| EGSTAT | Completion Status | char | Predecessor | 采集完成状态（如 NOT DONE） |
| EGLOC | Lead Location Used for Measurement | char | Predecessor | 导联/测量部位 |
| EGBLFL | Baseline Flag | char | Predecessor | EG 域原始基线标志 |
| VISITNUM | Visit Number | num | Predecessor | EG.VISITNUM |
| VISIT | Visit Name | char | Predecessor | EG.VISIT |
| VISITDY | Planned Study Day of Visit | num | Predecessor | EG.VISITDY |
| EGDTC | Date/Time of ECG | char | Predecessor | EG.EGDTC，ADT/ADTM 来源 |
| EGDY | Study Day of ECG | num | Predecessor | EG.EGDY |
| EGTPT | Planned Time Point Name | char | Predecessor | 计划时间点名称 |
| EGTPTNUM | Planned Time Point Number | num | Predecessor | 计划时间点编号 |
| EGELTM | Planned Elapsed Time from Time Point Ref | char | Predecessor | 相对参考时间点的计划经过时间 |
| EGTPTREF | Time Point Reference | char | Predecessor | 时间点参考 |

---

## Dummy 数据示例（R，取自 pharmaverseadam::adeg 真实样本）

```r
library(tibble)

adeg <- tibble(
  STUDYID  = "CDISCPILOT01",
  USUBJID  = "01-701-1015",
  PARAMCD  = "QT",
  PARAM    = "QT Duration (ms)",
  AVISIT   = c("Baseline", "Baseline", "Week 2", "Week 2"),
  AVAL     = c(395, 476, 400, 424),
  BASE     = c(457, 457, 457, 457),
  CHG      = c(NA, NA, -57, -33),
  ABLFL    = c("Y", NA, NA, NA),
  TRTA     = "Placebo"
)
```
