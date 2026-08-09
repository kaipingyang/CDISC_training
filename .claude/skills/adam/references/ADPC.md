# ADPC — Pharmacokinetic Concentration Analysis Dataset

> 数据来源：CDISC ADaM IG v1.3（BDS 结构）+ pharmaverse `pharmaverseadam::adpc` 实际结构整理

## 数据集概览

| 项目 | 内容 |
|------|------|
| 数据集名称 | ADPC |
| 描述 | Pharmacokinetic Concentration Analysis Dataset（药代动力学浓度分析数据集） |
| Class | BDS（Basic Data Structure） |
| Structure | One record per subject per parameter per analysis timepoint（每受试者每参数每分析时间点一条记录） |
| 用途 | 支持 PK 浓度-时间分析：血浆药物浓度、相对给药时间（名义/实际）、给药剂量、LLOQ 处理等 |
| 主键 | STUDYID, USUBJID, PARAMCD, AVISITN, ATPTN, ADTM |
| 输入 | SDTM PC 域（浓度）+ EX 域（给药参考时间）+ ADSL；用 `admiral` PK 流程衍生 |
| 备注 | 含 DOSE 记录（给药事件）与 XAN 浓度记录；相对时间以给药参考时点为基准计算 |

---

## 变量列表（共 128 个变量，取自 `pharmaverseadam::adpc`）

说明：前段 STUDYID–DTHCGR1 为从 ADSL 合并的受试者级变量（简写为“合并自 ADSL”）；中段为 BDS 分析与相对时间变量（本域核心）；末段 PC* 为 SDTM PC 域 Predecessor。

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
| DOSEP | Planned Treatment Dose | num | Derived | 计划给药剂量（按方案） |
| DOSEA | Actual Treatment Dose | num | Derived | 实际给药剂量，取自 EX.EXDOSE |
| DOSEU | Treatment Dose Units | char | Derived | 给药剂量单位（如 mg） |
| ADT | Analysis Date | num (Date) | Derived | 采样分析日期，`derive_vars_dt()` 解析 PC.PCDTC |
| ATM | Analysis Time | char | Derived | 采样分析时间部分 |
| ADTM | Analysis Datetime | num (dtm) | Derived | 采样分析日期时间，`derive_vars_dtm()` |
| ADY | Analysis Relative Day | num | Derived | ADT 相对 TRTSDT 的研究日 |
| ATMF | Analysis Time Imputation Flag | char | Derived | 时间插补标志 |
| ASTDT | Analysis Start Date | num (Date) | Derived | 参考给药开始日期 |
| ASTTM | Analysis Start Time | char | Derived | 参考给药开始时间 |
| ASTDTM | Analysis Start Datetime | num (dtm) | Derived | 参考给药开始日期时间 |
| AENDT | Analysis End Date | num (Date) | Derived | 参考给药结束日期（输注结束） |
| AENTM | Analysis End Time | char | Derived | 参考给药结束时间 |
| AENDTM | Analysis End Datetime | num (dtm) | Derived | 参考给药结束日期时间 |
| AVISIT | Analysis Visit | char | Derived | 分析访视，如 "Day 1" |
| AVISITN | Analysis Visit (N) | num | Derived | AVISIT 的数值排序 |
| ATPT | Analysis Timepoint | char | Derived | 分析时间点，如 "Pre-dose"、"5 Min Post-dose" |
| ATPTN | Analysis Timepoint (N) | num | Derived | ATPT 的数值排序 |
| ATPTREF | Analysis Timepoint Reference | char | Derived | 时间点参考基准（对应给药事件） |
| PARAM | Parameter | char | Derived | 参数全称，如 "Pharmacokinetic concentration of Xanomeline" |
| PARAMCD | Parameter Code | char | Derived | 参数短码：XAN（浓度）、DOSE（给药事件） |
| PARAMN | Parameter (N) | num | Derived | PARAM 的数值编码 |
| PARCAT1 | Parameter Category 1 | char | Derived | 参数分类（如分析物 / 剂量） |
| AVAL | Analysis Value | num | Derived | 浓度分析值，取自 PC.PCSTRESN；低于 LLOQ 时按规则处理（如置 0） |
| AVALU | Analysis Value Unit | char | Derived | 分析值单位，如 "ug/ml"、"mg" |
| AVALCAT1 | Analysis Value Category 1 | char | Derived | AVAL 分组类别 |
| BASE | Baseline Value | num | Derived | 基线浓度，ABLFL="Y" 记录的 AVAL |
| BASETYPE | Baseline Type | char | Derived | 基线定义类型 |
| CHG | Change from Baseline | num | Derived | AVAL - BASE |
| DTYPE | Derivation Type | char | Derived | 派生记录类型（原始记录为空） |
| ABLFL | Baseline Record Flag | char | Derived | 基线记录标志（"Y"），通常为 Pre-dose 记录 |
| ANL01FL | Analysis Flag 01 | char | Derived | 主分析记录标志（"Y"） |
| ANL02FL | Analysis Flag 02 | char | Derived | 次分析记录标志 |
| SRCDOM | Source Data | char | Derived | 溯源域名（如 "PC"） |
| SRCVAR | Source Variable | char | Derived | 溯源变量名（如 "PCSTRESN"） |
| SRCSEQ | Source Sequence Number | num | Derived | 溯源记录序号（PC.PCSEQ） |
| NFRLT | Nom. Rel. Time from Analyte First Dose | num | Derived | 名义上相对分析物首剂的时间 |
| PCTESTCD | Pharmacokinetic Test Short Name | char | Predecessor | PC.PCTESTCD |
| PCTEST | Pharmacokinetic Test Name | char | Predecessor | PC.PCTEST |
| PCORRES | Result or Finding in Original Units | char | Predecessor | PC.PCORRES |
| PCORRESU | Original Units | char | Predecessor | PC.PCORRESU |
| PCSTRESC | Character Result/Finding in Std Format | char | Predecessor | PC.PCSTRESC |
| PCSTRESN | Numeric Result/Finding in Standard Units | num | Predecessor | PC.PCSTRESN |
| PCSTRESU | Standard Units | char | Predecessor | PC.PCSTRESU |
| PCNAM | Vendor Name | char | Predecessor | PC.PCNAM |
| PCSPEC | Specimen Material Type | char | Predecessor | PC.PCSPEC |
| PCLLOQ | Lower Limit of Quantitation | num | Predecessor | PC.PCLLOQ |
| VISIT | Visit Name | char | Predecessor | PC.VISIT |
| VISITNUM | Visit Number | num | Predecessor | PC.VISITNUM |
| VISITDY | Planned Study Day of Visit | num | Predecessor | PC.VISITDY |
| PCDTC | Date/Time of Specimen Collection | char | Predecessor | PC.PCDTC |
| PCDY | Actual Study Day of Specimen Collection | num | Predecessor | PC.PCDY |
| PCTPT | Planned Time Point Name | char | Predecessor | PC.PCTPT |
| PCTPTNUM | Planned Time Point Number | num | Predecessor | PC.PCTPTNUM |
| FANLDTM | First Datetime of Dose for Analyte | num (dtm) | Derived | 分析物首剂给药日期时间 |
| AFRLT | Act. Rel. Time from Analyte First Dose | num | Derived | 实际相对分析物首剂的时间 |
| ARRLT | Actual Rel. Time from Ref. Dose | num | Derived | 实际相对参考给药的时间（采样-参考给药） |
| PCRFTDTM | Reference Datetime of Dose for Analyte | num (dtm) | Derived | 参考给药日期时间 |
| FANLDT | First Date of Dose for Analyte | num (Date) | Derived | 分析物首剂给药日期 |
| FANLTM | First Time of Dose for Analyte | char | Derived | 分析物首剂给药时间 |
| PCRFTDT | Reference Date of Dose for Analyte | num (Date) | Derived | 参考给药日期 |
| PCRFTTM | Reference Time of Dose for Analyte | char | Derived | 参考给药时间 |
| NRRLT | Nominal Rel. Time from Ref. Dose | num | Derived | 名义相对参考给药的时间（按 ATPT 分配） |
| FRLTU | Rel. Time from First Dose Unit | char | Derived | 相对首剂时间单位（如 h） |
| RRLTU | Rel. Time from Ref. Dose Unit | char | Derived | 相对参考给药时间单位 |
| ALLOQ | Analysis Lower Limit of Quantitation | num | Derived | 分析用定量下限 |
| MRRLT | Modified Rel. Time from Ref. Dose | num | Derived | 修正后的相对参考给药时间 |
| HTBL | Numeric Result/Finding in Standard Units | num | Derived | 基线身高数值（协变量） |
| HTBLU | Standard Units | char | Derived | 基线身高单位 |
| WTBL | Numeric Result/Finding in Standard Units | num | Derived | 基线体重数值（协变量） |
| WTBLU | Standard Units | char | Derived | 基线体重单位 |
| BMIBL | Baseline Body Mass Index (kg/m2) | num | Derived | 基线体质指数 |
| BMIBLU | BMI at Baseline (Unit) | char | Derived | 基线 BMI 单位（kg/m2） |

---

## Dummy 数据示例（R，取自 `pharmaverseadam::adpc` 真实样本）

```r
library(tibble)

adpc <- tibble(
  STUDYID = "CDISCPILOT01",
  USUBJID = "01-701-1028",
  PARAMCD = c("XAN", "DOSE", "XAN", "XAN"),
  PARAM   = c("Pharmacokinetic concentration of Xanomeline",
              "Xanomeline Patch Dose",
              "Pharmacokinetic concentration of Xanomeline",
              "Pharmacokinetic concentration of Xanomeline"),
  AVISIT  = "Day 1",
  ATPT    = c("Pre-dose", "Dose", "5 Min Post-dose", "30 Min Post-dose"),
  NFRLT   = c(0, 0, 0.08333333, 0.5),
  AFRLT   = c(-0.5, 0, 0.08333333, 0.5),
  AVAL    = c(0.0, 54.0, 0.1015662, 0.5469018),
  AVALU   = c("ug/ml", "mg", "ug/ml", "ug/ml"),
  ABLFL   = c("Y", NA, NA, NA),
  ANL01FL = c("Y", "Y", "Y", "Y")
)
```
