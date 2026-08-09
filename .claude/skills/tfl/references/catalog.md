# 官方资源导航 — TFL / TLG 开源权威来源

> 数据来源：insightsengineering tern/rtables 官方文档 + pharmaverse TLG catalog

本文件汇总制作 TFL 时应优先查阅的**开源官方权威资源**。这些均为 pharmaverse / insightsengineering 公开维护的文档与代码库，可自由学习、引用、复用。**遇到没见过的表格/图形类型，第一站永远是 TLG Catalog。**

## 一、首选：TLG Catalog（最重要）

> **https://insightsengineering.github.io/tlg-catalog/stable/**

**这是最重要的资源**。TLG Catalog 收录了**数百个即用（copy-paste ready）的 Table / Listing / Graph 代码示例**，每个示例都：
- 用 pharmaverse 公开数据集（如 ADSL/ADAE/ADTTE）跑通，
- 给出完整可运行的 R 代码 + 渲染出的成品预览，
- 按临床领域分类（Demographics、Adverse Events、Efficacy、Labs、Survival 等）。

**使用建议**：当你需要做一张"没做过的表"（例如某种特定的 AE 亚组表、某种疗效图），先到 Catalog 按类别搜同类范例，直接套用其代码骨架，再换成自己的数据集和变量。这是权威、最省时的做法。

## 二、核心 R 包文档

| 资源 | 链接 | 用途 |
|------|------|------|
| **tern GitHub** | https://github.com/insightsengineering/tern | 临床高层分析函数（`analyze_vars` / `count_occurrences` / `g_km` 等）的源码、issue、vignette |
| **tern 文档站** | https://insightsengineering.github.io/tern/ | tern 函数参考手册与教程（function reference / articles） |
| **rtables 文档** | https://insightsengineering.github.io/rtables/ | 底层布局引擎：`basic_table` / `split_cols_by` / `split_rows_by` / `build_table` 的完整机制说明 |
| **rlistings 文档** | https://insightsengineering.github.io/rlistings/ | Listings（明细清单）专用引擎文档 |

## 三、pharmaverse 生态

| 资源 | 链接 | 用途 |
|------|------|------|
| **pharmaverse examples（TLG 章节）** | https://pharmaverse.github.io/examples/ | 端到端范例：从 SDTM → ADaM → TFL 的完整工作流，TLG 章节演示 tern/rtables 实战 |
| **pharmaverse 主站** | https://pharmaverse.org/ | pharmaverse 全景，了解各包分工与推荐组合 |
| **pharmaverseadam** | https://github.com/pharmaverse/pharmaverseadam | 本项目所有示例使用的公开 ADaM 数据集（`adsl` / `adae` / `adtte_onco` 等）来源 |

## 四、如何选择资源（决策路径）

```
需要做一张 TFL？
        │
        ├─ 有没见过的表格/图形类型？ ──► 先查 TLG Catalog（找同类即用范例）
        │
        ├─ 想深入理解某个 tern 函数参数？ ──► tern 文档站 function reference
        │
        ├─ 需要自定义布局、tern 没有现成函数？ ──► rtables 文档（直接写 analyze()）
        │
        └─ 想看端到端 SDTM→ADaM→TFL 全流程？ ──► pharmaverse examples
```

## 五、说明

- 以上全部为 **pharmaverse / insightsengineering 开源官方资源**，采用开源许可证，面向社区公开发布，可自由学习、引用与复用。
- 本 skill 的所有示例代码均基于这些公开资源与 `pharmaverseadam` 公开数据集（STUDYID `CDISCPILOT01`）编写，不含任何专有内容。
- 遇到本 skill 未覆盖的场景，**以上官方资源为准**，尤其优先 TLG Catalog。

---

返回：[overview.md](overview.md)（TFL 总览）· [tables.md](tables.md)（表格速查）· [figures.md](figures.md)（图形速查）
