# MH — Medical History

> 数据来源：CDISC SDTMIG v3.4 (Events class) + pharmaverse `pharmaversesdtm::mh` 实际结构整理

## 数据集概览

| 项目 | 内容 |
|------|------|
| Domain | MH |
| 描述 | Medical History |
| Class | Events |
| Structure | One record per medical history event per subject |
| Key Variables | STUDYID, USUBJID, MHDECOD, MHCAT |
| 备注 | MH 记录受试者的既往及现有病史，MHTERM 为 CRF 原始术语，MHDECOD 为经 MedDRA 编码后的 Preferred Term，MHBODSYS 为对应的 System Organ Class。MHCAT 区分诊断类别（原发诊断、既往病史、历史诊断）。 |

---

## 变量列表

> 以下变量基于 `pharmaversesdtm::mh` 真实 `names()`，Label 取自各列 `attr(., "label")`。

| Variable | Label | Type | Core | Origin | Codelist | 说明 |
|----------|-------|------|------|--------|----------|------|
| STUDYID | Study Identifier | text | Req | Protocol | — | |
| DOMAIN | Domain Abbreviation | text | Req | Assigned | MH | 固定 "MH" |
| USUBJID | Unique Subject Identifier | text | Req | Derived | — | 关联回 DM |
| MHSEQ | Sequence Number | integer | Req | Derived | — | 域内唯一序号 |
| MHSPID | Sponsor-Defined Identifier | text | Perm | CRF | — | CRF 行号等 |
| MHTERM | Reported Term for the Medical History | text | Req | CRF | — | CRF 原始病史术语 |
| MHLLT | Lowest Level Term | text | Perm | Derived | MedDRA | MedDRA LLT |
| MHDECOD | Dictionary-Derived Term | text | Perm | Derived | MedDRA | MedDRA PT |
| MHHLT | High Level Term | text | Perm | Derived | MedDRA | MedDRA HLT |
| MHHLGT | High Level Group Term | text | Perm | Derived | MedDRA | MedDRA HLGT |
| MHCAT | Category for Medical History | text | Perm | Assigned | — | 见下方 Codelist |
| MHBODSYS | Body System or Organ Class | text | Perm | Derived | MedDRA | MedDRA SOC |
| MHSEV | Severity/Intensity | text | Perm | CRF | SEV | MILD/MODERATE/SEVERE |
| VISITNUM | Visit Number | float | Perm | Derived | — | |
| VISIT | Visit Name | text | Perm | Derived | — | |
| VISITDY | Planned Study Day of Visit | integer | Perm | Protocol | — | |
| MHDTC | Date/Time of History Collection | datetime | Perm | CRF | — | ISO 8601 |
| MHSTDTC | Start Date/Time of Medical History Event | datetime | Perm | CRF | — | 病史开始日期，可为部分日期 |
| MHDY | Study Day of History Collection | integer | Perm | Derived | — | 相对参照起始日 |
| MHENDTC | End Date/Time of Medical History Event | datetime | Perm | CRF | — | 病史结束日期，持续中可为空 |
| MHPRESP | Medical History Event Pre-Specified | text | Perm | CRF | NY | 预设病史项标记 |
| MHOCCUR | Medical History Occurrence | text | Perm | CRF | NY | 预设项是否发生 |
| MHSTRTPT | Start Relative to Reference Time Point | text | Perm | CRF | STENRF | |
| MHENRTPT | End Relative to Reference Time Point | text | Perm | CRF | STENRF | |
| MHSTTPT | Start Reference Time Point | text | Perm | Derived | — | 起始参照点 |
| MHENTPT | End Reference Time Point | text | Perm | Derived | — | 结束参照点 |
| MHENRF | End Relative to Reference Period | text | Perm | CRF | STENRF | BEFORE/DURING/AFTER |
| MHSTAT | Completion Status | text | Perm | CRF | ND | 未采集时为 NOT DONE |

---

## Codelist 值

### MHCAT（Category，来自真实数据）
| 值 | 含义 |
|----|------|
| PRIMARY DIAGNOSIS | 原发诊断 |
| SIGNIFICANT PRE-EXISTING CONDITION | 重要既往合并状况 |
| HISTORICAL DIAGNOSIS | 历史诊断 |

### MHSEV（Severity，来自真实数据）
`MILD` / `MODERATE` / `SEVERE`

### MHENRF / MHENRTPT（相对参照）
`BEFORE` / `DURING` / `AFTER` / `ONGOING` / `U`

---

## Dummy 数据示例（R，取自 pharmaversesdtm::mh 真实样本）

```r
library(tibble)

mh <- tibble(
  STUDYID  = "CDISCPILOT01",
  DOMAIN   = "MH",
  USUBJID  = "01-701-1015",
  MHSEQ    = c(1L, 2L, 3L, 4L),
  MHTERM   = c("ALZHEIMER'S DISEASE", "PALPITATIONS",
               "HYSTERECTOMY", "HEADACHE"),
  MHDECOD  = c("Alzheimer's disease", "Palpitations",
               "Hysterectomy", "Headache"),
  MHBODSYS = c("Nervous system disorders", "Cardiac disorders",
               "Surgical and medical procedures",
               "Nervous system disorders"),
  MHCAT    = c("PRIMARY DIAGNOSIS", "SIGNIFICANT PRE-EXISTING CONDITION",
               "HISTORICAL DIAGNOSIS", "SIGNIFICANT PRE-EXISTING CONDITION"),
  MHSTDTC  = c("2010-04-30", NA, "1986", NA),
  MHENRF   = c("BEFORE", NA, NA, NA)
)
```
