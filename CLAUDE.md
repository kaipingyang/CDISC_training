# CDISC 数据集生成训练项目 — Claude Code 项目说明

## 项目定位

面向不熟悉 R 的临床数据人员的 CDISC 培训项目：通过 Claude Code 的
Agent Skills，用中文自然语言驱动生成 SDTM / ADaM / TFL 数据集与报告。

## Skill 体系（三层，按此路由）

1. **教学层（中文，学员主路径，优先触发）**
   - `sdtm` / `adam` — 结构查询与 dummy 数据生成
   - `sdtm-map` / `adam-derive` / `tfl` — 代码生成（sdtm.oak / admiral / tern+rtables）
   - `new-user` — 创建学员练习区（users/<学员名>/）
2. **官方参考层（英文，生产级，深入/校验用）**
   - `admiral`（父级）+ `admiral-adsl` / `admiral-bds` — ADaM 派生
   - `sdtm-oak` — SDTM 映射
3. **延伸层（文档链接）**
   - 官方 R Consortium pharma-skills 仓库：https://github.com/RConsortium/pharma-skills
   - 本地副本位于 `.claude/skills/admiral/` 与 `.claude/skills/sdtm-oak/`
     （含 references/ 与 LICENSE，来自官方 main 分支；官方更新时按同样方式手动同步）

学员的中文请求优先匹配中文教学 skill；涉及"生产规范/函数选择/为什么这么做"的
追问可引用官方 skill 作为权威依据。

## 项目结构要点

- `sdtm/` `adam/` `tfl/` — 完整答案脚本（供对照，勿改）
- `users/` — 学员练习区：`_template/`（挖空 starter）+ 各学员目录；`users/setup.R <名字>` 初始化
- `sdtm/output/` `adam/output/` `tfl/output/` — 各层生成产物（xpt / docx，已 gitignore）
- `metadata/` — 规格书（onco_spec.xlsx、safety_specs.xlsx、sdtm_ct.csv）
- 脚本产出：SDTM/ADaM 输出 xpt；TFL 输出三线表 Word 报告（横版、Times New Roman、标题/人群居中、脚注在表格下方）

## 环境注意

- R 包环境由 renv 管理；机器级配置（如 RENV_PATHS_ROOT）在 `~/.Renviron`，不入库
- `.Rprofile` 与 `.git-config.json` 为本地文件，均不提交
- quarto 持久化在 `/config/quarto/bin/quarto`（渲染 `docs/*.qmd` 用：
  `quarto render docs/slides.qmd --self-contained`，产物 html 不入库）
