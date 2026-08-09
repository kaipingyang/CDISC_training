# ADVS — Vital Signs Analysis Dataset

> 数据来源：CDISC ADaM IG v1.3（BDS 结构）+ pharmaverse `pharmaverseadam::advs` 实际结构整理

## 数据集概览

| 项目 | 内容 |
|------|------|
| 数据集名称 | ADVS |
| 描述 | Vital Signs Analysis Dataset |
| Class | BDS（Basic Data Structure） |
| Structure | One record per subject per parameter per analysis visit (per timepoint)（每受试者每参数每分析访视一条记录） |
| 用途 | 支持生命体征分析，包括基线、变化量、百分比变化、参考范围指示、分析访视窗口、基线/治疗期标志等 |
| 主键 | STUDYID, USUBJID, PARAMCD, AVISIT（+ ATPT / ADT，视设计而定） |
| 备注 | 基于 SDTM VS 域衍生，并合并 ADSL 的受试者级别变量。前 57 个变量来自 ADSL，其余为 BDS 分析变量与 VS 域来源变量。admiral 官方 vignette（`vignette("bds_finding")`）演示了 PARAMCD 分配、基线、变化量、访视窗口等标准派生。 |

---

## 变量列表（共 105 个变量，取自 `pharmaverseadam::advs`）

> 注：前 57 个变量（STUDYID … DTHCGR1）来自 ADSL 合并，Origin 记为 `ADSL`。以下重点说明 BDS 核心分析变量与 VS 域来源变量。

### ADSL 合并变量（受试者级别）

| Variable | Label | Type | Origin | 说明 |
|----------|-------|------|--------|------|
| STUDYID | Study Identifier | char | ADSL | |
| USUBJID | Unique Subject Identifier | char | ADSL | |
| SUBJID | Subject Identifier for the Study | char | ADSL | |
| SITEID | Study Site Identifier | char | ADSL | |
| COUNTRY | Country | char | ADSL | |
| DOMAIN | Domain Abbreviation | char | Predecessor | VS.DOMAIN |
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
| ADT | Analysis Date | num (Date) | Derived | `derive_vars_dt()` 解析 VSDTC 得到的分析日期 |
| ADY | Analysis Relative Day | num | Derived | `derive_vars_dy()`：ADT 相对 TRTSDT 的研究日 |
| AVISIT | Analysis Visit | char | Derived | 分析访视，按访视窗口把原始 VISIT 映射为标准化标签（如 Baseline/Week 2） |
| AVISITN | Analysis Visit (N) | num | Derived | AVISIT 的数值排序编码 |
| ATPT | Analysis Timepoint | char | Derived | 分析时间点（如给药前/后），来自 VSTPT |
| ATPTN | Analysis Timepoint (N) | num | Derived | ATPT 数值编码 |
| PARAM | Parameter | char | Assigned | 参数完整描述（含单位），如 "Systolic Blood Pressure (mmHg)"，用 `derive_vars_param()`/查找表分配 |
| PARAMCD | Parameter Code | char | Assigned | 参数短代码（如 SYSBP/DIABP/PULSE/TEMP/WEIGHT），BDS 核心分类键，通常映射自 VSTESTCD |
| PARAMN | Parameter (N) | num | Assigned | PARAMCD 的数值排序编码 |
| AVAL | Analysis Value | num | Derived | 分析数值，通常取 VSSTRESN；派生记录（如均值）按 DTYPE 逻辑计算 |
| AVALCAT1 | Analysis Value Category 1 | char | Derived | AVAL 分类（如按临床阈值分组） |
| AVALCA1N | Analysis Value Category 1 (N) | num | Derived | AVALCAT1 数值编码 |
| BASE | Baseline Value | num | Derived | `derive_var_base()`：取该受试者该参数基线记录（ABLFL="Y"）的 AVAL |
| BASETYPE | Baseline Type | char | Derived | 基线类型，多基线设计时区分不同基线定义 |
| CHG | Change from Baseline | num | Derived | `derive_var_chg()`：AVAL - BASE |
| PCHG | Percent Change from Baseline | num | Derived | `derive_var_pchg()`：(AVAL - BASE) / BASE * 100 |
| DTYPE | Derivation Type | char | Derived | 派生类型，非原始记录标记来源（如 AVERAGE/LOCF），原始观测为空 |
| ANRIND | Analysis Reference Range Indicator | char | Derived | `derive_var_anrind()`：AVAL 相对 ANRLO/ANRHI 的范围指示（LOW/NORMAL/HIGH） |
| BNRIND | Baseline Reference Range Indicator | char | Derived | 基线记录的 ANRIND，合并到后续访视记录 |
| ANRLO | Analysis Normal Range Lower Limit | num | Predecessor | 正常范围下限，来自 VS.VSSTRNLO 或元数据 |
| ANRHI | Analysis Normal Range Upper Limit | num | Predecessor | 正常范围上限 |
| A1LO | Analysis Range 1 Lower Limit | num | Assigned | 分析范围 1 下限（附加临床阈值） |
| A1HI | Analysis Range 1 Upper Limit | num | Assigned | 分析范围 1 上限 |
| ABLFL | Baseline Record Flag | char | Derived | `derive_var_extreme_flag()`：标记每受试者每参数的基线记录（通常给药前末次），"Y" |
| ANL01FL | Analysis Flag 01 | char | Derived | 标记纳入主要分析的记录（如每访视窗口取一条），"Y" |
| ONTRTFL | On Treatment Record Flag | char | Derived | `derive_var_ontrtfl()`：测量日期落在治疗窗内则 "Y" |

### VS 域来源变量

| Variable | Label | Type | Origin | 说明 |
|----------|-------|------|--------|------|
| VSSEQ | Sequence Number | num | Predecessor | VS.VSSEQ |
| VSTESTCD | Vital Signs Test Short Name | char | Predecessor | VS.VSTESTCD，映射 PARAMCD 的来源 |
| VSTEST | Vital Signs Test Name | char | Predecessor | VS.VSTEST |
| VSPOS | Vital Signs Position of Subject | char | Predecessor | 测量时体位 |
| VSORRES | Result or Finding in Original Units | char | Predecessor | 原始单位结果 |
| VSORRESU | Original Units | char | Predecessor | 原始单位 |
| VSSTRESC | Character Result/Finding in Std Format | char | Predecessor | 标准格式字符结果 |
| VSSTRESN | Numeric Result/Finding in Standard Units | num | Predecessor | 标准单位数值结果，AVAL 主要来源 |
| VSSTRESU | Standard Units | char | Predecessor | 标准单位 |
| VSSTAT | Completion Status | char | Predecessor | 采集完成状态（如 NOT DONE） |
| VSLOC | Location of Vital Signs Measurement | char | Predecessor | 测量部位 |
| VSBLFL | Baseline Flag | char | Predecessor | VS 域原始基线标志 |
| VISITNUM | Visit Number | num | Predecessor | VS.VISITNUM |
| VISIT | Visit Name | char | Predecessor | VS.VISIT |
| VISITDY | Planned Study Day of Visit | num | Predecessor | VS.VISITDY |
| VSDTC | Date/Time of Measurements | char | Predecessor | VS.VSDTC，ADT 来源 |
| VSDY | Study Day of Vital Signs | num | Predecessor | VS.VSDY |
| VSTPT | Planned Time Point Name | char | Predecessor | 计划时间点名称 |
| VSTPTNUM | Planned Time Point Number | num | Predecessor | 计划时间点编号 |
| VSELTM | Planned Elapsed Time from Time Point Ref | char | Predecessor | 相对参考时间点的计划经过时间 |
| VSTPTREF | Time Point Reference | char | Predecessor | 时间点参考 |

---

## Dummy 数据示例（R，取自 pharmaverseadam::advs 真实样本）

```r
library(tibble)

advs <- tibble(
  STUDYID  = "CDISCPILOT01",
  USUBJID  = "01-701-1015",
  PARAMCD  = "BMI",
  PARAM    = "Body Mass Index(kg/m^2)",
  AVISIT   = c("Baseline", "Baseline", "Week 2"),
  AVAL     = c(25.1, 25.1, 24.5),
  BASE     = c(25.1, 25.1, 25.1),
  CHG      = c(NA, NA, -0.627),
  ABLFL    = c("Y", NA, NA),
  TRTA     = "Placebo"
)
```
