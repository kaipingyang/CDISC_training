# =============================================================================
# 输出名称：t_vitals（生命体征汇总表 Vital Signs Summary Table）
# =============================================================================
# 功能说明：
#   基于 ADVS 数据集，按治疗组分列，按生命体征参数（PARAMCD）分层，
#   汇总各参数的 n/Mean(SD)/Median/Min-Max。这是 BDS 结构数据的典型汇总表。
#
# 使用的包：
#   - rtables      : 表格布局引擎
#   - tern         : 提供 analyze_vars 等预制统计函数
#   - pharmaverseadam : ADaM 示例数据（ADVS）
#   - rtables.officer / flextable / officer : Word 报告导出（可选）
#
# 输入数据来源：
#   - pharmaverseadam::advs : ADVS 生命体征分析数据集（BDS 长表）
#
# 输出文件：
#   - t_vitals.txt（表格文本，写入 tempdir()）
#   - t_vitals.docx（Word 报告，写入 tfl/output/，rtables.officer 已安装时）
#
# 关键概念说明（给不熟悉 R 的临床数据人员）：
#   BDS 长表：每行是"一个受试者 × 一个参数 × 一次访视"的测量，
#     汇总时先按参数分层（split_rows_by），再在层内对分析值 AVAL 算统计量。
#   PARAMCD：参数代码（SYSBP/DIABP/PULSE/TEMP/WEIGHT/HEIGHT/MAP/BMI/BSA）
#   analyze_vars 对连续变量默认算 n/Mean/SD/Median/Min-Max
# =============================================================================

# =============================================================================
# 【练习版】按 # TODO 提示填空。填不出就问 Claude Code："帮我补全这个 TODO"——
# 练习模式只会给提示，不会直接读答案，也不会替你写完整版。
# 写完自查：跟 Claude Code 说"我写完了，帮我对照检查"，它会逐条说明差异。
# 项目根的 sdtm/ adam/ tfl/ 是完整答案脚本（供对照，勿改），练习时不要读/改它们。
# =============================================================================

## ----r setup, message=FALSE, warning=FALSE-----------------------------------
library(rtables)
library(tern)
library(dplyr)

# 读入 ADVS
advs <- pharmaverseadam::advs

## ----r prepare---------------------------------------------------------------
# 数据预处理：
# 1. 治疗组转因子（决定列顺序）
# 2. 参数代码转因子（决定分层顺序）
# 3. 显式化缺失值
advs <- advs %>%
  filter(SAFFL == "Y") %>%
  mutate(
    ACTARM = factor(ACTARM),
    PARAMCD = factor(PARAMCD)
  ) %>%
  df_explicit_na()

# 给分析变量加上易读的标签
formatters::var_labels(advs)[c("AVAL")] <- "Value"

## ----r layout----------------------------------------------------------------
# 定义布局：按治疗组分列 → 加合计列 → 按参数分层 → 层内分析 AVAL
lyt <- basic_table(
  show_colcounts = TRUE,
  # TODO 1: 补上表题/人群/脚注（临床报告必须的页眉页脚）
  #   title = "Table 14.1.3 Summary of Vital Signs"
  #   subtitles = "Population: Safety Analysis Set"
  #   main_footer = "Source: ...ADVS ..."
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
    .stats = c("n", "mean_sd", "median", "min_max")
  )

## ----r build-----------------------------------------------------------------
# 把数据喂进布局，生成最终表格
tbl <- build_table(lyt, df = advs)

# 在控制台打印
print(tbl)

## ----r export----------------------------------------------------------------
# 导出为文本文件
dir <- tempdir()
export_as_txt(tbl, file = file.path(dir, "t_vitals.txt"))
cat("\n表格已导出:", file.path(dir, "t_vitals.txt"), "\n")

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
  docx_file <- "tfl/output/t_vitals.docx"
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