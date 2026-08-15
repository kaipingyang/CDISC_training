---
name: teal-clinical-modules
description: >
  用 teal + teal.modules.clinical 搭建临床试验 TFL（表格/清单/图形）展示 app 时使用。
  覆盖 teal_data/join_keys 数据准备、choices_selected/variable_choices/value_choices
  选择器、以及 tm_front_page / tm_data_table / tm_t_summary / tm_t_events / tm_g_km
  这几个常用模块的官方参数与最小可运行示例。当用户提到 teal、teal.modules.clinical、
  tm_t_summary、tm_t_events、tm_g_km、ADSL/ADAE/ADTTE、KM 曲线、基线特征表、AE 表、
  choices_selected、"Treatment variable is not a factor"、临床 TFL 平台、
  交互展示 sdtm/adam/tfl 产物、pharmaverseadam 数据、CDISC_training 的 app 等关键词时触发。
---

# teal.modules.clinical 临床模块速查

面向用 `teal` 框架搭建临床 TFL 展示 app 的开发者。**所有参数说明和示例均来自已安装包的官方帮助文档（`?tm_*`）**，并标注了在本培训环境实测发现的注意事项。

> 版本基准（生成时）：`teal 1.2.0`、`teal.modules.clinical 0.13.0`、`teal.transform`、`teal.modules.general`。不同版本参数可能变化，**以本机 `?函数名` 为准**。

## 什么时候用这个 skill

- 要做临床数据的基线特征表、不良事件（AE）表、Kaplan-Meier 生存曲线等标准 TFL
- 搭 teal app 时不确定 `choices_selected` / `variable_choices` / `value_choices` 怎么配
- 遇到 teal 模块报错（如 arm 变量不是 factor、KM 缺参数）想快速定位

## 最小可运行 app 骨架

`teal.modules.clinical` 自带示例数据 `tmc_ex_adsl / tmc_ex_adae / tmc_ex_adtte`
（分类变量已是 factor、join key 齐全、含 AVALU），最省心：

```r
library(teal)
library(teal.modules.general)    # tm_data_table / tm_front_page 在这个包
library(teal.modules.clinical)   # tm_t_summary / tm_t_events / tm_g_km 在这个包

# 本环境需要：覆盖 teal 默认主题，否则页面白屏（详见 references/gotchas.md #5）
options(teal.bs_theme = bslib::bs_theme(version = 5))

data <- teal_data()
data <- within(data, {
  ADSL  <- tmc_ex_adsl
  ADAE  <- tmc_ex_adae
  ADTTE <- tmc_ex_adtte
})
join_keys(data) <- default_cdisc_join_keys[names(data)]

# 提取数据框用于构造 choices（变量名/取值在 UI 里的可选项）
ADSL <- data[["ADSL"]]; ADAE <- data[["ADAE"]]; ADTTE <- data[["ADTTE"]]

app <- init(
  data = data,
  modules = modules(
    tm_data_table(label = "数据清单"),
    tm_t_summary(
      label = "基线特征",
      dataname = "ADSL",
      arm_var = choices_selected(variable_choices(ADSL, c("ARM", "ARMCD")), "ARM"),
      add_total = TRUE,
      summarize_vars = choices_selected(variable_choices(ADSL, c("SEX", "RACE", "AGE")), c("SEX", "RACE"))
    )
  )
)
shinyApp(app$ui, app$server)
```

## 参考文档（按需阅读 references/）

teal 临床模块按 **TFL（Tables / Figures / Listings）** 组织，模块名有规律：
`tm_t_*` = 表格，`tm_g_*` = 图形，清单用数据表类模块。

- `references/data-and-choices.md` — 数据准备（teal_data/within/join_keys）+ 三个选择器（官方签名）
- `references/app-structure-and-filters.md` — `init()`/`modules()` 组装 + 过滤面板 `teal_slices`/`teal_slice`
- `references/tables.md` — **Tables（tm_t_\*）**：家族清单 + `tm_t_summary`（基线表）、`tm_t_events`（AE 表）详例
- `references/figures.md` — **Figures（tm_g_\*）**：家族清单 + `tm_g_km`（KM 曲线）详例
- `references/listings.md` — **Listings**：`tm_data_table`（数据清单）、患者档案、数据浏览 + `tm_front_page`（首页）
- `references/tlg-catalog.md` — 官方 **TLG Catalog**（标准输出编号 DMT01/AET01/KMG01… → teal 模块对照 + 查阅方法）
- `references/gotchas.md` — 实测踩过的坑与规避（factor 要求、KM 参数、主题、版本弃用等）

## 完整可运行范例（本项目 examples/）

完整对照范例在**原仓库**（shiny_training，私有）：
- `examples/app_v2.R` — 主范例：teal + 5 个模块 + `teal_slices` 过滤 + 主题规避，完整的临床 TFL 平台。
- `examples/app_v1.R` — 纯 bslib 仪表盘；`examples/app_v3.R` — querychat + ellmer 的 AI 数据问答。

## 本项目（CDISC_training）数据准备

本仓库的 app 用 `pharmaverseadam` 数据（与 `tfl/` 脚本同源）：
`adsl` / `adae` / `adtte_onco`。**三个数据集的分类变量全是 character**（已实证），
必须按 gotchas #1 转 factor。以下模板可直接用：

```r
data <- teal_data()
data <- within(data, {
  ADSL <- pharmaverseadam::adsl |> dplyr::mutate(
    ACTARM = factor(ACTARM, levels = c("Placebo", "Xanomeline High Dose", "Xanomeline Low Dose")),
    dplyr::across(dplyr::any_of(c("SEX", "RACE", "AGEGR1", "SAFFL")), as.factor)
  )
  ADAE <- pharmaverseadam::adae |> dplyr::mutate(
    ACTARM = factor(ACTARM, levels = levels(ADSL$ACTARM)),   # 分子分母 levels 对齐
    dplyr::across(dplyr::any_of(c("AEBODSYS", "AEDECOD", "AESEV", "TRTEMFL")), as.factor)
  )
  ADTTE <- pharmaverseadam::adtte_onco |>
    dplyr::filter(PARAMCD == "OS") |>
    dplyr::mutate(
      ARM      = factor(ARM),
      PARAMCD  = factor(PARAMCD),
      is_event = as.integer(CNSR == 0)   # tm_g_km 需要事件标志（CNSR 是 integer）
    )
})
join_keys(data) <- default_cdisc_join_keys[names(data)]
options(teal.bs_theme = bslib::bs_theme(version = 5))   # gotchas #5：主题白屏规避
```

注意：
- ACTARM 显式 levels 控制列顺序（默认字母序 High 在前，与 `tfl/` 脚本不一致）
- `adtte_onco` 无 `AVALU`（gotchas #4），`tm_g_km` 的 `time_unit_var` 传 NULL
- 学员做练习后，可把 `sdtm/output/`、`adam/output/` 的 xpt 换成上面的数据源来展示自己的产物

## 运行与部署（用姊妹技能）

本 skill 只管“怎么写 teal 模块”。要把 app 跑起来/发布，用这些技能：
- 在 Workbench 里运行 Shiny/teal app → `run-shiny`
- 部署到 Posit Connect / shinyapps.io → `rsconnect-deploy`（CI/CD 版：`rsconnect-cicd-deploy`）
- 无头浏览器验证 app 是否真渲染 → `shiny-browser-verify`
- bslib 布局/主题美化 → `shiny-bslib` / `shiny-bslib-theming`

## 高频注意事项（详见 gotchas.md）

1. **分组变量必须是 factor**：`arm_var`（以及做分层/分面的分类变量）指向的列必须是 `factor`，否则报 `Treatment variable is not a factor`。官方示例数据 `tmc_ex_*` 本就是 factor；若用 `pharmaverseadam` 等真实 ADaM（列多为 character），需在 `within()` 里 `mutate(across(..., as.factor))` 转换。
2. **`tm_g_km` 有必填参数**：`arm_var`、`paramcd`、`strata_var`、`facet_var` 在官方 Usage 里没有默认值 —— 必须提供（`facet_var` 可 `selected = NULL` 表示不分面）。
3. **choices 的两种写法**：`variable_choices(ADSL, ...)` 传**数据框**会立即解析；传**字符串**（如 `variable_choices("ADSL", ...)`）是延迟解析。构造 app 时用提取出来的数据框最稳。
4. 数据集之间要能 join：`join_keys(data) <- default_cdisc_join_keys[names(data)]`。
