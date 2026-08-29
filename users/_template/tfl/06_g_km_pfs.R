# =============================================================================
# 输出名称：g_km_pfs（无进展生存期 KM 曲线 Progression-Free Survival Plot）
# =============================================================================
# 功能说明：
#   基于 ADTTE 数据集，绘制无进展生存期（PFS）的 Kaplan-Meier 生存曲线，
#   按治疗组着色，并标注中位生存时间。这是 g_km.R（OS 版）的姊妹脚本，
#   只需把终点参数从 OS 换成 PFS。
#
# 使用的包：
#   - tern         : 提供 g_km 生存曲线绘图函数（基于 ggplot2 封装）
#   - dplyr        : 数据筛选
#   - ggplot2      : 图形保存（ggsave）
#   - pharmaverseadam : ADaM 示例数据（adtte_onco，含 OS/PFS 终点）
#   - officer      : Word 报告导出（可选）
#
# 输入数据来源：
#   - pharmaverseadam::adtte_onco : ADTTE 时间到事件数据集
#     必需变量：AVAL（生存时间）、CNSR（删失标志）、PARAMCD（终点代码）
#
# 输出文件：
#   - g_km_pfs.png（KM 曲线图，写入 tempdir()）
#   - g_km_pfs.docx（Word 报告，写入 tfl/output/，officer 已安装时）
#
# 关键概念说明（给不熟悉 R 的临床数据人员）：
#   PFS（无进展生存期）：从随机化到"疾病进展或死亡"的时间（先发生者）
#   AVAL  : 分析值，这里是 PFS 时间（天）
#   CNSR  : 删失标志。CNSR=0 表示事件已发生（进展/死亡），CNSR=1 表示删失
#   is_event = (CNSR == 0)：tern 需要"是否发生事件"的逻辑变量
# =============================================================================

# =============================================================================
# 【练习版】按 # TODO 提示填空。填不出就问 Claude Code："帮我补全这个 TODO"——
# 练习模式只会给提示，不会直接读答案，也不会替你写完整版。
# 写完自查：跟 Claude Code 说"我写完了，帮我对照检查"，它会逐条说明差异。
# 项目根的 sdtm/ adam/ tfl/ 是完整答案脚本（供对照，勿改），练习时不要读/改它们。
# =============================================================================

## ----r setup, message=FALSE, warning=FALSE-----------------------------------
library(tern)
library(dplyr)
library(ggplot2)

# 读入 ADTTE（时间到事件数据集）
adtte <- pharmaverseadam::adtte_onco

## ----r prepare---------------------------------------------------------------
# 只取无进展生存期（PFS）这个终点，并把治疗组转成因子（决定曲线分组和图例顺序）
anl <- adtte %>%
  filter(PARAMCD == "PFS") %>%
  mutate(
    ARM = factor(ARM),
    is_event = (CNSR == 0)
  )

## ----r plot------------------------------------------------------------------
# g_km：一步生成 KM 曲线；统一字体为 Times New Roman（报告规范）
km_plot <- g_km(
  df = anl,
  variables = list(tte = "AVAL", is_event = "is_event", arm = "ARM"),
  # TODO 1: 补全 g_km 参数：
  #   annot_surv_med = TRUE（标注中位生存时间）、title、xlab="Time (Days)"、ylab="Survival Probability"
  #   并加 ggplot2::theme(text = ggplot2::element_text(family = "Times New Roman")) 统一字体
  # 👉 在这里补全参数（删除注释后）...
)

## ----r export----------------------------------------------------------------
# g_km 返回 ggplot 对象，用 ggsave 导出为 PNG（临时目录，供报告嵌入或预览）
dir <- tempdir()
outfile <- file.path(dir, "g_km_pfs.png")
ggsave(outfile, plot = km_plot, width = 10, height = 7, dpi = 150)
cat("PFS KM 生存曲线图已导出:", outfile, "\n")

## ----r export-docx-----------------------------------------------------------
# 可选：导出为 Word 报告（officer 未安装时自动跳过）
# 横版；Figure 题注与人群说明居中，脚注为图片下方的独立段落
if (requireNamespace("officer", quietly = TRUE)) {
  dir.create("tfl/output", showWarnings = FALSE, recursive = TRUE)
  docx_file <- "tfl/output/g_km_pfs.docx"

  prop_title <- officer::fp_text(font.family = "Times New Roman", font.size = 14, bold = TRUE)
  prop_text  <- officer::fp_text(font.family = "Times New Roman", font.size = 11)

  officer::read_docx() %>%
    officer::body_set_default_section(officer::prop_section(
      page_size = officer::page_size(orient = "landscape")
    )) %>%
    officer::body_add_fpar(officer::fpar(officer::ftext(
      "Figure 1. Kaplan-Meier Plot of Progression-Free Survival", prop = prop_title),
      fp_p = officer::fp_par(text.align = "center"))) %>%
    officer::body_add_fpar(officer::fpar(officer::ftext(
      "Population: All Randomized Subjects", prop = prop_text),
      fp_p = officer::fp_par(text.align = "center"))) %>%
    officer::body_add_img(src = outfile, width = 9, height = 5.5) %>%
    officer::body_add_fpar(officer::fpar(officer::ftext(
      paste0("Source: ADTTE. Censored subjects are indicated by tick marks; ",
             "median survival time is annotated on each curve."), prop = prop_text))) %>%
    print(target = docx_file)
  cat("Word 报告已导出:", docx_file, "\n")
}
