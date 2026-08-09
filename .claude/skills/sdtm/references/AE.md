# AE — Adverse Events

> 数据来源：CDISC SDTMIG v3.4 (Events class) + pharmaverse `pharmaversesdtm::ae` 实际结构整理

## 数据集概览

| 项目 | 内容 |
|------|------|
| Domain | AE |
| 描述 | Adverse Events |
| Class | Events |
| Structure | One record per adverse event per subject |
| Key Variables | STUDYID, USUBJID, AEDECOD, AESTDTC |
| 备注 | AE 记录受试者在研究期间发生的不良事件。AETERM 为研究者原始报告术语，经 MedDRA 词典编码衍生出 AEDECOD、AEBODSYS 等标准术语及层级。注意区分「严重事件」（AESER，是否达到 SAE 判定标准）与「严重程度」（AESEV，MILD/MODERATE/SEVERE），二者是不同概念。 |

---

## 变量列表

| Variable | Label | Type | Core | Origin | Codelist | 说明 |
|----------|-------|------|------|--------|----------|------|
| STUDYID | Study Identifier | text | Req | Protocol | — | |
| DOMAIN | Domain Abbreviation | text | Req | Assigned | — | 固定 "AE" |
| USUBJID | Unique Subject Identifier | text | Req | Derived | — | 关联回 DM |
| AESEQ | Sequence Number | integer | Req | Derived | — | 同一受试者内唯一序号 |
| AESPID | Sponsor-Defined Identifier | text | Perm | CRF | — | CRF 上的行标识 |
| AETERM | Reported Term for the Adverse Event | text | Req | CRF | — | 研究者原始报告术语 |
| AELLT | Lowest Level Term | text | Perm | Derived | MedDRA | MedDRA LLT |
| AELLTCD | Lowest Level Term Code | integer | Perm | Derived | MedDRA | MedDRA LLT Code |
| AEDECOD | Dictionary-Derived Term | text | Req | Derived | MedDRA | MedDRA Preferred Term |
| AEPTCD | Preferred Term Code | integer | Perm | Derived | MedDRA | MedDRA PT Code |
| AEHLT | High Level Term | text | Perm | Derived | MedDRA | MedDRA HLT |
| AEHLTCD | High Level Term Code | integer | Perm | Derived | MedDRA | |
| AEHLGT | High Level Group Term | text | Perm | Derived | MedDRA | MedDRA HLGT |
| AEHLGTCD | High Level Group Term Code | integer | Perm | Derived | MedDRA | |
| AEBODSYS | Body System or Organ Class | text | Exp | Derived | MedDRA | 报告用 SOC |
| AEBDSYCD | Body System or Organ Class Code | integer | Perm | Derived | MedDRA | |
| AESOC | Primary System Organ Class | text | Perm | Derived | MedDRA | 主要 SOC |
| AESOCCD | Primary System Organ Class Code | integer | Perm | Derived | MedDRA | |
| AESEV | Severity/Intensity | text | Perm | CRF | AESEV | MILD / MODERATE / SEVERE |
| AESER | Serious Event | text | Exp | CRF | NY | Y / N，是否为严重事件 |
| AEACN | Action Taken with Study Treatment | text | Perm | CRF | ACN | 对研究药物采取的措施 |
| AEREL | Causality | text | Exp | CRF | — | 与研究药物的因果关系 |
| AEOUT | Outcome of Adverse Event | text | Perm | CRF | OUT | 事件转归 |
| AESCAN | Involves Cancer | text | Perm | CRF | NY | 严重性判定标准之一 |
| AESCONG | Congenital Anomaly or Birth Defect | text | Perm | CRF | NY | |
| AESDISAB | Persist or Signif Disability/Incapacity | text | Perm | CRF | NY | |
| AESDTH | Results in Death | text | Perm | CRF | NY | |
| AESHOSP | Requires or Prolongs Hospitalization | text | Perm | CRF | NY | |
| AESLIFE | Is Life Threatening | text | Perm | CRF | NY | |
| AESOD | Occurred with Overdose | text | Perm | CRF | NY | |
| AEDTC | Date/Time of Collection | datetime | Perm | CRF | — | ISO 8601 |
| AESTDTC | Start Date/Time of Adverse Event | datetime | Exp | CRF | — | 事件开始日期 |
| AEENDTC | End Date/Time of Adverse Event | datetime | Perm | CRF | — | 事件结束日期（ongoing 则为空） |
| AESTDY | Study Day of Start of Adverse Event | integer | Perm | Derived | — | 相对参照日期的研究日 |
| AEENDY | Study Day of End of Adverse Event | integer | Perm | Derived | — | |

---

## Codelist 值

### AESEV（严重程度）
`MILD` / `MODERATE` / `SEVERE`

### AESER 及各严重性标准（NY）
`Y` / `N`

### AEACN（对研究药物采取的措施）
`DOSE NOT CHANGED` / `DOSE REDUCED` / `DOSE INCREASED` / `DRUG INTERRUPTED` / `DRUG WITHDRAWN` / `NOT APPLICABLE` / `UNKNOWN`

### AEOUT（转归）
`RECOVERED/RESOLVED` / `RECOVERING/RESOLVING` / `NOT RECOVERED/NOT RESOLVED` / `RECOVERED/RESOLVED WITH SEQUELAE` / `FATAL` / `UNKNOWN`

### AEREL（因果关系；具体取值由研究方案定义，示例文字值）
如 `NOT RELATED` / `REMOTE` / `POSSIBLE` / `PROBABLE` / `RELATED`

---

## Dummy 数据示例（R，取自 pharmaversesdtm::ae 真实样本）

```r
library(tibble)

ae <- tibble(
  STUDYID  = "CDISCPILOT01",
  DOMAIN   = "AE",
  USUBJID  = c("01-701-1015", "01-701-1015", "01-701-1015", "01-701-1023"),
  AESEQ    = c(1L, 2L, 3L, 3L),
  AETERM   = c("APPLICATION SITE ERYTHEMA", "APPLICATION SITE PRURITUS",
               "DIARRHOEA", "ATRIOVENTRICULAR BLOCK SECOND DEGREE"),
  AEDECOD  = c("APPLICATION SITE ERYTHEMA", "APPLICATION SITE PRURITUS",
               "DIARRHOEA", "ATRIOVENTRICULAR BLOCK SECOND DEGREE"),
  AEBODSYS = c("GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS",
               "GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS",
               "GASTROINTESTINAL DISORDERS", "CARDIAC DISORDERS"),
  AESEV    = c("MILD", "MILD", "MILD", "MILD"),
  AESER    = c("N", "N", "N", "N"),
  AEREL    = c("PROBABLE", "PROBABLE", "REMOTE", "POSSIBLE"),
  AEOUT    = c("NOT RECOVERED/NOT RESOLVED", "NOT RECOVERED/NOT RESOLVED",
               "RECOVERED/RESOLVED", "NOT RECOVERED/NOT RESOLVED"),
  AESTDTC  = c("2014-01-03", "2014-01-03", "2014-01-09", "2012-08-26")
)
```
