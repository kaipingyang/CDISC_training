# ADTTE — Time-to-Event Analysis Dataset

> 数据来源：基于 CDISC ADaM IG v1.3 的 **BDS Time-to-Event（TTE）通用结构** + pharmaverse `admiral::derive_param_tte()` / `admiralonco` 的 ADTTE 模板，用 `pharmaverseadam::adtte_onco`（基于 CDISC 公开 **CDISCPILOT01** 研究）交叉核实。以下按通用 TTE 结构组织，示例参数取 OS（Overall Survival）、PFS（Progression Free Survival）、DOR（Duration of Response）；实际研究可替换为任意时间到事件终点。非任何真实公司/产品数据。

## 数据集概览

| 项目 | 内容 |
|------|------|
| 数据集名称 | ADTTE |
| 描述 | Time-to-Event Analysis Dataset |
| Class | BDS (Basic Data Structure) |
| Structure | One record per subject per analysis parameter |
| 用途 | 存储时间到事件终点的生存时间（AVAL）、删失指示（CNSR）、事件/删失描述，供 Kaplan-Meier 曲线、Cox 回归、Log-rank 检验使用 |
| 主键 | STUDYID, USUBJID, PARAMCD |
| 备注 | 派生域，基于 ADSL 与相应事件源数据集（如 ADRS/ADAE）。核心是 `admiral::derive_param_tte()`：为每个受试者每个参数计算起点（STARTDT）到事件或删失日期（ADT）的时间。AVAL = ADT − STARTDT + 1。 |

---

## 变量列表（共 20 个变量，取自 `pharmaverseadam::adtte_onco`）

> TTE 的**六个核心变量**为 STARTDT、ADT、AVAL、CNSR、PARAMCD、EVNTDESC —— 它们共同定义"从何时起、到何时、发生了什么、是否删失"。理解这六个即掌握 TTE 结构。

| Variable | Label | Type | Origin | 说明 |
|----------|-------|------|--------|------|
| STUDYID | Study Identifier | char | Predecessor(ADSL) | 研究标识 |
| USUBJID | Unique Subject Identifier | char | Predecessor(ADSL) | 受试者唯一标识 |
| ASEQ | Analysis Sequence Number | num | Derived | 分析序号 |
| AGE | Age | num | Predecessor(ADSL) | 年龄（分组分析协变量） |
| SEX | Sex | char | Predecessor(ADSL) | 性别 |
| ARM | Description of Planned Arm | char | Predecessor(ADSL) | 计划治疗组描述（KM 分组变量） |
| ARMCD | Planned Arm Code | char | Predecessor(ADSL) | 计划治疗组代码 |
| ACTARM | Description of Actual Arm | char | Predecessor(ADSL) | 实际治疗组描述 |
| ACTARMCD | Actual Arm Code | char | Predecessor(ADSL) | 实际治疗组代码 |
| **STARTDT** | Time-to-Event Origin Date for Subject | num (Date) | Derived | **【核心】时间起点日期**，如随机化日期（OS/PFS）或首次缓解日期（DOR）。`derive_param_tte()` 的 `start_date` |
| **ADT** | Analysis Date | num (Date) | Derived | **【核心】事件或删失日期**，取事件日期或末次评估/存活日期中的较早/相应者 |
| **AVAL** | Analysis Value | num | Derived | **【核心】生存时间** = ADT − STARTDT + 1（天） |
| **PARAMCD** | Parameter Code | char | Assigned | **【核心】参数代码**，如 OS/PFS/RSD(DOR) |
| PARAM | Parameter | char | Assigned | 参数描述，如 "Overall Survival" |
| **CNSR** | Censor | int | Derived | **【核心】删失指示：0 = 发生事件，1 = 删失**（CDISC 约定） |
| **EVNTDESC** | Event or Censoring Description | char | Derived | **【核心】事件/删失描述**，如 "Death"、"Disease Progression"、"Alive"、"Last Tumor Assessment" |
| CNSDTDSC | Censor Date Description | char | Derived | 删失日期来源描述，仅删失记录填充，如 "Alive During Study"、"Last Tumor Assessment" |
| SRCDOM | Source Data | char | Derived | 事件/删失日期来源数据集，如 "ADSL"、"ADRS" |
| SRCVAR | Source Variable | char | Derived | 来源变量名 |
| SRCSEQ | Source Sequence Number | num | Derived | 来源记录序号 |

### 关键参数（PARAMCD）说明

| PARAMCD | PARAM | 时间起点 STARTDT | 事件定义（CNSR=0） | 删失（CNSR=1） |
|---------|-------|------------------|--------------------|----------------|
| OS | Overall Survival | 随机化日期 | 死亡 | 末次确认存活 |
| PFS | Progression Free Survival | 随机化日期 | 疾病进展或死亡 | 末次肿瘤评估 |
| RSD | Duration of Response | 首次缓解（CR/PR）日期 | 进展或死亡 | 末次肿瘤评估 |

> **通用化说明**：上表以肿瘤终点举例，但 TTE 结构适用于任何"时间到事件"分析——如"到不良事件时间"（起点=首次给药，事件=特定 AE）、"到住院时间"等。只需替换 PARAMCD/PARAM/STARTDT/事件定义即可。

---

## Dummy 数据示例（R，取自 pharmaverseadam::adtte_onco 真实样本）

```r
library(tibble)

adtte <- tribble(
  ~STUDYID,       ~USUBJID,      ~PARAMCD, ~PARAM,                       ~STARTDT,     ~ADT,         ~AVAL, ~CNSR, ~EVNTDESC,               ~SRCDOM,
  "CDISCPILOT01", "01-701-1015", "OS",     "Overall Survival",           "2014-01-02", "2014-07-02",   182,     1, "Alive",                 "ADSL",
  "CDISCPILOT01", "01-701-1015", "PFS",    "Progression Free Survival",  "2014-01-02", "2014-03-06",    64,     1, "Last Tumor Assessment", "ADRS",
  "CDISCPILOT01", "01-701-1023", "PFS",    "Progression Free Survival",  "2012-08-05", "2012-08-05",     1,     1, "Randomization",         "ADSL",
  "CDISCPILOT01", "01-701-1028", "OS",     "Overall Survival",           "2013-07-19", "2014-01-14",   180,     1, "Alive",                 "ADSL",
  "CDISCPILOT01", "01-701-1028", "PFS",    "Progression Free Survival",  "2013-07-19", "2013-08-30",    43,     0, "Disease Progression",   "ADRS"
) |>
  dplyr::mutate(STARTDT = as.Date(STARTDT), ADT = as.Date(ADT))
```
