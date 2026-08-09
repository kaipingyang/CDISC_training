# 图形速查 — Clinical Figures with tern

> 数据来源：insightsengineering tern/rtables 官方文档 + pharmaverse TLG catalog

tern 的图形函数（`g_*` 前缀）是**基于 `ggplot2` 的高层封装**：它们内部用 ggplot2 绘图，但把临床图形常见的分组、统计标注、风险表（risk table）等都预制好了。**函数返回的是标准 `ggplot` 对象**，因此可以用 `ggplot2::ggsave()` 直接导出为 PNG/PDF，也可以用 `+` 继续叠加 ggplot2 图层微调。

所有示例数据来自 `pharmaverseadam` 公开数据集，STUDYID 为 `CDISCPILOT01`。

## 常用临床图形一览

| 图形 | 英文 | tern 函数 | 数据来源 | 关键变量 |
|------|------|----------|---------|---------|
| **KM 生存曲线** | Kaplan-Meier Curve | `g_km()` | ADTTE | `AVAL`, `CNSR`, `PARAMCD`, `ARM` |
| **均值折线图** | Mean Line Plot | `g_lineplot()` | ADLB / ADVS / ADPC | `AVAL`, `AVISIT`, `ARM`, `PARAMCD` |
| **瀑布图** | Waterfall Plot | 概念（见文末） | ADRS / ADTR | 每受试者最佳变化百分比 |

---

## 1. `g_km()` — KM 生存曲线

生存分析最核心的图。需要 **ADTTE**（Time-to-Event 数据集），其中：
- `AVAL` = 事件/删失时间，
- `CNSR` = 删失标志（1 = censored 删失，0 = event 发生事件），
- `PARAMCD` = 用来筛选具体终点（如 OS 总生存、PFS 无进展生存）。

```r
library(dplyr)
library(tern)
library(ggplot2)
library(pharmaverseadam)

adtte <- pharmaverseadam::adtte_onco %>%
  filter(PARAMCD == "OS") %>%                 # 筛选终点：总生存 OS
  mutate(
    ARM       = factor(ARM),
    is_event  = CNSR == 0                      # tern 用逻辑型 is_event 标记"发生事件"
  )

g <- g_km(
  df       = adtte,
  variables = list(
    tte    = "AVAL",                           # 时间
    arm    = "ARM",                            # 分组曲线
    is_event = "is_event"                      # 事件指示
  ),
  annot_surv_med = TRUE                        # 标注中位生存时间
)

g                                              # g 是 ggplot 对象，可直接打印
# ggsave("g_km_os.png", g, width = 9, height = 6, dpi = 300)
```

> `g_km()` 通常还会附带底部的 risk table（各时间点在险人数），并可叠加 log-rank p 值、HR 等统计标注（通过对应参数开启）。

---

## 2. `g_lineplot()` — 均值折线图

展示某参数随访视（visit）变化的**分组均值折线**（含误差棒），常用于实验室指标、生命体征、PK 浓度随时间的趋势。用 `control_lineplot_vars()` 集中配置绘图用到的变量映射。

```r
library(dplyr)
library(tern)
library(ggplot2)
library(pharmaverseadam)

adlb <- pharmaverseadam::adlb %>%
  filter(PARAMCD == "ALT", ANL01FL == "Y") %>%   # 举例：ALT 指标，选分析记录
  mutate(
    ARM    = factor(ARM),
    AVISIT = factor(AVISIT)                        # 因子化控制访视顺序
  )

g <- g_lineplot(
  df       = adlb,
  variables = control_lineplot_vars(
    x     = "AVISIT",                              # 横轴：访视
    y     = "AVAL",                                # 纵轴：分析值
    group_var = "ARM",                             # 分组：治疗组
    subject_var = "USUBJID"
  ),
  y_lab    = "ALT (U/L)",
  title    = "Mean (+/- SD) of ALT by Visit"
)

g
# ggsave("g_lineplot_alt.png", g, width = 10, height = 6, dpi = 300)
```

> `control_lineplot_vars()` 是 tern 的"配置构造器"模式：把绘图相关的变量名打包成一个 list 传给 `g_lineplot()`，比逐个传参更清晰。默认按分组每访视画 Mean ± SD。

---

## 3. 瀑布图（Waterfall Plot）概念

瀑布图把**每个受试者肿瘤负荷相对基线的最佳变化百分比**画成一根竖条，按数值从高到低排序，形似瀑布，是肿瘤疗效的经典图。

- 数据来源：ADRS / ADTR（先派生每受试者的"最佳变化百分比"，如 target lesion 最佳 `PCHG`）。
- 每根 bar = 一个受试者；bar 高度 = 变化百分比；常按响应类别（CR/PR/SD/PD）着色。
- tern/TLG catalog 提供瀑布图范例；也可直接用 `ggplot2::geom_bar(stat = "identity")` 对排序后的每受试者数据绘制。

由于瀑布图对数据预处理（每受试者取最佳值、排序、着色映射）要求较高，建议直接参考官方 TLG Catalog 的瀑布图范例套用，见 [catalog.md](catalog.md)。

---

## 导出与微调

因为所有 `g_*` 函数返回 **ggplot 对象**：

```r
library(ggplot2)

# 导出
ggsave("figure.png", g, width = 9, height = 6, dpi = 300)   # 位图
ggsave("figure.pdf", g, width = 9, height = 6)              # 矢量图（递交常用）

# 继续叠加 ggplot2 图层微调
g + theme_bw() + labs(caption = "Source: ADTTE")
```

---

表格速查见 [tables.md](tables.md)。更多即用图形代码见官方 **TLG Catalog**，导航见 [catalog.md](catalog.md)。
