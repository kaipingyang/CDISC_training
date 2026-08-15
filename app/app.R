# =============================================================================
# CDISC 数据集生成训练 · 交互展示 App（teal 单 app）
# =============================================================================
# 功能：
#   - 数据浏览：ADSL / ADAE / ADTTE 原始查看（tm_data_table）
#   - 三张标准 TFL：人口学特征表（tm_t_summary）、AE 汇总表（tm_t_events）、
#     KM 生存曲线（tm_g_km）—— 与 tfl/ 脚本输出对应，可交互切换
# 数据源：
#   pharmaverseadam::adsl / adae / adtte_onco（与 tfl/ 脚本同源，开箱即用）
# 运行：
#   Rscript app/app.R   （或 R 会话内 source("app/app.R")）
# 依赖：teal、teal.modules.clinical、teal.modules.general
# =============================================================================
# 已知坑（详见 .claude/skills/teal-clinical-modules/references/gotchas.md）：
#   1) pharmaverseadam 分类变量全是 character，必须转 factor，否则报
#      "Treatment variable is not a factor"
#   2) teal 二进制包默认 bslib 主题可能白屏，用本机主题覆盖（gotchas #5）
#   3) adtte_onco 缺 AVALU（gotchas #4）—— 补一个，tm_g_km 的 time_unit_var
#      默认取 AVALU
# =============================================================================

# teal 的 footer（session info）在 bslib v5 主题下定位异常（static 且横跨顶部，
# 会盖住模块 tab 栏）—— 通过主题规则固定到底部修复
options(teal.bs_theme = bslib::bs_theme(version = 5) |>
          bslib::bs_add_rules("footer#teal-footer { position: fixed; bottom: 0; left: 0; right: 0; z-index: 1030; }"))

library(teal)
library(teal.modules.general)   # tm_front_page / tm_data_table
library(teal.modules.clinical)  # tm_t_summary / tm_t_events / tm_g_km

# ── 数据准备 ─────────────────────────────────────────────────────────────
data <- teal_data()
data <- within(data, {
  ADSL <- pharmaverseadam::adsl |>
    dplyr::mutate(
      # 显式 levels 控制治疗组列顺序（默认字母序 High 在前，与 tfl/ 脚本不一致）
      ACTARM = factor(ACTARM, levels = c("Placebo", "Xanomeline High Dose", "Xanomeline Low Dose")),
      dplyr::across(dplyr::any_of(c("SEX", "RACE", "AGEGR1", "SAFFL")), as.factor)
    )
  ADAE <- pharmaverseadam::adae |>
    dplyr::mutate(
      # 分子分母 levels 对齐（与 tfl/t_adverse_events.R 同理）
      ACTARM = factor(ACTARM, levels = levels(ADSL$ACTARM)),
      dplyr::across(dplyr::any_of(c("AEBODSYS", "AEDECOD", "AESEV", "TRTEMFL")), as.factor)
    )
  ADTTE <- pharmaverseadam::adtte_onco |>
    dplyr::filter(PARAMCD == "OS") |>
    dplyr::mutate(
      ARM      = factor(ARM),
      PARAMCD  = factor(PARAMCD),
      AVALU    = "Days",                    # adtte_onco 缺 AVALU，补上（tm_g_km 默认取它）
      is_event = as.integer(CNSR == 0)      # tm_g_km 需要事件标志（CNSR 是 integer）
    )
})
join_keys(data) <- default_cdisc_join_keys[names(data)]

# 数据框引用（构造 choices 用，立即解析比字符串延迟解析稳）
ADSL  <- data[["ADSL"]]
ADAE  <- data[["ADAE"]]
ADTTE <- data[["ADTTE"]]

# ── 模块 ─────────────────────────────────────────────────────────────────
modules <- modules(
  tm_front_page(
    header_text = c(
      "CDISC 数据集生成训练",
      "SDTM → ADaM → TFL 全流程产出交互浏览"
    )
  ),
  tm_data_table(label = "ADSL 数据", datanames = "ADSL"),
  tm_data_table(label = "ADAE 数据", datanames = "ADAE"),
  tm_data_table(label = "ADTTE 数据", datanames = "ADTTE"),
  tm_t_summary(
    label = "人口学特征表",
    dataname = "ADSL",
    parentname = "ADSL",
    arm_var = choices_selected(variable_choices(ADSL, "ACTARM"), "ACTARM"),
    summarize_vars = choices_selected(
      variable_choices(ADSL, c("AGE", "SEX", "RACE", "AGEGR1")),
      c("AGE", "SEX", "RACE", "AGEGR1")
    )
  ),
  tm_t_events(
    label = "不良事件汇总表",
    dataname = "ADAE",
    parentname = "ADSL",
    arm_var = choices_selected(variable_choices(ADAE, "ACTARM"), "ACTARM"),
    hlt = choices_selected(variable_choices(ADAE, "AEBODSYS"), "AEBODSYS"),
    llt = choices_selected(variable_choices(ADAE, "AEDECOD"), "AEDECOD"),
    add_total = TRUE
  ),
  tm_g_km(
    label = "KM 生存曲线",
    dataname = "ADTTE",
    parentname = "ADSL",
    arm_var = choices_selected(variable_choices(ADSL, "ACTARM"), "ACTARM"),
    paramcd = choices_selected(value_choices(ADTTE, "PARAMCD", "PARAM"), "OS"),
    strata_var = choices_selected(variable_choices(ADSL, "SEX"), "SEX"),
    facet_var = choices_selected(variable_choices(ADSL, c("SEX", "RACE")), NULL),
    # aval/cnsr 显式指定（gotchas #6：延迟解析取不到；cnsr 用的是派生的 is_event）
    aval_var = choices_selected(variable_choices(ADTTE, "AVAL"), "AVAL"),
    cnsr_var = choices_selected(variable_choices(ADTTE, "is_event"), "is_event")
  )
)

app <- init(
  data = data,
  modules = modules
)

# 标准 Shiny app.R 约定（Posit Connect 部署直接识别本对象）
# 本地运行：R 会话里 runApp("app")（或 shiny::runApp(app)）
shiny::shinyApp(ui = app$ui, server = app$server)
