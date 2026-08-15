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

# ── 自动探测平台代理配置（不写死任何域名/路径）─────────────────────────
detect_proxy <- function() {
  # 1) 环境变量（平台注入，最可靠）
  domain <- Sys.getenv("PROXY_DOMAIN", unset = NA)
  base   <- Sys.getenv("BASE_URL", unset = NA)
  # 2) code-server 配置文件
  if (is.na(domain)) {
    cfg <- tryCatch(readLines("~/.config/code-server/config.yaml", warn = FALSE),
                    error = function(e) character())
    m <- grep("proxy-domain", cfg, value = TRUE)
    if (length(m)) domain <- sub(".*proxy-domain:\\s*([^ ]+).*", "\\1", m[1])
  }
  # 3) code-server 进程启动参数
  if (is.na(domain)) {
    ps <- tryCatch(system2("ps", "aux", stdout = TRUE), error = function(e) character())
    m <- grep("--proxy-domain", ps, value = TRUE)
    if (length(m)) domain <- sub(".*--proxy-domain\\s+([^ ]+).*", "\\1", m[1])
  }
  list(domain = domain, base = base)
}

proxy <- detect_proxy()

cat("\n============================================\n")
cat("  App 已启动\n")
cat("  本地访问: http://127.0.0.1:", port, "\n", sep = "")
if (!is.na(proxy$domain) && !is.na(proxy$base)) {
  cat("  外部访问: https://", proxy$domain, proxy$base,
      "/proxy/", port, "/\n", sep = "")
} else {
  cat("  （未检测到平台代理配置，仅本地可访问）\n")
}
cat("============================================\n\n")

# ── 启动（根目录 app.R）──────────────────────────────────────────────────
shiny::runApp(".", host = "0.0.0.0", port = port, launch.browser = FALSE)
