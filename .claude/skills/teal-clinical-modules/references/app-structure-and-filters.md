# app 组装 + 过滤面板（teal_slices）

> `teal_slice`/`teal_slices` 来自 `teal.slice`（teal 已重新导出）。签名以本机
> `?teal.slice::teal_slice` 为准；下面用法已在本环境实测 `init()` 通过。

## init() 的整体结构

```r
app <- init(
  data    = data,                 # teal_data 对象
  modules = modules(              # 一个或多个 tm_* 模块（顺序即左侧导航顺序）
    tm_front_page(...),
    tm_t_summary(...),
    tm_g_km(...)
  ),
  filter  = teal_slices(          # 可选：全局过滤面板的初始过滤器
    teal_slice("ADSL", "SAFFL", selected = "Y")
  ),
  title   = "临床数据展示平台"     # 可选
)
shinyApp(app$ui, app$server)
```

- `modules()` 里模块的**先后顺序**就是 app 左侧/顶部导航的顺序。
- 也可以用 `modules(label = "分组名", modA, modB)` 把多个模块**分组**到一个下拉里。

## teal_slice() —— 定义单个过滤器

官方关键参数：
```r
teal_slice(dataname, varname, id, expr, choices, selected,
           keep_na, keep_inf, fixed, anchored, multiple, title, ...)
```
- `dataname`：数据集名（如 `"ADSL"`）。
- `varname`：要过滤的变量（如 `"SAFFL"`、`"AGE"`）。
- `selected`：初始选中的值/范围。分类变量给取值（`"Y"`）；数值变量给区间（`c(18, 65)`）。
- `fixed = TRUE`：锁死该过滤器，用户不能改。
- `keep_na` / `keep_inf`：是否保留缺失/无穷值。

例：
```r
teal_slice("ADSL", "SAFFL", selected = "Y")        # 只看安全性分析集
teal_slice("ADSL", "AGE",   selected = c(18, 64))  # 年龄区间
teal_slice("ADSL", "SEX",   selected = "F", fixed = TRUE)  # 锁定只看女性
```

## teal_slices() —— 打包多个过滤器

```r
filter = teal_slices(
  teal_slice("ADSL", "SAFFL", selected = "Y"),
  teal_slice("ADSL", "AGE",   selected = c(18, 64))
)
```
- 传给 `init(filter = ...)`，作为 app 启动时的**默认过滤**。
- 过滤是**跨数据集联动**的：按 join keys，过滤 ADSL 会同时影响 ADAE/ADTTE 里对应受试者。
- 用户仍可在运行时于右侧过滤面板增删过滤器（除非 `fixed = TRUE`）。

## 小抄
| 想要 | 写法 |
|---|---|
| 只看某分类取值 | `teal_slice("ADSL","SAFFL",selected="Y")` |
| 数值区间 | `teal_slice("ADSL","AGE",selected=c(18,64))` |
| 锁死不让改 | 加 `fixed = TRUE` |
| 多个默认过滤 | 都塞进 `teal_slices(...)` |
| 模块分组到一个下拉 | `modules(label="组名", modA, modB)` |
