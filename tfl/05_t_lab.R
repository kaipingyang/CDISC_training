# =============================================================================
# 输出名称：t_lab（实验室检查汇总表 Laboratory Summary Table）
# =============================================================================
# 功能说明：
#   基于 ADLB 数据集，按治疗组分列，按实验室参数（PARAMCD）分层，
#   汇总各参数的 n/Mean(SD)/Median/Range，并统计各参数的异常率（ANRIND 分布）。
#   这是 BDS 结构 + 分类变量的典型汇总表。
#
# 使用的包：
#   - rtables      : 表格布局引擎
#   - tern         : 提供 analyze_vars / count_occurrences 等统计函数
#   - pharmaverseadam : ADaM 示例数据（ADLB）
#   - rtables.officer / flextable / officer : Word 报告导出（可选）
#
# 输入数据来源：
#   - pharmaverseadam::adlb : ADLB 实验室检查分析数据集（BDS 长表）
#
# 输出文件：
#   - t_lab.txt（表格文本，写入 tempdir()）
#   - t_lab.docx（Word 报告，写入 tfl/output/，rtables.officer 已安装时）
#
# 关键概念说明（给不熟悉 R 的临床数据人员）：
#   异常率（ANRIND）：每条实验室记录都带正常范围指示
#     NORMAL（正常）/ LOW（低于正常范围）/ HIGH（高于正常范围）
#   先按参数分层（split_rows_by），层内 analyze_vars 算数值统计量，
#   再用 count_occurrences 统计各参数的 NORMAL/LOW/HIGH 计数和百分比
# =============================================================================

## ----r setup, message=FALSE, warning=FALSE-----------------------------------
library(rtables)
library(tern)
library(dplyr)

# 读入 ADLB
adlb <- pharmaverseadam::adlb

## ----r prepare---------------------------------------------------------------
# 数据预处理：
# 1. 治疗组转因子（决定列顺序）
# 2. 参数代码转因子（决定分层顺序）
# 3. ANRIND 转因子（count_occurrences 需要分类变量）
# 4. AVALCAT1 作为"参数值的文本展示"保留（定性检验如尿液颜色）
adlb <- adlb %>%
  filter(SAFFL == "Y") %>%
  mutate(
    ACTARM = factor(ACTARM),
    PARAMCD = factor(PARAMCD),
    ANRIND = factor(ANRIND)
  ) %>%
  df_explicit_na()

## ----r layout----------------------------------------------------------------
# 定义布局：按治疗组分列 → 加合计列 → 按参数分层 → 数值统计 + 异常分布
lyt <- basic_table(
  show_colcounts = TRUE,
  title = "Table 14.2.5 Summary of Laboratory Results",
  subtitles = "Population: Safety Analysis Set",
  main_footer = paste0(
    "Source: ADLB. Percentages are based on the safety analysis set; ",
    "results are summarized using the analysis value (AVAL)."
  )
) %>%
  split_cols_by("ACTARM") %>%
  add_overall_col("All Patients") %>%
  split_rows_by(
    "PARAMCD",
    child_labels = "visible",
    nested = FALSE,
    indent_mod = -1L
  ) %>%
  analyze_vars(
    vars = "AVAL",
    .stats = c("n", "mean_sd", "median", "range")
  ) %>%
  count_occurrences(vars = "ANRIND")

## ----r build-----------------------------------------------------------------
# 把数据喂进布局，生成最终表格
tbl <- build_table(lyt, df = adlb)

# 在控制台打印（参数较多，打印前 12 行示意）
print(head(tbl, 12))

## ----r export----------------------------------------------------------------
# 导出为文本文件
dir <- tempdir()
export_as_txt(tbl, file = file.path(dir, "t_lab.txt"))
cat("\n表格已导出:", file.path(dir, "t_lab.txt"), "\n")

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
  docx_file <- "tfl/output/t_lab.docx"
  # 表格转 flextable：标题不进表格、去掉表内脚注、内容不加粗
  ft <- rtables.officer::tt_to_flextable(tbl, theme = booktabs_tnr, titles_as_header = FALSE) %>%
    flextable::delete_part(part = "footer") %>%
    flextable::bold(part = "all", bold = FALSE)

  # 标题/人群/脚注文本（单一来源：表对象上定义的 title/subtitles/main_footer）
  ttls <- formatters::all_titles(tbl)
  ftns <- formatters::all_footers(tbl)

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
