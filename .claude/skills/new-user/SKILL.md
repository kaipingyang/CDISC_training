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

### Step 3 — 告诉学员怎么开始

初始化成功后，告诉学员：

1. **打开** `users/<名字>/sdtm/ae.R`，按文件里的 `# TODO` 提示填空
2. **填不出**就直接问 Claude Code："帮我补全这个 TODO"，或"解释这段在做什么"
3. **跑通后对照答案**：项目根的 `sdtm/ae.R`（完整版，**别改答案文件**）
4. 建议顺序：先 SDTM（`sdtm/ae.R` → `dm.R` → `vs.R`），
   再 ADaM（`adam/adsl.R` → `adae.R`），最后 TFL（`tfl/` 三个）

## 铁律

- **绝不把答案直接写进学员的 starter** —— 学员目录里保持 TODO 挖空状态，
  学员自己填。要帮忙就引导思路或解释，别替他把整段填满（除非他明确说"直接给答案"）。
- **绝不改动** `sdtm/` `adam/` `tfl/` 下的答案脚本。
- 学员目录 `users/<名字>/` 不入库（已在 .gitignore），是各人的私有练习副本。

## 输出规范

- 中文引导，语气鼓励（受众多是不熟 R 的临床数据人员）。
- 初始化后给出明确的"下一步做什么"，别让学员对着空目录发懵。
