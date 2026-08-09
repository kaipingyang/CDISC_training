# ADSL — Subject-Level Analysis Dataset

> 数据来源：CDISC ADaM IG v1.3（ADSL 章节）+ pharmaverse `admiral` 官方 ADSL vignette + `pharmaverseadam::adsl` 实际结构整理

## 数据集概览

| 项目 | 内容 |
|------|------|
| 数据集名称 | ADSL |
| 描述 | Subject-Level Analysis Dataset |
| Class | ADSL |
| Structure | One record per subject |
| 用途 | 所有 ADaM 数据集的基础，提供受试者级别的分组、暴露、终点日期等变量，供其他 BDS/OCCDS 数据集合并使用 |
| 主键 | STUDYID, USUBJID |
| 备注 | 基于 SDTM DM 域衍生，通常还需合并 EX（暴露）、DS（处置）等域。admiral 官方 vignette（`vignette("adsl")`）演示了本文件列出的绝大多数变量的标准派生方法。 |

---

## 变量列表（共 55 个变量，取自 `pharmaverseadam::adsl`）

| Variable | Label | Type | Origin | 说明 |
|----------|-------|------|--------|------|
| STUDYID | Study Identifier | char | Predecessor | DM.STUDYID |
| USUBJID | Unique Subject Identifier | char | Predecessor | DM.USUBJID |
| SUBJID | Subject Identifier for the Study | char | Predecessor | DM.SUBJID |
| SITEID | Study Site Identifier | char | Predecessor | DM.SITEID |
| COUNTRY | Country | char | Predecessor | DM.COUNTRY |
| RFSTDTC | Subject Reference Start Date/Time | char | Predecessor | DM.RFSTDTC |
| RFENDTC | Subject Reference End Date/Time | char | Predecessor | DM.RFENDTC |
| RFXSTDTC | Date/Time of First Study Treatment | char | Predecessor | DM.RFXSTDTC |
| RFXENDTC | Date/Time of Last Study Treatment | char | Predecessor | DM.RFXENDTC |
| RFPENDTC | Date/Time of End of Participation | char | Predecessor | DM.RFPENDTC |
| SCRFDT | Screen Failure Date | num (Date) | Derived | `derive_vars_dt()`，来自 DS 域筛选失败记录的日期 |
| FRVDT | Final Retrieval Visit Date | num (Date) | Derived | 来自 SV/DS 域末次访视日期 |
| DTHDTC | Date/Time of Death | char | Predecessor | DM.DTHDTC |
| DTHADY | Relative Day of Death | num | Derived | DTHDT - TRTSDT + 1 |
| DTHFL | Subject Death Flag | char | Predecessor | DM.DTHFL |
| LDDTHELD | Elapsed Days from Last Dose to Death | num | Derived | DTHDT - TRTEDT |
| LDDTHGR1 | Last Dose to Death - Days Elapsed Grp 1 | char | Derived | 按 LDDTHELD 分组（如 ≤30 天 / >30 天） |
| DTH30FL | Death Within 30 Days of Last Trt Flag | char | Derived | LDDTHELD ≤ 30 则 "Y" |
| DTHA30FL | Death After 30 Days from Last Trt Flag | char | Derived | LDDTHELD > 30 则 "Y" |
| DTHDOM | Domain for Date of Death Collection | char | Derived | 记录死亡日期来自哪个 SDTM 域（DM/DS/AE） |
| DTHB30FL | Death Within 30 Days of First Trt Flag | char | Derived | DTHDT - TRTSDT ≤ 30 则 "Y" |
| REGION1 | Geographic Region 1 | char | Derived | 按 COUNTRY 归类地理区域，`admiral::country_code_lookup` |
| DMDTC | Date/Time of Collection | char | Predecessor | DM.DMDTC |
| DMDY | Study Day of Collection | num | Derived | `derive_vars_dy()` |
| AGE | Age | num | Predecessor | DM.AGE |
| AGEU | Age Units | char | Predecessor | DM.AGEU |
| AGEGR1 | Pooled Age Group 1 | char | Derived | `derive_vars_cat()` 按年龄段分组，如 "<65"/"65-80"/">80" |
| SEX | Sex | char | Predecessor | DM.SEX |
| RACE | Race | char | Predecessor | DM.RACE |
| RACEGR1 | Pooled Race Group 1 | char | Derived | 按 RACE 归并为较少分组（如 "WHITE" / "NON-WHITE"） |
| ETHNIC | Ethnicity | char | Predecessor | DM.ETHNIC |
| SAFFL | Safety Population Flag | char | Derived | `derive_var_merged_exist_flag()`：TRTSDT 非缺失则 "Y" |
| ARM | Description of Planned Arm | char | Predecessor | DM.ARM |
| ARMCD | Planned Arm Code | char | Predecessor | DM.ARMCD |
| ACTARM | Description of Actual Arm | char | Predecessor | DM.ACTARM |
| ACTARMCD | Actual Arm Code | char | Predecessor | DM.ACTARMCD |
| TRT01P | Planned Treatment for Period 01 | char | Derived | 通常等于 ARM |
| TRT01A | Actual Treatment for Period 01 | char | Derived | 通常等于 ACTARM |
| TRTSDT | Date of First Exposure to Treatment | num (Date) | Derived | `derive_vars_merged()` 取 EX 域最早给药日期 |
| TRTSDTM | Datetime of First Exposure to Treatment | num (datetime) | Derived | 同上，含时间部分 |
| TRTSTMF | Time of First Exposure Imput. Flag | char | Derived | `derive_vars_dtm()` 的插补标志输出 |
| TRTEDT | Date of Last Exposure to Treatment | num (Date) | Derived | 取 EX 域最晚给药日期 |
| TRTEDTM | Datetime of Last Exposure to Treatment | num (datetime) | Derived | 同上，含时间部分 |
| TRTETMF | Time of Last Exposure Imput. Flag | char | Derived | 同 TRTSTMF |
| EOSSTT | End of Study Status | char | Derived | `derive_var_disposition_status()`，基于 DS 域 |
| EOSDT | End of Study Date | num (Date) | Derived | 来自 DS 域研究完成/退出日期 |
| RFICDTC | Date/Time of Informed Consent | char | Predecessor | DM.RFICDTC |
| RANDDT | Date of Randomization | num (Date) | Derived | 来自 DS 域 "RANDOMIZED" 里程碑日期 |
| LSTALVDT | Date Last Known Alive | num (Date) | Derived | 扫描各域完整日期取最晚的"存活确认"日期 |
| TRTDURD | Total Treatment Duration (Days) | num | Derived | TRTEDT - TRTSDT + 1 |
| DTHDT | Date of Death | num (Date) | Derived | `derive_vars_dt()` 解析 DM.DTHDTC，含部分缺失插补 |
| DTHDTF | Date of Death Imputation Flag | char | Derived | DTHDT 插补标志（D/M/Y） |
| DTHCAUS | Cause of Death | char | Derived | 来自 AE/DS/其他死因记录域 |
| DTHCGR1 | Cause of Death Reason 1 | char | Derived | 按 DTHCAUS 归类（如 "ADVERSE EVENT" / "PROGRESSIVE DISEASE" / "OTHER"） |
| BRTHDTC | Date/Time of Birth | char | Predecessor | DM.BRTHDTC |

---

## Dummy 数据示例（R，取自 pharmaverseadam::adsl 真实样本）

```r
library(tibble)

adsl <- tibble(
  STUDYID  = "CDISCPILOT01",
  USUBJID  = c("01-701-1015", "01-701-1023", "01-701-1028", "01-701-1033"),
  SUBJID   = c("1015", "1023", "1028", "1033"),
  SITEID   = c("701", "701", "701", "701"),
  AGE      = c(63, 64, 71, 76),
  AGEU     = "YEARS",
  AGEGR1   = c("65-80", "<65", "65-80", ">80"),
  SEX      = c("F", "M", "M", "F"),
  RACE     = c("WHITE", "WHITE", "WHITE", "WHITE"),
  ETHNIC   = c("HISPANIC OR LATINO", "HISPANIC OR LATINO",
               "NOT HISPANIC OR LATINO", "NOT HISPANIC OR LATINO"),
  ARM      = c("Placebo", "Placebo", "Xanomeline High Dose", "Xanomeline Low Dose"),
  ARMCD    = c("Pbo", "Pbo", "Xan_Hi", "Xan_Lo"),
  ACTARM   = ARM,
  ACTARMCD = ARMCD,
  SAFFL    = c("Y", "Y", "Y", "Y"),
  TRTSDT   = as.Date(c("2013-06-11", "2012-08-27", "2013-05-14", "2014-01-06")),
  TRTEDT   = as.Date(c("2014-07-01", "2013-09-01", "2014-06-30", "2014-08-15")),
  TRTDURD  = as.numeric(TRTEDT - TRTSDT) + 1,
  DTHFL    = c(NA_character_, NA_character_, NA_character_, "Y"),
  DTHDT    = as.Date(c(NA, NA, NA, "2014-09-02")),
  EOSSTT   = c("COMPLETED", "COMPLETED", "COMPLETED", "DISCONTINUED")
)
```
