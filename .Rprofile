# 团队共享 renv 缓存（加速 restore，须在激活 renv 之前设置）
Sys.setenv(RENV_PATHS_CACHE = "/shared/apps/renv_cache")

# 快速安装源：清华镜像（本环境实测 PPM 访问极慢，仅用 TUNA）
options(repos = c(TUNA = "https://mirrors.tuna.tsinghua.edu.cn/CRAN/"))

# 激活 renv（保持此行为 renv 自动生成的模板行）
source("renv/activate.R")
