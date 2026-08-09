# SDTM 数据集结构总览 (SDTMIG v3.4)

> 基于 CDISC SDTMIG v3.4 官方标准整理。
> 参考: CDISC SDTM v2.0 模型、CDISC Controlled Terminology。

---

## SDTM 核心概念

- [overview.md](overview.md) — 变量 Role / Core / Type / Origin、ISO 8601 日期格式、Study Day 计算、命名规则
- [SUPPQUAL.md](SUPPQUAL.md) — Supplemental Qualifiers 结构、10 固定变量、与父域关联方式

---

## 快速导航 — 常用域

### Special Purpose（特殊用途）

| Domain | 描述 | Structure | 变量数 | 详情 |
|--------|------|-----------|-------:|------|
| **DM** | Demographics | One record per subject | 26+ | [DM.md](DM.md) |
| **CO** | Comments | One record per comment | 7 | — |
| **SE** | Subject Elements | One record per element per subject | 8 | — |
| **SV** | Subject Visits | One record per visit per subject | 8 | — |

### Events（事件）

| Domain | 描述 | Structure | 详情 |
|--------|------|-----------|------|
| **AE** | Adverse Events | One record per AE per subject | [AE.md](AE.md) |
| **MH** | Medical History | One record per MH event per subject | [MH.md](MH.md) |
| **DS** | Disposition | One record per disposition event per subject | [DS.md](DS.md) |
| **DV** | Protocol Deviations | One record per deviation per subject | — |
| **CE** | Clinical Events | One record per event per subject | — |
| **HO** | Healthcare Encounters | One record per encounter | — |
| **BE** | Biospecimen Events | One record per event per subject | — |

### Interventions（干预）

| Domain | 描述 | Structure | 详情 |
|--------|------|-----------|------|
| **EX** | Exposure | One record per constant-dosing interval per treatment | [EX.md](EX.md) |
| **CM** | Concomitant/Prior Medications | One record per medication per subject | [CM.md](CM.md) |
| **EC** | Exposure as Collected | One record per collected dosing record | — |
| **PR** | Procedures | One record per procedure | — |
| **SU** | Substance Use | One record per substance use record | — |
| **AG** | Procedure Agents | One record per agent per procedure | — |
| **ML** | Meal Data | One record per meal event | — |

### Findings（检测/结果）

| Domain | 描述 | Structure | 详情 |
|--------|------|-----------|------|
| **LB** | Laboratory Test Results | One record per lab test per time point | [LB.md](LB.md) |
| **VS** | Vital Signs | One record per vital sign per time point | [VS.md](VS.md) |
| **EG** | ECG Test Results | One record per ECG measurement | [EG.md](EG.md) |
| **PE** | Physical Examination | One record per finding per time point | — |
| **QS** | Questionnaires | One record per questionnaire item | — |
| **RS** | Disease Response and Clinical Classification | One record per assessment | [RS.md](RS.md) |
| **TR** | Tumor/Lesion Results | One record per lesion measurement per time point | [TR.md](TR.md) |
| **TU** | Tumor/Lesion Identification | One record per lesion identified | [TU.md](TU.md) |
| **SC** | Subject Characteristics | One record per characteristic | — |
| **SS** | Subject Status | One record per status assessment | — |
| **DD** | Death Details | One record per death detail | — |
| **IE** | Inclusion/Exclusion Criteria Not Met | One record per unmet criterion | — |
| **DA** | Drug Accountability | One record per accountability record | — |
| **FA** | Findings About Events/Interventions | One record per finding about parent record | — |
| **IS** | Immunogenicity Specimen Assessments | One record per specimen per test | — |
| **PC** | Pharmacokinetics Concentrations | One record per sample per analyte | [PC.md](PC.md) |
| **PP** | Pharmacokinetics Parameters | One record per PK parameter | [PP.md](PP.md) |

### Trial Design（试验设计）— 无 USUBJID，Reference Data

| Domain | 描述 | Key Variables |
|--------|------|---------------|
| **TA** | Trial Arms | STUDYID, ARMCD, ARM, TAETORD, ETCD |
| **TE** | Trial Elements | STUDYID, ETCD, ELEMENT, TESTRL, TEENRL |
| **TV** | Trial Visits | STUDYID, VISITNUM, VISIT, VISITDY |
| **TD** | Trial Disease Assessments | STUDYID, TDORDER, TDANCVAR |
| **TI** | Trial Inclusion/Exclusion Criteria | STUDYID, IETESTCD, IETEST |
| **TM** | Trial Disease Milestones | STUDYID, MIDS, MIDTYPE |
| **TS** | Trial Summary Information | STUDYID, TSPARMCD, TSPARM, TSVAL |

### Relationship（关系）

| Domain | 描述 |
|--------|------|
| **SUPP--** | Supplemental Qualifiers → [SUPPQUAL.md](SUPPQUAL.md) |
| **RELREC** | Related Records (cross-domain links) |
| **RELSPEC** | Related Specimens |
| **RELSUB** | Related Subjects |

---

## 通用变量规则

| 位置 | 变量 | Core | 说明 |
|------|------|------|------|
| 1 | STUDYID | Req | 所有域第 1 个变量 |
| 2 | DOMAIN | Req | 所有域第 2 个变量（2 字符大写） |
| 3 | USUBJID | Req | 所有非 Trial Design 域第 3 个变量 |
| 4 | --SEQ | Req | 大多数域第 4 个变量（integer，记录唯一标识） |
| — | VISITNUM | Exp/Perm | 访视号（float） |
| — | VISIT | Perm | 访视名称（text） |
| — | EPOCH | Perm | 研究阶段，codelist: EPOCH |
| — | --DTC / --STDTC / --ENDTC | Exp/Perm | ISO 8601 datetime |
| — | --DY / --STDY / --ENDY | Perm | Study Day（integer，derived） |

---

## Core 说明

| Core | 含义 |
|------|------|
| **Req** | 必须存在且非空 |
| **Exp** | 预期存在；如缺失须在 Reviewer's Guide 中说明 |
| **Perm** | 可选；有收集时才包含 |

---

## 变量 Role 说明

| Role | 含义 | 示例 |
|------|------|------|
| Identifier | 唯一标识记录 | STUDYID, USUBJID, --SEQ |
| Topic | 观测的主题 | AETERM, LBTESTCD, EXTRT |
| Synonym Qualifier | Topic 的同义/标准名称 | AEDECOD, LBTEST |
| Record Qualifier | 描述观测的属性 | AESER, EXDOSE, LBORRES |
| Variable Qualifier | 修饰另一变量 | EXDOSU（修饰 EXDOSE）|
| Result Qualifier | 检测结果 | LBORRES, LBSTRESC, LBSTRESN |
| Grouping Qualifier | 分类 | --CAT, --SCAT |
| Timing | 日期/时间上下文 | VISITNUM, --DTC, --DY |

---

## 肿瘤研究常用域组合

```
肿瘤疗效评估:  TU → TR → RS
生存分析来源:  DS + RS + AE + MH
安全性分析:   AE (+ SUPPAE) + CM + EX
PK 分析:      EC → PC → PP
```
