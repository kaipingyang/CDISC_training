# Listings（L）+ 首页 / 数据浏览

teal 没有单独的 `tm_l_*` 命名；**清单（Listings）**通常用数据表模块直接展示受试者水平原始记录。
这些模块主要来自 `teal.modules.general`。

## tm_data_table —— 交互式数据清单（DT）

最常用的 Listing 模块，用 `DT` 渲染可分页/排序/筛选的表。

官方 Usage：
```r
tm_data_table(
  label = "Data Table",
  variables_selected = list(),       # 命名 list：每个数据集初始展示哪些列（默认前 6 列）
  datasets_selected = character(0),  # 展示哪些数据集及顺序（默认全部）
  dt_args = list(),                  # 传给 DT::datatable() 的额外参数
  dt_options = list(searching = FALSE, pageLength = 30,
                    lengthMenu = c(5, 15, 30, 100), scrollX = TRUE),
  server_rendering = FALSE, ...
)
```
例：
```r
tm_data_table(
  label = "受试者数据清单",
  datasets_selected = c("ADSL", "ADAE"),
  variables_selected = list(ADSL = c("USUBJID", "ARM", "AGE", "SEX"))
)
```

## 患者档案清单（Patient Profile，属 tm_t_* 但偏 Listing）
`teal.modules.clinical` 的 `tm_t_pp_basic_info` / `tm_t_pp_laboratory` /
`tm_t_pp_medical_history` / `tm_t_pp_prior_medication` 面向**单个受试者**列出其
基本信息、实验室、既往史、既往用药，常与 `tm_g_pp_*` 图配合做患者档案页。

## 数据浏览 / 质控辅助（teal.modules.general）
- `tm_variable_browser` — 逐变量浏览分布/类型（探索数据用）
- `tm_missing_data` — 缺失值概览
- `tm_outliers` — 离群值检查
- `tm_file_viewer` — 查看附带文件

---

## tm_front_page —— app 首页（非 TFL 的通用模块）

官方 Usage：
```r
tm_front_page(
  label = "Front page",
  header_text = character(0),   # 命名向量：名字加粗做小标题，值做正文
  tables = list(),              # 命名 list of data.frame
  additional_tags = tagList(),  # 额外 html/shiny 标签（图片等）
  footnotes = character(0),
  show_metadata = FALSE
)
```
例：
```r
tm_front_page(
  label = "首页",
  header_text = c("临床试验 TFL 展示平台" = "基于 teal.modules.clinical 示例数据"),
  footnotes = c("说明" = "仅用于培训演示")
)
```
