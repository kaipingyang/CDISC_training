# =============================================================================
# 输出名称：t_demographic（人口学特征表 Demographic Characteristics Table）
# =============================================================================
# 功能说明：
#   基于 ADSL 数据集，按治疗组分列，汇总受试者的人口学特征
#   （年龄、年龄分组、性别、种族），生成符合临床报告规范的汇总表。
#   这是最基础的 TFL 表格类型，是学习 tern/rtables 的入门主线。
#
# 使用的包：
#   - rtables      : 表格布局引擎，提供 basic_table/split_cols_by/build_table
#   - tern         : 临床分析高层封装，提供 analyze_vars 等预制统计函数
#   - pharmaverseadam : ADaM 示例数据（ADSL）
#
# 输入数据来源：
#   - pharmaverseadam::adsl : ADSL 受试者级分析数据集
#
# 输出文件：
#   - t_demographic.txt（表格文本，写入 tempdir()）
#
# 关键概念说明（给不熟悉 R 的临床数据人员）：
#   Layout 与 Data 分离：先用 basic_table() 声明"表长什么样"（分几列、
#     每行分析什么变量），再用 build_table() 把数据"喂"进这个布局。
#     这与 SDTM/ADaM 的规范化思路一致——结构和内容解耦。
#   split_cols_by  : 按某个变量的取值把表拆成多列（这里按治疗组 ACTARM）
#   add_overall_col: 额外加一个"合计"列，汇总所有受试者
#   analyze_vars   : tern 的核心函数，对连续变量自动算 n/Mean/SD/Median/Min-Max，
#     对分类变量自动算各水平的计数和百分比
#   df_explicit_na : 把 R 的 NA 转成显式的 "<Missing>" 分类，避免统计时被悄悄丢弃
# =============================================================================

## ----r setup, message=FALSE, warning=FALSE-----------------------------------
library(rtables)
library(tern)
library(dplyr)

# 读入 ADSL（受试者级分析数据集，每受试者一条记录）
adsl <- pharmaverseadam::adsl

## ----r prepare---------------------------------------------------------------
# 数据预处理：
# 1. 只保留安全性人群（SAFFL=="Y"），这是人口学表的标准分析集
# 2. 把分析用的分类变量转成因子，并显式化缺失值
adsl <- adsl %>%
  filter(SAFFL == "Y") %>%
  mutate(
    SEX = factor(SEX, levels = c("F", "M"), labels = c("Female", "Male")),
    AGEGR1 = factor(AGEGR1),
    RACE = factor(RACE)
  ) %>%
  df_explicit_na()

# 给分析变量加上易读的标签（表格里会显示这些标签而非变量名）
# formatters::var_labels() 逐变量设置 label 属性
formatters::var_labels(adsl)[c("AGE", "AGEGR1", "SEX", "RACE")] <-
  c("Age (years)", "Age Group", "Sex", "Race")

## ----r layout----------------------------------------------------------------
# 第一步：定义表格布局（Layout）——此时还没有数据，只是声明结构
# 读法：以空白表起手 → 按治疗组 ACTARM 分列 → 加合计列 → 逐个分析4个人口学变量
lyt <- basic_table(
  show_colcounts = TRUE,                            # 列标题显示每组 N
  title = "Table 14.1.1 Demographic Characteristics",   # 表题
  subtitles = "Population: Safety Analysis Set",    # 分析人群
  main_footer = paste0(                              # 脚注
    "Source: ADSL. Percentages are based on the safety analysis set; ",
    "medians are reported with min-max range."
  )
) %>%
  split_cols_by("ACTARM") %>%                        # 按治疗组分列
  add_overall_col("All Patients") %>%                # 追加"合计"列
  analyze_vars(
    vars = c("AGE", "AGEGR1", "SEX", "RACE"),        # 要汇总的4个变量
    .stats = c("n", "mean_sd", "median", "range", "count_fraction")
  )

## ----r build-----------------------------------------------------------------
# 第二步：把数据喂进布局，生成最终表格
tbl <- build_table(lyt, df = adsl)

# 在控制台打印（教学时可直接看到成型的表格）
print(tbl)

## ----r export----------------------------------------------------------------
# 导出为文本文件，供报告或进一步处理使用
dir <- tempdir()
export_as_txt(tbl, file = file.path(dir, "t_demographic.txt"))
cat("\n表格已导出:", file.path(dir, "t_demographic.txt"), "\n")

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
  docx_file <- "tfl/output/t_demographic.docx"
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
