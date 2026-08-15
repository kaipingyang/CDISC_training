# =============================================================================
# run_app.R —— 一键启动交互展示 App
# =============================================================================
# 用法：
#   Rscript run_app.R          # 直接运行
#   source("run_app.R")        # R 会话内
#
# 自动完成三件事：
#   1. 监听 0.0.0.0（容器内 127.0.0.1 外部访问不到）
#   2. 端口被占用时自动顺延（8789 → 8790 → ...）
#   3. 打印本环境（PharmaROSE）的正确外部访问 URL
# =============================================================================

# ── 自动选择可用端口 ──────────────────────────────────────────────────────
find_port <- function(start = 8789) {
  for (p in start:(start + 10)) {
    free <- suppressWarnings(tryCatch({
      con <- socketConnection("127.0.0.1", p, open = "r", timeout = 1)
      close(con)
      FALSE  # 能连上 = 端口被占用
    }, error = function(e) TRUE))
    if (free) return(p)
  }
  stop("端口 8789-8799 全部被占用，请手动指定")
}

port <- find_port()

# ── 打印访问地址 ──────────────────────────────────────────────────────────
host <- Sys.getenv("PROXY_DOMAIN", "c3c-training.mediwei.com")
base <- Sys.getenv("BASE_URL", "/u/c3c-training-kaiping-cdisc-training")

cat("\n============================================\n")
cat("  App 已启动\n")
cat("  本地访问: http://127.0.0.1:", port, "\n", sep = "")
cat("  外部访问: https://", host, base, "/proxy/", port, "/\n", sep = "")
cat("============================================\n\n")

# ── 启动（根目录 app.R）──────────────────────────────────────────────────
shiny::runApp(".", host = "0.0.0.0", port = port, launch.browser = FALSE)
