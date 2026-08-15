# Tables（T）—— 表格模块 tm_t_*

teal 临床表格模块统一以 `tm_t_` 开头。**下面示例来自官方 `?tm_t_*` 帮助**，本环境已实测可渲染。

## tm_t_* 家族（teal.modules.clinical 0.13.0，共 24 个）

| 模块 | 用途 |
|---|---|
| `tm_t_summary` | 变量汇总 / 基线特征（Demographics） |
| `tm_t_summary_by` | 按某变量分组的汇总 |
| `tm_t_events` | 按术语的事件表（AE 表） |
| `tm_t_events_by_grade` | 按严重程度分级的事件表 |
| `tm_t_events_summary` / `tm_t_events_patyear` / `tm_t_mult_events` | 事件相关的其它汇总 |
| `tm_t_ancova` / `tm_t_coxreg` / `tm_t_logistic` / `tm_t_glm_counts` | 建模类表（ANCOVA / Cox / 逻辑回归 / 计数 GLM） |
| `tm_t_tte` | 生存分析表（Time-To-Event） |
| `tm_t_binary_outcome` | 二分类结局（有效性响应率等） |
| `tm_t_abnormality` / `tm_t_abnormality_by_worst_grade` | 实验室异常 |
| `tm_t_shift_by_arm` / `tm_t_shift_by_arm_by_worst` / `tm_t_shift_by_grade` | Shift 表 |
| `tm_t_exposure` / `tm_t_smq` | 暴露 / 标准化 MedDRA 查询 |
| `tm_t_pp_basic_info` / `tm_t_pp_laboratory` / `tm_t_pp_medical_history` / `tm_t_pp_prior_medication` | 患者档案（Patient Profile）表 |

> 另外 `teal.modules.general::tm_t_crosstable` 提供通用交叉表。
> 每个模块的完整参数以本机 `?tm_t_xxx` 为准；下面详述最常用的两个。

---

## tm_t_summary —— 基线特征表

官方 Usage（关键参数）：
```r
tm_t_summary(
  label, dataname,
  parentname = "ADSL",
  arm_var,                       # choices_selected：分组变量（治疗组），须是 factor
  summarize_vars,                # choices_selected：要汇总的变量（分类按计数，数值按统计量）
  add_total = TRUE,              # "All Patients" 合计列
  useNA = c("ifany", "no"),
  numeric_stats = c("n","mean_sd","mean_ci","median","median_ci","quantiles","range","geom_mean"),
  numeric_formats = NULL, denominator = c("N","n","omit"), ...
)
```
- `arm_var` 选两个变量时，第二个嵌套在第一个下。

官方示例：
```r
data <- teal_data()
data <- within(data, { ADSL <- tmc_ex_adsl; ADSL$EOSDY[1] <- NA_integer_ })
join_keys(data) <- default_cdisc_join_keys[names(data)]
ADSL <- data[["ADSL"]]

tm_t_summary(
  label = "Demographic Table",
  dataname = "ADSL",
  arm_var = choices_selected(c("ARM", "ARMCD"), "ARM"),
  add_total = TRUE,
  summarize_vars = choices_selected(
    c("SEX", "RACE", "BMRKR2", "EOSDY", "DCSREAS", "AGE"), c("SEX", "RACE")),
  numeric_formats = list("mean_ci" = "(xx.x, xx.x)"),
  useNA = "ifany"
)
```

---

## tm_t_events —— AE 表（按术语的事件）

官方 Usage（关键参数）：
```r
tm_t_events(
  label, dataname,               # dataname 通常 "ADAE"
  parentname = "ADSL",
  arm_var,                       # 分组变量（来自 ADSL），须是 factor
  hlt,                           # 高层术语：AEBODSYS / AESOC
  llt,                           # 低层术语：AEDECOD / AETERM
  add_total = TRUE,
  event_type = "event",          # 如 "adverse event"
  sort_criteria = c("freq_desc", "alpha"),
  incl_overall_sum = TRUE, ...
)
```

官方示例：
```r
data <- teal_data()
data <- within(data, { ADSL <- tmc_ex_adsl; ADAE <- tmc_ex_adae })
join_keys(data) <- default_cdisc_join_keys[names(data)]
ADSL <- data[["ADSL"]]; ADAE <- data[["ADAE"]]

tm_t_events(
  label = "Adverse Event Table",
  dataname = "ADAE",
  arm_var = choices_selected(c("ARM", "ARMCD"), "ARM"),
  llt = choices_selected(variable_choices(ADAE, c("AETERM", "AEDECOD")), "AEDECOD"),
  hlt = choices_selected(variable_choices(ADAE, c("AEBODSYS", "AESOC")), "AEBODSYS"),
  add_total = TRUE,
  event_type = "adverse event"
)
```
