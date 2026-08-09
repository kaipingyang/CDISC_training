# ADLB — Laboratory Analysis Dataset

> 数据来源：CDISC ADaM IG v1.3（BDS 结构）+ pharmaverse `pharmaverseadam::adlb` 实际结构整理

## 数据集概览

| 项目 | 内容 |
|------|------|
| 数据集名称 | ADLB |
| 描述 | Laboratory Analysis Dataset（实验室检查分析数据集） |
| Class | BDS（Basic Data Structure） |
| Structure | One record per subject per parameter per analysis visit（每受试者每参数每分析访视一条记录） |
| 用途 | 支持实验室检查的描述性分析、基线/变化量、参考范围异常、NCI-CTCAE 毒性分级、shift table，以及 Hy's Law 前置数据 |
| 主键 | STUDYID, USUBJID, PARAMCD, AVISITN, ADT（或 ASEQ） |
| 输入 | SDTM LB 域 + ADSL；用 `admiral` BDS findings 流程衍生 |
| 备注 | ADSL 级别变量（人口学、暴露、处置）通过合并带入；LB* 前缀变量为 SDTM Predecessor |

---

## 变量列表（共 115 个变量，取自 `pharmaverseadam::adlb`）

说明：前段 STUDYID–DTHCGR1 为从 ADSL 合并的受试者级变量（此处简写为“合并自 ADSL”）；中段为 BDS 分析变量（本域核心）；末段 LB* / VISIT* 为 SDTM LB 域 Predecessor。

| Variable | Label | Type | Origin | 说明 |
|----------|-------|------|--------|------|
| STUDYID | Study Identifier | char | Predecessor | ADSL.STUDYID |
| USUBJID | Unique Subject Identifier | char | Predecessor | ADSL.USUBJID |
| SUBJID | Subject Identifier for the Study | char | Predecessor | 合并自 ADSL |
| SITEID | Study Site Identifier | char | Predecessor | 合并自 ADSL |
| COUNTRY | Country | char | Predecessor | 合并自 ADSL |
| DOMAIN | Domain Abbreviation | char | Predecessor | LB.DOMAIN |
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
| TRTP | Planned Treatment | char | Derived | 本分析记录对应的计划治疗，通常取自 TRT01P |
| TRTA | Actual Treatment | char | Derived | 本分析记录对应的实际治疗，通常取自 TRT01A |
| TRT01P | Planned Treatment for Period 01 | char | Derived | 合并自 ADSL |
| TRT01A | Actual Treatment for Period 01 | char | Derived | 合并自 ADSL |
| TRTSDT | Date of First Exposure to Treatment | num (Date) | Derived | 合并自 ADSL，用于计算 ADY |
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
| ADT | Analysis Date | num (Date) | Derived | `derive_vars_dt()` 解析 LB.LBDTC |
| ADY | Analysis Relative Day | num | Derived | `derive_vars_dy()`：ADT 相对 TRTSDT 的研究日 |
| AVISIT | Analysis Visit | char | Derived | 由 VISIT 派生的分析访视（Baseline / Week n / 派生汇总访视） |
| AVISITN | Analysis Visit (N) | num | Derived | AVISIT 的数值排序 |
| PARAM | Parameter | char | Derived | 参数全称含单位，如 "Albumin (g/L)" |
| PARAMCD | Parameter Code | char | Derived | 参数短码（ALB/ALT/AST/BILI/CREAT 等），映射自 LB.LBTESTCD |
| PARAMN | Parameter (N) | num | Derived | PARAM 的数值编码，供排序 |
| PARCAT1 | Parameter Category 1 | char | Derived | 参数分类，取自 LB.LBCAT（如 CHEMISTRY / HEMATOLOGY） |
| AVAL | Analysis Value | num | Derived | 分析数值，通常取自 LB.LBSTRESN |
| AVALC | Analysis Value (C) | char | Derived | AVAL 的字符表示，或取自 LB.LBSTRESC |
| BASE | Baseline Value | num | Derived | ABLFL="Y" 记录的 AVAL，`derive_var_base()` |
| BASEC | Baseline Value (C) | char | Derived | BASE 的字符表示 |
| BASETYPE | Baseline Type | char | Derived | 多基线场景下的基线定义类型（如 "LAST"） |
| CHG | Change from Baseline | num | Derived | AVAL - BASE，`derive_var_chg()` |
| PCHG | Percent Change from Baseline | num | Derived | 100*(AVAL-BASE)/BASE，`derive_var_pchg()` |
| R2BASE | Ratio to Baseline | num | Derived | AVAL / BASE |
| R2ANRLO | Ratio of Analysis Val compared to ANRLO | num | Derived | AVAL / ANRLO |
| R2ANRHI | Ratio of Analysis Val compared to ANRHI | num | Derived | AVAL / ANRHI（Hy's Law 常用） |
| SHIFT1 | Shift from Baseline to Analysis Value | char | Derived | BNRIND→ANRIND 移位（如 "NORMAL to HIGH"），用于 shift table |
| SHIFT2 | Shift from Baseline to Overall Grade | char | Derived | BTOXGR→ATOXGR 毒性等级移位 |
| DTYPE | Derivation Type | char | Derived | 派生记录类型（汇总访视如 MINIMUM/MAXIMUM/LOV），原始记录为空 |
| ATOXGR | Analysis Toxicity Grade | char | Derived | 分析毒性分级（NCI-CTCAE），`derive_var_atoxgr()` |
| BTOXGR | Baseline Toxicity Grade | char | Derived | 基线毒性分级 |
| ANRIND | Analysis Reference Range Indicator | char | Derived | 参考范围指示（LOW/NORMAL/HIGH），`derive_var_anrind()` |
| BNRIND | Baseline Reference Range Indicator | char | Derived | 基线记录的 ANRIND |
| ANRLO | Analysis Normal Range Lower Limit | num | Derived | 参考范围下限，取自 LB.LBSTNRLO |
| ANRHI | Analysis Normal Range Upper Limit | num | Derived | 参考范围上限，取自 LB.LBSTNRHI |
| ATOXGRL | Analysis Toxicity Grade Low | char | Derived | 低值方向毒性分级（低值异常参数） |
| ATOXGRH | Analysis Toxicity Grade High | char | Derived | 高值方向毒性分级（高值异常参数） |
| BTOXGRL | Baseline Toxicity Grade Low | char | Derived | 基线低值方向毒性分级 |
| BTOXGRH | Baseline Toxicity Grade High | char | Derived | 基线高值方向毒性分级 |
| ATOXDSCL | Analysis Toxicity Description Low | char | Derived | 低值方向毒性判定所用标准描述 |
| ATOXDSCH | Analysis Toxicity Description High | char | Derived | 高值方向毒性判定所用标准描述 |
| ABLFL | Baseline Record Flag | char | Derived | 基线记录标志（"Y"），取治疗前末次值，`derive_var_extreme_flag()` |
| ANL01FL | Analysis Flag 01 | char | Derived | 主分析记录标志（"Y"），每受试者每参数每访视选唯一记录参与分析 |
| ONTRTFL | On Treatment Record Flag | char | Derived | 治疗期内记录标志，`derive_var_ontrtfl()` |
| LVOTFL | Last Value On Treatment Record Flag | char | Derived | 治疗期末次值标志 |
| LBSEQ | Sequence Number | num | Predecessor | LB.LBSEQ |
| LBTESTCD | Lab Test or Examination Short Name | char | Predecessor | LB.LBTESTCD |
| LBTEST | Lab Test or Examination Name | char | Predecessor | LB.LBTEST |
| LBCAT | Category for Lab Test | char | Predecessor | LB.LBCAT |
| LBORRES | Result or Finding in Original Units | char | Predecessor | LB.LBORRES |
| LBORRESU | Original Units | char | Predecessor | LB.LBORRESU |
| LBORNRLO | Reference Range Lower Limit in Orig Unit | char | Predecessor | LB.LBORNRLO |
| LBORNRHI | Reference Range Upper Limit in Orig Unit | char | Predecessor | LB.LBORNRHI |
| LBSTRESC | Character Result/Finding in Std Format | char | Predecessor | LB.LBSTRESC |
| LBSTRESN | Numeric Result/Finding in Standard Units | num | Predecessor | LB.LBSTRESN |
| LBSTRESU | Standard Units | char | Predecessor | LB.LBSTRESU |
| LBSTNRLO | Reference Range Lower Limit-Std Units | num | Predecessor | LB.LBSTNRLO |
| LBSTNRHI | Reference Range Upper Limit-Std Units | num | Predecessor | LB.LBSTNRHI |
| LBNRIND | Reference Range Indicator | char | Predecessor | LB.LBNRIND |
| LBBLFL | Baseline Flag | char | Predecessor | LB.LBBLFL（SDTM 采集的基线标志，供参照） |
| VISITNUM | Visit Number | num | Predecessor | LB.VISITNUM |
| VISIT | Visit Name | char | Predecessor | LB.VISIT |
| VISITDY | Planned Study Day of Visit | num | Predecessor | LB.VISITDY |
| LBDTC | Date/Time of Specimen Collection | char | Predecessor | LB.LBDTC |
| LBDY | Study Day of Specimen Collection | num | Predecessor | LB.LBDY |

---

## Dummy 数据示例（R，取自 `pharmaverseadam::adlb` 真实样本）

```r
library(tibble)

adlb <- tibble(
  STUDYID = "CDISCPILOT01",
  USUBJID = "01-701-1015",
  PARAMCD = c("ALB", "ALB", "ALB"),
  PARAM   = "Albumin (g/L)",
  PARCAT1 = "CHEMISTRY",
  AVISIT  = c("Baseline", "Week 2", "Week 4"),
  AVISITN = c(0, 2, 4),
  ADT     = as.Date(c("2013-12-26", "2014-01-16", "2014-01-30")),
  AVAL    = c(38, 39, 38),
  BASE    = c(38, 38, 38),
  CHG     = c(NA, 1, 0),
  PCHG    = c(NA, 2.631579, 0),
  ANRLO   = 33, ANRHI = 49,
  ANRIND  = c("NORMAL", "NORMAL", "NORMAL"),
  ATOXGR  = c("0", "0", "0"),
  ABLFL   = c("Y", NA, NA),
  ANL01FL = c(NA, "Y", "Y")
)
```
