# ADTR — Tumor/Lesion Result Analysis Dataset

> 数据来源：CDISC ADaM IG v1.3（BDS 章节）+ pharmaverse `admiralonco` 官方 ADTR vignette + `pharmaverseadam::adtr_onco` 实际结构整理。该测试数据基于 CDISC 公开的 **CDISCPILOT01** 研究，非任何真实公司/产品数据。

## 数据集概览

| 项目 | 内容 |
|------|------|
| 数据集名称 | ADTR |
| 描述 | Tumor/Lesion Result Analysis Dataset |
| Class | BDS (Basic Data Structure) |
| Structure | One record per subject per analysis parameter per visit（靶病灶或直径总和） |
| 用途 | 存储靶病灶单个直径（LDIAMn）与直径总和（SDIAM），派生基线、变化（CHG/PCHG）、最低点（NADIR）等，用于绘制瀑布图（waterfall）与蜘蛛图（spider） |
| 主键 | STUDYID, USUBJID, PARAMCD, AVISITN, TRLNKID |
| 备注 | 基于 SDTM **TR**（Tumor/Lesion Results）域衍生，合并 ADSL。`admiralonco` 官方 vignette（`vignette("adtr")`）演示了直径总和、基线、相对最低点变化等派生方法。 |

---

## 变量列表（共 99 个变量，取自 `pharmaverseadam::adtr_onco`）

> 前段（STUDYID … DTHCGR1，含 PDFL）为从 **ADSL** 带入的受试者级变量；中段为 BDS 分析变量；末段（TRSEQ … LSASS）为从 **TR** 域带入的采集变量。ADSL 带入部分与 ADRS 相同，此处从略标注。

| Variable | Label | Type | Origin | 说明 |
|----------|-------|------|--------|------|
| STUDYID | Study Identifier | char | Predecessor(ADSL) | 研究标识 |
| USUBJID | Unique Subject Identifier | char | Predecessor(ADSL) | 受试者唯一标识 |
| SUBJID | Subject Identifier for the Study | char | Predecessor(ADSL) | 研究内受试者编号 |
| SITEID | Study Site Identifier | char | Predecessor(ADSL) | 中心编号 |
| COUNTRY | Country | char | Predecessor(ADSL) | 国家 |
| DOMAIN | Domain Abbreviation | char | Predecessor(TR) | 域缩写（TR） |
| RFSTDTC | Subject Reference Start Date/Time | char | Predecessor(ADSL) | 参考起始日期 |
| RFENDTC | Subject Reference End Date/Time | char | Predecessor(ADSL) | 参考结束日期 |
| RFXSTDTC | Date/Time of First Study Treatment | char | Predecessor(ADSL) | 首次给药日期 |
| RFXENDTC | Date/Time of Last Study Treatment | char | Predecessor(ADSL) | 末次给药日期 |
| RFPENDTC | Date/Time of End of Participation | char | Predecessor(ADSL) | 参与结束日期 |
| SCRFDT | Screen Failure Date | num (Date) | Predecessor(ADSL) | 筛选失败日期 |
| FRVDT | Final Retrieval Visit Date | num (Date) | Predecessor(ADSL) | 末次回访日期 |
| DTHDTC | Date/Time of Death | char | Predecessor(ADSL) | 死亡日期（字符） |
| DTHADY | Relative Day of Death | num | Predecessor(ADSL) | 死亡相对日 |
| DTHFL | Subject Death Flag | char | Predecessor(ADSL) | 死亡标志 |
| LDDTHELD | Elapsed Days from Last Dose to Death | num | Predecessor(ADSL) | 末次给药至死亡天数 |
| LDDTHGR1 | Last Dose to Death - Days Elapsed Grp 1 | char | Predecessor(ADSL) | 末次给药至死亡分组 |
| DTH30FL | Death Within 30 Days of Last Trt Flag | char | Predecessor(ADSL) | 末次给药后30天内死亡标志 |
| DTHA30FL | Death After 30 Days from Last Trt Flag | char | Predecessor(ADSL) | 末次给药后30天以上死亡标志 |
| DTHDOM | Domain for Date of Death Collection | char | Predecessor(ADSL) | 死亡日期采集域 |
| DTHB30FL | Death Within 30 Days of First Trt Flag | char | Predecessor(ADSL) | 首次给药后30天内死亡标志 |
| ASEQ | Analysis Sequence Number | num | Derived | 分析序号 |
| REGION1 | Geographic Region 1 | char | Predecessor(ADSL) | 地理区域 |
| DMDTC | Date/Time of Collection | char | Predecessor(ADSL) | DM 采集日期 |
| DMDY | Study Day of Collection | num | Predecessor(ADSL) | DM 采集研究日 |
| AGE | Age | num | Predecessor(ADSL) | 年龄 |
| AGEU | Age Units | char | Predecessor(ADSL) | 年龄单位 |
| AGEGR1 | Pooled Age Group 1 | char | Predecessor(ADSL) | 年龄分组 |
| SEX | Sex | char | Predecessor(ADSL) | 性别 |
| RACE | Race | char | Predecessor(ADSL) | 种族 |
| RACEGR1 | Pooled Race Group 1 | char | Predecessor(ADSL) | 种族分组 |
| ETHNIC | Ethnicity | char | Predecessor(ADSL) | 民族 |
| SAFFL | Safety Population Flag | char | Predecessor(ADSL) | 安全性人群标志 |
| PDFL | Pharmacodynamic Analysis Set Flag | char | Predecessor(ADSL) | 药效学分析集标志 |
| ARM | Description of Planned Arm | char | Predecessor(ADSL) | 计划治疗组描述 |
| ARMCD | Planned Arm Code | char | Predecessor(ADSL) | 计划治疗组代码 |
| ACTARM | Description of Actual Arm | char | Predecessor(ADSL) | 实际治疗组描述 |
| ACTARMCD | Actual Arm Code | char | Predecessor(ADSL) | 实际治疗组代码 |
| TRT01P | Planned Treatment for Period 01 | char | Predecessor(ADSL) | 计划治疗（周期01） |
| TRT01A | Actual Treatment for Period 01 | char | Predecessor(ADSL) | 实际治疗（周期01） |
| TRTSDT | Date of First Exposure to Treatment | num (Date) | Predecessor(ADSL) | 首次给药日期 |
| TRTSDTM | Datetime of First Exposure to Treatment | num (datetime) | Predecessor(ADSL) | 首次给药日期时间 |
| TRTSTMF | Time of First Exposure Imput. Flag | char | Predecessor(ADSL) | 首次给药时间插补标志 |
| TRTEDT | Date of Last Exposure to Treatment | num (Date) | Predecessor(ADSL) | 末次给药日期 |
| TRTEDTM | Datetime of Last Exposure to Treatment | num (datetime) | Predecessor(ADSL) | 末次给药日期时间 |
| TRTETMF | Time of Last Exposure Imput. Flag | char | Predecessor(ADSL) | 末次给药时间插补标志 |
| EOSSTT | End of Study Status | char | Predecessor(ADSL) | 研究结束状态 |
| EOSDT | End of Study Date | num (Date) | Predecessor(ADSL) | 研究结束日期 |
| RFICDTC | Date/Time of Informed Consent | char | Predecessor(ADSL) | 知情同意日期 |
| RANDDT | Date of Randomization | num (Date) | Predecessor(ADSL) | 随机化日期 |
| LSTALVDT | Date Last Known Alive | num (Date) | Predecessor(ADSL) | 末次确认存活日期 |
| TRTDURD | Total Treatment Duration (Days) | num | Predecessor(ADSL) | 总治疗持续天数 |
| DTHDT | Date of Death | num (Date) | Predecessor(ADSL) | 死亡日期（数值） |
| DTHCAUS | Cause of Death | char | Predecessor(ADSL) | 死亡原因 |
| DTHCGR1 | Cause of Death Reason 1 | char | Predecessor(ADSL) | 死亡原因分组 |
| ADT | Analysis Date | num (Date) | Derived | 分析日期，`derive_vars_dt()` 解析 TR.TRDTC |
| ADY | Analysis Relative Day | num | Derived | 分析相对日，`derive_vars_dy()`，相对 TRTSDT |
| ADTF | Analysis Date Imputation Flag | char | Derived | ADT 日期插补标志 |
| AVISIT | Analysis Visit | char | Derived | 分析访视，基线记录设 "BASELINE"，余取 TR.VISIT |
| AVISITN | Analysis Visit (N) | num | Derived | 分析访视编号 |
| PARAM | Parameter | char | Assigned | 参数描述（见下方参数说明） |
| PARAMCD | Parameter Code | char | Assigned | 参数代码（见下方参数说明） |
| PARCAT1 | Parameter Category 1 | char | Assigned | 参数大类，如 "Target Lesion(s)" |
| PARCAT2 | Parameter Category 2 | char | Assigned | 参数子类（可选） |
| PARCAT3 | Parameter Category 3 | char | Assigned | 参数子类（可选） |
| AVAL | Analysis Value | num | Derived | 数值分析值（直径 mm 或直径总和 mm） |
| BASE | Baseline Value | num | Derived | 基线值，取 ABLFL="Y" 记录的 AVAL |
| CHG | Change from Baseline | num | Derived | 相对基线变化 = AVAL − BASE |
| PCHG | Percent Change from Baseline | num | Derived | 相对基线百分比变化 = CHG/BASE×100 |
| NADIR | NADIR | num | Derived | 基线后至当前访视前的最小直径总和（含基线） |
| CHGNAD | Change from NADIR | num | Derived | 相对最低点变化 = AVAL − NADIR |
| PCHGNAD | Percent Change from NADIR | num | Derived | 相对最低点百分比变化 = CHGNAD/NADIR×100 |
| ABLFL | Baseline Record Flag | char | Derived | 基线记录标志，`derive_var_extreme_flag()` |
| ANL01FL | Analysis Flag 01 | char | Derived | 蜘蛛图记录选择标志 |
| ANL02FL | Analysis Flag 02 | char | Derived | 瀑布图记录选择标志 |
| ANL03FL | Analysis Flag 03 | char | Derived | 附加分析标志 |
| ANL04FL | Analysis Flag 04 | char | Derived | 附加分析标志 |
| TRSEQ | Sequence Number | num | Predecessor(TR) | TR.TRSEQ |
| TRGRPID | Group ID | char | Predecessor(TR) | TR.TRGRPID |
| TRLNKID | Link ID | char | Predecessor(TR) | TR.TRLNKID，病灶链接标识（如 T01/T02） |
| TRTESTCD | Tumor/Lesion Assessment Short Name | char | Predecessor(TR) | TR.TRTESTCD（如 DIAMETER/SUMDIAM） |
| TRTEST | Tumor/Lesion Assessment Test Name | char | Predecessor(TR) | TR.TRTEST |
| TRORRES | Result or Finding in Original Units | char | Predecessor(TR) | TR.TRORRES，原始结果 |
| TRORRESU | Original Units | char | Predecessor(TR) | TR.TRORRESU，原始单位 |
| TRSTRESC | Character Result/Finding in Std Format | char | Predecessor(TR) | TR.TRSTRESC |
| TRSTRESN | Numeric Result/Finding in Standard Units | num | Predecessor(TR) | TR.TRSTRESN，标准化数值结果 |
| TRSTRESU | Standard Units | char | Predecessor(TR) | TR.TRSTRESU，标准单位（如 mm） |
| TREVAL | Evaluator | char | Predecessor(TR) | TR.TREVAL，评估者 |
| TREVALID | Evaluator Identifier | char | Predecessor(TR) | TR.TREVALID |
| TRACPTFL | Accepted Record Flag | char | Predecessor(TR) | TR.TRACPTFL |
| VISITNUM | Visit Number | num | Predecessor(TR) | TR.VISITNUM |
| VISIT | Visit Name | char | Predecessor(TR) | TR.VISIT |
| TRDTC | Date/Time of Tumor/Lesion Measurement | char | Predecessor(TR) | TR.TRDTC |
| TULOC | Location of the Tumor/Lesion | char | Predecessor(TU) | 病灶部位（如 LYMPH NODE/BONE） |
| TULOCGR1 | Tumor Site Group 1 | char | Derived | 病灶部位分组 |
| LSEXP | Lesion IDs Expected | char | Derived | 期望评估的病灶 ID 集合 |
| LSASS | Lesion IDs Assessed | char | Derived | 实际评估的病灶 ID 集合 |
| DTHDTF | Date of Death Imputation Flag | char | Predecessor(ADSL) | 死亡日期插补标志 |

### 关键参数（PARAMCD）说明

| PARAMCD | PARAM | 含义 |
|---------|-------|------|
| LDIAM1–LDIAM5 | Target Lesion n Analysis Diameter | 第 n 个靶病灶直径 |
| NLDIAM1–NLDIAM5 | Target Lesion n Analysis Perpendicular | 第 n 个靶病灶垂直径 |
| SDIAM | Target Lesions Sum of Diameters by Investigator | 靶病灶直径总和（SoD，用于瀑布/蜘蛛图） |

---

## Dummy 数据示例（R，取自 pharmaverseadam::adtr_onco 真实样本）

```r
library(tibble)

adtr <- tribble(
  ~STUDYID,       ~USUBJID,      ~PARAMCD, ~PARAM,                                              ~TRLNKID, ~AVISIT,    ~ADT,         ~AVAL, ~BASE, ~CHG, ~PCHG, ~ABLFL, ~PARCAT1,
  "CDISCPILOT01", "01-701-1015", "SDIAM",  "Target Lesions Sum of Diameters by Investigator",   NA,       "BASELINE", "2014-01-02",  54.3,  54.3,   NA,    NA, "Y",    "Target Lesion(s)",
  "CDISCPILOT01", "01-701-1015", "SDIAM",  "Target Lesions Sum of Diameters by Investigator",   NA,       "WEEK 3",   "2014-01-23",  55.7,  54.3,  1.4,   2.6, NA,     "Target Lesion(s)",
  "CDISCPILOT01", "01-701-1015", "SDIAM",  "Target Lesions Sum of Diameters by Investigator",   NA,       "WEEK 9",   "2014-03-06",   0.0,  54.3,-54.3,-100.0, NA,     "Target Lesion(s)",
  "CDISCPILOT01", "01-701-1015", "LDIAM1", "Target Lesion 1 Analysis Diameter",                 "T01",    "BASELINE", "2014-01-02",  21.0,  21.0,   NA,    NA, "Y",    "Target Lesion(s)",
  "CDISCPILOT01", "01-701-1015", "LDIAM1", "Target Lesion 1 Analysis Diameter",                 "T01",    "WEEK 3",   "2014-01-23",  20.0,  21.0, -1.0,  -4.8, NA,     "Target Lesion(s)"
) |>
  dplyr::mutate(ADT = as.Date(ADT))
```
