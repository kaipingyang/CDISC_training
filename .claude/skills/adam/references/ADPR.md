# ADPR — Procedures Analysis Dataset

> 数据来源：SDTMIG PR域 + 肿瘤学TAUG既往治疗概念 + admiralonco NACTDT vignette的OCCDS应用（非ADaMIG官方命名数据集）

## 数据集概览

| 项目 | 内容 |
|------|------|
| 数据集名称 | ADPR |
| 描述 | Procedures Analysis Dataset |
| Class | OCCDS (Occurrence Data Structure) |
| Structure | One record per subject per procedure per procedure start date |
| 用途 | 分析手术/操作（既往及伴随的手术、放疗、局部治疗等），支持"既往/伴随治疗"及"新抗肿瘤治疗"相关概念 |
| 主键 | STUDYID, USUBJID, PRDECOD, ASTDT |
| 备注 | 基于 SDTM PR 域衍生。ASTDT/AENDT 支持部分日期插补。ADaM IG v1.3 未定义官方 ADPR 数据集，本文件为通用 OCCDS 应用 |

---

## 变量列表（共 27 个变量）

| Variable | Label | Type | Origin | 说明 |
|----------|-------|------|--------|------|
| STUDYID | Study Identifier | char | Predecessor | ADSL.STUDYID |
| USUBJID | Unique Subject Identifier | char | Predecessor | ADSL.USUBJID |
| SUBJID | Subject Identifier for the Study | char | Predecessor | ADSL.SUBJID |
| SITEID | Study Site Identifier | char | Predecessor | ADSL.SITEID |
| TRTA | Actual Treatment | char | Derived | 按 ASTDT 落入的分析期间取 ADSL.TRT0xA |
| TRTP | Planned Treatment | char | Derived | 按 ASTDT 落入的分析期间取 ADSL.TRT0xP |
| TRTSDT | Date of First Exposure to Treatment | num (Date) | Predecessor | ADSL.TRTSDT |
| TRTEDT | Date of Last Exposure to Treatment | num (Date) | Predecessor | ADSL.TRTEDT |
| PRSEQ | Sequence Number | num | Predecessor | PR.PRSEQ |
| PRSPID | Sponsor-Defined Identifier | char | Predecessor | PR.PRSPID |
| PRCAT | Category for Procedure | char | Predecessor | PR.PRCAT |
| PRSCAT | Subcategory for Procedure | char | Predecessor | PR.PRSCAT |
| PRTRT | Reported Name of Procedure | char | Predecessor | PR.PRTRT |
| PRDECOD | Standardized Procedure Name | char | Predecessor | PR.PRDECOD（字典标准名） |
| PRINDC | Indication | char | Predecessor | PR.PRINDC |
| PRLOC | Location of Procedure | char | Predecessor | PR.PRLOC |
| PRLAT | Laterality | char | Predecessor | PR.PRLAT |
| PRSTDTC | Start Date/Time of Procedure | char | Predecessor | PR.PRSTDTC |
| ASTDT | Analysis Start Date | num (Date) | Derived | PR.PRSTDTC 转数值日期，部分缺失按 SAP 插补 |
| ASTDY | Analysis Start Relative Day | num | Derived | ASTDT ≥ TRTSDT 时 =(ASTDT−TRTSDT)+1，否则 =(ASTDT−TRTSDT) |
| ASTDTF | Analysis Start Date Imputation Flag | char | Assigned | 插补标志：D=日插补，M=月日插补 |
| PRENDTC | End Date/Time of Procedure | char | Predecessor | PR.PRENDTC |
| AENDT | Analysis End Date | num (Date) | Derived | PR.PRENDTC 转数值日期，部分缺失按 SAP 插补 |
| AENDY | Analysis End Relative Day | num | Derived | AENDT ≥ TRTSDT 时 =(AENDT−TRTSDT)+1，否则 =(AENDT−TRTSDT) |
| AENDTF | Analysis End Date Imputation Flag | char | Assigned | 插补标志：D=日插补，M=月日插补 |
| PRIORPFL | Prior Procedure Flag | char | Derived | ASTDT < TRTSDT 时设 "Y"（既往手术/操作） |
| CONPRFL | Concomitant Procedure Flag | char | Derived | 治疗期间进行的手术/操作设 "Y" |

---

## Dummy 数据示例（R）

```r
library(tibble)

adpr <- tibble(
  STUDYID = "STUDY-001",
  USUBJID = c("STUDY-001-01-001", "STUDY-001-01-001",
              "STUDY-001-01-002", "STUDY-001-01-002"),
  PRSEQ    = c(1, 2, 1, 2),
  PRCAT    = "PRIOR AND CONCOMITANT PROCEDURES/SURGERIES",
  PRTRT    = c("Appendectomy", "Biopsy",
               "Tumor resection", "Radiotherapy"),
  PRDECOD  = c("APPENDECTOMY", "BIOPSY",
               "EXCISION OF TUMOR", "RADIOTHERAPY"),
  PRSTDTC  = c("2023-11-05", "2024-02-20",
               "2023-12-01", "2024-03-15"),
  ASTDT    = as.Date(c("2023-11-05", "2024-02-20",
                       "2023-12-01", "2024-03-15")),
  ASTDTF   = c(NA, NA, NA, NA),
  TRTSDT   = as.Date(c("2024-01-10", "2024-01-10",
                       "2024-01-15", "2024-01-15")),
  ASTDY    = c(-66, 42, -45, 61),
  PRIORPFL = c("Y", NA, "Y", NA),
  CONPRFL  = c(NA, "Y", NA, "Y")
)
```
