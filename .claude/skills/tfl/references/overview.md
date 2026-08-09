# TFL 总览 — Tables / Figures / Listings

> 数据来源：insightsengineering tern/rtables 官方文档 + pharmaverse TLG catalog

## 什么是 TFL

**TFL**（也常写作 **TLG**，Tables / Listings / Graphs）是临床研究报告的最终产出物，供监管递交（CSR、submission package）使用。三者定位不同：

| 类型 | 英文 | 用途 | 典型例子 | 主要 R 包 |
|------|------|------|---------|-----------|
| **Table** | Tables | 汇总统计（sum­mary statistics），把多受试者数据聚合成行列结构 | 人口学特征表、AE 汇总表、实验室 shift 表 | `rtables` + `tern` |
| **Figure** | Figures / Graphs | 图形化展示趋势、分布、生存等 | KM 生存曲线、均值随访折线图、瀑布图 | `tern` + `ggplot2` |
| **Listing** | Listings | 逐条明细清单（不聚合），每条观测一行，供核查追溯 | AE 明细清单、死亡受试者清单 | `rlistings` |

一句话区分：**Table 是"算出来的汇总"，Listing 是"逐行的原始明细"，Figure 是"画出来的图"**。

## 技术栈分层：rtables 与 tern

pharmaverse 官方 TLG 栈是一个分层结构，学员应理解"底层引擎 + 高层封装"的关系：

```
┌─────────────────────────────────────────────┐
│  tern         临床高层封装（学员主要调用层）    │
│  提供预制分析函数：analyze_vars / count_*      │
│  g_km / g_lineplot 等，直接对应临床表格/图形    │
├─────────────────────────────────────────────┤
│  rtables      底层布局引擎                      │
│  basic_table / split_cols_by / split_rows_by  │
│  build_table，负责"表格结构"的声明与构建         │
├─────────────────────────────────────────────┤
│  rlistings    明细清单引擎（Listings 专用）      │
│  ggplot2      图形底层（Figures 由 tern 封装）   │
└─────────────────────────────────────────────┘
```

- **rtables** 是**底层布局引擎**：它定义了"表格如何分列、分行、如何嵌套"的通用机制，但不含任何临床统计逻辑。
- **tern** 是**基于 rtables 的临床高层封装**：它把"人口学汇总""AE 计数""按毒性分级计数"等常见临床分析，预制成一个个 `analyze_*` / `count_*` / `summarize_*` 函数，直接叠加到 rtables 的 layout 上。
- **学员绝大多数时候只需调用 tern 的高层函数**，把 rtables 当作 tern 的地基即可；只有在 tern 没有现成函数、需要自定义统计时才直接写 rtables 的 `analyze()`。

## 核心心智模型：Layout 与 Data 分离

这是理解整个 tern/rtables 栈的**最关键概念**，与 SAS PROC 的思维完全不同：

> **先声明"表长什么样"（layout），再把数据"喂"进去（build），两步彻底分开。**

- **Layout（布局）**：一个纯粹描述表格结构的对象——有几列、按什么分列、按什么分行、每个单元格算什么统计量。此时**还没有任何数据参与**，layout 只是"一张空的模板"。
- **Data（数据）**：真正的 ADaM 数据框。只有在 `build_table(layout, df)` 这一步，数据才被灌入 layout，算出最终结果。

这样分离带来的好处：
- **同一个 layout 可复用于不同数据集**（如换一个 population 子集重跑）。
- Layout 用**管道 `%>%`（或 `|>`）逐层叠加**，可读性强、易于逐段调试。
- 结构与内容解耦，改结构不动数据、改数据不动结构。

一个最小 layout 示意（还没有数据）：

```r
library(rtables)
library(tern)

lyt <- basic_table() %>%            # 起手：一张空表
  split_cols_by("ARM") %>%          # 声明：按治疗组 ARM 分列
  analyze_vars("AGE")               # 声明：对 AGE 做连续变量汇总

# 此刻 lyt 里没有任何数字，它只是"模板"
```

## 从 ADaM 到 TFL 的 5 步通用骨架

几乎所有 tern 表格都遵循同一套流程。记住这 5 步，套用到任何表格类型：

### ① 读入 ADaM 并预处理

关键动作：用 `df_explicit_na()` 把缺失值**显式化**（把 `NA` 转成可见的 `"<Missing>"` 类别，否则 tern 汇总时会漏计），并把分组变量**因子化**（factor，控制行/列的**出现顺序和是否显示零计数类别**）。

```r
library(dplyr)
library(pharmaverseadam)
library(tern)

adsl <- pharmaverseadam::adsl %>%
  filter(SAFFL == "Y") %>%                  # 先筛人群（如安全性人群）
  mutate(
    ARM = factor(ARM),                      # 治疗组因子化 → 控制列顺序
    SEX = factor(SEX)
  ) %>%
  df_explicit_na()                          # NA 显式化为 "<Missing>"
```

### ② 定义 layout（结构声明）

`basic_table()` 起手，`split_cols_by()` 按治疗组分列，`split_rows_by()` 按分层变量分行（可嵌套多层）。

```r
lyt <- basic_table(show_colcounts = TRUE) %>%   # show_colcounts 显示每列 N
  split_cols_by("ARM") %>%                       # 按治疗组分列
  split_rows_by("SEX")                           # 按性别分行分层（可选）
```

### ③ 叠加 tern 分析函数

在 layout 上继续用管道叠加 tern 的高层分析函数，声明每个单元格算什么。

```r
lyt <- lyt %>%
  analyze_vars(vars = "AGE")                      # 对 AGE 做 n/Mean/SD/Median 等汇总
```

### ④ build_table（灌入数据，注意分母 alt_counts_df）

`build_table(layout, df)` 把数据喂进 layout 得到结果表。**关键参数 `alt_counts_df`**：它指定"列头 N（分母）"来自哪个数据集。对于事件类数据（如 ADAE），事件数据集里**没有"没发生事件"的受试者**，所以分母必须单独从 ADSL 传入，否则百分比分母会错。

```r
result <- build_table(
  lyt,
  df = adsl,                 # 主数据（本例主数据即 ADSL）
  alt_counts_df = adsl       # 分母数据集；AE 表时这里传 ADSL 而非 ADAE
)
```

### ⑤ 格式化输出（标题脚注 / 导出）

加主标题、副标题、脚注，再导出为文本或其他格式。

```r
main_title(result) <- "Table 14.1 Demographic Characteristics"
subtitles(result) <- "Safety Population"
main_footer(result) <- "Source: ADSL"

result                                   # 控制台预览
# export_as_txt(result, file = "t_dm.txt")   # 导出为纯文本
```

## 小结

- **Table / Figure / Listing** 分别是"汇总 / 图形 / 明细"，服务于 CSR 不同章节。
- **tern 是临床高层封装，rtables 是底层布局引擎**，学员主要调 tern。
- **Layout 与 Data 分离**是核心：先声明结构，再 `build_table` 喂数据。
- 记住 **5 步骨架**：预处理 → 定 layout → 叠 tern 函数 → build（管好 `alt_counts_df` 分母）→ 格式化导出。

延伸阅读见 [tables.md](tables.md)（表格速查）、[figures.md](figures.md)（图形速查）、[catalog.md](catalog.md)（官方资源导航）。
