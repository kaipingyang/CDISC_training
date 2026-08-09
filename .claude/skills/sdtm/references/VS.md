# VS — Vital Signs

> 数据来源：CDISC SDTMIG v3.4 (Findings class) + pharmaverse `pharmaversesdtm::vs` 实际结构整理

## 数据集概览

| 项目 | 内容 |
|------|------|
| Domain | VS |
| 描述 | Vital Signs |
| Class | Findings |
| Structure | One record per vital sign measurement per time point per subject |
| Key Variables | STUDYID, USUBJID, VSTESTCD, VISITNUM, VSTPTNUM |
| 备注 | VS 是典型 Findings 结构：原始值（VSORRES/VSORRESU）+ 标准化值（VSSTRESC/VSSTRESN/VSSTRESU）。每个访视、每个时间点、每种生命体征各一行。基线记录通过 VSBLFL="Y" 标识。 |

---

## 变量列表

| Variable | Label | Type | Core | Origin | Codelist | 说明 |
|----------|-------|------|------|--------|----------|------|
| STUDYID | Study Identifier | text | Req | Protocol | — | |
| DOMAIN | Domain Abbreviation | text | Req | Assigned | — | 固定 "VS" |
| USUBJID | Unique Subject Identifier | text | Req | Derived | — | 关联回 DM |
| VSSEQ | Sequence Number | integer | Req | Derived | — | 同一受试者内唯一序号 |
| VSTESTCD | Vital Signs Test Short Name | text | Req | Assigned | VSTESTCD | ≤8字符（如 SYSBP、DIABP、PULSE） |
| VSTEST | Vital Signs Test Name | text | Req | Assigned | VSTEST | 检测全称 |
| VSPOS | Vital Signs Position of Subject | text | Perm | CRF | POSITION | SUPINE / SITTING / STANDING |
| VSORRES | Result or Finding in Original Units | text | Exp | CRF | — | 原始结果（character） |
| VSORRESU | Original Units | text | Exp | CRF | UNIT | 原始单位 |
| VSSTRESC | Character Result/Finding in Std Format | text | Exp | Derived | — | 标准化字符结果 |
| VSSTRESN | Numeric Result/Finding in Standard Units | float | Exp | Derived | — | 标准化数值结果 |
| VSSTRESU | Standard Units | text | Exp | Derived | UNIT | 标准单位 |
| VSSTAT | Completion Status | text | Perm | CRF | ND | NOT DONE（未测量时填写） |
| VSLOC | Location of Vital Signs Measurement | text | Perm | CRF | LOC | 测量部位 |
| VSBLFL | Baseline Flag | text | Exp | Derived | NY | Y = 基线记录 |
| VISITNUM | Visit Number | float | Exp | Derived | — | 访视编号（用于排序） |
| VISIT | Visit Name | text | Perm | Assigned | — | 访视名称 |
| VISITDY | Planned Study Day of Visit | integer | Perm | Protocol | — | 计划研究日 |
| VSDTC | Date/Time of Measurements | datetime | Exp | CRF | — | 测量日期/时间 ISO 8601 |
| VSDY | Study Day of Vital Signs | integer | Perm | Derived | — | 相对参照日期的研究日 |
| VSTPT | Planned Time Point Name | text | Perm | CRF | — | 计划时间点名称 |
| VSTPTNUM | Planned Time Point Number | integer | Perm | CRF | — | 计划时间点编号 |
| VSELTM | Planned Elapsed Time from Time Point Ref | datetime | Perm | Protocol | — | 相对参考时间点的计划经过时间（ISO 8601 duration） |
| VSTPTREF | Time Point Reference | text | Perm | Protocol | — | 时间点参考基准 |

---

## Codelist 值

### VSTESTCD / VSTEST（常用生命体征测试代码）
| VSTESTCD | VSTEST |
|----------|--------|
| SYSBP | Systolic Blood Pressure |
| DIABP | Diastolic Blood Pressure |
| PULSE | Pulse Rate |
| TEMP | Temperature |
| WEIGHT | Weight |
| HEIGHT | Height |
| RESP | Respiratory Rate |
| OXYSAT | Oxygen Saturation |

### VSPOS（体位）
`SUPINE` / `SITTING` / `STANDING`

### VSORRESU / VSSTRESU（常见单位）
`mmHg`（血压）/ `beats/min`（脉搏）/ `C`（温度）/ `kg`（体重）/ `cm`（身高）/ `breaths/min`（呼吸）/ `%`（血氧）

---

## Dummy 数据示例（R，取自 pharmaversesdtm::vs 真实样本）

```r
library(tibble)

vs <- tibble(
  STUDYID  = "CDISCPILOT01",
  DOMAIN   = "VS",
  USUBJID  = "01-701-1015",
  VSSEQ    = c(1L, 2L, 3L, 4L),
  VSTESTCD = "DIABP",
  VSTEST   = "Diastolic Blood Pressure",
  VSORRES  = c("64", "83", "57", "68"),
  VSORRESU = "mmHg",
  VSSTRESN = c(64, 83, 57, 68),
  VSSTRESU = "mmHg",
  VISIT    = c("SCREENING 1", "SCREENING 1", "SCREENING 1", "SCREENING 2"),
  VSDTC    = c("2013-12-26", "2013-12-26", "2013-12-26", "2013-12-31")
)
```
