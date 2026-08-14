# =============================================================================
# 输出名称：t_adverse_events（不良事件汇总表 Adverse Events Summary Table）
# =============================================================================
# 功能说明：
#   基于 ADAE（事件级）和 ADSL（受试者级）数据集，按治疗组分列，
#   按系统器官分类（SOC）分层，统计各首选术语（PT）的发生受试者数和百分比。
#   这是中级 TFL 表格，核心难点是"分母来自 ADSL"（alt_counts_df）。
#
# 使用的包：
#   - rtables      : 表格布局引擎
#   - tern         : 提供 summarize_num_patients / count_occurrences 等 AE 专用函数
#   - pharmaverseadam : ADaM 示例数据（ADAE + ADSL）
#
# 输入数据来源：
#   - pharmaverseadam::adae : ADAE 不良事件分析数据集（事件级，每事件一条记录）
#   - pharmaverseadam::adsl : ADSL 受试者级分析数据集（提供分母）
#
# 输出文件：
#   - t_adverse_events.txt（表格文本，写入 tempdir()）
#
# 关键概念说明（给不熟悉 R 的临床数据人员）：
#   ★ alt_counts_df（分母数据集）★ —— 这是 AE 表最容易困惑的地方：
#     ADAE 里只有"发生过 AE 的受试者"的记录，没发生 AE 的受试者根本不在里面。
#     所以百分比的分母（每个治疗组总人数 N）不能从 ADAE 算，必须单独从 ADSL 传进来。
#     口诀：分子看 ADAE（发生数），分母看 ADSL（总人数）。
#     build_table(..., alt_counts_df = adsl) 就是告诉 tern"分母去 ADSL 数"。
#   split_rows_by         : 按变量把行分成若干层（这里按系统器官分类 AEBODSYS）
#   summarize_num_patients: 统计每层有多少受试者发生了事件（去重计数，非事件数）
#   count_occurrences     : 统计每个首选术语 AEDECOD 的发生受试者数
# =============================================================================

# =============================================================================
# 【练习版】按 # TODO 提示填空。填不出就问 Claude Code："帮我补全这个 TODO"。
# 参考答案：tfl/t_adverse_events.R（完整版，别改它）—— 先自己填，卡住再看。
# =============================================================================

## ----r setup, message=FALSE, warning=FALSE-----------------------------------
library(rtables)
library(tern)
library(dplyr)

# 读入两个数据集：ADAE（分子）和 ADSL（分母）
adae <- pharmaverseadam::adae
adsl <- pharmaverseadam::adsl

## ----r prepare---------------------------------------------------------------
# 分母：安全性人群，治疗组转因子（列的顺序由因子水平决定）
adsl <- adsl %>%
  filter(SAFFL == "Y") %>%
  mutate(ACTARM = factor(ACTARM))

# 分子：治疗期内不良事件（TRTEMFL=="Y"），且受试者在安全性人群内
# ACTARM 因子水平必须与 adsl 保持一致，否则分子分母对不上
adae <- adae %>%
  filter(TRTEMFL == "Y", USUBJID %in% adsl$USUBJID) %>%
  mutate(ACTARM = factor(ACTARM, levels = levels(adsl$ACTARM)))

## ----r layout----------------------------------------------------------------
# 定义布局：按治疗组分列 → 顶层统计"发生任意 AE 的受试者数" →
#           按 SOC 分层 → 层内统计"该 SOC 的受试者数" → 再按 PT 计数
lyt <- basic_table(show_colcounts = TRUE) %>%
  split_cols_by("ACTARM") %>%
  # 顶层：发生至少一个 AE 的受试者总数
  summarize_num_patients(
    var = "USUBJID",
    .stats = "unique",
    .labels = c(unique = "Subjects with at least one AE")
  ) %>%
  # 按系统器官分类（SOC）分层
  split_rows_by(
    "AEBODSYS",
    child_labels = "visible",
    nested = FALSE,
    indent_mod = -1L
  ) %>%
  # 每个 SOC 内：发生该类 AE 的受试者数
  summarize_num_patients(
    var = "USUBJID",
    .stats = "unique",
    .labels = c(unique = "Subjects with at least one AE")
  ) %>%
  # TODO 1: 按首选术语（PT）计数每个 AEDECOD 的发生受试者数。
  #   count_occurrences 会对 vars 指定的变量逐个取值计数（去重到受试者）。
  # 👉 在这里补 count_occurrences(vars = "AEDECOD")，替换下面的 identity()
  identity()                                          # 占位：填好上面 TODO 后删掉这行 identity()

## ----r build-----------------------------------------------------------------
# TODO 2: build_table 时传入分母数据集（本脚本最重要的教学点）。
#   ADAE 里只有发生过 AE 的人，百分比分母（每组总人数 N）必须来自 ADSL。
#   口诀：分子看 ADAE，分母看 ADSL。
# 👉 给 build_table 补上 alt_counts_df = adsl 参数
tbl <- build_table(lyt, df = adae)   # ← 在这行补 alt_counts_df = adsl 参数

# 按发生频率排序 + 只保留发生率较高的 PT（教学示例，避免表格过长）
tbl_sorted <- tbl %>%
  prune_table() %>%
  sort_at_path(path = c("AEBODSYS", "*", "AEDECOD"), scorefun = score_occurrences)

print(tbl_sorted)

## ----r export----------------------------------------------------------------
dir <- tempdir()
export_as_txt(tbl_sorted, file = file.path(dir, "t_adverse_events.txt"))
cat("\n表格已导出:", file.path(dir, "t_adverse_events.txt"), "\n")
