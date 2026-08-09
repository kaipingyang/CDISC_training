# ADMH — Medical History Analysis Dataset

> 数据来源：CDISC ADaM IG v1.3（OCCDS 结构）+ pharmaverse `pharmaverseadam::admh` 实际结构整理

## 数据集概览

| 项目 | 内容 |
|------|------|
| 数据集名称 | ADMH |
| 描述 | Medical History Analysis Dataset |
| Class | OCCDS（Occurrence Data Structure） |
| Structure | One record per subject per medical history event（每条病史一条记录） |
| 用途 | 支持既往/现有病史汇总分析，包括按 SOC/PT 分类、首次出现标志、标准化 MedDRA 查询（SMQ）/自定义查询（CQ）分组等 |
| 主键 | STUDYID, USUBJID, MHSEQ |
| 备注 | 基于 SDTM MH 域衍生，并合并 ADSL 的受试者级别变量。前 60 个变量来自 ADSL，其余为 MH 域派生变量。SMQ/CQ 变量用于按预定义医学概念集分组病史事件。 |

---

## 变量列表（共 114 个变量，取自 `pharmaverseadam::admh`）

> 注：前 60 个变量（STUDYID … DTHCGR1）来自 ADSL 合并，Origin 记为 `ADSL`。以下重点说明 MH 域特有变量。

### ADSL 合并变量（受试者级别）

| Variable | Label | Type | Origin | 说明 |
|----------|-------|------|--------|------|
| STUDYID | Study Identifier | char | ADSL | |
| USUBJID | Unique Subject Identifier | char | ADSL | |
| SUBJID | Subject Identifier for the Study | char | ADSL | |
| SITEID | Study Site Identifier | char | ADSL | |
| COUNTRY | Country | char | ADSL | |
| DOMAIN | Domain Abbreviation | char | Predecessor | MH.DOMAIN |
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
| SAFFL | Safety Population Flag | char | ADSL | |
| ARM | Description of Planned Arm | char | ADSL | |
| ARMCD | Planned Arm Code | char | ADSL | |
| ACTARM | Description of Actual Arm | char | ADSL | |
| ACTARMCD | Actual Arm Code | char | ADSL | |
| TRTP | Planned Treatment | char | Derived | 计划治疗，通常等于 TRT01P |
| TRTA | Actual Treatment | char | Derived | 实际治疗，通常等于 TRT01A |
| TRT01P | Planned Treatment for Period 01 | char | ADSL | |
| TRT01A | Actual Treatment for Period 01 | char | ADSL | |
| TRTSDT | Date of First Exposure to Treatment | num (Date) | ADSL | |
| TRTSDTM | Datetime of First Exposure to Treatment | num (datetime) | ADSL | |
| TRTSTMF | Time of First Exposure Imput. Flag | char | ADSL | |
| TRTEDT | Date of Last Exposure to Treatment | num (Date) | ADSL | |
| TRTEDTM | Datetime of Last Exposure to Treatment | num (datetime) | ADSL | |
| TRTETMF | Treatment End Datetime Imput Flag | char | ADSL | |
| APHASE | Phase | char | Derived | 分析阶段 |
| APHASEN | Description of Phase N | num | Derived | APHASE 数值编码 |
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

### MH 域特有变量

| Variable | Label | Type | Origin | 说明 |
|----------|-------|------|--------|------|
| MHSEQ | Sequence Number | num | Predecessor | MH.MHSEQ，主键之一 |
| MHTERM | Reported Term for the Medical History | char | Predecessor | MH.MHTERM，原始报告病史术语 |
| MHTERMN | Medical History Term (N) | num | Derived | MHTERM 的数值编码 |
| MHDECOD | Dictionary-Derived Term | char | Predecessor | MedDRA PT（首选术语） |
| MHBODSYS | Body System or Organ Class | char | Predecessor | MedDRA SOC 系统器官分类 |
| MHLLT | Lowest Level Term | char | Predecessor | MedDRA 最低级别术语 |
| MHHLT | High Level Term | char | Predecessor | 高级别术语 |
| MHHLGT | High Level Group Term | char | Predecessor | 高级别组术语 |
| MHCAT | Category for Medical History | char | Predecessor | MH.MHCAT，病史类别（如 PRIMARY DIAGNOSIS/GENERAL） |
| MHSTDTC | Start Date/Time of Medical History Event | char | Predecessor | MH.MHSTDTC，病史开始日期（字符） |
| ASTDT | Analysis Start Date | num (Date) | Derived | `derive_vars_dt()` 解析 MHSTDTC，含部分日期插补 |
| MHENDTC | End Date/Time of Medical History Event | char | Predecessor | MH.MHENDTC，病史结束日期（字符） |
| AENDT | Analysis End Date | num (Date) | Derived | `derive_vars_dt()` 解析 MHENDTC |
| ASTDY | Analysis Start Relative Day | num | Derived | ASTDT 相对 TRTSDT 的研究日 |
| AENDY | Analysis End Relative Day | num | Derived | AENDT 相对 TRTSDT 的研究日 |
| MHOCCUR | Medical History Occurrence | char | Predecessor | 病史是否发生（Y/N），用于预设病史 |
| MHPRESP | Medical History Event Pre-Specified | char | Predecessor | 是否为预设病史项 |
| ANL01FL | Analysis Flag 01 | char | Derived | 标记纳入主要分析的记录，"Y" |
| AOCCFL | 1st Occurrence within Subject Flag | char | Derived | `derive_var_extreme_flag()`：受试者内首次出现记录标记 "Y" |
| AOCCPFL | 1st Occurrence of Preferred Term Flag | char | Derived | 受试者内某 PT 首次出现记录标记 "Y" |
| AOCCSFL | 1st Occurrence of SOC Flag | char | Derived | 受试者内某 SOC 首次出现记录标记 "Y" |
| MHSPID | Sponsor-Defined Identifier | char | Predecessor | MH.MHSPID |
| MHSEV | Severity/Intensity | char | Predecessor | 病史严重程度 |
| VISITNUM | Visit Number | num | Predecessor | MH.VISITNUM |
| VISIT | Visit Name | char | Predecessor | MH.VISIT |
| VISITDY | Planned Study Day of Visit | num | Predecessor | MH.VISITDY |
| MHDTC | Date/Time of History Collection | char | Predecessor | MH.MHDTC |
| MHDY | Study Day of History Collection | num | Predecessor | MH.MHDY |
| MHSTRTPT | Start Relative to Reference Time Point | char | Predecessor | 开始相对参考时间点 |
| MHENRTPT | End Relative to Reference Time Point | char | Predecessor | 结束相对参考时间点（如 ONGOING） |
| MHSTTPT | Start Reference Time Point | char | Predecessor | 开始参考时间点 |
| MHENTPT | End Reference Time Point | char | Predecessor | 结束参考时间点 |
| MHENRF | End Relative to Reference Period | char | Derived | 结束相对研究参考期（BEFORE/DURING/AFTER） |
| MHSTAT | Completion Status | char | Predecessor | 采集完成状态 |
| ADT | Analysis Date | num (Date) | Derived | 分析日期，通常取 ASTDT |
| ADY | Analysis Relative Day | num | Derived | ADT 相对 TRTSDT 的研究日 |
| SMQ02NAM | SMQ 02 Name | char | Assigned | 标准化 MedDRA 查询 02 名称，按 MedDRA 层级归入该 SMQ |
| SMQ02CD | SMQ 02 Code | num | Assigned | SMQ 02 编码 |
| SMQ02SC | SMQ 02 Scope | char | Assigned | SMQ 02 范围（BROAD/NARROW） |
| SMQ02SCN | SMQ 02 Scope (N) | num | Assigned | SMQ 02 范围数值编码 |
| SMQ03NAM | SMQ 03 Name | char | Assigned | 标准化 MedDRA 查询 03 名称 |
| SMQ03CD | SMQ 03 Code | num | Assigned | SMQ 03 编码 |
| SMQ03SC | SMQ 03 Scope | char | Assigned | SMQ 03 范围 |
| SMQ03SCN | SMQ 03 Scope (N) | num | Assigned | SMQ 03 范围数值编码 |
| SMQ05NAM | SMQ 05 Name | char | Assigned | 标准化 MedDRA 查询 05 名称 |
| SMQ05CD | SMQ 05 Code | num | Assigned | SMQ 05 编码 |
| SMQ05SC | SMQ 05 Scope | char | Assigned | SMQ 05 范围 |
| SMQ05SCN | SMQ 05 Scope (N) | num | Assigned | SMQ 05 范围数值编码 |
| CQ01NAM | Customized Query 01 Name | char | Assigned | 自定义查询 01 名称，按 sponsor 定义的术语集归组 |
| CQ04NAM | Customized Query 04 Name | char | Assigned | 自定义查询 04 名称 |
| CQ04CD | Customized Query 04 Code | num | Assigned | 自定义查询 04 编码 |
| AHIST | Response of Med Hx (past or current) | char | Derived | 病史状态（Past/Current），基于 MHENRF/结束时间点派生 |
| AOCPFL | 1st Occur w/in Trt Prd FL | char | Derived | 治疗期内受试者首次出现记录标记 "Y" |
| AOCPSFL | 1st Occur of SOC w/in Trt Prd FL | char | Derived | 治疗期内某 SOC 首次出现记录标记 "Y" |
| AOCPPFL | 1st Occur of PT w/in Trt Prd FL | char | Derived | 治疗期内某 PT 首次出现记录标记 "Y" |

---

## Dummy 数据示例（R，取自 pharmaverseadam::admh 真实样本）

```r
library(tibble)

admh <- tibble(
  STUDYID  = "CDISCPILOT01",
  USUBJID  = c("01-701-1015", "01-701-1023", "01-701-1028", "01-701-1033"),
  MHSEQ    = c(1, 1, 1, 1),
  MHTERM   = "ALZHEIMER'S DISEASE",
  MHCAT    = "PRIMARY DIAGNOSIS",
  AHIST    = "Past",
  MHENRF   = "BEFORE",
  ASTDT    = as.Date(c("2010-04-30", "2006-03-11", "2009-12-16", "2009-08-02")),
  ANL01FL  = c("Y", "Y", "Y", "Y"),
  AOCCFL   = c("Y", "Y", "Y", "Y"),
  TRTA     = c("Placebo", "Placebo", "Xanomeline High Dose", "Xanomeline Low Dose")
)
```
