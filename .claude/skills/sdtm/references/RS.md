# RS — Disease Response

> 数据来源：CDISC SDTMIG v3.4 (Findings class) + pharmaverse `pharmaversesdtm::rs_onco` 实际结构整理

## 数据集概览

| 项目 | 内容 |
|------|------|
| Domain | RS |
| 描述 | Disease Response and Clin Classification |
| Class | Findings |
| Structure | One record per response assessment per time point per evaluator per subject |
| Key Variables | STUDYID, USUBJID, RSTESTCD, RSEVAL, VISITNUM |
| 备注 | RS 是肿瘤三联域之一（TU 识别病灶 → TR 测量病灶 → RS 总体评估）。RS 记录基于 RECIST 1.1 等标准的缓解评估结果（RSCAT 指定标准）。RSTESTCD="OVRLRESP" 为总体反应，值 CR/PR/SD/PD/NE。RSLNKGRP 将同一次评估的目标/非目标/总体结果关联。RSEVAL 区分研究者（INVESTIGATOR）与独立评审（INDEPENDENT ASSESSOR）。RS 是派生 ADRS/ADTTE 的主要来源。 |

---

## 变量列表

| Variable | Label | Type | Core | Origin | Codelist | 说明 |
|----------|-------|------|------|--------|----------|------|
| STUDYID | Study Identifier | text | Req | Protocol | — | |
| DOMAIN | Domain Abbreviation | text | Req | Assigned | — | 固定 "RS" |
| USUBJID | Unique Subject Identifier | text | Req | Derived | — | 关联回 DM |
| RSSEQ | Sequence Number | integer | Req | Derived | — | 受试者内唯一序号 |
| RSLNKGRP | Link Group | text | Perm | Assigned | — | 关联 TR 同一次评估的分组 |
| RSTESTCD | Response Assessment Short Name | text | Req | Assigned | — | 评估短名，≤8 字符 |
| RSTEST | Response Assessment Name | text | Req | Assigned | — | 评估全名 |
| RSCAT | Category for Response Assessment | text | Exp | Assigned | — | 评估标准，如 RECIST 1.1 |
| RSORRES | Response Assessment Original Result | text | Exp | Collected | — | 原始缓解结果 |
| RSSTRESC | Response Assessment Result in Std Format | text | Exp | Derived | — | 标准化缓解结果 |
| RSSTAT | Completion Status | text | Perm | Collected | ND | NOT DONE |
| RSREASND | Reason Response Assessment Not Performed | text | Perm | Collected | — | 未评估原因 |
| RSEVAL | Evaluator | text | Exp | Assigned | EVAL | INVESTIGATOR / INDEPENDENT ASSESSOR |
| RSEVALID | Evaluator Identifier | text | Perm | Assigned | MEDEVAL | 评审人标识 |
| RSACPTFL | Accepted Record Flag | text | Perm | Derived | NY | 多评审时被采纳的记录 |
| VISITNUM | Visit Number | float | Exp | Derived | — | 访视序号 |
| VISIT | Visit Name | text | Perm | Derived | — | 访视名称 |
| RSDTC | Date/Time of Response Assessment | datetime | Exp | Collected | — | 缓解评估日期 |
| RSDY | Study Day of Response Assessment | integer | Perm | Derived | — | 相对参照日的研究日 |

---

## Codelist 值

### RSTESTCD / RSTEST（取自真实数据）
| RSTESTCD | RSTEST | 说明 |
|----------|--------|------|
| OVRLRESP | Overall Response | 总体缓解（最关键） |
| TRGRESP | Target Response | 目标病灶缓解 |
| NTRGRESP | Non-target Response | 非目标病灶缓解 |
| NEWLPROG | New Lesion Progression | 新病灶进展 |

### RSORRES / RSSTRESC（RECIST 1.1 缓解值）
| 值 | 含义 |
|----|------|
| CR | Complete Response（完全缓解） |
| PR | Partial Response（部分缓解） |
| SD | Stable Disease（疾病稳定） |
| PD | Progressive Disease（疾病进展） |
| NON-CR/NON-PD | 非完全缓解/非进展（用于非目标病灶） |
| NE | Not Evaluable（无法评估） |

### RSCAT
`RECIST 1.1`（真实数据中使用）；其他常见标准：`iRECIST` / `LUGANO 2014` / `RANO`

### RSEVAL
`INVESTIGATOR` / `INDEPENDENT ASSESSOR`

---

## Dummy 数据示例（R，取自 pharmaversesdtm::rs_onco 真实样本）

```r
library(tibble)

rs <- tibble(
  STUDYID  = "CDISCPILOT01",
  DOMAIN   = "RS",
  USUBJID  = "01-701-1015",
  RSSEQ    = 1:4,
  RSLNKGRP = c("R1-A2", NA, NA, "R2-A2"),
  RSTESTCD = c("OVRLRESP", "NTRGRESP", "TRGRESP", "OVRLRESP"),
  RSTEST   = c("Overall Response", "Non-target Response",
               "Target Response", "Overall Response"),
  RSCAT    = "RECIST 1.1",
  RSORRES  = c("PD", "PD", "PR", "SD"),
  RSSTRESC = c("PD", "PD", "PR", "SD"),
  RSEVAL   = "INDEPENDENT ASSESSOR",
  VISIT    = "WEEK 6",
  RSDTC    = "2014-02-12"
)
```
