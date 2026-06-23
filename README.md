# CDISC 数据集生成训练项目

## 项目简介

本项目是面向临床数据专员的 CDISC 标准数据集生成训练平台，
旨在让不熟悉 R 编程的临床数据人员，通过 Claude Code 中的
AI skill，用中文自然语言驱动生成符合 CDISC 规范的 SDTM 和 ADaM 数据集。
项目基于 pharmaverse 生态系统（sdtm.oak + admiral），所有参考脚本均使用
CDISCPILOT01 内置示例数据。

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
└── data/
    └── raw/                 # 原始数据目录（示例数据来自 pharmaverseraw 包）
```

---

## 依赖包说明

| 包名 | 用途 |
|------|------|
| `sdtm.oak` | SDTM 域映射引擎，提供 `assign_no_ct`、`assign_ct`、`hardcode_ct` 等核心函数 |
| `admiral` | ADaM 数据集构建框架，提供 `derive_vars_*`、`derive_param_*` 等派生函数 |
| `metacore` | 规格/元数据管理，读取变量级规格表 |
| `metatools` | 数据集验证工具，配合 metacore 使用 |
| `xportr` | 导出 SAS 传输格式（.xpt）文件，供电子提交使用 |
| `pharmaverseraw` | SDTM 映射用原始数据（EDC 模拟数据，CDISCPILOT01 研究） |
| `pharmaversesdtm` | SDTM 标准域数据（供 ADaM 脚本作为输入使用） |
| `pharmaverseadam` | ADaM 参考数据集（用于对比验证输出结果） |

---

## Phase 2 路线图

Phase 2 计划扩展更多 SDTM 域（LB、CM、MH、DS 等）和 ADaM 数据集（ADLB、ADCM），
并完善从原始数据到 XPT 文件导出的完整电子提交流程，包括 define.xml 生成、
Pinnacle 21 合规验证，以及与 Posit Connect 部署的自动化管道。
