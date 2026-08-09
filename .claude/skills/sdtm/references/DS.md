# DS — Disposition

> 数据来源：CDISC SDTMIG v3.4 (Events class) + pharmaverse `pharmaversesdtm::ds` 实际结构整理

## 数据集概览

| 项目 | 内容 |
|------|------|
| Domain | DS |
| 描述 | Disposition |
| Class | Events |
| Structure | One record per disposition event or protocol milestone per subject |
| Key Variables | STUDYID, USUBJID, DSDECOD, DSSTDTC |
| 备注 | DS 记录受试者在研究中的关键里程碑（随机化、完成等）及离组原因。DSCAT="PROTOCOL MILESTONE" 用于里程碑，DSCAT="DISPOSITION EVENT" 用于离组/终止原因，DSCAT="OTHER EVENT" 用于其他事件（如末次随访）。DSDECOD 为标准化术语。 |

---

## 变量列表

> 以下变量基于 `pharmaversesdtm::ds` 真实 `names()`，Label 取自各列 `attr(., "label")`。

| Variable | Label | Type | Core | Origin | Codelist | 说明 |
|----------|-------|------|------|--------|----------|------|
| STUDYID | Study Identifier | text | Req | Protocol | — | |
| DOMAIN | Domain Abbreviation | text | Req | Assigned | DS | 固定 "DS" |
| USUBJID | Unique Subject Identifier | text | Req | Derived | — | 关联回 DM |
| DSSEQ | Sequence Number | integer | Req | Derived | — | 域内唯一序号 |
| DSSPID | Sponsor-Defined Identifier | text | Perm | CRF | — | CRF 行号等 |
| DSTERM | Reported Term for the Disposition Event | text | Req | CRF | — | CRF 原始文本 |
| DSDECOD | Standardized Disposition Term | text | Req | Derived | DSDECOD | 标准化术语（见 Codelist） |
| DSCAT | Category for Disposition Event | text | Exp | Assigned | DSCAT | 见下方 Codelist |
| VISITNUM | Visit Number | float | Perm | Derived | — | |
| VISIT | Visit Name | text | Perm | Derived | — | |
| DSDTC | Date/Time of Collection | datetime | Perm | CRF | — | ISO 8601 |
| DSSTDTC | Start Date/Time of Disposition Event | datetime | Exp | CRF | — | 事件日期 |
| DSSTDY | Study Day of Start of Disposition Event | integer | Perm | Derived | — | 相对参照起始日 |

---

## Codelist 值

### DSCAT（Category，来自真实数据）
| 值 | 含义 |
|----|------|
| PROTOCOL MILESTONE | 研究里程碑（如随机化） |
| DISPOSITION EVENT | 离组/终止研究的事件 |
| OTHER EVENT | 其他事件（如末次实验室/检索访视） |

### DSDECOD（标准化术语，来自真实数据）
`RANDOMIZED` / `COMPLETED` / `FINAL LAB VISIT` / `ADVERSE EVENT` / `FINAL RETRIEVAL VISIT` / `STUDY TERMINATED BY SPONSOR` / `SCREEN FAILURE` / `DEATH` / `WITHDRAWAL BY SUBJECT` / `PHYSICIAN DECISION` / `PROTOCOL VIOLATION` / `LOST TO FOLLOW-UP` / `LACK OF EFFICACY`

---

## Dummy 数据示例（R，取自 pharmaversesdtm::ds 真实样本）

```r
library(tibble)

ds <- tibble(
  STUDYID  = "CDISCPILOT01",
  DOMAIN   = "DS",
  USUBJID  = c("01-701-1015", "01-701-1015", "01-701-1015", "01-701-1023"),
  DSSEQ    = c(1L, 2L, 3L, 1L),
  DSTERM   = c("RANDOMIZED", "PROTOCOL COMPLETED", "FINAL LAB VISIT",
               "RANDOMIZED"),
  DSDECOD  = c("RANDOMIZED", "COMPLETED", "FINAL LAB VISIT",
               "RANDOMIZED"),
  DSCAT    = c("PROTOCOL MILESTONE", "DISPOSITION EVENT", "OTHER EVENT",
               "PROTOCOL MILESTONE"),
  DSSTDTC  = c("2014-01-02", "2014-07-02", "2014-07-02", "2012-08-05")
)
```
