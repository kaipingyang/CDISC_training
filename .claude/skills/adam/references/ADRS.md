# ADRS — Disease Response Analysis Dataset

> 数据来源：CDISC ADaM IG v1.3（BDS 章节）+ pharmaverse `admiralonco` 官方 ADRS vignette + `pharmaverseadam::adrs_onco` 实际结构整理。该测试数据基于 CDISC 公开的 **CDISCPILOT01** 研究，非任何真实公司/产品数据。

## 数据集概览

| 项目 | 内容 |
|------|------|
| 数据集名称 | ADRS |
| 描述 | Disease Response Analysis Dataset |
| Class | BDS (Basic Data Structure) |
| Structure | One record per subject per analysis parameter (per visit for visit-level response) |
| 用途 | 分析肿瘤缓解（Response）终点：总体缓解（OVR）、最佳总体缓解（BOR/CBOR）、确认缓解、临床获益、疾病进展等，供 ORR/DCR 疗效表和 ADTTE（PFS/DOR）派生使用 |
| 主键 | STUDYID, USUBJID, PARAMCD, ADT（visit-level 参数含 AVISIT/VISITNUM） |
| 备注 | 基于 SDTM **RS**（Disease Response）域衍生，合并 ADSL 的受试者级变量。`admiralonco` 官方 vignette（`vignette("adrs")`）演示了 RECIST 1.1 下 BOR、确认缓解、临床获益等参数的标准派生方法。保留 ADSL 全部受试者。 |

---

## 变量列表（共 79 个变量，取自 `pharmaverseadam::adrs_onco`）

> 前段（STUDYID … DTHCGR1）为从 **ADSL** 带入的受试者级变量，Origin 记为 Predecessor(ADSL)；中段为 BDS 分析变量；末段（RSTESTCD … RSSEQ）为从 **RS** 域带入的采集变量。

| Variable | Label | Type | Origin | 说明 |
|----------|-------|------|--------|------|
| STUDYID | Study Identifier | char | Predecessor(ADSL) | 研究标识 |
| USUBJID | Unique Subject Identifier | char | Predecessor(ADSL) | 受试者唯一标识 |
| SUBJID | Subject Identifier for the Study | char | Predecessor(ADSL) | 研究内受试者编号 |
| SITEID | Study Site Identifier | char | Predecessor(ADSL) | 中心编号 |
| COUNTRY | Country | char | Predecessor(ADSL) | 国家 |
| DOMAIN | Domain Abbreviation | char | Predecessor(RS) | 域缩写（RS） |
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
| ASEQ | Analysis Sequence Number | num | Derived | 分析序号，`derive_var_obs_number()` |
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
| ADT | Analysis Date | num (Date) | Derived | 分析日期，`derive_vars_dt()` 解析 RS.RSDTC；BOR 等派生参数取对应评估日期 |
| ADTF | Analysis Date Imputation Flag | char | Derived | ADT 日期插补标志 |
| AVISIT | Analysis Visit | char | Derived | 分析访视（如 WEEK 9）；visit-level 参数填充，整体缓解类参数可为空 |
| PARAM | Parameter | char | Assigned | 参数描述（见下方参数说明） |
| PARAMCD | Parameter Code | char | Assigned | 参数代码（见下方参数说明） |
| PARCAT1 | Parameter Category 1 | char | Assigned | 参数大类，如 "Tumor Response" / "Reference Event" |
| PARCAT2 | Parameter Category 2 | char | Assigned | 评估者类别，如 "Investigator" |
| PARCAT3 | Parameter Category 3 | char | Assigned | 参数子类（可选，如缓解标准版本） |
| AVAL | Analysis Value | num | Derived | 数值分析值（与 AVALC 顺序对应，如 CR=1、PR=2…；标志类 Y=1/N=0） |
| AVALC | Analysis Value (C) | char | Derived | 字符分析值，如 CR/PR/SD/PD/NE、Y/N |
| ANL01FL | Analysis Flag 01 | char | Derived | 主分析记录标志 |
| ANL02FL | Analysis Flag 02 | char | Derived | 次分析记录标志 |
| VISITNUM | Visit Number | num | Predecessor(RS) | 访视编号（visit-level 参数） |
| VISIT | Visit Name | char | Predecessor(RS) | 访视名称（visit-level 参数） |
| RSTESTCD | Assessment Short Name | char | Predecessor(RS) | RS.RSTESTCD，评估短名（如 OVRLRESP） |
| RSTEST | Assessment Name | char | Predecessor(RS) | RS.RSTEST，评估全名 |
| RSORRES | Result or Finding in Original Units | char | Predecessor(RS) | RS.RSORRES，原始结果 |
| RSSTRESC | Character Result/Finding in Std Format | char | Predecessor(RS) | RS.RSSTRESC，标准化字符结果 |
| RSEVAL | Evaluator | char | Predecessor(RS) | RS.RSEVAL，评估者（如 INVESTIGATOR） |
| RSEVALID | Evaluator Identifier | char | Predecessor(RS) | RS.RSEVALID，评估者标识 |
| RSACPTFL | Accepted Record Flag | char | Predecessor(RS) | RS.RSACPTFL，采纳记录标志 |
| RSDTC | Date/Time of Assessment | char | Predecessor(RS) | RS.RSDTC，评估日期 |
| RSSEQ | Sequence Number | num | Predecessor(RS) | RS.RSSEQ，源记录序号 |
| DTHDTF | Date of Death Imputation Flag | char | Predecessor(ADSL) | 死亡日期插补标志 |

### 关键参数（PARAMCD）说明

| PARAMCD | PARAM | 含义 |
|---------|-------|------|
| OVR | Overall Response by Investigator | 各访视的总体缓解（CR/PR/SD/PD/NE） |
| BOR | Best Overall Response by Investigator (confirmation not required) | 最佳总体缓解（无需确认） |
| CBOR | Best Confirmed Overall Response by Investigator | 确认后最佳总体缓解 |
| RSP / CRSP | Response / Confirmed Response by Investigator | 缓解者标志（BOR 达 CR/PR） |
| CB / CCB | Clinical Benefit / Confirmed Clinical Benefit | 临床获益标志 |
| PD | Disease Progression by Investigator | 疾病进展事件 |
| DEATH | Death | 死亡参考事件 |
| MDIS | Measurable Disease at Baseline | 基线可测量病灶标志 |
| LSTA | Last Disease Assessment by Investigator | 末次疾病评估 |

---

## Dummy 数据示例（R，取自 pharmaverseadam::adrs_onco 真实样本）

```r
library(tibble)

adrs <- tribble(
  ~STUDYID,       ~USUBJID,      ~PARAMCD, ~PARAM,                                 ~AVISIT,  ~ADT,         ~AVALC, ~AVAL, ~PARCAT1,         ~PARCAT2,       ~ANL01FL,
  "CDISCPILOT01", "01-701-1015", "OVR",    "Overall Response by Investigator",     "WEEK 9", "2014-03-06", "CR",       1, "Tumor Response", "Investigator", "Y",
  "CDISCPILOT01", "01-701-1015", "BOR",    "Best Overall Response by Investigator","WEEK 9", "2014-03-06", "CR",       1, "Tumor Response", "Investigator", "Y",
  "CDISCPILOT01", "01-701-1015", "RSP",    "Response by Investigator",              NA,       NA,           "Y",        1, "Tumor Response", "Investigator", "Y",
  "CDISCPILOT01", "01-701-1015", "PD",     "Disease Progression by Investigator",   NA,       NA,           "N",        0, "Reference Event",NA,             "Y",
  "CDISCPILOT01", "01-701-1023", "BOR",    "Best Overall Response by Investigator", "WEEK 6", "2012-09-01", "SD",       3, "Tumor Response", "Investigator", "Y",
  "CDISCPILOT01", "01-701-1028", "BOR",    "Best Overall Response by Investigator", "WEEK 9", "2013-08-30", "PD",       5, "Tumor Response", "Investigator", "Y"
) |>
  dplyr::mutate(ADT = as.Date(ADT))
```
