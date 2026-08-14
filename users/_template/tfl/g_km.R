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

# =============================================================================
# 【练习版】按 # TODO 提示填空。填不出就问 Claude Code："帮我补全这个 TODO"。
# 参考答案：tfl/g_km.R（完整版，别改它）—— 先自己填，卡住再看。
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
  # TODO 1: 只保留总生存 OS 这个终点。ADTTE 里可能含多个终点（OS / PFS ...），
  #   用 PARAMCD 这个终点代码来筛选。
  # 👉 在这里补 filter(PARAMCD == "OS")，然后接 %>%
  identity() %>%                          # 占位：填好上面 TODO 后删掉这行 identity()
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
  # TODO 2: 用 variables 指定三个角色变量的映射（告诉 g_km 哪列扮演什么角色）：
  #   tte      = 生存时间        → "AVAL"
  #   is_event = 是否发生事件    → "is_event"（前面 mutate 派生的逻辑变量）
  #   arm      = 分组变量（治疗组）→ "ARM"
  # 👉 在这里补 variables = list(tte = "...", is_event = "...", arm = "...")，末尾加逗号
  # 在曲线上标注每组的中位生存时间
  annot_surv_med = TRUE,
  title = "Kaplan-Meier Plot of Overall Survival",
  xlab = "Time (Days)",
  ylab = "Survival Probability"
)

## ----r export----------------------------------------------------------------
# g_km 返回 ggplot 对象，用 ggsave 导出为 PNG
dir <- tempdir()
outfile <- file.path(dir, "g_km_os.png")
ggsave(outfile, plot = km_plot, width = 10, height = 7, dpi = 150)
cat("KM 生存曲线图已导出:", outfile, "\n")
