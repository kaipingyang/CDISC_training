# ADLC — Laboratory Analysis Dataset (Conventional Units)

> 数据来源：FDA Technical Specifications(双单位提交) + CDISC多单位提交指南 + ADaM IG v1.3 BDS

## 数据集概览

| 项目 | 内容 |
|------|------|
| 数据集名称 | ADLC |
| 描述 | Laboratory Analysis Dataset in Conventional Units |
| Class | BDS (Basic Data Structure) |
| Structure | One record per subject per analysis parameter per analysis visit per analysis date |
| 用途 | 与 ADLB 同构的实验室分析数据集，但结果以常规单位（Conventional Unit）而非 SI 单位表示，供 FDA 双单位提交使用 |
| 主键 | STUDYID, USUBJID, PARAMCD, BASETYPE, AVISITN, ADT |
| 备注 | 结构完全对齐 ADLB。核心区别在于 AVAL/BASE/ANRLO/ANRHI 均为常规单位数值，通过单位换算系数从 SI 单位或采集单位转换得到 |

---

## 单位转换逻辑说明

FDA 要求肿瘤及部分领域实验室数据同时提供 SI 单位（ADLB）与常规单位（ADLC）两套数据集。ADLC 的数值变量由 ADLB 对应变量乘以参数级换算系数得到：

- `AVAL(conv) = AVAL(SI) × conversion_factor`（换算系数按 PARAMCD 在参数级元数据中定义）
- 参考范围 `ANRLO`/`ANRHI` 同步换算，保证 `ANRIND`（范围内/高/低）判定一致
- 单位标签 `AVALU` 记录常规单位（如 mg/dL、10^3/µL），而非 SI 单位（如 mmol/L、10^9/L）
- 毒性分级 `ATOXGR` 基于换算后数值与常规单位阈值重新判定

---

## 变量列表（共 34 个变量）

| Variable | Label | Type | Origin | 说明 |
|----------|-------|------|--------|------|
| STUDYID | Study Identifier | char | Predecessor | ADSL.STUDYID |
| USUBJID | Unique Subject Identifier | char | Predecessor | ADSL.USUBJID |
| SUBJID | Subject Identifier for the Study | char | Predecessor | ADSL.SUBJID |
| SITEID | Study Site Identifier | char | Predecessor | ADSL.SITEID |
| TRTP | Planned Treatment | char | Derived | 按 ADT 落入的分析期间取 ADSL.TRT0xP |
| TRTA | Actual Treatment | char | Derived | 按 ADT 落入的分析期间取 ADSL.TRT0xA |
| TRTSDT | Date of First Exposure to Treatment | num (Date) | Predecessor | ADSL.TRTSDT |
| LBSEQ | Sequence Number | num | Predecessor | LB.LBSEQ |
| PARAMCD | Parameter Code | char | Assigned | 实验室检测短代码 |
| PARAM | Parameter | char | Assigned | 检测名称（常规单位），LBTEST 与单位拼接 |
| PARAMN | Parameter (N) | num | Assigned | PARAM 的数值编码 |
| PARCAT1 | Parameter Category 1 | char | Assigned | 检测类别（如 CHEMISTRY、HEMATOLOGY） |
| AVISIT | Analysis Visit | char | Derived | 分析访视名；基线记录设为 "BASELINE" |
| AVISITN | Analysis Visit (N) | num | Derived | AVISIT 的数值 |
| ADT | Analysis Date | num (Date) | Derived | LB.LBDTC 的日期部分 |
| ADY | Analysis Relative Day | num | Derived | ADT ≥ TRTSDT 时 =(ADT−TRTSDT)+1，否则 =(ADT−TRTSDT) |
| AVAL | Analysis Value | num | Derived | 常规单位数值 = SI 值 × 换算系数 |
| AVALC | Analysis Value (C) | char | Derived | 字符型结果（如尿检定性），源自 LB.LBSTRESC |
| AVALU | Analysis Value Unit | char | Derived | 常规单位标签 |
| ABLFL | Baseline Record Flag | char | Derived | 基线记录设 "Y"，源自 LB.LBBLFL |
| BASE | Baseline Value | num | Derived | ABLFL="Y" 时的 AVAL（常规单位） |
| BASEC | Baseline Value (C) | char | Derived | ABLFL="Y" 时的 AVALC |
| BASETYPE | Baseline Type | char | Assigned | 区分中心/本地实验室基线（如 "CENTRAL"/"LOCAL"） |
| CHG | Change from Baseline | num | Derived | AVAL − BASE |
| PCHG | Percent Change from Baseline | num | Derived | (CHG / BASE) × 100 |
| ANRLO | Analysis Normal Range Lower Limit | num | Derived | 常规单位参考下限 |
| ANRHI | Analysis Normal Range Upper Limit | num | Derived | 常规单位参考上限 |
| ANRIND | Analysis Reference Range Indicator | char | Derived | NORMAL/HIGH/LOW，基于 AVAL 与 ANRLO/ANRHI |
| ATOXGR | Analysis Toxicity Grade | char | Derived | 基于常规单位阈值的 CTCAE 毒性分级 |
| BTOXGR | Baseline Toxicity Grade | char | Derived | ABLFL="Y" 时的 ATOXGR |
| SHIFT1 | Shift 1 | char | Derived | 基线到分析访视的等级移位（如 "NORMAL to HIGH"） |
| DTYPE | Derivation Type | char | Assigned | 标识经插补/衍生的记录（如 LOCF） |
| ANL01FL | Analysis Flag 01 | char | Derived | 基线及计划内访视后记录设 "Y" |
| ASEQ | Analysis Sequence Number | num | Derived | 按主键排序后每受试者从 1 递增 |

---

## Dummy 数据示例（R）

```r
library(tibble)

adlc <- tibble(
  STUDYID = "STUDY-001",
  USUBJID = c("STUDY-001-01-001", "STUDY-001-01-001",
              "STUDY-001-01-001", "STUDY-001-01-002",
              "STUDY-001-01-002", "STUDY-001-01-002"),
  PARAMCD  = "GLUC",
  PARAM    = "Glucose (mg/dL)",
  PARCAT1  = "CHEMISTRY",
  BASETYPE = "CENTRAL",
  AVISIT   = c("BASELINE", "WEEK 4", "WEEK 8",
               "BASELINE", "WEEK 4", "WEEK 8"),
  AVISITN  = c(0, 4, 8, 0, 4, 8),
  ADT      = as.Date(c("2024-01-10", "2024-02-07", "2024-03-06",
                       "2024-01-15", "2024-02-12", "2024-03-11")),
  AVAL     = c(90, 95, 110, 85, 88, 92),   # mg/dL (常规单位)
  AVALU    = "mg/dL",
  ANRLO    = 70,
  ANRHI    = 100,
  ANRIND   = c("NORMAL", "NORMAL", "HIGH",
               "NORMAL", "NORMAL", "NORMAL"),
  ABLFL    = c("Y", NA, NA, "Y", NA, NA),
  BASE     = c(90, 90, 90, 85, 85, 85),
  CHG      = c(NA, 5, 20, NA, 3, 7)
)
```
