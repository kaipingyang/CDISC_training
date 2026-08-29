---
name: new-user
description: 为学员创建 CDISC 练习区。把挖空 starter 复制到 users/<学员名>/，供其填 TODO 练习 SDTM/ADaM/TFL。当用户说"创建学员目录"、"初始化练习区"、"我要练习"、"new user"、"开始练习"、"给我一份练习脚本"时触发。
trigger: 创建学员目录、初始化练习区、我要练习、开始练习、new user、new-user、练习脚本、学员目录、setup 练习
argument-hint: "[学员名，如你的拼音名 zhangsan]"
---

# 创建学员练习区

本 skill 为学员初始化一份 CDISC 数据集生成练习区。项目根的 `sdtm/` `adam/` `tfl/`
是**完整参考答案**；练习区放的是**挖空 starter**（关键行挖成 `# TODO`），学员填空练习，
跑通后对照答案。

## 用户输入

$ARGUMENTS

## 执行流程

### Step 1 — 确认学员名

- 若 `$ARGUMENTS` 里给了名字（如 `zhangsan`），直接用它。
- 若为空，先问用户："给你的练习区起个名字吧（建议用你的拼音名，如 `zhangsan`）"，
  拿到后再继续。
- 名字只用字母/数字/下划线，避免空格和中文（作目录名）。

### Step 2 — 运行初始化脚本

在项目根目录运行（把 `<名字>` 换成实际学员名）：

```bash
Rscript users/setup.R <名字>
```

这会把 `users/_template/` 的挖空 starter（sdtm/adam/tfl 三个子目录）复制到
`users/<名字>/`。脚本用 `overwrite = FALSE`，重跑不会冲掉学员已填的内容。

模板里的输出路径带 `<STUDENT_NAME>` 占位符（如 `users/<STUDENT_NAME>/sdtm/output`），
setup.R 复制后自动替换为学员名——产物写进学员自己的目录，**不会覆盖根目录
`sdtm/output/`、`adam/output/` 的答案产物**。若发现某学员目录里的路径仍是
`<STUDENT_NAME>`（旧模板复制残留），手动替换成该学员名即可。

### Step 3 — 告诉学员怎么开始

初始化成功后，告诉学员：

1. **打开** `users/<名字>/sdtm/03_ae.R`，按文件里的 `# TODO` 提示填空
2. **填不出**就直接问 Claude Code："帮我补全这个 TODO"，或"解释这段在做什么"
3. **跑通后对照答案**：跟 Claude Code 说"我写完了，帮我对照检查"（检查模式），
   或自己打开项目根的 `sdtm/03_ae.R` 对比（完整版，**别改答案文件**）
4. 建议顺序（文件编号即顺序，由易到难）：
   先 SDTM（`sdtm/01_dm.R` → `02_vs.R` → `03_ae.R`；`04_ds.R`/`05_ex.R` 进阶可选），
   再 ADaM（`adam/01_adsl.R` → `02_adae.R` → `03_advs.R`；`04_adtte.R`、`05_adlb.R`/`06_adeg.R`/`07_adcm.R` 进阶可选），
   最后 TFL（`tfl/01_t_demographic.R` → `02_t_adverse_events.R` → `03_g_km.R`；
   `04_t_vitals.R`/`05_t_lab.R`/`06_g_km_pfs.R` 进阶可选）

## 铁律

- **绝不把答案直接写进学员的 starter** —— 学员目录里保持 TODO 挖空状态，
  学员自己填。要帮忙就引导思路或解释，别替他把整段填满。学员若明确说"直接给答案"，
  可以凭 CDISC 标准直接写出完整代码，但**仍不得读取**根目录答案脚本。
- **练习/检查双模式**（与 CLAUDE.md"答案访问规则"一致）：学员练习时严禁读取
  根目录 `sdtm/` `adam/` `tfl/` 的答案脚本；仅当学员明确表达"检查/对照/对比答案"
  （如"我写完了，帮我对照检查"）时，才允许读取答案进行比对并逐条说明差异。
- **绝不改动** `sdtm/` `adam/` `tfl/` 下的答案脚本。
- 学员目录 `users/<名字>/` 不入库（已在 .gitignore），是各人的私有练习副本。

## 输出规范

- 中文引导，语气鼓励（受众多是不熟 R 的临床数据人员）。
- 初始化后给出明确的"下一步做什么"，别让学员对着空目录发懵。
