# CDISC 数据集生成训练项目

## 项目简介

本项目是面向临床数据专员的 CDISC 标准数据集生成训练平台，
旨在让不熟悉 R 编程的临床数据人员，通过 Claude Code 中的
AI skill，用中文自然语言驱动生成符合 CDISC 规范的 SDTM 和 ADaM 数据集。
项目基于 pharmaverse 生态系统（sdtm.oak + admiral），所有参考脚本均使用
CDISCPILOT01 内置示例数据。

---

## 课程介绍

### Claude Code 临床数据自动化开发

**使用 Agent Skills 加速 SDTM、ADaM 与 TFL 开发**

本课程介绍如何利用 **Claude Code 和 Agent Skills** 加速基于 R 的临床数据自动化开发，涵盖 SDTM、ADaM 和 TFL 等常见临床编程任务。课程结合实际临床数据案例，演示如何通过自然语言描述需求并调用专业 Skill，辅助完成需求分析、数据映射、变量派生、R 代码生成、程序解释和结果验证。

课程重点讲解 Agent Skills 在标准化临床开发流程中的实际应用。学员将学习如何清晰地向 Claude Code 表达任务需求、正确使用预设 Skill，并结合项目规范检查和调整 AI 生成的程序。即使没有 R 编程经验，也可以在 Claude Code 的辅助下逐步理解代码逻辑和临床数据处理流程。

完成课程后，学员能够使用 Claude Code 和 Agent Skills 辅助 SDTM、ADaM 与 TFL 开发，将重复性任务转化为更加高效、一致且可复用的自动化流程，从而提升临床数据开发的效率和质量。

### Clinical Data Automation with Claude Code

**Using Agent Skills to Accelerate SDTM, ADaM, and TFL Development**

This course introduces how to use **Claude Code and Agent Skills** to accelerate R-based clinical data automation, covering common clinical programming tasks related to SDTM, ADaM, and TFL development. Through practical clinical data examples, participants will learn how to describe requirements in natural language and use specialized Skills to support requirement analysis, data mapping, variable derivation, R code generation, code interpretation, and result validation.

The course focuses on the practical use of Agent Skills in standardized clinical development workflows. Participants will learn how to communicate requirements clearly to Claude Code, use predefined Skills effectively, and review and adjust AI-generated programs according to project specifications. Even without prior R programming experience, participants can use Claude Code to gradually understand the code logic and clinical data processing workflow.

By the end of the course, participants will be able to use Claude Code and Agent Skills to support SDTM, ADaM, and TFL development, transforming repetitive tasks into more efficient, consistent, and reusable automated workflows while improving the quality and efficiency of clinical data development.

---

## 环境要求

- R >= 4.2.0
- Claude Code（用于触发 `sdtm-domain` 和 `adam-domain` skill）

---

## 快速开始（3步）

### 第一步：恢复 R 环境

首次克隆项目后，在 R 控制台中运行以下命令，自动安装所有锁定版本的依赖包：

```r
renv::restore()
```

renv 会读取 `renv.lock` 中记录的精确版本，确保环境完全一致。
安装完成后会提示 `The library is already synchronized with the lockfile.`

> 注意：`metadata/sdtm_ct.csv` 受控术语文件已包含在项目中，无需手动下载。

---

### 第二步：生成 SDTM 数据集

有两种方式可以生成 SDTM 域数据集：

**方式一：直接运行参考脚本**

```r
source("sdtm/dm.R")   # DM 域（人口学）
source("sdtm/ae.R")   # AE 域（不良事件）
source("sdtm/vs.R")   # VS 域（生命体征）
```

**方式二：在 Claude Code 中用自然语言触发 `sdtm-domain` skill**

直接在 Claude Code 对话框中输入描述，系统会自动生成映射代码框架：

> "帮我创建 AE 域的 SDTM 映射代码"
> "我需要生成 DM 域数据，原始变量包括性别、年龄、种族"
> "create sdtm for vital signs domain"
> "生成 LB 域映射，数据来自实验室原始表"

---

### 第三步：生成 ADaM 数据集

ADaM 数据集在 SDTM 基础上进一步加工为分析用数据集：

**方式一：直接运行参考脚本**

```r
source("adam/adsl.R")   # ADSL（受试者级数据集，所有 ADaM 的基础）
source("adam/adae.R")   # ADAE（不良事件分析数据集）
source("adam/advs.R")   # ADVS（生命体征分析数据集）
source("adam/adtte.R")  # ADTTE（生存分析数据集）
```

> 建议先运行 `adsl.R`，因为其他 ADaM 数据集均依赖 ADSL。

**方式二：在 Claude Code 中用自然语言触发 `adam-domain` skill**

> "帮我创建 ADSL 数据集"
> "生成 ADAE，需要标记 TRTEMFL（治疗期间不良事件标志）"
> "create adam for survival analysis"
> "生成 ADVS，需要添加基线值 BASE 和相对基线变化量 CHG"

---

### 第四步：生成 TFL（表格 / 图形 / 列表）

TFL（Tables/Figures/Listings）是临床研究报告的最终交付物，建立在 ADaM 分析数据集之上，
使用 pharmaverse 官方 TLG 技术栈（`tern` + `rtables`）生成。

**方式一：直接运行参考脚本**

```r
source("tfl/t_demographic.R")      # 人口学特征表（入门主线，ADSL 单表）
source("tfl/t_adverse_events.R")   # AE 汇总表（ADAE + ADSL，含分母逻辑）
source("tfl/g_km.R")               # KM 生存曲线图（ADTTE）
```

> 三个示例难度递增：人口学表 → AE 表 → KM 图，覆盖"表"与"图"两大类。
> 表格导出为文本文件，图形导出为 PNG（均写入临时目录 `tempdir()`）。

**方式二：在 Claude Code 中用自然语言触发 `tfl` skill**

> "帮我做一张人口学特征表，按治疗组分列"
> "生成 AE 汇总表，按 SOC 和 PT 统计发生率"
> "画一张总生存期 OS 的 KM 生存曲线"
> "create a demographic table from ADSL"

> **技术栈说明**：`rtables` 是底层布局引擎，`tern` 是基于它的临床高层封装（学员主要调 tern）。
> 核心心智模型是"Layout 与 Data 分离"——先声明表长什么样，再喂数据。
> 遇到没见过的表格类型，可查官方 [TLG Catalog](https://insightsengineering.github.io/tlg-catalog/stable/)（数百个即用示例）。

> **关于交互展示（teal）**：分析数据集和 TFL 都有了之后，若需要交互式探索（动态筛选、
> 切换参数），可了解 pharmaverse 的 `teal` 框架——它把 TFL 输出包装成 Shiny 交互应用。
> 这属于 Shiny/teal 的进阶主题，本项目不展开。

---

## 项目结构

```
CDISC_training/
├── DESCRIPTION              # 项目元数据和 R 包依赖声明
├── renv.lock                # R 包版本锁定文件（精确复现环境用）
├── renv/                    # renv 运行时（activate.R 等）
├── .gitignore               # Git 忽略规则（library/ 等不提交）
├── metadata/
│   └── sdtm_ct.csv          # CDISC 受控术语对照表（assign_ct 依赖）
├── sdtm/
│   ├── dm.R                 # DM 域：人口学，SDTM 映射参考脚本
│   ├── ae.R                 # AE 域：不良事件映射
│   └── vs.R                 # VS 域：生命体征映射
├── adam/
│   ├── adsl.R               # ADSL：受试者级分析数据集
│   ├── adae.R               # ADAE：不良事件分析数据集
│   ├── advs.R               # ADVS：生命体征分析数据集
│   └── adtte.R              # ADTTE：生存分析数据集
├── tfl/
│   ├── t_demographic.R      # 人口学特征表（tern/rtables）
│   ├── t_adverse_events.R   # AE 汇总表（含 alt_counts_df 分母）
│   └── g_km.R               # KM 生存曲线图（tern g_km）
├── docs/
│   ├── slides.qmd           # 讲师幻灯片（Quarto revealjs，两课时）
│   └── tutorial.qmd         # 学员自学手册（Quarto html）
└── data/
    └── raw/                 # 原始数据目录（示例数据来自 pharmaverseraw 包）
```

---

## 培训材料

`docs/` 下有两份 Quarto 培训材料（两课时：课时1 SDTM，课时2 ADaM+TFL）：

| 文件 | 用途 |
|------|------|
| `docs/slides.qmd` | 讲师用幻灯片（revealjs） |
| `docs/tutorial.qmd` | 学员自学手册（可跟做的完整步骤 + 常见问题） |

渲染为 HTML（需已安装 [Quarto](https://quarto.org/)）：

```bash
quarto render docs/slides.qmd     # 生成 docs/slides.html
quarto render docs/tutorial.qmd   # 生成 docs/tutorial.html
```

> 渲染产物（`*.html`、`*_files/`）已在 `.gitignore` 中排除，仓库只保留 `.qmd` 源文件。

---

## 依赖包说明

| 包名 | 用途 |
|------|------|
| `sdtm.oak` | SDTM 域映射引擎，提供 `assign_no_ct`、`assign_ct`、`hardcode_ct` 等核心函数 |
| `admiral` | ADaM 数据集构建框架，提供 `derive_vars_*`、`derive_param_*` 等派生函数 |
| `metacore` | 规格/元数据管理，读取变量级规格表 |
| `metatools` | 数据集验证工具，配合 metacore 使用 |
| `xportr` | 导出 SAS 传输格式（.xpt）文件，供电子提交使用 |
| `rtables` | TFL 表格布局引擎，提供 `basic_table`/`build_table` 等 |
| `tern` | 基于 rtables 的临床分析高层封装，提供 `analyze_vars`/`count_occurrences`/`g_km` 等 |
| `rlistings` | 病人级列表（Listing）生成 |
| `pharmaverseraw` | SDTM 映射用原始数据（EDC 模拟数据，CDISCPILOT01 研究） |
| `pharmaversesdtm` | SDTM 标准域数据（供 ADaM 脚本作为输入使用） |
| `pharmaverseadam` | ADaM 参考数据集（供 TFL 脚本作为输入 / 对比验证） |

---

## 路线图

已完成：SDTM 映射（sdtm.oak）→ ADaM 派生（admiral）→ TFL 生成（tern/rtables）完整生产链，
配套 `sdtm` / `adam` / `tfl` 三个 Claude Code skill。

后续可扩展：更多 SDTM 域（LB、CM、MH、DS 等）和 ADaM 数据集，完善电子提交流程
（define.xml 生成、Pinnacle 21 合规验证），以及 teal 交互式展示应用。
