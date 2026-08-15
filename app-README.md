# app.R — 交互展示 App（teal）

基于 **teal + teal.modules.clinical** 的单一 Shiny app（`app.R` 在项目根目录，
Shiny 标准惯例），把 SDTM → ADaM → TFL 的产出变成可交互探索平台。
数据与 `sdtm/`、`adam/`、`tfl/` 脚本同源（pharmaverseraw / pharmaverseadam）。

## 功能（10 个模块）

| 模块 | 内容 |
|---|---|
| SDTM 数据浏览 | DM / AE / VS（对应 `sdtm/` 脚本产物，3 个 tab） |
| ADaM 数据浏览 | ADSL / ADAE / ADTTE（对应 `adam/` 脚本产物，3 个 tab） |
| 人口学特征表 | `tm_t_summary`（对应 `tfl/t_demographic.R`） |
| 不良事件汇总表 | `tm_t_events`（对应 `tfl/t_adverse_events.R`） |
| KM 生存曲线 | `tm_g_km`（对应 `tfl/g_km.R`） |

## 运行

```r
renv::restore()            # 首次：恢复环境（含 teal 系列）
Rscript run_app.R          # 一键启动（自动监听 0.0.0.0 + 打印访问 URL）
```

启动后按终端打印的地址访问：本地 `http://127.0.0.1:<port>`，
外部（PharmaROSE 平台）`https://c3c-training.mediwei.com<BASE_URL>/proxy/<port>/`。

> ⚠️ 注意：**不要**把 `app.R` 的内容逐行粘贴到 R 控制台执行 ——
> 脚本大量使用多行管道（`|>`）和跨行调用，逐行执行会全部报语法错误。
> 用 `runApp()` 或 `source("app.R")` 整体加载。

## 数据源说明

`pharmaverseadam::adsl / adae / adtte_onco` —— 分类变量全是 character，
app 内已统一转 factor（显式 levels 控制治疗组列顺序，ADAE 与 ADSL 对齐）；
`adtte_onco` 缺 `AVALU`，已补 `AVALU = "Days"` 并派生 `is_event` 供 KM 使用。

想展示学员自己生成的产物：把上面三个数据源替换为
`haven::read_xpt("sdtm/output/dm.xpt")` 等对应读入即可（需先跑通
`sdtm/`、`adam/` 脚本）。

## 常见坑（详见 .claude/skills/teal-clinical-modules/references/gotchas.md）

- 分组变量必须 factor（`Treatment variable is not a factor`）
- teal 二进制包默认 bslib 主题白屏 → `options(teal.bs_theme = bslib::bs_theme(version = 5))`
- `tm_g_km` 的必填参数：`arm_var` / `paramcd` / `strata_var` / `facet_var`
