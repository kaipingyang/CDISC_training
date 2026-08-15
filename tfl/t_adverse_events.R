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
lyt <- basic_table(
  show_colcounts = TRUE,                             # 列标题显示每组 N
  title = "Table 14.2.1 Summary of Adverse Events",  # 表题
  subtitles = "Population: Safety Analysis Set",     # 分析人群
  main_footer = paste0(                               # 脚注
    "Source: ADAE, ADSL. Adverse events occurring during the treatment-emergent ",
    "period (TRTEMFL = Y); MedDRA System Organ Class and Preferred Terms."
  )
) %>%
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
  # 按首选术语（PT）计数发生受试者数
  count_occurrences(vars = "AEDECOD")

## ----r build-----------------------------------------------------------------
# 关键：alt_counts_df = adsl，让百分比分母取自 ADSL 的治疗组人数
tbl <- build_table(lyt, df = adae, alt_counts_df = adsl)

# 按发生频率排序 + 只保留发生率较高的 PT（教学示例，避免表格过长）
tbl_sorted <- tbl %>%
  prune_table() %>%
  sort_at_path(path = c("AEBODSYS", "*", "AEDECOD"), scorefun = score_occurrences)

print(tbl_sorted)

## ----r export----------------------------------------------------------------
dir <- tempdir()
export_as_txt(tbl_sorted, file = file.path(dir, "t_adverse_events.txt"))
cat("\n表格已导出:", file.path(dir, "t_adverse_events.txt"), "\n")

## ----r export-docx-----------------------------------------------------------
# 可选：导出为 Word 报告（rtables.officer 未安装时自动跳过）
# 横版 + 三线表（booktabs）+ Times New Roman；
# 标题/人群居中，脚注为表格下方的独立段落
if (requireNamespace("rtables.officer", quietly = TRUE)) {
  # 三线表 + Times New Roman 自定义主题（booktabs 只画三条横线）
  booktabs_tnr <- function(flx, ...) {
    flx %>%
      flextable::theme_booktabs() %>%
      flextable::font(fontname = "Times New Roman", part = "all")
  }
  dir.create("tfl/output", showWarnings = FALSE, recursive = TRUE)
  docx_file <- "tfl/output/t_adverse_events.docx"
  # 表格转 flextable：标题不进表格、去掉表内脚注、内容不加粗
  ft <- rtables.officer::tt_to_flextable(tbl_sorted, theme = booktabs_tnr, titles_as_header = FALSE) %>%
    flextable::delete_part(part = "footer") %>%
    flextable::bold(part = "all", bold = FALSE)

  # 标题/人群/脚注文本（单一来源：表对象上定义的 title/subtitles/main_footer）
  ttls <- formatters::all_titles(tbl_sorted)
  ftns <- formatters::all_footers(tbl_sorted)

  prop_title <- officer::fp_text(font.family = "Times New Roman", font.size = 14, bold = TRUE)
  prop_text  <- officer::fp_text(font.family = "Times New Roman", font.size = 11)
  prop_foot  <- officer::fp_text(font.family = "Times New Roman", font.size = 9)

  officer::read_docx() %>%
    officer::body_set_default_section(officer::prop_section(
      page_size = officer::page_size(orient = "landscape")
    )) %>%
    officer::body_add_fpar(officer::fpar(officer::ftext(ttls[1], prop = prop_title),
      fp_p = officer::fp_par(text.align = "center"))) %>%
    officer::body_add_fpar(officer::fpar(officer::ftext(paste(ttls[-1], collapse = " "), prop = prop_text),
      fp_p = officer::fp_par(text.align = "center"))) %>%
    flextable::body_add_flextable(ft) %>%
    officer::body_add_fpar(officer::fpar(officer::ftext(paste(ftns, collapse = " "), prop = prop_foot))) %>%
    print(target = docx_file)
  cat("Word 报告已导出:", docx_file, "\n")
}
