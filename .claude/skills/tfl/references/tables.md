# 表格类型速查 — Clinical Tables with tern

> 数据来源：insightsengineering tern/rtables 官方文档 + pharmaverse TLG catalog

本文件按"常用临床表格"和"tern 分析函数"两个角度速查。所有示例数据来自 `pharmaverseadam` 公开数据集（`adsl` / `adae` / `adtte_onco`），STUDYID 为 `CDISCPILOT01`。

## 一、常用临床表格

| 表格 | 英文 | 数据来源 | 核心 tern 函数 | 分母 (alt_counts_df) |
|------|------|---------|---------------|---------------------|
| **人口学特征表** | Demographic Characteristics | ADSL | `analyze_vars` | ADSL |
| **AE 汇总表** | Adverse Events (by SOC/PT) | ADAE | `summarize_num_patients` + `count_occurrences` | **ADSL** |
| **AE 按毒性分级表** | AE by Grade | ADAE | `count_occurrences_by_grade` | **ADSL** |
| **实验室 shift 表** | Laboratory Shift Table | ADLB | `count_patients_with_flags` / 交叉计数 | ADSL |

> 划重点：**所有事件类表格（AE、CM、MH）的分母都必须从 ADSL 传入**，原因见文末"alt_counts_df 分母概念"。

## 二、tern 分析函数速查

| 函数 | 用途 | 典型场景 |
|------|------|---------|
| `analyze_vars()` | 连续变量（n/Mean/SD/Median/Min/Max）或分类变量（n/%）汇总 | 年龄、身高、体重；性别、种族 |
| `count_occurrences()` | 对事件"发生次数/发生人数"计数 | AE 按 PT（首选术语）计数 |
| `summarize_num_patients()` | 受试者计数（多少人至少发生一次） | AE 表顶部"发生任一 AE 的受试者数" |
| `count_occurrences_by_grade()` | 按毒性分级（CTCAE Grade）计数 | AE 按最高分级汇总 |

---

### 1. `analyze_vars()` — 连续/分类汇总（人口学表核心）

对数值变量自动给出 n、Mean (SD)、Median、Min–Max；对因子变量给出各水平的 n (%)。

```r
library(dplyr)
library(rtables)
library(tern)
library(pharmaverseadam)

adsl <- pharmaverseadam::adsl %>%
  filter(SAFFL == "Y") %>%
  mutate(ARM = factor(ARM), SEX = factor(SEX)) %>%
  df_explicit_na()

lyt <- basic_table(show_colcounts = TRUE) %>%
  split_cols_by("ARM") %>%
  analyze_vars(
    vars = c("AGE", "SEX"),                      # 数值 + 分类混合
    var_labels = c("Age (years)", "Sex")
  )

tbl <- build_table(lyt, df = adsl, alt_counts_df = adsl)
tbl
```

---

### 2. `count_occurrences()` — 事件计数（AE PT 表核心）

统计每个 AE 首选术语（`AEDECOD` / PT）在各治疗组的发生人数与百分比。

```r
library(dplyr)
library(rtables)
library(tern)
library(pharmaverseadam)

adsl <- pharmaverseadam::adsl %>%
  filter(SAFFL == "Y") %>%
  mutate(ARM = factor(ARM)) %>%
  df_explicit_na()

adae <- pharmaverseadam::adae %>%
  filter(SAFFL == "Y") %>%
  mutate(ARM = factor(ARM), AEDECOD = as.character(AEDECOD)) %>%
  df_explicit_na()

lyt <- basic_table(show_colcounts = TRUE) %>%
  split_cols_by("ARM") %>%
  count_occurrences(vars = "AEDECOD")            # 按 PT 计数发生人数 (%)

tbl <- build_table(
  lyt,
  df = adae,                 # 主数据 = 事件表 ADAE
  alt_counts_df = adsl       # 分母 = ADSL（关键！）
)
tbl
```

---

### 3. `summarize_num_patients()` — 受试者计数

用于 AE 表顶部的"至少发生一次任一 AE 的受试者数 (%)"和"事件总数"这类汇总行。

```r
lyt <- basic_table(show_colcounts = TRUE) %>%
  split_cols_by("ARM") %>%
  summarize_num_patients(
    var = "USUBJID",
    .stats = c("unique", "nonunique"),           # unique=人数, nonunique=事件数
    .labels = c(
      unique    = "Subjects with at least one AE",
      nonunique = "Total number of AEs"
    )
  )

tbl <- build_table(lyt, df = adae, alt_counts_df = adsl)
tbl
```

---

### 4. `count_occurrences_by_grade()` — 按毒性分级计数

按 CTCAE 毒性分级（如 `AETOXGR` / `ATOXGR`）汇总，常用于"AE 按最高分级"表。

```r
adae <- pharmaverseadam::adae %>%
  filter(SAFFL == "Y") %>%
  mutate(
    ARM     = factor(ARM),
    AETOXGR = factor(AETOXGR, levels = c("1", "2", "3", "4", "5"))
  ) %>%
  df_explicit_na()

lyt <- basic_table(show_colcounts = TRUE) %>%
  split_cols_by("ARM") %>%
  count_occurrences_by_grade(
    var       = "AETOXGR",
    grade_groups = list(
      "Grade 1-2" = c("1", "2"),
      "Grade 3-4" = c("3", "4"),
      "Grade 5"   = "5"
    )
  )

tbl <- build_table(lyt, df = adae, alt_counts_df = adsl)
tbl
```

> 若要"按 SOC 分行、SOC 内再按 PT 汇总分级"，在 layout 里先 `split_rows_by("AESOC")` 再叠 `count_occurrences_by_grade()`，即体现 layout 的嵌套分行能力。

---

### 5. 实验室 shift 表（概念）

Shift 表展示"基线状态 → 访视后状态"的转移（如 Normal→High）。做法是把基线分类与分析时点分类交叉计数，通常先在数据里派生 `BNRIND`（基线范围指示）与 `ANRIND`（分析范围指示），再用 `split_rows_by("BNRIND")` + `split_cols_by` 分析时点分类做交叉表。ADLB 结构见 adam skill 的 `ADLB.md`。

---

## 三、重点：`alt_counts_df` 分母概念

这是 AE / 事件类表格**最容易出错**的地方，务必理解。

**问题**：AE 表要显示"某 AE 在治疗组内发生的百分比"，百分比 = 发生该 AE 的人数 ÷ **该组总人数**。但事件数据集 ADAE 里，**只记录了"发生过 AE 的受试者"**——一个从未发生任何 AE 的受试者，在 ADAE 里根本没有任何行。因此：

- 若直接用 ADAE 自己算分母，分母 = "发生过 AE 的人数"，**偏小**，百分比被高估，且总人数 N 也错。
- 正确做法：**分母必须来自 ADSL**（ADSL 每受试者一条记录，才是真正的"该组总人数"）。

**解法**：`build_table()` 的 `alt_counts_df` 参数专门用来指定"列头计数（分母）用哪个数据集"：

```r
build_table(
  lyt,
  df            = adae,     # 分子来源：事件表
  alt_counts_df = adsl      # 分母来源：ADSL（受试者层面，含未发生 AE 者）
)
```

记忆口诀：**"分子看事件（ADAE），分母看受试者（ADSL）"**。凡是 OCCDS 事件类表格（AE/CM/MH/DV），`alt_counts_df` 一律传 ADSL。人口学表因为主数据本身就是 ADSL，`alt_counts_df` 传 ADSL 即可（分子分母同源）。

---

更多即用表格代码见官方 **TLG Catalog**，导航见 [catalog.md](catalog.md)。图形速查见 [figures.md](figures.md)。
