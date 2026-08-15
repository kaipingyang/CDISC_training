---
name: run-shiny
description: 在 Posit Workbench VS Code session 中运行 Shiny app，自动构建正确的代理 URL。当用户提到 runApp、运行 shiny、启动 app、shiny app 打不开等关键词时触发。
argument-hint: "[app.R 路径，默认当前目录]"
---

# 在 Posit Workbench VS Code 中运行 Shiny App

## 背景

Posit Workbench 的 VS Code session 通过反向代理暴露端口，URL 格式为：
```
https://<server>/s/<session-id>/p/<proxy-hash>/
```

直接用 `shiny::runApp()` 监听 `127.0.0.1` 无法通过代理访问。需要：
1. 监听 `0.0.0.0`
2. 通过 VS Code PORTS 面板转发端口
3. 手动修正生成的 URL（反斜杠 `%5C` 问题）

## 操作步骤

### Step 1: 获取环境信息

在 R console 中运行以下命令获取 session URL 前缀：

```r
cat(Sys.getenv("RS_SERVER_URL"))
cat(Sys.getenv("RS_SESSION_URL"))
```

### Step 1.5: 检查环境与加载方式

在给出启动命令之前，Claude 必须自动完成以下检查：

#### a) 确定 app.R 的绝对路径

用 Glob 工具查找项目中的 `app.R` 文件，始终以**绝对路径**提供给用户（如 `/usrfiles/shared-projects/users/.../example/app.R`），不要使用相对路径。

#### b) 检查是否存在 renv 环境

检查项目根目录是否存在 `renv.lock` 或 `renv/` 目录。如果存在 renv：
- **必须先 `setwd("<项目绝对路径>")` 再 `renv::load()`** 来加载项目库
- 不要使用 `renv::activate()`：它需要重启 R session 才能生效，无法在同一行内直接接着运行 app
- `setwd()` + `renv::load()` 会立即将项目库挂载到搜索路径，无需重启

#### c) 判断当前开发的 R 包的加载方式

如果当前项目本身是一个 R 包（存在 `DESCRIPTION` 文件），**始终使用 `devtools::load_all()` 加载**，不论包是否已安装。原因：
- 工作目录在包项目内 = 正在开发，`load_all()` 总是加载磁盘上的最新代码
- 即使包已通过 `R CMD INSTALL` 安装，安装版本也可能已过时
- 无需反复 `R CMD INSTALL`，改完代码重启 app 即可

如果当前项目**不是** R 包（无 `DESCRIPTION` 文件），则直接 `shiny::runApp()`。

给用户的启动命令应根据检查结果调整（**所有情况下，有 renv 就必须先 setwd + renv::load()**）：

- **有 renv + R 包项目**：
  ```r
  setwd("<项目绝对路径>"); renv::load(); devtools::load_all(); shiny::runApp("app.R", host = "0.0.0.0", port = 8080)
  ```
- **有 renv + 非 R 包项目**：
  ```r
  setwd("<项目绝对路径>"); renv::load(); shiny::runApp("app.R", host = "0.0.0.0", port = 8080)
  ```
- **无 renv + R 包项目**：
  ```r
  devtools::load_all("<项目绝对路径>"); shiny::runApp("<绝对路径>/app.R", host = "0.0.0.0", port = 8080)
  ```
- **无 renv + 非 R 包项目**：
  ```r
  shiny::runApp("<绝对路径>/app.R", host = "0.0.0.0", port = 8080)
  ```

> `setwd()` 之后 working directory 已切换，`shiny::runApp()` 的路径直接用文件名即可（如 `"app.R"`、`"app_test_flickering.R"`）。无 renv 时没有 setwd，仍需绝对路径。

### Step 2: 启动 Shiny App

根据 Step 1.5 的检查结果，给出完整的启动命令。**始终使用绝对路径**。

### Step 3: 转发端口

告诉用户：
1. 在 VS Code 底部面板找到 **PORTS** 标签
2. 如果端口 8080 没自动出现，点击 **Forward a Port** 手动添加
3. PORTS 面板会生成一个代理 URL

### Step 4: 打开 App（推荐 Simple Browser）

PORTS 面板生成的代理 URL 通常包含 `%5C`（反斜杠被错误编码），直接在浏览器中打开会 404。

**推荐方式**：在 PORTS 面板中，右键点击对应端口 → **Open in Simple Browser**，可直接在 VS Code 内打开，无需手动修正 URL。

**备选方式**（在外部浏览器打开）：复制 PORTS 面板生成的 URL，手动把所有 `%5C` 替换为 `/`。
- 正确格式示例：`https://<workbench-host>/s/ea58b3c9ab5a761f61739/p/301ffb0c/`

### 常见问题

- **"The requested page was not found"**: 检查是否用了 `host = "0.0.0.0"` 而非默认的 `127.0.0.1`
- **URL 中有 `%5C`**: 推荐用 Simple Browser 打开；或手动把 `%5C` 替换为 `/`
- **端口被占用**: 换一个端口号，如 `port = 7777`
