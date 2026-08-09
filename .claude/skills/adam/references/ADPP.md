# ADPP — Pharmacokinetic Parameters Analysis Dataset

> 数据来源：CDISC ADaM IG v1.3（BDS 结构）+ pharmaverse `pharmaverseadam::adpp` 实际结构整理

## 数据集概览

| 项目 | 内容 |
|------|------|
| 数据集名称 | ADPP |
| 描述 | Pharmacokinetic Parameters Analysis Dataset（药代动力学参数分析数据集） |
| Class | BDS（Basic Data Structure） |
| Structure | One record per subject per parameter per analysis visit（每受试者每 PK 参数每分析访视一条记录） |
| 用途 | 支持 NCA PK 参数分析：AUC、Cmax、Tmax、半衰期（LAMZHL）、清除率、肾清除率等 |
| 主键 | STUDYID, USUBJID, PPCAT, PARAMCD, AVISITN |
| 输入 | SDTM PP 域（PK 参数）+ ADSL；PK 参数通常由 ADPC 浓度数据经 NCA 计算得到并回填至 PP |
| 备注 | 与 ADPC 配套：ADPC 为浓度-时间数据，ADPP 为由其派生的 NCA 汇总参数 |

---

## 变量列表（共 79 个变量，取自 `pharmaverseadam::adpp`）

说明：前段 STUDYID–DTHCGR1 为从 ADSL 合并的受试者级变量（简写为“合并自 ADSL”）；中段为 BDS 分析变量；末段 PP* 为 SDTM PP 域 Predecessor。

| Variable | Label | Type | Origin | 说明 |
|----------|-------|------|--------|------|
| STUDYID | Study Identifier | char | Predecessor | ADSL.STUDYID |
| USUBJID | Unique Subject Identifier | char | Predecessor | ADSL.USUBJID |
| SUBJID | Subject Identifier for the Study | char | Predecessor | 合并自 ADSL |
| SITEID | Study Site Identifier | char | Predecessor | 合并自 ADSL |
| COUNTRY | Country | char | Predecessor | 合并自 ADSL |
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
| TRTP | Planned Treatment | char | Derived | 本记录对应计划治疗，通常取自 TRT01P |
| TRTA | Actual Treatment | char | Derived | 本记录对应实际治疗，通常取自 TRT01A |
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
| ADT | Analysis Date | num (Date) | Derived | 参数对应的分析日期（通常为给药参考日） |
| ADY | Analysis Relative Day | num | Derived | ADT 相对 TRTSDT 的研究日 |
| AVISIT | Analysis Visit | char | Derived | 分析访视，如 "Day 1"，取自 VISIT |
| AVISITN | Analysis Visit (N) | num | Derived | AVISIT 的数值排序，取自 VISITNUM |
| PARAMCD | Parameter Code | char | Derived | PK 参数短码，源自 PP.PPTESTCD：AUCALL/AUCLST/CMAX/TMAX/CLST/LAMZ/LAMZHL/LAMZNPT/RCAMINT/RENALCL 等 |
| AVAL | Numeric Result/Finding in Standard Units | num | Derived | 参数分析值，取自 PP.PPSTRESN |
| AVALCAT1 | Analysis Value Category 1 | char | Derived | AVAL 分组类别（如数值区间） |
| AVALCA1N | Analysis Value Category 1 (N) | num | Derived | AVALCAT1 的数值编码 |
| SRCDOM | Domain Abbreviation | char | Derived | 溯源域名（如 "PP"） |
| SRCVAR | Source Variable | char | Derived | 溯源变量名（如 "PPSTRESN"） |
| SRCSEQ | Sequence Number | num | Derived | 溯源记录序号（PP.PPSEQ） |
| PPTESTCD | Parameter Short Name | char | Predecessor | PP.PPTESTCD |
| PPTEST | Parameter Name | char | Predecessor | PP.PPTEST |
| PPCAT | Parameter Category | char | Predecessor | PP.PPCAT（分析物类别，如 XANOMELINE） |
| PPORRES | Result or Finding in Original Units | char | Predecessor | PP.PPORRES |
| PPORRESU | Original Units | char | Predecessor | PP.PPORRESU |
| PPSTRESU | Standard Units | char | Predecessor | PP.PPSTRESU |
| PPSPEC | Specimen Material Type | char | Predecessor | PP.PPSPEC |
| PPRFDTC | Date/Time of Reference Point | char | Predecessor | PP.PPRFDTC（参考给药时点） |
| VISIT | Visit Name | char | Predecessor | PP.VISIT |
| VISITNUM | Visit Number | num | Predecessor | PP.VISITNUM |
| PARCAT1 | Parameter Category | char | Derived | 参数分类（供分析分组，可与 PPCAT 对应） |
| AVALU | Standard Units | char | Derived | 分析值单位，如 "h*ug/ml"、"ug/ml"、"h" |

---

## Dummy 数据示例（R，取自 `pharmaverseadam::adpp` 真实样本）

```r
library(tibble)

adpp <- tibble(
  STUDYID = "CDISCPILOT01",
  USUBJID = "01-701-1028",
  PPCAT   = "XANOMELINE",
  PARAMCD = c("AUCALL", "CMAX", "TMAX", "LAMZHL"),
  PARAM   = c("AUC All", "Max Concentration",
              "Time of CMAX", "Half-Life Lambda z"),
  AVISIT  = "Day 1",
  AVAL    = c(18.12104, 0.5469018, 0.5, 3.21),
  AVALU   = c("h*ug/ml", "ug/ml", "h", "h"),
  AVALCAT1 = c("<19", NA, NA, NA)
)
```
