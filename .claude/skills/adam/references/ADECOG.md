# ADECOG — ECOG Performance Status Analysis Dataset

> 数据来源：CDISC QRS ECOG Performance Status ADaM Supplement + ADaM IG v1.3 BDS结构

## 数据集概览

| 项目 | 内容 |
|------|------|
| 数据集名称 | ADECOG |
| 描述 | ECOG Performance Status Analysis Dataset |
| Class | BDS (Basic Data Structure) |
| Structure | One record per subject per analysis parameter per analysis visit |
| 用途 | 分析 ECOG（Eastern Cooperative Oncology Group）体能状态评分随访变化。可视为 ADQS 中 `PARCAT1='ECOG'` 的特化数据集 |
| 主键 | STUDYID, USUBJID, PARAMCD, AVISITN, ADT |
| 备注 | 通常基于 SDTM RS 域（RSCAT='ECOG'）或 QS 域衍生，剔除 "NOT DONE" 记录。ECOG 评分为 0-5 的有序等级（0=完全活动，5=死亡） |

---

## 变量列表（共 27 个变量）

| Variable | Label | Type | Origin | 说明 |
|----------|-------|------|--------|------|
| STUDYID | Study Identifier | char | Predecessor | ADSL.STUDYID |
| USUBJID | Unique Subject Identifier | char | Predecessor | ADSL.USUBJID |
| SUBJID | Subject Identifier for the Study | char | Predecessor | ADSL.SUBJID |
| SITEID | Study Site Identifier | char | Predecessor | ADSL.SITEID |
| ARM | Description of Planned Arm | char | Predecessor | ADSL.ARM |
| ACTARM | Description of Actual Arm | char | Predecessor | ADSL.ACTARM |
| TRTP | Planned Treatment | char | Derived | 按 ADT 落入的分析期间取 ADSL.TRT0xP |
| TRTA | Actual Treatment | char | Derived | 按 ADT 落入的分析期间取 ADSL.TRT0xA |
| TRTSDT | Date of First Exposure to Treatment | num (Date) | Predecessor | ADSL.TRTSDT |
| RSSEQ | Sequence Number | num | Predecessor | RS.RSSEQ（源自 QS 时为 QS.QSSEQ） |
| PARAMCD | Parameter Code | char | Assigned | 如 "ECOG" |
| PARAM | Parameter | char | Assigned | 如 "ECOG Performance Status" |
| PARAMN | Parameter (N) | num | Assigned | PARAM 的数值编码 |
| PARCAT1 | Parameter Category 1 | char | Assigned | 设为 "ECOG" |
| AVISIT | Analysis Visit | char | Derived | 分析访视名；基线记录设为 "BASELINE" |
| AVISITN | Analysis Visit (N) | num | Derived | AVISIT 的数值 |
| ADT | Analysis Date | num (Date) | Derived | RS.RSDTC / QS.QSDTC 的日期部分 |
| ADY | Analysis Relative Day | num | Derived | ADT ≥ TRTSDT 时 =(ADT−TRTSDT)+1，否则 =(ADT−TRTSDT) |
| AVAL | Analysis Value | num | Derived | ECOG 评分数值（0-5），源自 RS.RSSTRESN |
| AVALC | Analysis Value (C) | char | Derived | ECOG 评分文本，源自 RS.RSSTRESC |
| ABLFL | Baseline Record Flag | char | Derived | 基线记录（TRTSDT 当天或之前最后一条非缺失结果）设 "Y" |
| BASE | Baseline Value | num | Derived | ABLFL="Y" 时的 AVAL |
| BASEC | Baseline Value (C) | char | Derived | ABLFL="Y" 时的 AVALC |
| CHG | Change from Baseline | num | Derived | AVAL − BASE |
| ANL01FL | Analysis Flag 01 | char | Derived | 基线及计划内访视后记录设 "Y"，用于按访视汇总 |
| ANL02FL | Analysis Flag 02 | char | Derived | 基线后最差（最大）ECOG 记录设 "Y"，并列时取最早 |
| ASEQ | Analysis Sequence Number | num | Derived | 按主键排序后每受试者从 1 递增 |

---

## Dummy 数据示例（R）

```r
library(tibble)

adecog <- tibble(
  STUDYID = "STUDY-001",
  USUBJID = c("STUDY-001-01-001", "STUDY-001-01-001",
              "STUDY-001-01-001", "STUDY-001-01-002",
              "STUDY-001-01-002", "STUDY-001-01-002"),
  PARAMCD = "ECOG",
  PARAM   = "ECOG Performance Status",
  PARCAT1 = "ECOG",
  AVISIT  = c("BASELINE", "WEEK 4", "WEEK 8",
              "BASELINE", "WEEK 4", "WEEK 8"),
  AVISITN = c(0, 4, 8, 0, 4, 8),
  ADT     = as.Date(c("2024-01-10", "2024-02-07", "2024-03-06",
                      "2024-01-15", "2024-02-12", "2024-03-11")),
  AVAL    = c(1, 1, 2, 0, 1, 1),
  ABLFL   = c("Y", NA, NA, "Y", NA, NA),
  BASE    = c(1, 1, 1, 0, 0, 0),
  CHG     = c(NA, 0, 1, NA, 1, 1),
  ANL01FL = "Y"
)
```
