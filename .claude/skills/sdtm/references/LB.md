# LB — Laboratory Test Results

> 数据来源：CDISC SDTMIG v3.4 (Findings class) + pharmaverse `pharmaversesdtm::lb` 实际结构整理

## 数据集概览

| 项目 | 内容 |
|------|------|
| Domain | LB |
| 描述 | Laboratory Test Results |
| Class | Findings |
| Structure | One record per lab test per time point per subject |
| Key Variables | STUDYID, USUBJID, LBTESTCD, VISITNUM, LBDTC |
| 备注 | LB 是典型 Findings 结构：原始值（LBORRES/LBORRESU）+ 标准化值（LBSTRESC/LBSTRESN/LBSTRESU）+ 参考范围（LBORNRLO/LBORNRHI 及标准单位版本）+ 参考范围指示（LBNRIND）。标准化到统一单位后才能跨中心汇总分析。 |

---

## 变量列表

| Variable | Label | Type | Core | Origin | Codelist | 说明 |
|----------|-------|------|------|--------|----------|------|
| STUDYID | Study Identifier | text | Req | Protocol | — | |
| DOMAIN | Domain Abbreviation | text | Req | Assigned | — | 固定 "LB" |
| USUBJID | Unique Subject Identifier | text | Req | Derived | — | 关联回 DM |
| LBSEQ | Sequence Number | integer | Req | Derived | — | 同一受试者内唯一序号 |
| LBTESTCD | Lab Test or Examination Short Name | text | Req | Assigned | LBTESTCD | ≤8字符代码（如 ALB、ALT、WBC） |
| LBTEST | Lab Test or Examination Name | text | Req | Assigned | LBTEST | 检测全称 |
| LBCAT | Category for Lab Test | text | Exp | Assigned | — | CHEMISTRY / HEMATOLOGY / URINALYSIS |
| LBORRES | Result or Finding in Original Units | text | Exp | CRF | — | 原始结果（character） |
| LBORRESU | Original Units | text | Exp | CRF | UNIT | 原始单位（如 g/dL） |
| LBORNRLO | Reference Range Lower Limit in Orig Unit | text | Exp | CRF | — | 原始单位参考范围下限 |
| LBORNRHI | Reference Range Upper Limit in Orig Unit | text | Exp | CRF | — | 原始单位参考范围上限 |
| LBSTRESC | Character Result/Finding in Std Format | text | Exp | Derived | — | 标准化字符结果 |
| LBSTRESN | Numeric Result/Finding in Standard Units | float | Exp | Derived | — | 标准化数值结果 |
| LBSTRESU | Standard Units | text | Exp | Derived | UNIT | 标准单位（如 g/L） |
| LBSTNRLO | Reference Range Lower Limit-Std Units | float | Exp | Derived | — | 标准单位参考范围下限 |
| LBSTNRHI | Reference Range Upper Limit-Std Units | float | Exp | Derived | — | 标准单位参考范围上限 |
| LBNRIND | Reference Range Indicator | text | Exp | Derived | NRIND | LOW / NORMAL / HIGH / ABNORMAL |
| LBBLFL | Baseline Flag | text | Exp | Derived | NY | Y = 基线记录 |
| VISITNUM | Visit Number | float | Exp | Derived | — | 访视编号（用于排序） |
| VISIT | Visit Name | text | Perm | Assigned | — | 访视名称 |
| VISITDY | Planned Study Day of Visit | integer | Perm | Protocol | — | 计划研究日 |
| LBDTC | Date/Time of Specimen Collection | datetime | Exp | CRF | — | 标本采集日期 ISO 8601 |
| LBDY | Study Day of Specimen Collection | integer | Perm | Derived | — | 相对参照日期的研究日 |

---

## Codelist 值

### LBNRIND（参考范围指示）
`LOW` / `NORMAL` / `HIGH` / `ABNORMAL`

### LBCAT（常用类别）
`CHEMISTRY` / `HEMATOLOGY` / `URINALYSIS` / `COAGULATION`

### LBTESTCD / LBTEST（常用测试代码示例）
| LBTESTCD | LBTEST |
|----------|--------|
| ALB | Albumin |
| ALT | Alanine Aminotransferase |
| AST | Aspartate Aminotransferase |
| BILI | Bilirubin |
| CREAT | Creatinine |
| WBC | Leukocytes |
| PLAT | Platelets |
| HGB | Hemoglobin |

---

## Dummy 数据示例（R，取自 pharmaversesdtm::lb 真实样本）

```r
library(tibble)

lb <- tibble(
  STUDYID  = "CDISCPILOT01",
  DOMAIN   = "LB",
  USUBJID  = "01-701-1015",
  LBSEQ    = c(1L, 39L, 74L, 104L),
  LBTESTCD = "ALB",
  LBTEST   = "Albumin",
  LBCAT    = "CHEMISTRY",
  LBORRES  = c("3.8", "3.9", "3.8", "3.7"),
  LBORRESU = "g/dL",
  LBSTRESN = c(38, 39, 38, 37),
  LBSTRESU = "g/L",
  LBNRIND  = "NORMAL",
  VISIT    = c("SCREENING 1", "WEEK 2", "WEEK 4", "WEEK 6")
)
```
