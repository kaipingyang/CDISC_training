# SUPPQUAL — Supplemental Qualifiers

> 基于 CDISC SDTMIG v3.4 SUPPQUAL 结构整理

---

## What is SUPPQUAL

SUPPQUAL (Supplemental Qualifiers) datasets hold **additional variables** that cannot fit within the standard 8-character limit of the parent domain, or that are not defined in the SDTMIG for that domain. They are always in **tall/long format**: one row per qualifier per parent record.

Naming: `SUPP` + parent domain abbreviation (e.g., `SUPPAE`, `SUPPLB`, `SUPPDM`)

---

## Fixed 10-Variable Structure

Every SUPP dataset has exactly these 10 variables — no more, no less:

| Variable | Type | Role | Core | Label | Notes |
|----------|------|------|------|-------|-------|
| STUDYID | text | Identifier | Req | Study Identifier | From parent domain |
| RDOMAIN | text | Identifier | Req | Related Domain Abbreviation | 2-char domain code (e.g., "AE") |
| USUBJID | text | Identifier | Req | Unique Subject Identifier | From parent domain |
| IDVAR | text | Identifier | Exp | Identifying Variable | Name of the key variable in parent (e.g., "AESEQ") |
| IDVARVAL | text | Identifier | Exp | Identifying Variable Value | Value of IDVAR for the parent record |
| QNAM | text | Topic | Req | Qualifier Variable Name | Short name (≤8 chars, uppercase, no special chars) |
| QLABEL | text | Synonym Qualifier | Req | Qualifier Variable Label | Long name (≤40 chars) |
| QVAL | text | Result | Req | Data Value | The actual value; cannot be null |
| QORIG | text | Result Qualifier | Req | Origin | e.g., "CRF" or "DERIVED" |
| QEVAL | text | Record Qualifier | Perm | Evaluator | If applicable (e.g., "CLINICAL STUDY SPONSOR") |

---

## How SUPPQUAL Links to Parent Domain

```
Parent domain (e.g., AE):
  STUDYID = "CDISCPILOT01"
  USUBJID = "01-701-1015"
  AESEQ = 1
  AETERM = "APPLICATION SITE ERYTHEMA"
  ... (standard AE variables)

SUPPAE:
  STUDYID  = "CDISCPILOT01"
  RDOMAIN  = "AE"              ← fixed = parent domain
  USUBJID  = "01-701-1015"     ← same subject
  IDVAR    = "AESEQ"           ← which key variable to use
  IDVARVAL = "1"               ← value of that key (AESEQ=1)
  QNAM     = "AETRTEM"         ← supplemental variable name
  QLABEL   = "TREATMENT EMERGENT FLAG"
  QVAL     = "Y"               ← the actual value
  QORIG    = "DERIVED"
  QEVAL    = "CLINICAL STUDY SPONSOR"
```

---

## IDVAR Rules

- IDVAR is almost always `--SEQ` (e.g., `AESEQ`, `LBSEQ`)
- IDVARVAL must be the **character representation** of the value (e.g., `"1"` not `1`)
- If no `--SEQ` exists (e.g., DM at subject level), IDVAR and IDVARVAL are left null and the link is made on USUBJID alone

---

## QNAM Rules

- ≤ 8 characters
- Uppercase
- Letters, digits, underscores only
- Cannot start with a digit
- Must be unique within each SUPP dataset

---

## 常见 SUPP 变量示例

以下为 CDISC 通用示例（取自 pharmaversesdtm 公开 pilot 数据），仅作结构演示，
实际 QNAM 取决于各研究收集内容与相应 CDISC Controlled Terminology。

### SUPPDM 示例（subject-level flags）

| QNAM | QLABEL | Description |
|------|--------|-------------|
| EFFICACY | Efficacy Population Flag | 分析人群标识（Y/N）|
| COMPLT16 | Completers of Week 16 Population Flag | 完成第 16 周人群标识 |
| ITT | Intent to Treat Population Flag | ITT 人群标识 |
| SAFETY | Safety Population Flag | 安全性人群标识 |

### SUPPAE 示例（record-level qualifiers）

| QNAM | QLABEL | Description |
|------|--------|-------------|
| AETRTEM | Treatment Emergent Flag | TEAE 标识（Y/N）|

（QVAL 为对应取值，如 "Y"；QORIG 常为 "DERIVED"；QEVAL 常为 "CLINICAL STUDY SPONSOR"。）

---

## SUPPQUAL vs. FA Domain

Before creating a SUPP variable, consider if the data should instead go into:
- **FA (Findings About)** — for yes/no or assessment-type data about a specific parent record event
- **SUPPQUAL** — for additional collected attributes that belong to the parent record

SUPPQUAL is preferred when the value directly describes the parent record attribute (not a separate assessment of it).

---

## R Code: Reconstruct SUPPQUAL View

Merge SUPP back to parent for analysis:

```r
library(dplyr)
library(tidyr)

# Pivot SUPPAE to wide (one row per AE record)
suppae_wide <- suppae %>%
  select(STUDYID, RDOMAIN, USUBJID, IDVAR, IDVARVAL, QNAM, QVAL) %>%
  pivot_wider(
    id_cols = c(STUDYID, USUBJID, IDVAR, IDVARVAL),
    names_from = QNAM,
    values_from = QVAL
  ) %>%
  mutate(AESEQ = as.integer(IDVARVAL)) %>%
  select(-IDVAR, -IDVARVAL)

# Join to AE
ae_full <- ae %>%
  left_join(suppae_wide, by = c("STUDYID", "USUBJID", "AESEQ"))
```
