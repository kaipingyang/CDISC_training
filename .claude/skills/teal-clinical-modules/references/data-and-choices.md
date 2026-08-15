# 数据准备 + 选择器（choices）

> 内容来自官方帮助：`?teal::init`、`?teal.data::join_keys`、`?teal.transform::choices_selected`、
> `?teal.transform::variable_choices`、`?teal.transform::value_choices`。

## 1. 构造 teal 数据对象

```r
data <- teal_data()
data <- within(data, {
  ADSL  <- tmc_ex_adsl          # teal.modules.clinical 内置示例数据
  ADAE  <- tmc_ex_adae
  ADTTE <- tmc_ex_adtte
})
# 按 CDISC 标准自动设置数据集间的主键/外键关系（ADSL<-ADAE 等）
join_keys(data) <- default_cdisc_join_keys[names(data)]
```

- `within(data, {...})` 里的赋值会被 teal 记录成可复现代码（这也是 teal 的 "Show R code" 能还原分析的原因）。
- 用真实 ADaM（如 `pharmaverseadam::adsl`）时，同样在 `within()` 里读入，并**在这里做必要的类型转换**（见 gotchas：factor 要求）。

构造模块的 `choices` 需要能访问到数据框，先提取出来：

```r
ADSL <- data[["ADSL"]]; ADAE <- data[["ADAE"]]; ADTTE <- data[["ADTTE"]]
```

## 2. `choices_selected()` — UI 下拉选项 + 默认值

官方 Usage：
```r
choices_selected(
  choices,
  selected = if (inherits(choices, "delayed_data")) NULL else choices[1],
  keep_order = FALSE,
  fixed = FALSE
)
```
- `choices`：可选项，字符向量，或 `variable_choices()`/`value_choices()` 返回的 `delayed_data`。
- `selected`：预选值。不传时默认取 `choices` 第一个。
- `fixed = TRUE`：锁定，用户不能改（常用于固定的分析变量，如 KM 的 `aval_var`）。
- `keep_order = TRUE`：保持 choices 原顺序（默认会把 selected 提到最前）。

## 3. `variable_choices(data, subset)` — 选“列名”

```r
variable_choices(data, subset = NULL, fill = FALSE, key = NULL)   # character 法
variable_choices(data, subset = NULL, fill = TRUE,  key = NULL)   # data.frame 法
```
- 从数据里挑**变量名**作为可选项，并自动带上变量 label。
- `data` 传**数据框**（如 `ADSL`）→ 立即解析；传**字符串**（如 `"ADSL"`）→ 延迟解析。
- `subset`：限定可选列，如 `c("ARM", "ARMCD")`。

例：`arm_var = choices_selected(variable_choices(ADSL, c("ARM","ARMCD")), "ARM")`

## 4. `value_choices(data, var_choices, var_label)` — 选“取值”

```r
value_choices(data, var_choices, var_label = NULL, subset = NULL, sep = " - ")
```
- 从**某一列的取值**里挑可选项（不是列名）。
- 典型用法是选 PARAMCD：从 ADTTE 的 PARAMCD 列取值，用 PARAM 列做显示 label：

例：`paramcd = choices_selected(value_choices(ADTTE, "PARAMCD", "PARAM"), "OS")`

## 小结：variable_choices vs value_choices

| 想让用户选 | 用哪个 | 例子 |
|---|---|---|
| 某个**变量/列** | `variable_choices` | 选用哪个 arm 变量（ARM / ARMCD） |
| 某列里的**具体取值** | `value_choices` | 选哪个 endpoint（PARAMCD = OS / PFS） |
