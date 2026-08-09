# ADLBHY — Hy's Law Laboratory Analysis Dataset

> 数据来源：CDISC ADaM IG v1.3（BDS 结构）+ pharmaverse `pharmaverseadam::adlbhy` 实际结构整理。参数与判定标准依据 CDISC ADaM 中 Hy's Law（肝功能）相关实现（ALT/AST/BILI 相对 ULN 的倍数标准）。

## 数据集概览

| 项目 | 内容 |
|------|------|
| 数据集名称 | ADLBHY |
| 描述 | Hy's Law Laboratory Analysis Dataset（Hy's Law 肝功能分析数据集） |
| Class | BDS（Basic Data Structure） |
| Structure | One record per subject per parameter per analysis date（每受试者每参数每分析日期一条记录） |
| 用途 | 评估药物性肝损伤（DILI）/ Hy's Law：ALT/AST ≥3×ULN、BILI ≥2×ULN，及综合 HYSLAW 判定 |
| 主键 | STUDYID, USUBJID, PARAMCD, ADT, LBSEQ |
| 输入 | 由 ADLB 中肝功能参数（ALT/AST/BILI）子集派生；HYSLAW 为综合派生参数 |
| 备注 | 是 ADLB 的下游数据集，仅保留肝功能相关记录并加上基于 CRIT1/CRIT1FL 的标准评估 |

---

## 变量列表（共 14 个变量，取自 `pharmaverseadam::adlbhy`）

| Variable | Label | Type | Origin | 说明 |
|----------|-------|------|--------|------|
| STUDYID | Study Identifier | char | Predecessor | 取自 ADLB.STUDYID |
| USUBJID | Unique Subject Identifier | char | Predecessor | 取自 ADLB.USUBJID |
| TRT01A | Actual Treatment for Period 01 | char | Derived | 合并自 ADSL/ADLB，用于按治疗组分层 |
| ADT | Analysis Date | num (Date) | Derived | 取自 ADLB.ADT（对应肝功能记录的分析日期） |
| ADY | Analysis Relative Day | num | Derived | 取自 ADLB.ADY，相对 TRTSDT 的研究日 |
| AVISIT | Analysis Visit | char | Derived | 取自 ADLB.AVISIT（Baseline / Week n 等） |
| PARAM | Parameter | char | Derived | 参数全称，如 "Alanine Aminotransferase (U/L)"；HYSLAW 参数为综合判定标签 |
| PARAMCD | Parameter Code | char | Derived | ALT / AST / BILI（源自 ADLB），以及派生的 HYSLAW（综合 Hy's Law 判定） |
| AVAL | Analysis Value | num | Derived | ALT/AST/BILI 取自 ADLB.AVAL；HYSLAW 记录以 0/1 等指示值表示是否满足综合标准 |
| AVALC | Analysis Value (C) | char | Derived | AVAL 的字符表示，或综合判定的文字结果 |
| CRIT1 | Analysis Criterion 1 | char | Derived | 判定标准文字描述：如 "ALT >=3xULN"、"AST >=3xULN"、"BILI >= 2xULN" |
| CRIT1FL | Criterion 1 Evaluation Result Flag | char | Derived | 满足 CRIT1 标准则为 "Y"，否则 "N"；核心逻辑：AVAL 与 ANRHI(ULN) 比值达到阈值（ALT/AST 3倍、BILI 2倍）时置 "Y" |
| ANRHI | Analysis Normal Range Upper Limit | num | Derived | 参考范围上限（ULN），用于计算 AVAL/ANRHI 比值判定 CRIT1FL |
| LBSEQ | Sequence Number | num | Predecessor | 取自源 LB.LBSEQ / ADLB.LBSEQ，用于溯源 |

### CRIT1 / CRIT1FL 判定逻辑说明

Hy's Law 相关标准通过“分析值相对 ULN（ANRHI）的倍数”评估：

- **ALT ≥3×ULN**：`CRIT1 = "ALT >=3xULN"`，当 `AVAL/ANRHI >= 3` 时 `CRIT1FL = "Y"`
- **AST ≥3×ULN**：`CRIT1 = "AST >=3xULN"`，当 `AVAL/ANRHI >= 3` 时 `CRIT1FL = "Y"`
- **BILI ≥2×ULN**：`CRIT1 = "BILI >= 2xULN"`，当 `AVAL/ANRHI >= 2` 时 `CRIT1FL = "Y"`
- **HYSLAW**（综合参数）：结合上述 aminotransferase 与 bilirubin 标志综合判断潜在 Hy's Law 病例，CRIT1 可为空

---

## Dummy 数据示例（R，取自 `pharmaverseadam::adlbhy` 真实样本）

```r
library(tibble)

adlbhy <- tibble(
  STUDYID = "CDISCPILOT01",
  USUBJID = "01-701-1015",
  TRT01A  = "Placebo",
  PARAMCD = c("ALT", "ALT", "ALT", "ALT"),
  PARAM   = "Alanine Aminotransferase (U/L)",
  AVISIT  = c("Baseline", "Week 2", "Week 4", "Week 6"),
  ADT     = as.Date(c("2013-12-26", "2014-01-16", "2014-01-30", "2014-02-12")),
  AVAL    = c(27, 41, 18, 26),
  ANRHI   = 34,
  CRIT1   = "ALT >=3xULN",
  CRIT1FL = c("N", "N", "N", "N"),
  LBSEQ   = c(1, 2, 3, 4)
)
```
