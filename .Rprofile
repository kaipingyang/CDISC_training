# 团队共享 renv 缓存：仅共享服务器环境启用（目录存在时）；
# 个人电脑等无此目录的环境自动回退 renv 默认本地缓存
if (dir.exists("/shared/apps/renv_cache")) {
  Sys.setenv(RENV_PATHS_CACHE = "/shared/apps/renv_cache")
}

# 快速安装源：清华镜像（本环境实测 PPM 访问极慢）；仓库名保持 CRAN 与 lockfile 契约一致
options(repos = c(CRAN = "https://mirrors.tuna.tsinghua.edu.cn/CRAN/"))

# 激活 renv（保持此行为 renv 自动生成的模板行）
source("renv/activate.R")
