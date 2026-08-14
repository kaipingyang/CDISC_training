# ── 初始化某学员的练习区 ─────────────────────────────────────────────────────
# 把 users/_template/ 的挖空 starter（sdtm/adam/tfl 三个子目录）复制到
# users/<名字>/，供学员填 TODO 练习。答案在项目根的 sdtm/ adam/ tfl/。
#
# 用法（从项目根目录运行）：
#   Rscript users/setup.R zhangsan
#   Rscript users/setup.R testuser
# ----------------------------------------------------------------------------

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1 || !nzchar(args[1])) {
  stop("请提供学员名，例如：Rscript users/setup.R zhangsan")
}
user <- args[1]

tpl <- "users/_template"
dst <- file.path("users", user)

if (!dir.exists(tpl)) {
  stop("找不到 users/_template/ —— 请确认在项目根目录运行本脚本")
}

dir.create(dst, showWarnings = FALSE, recursive = TRUE)

# 递归复制 _template 下的 sdtm/adam/tfl 子目录到学员目录
# overwrite = FALSE：学员重跑本脚本时，不覆盖已经填过的内容
copied <- file.copy(
  from = list.files(tpl, full.names = TRUE),
  to = dst,
  recursive = TRUE,
  overwrite = FALSE
)

cat(sprintf("\n✓ 练习区就绪：%s/\n", dst))
cat("  子目录：sdtm/  adam/  tfl/（各含挖空 starter）\n\n")
cat("开始练习：\n")
cat(sprintf("  1. 打开 %s/sdtm/ae.R，按 # TODO 提示填空\n", dst))
cat("  2. 填不出就问 Claude Code：\"帮我补全这个 TODO\"\n")
cat(sprintf("  3. 跑通后对照答案：sdtm/ae.R（完整版，别改它）\n\n"))
