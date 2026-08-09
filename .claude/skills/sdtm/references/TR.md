# TR — Tumor/Lesion Results

> 数据来源：CDISC SDTMIG v3.4 (Findings class) + pharmaverse `pharmaversesdtm::tr_onco` 实际结构整理

## 数据集概览

| 项目 | 内容 |
|------|------|
| Domain | TR |
| 描述 | Tumor/Lesion Results |
| Class | Findings |
| Structure | One record per tumor measurement per lesion per time point per evaluator per subject |
| Key Variables | STUDYID, USUBJID, TRLNKID, TRTESTCD, TREVAL, VISITNUM |
| 备注 | TR 是肿瘤三联域之一（TU 识别病灶 → TR 测量病灶 → RS 总体评估）。TR 存储每次影像评估中各病灶的定量测量值（直径、最长径、垂直径、径线和等）。通过 TRLNKID 关联回 TU 中识别的病灶，通过 TRLNKGRP 关联 RS 的评估。TRTESTCD="SUMDIAM" 为目标病灶径线之和，是 RECIST 反应判定的关键。 |

---

## 变量列表

| Variable | Label | Type | Core | Origin | Codelist | 说明 |
|----------|-------|------|------|--------|----------|------|
| STUDYID | Study Identifier | text | Req | Protocol | — | |
| DOMAIN | Domain Abbreviation | text | Req | Assigned | — | 固定 "TR" |
| USUBJID | Unique Subject Identifier | text | Req | Derived | — | 关联回 DM |
| TRSEQ | Sequence Number | integer | Req | Derived | — | 受试者内唯一序号 |
| TRGRPID | Group ID | text | Perm | Assigned | — | 组标识 |
| TRLNKGRP | Link Group | text | Perm | Assigned | — | 关联 RS 同一次评估 |
| TRLNKID | Link ID | text | Perm | Assigned | — | 关联 TU.TULNKID（病灶编号） |
| TRTESTCD | Tumor Assessment Short Name | text | Req | Assigned | — | 测量短名，≤8 字符 |
| TRTEST | Tumor Assessment Test Name | text | Req | Assigned | — | 测量全名 |
| TRORRES | Result or Finding in Original Units | text | Exp | Collected | — | 原始测量值 |
| TRORRESU | Original Units | text | Exp | Collected | UNIT | 原始单位，如 mm |
| TRSTRESC | Character Result/Finding in Std Format | text | Exp | Derived | — | 标准化字符结果 |
| TRSTRESN | Numeric Result/Finding in Standard Units | float | Exp | Derived | — | 标准化数值结果 |
| TRSTRESU | Standard Units | text | Exp | Derived | UNIT | 标准单位 |
| TRSTAT | Completion Status | text | Perm | Collected | ND | NOT DONE |
| TRREASND | Reason Tumor Measurement Not Performed | text | Perm | Collected | — | 未测量原因 |
| TRMETHOD | Method used to Identify the Tumor | text | Exp | Collected | METHOD | 影像方法，如 CT SCAN |
| TREVAL | Evaluator | text | Exp | Assigned | EVAL | INVESTIGATOR / INDEPENDENT ASSESSOR |
| TREVALID | Evaluator Identifier | text | Perm | Assigned | MEDEVAL | 评审人标识 |
| TRACPTFL | Accepted Record Flag | text | Perm | Derived | NY | 多评审时被采纳的记录 |
| VISITNUM | Visit Number | float | Exp | Derived | — | 访视序号 |
| VISIT | Visit Name | text | Perm | Derived | — | 访视名称 |
| TRDTC | Date/Time of Tumor Measurement | datetime | Exp | Collected | — | 测量日期 |
| TRDY | Study Day of Tumor Measurement | integer | Perm | Derived | — | 相对参照日的研究日 |

---

## Codelist 值

### TRTESTCD / TRTEST（取自真实数据）
| TRTESTCD | TRTEST | 说明 |
|----------|--------|------|
| DIAMETER | Diameter | 直径 |
| LDIAM | Longest Diameter | 最长径（非淋巴结目标病灶） |
| LPERP | Longest Perpendicular | 最长垂直径 |
| SUMDIAM | Sum of Diameter | 径线之和（RECIST 反应判定关键） |
| TUMSTATE | Tumor State | 肿瘤状态 |

### TRMETHOD（影像方法）
`CT SCAN`（真实数据中使用）；其他常见：`MRI` / `PET-CT` / `PET SCAN` / `ULTRASOUND` / `PHYSICAL EXAMINATION`

### TREVAL
`INVESTIGATOR` / `INDEPENDENT ASSESSOR`

---

## Dummy 数据示例（R，取自 pharmaversesdtm::tr_onco 真实样本）

```r
library(tibble)

tr <- tibble(
  STUDYID  = "CDISCPILOT01",
  DOMAIN   = "TR",
  USUBJID  = "01-701-1015",
  TRSEQ    = 1:4,
  TRLNKGRP = "A1",
  TRLNKID  = c("T01", "T01", "T01", "T02"),
  TRTESTCD = c("DIAMETER", "LDIAM", "LPERP", "DIAMETER"),
  TRTEST   = c("Diameter", "Longest Diameter",
               "Longest Perpendicular", "Diameter"),
  TRORRES  = c("10", "10", "9", "16"),
  TRORRESU = "mm",
  TRSTRESN = c(10, 10, 9, 16),
  TRSTRESU = "mm",
  TRMETHOD = "CT SCAN",
  TREVAL   = "INVESTIGATOR",
  VISIT    = "BASELINE"
)
```
