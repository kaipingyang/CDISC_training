# 踩坑与规避

分两类：**官方要求**（任何环境都成立）与 **本环境实测**（版本/端点相关的规避）。

## 官方要求

### 1. 分组变量必须是 factor
`arm_var`、以及用作分层/分面的分类变量，所指向的列必须是 `factor`。
- 症状：打开表格页报 `Treatment variable is not a factor`。
- 原因：底层 `tern` 用 factor 的 levels 定义分组列。
- 官方示例数据 `tmc_ex_adsl/adae/adtte` 本就是 factor；用真实 ADaM（`pharmaverseadam` 等，多为 character）时需转换：
```r
data <- within(data, {
  ADSL <- pharmaverseadam::adsl
  ADSL <- dplyr::mutate(ADSL, dplyr::across(
    dplyr::any_of(c("ARM","ARMCD","ACTARM","ACTARMCD","SEX","RACE","ETHNIC","AGEGR1")), as.factor))
})
```
（用 `any_of()` 避免列不存在时报错；不要把 USUBJID 这类主键也转 factor。）

### 2. tm_g_km 的必填参数
`arm_var`、`paramcd`、`strata_var`、`facet_var` 无默认值，必须传。
- 症状：`argument "strata_var" is missing, with no default`（在 `init()` 阶段）。
- `facet_var` 不分面就 `selected = NULL`。

### 3. 选择器传数据框 vs 字符串
`variable_choices(ADSL, ...)`（数据框）立即解析；`variable_choices("ADSL", ...)`（字符串）延迟解析。
构造 app 时优先用从 `data[["ADSL"]]` 提取出来的数据框，最稳。

### 4. 列必须真实存在
`variable_choices`/`select` 里写的列名必须在数据里存在，否则报
`Column X doesn't exist` / `Must be a subset of {...}`。先 `names(df)` 确认。
例：`pharmaverseadam::adsl` 没有 `ITTFL`；其 TTE 数据集是 `adtte_onco` 且缺 `AVALU`。

## 本环境实测（版本/端点相关，非官方要求）

### 5. teal 默认 bslib 主题加载失败
- 症状：页面白屏，报 `File to import not found or unreadable: /rspm_builder/tmp/.../bslib/lib/bs5/scss/_functions.scss`。
- 根因：从 Posit Package Manager 装的 teal **二进制包**把构建机的 bslib 绝对路径冻结进了内置默认主题；该路径在运行机不存在。
- 规避：用本机新构建的主题覆盖（放在 `library(teal)` 之后）：
```r
options(teal.bs_theme = bslib::bs_theme(version = 5))
```
- 根治：从源码装 teal（`pak::pkg_install("insightsengineering/teal")`）。

### 6. tm_g_km 的 aval/cnsr/time_unit 延迟解析取不到
- 症状：`An analysis variable is required` / `A censor variable is required` / `time_unit_var ... Must have length 1`。
- 规避：用数据框显式指定（见 `figures.md` 的 tm_g_km 环境注意）。

### 7. shinychat / ellmer 开发版：会话标题生成报 400
- 场景：`chat_server()`（不是 querychat）默认会用 LLM 自动生成会话标题。
- 症状：`Title generation failed` / `HTTP 400 message must be json_object`。
- 根因（实测）：dev 版 shinychat 的 `generate_title()` 调 `chat_async(echo=)`，而 dev 版 ellmer 的 `chat_async()` 已无 `echo` 形参，`echo` 漏进请求体使 messages/content 变成 JSON 对象而非数组。
- 规避：关掉自动标题
```r
chat_server("my_chat", client = client, history = history_options(title = NULL))
```
- 非致命：仅影响历史侧栏标题，主聊天与 querychat 的 SQL/表格不受影响。

### 8. 无头浏览器验证 teal app 的要点
- teal 用 Bootstrap 5，导航是 `a[data-bs-toggle="tab"]`（不是 bs3 的 `data-toggle`）。
- 表格输出不是 `<table>` 直出，而在 `[id$="table-with-settings"]` 卡片内（`teal.widgets`）；KM 图在 `[id$="plot-with-settings"]` 里的 `<img>`。
- 同一个 app 实例被反复开关多个浏览器会话后可能"变钝"渲染不出——**每个模块用一个全新 app 实例**验证最可靠。
