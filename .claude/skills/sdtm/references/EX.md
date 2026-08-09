# EX — Exposure

> 数据来源：CDISC SDTMIG v3.4 (Interventions class) + pharmaverse `pharmaversesdtm::ex` 实际结构整理

## 数据集概览

| 项目 | 内容 |
|------|------|
| Domain | EX |
| 描述 | Exposure |
| Class | Interventions |
| Structure | One record per constant-dosing interval per treatment per subject |
| Key Variables | STUDYID, USUBJID, EXTRT, EXSTDTC |
| 备注 | EX 记录受试者实际暴露于研究药物的情况（剂量、剂型、频率、给药途径及起止日期）。每个恒定剂量区间一条记录，剂量变化时开启新记录。DM 中的 RFXSTDTC/RFXENDTC 由 EX 的 EXSTDTC/EXENDTC 派生。 |

---

## 变量列表

| Variable | Label | Type | Core | Origin | Codelist | 说明 |
|----------|-------|------|------|--------|----------|------|
| STUDYID | Study Identifier | text | Req | Protocol | — | |
| DOMAIN | Domain Abbreviation | text | Req | Assigned | — | 固定 "EX" |
| USUBJID | Unique Subject Identifier | text | Req | Derived | — | 关联回 DM |
| EXSEQ | Sequence Number | integer | Req | Derived | — | 同一受试者内唯一序号 |
| EXTRT | Name of Actual Treatment | text | Req | CRF | — | 实际给药名称 |
| EXDOSE | Dose per Administration | float | Exp | CRF | — | 每次给药剂量（数值） |
| EXDOSU | Dose Units | text | Exp | CRF | UNIT | 剂量单位（如 mg） |
| EXDOSFRM | Dose Form | text | Perm | CRF | FRM | 剂型（如 PATCH、TABLET、INJECTION） |
| EXDOSFRQ | Dosing Frequency per Interval | text | Perm | CRF | FREQ | 给药频率（如 QD、BID） |
| EXROUTE | Route of Administration | text | Perm | CRF | ROUTE | 给药途径（如 TRANSDERMAL、ORAL） |
| VISITNUM | Visit Number | float | Perm | Derived | — | 访视编号 |
| VISIT | Visit Name | text | Perm | Assigned | — | 访视名称 |
| VISITDY | Planned Study Day of Visit | integer | Perm | Protocol | — | 计划研究日 |
| EXSTDTC | Start Date/Time of Treatment | datetime | Exp | CRF | — | 给药开始日期 ISO 8601 |
| EXENDTC | End Date/Time of Treatment | datetime | Exp | CRF | — | 给药结束日期 |
| EXSTDY | Study Day of Start of Treatment | integer | Perm | Derived | — | 相对参照日期的研究日 |
| EXENDY | Study Day of End of Treatment | integer | Perm | Derived | — | |

---

## Codelist 值

### EXROUTE（给药途径，常见值）
`TRANSDERMAL` / `ORAL` / `INTRAVENOUS` / `SUBCUTANEOUS` / `INTRAMUSCULAR` / `TOPICAL` / `INHALATION`

### EXDOSFRM（剂型，常见值）
`PATCH` / `TABLET` / `CAPSULE` / `INJECTION` / `SOLUTION` / `POWDER`

### EXDOSFRQ（给药频率，常见值）
`QD`（每日一次）/ `BID`（每日两次）/ `TID`（每日三次）/ `QW`（每周一次）/ `ONCE`（单次）

---

## Dummy 数据示例（R，取自 pharmaversesdtm::ex 真实样本）

```r
library(tibble)

ex <- tibble(
  STUDYID  = "CDISCPILOT01",
  DOMAIN   = "EX",
  USUBJID  = c("01-701-1015", "01-701-1015", "01-701-1015", "01-701-1023"),
  EXSEQ    = c(1L, 2L, 3L, 1L),
  EXTRT    = "PLACEBO",
  EXDOSE   = 0,
  EXDOSU   = "mg",
  EXDOSFRM = "PATCH",
  EXDOSFRQ = "QD",
  EXROUTE  = "TRANSDERMAL",
  EXSTDTC  = c("2014-01-02", "2014-01-17", "2014-06-19", "2012-08-05"),
  EXENDTC  = c("2014-01-16", "2014-06-18", "2014-07-02", "2012-08-27")
)
```
