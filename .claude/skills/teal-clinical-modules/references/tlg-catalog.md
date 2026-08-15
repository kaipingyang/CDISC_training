# TLG Catalog —— 官方标准输出代码目录

官方站点：https://insightsengineering.github.io/tlg-catalog/stable/
（Apache-2.0 授权，NEST 团队维护，每日重建；有 Stable / Dev 两个 profile。）

> 本页内容是**实际浏览该站点后**总结的（结构 + KMG01 页面）。它是 teal/tern 之上最权威的
> “某个标准临床输出该怎么写”的代码参考，非常适合学员按需查阅。

## 它是什么
一个按 **T**ables / **L**istings / **G**raphs 组织的临床标准输出（TLG）代码目录，
每个输出用**标准化编号**命名（如 DMT01、AET01、KMG01）。每个输出一个页面，含：
1. 合成数据的准备/预处理（用 `random.cdisc.data`，即 `tmc_ex_*` 的来源）
2. 生成该 TLG 的代码（**两套**：见下）
3. 输出结果（常含多个变体 variant）
4. 一个可交互的 **teal app**
5. 复现信息（session info + `.lock` 文件）

## 每页的两套代码（重要）
以 KMG01（KM 曲线）为例：
- **tern 直接法**（画单张图/做单张表）：
  ```r
  library(tern); library(dplyr)
  anl <- random.cdisc.data::cadtte %>% filter(PARAMCD == "OS") %>% mutate(is_event = CNSR == 0)
  variables <- list(tte = "AVAL", is_event = "is_event", arm = "ARMCD")
  g_km(df = anl, variables = variables, xlab = "Time (Days)", annot_coxph = TRUE)
  ```
- **teal app 法**（交互式模块，就是本 skill 讲的 `tm_*`）：KMG01 的 teal app 代码与
  `figures.md` 里的 `tm_g_km(...)` 用法一致（arm_var/paramcd/strata_var/facet_var + 同样的 choices）。

→ 学员要**交互式 app** 就照 `tm_*`（本 skill）；要**脚本直接出图/出表**就用 tern 的 `g_*`/表函数（照 catalog 的 tern 段）。

## 常用编号 → 本 skill 模块 对照
| Catalog 编号 | 输出 | 对应 teal 模块 | 目录路径 |
|---|---|---|---|
| DMT01 | Demography 基线人口学 | `tm_t_summary` | tables/demography/dmt01.html |
| AET01 / AET02 … | 不良事件表 | `tm_t_events` / `tm_t_events_by_grade` | tables/adverse-events/ |
| DTHT01 | 死亡 | `tm_t_events*` | tables/deaths/dtht01.html |
| DST01 | 分组处置 Disposition | `tm_t_summary`/`tm_t_events` | tables/disposition/ |
| TTET01 | 生存分析表 | `tm_t_tte` | tables/efficacy/ttet01.html |
| COXT01/02 | Cox 回归 | `tm_t_coxreg` | tables/efficacy/ |
| MMRMT01 | MMRM | `tm_a_mmrm` | tables/efficacy/mmrmt01.html |
| RSPT01 | 响应率 | `tm_t_binary_outcome` | tables/efficacy/rspt01.html |
| LBT01 … | 实验室 | `tm_t_summary_by`/`tm_t_shift_*` | tables/lab-results/ |
| **KMG01** | **KM 曲线** | **`tm_g_km`** | graphs/efficacy/kmg01.html |
| FSTG01/02 | 森林图 | `tm_g_forest_tte` / `tm_g_forest_rsp` | graphs/efficacy/ |
| MMRMG01/02 | MMRM 图 | `tm_g_lineplot` 等 | graphs/efficacy/ |
| LTG01 / BWG01 / CIG01 / IPPG01 | 折线/箱线/CI/个体患者图 | `tm_g_lineplot` / `tm_g_ci` / `tm_g_ipp` 等 | graphs/other/ |
| AEL01 / CML01 / DSL01 / LBL01 / MHL01 | AE/合并用药/处置/实验室/病史清单 | `tm_data_table`（清单） | listings/… |

> 完整清单见站点 Index：https://insightsengineering.github.io/tlg-catalog/stable/tlg-index.html
> 查某个输出：打开对应页，点右上 “Source Code” 看完整 `.qmd`，或用页内 WebR/shinylive 直接试跑。

## 用法建议
- 学员要做某个“标准输出”，先去 catalog 找编号（AE 表→AET0x、KM→KMG01…），
  直接复制它的 teal app 代码，再对照本 skill 的 references 调参数。
- catalog 的 teal app 段与本 skill 的模块用法一致，可互相印证。
