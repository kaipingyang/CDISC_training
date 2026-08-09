# ADQS — Questionnaires Analysis Dataset

> 数据来源：CDISC ADaM IG v1.3 BDS + CDISC ADQRS Best Practices + admiral官方Questionnaires vignette

## 数据集概览

| 项目 | 内容 |
|------|------|
| 数据集名称 | ADQS |
| 描述 | Questionnaires Analysis Dataset |
| Class | BDS (Basic Data Structure) |
| Structure | One record per subject per analysis parameter per analysis visit |
| 用途 | 分析问卷/量表（PRO、QoL 等）的条目得分及衍生总分，按访视比较基线变化 |
| 主键 | STUDYID, USUBJID, PARCAT1, PARAMCD, AVISITN, ADT |
| 备注 | 基于 SDTM QS 域衍生；`PARCAT1` 用于标识量表名称（QSCAT）。保留 ADSL 中全部受试者 |

---

## 变量列表（共 30 个变量）

| Variable | Label | Type | Origin | 说明 |
|----------|-------|------|--------|------|
| STUDYID | Study Identifier | char | Predecessor | ADSL.STUDYID |
| USUBJID | Unique Subject Identifier | char | Predecessor | ADSL.USUBJID |
| SUBJID | Subject Identifier for the Study | char | Predecessor | ADSL.SUBJID |
| SITEID | Study Site Identifier | char | Predecessor | ADSL.SITEID |
| TRTP | Planned Treatment | char | Derived | 按 ADT 落入的分析期间取 ADSL.TRT0xP |
| TRTA | Actual Treatment | char | Derived | 按 ADT 落入的分析期间取 ADSL.TRT0xA |
| TRTSDT | Date of First Exposure to Treatment | num (Date) | Predecessor | ADSL.TRTSDT |
| QSSEQ | Sequence Number | num | Predecessor | QS.QSSEQ（仅直接源自 SDTM 的记录） |
| PARCAT1 | Parameter Category 1 | char | Assigned | 量表名称，源自 QS.QSCAT |
| PARAMTYP | Parameter Type | char | Assigned | 衍生参数设为 "DERIVED" |
| PARAMCD | Parameter Code | char | Assigned | 参数短代码 |
| PARAM | Parameter | char | Assigned | 参数完整名称 |
| PARAMN | Parameter (N) | num | Assigned | PARAM 的数值编码 |
| AVISIT | Analysis Visit | char | Derived | 分析访视名；基线记录设为 "BASELINE" |
| AVISITN | Analysis Visit (N) | num | Derived | AVISIT 的数值 |
| ADT | Analysis Date | num (Date) | Derived | QS.QSDTC 的日期部分 |
| ADY | Analysis Relative Day | num | Derived | ADT ≥ 锚点日期时 =(ADT−锚点)+1，否则 =(ADT−锚点) |
| AVAL | Analysis Value | num | Derived | QS.QSSTRESN，衍生参数按参数级元数据计算 |
| AVALC | Analysis Value (C) | char | Derived | QS.QSSTRESC |
| ABLFL | Baseline Record Flag | char | Derived | 锚点日期当天或之前最后一条非缺失结果设 "Y" |
| BASE | Baseline Value | num | Derived | ABLFL="Y" 时的 AVAL |
| BASEC | Baseline Value (C) | char | Derived | ABLFL="Y" 时的 AVALC |
| CHG | Change from Baseline | num | Derived | AVAL − BASE |
| PCHG | Percent Change from Baseline | num | Derived | (CHG / BASE) × 100 |
| ANL01FL | Analysis Flag 01 | char | Derived | 基线及计划内访视后记录设 "Y"，用于按访视汇总 |
| ANL02FL | Analysis Flag 02 | char | Derived | 基线后最差结果设 "Y"，并列时取最早 |
| CRIT1 | Analysis Criterion 1 | char | Assigned | 临床有意义恶化标准的文本描述 |
| CRIT1FL | Criterion 1 Evaluation Result Flag | char | Derived | 满足 CRIT1 标准的记录设 "Y" |
| DTYPE | Derivation Type | char | Assigned | 标识经插补/衍生的记录（如 LOCF） |
| ASEQ | Analysis Sequence Number | num | Derived | 按主键排序后每受试者从 1 递增 |

---

## Dummy 数据示例（R）

```r
library(tibble)

adqs <- tibble(
  STUDYID = "STUDY-001",
  USUBJID = c("STUDY-001-01-001", "STUDY-001-01-001",
              "STUDY-001-01-001", "STUDY-001-01-002",
              "STUDY-001-01-002", "STUDY-001-01-002"),
  PARCAT1 = "QoL Questionnaire",
  PARAMCD = "TOTSCORE",
  PARAM   = "Total Score",
  AVISIT  = c("BASELINE", "WEEK 6", "WEEK 12",
              "BASELINE", "WEEK 6", "WEEK 12"),
  AVISITN = c(0, 6, 12, 0, 6, 12),
  ADT     = as.Date(c("2024-01-10", "2024-02-21", "2024-04-03",
                      "2024-01-15", "2024-02-26", "2024-04-08")),
  AVAL    = c(60, 65, 70, 55, 50, 58),
  ABLFL   = c("Y", NA, NA, "Y", NA, NA),
  BASE    = c(60, 60, 60, 55, 55, 55),
  CHG     = c(NA, 5, 10, NA, -5, 3),
  PCHG    = c(NA, 8.3, 16.7, NA, -9.1, 5.5),
  ANL01FL = "Y"
)
```
