# ADTTEQS — Time-to-Event Questionnaire Analysis Dataset

> 数据来源：ADaM IG v1.3 TTE通用结构 + ADQS结构组合应用，FDA PRO/Time-to-Deterioration概念支撑（非ADaMIG官方命名标准）

## 数据集概览

| 项目 | 内容 |
|------|------|
| 数据集名称 | ADTTEQS |
| 描述 | Time-to-Event Questionnaire Analysis Dataset |
| Class | BDS (Basic Data Structure — Time-to-Event) |
| Structure | One record per subject per analysis parameter |
| 用途 | 分析问卷/量表相关的时间到事件终点，典型为"到确认恶化时间"（Time to Deterioration），如 PRO 症状恶化 |
| 主键 | STUDYID, USUBJID, PARAMCD |
| 备注 | TTE 结构，结合 ADQS 定义的恶化事件。CNSR=0 表示事件，CNSR=1 表示删失。ADaM IG v1.3 未定义官方 ADTTEQS，本文件为通用组合应用 |

---

## 变量列表（共 18 个变量）

| Variable | Label | Type | Origin | 说明 |
|----------|-------|------|--------|------|
| STUDYID | Study Identifier | char | Predecessor | ADSL.STUDYID |
| USUBJID | Unique Subject Identifier | char | Predecessor | ADSL.USUBJID |
| SUBJID | Subject Identifier for the Study | char | Predecessor | ADSL.SUBJID |
| SITEID | Study Site Identifier | char | Predecessor | ADSL.SITEID |
| TRTA | Actual Treatment | char | Predecessor | ADSL.TRT01A |
| TRTP | Planned Treatment | char | Predecessor | ADSL.TRT01P |
| PARAMCD | Parameter Code | char | Assigned | 如 "TTDPRO"（到 PRO 恶化时间） |
| PARAM | Parameter | char | Assigned | PARAMCD 的解码值 |
| PARAMN | Parameter (N) | num | Assigned | PARAM 的数值编码 |
| STARTDT | Time-to-Event Origin Date for Subject | num (Date) | Derived | 时间起点（锚点日期），通常为首次给药或随机日期 |
| ADT | Analysis Date | num (Date) | Derived | 事件或删失发生日期 |
| ADTF | Analysis Date Imputation Flag | char | Assigned | 插补标志：D=日插补，M=月日插补 |
| ADY | Analysis Relative Day | num | Derived | ADT ≥ STARTDT 时 =(ADT−STARTDT)+1，否则 =(ADT−STARTDT) |
| AVAL | Analysis Value | num | Derived | 事件/删失时间 = ADT − STARTDT + 1（天），可换算为月 |
| CNSR | Censor | num | Derived | 0=事件发生；1=删失 |
| EVNTDESC | Event Description | char | Derived | 事件描述（如 "Confirmed Deterioration"） |
| CNSDTDSC | Censor Date Description | char | Derived | 删失日期描述（如 "Last Assessment"） |
| SRCDOM | Source Domain | char | Assigned | 事件/删失日期来源域（如 "ADQS"） |

---

## Dummy 数据示例（R）

```r
library(tibble)

adtteqs <- tibble(
  STUDYID  = "STUDY-001",
  USUBJID  = c("STUDY-001-01-001", "STUDY-001-01-002",
               "STUDY-001-01-003", "STUDY-001-01-004"),
  PARAMCD  = "TTDPRO",
  PARAM    = "Time to PRO Deterioration",
  STARTDT  = as.Date(c("2024-01-10", "2024-01-15",
                       "2024-01-20", "2024-01-25")),
  ADT      = as.Date(c("2024-04-03", "2024-06-12",
                       "2024-03-11", "2024-05-20")),
  AVAL     = c(85, 149, 51, 116),
  CNSR     = c(0, 1, 0, 1),
  EVNTDESC = c("Confirmed Deterioration", NA,
               "Confirmed Deterioration", NA),
  CNSDTDSC = c(NA, "Last Assessment",
               NA, "Last Assessment"),
  SRCDOM   = "ADQS"
)
```
