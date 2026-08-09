# DM — Demographics

> 数据来源：CDISC SDTMIG v3.4 (Special Purpose class) + pharmaverse `pharmaversesdtm::dm` 实际结构整理

## 数据集概览

| 项目 | 内容 |
|------|------|
| Domain | DM |
| 描述 | Demographics |
| Class | Special Purpose |
| Structure | One record per subject |
| Key Variables | STUDYID, USUBJID |
| 备注 | DM 是每个 SDTM 数据集提交的必备域，其他所有域都通过 USUBJID 关联回 DM。RFSTDTC/RFENDTC 等参照日期由程序衍生，用于计算各域的 Study Day（--DY）。 |

---

## 变量列表

| Variable | Label | Type | Core | Origin | Codelist | 说明 |
|----------|-------|------|------|--------|----------|------|
| STUDYID | Study Identifier | text | Req | Protocol | — | |
| DOMAIN | Domain Abbreviation | text | Req | Assigned | DM | 固定 "DM" |
| USUBJID | Unique Subject Identifier | text | Req | Derived | — | |
| SUBJID | Subject Identifier for the Study | text | Req | CRF | — | |
| RFSTDTC | Subject Reference Start Date/Time | datetime | Exp | Derived | — | 通常等于首次用药日期 |
| RFENDTC | Subject Reference End Date/Time | datetime | Exp | Derived | — | 通常等于末次用药日期或末次访视日期 |
| RFXSTDTC | Date/Time of First Study Treatment | datetime | Perm | Derived | — | 来自 EX 域最早给药日期 |
| RFXENDTC | Date/Time of Last Study Treatment | datetime | Perm | Derived | — | 来自 EX 域最晚给药日期 |
| RFICDTC | Date/Time of Informed Consent | datetime | Perm | CRF | — | |
| RFPENDTC | Date/Time of End of Participation | datetime | Perm | CRF/Derived | — | |
| DTHDTC | Date/Time of Death | datetime | Perm | CRF | — | |
| DTHFL | Subject Death Flag | text | Perm | Derived | NY | Y = 已死亡 |
| SITEID | Study Site Identifier | text | Req | CRF | — | |
| BRTHDTC | Date/Time of Birth | datetime | Perm | CRF | — | |
| AGE | Age | integer | Exp | CRF/Derived | — | |
| AGEU | Age Units | text | Exp | CRF/Assigned | AGEU | YEARS / MONTHS / WEEKS / DAYS |
| SEX | Sex | text | Req | CRF | SEX | M / F / U |
| RACE | Race | text | Exp | CRF | RACE | |
| ETHNIC | Ethnicity | text | Perm | CRF | ETHNIC | |
| ARMCD | Planned Arm Code | text | Req | Assigned | ARMCD | ≤20 字符 |
| ARM | Description of Planned Arm | text | Req | Assigned | ARM | |
| ACTARMCD | Actual Arm Code | text | Perm | Assigned | ARMCD | 与计划不符时才与 ARMCD 不同 |
| ACTARM | Description of Actual Arm | text | Perm | Assigned | ARM | |
| COUNTRY | Country | text | Req | CRF | COUNTRY | ISO 3166-1 alpha-3 |
| DMDTC | Date/Time of Collection | datetime | Perm | CRF | — | |
| DMDY | Study Day of Collection | integer | Perm | Derived | — | 相对 RFXSTDTC 的研究日 |
| ARMNRS | Reason Arm and/or Actual Arm is Null | text | Perm | CRF/Assigned | ARMNRS | 未入组/筛选失败等原因 |
| ACTARMUD | Description of Unplanned Actual Arm | text | Perm | Assigned | — | |

---

## Codelist 值

### AGEU
`YEARS` / `MONTHS` / `WEEKS` / `DAYS`

### SEX
`M` / `F` / `U`

### RACE（节选，完整清单见 CDISC CT）
`WHITE` / `BLACK OR AFRICAN AMERICAN` / `ASIAN` / `AMERICAN INDIAN OR ALASKA NATIVE` / `NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDER` / `OTHER`

### ETHNIC
`HISPANIC OR LATINO` / `NOT HISPANIC OR LATINO` / `NOT REPORTED` / `UNKNOWN`

---

## Dummy 数据示例（R，取自 pharmaversesdtm::dm 真实样本）

```r
library(tibble)

dm <- tibble(
  STUDYID  = "CDISCPILOT01",
  DOMAIN   = "DM",
  USUBJID  = c("01-701-1015", "01-701-1023", "01-701-1028", "01-701-1033"),
  SUBJID   = c("1015", "1023", "1028", "1033"),
  SITEID   = c("701", "701", "701", "701"),
  AGE      = c(63L, 64L, 71L, 76L),
  AGEU     = "YEARS",
  SEX      = c("F", "M", "M", "F"),
  RACE     = c("WHITE", "WHITE", "WHITE", "WHITE"),
  ETHNIC   = c("HISPANIC OR LATINO", "HISPANIC OR LATINO",
               "NOT HISPANIC OR LATINO", "NOT HISPANIC OR LATINO"),
  ARMCD    = c("Pbo", "Pbo", "Xan_Hi", "Xan_Lo"),
  ARM      = c("Placebo", "Placebo", "Xanomeline High Dose", "Xanomeline Low Dose"),
  COUNTRY  = "USA",
  RFSTDTC  = c("2013-06-11", "2012-08-27", "2013-05-14", "2014-01-06"),
  RFENDTC  = c("2014-07-01", "2013-09-01", "2014-06-30", "2014-08-15")
)
```
