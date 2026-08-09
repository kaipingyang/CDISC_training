# ADIS — Immunogenicity Specimen Analysis Dataset

> 数据来源：CDISC ADA(Anti-Drug Antibody) ADaM实施文档(2023) + FDA免疫原性提交指南 + ADaM IG v1.3 BDS

## 数据集概览

| 项目 | 内容 |
|------|------|
| 数据集名称 | ADIS |
| 描述 | Immunogenicity Specimen Analysis Dataset |
| Class | BDS (Basic Data Structure) |
| Structure | One record per subject per analysis parameter per analysis visit |
| 用途 | 分析免疫原性（抗药抗体 ADA、中和抗体 NAb）检测结果，含定性判定与定量滴度 |
| 主键 | STUDYID, USUBJID, PARAMCD, AVISITN, ADT |
| 备注 | 基于 SDTM IS 域衍生。检测值受定量下限（ISLLOQ）/上限（ISULOQ）约束 |

---

## 变量列表（共 24 个变量）

| Variable | Label | Type | Origin | 说明 |
|----------|-------|------|--------|------|
| STUDYID | Study Identifier | char | Predecessor | ADSL.STUDYID |
| USUBJID | Unique Subject Identifier | char | Predecessor | ADSL.USUBJID |
| SUBJID | Subject Identifier for the Study | char | Predecessor | ADSL.SUBJID |
| SITEID | Study Site Identifier | char | Predecessor | ADSL.SITEID |
| TRTA | Actual Treatment | char | Derived | 按 ADT 落入的分析期间取 ADSL.TRT0xA |
| TRTSDT | Date of First Exposure to Treatment | num (Date) | Predecessor | ADSL.TRTSDT |
| ISSEQ | Sequence Number | num | Predecessor | IS.ISSEQ |
| VISIT | Visit Name | char | Predecessor | IS.VISIT |
| VISITNUM | Visit Number | num | Predecessor | IS.VISITNUM |
| PARAMCD | Parameter Code | char | Assigned | 如 "ADA"、"NAB"、"TITER" |
| PARAM | Parameter | char | Assigned | PARAMCD 的解码值 |
| PARCAT1 | Parameter Category 1 | char | Assigned | 检测类别，源自 IS.ISCAT |
| AVISIT | Analysis Visit | char | Derived | 分析访视名；基线记录设为 "BASELINE" |
| AVISITN | Analysis Visit (N) | num | Derived | AVISIT 的数值 |
| ADT | Analysis Date | num (Date) | Derived | IS.ISDTC 的日期部分 |
| ADTM | Analysis Datetime | num (datetime) | Derived | IS.ISDTC 完整日期时间，部分缺失按 SAP 插补 |
| ADY | Analysis Relative Day | num | Derived | ADT ≥ TRTSDT 时 =(ADT−TRTSDT)+1，否则 =(ADT−TRTSDT) |
| AVAL | Analysis Value | num | Derived | 定量结果（如滴度），源自 IS.ISSTRESN |
| AVALC | Analysis Value (C) | char | Derived | 定性结果（如 "POSITIVE"/"NEGATIVE"），源自 IS.ISSTRESC |
| AVALU | Analysis Value Unit | char | Derived | 结果单位，源自 IS.ISSTRESU |
| ABLFL | Baseline Record Flag | char | Derived | TRTSDT 当天或之前最后一条非缺失结果设 "Y" |
| BASE | Baseline Value | num | Derived | ABLFL="Y" 时的 AVAL |
| ISLLOQ | Lower Limit of Quantitation | num | Predecessor | IS.ISLLOQ，定量下限 |
| ISULOQ | Upper Limit of Quantitation | num | Predecessor | IS.ISULOQ，定量上限 |

---

## Dummy 数据示例（R）

```r
library(tibble)

adis <- tibble(
  STUDYID = "STUDY-001",
  USUBJID = c("STUDY-001-01-001", "STUDY-001-01-001",
              "STUDY-001-01-001", "STUDY-001-01-002",
              "STUDY-001-01-002", "STUDY-001-01-002"),
  PARAMCD = "ADA",
  PARAM   = "Anti-Drug Antibody",
  PARCAT1 = "IMMUNOGENICITY",
  AVISIT  = c("BASELINE", "WEEK 4", "WEEK 12",
              "BASELINE", "WEEK 4", "WEEK 12"),
  AVISITN = c(0, 4, 12, 0, 4, 12),
  ADT     = as.Date(c("2024-01-10", "2024-02-07", "2024-04-03",
                      "2024-01-15", "2024-02-12", "2024-04-08")),
  AVALC   = c("NEGATIVE", "NEGATIVE", "POSITIVE",
              "NEGATIVE", "POSITIVE", "POSITIVE"),
  AVAL    = c(0, 0, 1, 0, 1, 1),
  ABLFL   = c("Y", NA, NA, "Y", NA, NA),
  BASE    = c(0, 0, 0, 0, 0, 0),
  ISLLOQ  = 10,
  ISULOQ  = 1000
)
```
