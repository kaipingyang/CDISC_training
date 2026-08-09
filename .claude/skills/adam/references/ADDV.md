# ADDV — Protocol Deviation Analysis Dataset

> 数据来源：CDISC **ADaM OCCDS IG v1.1**（该文档明确将 ADDV 列为 OCCDS 结构应用示例）+ CDISC **SDTMIG DV**（Protocol Deviations）域。
> **命名说明**：ADDV **属于 CDISC OCCDS 结构的应用范例**（One record per subject per event/occurrence），使用标准 OCCDS 变量框架；ADDV 数据集名本身是行业通用惯例。以下变量与 dummy 数据均为教学中性示例，不含任何真实研究内容。

## 数据集概览

| 项目 | 内容 |
|------|------|
| 数据集名称 | ADDV |
| 描述 | Protocol Deviation Analysis Dataset |
| Class | OCCDS (Occurrence Data Structure) |
| Structure | One record per subject per protocol deviation |
| 用途 | 汇总方案偏离（Protocol Deviation）以支持偏离例数/分类统计表，识别重要方案偏离（Important PD） |
| 主键 | STUDYID, USUBJID, ASTDT, DVDECOD/DVTERM |
| 备注 | 基于 SDTM **DV** 域（及 SUPPDV）衍生，合并 ADSL 受试者级变量与治疗信息，保留 ADSL 全部受试者中有偏离记录者。 |

---

## 变量列表（共 20 个变量，基于 OCCDS 标准框架）

> Origin 中 Predecessor(DV) 表示直接来自 SDTM DV 域；Predecessor(ADSL) 表示来自 ADSL；Derived 为衍生。

| Variable | Label | Type | Origin | 说明 |
|----------|-------|------|--------|------|
| STUDYID | Study Identifier | char | Predecessor(ADSL) | 研究标识 |
| USUBJID | Unique Subject Identifier | char | Predecessor(ADSL) | 受试者唯一标识 |
| SUBJID | Subject Identifier for the Study | char | Predecessor(ADSL) | 研究内受试者编号 |
| SITEID | Study Site Identifier | char | Predecessor(ADSL) | 中心编号 |
| TRTA | Actual Treatment | char | Derived | 实际治疗，单周期研究取 ADSL.TRT01A |
| TRTP | Planned Treatment | char | Derived | 计划治疗，单周期研究取 ADSL.TRT01P |
| TRTSDT | Date of First Exposure to Treatment | num (Date) | Predecessor(ADSL) | 首次给药日期（计算相对日基准） |
| APERIOD | Period | num | Derived | 分析周期编号，多周期研究适用 |
| APERIODC | Period (C) | char | Derived | 分析周期描述 |
| DVSEQ | Sequence Number | num | Predecessor(DV) | DV.DVSEQ，源记录序号 |
| DVTERM | Protocol Deviation Term | char | Predecessor(DV) | DV.DVTERM，偏离的逐字描述 |
| DVDECOD | Protocol Deviation Coded Term | char | Predecessor(DV) | DV.DVDECOD，偏离标准化术语 |
| DVCAT | Category for Protocol Deviation | char | Predecessor(DV) | DV.DVCAT，偏离大类 |
| DVSCAT | Subcategory for Protocol Deviation | char | Predecessor(DV) | DV.DVSCAT，偏离子类 |
| ASTDT | Analysis Start Date | num (Date) | Derived | 偏离开始日期，`derive_vars_dt()` 解析 DV.DVSTDTC，部分日期不插补则设缺失 |
| ASTDY | Analysis Start Relative Day | num | Derived | 偏离开始相对日 = ASTDT − TRTSDT (+1)，`derive_vars_dy()` |
| AENDT | Analysis End Date | num (Date) | Derived | 偏离结束日期，解析 DV.DVENDTC |
| AENDY | Analysis End Relative Day | num | Derived | 偏离结束相对日 |
| AVISIT | Analysis Visit | char | Derived | 分析访视（如适用） |
| DVIMPOFL | Important Protocol Deviation Flag | char | Derived | 重要方案偏离标志，取自 SUPPDV.DVIMPOYN，设 "Y"/NA |

---

## Dummy 数据示例（R，中性教学占位数据）

```r
library(tibble)

addv <- tribble(
  ~STUDYID,    ~USUBJID,             ~TRTA,      ~DVDECOD,                  ~DVCAT,                    ~ASTDT,       ~ASTDY, ~DVIMPOFL,
  "STUDY-001", "STUDY-001-01-001",   "Drug A",   "MISSED STUDY VISIT",      "VISIT DEVIATION",         "2023-02-15",     26, NA,
  "STUDY-001", "STUDY-001-01-001",   "Drug A",   "OUT OF WINDOW ASSESSMENT","VISIT DEVIATION",         "2023-03-10",     49, NA,
  "STUDY-001", "STUDY-001-01-002",   "Placebo",  "INCORRECT DOSE ADMIN",    "TREATMENT DEVIATION",     "2023-01-30",     12, "Y",
  "STUDY-001", "STUDY-001-02-001",   "Drug A",   "PROHIBITED CONCOMITANT MED","MEDICATION DEVIATION",  "2023-04-05",     70, "Y"
) |>
  dplyr::mutate(ASTDT = as.Date(ASTDT))
```
