# PP — Pharmacokinetics Parameters

> 数据来源：CDISC SDTMIG v3.4 (Findings class) + pharmaverse `pharmaversesdtm::pp` 实际结构整理

## 数据集概览

| 项目 | 内容 |
|------|------|
| Domain | PP |
| 描述 | Pharmacokinetics Parameters |
| Class | Findings |
| Structure | One record per PK parameter per analyte per subject |
| Key Variables | STUDYID, USUBJID, PPTESTCD, PPCAT |
| 备注 | PP 存储由 PC 浓度数据经非房室分析（NCA）推导的药代动力学参数，如 AUC、Cmax、Tmax、半衰期等。PPCAT 通常为分析物名称。PPRFDTC 为参考时间点（参照给药时间），用于时间相关参数的计算基准。 |

---

## 变量列表

| Variable | Label | Type | Core | Origin | Codelist | 说明 |
|----------|-------|------|------|--------|----------|------|
| STUDYID | Study Identifier | text | Req | Protocol | — | |
| DOMAIN | Domain Abbreviation | text | Req | Assigned | — | 固定 "PP" |
| USUBJID | Unique Subject Identifier | text | Req | Derived | — | 关联回 DM |
| PPSEQ | Sequence Number | integer | Req | Derived | — | 受试者内唯一序号 |
| PPTESTCD | Parameter Short Name | text | Req | Assigned | — | 参数短名，≤8 字符 |
| PPTEST | Parameter Name | text | Req | Assigned | — | 参数全名 |
| PPCAT | Parameter Category | text | Exp | Assigned | — | 分析物名称/参数类别 |
| PPORRES | Result or Finding in Original Units | text | Exp | Derived | — | 原始参数值 |
| PPORRESU | Original Units | text | Exp | Derived | UNIT | 原始单位 |
| PPSTRESC | Character Result/Finding in Std Format | text | Exp | Derived | — | 标准化字符结果 |
| PPSTRESN | Numeric Result/Finding in Standard Units | float | Exp | Derived | — | 标准化数值结果 |
| PPSTRESU | Standard Units | text | Exp | Derived | UNIT | 标准单位 |
| PPSPEC | Specimen Material Type | text | Exp | Collected | SPECTYPE | 样本类型，如 PLASMA/URINE |
| PPRFDTC | Date/Time of Reference Point | datetime | Perm | Derived | — | 参考时间点日期（通常为给药时间） |

---

## Codelist 值

### PPTESTCD（PK 参数代码，节选自真实数据 + CDISC CT）
| PPTESTCD | 含义 | 常见单位 |
|----------|------|----------|
| CMAX | Maximum Observed Concentration | ug/ml |
| TMAX | Time of Maximum Concentration | h |
| AUCALL | AUC All | h*ug/ml |
| AUCLST | AUC to Last Quantifiable Concentration | h*ug/ml |
| CLST | Last Quantifiable Concentration | ug/ml |
| LAMZ | Lambda z（末端消除速率常数） | 1/h |
| LAMZHL | Lambda z Half-Life（末端半衰期） | h |
| LAMZNPT | Number of Points for Lambda z | — |
| RCAMINT | Amount Recovered in Urine | — |
| RENALCL | Renal Clearance | — |

### PPSPEC（样本类型）
`PLASMA` / `URINE`

---

## Dummy 数据示例（R，取自 pharmaversesdtm::pp 真实样本）

```r
library(tibble)

pp <- tibble(
  STUDYID  = "CDISCPILOT01",
  DOMAIN   = "PP",
  USUBJID  = "01-701-1028",
  PPSEQ    = 1:4,
  PPTESTCD = c("AUCALL", "CMAX", "TMAX", "LAMZHL"),
  PPTEST   = c("AUC All", "Max Conc", "Time of CMAX", "Half-Life Lambda z"),
  PPCAT    = "XANOMELINE",
  PPORRES  = c("18.121041", "1.771855", "8.000000", "2.170072"),
  PPORRESU = c("h*ug/ml", "ug/ml", "h", "h"),
  PPSTRESN = c(18.121041, 1.771855, 8.000000, 2.170072),
  PPSTRESU = c("h*ug/ml", "ug/ml", "h", "h"),
  PPSPEC   = "PLASMA",
  PPRFDTC  = "2013-07-19"
)
```
