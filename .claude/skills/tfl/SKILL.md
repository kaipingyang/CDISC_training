---
name: tfl
description: 用 tern/rtables 创建 TFL（表格/图形/列表）代码。用户描述目标输出，自动生成分析报告代码。基于 CDISC ADaM 数据集和 pharmaverse 官方 TLG 技术栈。
trigger: tfl、TFL、tlg、TLG、table、表格、figure、图形、listing、列表、rtables、tern、生成表格、人口学表、AE表、KM图、生存曲线、demographic table、adverse event table、kaplan-meier
---

# TFL（Tables / Figures / Listings）代码生成助手

本 skill 帮助不熟悉 R 的临床数据人员，用自然语言描述目标输出（表格/图形/列表），自动生成基于 pharmaverse 官方 TLG 技术栈（tern + rtables）的分析报告代码。TFL 是临床研究报告的最终交付物，建立在 ADaM 分析数据集之上。本 skill 适合刚接触 R 的临床数据经理、统计程序员助手，以及需要快速原型的分析人员。

---

## 技术栈：tern 与 rtables 的关系

| 包 | 角色 | 学员是否直接用 |
|----|------|--------------|
| **rtables** | 底层布局引擎，提供 `basic_table()`/`split_cols_by()`/`build_table()` 管道骨架 | 用管道骨架 |
| **tern** | 基于 rtables 的临床高层封装，提供 `analyze_vars`/`count_occurrences`/`g_km` 等预制分析函数 | **主要调这层** |
| **rlistings** | 病人级列表（Listing） | 需要时用 |
| **ggplot2** | 图形底层，tern 的图形函数（g_km/g_lineplot）封装其上 | 导出图形时用 |

**核心心智模型：Layout 与 Data 分离** —— 先用 `basic_table()` 声明"表长什么样"（分几列、每行分析什么），再用 `build_table()` 把数据喂进去。这与 SDTM/ADaM 的规范化思路一致：结构和内容解耦。

详见 `references/overview.md`。

---

## 使用流程

### Step 1 - 确认输出类型

询问用户要生成哪类 TFL：
- **Table（表格）**：人口学特征表、AE 汇总表、实验室 shift 表等 → 见 `references/tables.md`
- **Figure（图形）**：KM 生存曲线、均值随访折线图、瀑布图等 → 见 `references/figures.md`
- **Listing（列表）**：病人级明细清单

### Step 2 - 确认输入 ADaM 数据集

询问：
- 用哪个 ADaM 数据集作为输入？（人口学表用 ADSL，AE 表用 ADAE+ADSL，KM 图用 ADTTE）
- 是否已有该数据集？没有的话可先用 `pharmaverseadam` 包的测试数据练习。
- 表格要按什么分列（通常是治疗组 ACTARM/ARM）、按什么分层？

### Step 3 - 套用五步骨架生成代码

所有 TFL 表格都遵循同一套五步骨架（图形类似，最后一步换成绘图函数）：

```
① 读入 ADaM 并预处理（df_explicit_na 显式化缺失、因子化分组变量）
② 定义 layout：basic_table() 起手 → split_cols_by(治疗组) → split_rows_by(分层)
③ 叠加 tern 分析函数（analyze_vars / count_occurrences / summarize_num_patients）
④ build_table(layout, data, alt_counts_df=...)   ← 注意分母
⑤ 格式化输出（标题脚注 → export_as_txt / ggsave）
```

根据用户需求，从下方模板中选择对应的代码提供给用户。

---

#### 模板 A：人口学特征表（入门，单数据集）

```r
library(rtables)
library(tern)
library(dplyr)

adsl <- pharmaverseadam::adsl |>
  filter(SAFFL == "Y") |>                              # 安全性人群
  mutate(SEX = factor(SEX), AGEGR1 = factor(AGEGR1), RACE = factor(RACE)) |>
  df_explicit_na()                                      # 显式化缺失值

# ① layout：按治疗组分列 + 合计列 + 分析4个变量
lyt <- basic_table(show_colcounts = TRUE) |>
  split_cols_by("ACTARM") |>
  add_overall_col("All Patients") |>
  analyze_vars(vars = c("AGE", "AGEGR1", "SEX", "RACE"))

# ② build：喂数据
tbl <- build_table(lyt, df = adsl)
print(tbl)

# ③ 导出
export_as_txt(tbl, file = file.path(tempdir(), "t_demographic.txt"))
```

---

#### 模板 B：AE 汇总表（中级，双数据集分母）

```r
library(rtables)
library(tern)
library(dplyr)

adsl <- pharmaverseadam::adsl |> filter(SAFFL == "Y") |> mutate(ACTARM = factor(ACTARM))
adae <- pharmaverseadam::adae |>
  filter(TRTEMFL == "Y", USUBJID %in% adsl$USUBJID) |>
  mutate(ACTARM = factor(ACTARM, levels = levels(adsl$ACTARM)))

lyt <- basic_table(show_colcounts = TRUE) |>
  split_cols_by("ACTARM") |>
  summarize_num_patients(var = "USUBJID", .stats = "unique",
                         .labels = c(unique = "Subjects with at least one AE")) |>
  split_rows_by("AEBODSYS", child_labels = "visible", nested = FALSE) |>
  summarize_num_patients(var = "USUBJID", .stats = "unique",
                         .labels = c(unique = "Subjects with at least one AE")) |>
  count_occurrences(vars = "AEDECOD")

# ★ 关键：alt_counts_df = adsl 让百分比分母取自 ADSL 治疗组人数
tbl <- build_table(lyt, df = adae, alt_counts_df = adsl) |>
  prune_table() |>
  sort_at_path(path = c("AEBODSYS", "*", "AEDECOD"), scorefun = score_occurrences)
print(tbl)
```

**★ alt_counts_df 分母概念（学员最易困惑处）**：ADAE 里只有"发生过 AE 的受试者"，没发生 AE 的人不在里面。所以百分比分母（每组总人数 N）不能从 ADAE 算，必须单独从 ADSL 传进来。**口诀：分子看 ADAE，分母看 ADSL。**

---

#### 模板 C：KM 生存曲线图（进阶，表→图）

```r
library(tern)
library(dplyr)
library(ggplot2)

anl <- pharmaverseadam::adtte_onco |>
  filter(PARAMCD == "OS") |>                            # 取总生存终点
  mutate(ARM = factor(ARM), is_event = (CNSR == 0))     # CNSR==0 表示事件发生

km_plot <- g_km(
  df = anl,
  variables = list(tte = "AVAL", is_event = "is_event", arm = "ARM"),
  annot_surv_med = TRUE,
  title = "Kaplan-Meier Plot of Overall Survival",
  xlab = "Time (Days)", ylab = "Survival Probability"
)

# g_km 返回 ggplot 对象，用 ggsave 导出
ggsave(file.path(tempdir(), "g_km_os.png"), km_plot, width = 10, height = 7, dpi = 150)
```

**CNSR 删失标志**：CNSR=1 表示删失（研究结束时事件未发生），CNSR=0 表示事件已发生。tern 需要 `is_event`，所以 `is_event = (CNSR == 0)`。

---

### Step 4 - 常用 tern 函数速查

| 函数 | 用途 | 适用输出 |
|------|------|---------|
| `analyze_vars()` | 连续变量算 n/Mean/SD/Median/Range，分类变量算计数/百分比 | 人口学表 |
| `count_occurrences()` | 按术语（如 AE PT）统计发生受试者数 | AE 表 |
| `summarize_num_patients()` | 去重统计受试者数（非事件数） | AE 表顶层 |
| `count_occurrences_by_grade()` | 按毒性分级统计 | 实验室毒性表 |
| `g_km()` | Kaplan-Meier 生存曲线 | 生存图 |
| `g_lineplot()` | 均值±误差随访折线图 | 实验室/PK 随访图 |
| `add_overall_col()` | 追加"合计"列 | 各类表格 |
| `split_cols_by()` / `split_rows_by()` | 按变量分列 / 分层 | 各类表格 |

更多函数和示例见 `references/tables.md`、`references/figures.md`。

---

### Step 5 - 遇到没见过的表格类型怎么办

**官方 TLG Catalog** 是最权威的资源，收录数百个即用 TLG 代码示例：
- TLG Catalog：https://insightsengineering.github.io/tlg-catalog/stable/
- tern GitHub：https://github.com/insightsengineering/tern
- rtables 文档：https://insightsengineering.github.io/rtables/

遇到本 skill 模板没覆盖的输出类型，去 TLG Catalog 搜对应的表/图，复制代码后把数据集名和变量名替换成自己的即可。详见 `references/catalog.md`。

---

## 铁律（Key Rules）

1. **Layout 先于 Data**：永远先声明布局再喂数据，不要在布局里写死具体数值。
2. **AE 表分母必须用 alt_counts_df**：否则百分比分母错误（会用 ADAE 的受试者数而非 ADSL 总数）。
3. **分组变量务必因子化**，且分子分母数据集的因子水平要一致（用 `levels=` 对齐），否则列对不上。
4. **不虚构统计量**：让 tern 函数算，不要手写统计逻辑再塞进表格。
5. **图形是 ggplot 对象**：g_* 函数返回 ggplot，用 ggsave 导出，可再叠加 ggplot2 图层微调。

---

## 常见问题解答

**Q：没有 ADaM 数据怎么练习？**
A：安装 `pharmaverseadam`，直接用 `pharmaverseadam::adsl`/`adae`/`adtte_onco` 等内置数据，无需真实数据即可运行所有模板。

**Q：AE 表百分比不对（分母错）怎么办？**
A：检查 `build_table()` 是否传了 `alt_counts_df = adsl`。没传的话分母会用 ADAE 里的受试者数，导致百分比偏高。

**Q：表格某列缺失（少一个治疗组）？**
A：分组变量因子化时，确认因子水平包含所有治疗组；分子数据集用 `factor(ACTARM, levels = levels(adsl$ACTARM))` 与分母对齐。

**Q：如何导出为其他格式？**
A：表格用 `export_as_txt()`（文本）、`as_html()`（网页）、`export_as_pdf()`（PDF）；图形用 `ggsave()` 存 PNG/PDF。

---

## 项目本地脚本参考

项目中已有完整可运行的 TFL 脚本，可作为参考：
- `tfl/t_demographic.R` - 人口学特征表完整示例（入门主线）
- `tfl/t_adverse_events.R` - AE 汇总表完整示例（含 alt_counts_df 分母）
- `tfl/g_km.R` - KM 生存曲线图完整示例

这些脚本已实测可运行（基于 pharmaverseadam 测试数据），如果本地脚本与模板有差异，以本地脚本为准。

---

## 下一步引导

TFL 生成后，若需要**交互式探索**分析数据集（动态筛选、切换参数），可以了解 pharmaverse 的 `teal` 框架——它把 tern/rtables 的输出包装成 Shiny 交互应用。这部分属于 Shiny/teal 的进阶主题，本 skill 不展开。
