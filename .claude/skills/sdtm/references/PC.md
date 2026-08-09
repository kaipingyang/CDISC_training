# PC — Pharmacokinetics Concentrations

> 数据来源：CDISC SDTMIG v3.4 (Findings class) + pharmaverse `pharmaversesdtm::pc` 实际结构整理

## 数据集概览

| 项目 | 内容 |
|------|------|
| Domain | PC |
| 描述 | Pharmacokinetics Concentrations |
| Class | Findings |
| Structure | One record per analyte per time point per visit per subject |
| Key Variables | STUDYID, USUBJID, PCTESTCD, VISITNUM, PCTPTNUM |
| 备注 | PC 记录生物样本（血浆/尿液等）中药物或代谢物的浓度测量，每条记录对应某分析物在某采样时间点（PCTPT）的浓度值。PC 是 PP（PK 参数）的数据来源：PP 中的 AUC、Cmax 等参数由 PC 的浓度-时间曲线经 NCA 推导。低于定量下限的值记为 `<BLQ`，PCLLOQ 存定量下限。 |

---

## 变量列表

| Variable | Label | Type | Core | Origin | Codelist | 说明 |
|----------|-------|------|------|--------|----------|------|
| STUDYID | Study Identifier | text | Req | Protocol | — | |
| DOMAIN | Domain Abbreviation | text | Req | Assigned | — | 固定 "PC" |
| USUBJID | Unique Subject Identifier | text | Req | Derived | — | 关联回 DM |
| PCSEQ | Sequence Number | integer | Req | Derived | — | 受试者内唯一序号 |
| PCTESTCD | Pharmacokinetic Test Short Name | text | Req | Assigned | — | 分析物短名，≤8 字符 |
| PCTEST | Pharmacokinetic Test Name | text | Req | Assigned | — | 分析物全名 |
| PCORRES | Result or Finding in Original Units | text | Exp | Collected | — | 原始浓度，含 `<BLQ` 等 |
| PCORRESU | Original Units | text | Exp | Collected | UNIT | 原始单位 |
| PCSTRESC | Character Result/Finding in Std Format | text | Exp | Derived | — | 标准化字符结果 |
| PCSTRESN | Numeric Result/Finding in Standard Units | float | Exp | Derived | — | 标准化数值结果 |
| PCSTRESU | Standard Units | text | Exp | Derived | UNIT | 标准单位 |
| PCNAM | Vendor Name | text | Perm | Collected | — | 检测实验室名称 |
| PCSPEC | Specimen Material Type | text | Exp | Collected | SPECTYPE | 样本类型，如 PLASMA/URINE |
| PCLLOQ | Lower Limit of Quantitation | float | Perm | Assigned | — | 定量下限 |
| VISIT | Visit Name | text | Perm | Derived | — | 访视名称 |
| VISITNUM | Visit Number | float | Exp | Derived | — | 访视序号 |
| VISITDY | Planned Study Day of Visit | integer | Perm | Assigned | — | 计划访视研究日 |
| PCDTC | Date/Time of Specimen Collection | datetime | Exp | Collected | — | 采样日期时间 |
| PCDY | Actual Study Day of Specimen Collection | integer | Perm | Derived | — | 相对参照日的研究日 |
| PCTPT | Planned Time Point Name | text | Perm | Assigned | — | 计划采样时间点名，如 Pre-dose |
| PCTPTNUM | Planned Time Point Number | float | Perm | Assigned | — | 时间点数值序号 |

---

## Codelist 值

### PCSPEC（样本类型，节选，完整清单见 CDISC CT）
`PLASMA` / `URINE` / `SERUM` / `BLOOD`

### PCORRES 特殊值
`<BLQ`（Below Limit of Quantitation，低于定量下限）— 对应 PCSTRESN 通常置 0 或缺失，具体由统计分析计划规定。

---

## Dummy 数据示例（R，取自 pharmaversesdtm::pc 真实样本）

```r
library(tibble)

pc <- tibble(
  STUDYID  = "CDISCPILOT01",
  DOMAIN   = "PC",
  USUBJID  = "01-701-1015",
  PCSEQ    = 1:4,
  PCTESTCD = "XAN",
  PCTEST   = "XANOMELINE",
  PCORRES  = "<BLQ",
  PCORRESU = "ug/ml",
  PCSTRESN = c(0, NA, NA, NA),
  PCSTRESU = "ug/ml",
  PCSPEC   = "PLASMA",
  PCLLOQ   = 0.01,
  VISIT    = "BASELINE",
  PCTPT    = c("Pre-dose", "5 Min Post-dose", "30 Min Post-dose", "1h Post-dose")
)
```
