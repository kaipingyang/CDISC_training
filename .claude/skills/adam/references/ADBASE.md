# ADBASE — Baseline Characteristic Analysis Dataset

> 数据来源：CDISC **ADaM IG v1.3 的 BDS（Basic Data Structure）通用结构**应用范例。
> **命名说明**：**ADBASE 并非 CDISC 官方命名标准**，而是"用 BDS 通用结构承载基线/疾病特征"的教学应用范例。基线特征（人口学、疾病史、既往治疗等）在实际项目中常整合入 ADSL 或专门的 BDS 数据集；此处以 ADBASE 演示 BDS 的参数化（PARAMCD/PARAM/AVAL/AVALC）与来源追溯（SRCDOM/SRCVAR/SRCSEQ）机制。以下变量与 dummy 数据均为教学中性示例。

## 数据集概览

| 项目 | 内容 |
|------|------|
| 数据集名称 | ADBASE（非官方命名，BDS 应用范例） |
| 描述 | Baseline Characteristic Analysis Dataset |
| Class | BDS (Basic Data Structure) |
| Structure | One record per subject per parameter |
| 用途 | 以参数化方式汇总基线人口学与疾病特征，支持基线特征汇总表（Baseline Characteristics table） |
| 主键 | STUDYID, USUBJID, PARAMCD |
| 备注 | 基线与疾病特征参数来自多个 SDTM 域（DM/MH/VS 等）或 ADSL，通过 SRCDOM/SRCVAR/SRCSEQ 追溯每个 AVAL/AVALC 的来源。保留 ADSL 全部受试者。 |

---

## 变量列表（共 12 个变量，基于 BDS 标准框架）

> 实用 ADBASE 通常还会带入 ADSL 的 STUDYID/USUBJID/治疗与分组变量；下表聚焦 BDS 核心的参数化与追溯变量。

| Variable | Label | Type | Origin | 说明 |
|----------|-------|------|--------|------|
| STUDYID | Study Identifier | char | Predecessor(ADSL) | 研究标识 |
| USUBJID | Unique Subject Identifier | char | Predecessor(ADSL) | 受试者唯一标识 |
| TRT01P | Planned Treatment for Period 01 | char | Predecessor(ADSL) | 计划治疗（分组变量） |
| PARAMCD | Parameter Code | char | Assigned | 参数代码，见受控术语/参数说明 |
| PARAM | Parameter | char | Assigned | 参数描述（PARAMCD 的解码值） |
| AVAL | Analysis Value | num | Derived | 数值分析值（连续型特征，如身高/体重/病程月数） |
| AVALC | Analysis Value (C) | char | Derived | 字符分析值（分类型特征，如疾病分期/ECOG 描述） |
| PARCAT1 | Parameter Category 1 | char | Assigned | 参数大类（研究/表格特定，理想上每类对应一张表），如 "DISEASE HISTORY"、"BASELINE CHARACTERISTICS" |
| PARSCAT1 | Parameter Subcategory 1 | char | Assigned | 参数子类，用于进一步细分（如某类特征的部位/设置） |
| SRCDOM | Source Domain | char | Assigned | AVAL/AVALC 关联的 SDTM 域或 ADaM 数据集名（如 DM、MH、VS） |
| SRCVAR | Source Variable | char | Assigned | 源域中承载该值的变量名（如 VSSTRESN、MHTERM） |
| SRCSEQ | Source Sequence Number | num | Assigned | 源域中对应行的序号 xxSEQ，仅当 AVAL/AVALC 来自源域唯一一行时填充 |

### 参数（PARAMCD）示例（教学中性）

| PARAMCD | PARAM | PARCAT1 | 类型 |
|---------|-------|---------|------|
| HGTBL | Height at Baseline (cm) | BASELINE CHARACTERISTICS | 数值 (AVAL) |
| WGTBL | Weight at Baseline (kg) | BASELINE CHARACTERISTICS | 数值 (AVAL) |
| BMIBL | BMI at Baseline (kg/m2) | BASELINE CHARACTERISTICS | 数值 (AVAL) |
| DURDIS | Duration of Disease (months) | DISEASE HISTORY | 数值 (AVAL) |
| STAGE | Disease Stage at Baseline | DISEASE HISTORY | 分类 (AVALC) |

---

## Dummy 数据示例（R，中性教学占位数据）

```r
library(tibble)

adbase <- tribble(
  ~STUDYID,    ~USUBJID,            ~PARAMCD, ~PARAM,                        ~AVAL, ~AVALC,     ~PARCAT1,                  ~SRCDOM, ~SRCVAR,
  "STUDY-001", "STUDY-001-01-001",  "HGTBL",  "Height at Baseline (cm)",      172,  NA,         "BASELINE CHARACTERISTICS","VS",    "VSSTRESN",
  "STUDY-001", "STUDY-001-01-001",  "WGTBL",  "Weight at Baseline (kg)",       68,  NA,         "BASELINE CHARACTERISTICS","VS",    "VSSTRESN",
  "STUDY-001", "STUDY-001-01-001",  "DURDIS", "Duration of Disease (months)",  14,  NA,         "DISEASE HISTORY",         "MH",    "MHSTDTC",
  "STUDY-001", "STUDY-001-01-001",  "STAGE",  "Disease Stage at Baseline",     NA,  "STAGE II", "DISEASE HISTORY",         "MH",    "MHSCAT",
  "STUDY-001", "STUDY-001-01-002",  "HGTBL",  "Height at Baseline (cm)",      165,  NA,         "BASELINE CHARACTERISTICS","VS",    "VSSTRESN"
)
```
