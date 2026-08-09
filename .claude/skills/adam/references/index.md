# ADaM 数据集结构总览 (ADaM IG v1.3)

> 基于 CDISC ADaM IG v1.3 官方标准 + pharmaverse `pharmaverseadam` 实际结构整理。
> 变量数取自 pharmaverse 开源数据集或对应 CDISC/admiral 官方标准结构。

## 快速导航

| 数据集 | 描述 | 结构 (Structure) | 变量数 | 详情 |
|---|---|---|---:|---|
| **ADSL** | Subject-Level Analysis Dataset | One record per subject | 55 | [ADSL.md](ADSL.md) |
| **ADAE** | Adverse Event Analysis Dataset | One record per subject per adverse event (OCCDS) | 107 | [ADAE.md](ADAE.md) |
| **ADCM** | Concomitant Medications Analysis Dataset | One record per subject per medication record (OCCDS) | 95 | [ADCM.md](ADCM.md) |
| **ADMH** | Medical History Analysis Dataset | One record per subject per medical history event (OCCDS) | 114 | [ADMH.md](ADMH.md) |
| **ADDV** | Protocol Deviation Analysis Dataset | One record per subject per protocol deviation (OCCDS) | 20 | [ADDV.md](ADDV.md) |
| **ADPR** | Procedures Analysis Dataset | One record per subject per procedure (OCCDS) | 27 | [ADPR.md](ADPR.md) |
| **ADVS** | Vital Signs Analysis Dataset | One record per subject per parameter per analysis timepoint (BDS) | 105 | [ADVS.md](ADVS.md) |
| **ADEG** | ECG Analysis Dataset | One record per subject per parameter per analysis timepoint (BDS) | 108 | [ADEG.md](ADEG.md) |
| **ADLB** | Laboratory Analysis Dataset | One record per subject per parameter per analysis timepoint (BDS) | 115 | [ADLB.md](ADLB.md) |
| **ADLBHY** | Hy's Law Analysis Dataset | One record per subject per parameter per analysis date (BDS) | 14 | [ADLBHY.md](ADLBHY.md) |
| **ADLC** | Labs Analysis Dataset in Conventional Unit | One record per subject per parameter per analysis timepoint (BDS) | 34 | [ADLC.md](ADLC.md) |
| **ADEX** | Exposure Analysis Dataset | One record per subject per treatment per exposure record (BDS) | 92 | [ADEX.md](ADEX.md) |
| **ADPC** | PK Concentration Analysis Dataset | One record per subject per parameter per timepoint (BDS) | 128 | [ADPC.md](ADPC.md) |
| **ADPP** | PK Parameters Analysis Dataset | One record per subject per parameter per visit (BDS) | 79 | [ADPP.md](ADPP.md) |
| **ADRS** | Disease Response Analysis Dataset | One record per subject per parameter per analysis date (BDS) | 79 | [ADRS.md](ADRS.md) |
| **ADTR** | Tumor Result Analysis Dataset | One record per subject per parameter per visit per tumor (BDS) | 99 | [ADTR.md](ADTR.md) |
| **ADTTE** | Time-to-Event Analysis Dataset | One record per subject per parameter (BDS) | 20 | [ADTTE.md](ADTTE.md) |
| **ADTTEQS** | Time-to-Event (Questionnaire) Analysis Dataset | One record per subject per parameter (BDS) | 18 | [ADTTEQS.md](ADTTEQS.md) |
| **ADQS** | Questionnaires Analysis Dataset | One record per subject per parameter per analysis visit (BDS) | 30 | [ADQS.md](ADQS.md) |
| **ADECOG** | ECOG Performance Status Analysis Dataset | One record per subject per parameter per analysis date (BDS) | 27 | [ADECOG.md](ADECOG.md) |
| **ADIS** | Immunogenicity Specimen Analysis Dataset | One record per subject per parameter (BDS) | 24 | [ADIS.md](ADIS.md) |
| **ADBASE** | Baseline Characteristic Analysis Dataset | One record per subject per parameter (BDS) | 12 | [ADBASE.md](ADBASE.md) |

> 注：ADDV / ADPR / ADBASE / ADTTEQS 非 ADaM IG 官方命名标准，是 BDS/OCCDS 通用结构的应用范例；ADECOG / ADIS / ADLC 依据 CDISC QRS/ADA Supplement、FDA 技术规范等公开文档整理。各文件顶部脚注注明具体来源。

## 按类别分组

### Subject-Level (受试者层面)

| 数据集 | 描述 | 主键 (Key) | 详情 |
|---|---|---|---|
| **ADSL** | Subject-Level Analysis Dataset | `STUDYID, USUBJID` | [ADSL.md](ADSL.md) |
| **ADBASE** | Baseline Characteristic Analysis Dataset | `STUDYID, USUBJID, PARAMCD` | [ADBASE.md](ADBASE.md) |

### Adverse Events / Occurrence (不良事件/发生数据)

| 数据集 | 描述 | 主键 (Key) | 详情 |
|---|---|---|---|
| **ADAE** | Adverse Event Analysis Dataset | `STUDYID, USUBJID, AEDECOD, ASTDT` | [ADAE.md](ADAE.md) |
| **ADCM** | Concomitant Medications Analysis Dataset | `STUDYID, USUBJID, CMDECOD, ASTDT` | [ADCM.md](ADCM.md) |
| **ADMH** | Medical History Analysis Dataset | `STUDYID, USUBJID, MHDECOD` | [ADMH.md](ADMH.md) |
| **ADDV** | Protocol Deviation Analysis Dataset | `STUDYID, USUBJID, DVDECOD, ASTDT` | [ADDV.md](ADDV.md) |
| **ADPR** | Procedures Analysis Dataset | `STUDYID, USUBJID, PRDECOD, ASTDT` | [ADPR.md](ADPR.md) |

### Findings — Vital Signs / ECG / Labs (生理指标/实验室)

| 数据集 | 描述 | 主键 (Key) | 详情 |
|---|---|---|---|
| **ADVS** | Vital Signs Analysis Dataset | `STUDYID, USUBJID, PARAMCD, AVISITN, ADT` | [ADVS.md](ADVS.md) |
| **ADEG** | ECG Analysis Dataset | `STUDYID, USUBJID, PARAMCD, AVISITN, ADT` | [ADEG.md](ADEG.md) |
| **ADLB** | Laboratory Analysis Dataset | `STUDYID, USUBJID, PARAMCD, AVISITN, ADT` | [ADLB.md](ADLB.md) |
| **ADLBHY** | Hy's Law Analysis Dataset | `STUDYID, USUBJID, PARAMCD, ADT` | [ADLBHY.md](ADLBHY.md) |
| **ADLC** | Labs Analysis Dataset in Conventional Unit | `STUDYID, USUBJID, PARAMCD, AVISITN, ADT` | [ADLC.md](ADLC.md) |
| **ADECOG** | ECOG Performance Status Analysis Dataset | `STUDYID, USUBJID, PARAMCD, AVISITN, ADT` | [ADECOG.md](ADECOG.md) |

### Exposure (暴露)

| 数据集 | 描述 | 主键 (Key) | 详情 |
|---|---|---|---|
| **ADEX** | Exposure Analysis Dataset | `STUDYID, USUBJID, PARAMCD, ASTDT` | [ADEX.md](ADEX.md) |

### Tumor Response / Efficacy (肿瘤疗效)

| 数据集 | 描述 | 主键 (Key) | 详情 |
|---|---|---|---|
| **ADRS** | Disease Response Analysis Dataset | `STUDYID, USUBJID, PARAMCD, ADT` | [ADRS.md](ADRS.md) |
| **ADTR** | Tumor Result Analysis Dataset | `STUDYID, USUBJID, PARAMCD, AVISITN, TRLNKID` | [ADTR.md](ADTR.md) |

### Time-to-Event (生存分析)

| 数据集 | 描述 | 主键 (Key) | 详情 |
|---|---|---|---|
| **ADTTE** | Time-to-Event Analysis Dataset | `STUDYID, USUBJID, PARAMCD` | [ADTTE.md](ADTTE.md) |
| **ADTTEQS** | Time-to-Event (Questionnaire) Analysis Dataset | `STUDYID, USUBJID, PARAMCD` | [ADTTEQS.md](ADTTEQS.md) |

### PK / PD (药代/药效)

| 数据集 | 描述 | 主键 (Key) | 详情 |
|---|---|---|---|
| **ADPC** | PK Concentration Analysis Dataset | `STUDYID, USUBJID, PARAMCD, AVISITN, ATPTN` | [ADPC.md](ADPC.md) |
| **ADPP** | PK Parameters Analysis Dataset | `STUDYID, USUBJID, PARAMCD, AVISITN` | [ADPP.md](ADPP.md) |

### Questionnaires / PRO / Immunogenicity (量表/PRO/免疫原性)

| 数据集 | 描述 | 主键 (Key) | 详情 |
|---|---|---|---|
| **ADQS** | Questionnaires Analysis Dataset | `STUDYID, USUBJID, PARCAT1, PARAMCD, AVISITN, ADT` | [ADQS.md](ADQS.md) |
| **ADIS** | Immunogenicity Specimen Analysis Dataset | `STUDYID, USUBJID, PARAMCD, VISITNUM` | [ADIS.md](ADIS.md) |

## 关于 ADaM

**ADaM** (Analysis Data Model) 是 CDISC 标准之一，专为统计分析设计。其核心原则:
- **可追溯性 (Traceability)**: 每个分析变量可追溯到 SDTM 来源或派生方法
- **分析就绪 (Analysis-Ready)**: 数据集可直接用于统计程序而无需额外操作
- **一份数据集对应一个分析目的**: 每个 ADaM 数据集服务于特定的分析问题

### 三种基本结构

- **ADSL** — Subject-Level Analysis Dataset，每受试者一条记录，所有 ADaM 的基础
- **BDS** (Basic Data Structure) — 参数化长表，每受试者每参数每分析时点一条记录，如 `ADVS`/`ADLB`/`ADTTE`
- **OCCDS** (Occurrence Data Structure) — 发生类事件，每受试者每事件一条记录，如 `ADAE`/`ADCM`/`ADMH`/`ADDV`

### 命名规则

- `ADSL` — Subject-Level Analysis Dataset (one record per subject)
- `AD<domain>` — BDS/OCCDS datasets，如 `ADAE`, `ADLB`, `ADVS`
- `ADTTE*` — Time-to-Event datasets

### 通用变量

| 变量 | 含义 |
|---|---|
| `STUDYID` | Study Identifier |
| `USUBJID` | Unique Subject Identifier (主键) |
| `SUBJID` | Subject ID within Study |
| `SITEID` | Study Site Identifier |
| `TRTxxP` / `TRTxxA` | Planned / Actual Treatment for Period xx |
| `SAFFL`, `ITTFL`, `EFFFL` | Population Flags |
| `PARAM` / `PARAMCD` | Analysis Parameter Name / Code (BDS) |
| `AVAL` / `AVALC` | Analysis Value (Numeric / Character) (BDS) |
| `BASE` / `CHG` / `PCHG` | Baseline / Change / Percent Change (BDS) |
| `AVISIT` / `AVISITN` | Analysis Visit / Visit Number (BDS) |
| `ABLFL` | Baseline Record Flag |
| `ANLzzFL` | Analysis Flag (zz=01..99) |
