# Figures（F/G）—— 图形模块 tm_g_*

teal 临床图形模块统一以 `tm_g_` 开头。KM 只是其中之一；先看家族全貌，再看 KM 详例。
**示例来自官方 `?tm_g_*` 帮助**，本环境已实测可渲染。

## tm_g_* 家族（teal.modules.clinical 0.13.0，共 11 个）

| 模块 | 用途 |
|---|---|
| `tm_g_km` | Kaplan-Meier 生存曲线 |
| `tm_g_forest_tte` | 生存分析森林图（子组 HR） |
| `tm_g_forest_rsp` | 响应率森林图 |
| `tm_g_lineplot` | 折线图（如均值随访视图随时间变化） |
| `tm_g_ci` | 置信区间图 |
| `tm_g_barchart_simple` | 简单条形图 |
| `tm_g_ipp` | 个体患者曲线（Individual Patient Plot） |
| `tm_g_pp_adverse_events` / `tm_g_pp_patient_timeline` / `tm_g_pp_therapy` / `tm_g_pp_vitals` | 患者档案（Patient Profile）图 |

> 通用绘图（非临床专用）在 `teal.modules.general`：`tm_g_scatterplot`、`tm_g_bivariate`、
> `tm_g_distribution`、`tm_g_association`、`tm_g_response`、`tm_g_scatterplotmatrix`。
> 每个模块参数以本机 `?tm_g_xxx` 为准。

---

## tm_g_km —— Kaplan-Meier 生存曲线（详例）

官方 Usage（关键参数，含默认值）：
```r
tm_g_km(
  label, dataname,               # dataname 通常 "ADTTE"
  parentname = "ADSL",
  arm_var,                       # 必填：分组变量（来自 ADSL），须是 factor
  arm_ref_comp = NULL,           # 可选：参考组/比较组（Cox）
  paramcd,                       # 必填：选 endpoint（PARAMCD 取值，如 OS）
  strata_var,                    # 必填：分层变量
  facet_var,                     # 必填：分面变量（不分面传 selected = NULL）
  time_unit_var = choices_selected(variable_choices(dataname, "AVALU"), "AVALU", fixed = TRUE),
  aval_var      = choices_selected(variable_choices(dataname, "AVAL"),  "AVAL",  fixed = TRUE),
  cnsr_var      = choices_selected(variable_choices(dataname, "CNSR"),  "CNSR",  fixed = TRUE),
  conf_level = ..., xticks = NULL, ...
)
```

### 必填参数
`arm_var`、`paramcd`、`strata_var`、`facet_var` 无默认值，必须提供，否则 `init()` 阶段报
`argument "strata_var" is missing, with no default`。不分面时 `facet_var = choices_selected(..., NULL)`。

### 官方示例
```r
library(nestcolor)
data <- teal_data()
data <- within(data, { ADSL <- tmc_ex_adsl; ADTTE <- tmc_ex_adtte })
join_keys(data) <- default_cdisc_join_keys[names(data)]
ADSL <- data[["ADSL"]]; ADTTE <- data[["ADTTE"]]

tm_g_km(
  label = "Kaplan-Meier Plot",
  dataname = "ADTTE",
  arm_var = choices_selected(variable_choices(ADSL, c("ARM", "ARMCD", "ACTARMCD")), "ARM"),
  paramcd = choices_selected(value_choices(ADTTE, "PARAMCD", "PARAM"), "OS"),
  strata_var = choices_selected(variable_choices(ADSL, c("SEX", "BMRKR2")), "SEX"),
  facet_var = choices_selected(variable_choices(ADSL, c("SEX", "BMRKR2")), NULL),
  xticks = c(0, 30, 60, 90, 120, 150, 180)
)
```

### 数据要求
- ADTTE 需含 `AVAL`、`CNSR`、`AVALU`、`PARAMCD`/`PARAM`（`tmc_ex_adtte` 都有；真实 TTE 若缺 `AVALU` 需补一列）。
- `arm_var` 指向的列须是 factor。

### 环境注意（实测，非官方要求）
官方 `aval_var`/`cnsr_var`/`time_unit_var` 默认用字符串 dataname 延迟解析，本环境下可能取不到，
报 `An analysis variable is required` 等。若遇到，改用数据框显式指定（详见 `gotchas.md #6`）。
