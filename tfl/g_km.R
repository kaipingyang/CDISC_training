# =============================================================================
# 输出名称：g_km（Kaplan-Meier 生存曲线图 Kaplan-Meier Survival Plot）
# =============================================================================
# 功能说明：
#   基于 ADTTE（时间到事件分析数据集），按治疗组绘制某个终点
#   （如总生存 OS）的 Kaplan-Meier 生存曲线，并标注中位生存时间、
#   风险人数表（number at risk）。这是进阶 TFL，从"表"过渡到"图"。
#
# 使用的包：
#   - tern         : 提供 g_km 生存曲线绘图函数（基于 ggplot2 封装）
#   - dplyr        : 数据筛选
#   - ggplot2      : 图形保存（ggsave）
#   - pharmaverseadam : ADaM 示例数据（adtte_onco，含 OS/PFS 终点）
#
# 输入数据来源：
#   - pharmaverseadam::adtte_onco : ADTTE 时间到事件数据集
#     必需变量：AVAL（生存时间）、CNSR（删失标志）、PARAMCD（终点代码）
#
# 输出文件：
#   - g_km_os.png（KM 曲线图，写入 tempdir()）
#
# 关键概念说明（给不熟悉 R 的临床数据人员）：
#   时间到事件（Time-to-Event）：分析"从起点到某事件发生"经历的时间，
#     如总生存期 OS（到死亡）、无进展生存 PFS（到疾病进展或死亡）。
#   AVAL  : 分析值，这里是生存时间（天/月）
#   CNSR  : 删失标志。CNSR=1 表示"删失"（研究结束时事件还没发生，只知道
#           至少活到了这个时间点）；CNSR=0 表示"事件已发生"。
#           tern 需要的是"是否发生事件"，所以 is_event = (CNSR == 0)。
#   Kaplan-Meier：一种估计生存概率随时间变化的非参数方法，曲线每次
#     下降对应一批事件发生；曲线上的小竖线是删失点。
#   g_km 返回的是 ggplot 图形对象，可以用 ggsave() 存成 PNG/PDF。
# =============================================================================

## ----r setup, message=FALSE, warning=FALSE-----------------------------------
library(tern)
library(dplyr)
library(ggplot2)

# 读入 ADTTE（时间到事件数据集）
adtte <- pharmaverseadam::adtte_onco

## ----r prepare---------------------------------------------------------------
# 只取总生存（OS）这个终点，并把治疗组转成因子（决定曲线分组和图例顺序）
# is_event：tern 用它区分"事件"和"删失"。CNSR==0 表示事件发生。
anl <- adtte %>%
  filter(PARAMCD == "OS") %>%
  mutate(
    ARM = factor(ARM),
    is_event = (CNSR == 0)
  )

## ----r plot------------------------------------------------------------------
# g_km：一步生成 KM 曲线。variables 指定三个角色变量：
#   tte      = 生存时间（AVAL）
#   is_event = 是否发生事件（前面派生的逻辑变量）
#   arm      = 分组变量（治疗组）
km_plot <- g_km(
  df = anl,
  variables = list(
    tte = "AVAL",
    is_event = "is_event",
    arm = "ARM"
  ),
  # 在曲线上标注每组的中位生存时间
  annot_surv_med = TRUE,
  title = "Kaplan-Meier Plot of Overall Survival",
  xlab = "Time (Days)",
  ylab = "Survival Probability"
)

# 图形字体统一为 Times New Roman（本机无该字体时回退到度量兼容的字体渲染）
km_plot <- km_plot +
  ggplot2::theme(text = ggplot2::element_text(family = "Times New Roman"))

## ----r export----------------------------------------------------------------
# g_km 返回 ggplot 对象，用 ggsave 导出为 PNG
dir <- tempdir()
outfile <- file.path(dir, "g_km_os.png")
ggsave(outfile, plot = km_plot, width = 10, height = 7, dpi = 150)
cat("KM 生存曲线图已导出:", outfile, "\n")

## ----r export-docx-----------------------------------------------------------
# 可选：把图嵌进 Word 报告（officer 未安装时自动跳过），横版展示
if (requireNamespace("officer", quietly = TRUE)) {
  dir.create("tfl/output", showWarnings = FALSE, recursive = TRUE)
  # Times New Roman 文本样式（标题 / 人群 / 脚注）
  prop_title <- officer::fp_text(font.family = "Times New Roman", font.size = 14, bold = TRUE)
  prop_text  <- officer::fp_text(font.family = "Times New Roman", font.size = 11)
  officer::read_docx() %>%
    officer::body_set_default_section(officer::prop_section(
      page_size = officer::page_size(orient = "landscape")
    )) %>%
    officer::body_add_fpar(officer::fpar(officer::ftext(
      "Figure 1. Kaplan-Meier Plot of Overall Survival", prop = prop_title),
      fp_p = officer::fp_par(text.align = "center"))) %>%
    officer::body_add_fpar(officer::fpar(officer::ftext(
      "Population: All Randomized Subjects", prop = prop_text),
      fp_p = officer::fp_par(text.align = "center"))) %>%
    officer::body_add_img(src = outfile, width = 9, height = 5.5) %>%
    officer::body_add_fpar(officer::fpar(officer::ftext(
      paste0("Source: ADTTE. Censored subjects are indicated by tick marks; ",
             "median survival time is annotated on each curve."), prop = prop_text))) %>%
    print(target = "tfl/output/g_km.docx")
  cat("Word 报告已导出: tfl/output/g_km.docx\n")
}
