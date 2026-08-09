# CM — Concomitant/Prior Medications

> 数据来源：CDISC SDTMIG v3.4 (Interventions class) + pharmaverse `pharmaversesdtm::cm` 实际结构整理

## 数据集概览

| 项目 | 内容 |
|------|------|
| Domain | CM |
| 描述 | Concomitant/Prior Medications |
| Class | Interventions |
| Structure | One record per medication intervention episode per subject |
| Key Variables | STUDYID, USUBJID, CMTRT, CMSTDTC |
| 备注 | CM 记录受试者在研究期间及研究前使用的合并用药与既往用药。CMTRT 为 CRF 原始录入的药物名称，CMDECOD 为经字典（如 WHO Drug）编码后的标准名称。既往用药（Prior）与合并用药（Concomitant）通过 CMSTDTC/CMENDTC 与治疗参照日期比较区分。 |

---

## 变量列表

> 以下变量基于 `pharmaversesdtm::cm` 真实 `names()`，Label 取自各列 `attr(., "label")`。

| Variable | Label | Type | Core | Origin | Codelist | 说明 |
|----------|-------|------|------|--------|----------|------|
| STUDYID | Study Identifier | text | Req | Protocol | — | |
| DOMAIN | Domain Abbreviation | text | Req | Assigned | CM | 固定 "CM" |
| USUBJID | Unique Subject Identifier | text | Req | Derived | — | 关联回 DM |
| CMSEQ | Sequence Number | integer | Req | Derived | — | 域内唯一序号 |
| CMSPID | Sponsor-Defined Identifier | text | Perm | CRF | — | CRF 行号等 |
| CMTRT | Reported Name of Drug, Med, or Therapy | text | Req | CRF | — | 原始录入名 |
| CMDECOD | Standardized Medication Name | text | Perm | Derived | — | 字典编码标准名（WHO Drug） |
| CMINDC | Indication | text | Perm | CRF | — | 用药指征 |
| CMCLAS | Medication Class | text | Perm | Derived | — | 药理分类（如 ATC） |
| CMDOSE | Dose per Administration | float | Perm | CRF | — | 单次剂量 |
| CMDOSU | Dose Units | text | Perm | CRF | UNIT | 剂量单位 |
| CMDOSFRQ | Dosing Frequency per Interval | text | Perm | CRF | FREQ | 给药频率 |
| CMROUTE | Route of Administration | text | Perm | CRF | ROUTE | 给药途径 |
| VISITNUM | Visit Number | float | Perm | Derived | — | |
| VISIT | Visit Name | text | Perm | Derived | — | |
| VISITDY | Planned Study Day of Visit | integer | Perm | Protocol | — | |
| CMDTC | Date/Time of Collection | datetime | Perm | CRF | — | ISO 8601 |
| CMSTDTC | Start Date/Time of Medication | datetime | Exp | CRF | — | 开始日期，可为部分日期 |
| CMENDTC | End Date/Time of Medication | datetime | Exp | CRF | — | 结束日期，正在服用可为空 |
| CMSTDY | Study Day of Start of Medication | integer | Perm | Derived | — | 相对参照起始日 |
| CMENDY | Study Day of End of Medication | integer | Perm | Derived | — | |
| CMENRTPT | End Relative to Reference Time Point | text | Perm | CRF | STENRF | 与参照点关系，如 ONGOING |

---

## Codelist 值

### CMDOSFRQ（Dosing Frequency，节选自真实数据）
`QD` / `BID` / `TID` / `QID` / `PRN` / `ONCE` / `Q3H` / `Q4H` / `Q6H` / `EVERY NIGHT` / `OTHER`

### CMROUTE（Route，节选自真实数据）
`ORAL` / `INTRAVENOUS` / `INTRAMUSCULAR` / `SUBCUTANEOUS` / `TOPICAL` / `TRANSDERMAL` / `SUBLINGUAL` / `NASAL` / `OPHTHALMIC` / `RESPIRATORY (INHALATION)` / `RECTAL` / `VAGINAL` / `AURICULAR (OTIC)`

### CMENRTPT（End Relative to Reference Time Point）
`BEFORE` / `ONGOING` / `AFTER` / `U`

---

## Dummy 数据示例（R，取自 pharmaversesdtm::cm 真实样本）

```r
library(tibble)

cm <- tibble(
  STUDYID  = "CDISCPILOT01",
  DOMAIN   = "CM",
  USUBJID  = c("01-701-1015", "01-701-1015", "01-701-1023", "01-701-1028"),
  CMSEQ    = c(1L, 2L, 1L, 1L),
  CMTRT    = c("ASPIRIN", "PARACETAMOL", "METFORMIN", "ATORVASTATIN"),
  CMDECOD  = c("ACETYLSALICYLIC ACID", "PARACETAMOL",
               "METFORMIN HYDROCHLORIDE", "ATORVASTATIN CALCIUM"),
  CMDOSE   = c(1, 500, 850, 20),
  CMDOSU   = c("TABLET", "mg", "mg", "mg"),
  CMDOSFRQ = c("PRN", "TID", "BID", "QD"),
  CMROUTE  = c("ORAL", "ORAL", "ORAL", "ORAL"),
  CMSTDTC  = c("2003", "2013-01-15", "2011", "2012-05"),
  CMENDTC  = c(NA, "2013-01-18", NA, NA)
)
```
