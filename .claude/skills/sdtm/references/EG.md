# EG — ECG Test Results

> 数据来源：CDISC SDTMIG v3.4 (Findings class) + pharmaverse `pharmaversesdtm::eg` 实际结构整理

## 数据集概览

| 项目 | 内容 |
|------|------|
| Domain | EG |
| 描述 | ECG Test Results |
| Class | Findings |
| Structure | One record per ECG test per time point per visit per subject |
| Key Variables | STUDYID, USUBJID, EGTESTCD, VISITNUM, EGDTC |
| 备注 | EG 记录心电图检测结果，结构与 LB/VS 等 Findings 域一致：含原始值（EGORRES/EGORRESU）与标准化值（EGSTRESC/EGSTRESN/EGSTRESU）。EGTESTCD 使用 CDISC EGTESTCD codelist。EGBLFL 标识基线记录。 |

---

## 变量列表

> 以下变量基于 `pharmaversesdtm::eg` 真实 `names()`，Label 取自各列 `attr(., "label")`。

| Variable | Label | Type | Core | Origin | Codelist | 说明 |
|----------|-------|------|------|--------|----------|------|
| STUDYID | Study Identifier | text | Req | Protocol | — | |
| DOMAIN | Domain Abbreviation | text | Req | Assigned | EG | 固定 "EG" |
| USUBJID | Unique Subject Identifier | text | Req | Derived | — | 关联回 DM |
| EGSEQ | Sequence Number | integer | Req | Derived | — | 域内唯一序号 |
| EGTESTCD | ECG Test Short Name | text | Req | Assigned | EGTESTCD | ≤8 字符（如 HR、QT） |
| EGTEST | ECG Test Name | text | Req | Assigned | EGTEST | 检测全称 |
| EGORRES | Result or Finding in Original Units | text | Exp | CRF/eDT | — | 原始结果 |
| EGORRESU | Original Units | text | Perm | CRF/eDT | UNIT | 原始单位 |
| EGSTRESC | Character Result/Finding in Std Format | text | Exp | Derived | — | 标准化字符结果 |
| EGSTRESN | Numeric Result/Finding in Standard Units | float | Perm | Derived | — | 标准化数值 |
| EGSTRESU | Standard Units | text | Perm | Derived | UNIT | 标准单位 |
| EGSTAT | Completion Status | text | Perm | CRF/eDT | ND | 未测量时为 NOT DONE |
| EGLOC | Location of Vital Signs Measurement | text | Perm | CRF | LOC | 测量位置 |
| EGBLFL | Baseline Flag | text | Exp | Derived | NY | 基线记录标记 Y |
| VISITNUM | Visit Number | float | Exp | Derived | — | |
| VISIT | Visit Name | text | Perm | Derived | — | |
| VISITDY | Planned Study Day of Visit | integer | Perm | Protocol | — | |
| EGDTC | Date/Time of Measurements | datetime | Exp | CRF/eDT | — | ISO 8601 |
| EGDY | Study Day of Vital Signs | integer | Perm | Derived | — | 相对参照起始日 |
| EGTPT | Planned Time Point Number | text | Perm | CRF | — | 计划时间点名称 |
| EGTPTNUM | Time Point Number | float | Perm | Assigned | — | 计划时间点编号 |
| EGELTM | Planned Elapsed Time from Time Point Ref | datetime | Perm | Protocol | — | ISO 8601 duration |
| EGTPTREF | Time Point Reference | text | Perm | CRF/Protocol | — | 时间点参照 |

---

## Codelist 值

### EGTESTCD / EGTEST（来自真实数据）
| EGTESTCD | EGTEST |
|----------|--------|
| ECGINT | ECG Interpretation |
| HR | Heart Rate |
| QT | QT Duration |
| RR | RR Duration |

### EGORRESU（Original Units，示例）
`BEATS/MIN`（心率）/ `msec`（时间间期）/ `LB`（ECG Interpretation 无单位占位）

### EGORRES（ECGINT 结果，来自真实数据）
`NORMAL` / `ABNORMAL`

---

## Dummy 数据示例（R，取自 pharmaversesdtm::eg 真实样本）

```r
library(tibble)

eg <- tibble(
  STUDYID  = "CDISCPILOT01",
  DOMAIN   = "EG",
  USUBJID  = "01-701-1015",
  EGSEQ    = c(1L, 2L, 3L, 4L),
  EGTESTCD = c("HR", "HR", "ECGINT", "ECGINT"),
  EGTEST   = c("Heart Rate", "Heart Rate",
               "ECG Interpretation", "ECG Interpretation"),
  EGORRES  = c("79", "52", "ABNORMAL", "ABNORMAL"),
  EGORRESU = c("BEATS/MIN", "BEATS/MIN", NA, NA),
  EGSTRESC = c("79", "52", "ABNORMAL", "ABNORMAL"),
  EGSTRESN = c(79, 52, NA, NA),
  EGSTRESU = c("beats/min", "beats/min", NA, NA),
  EGBLFL   = c(NA, "Y", NA, "Y"),
  VISITNUM = c(1, 3, 1, 3),
  VISIT    = c("SCREENING 1", "BASELINE", "SCREENING 1", "BASELINE"),
  EGDTC    = c("2013-12-26", "2014-01-02", "2013-12-26", "2014-01-02")
)
```
