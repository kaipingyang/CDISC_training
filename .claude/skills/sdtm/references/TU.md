# TU — Tumor/Lesion Identification

> 数据来源：CDISC SDTMIG v3.4 (Findings class) + pharmaverse `pharmaversesdtm::tu_onco` 实际结构整理

## 数据集概览

| 项目 | 内容 |
|------|------|
| Domain | TU |
| 描述 | Tumor/Lesion Identification |
| Class | Findings |
| Structure | One record per identified tumor/lesion per evaluator per subject |
| Key Variables | STUDYID, USUBJID, TULNKID, TUEVAL |
| 备注 | TU 是肿瘤三联域之一（TU 识别病灶 → TR 测量病灶 → RS 总体评估）。TU 在基线识别每个病灶并分类为目标（TARGET）/非目标（NON-TARGET）/新病灶（NEW），记录其解剖位置（TULOC）与识别方法（TUMETHOD）。TULNKID 是病灶唯一标识，供 TR 通过 TRLNKID 引用各次访视的测量值。 |

---

## 变量列表

| Variable | Label | Type | Core | Origin | Codelist | 说明 |
|----------|-------|------|------|--------|----------|------|
| STUDYID | Study Identifier | text | Req | Protocol | — | |
| DOMAIN | Domain Abbreviation | text | Req | Assigned | — | 固定 "TU" |
| USUBJID | Unique Subject Identifier | text | Req | Derived | — | 关联回 DM |
| TUSEQ | Sequence Number | integer | Req | Derived | — | 受试者内唯一序号 |
| TULNKID | Link ID | text | Perm | Assigned | — | 病灶唯一标识；供 TR.TRLNKID 引用 |
| TUTESTCD | Tumor Identification Short Name | text | Req | Assigned | — | 识别短名，≤8 字符 |
| TUTEST | Tumor Identification Test Name | text | Req | Assigned | — | 识别全名 |
| TUORRES | Tumor Identification Result | text | Exp | Collected | TUMIDENT | 病灶分类，如 TARGET |
| TUSTRESC | Tumor Identification Result Std. Format | text | Exp | Derived | TUMIDENT | 标准化结果 |
| TULOC | Location of the Tumor | text | Perm | Collected | LOC | 病灶解剖位置 |
| TUMETHOD | Method of Identification | text | Exp | Collected | METHOD | 影像方法，如 CT SCAN |
| TUEVAL | Evaluator | text | Exp | Assigned | EVAL | INVESTIGATOR / INDEPENDENT ASSESSOR |
| TUEVALID | Evaluator Identifier | text | Perm | Assigned | MEDEVAL | 评审人标识 |
| TUACPTFL | Accepted Record Flag | text | Perm | Derived | NY | 多评审时被采纳的记录 |
| VISITNUM | Visit Number | float | Exp | Derived | — | 访视序号 |
| VISIT | Visit Name | text | Perm | Derived | — | 访视名称 |
| TUDTC | Date/Time of Tumor Identification | datetime | Exp | Collected | — | 识别日期（通常为基线影像日） |
| TUDY | Study Day of Tumor Identification | integer | Perm | Derived | — | 相对参照日的研究日 |

---

## Codelist 值

### TUTESTCD / TUTEST（取自真实数据）
| TUTESTCD | TUTEST | 说明 |
|----------|--------|------|
| TUMIDENT | Tumor Identification | 肿瘤/病灶识别 |

### TUORRES / TUSTRESC（病灶分类）
| 值 | 含义 |
|----|------|
| TARGET | 目标病灶 |
| NON-TARGET | 非目标病灶 |
| NEW | 新病灶 |

### TULOC（解剖位置，节选自真实数据，完整清单见 CDISC CT）
`ADRENAL GLAND` / `LYMPH NODE` / `BLADDER` / `BONE` / `BREAST` / `CHEST` / `BODY`

### TUMETHOD（影像方法）
`CT SCAN`（真实数据中使用）；其他常见：`MRI` / `PET-CT` / `ULTRASOUND` / `PHYSICAL EXAMINATION`

### TUEVAL
`INVESTIGATOR` / `INDEPENDENT ASSESSOR`

---

## TU → TR → RS 三联域关联示意

```
TU（每病灶一条，基线识别）:
  TULNKID="T01", TULOC="ADRENAL GLAND", TUORRES="TARGET", TUDTC="基线"
  TULNKID="T02", TULOC="LYMPH NODE",    TUORRES="TARGET"

TR（每病灶每访视一条，测量）:
  TRLNKID="T01", VISIT="BASELINE", LDIAM=10mm   ← 引用 TU 的 T01
  TRLNKID="T01", VISIT="WEEK 6",   LDIAM=...
  TRLNKID="T02", VISIT="BASELINE", DIAMETER=16mm

RS（每次评估一条，总体反应）:
  RSTESTCD="OVRLRESP", VISIT="WEEK 6", RSORRES="SD"  ← 汇总 TR 径线之和判定
```

---

## Dummy 数据示例（R，取自 pharmaversesdtm::tu_onco 真实样本）

```r
library(tibble)

tu <- tibble(
  STUDYID  = "CDISCPILOT01",
  DOMAIN   = "TU",
  USUBJID  = "01-701-1015",
  TUSEQ    = 1:4,
  TULNKID  = c("T01", "T02", "T03", "T04"),
  TUTESTCD = "TUMIDENT",
  TUTEST   = "Tumor Identification",
  TUORRES  = "TARGET",
  TUSTRESC = "TARGET",
  TULOC    = c("ADRENAL GLAND", "LYMPH NODE", "BLADDER", "BODY"),
  TUMETHOD = "CT SCAN",
  TUEVAL   = "INVESTIGATOR",
  VISIT    = "BASELINE"
)
```
