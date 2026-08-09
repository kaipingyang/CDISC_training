---
name: adam
description: 当用户询问 ADaM 数据集结构、变量、用途，或需要生成 dummy ADaM 数据时触发。例如 "ADSL 有哪些变量"、"ADAE 的结构是什么"、"生成 ADLB 的 dummy 数据"、"列出所有 ADaM 数据集"、"ADTTE 的 key 是什么"。基于 CDISC ADaM IG v1.3 标准。
argument-hint: "[数据集名称或问题，例如 'ADSL'、'生成 ADAE dummy 数据'、'列出所有数据集']"
---

# ADaM 数据集查询与 Dummy Data 生成

本 skill 用于查询 ADaM v1.2.1 标准数据集的结构信息，以及生成测试用的 dummy ADaM 数据集。

## 第 1 步 — 始终先读取索引

**任何查询都必须先读取以下文件以获取 ADaM 数据集总览**:

```
references/index.md
```

该文件包含:
- 30 个 ADaM 数据集的快速导航表(数据集名 / 描述 / 结构 / 变量数 / 详情链接)
- 按业务类别分组(Subject-Level / AE / CM / LB / VS / Tumor Response / TTE / PK / PRO 等)
- ADaM 命名规则与通用变量说明

## 第 2 步 — 根据用户问题路由

### 场景 A: 用户询问某个具体数据集的结构

例如 "ADSL 有哪些变量"、"ADAE 的 key 是什么"、"ADLB 的结构"、"ADTTE 怎么衍生 AVAL"

**做法**: 读取对应的 `references/<DATASET>.md` 文件,例如:
- `references/ADSL.md`
- `references/ADAE.md`
- `references/ADTTE.md`
- `references/ADLB.md`

每个数据集 MD 包含: 概览(描述/类别/结构/用途/主键/备注) + 变量列表(Variable/Label/Type/Origin/说明) + 衍生方法。

### 场景 B: 用户询问总览或对比

例如 "列出所有 ADaM 数据集"、"哪些是 BDS 结构"、"PK 相关的数据集有哪些"

**做法**: 直接基于 index.md 回答,必要时再读取相关数据集 MD 做补充。

### 场景 C: 用户要求生成 dummy data

例如 "生成 ADSL 的 dummy 数据"、"我要测试 ADAE,给我造一份"、"生成 ADLB dummy"

**做法**: 调用本 skill 目录下的 R 脚本（路径相对 skill 自身目录，无需硬编码绝对路径）:

```bash
Rscript .claude/skills/adam/generate_dummy.R <DATASET> [n_subjects] [out_dir]
```

参数:
- `<DATASET>`: ADaM 数据集名称(必填),例如 `ADSL`、`ADAE`、`ADLB`
- `[n_subjects]`: 受试者数量(可选,默认 30)
- `[out_dir]`: 输出目录(可选,默认 `/tmp/adam_dummy/`)

脚本会:
1. 读取 `references/<DATASET>.md` 提取变量结构
2. 若设置了环境变量 `ADAM_REF_DIR` 指向真实 dummy 数据目录,则参考 `<dataset>.sas7bdat`(若存在)推断真实分布;否则纯按变量类型生成
3. 生成 `.sas7bdat` 与 `.qs` 双格式输出到 `out_dir`
4. 打印生成结果摘要

### 场景 D: 用户问 ADaM 概念

例如 "什么是 BDS"、"PARAMCD 是什么"、"ANL01FL 怎么用"

**做法**: 基于 index.md 的 "通用变量" 章节回答,必要时引用具体数据集 MD 中的实例。

## 用户需求

$ARGUMENTS

## 示例查询

| 用户问题 | 触发动作 |
|---|---|
| "ADSL 有哪些变量?" | Read `references/ADSL.md` → 列出变量表 |
| "ADAE 的主键是什么?" | Read `references/ADAE.md` → 引用 KeyVariables |
| "ADLB 怎么衍生 BASE?" | Read `references/ADLB.md` → 在衍生方法表中查找 BASE |
| "列出所有 PK 相关数据集" | Read `references/index.md` → 引用 "PK / PD" 类别 |
| "BDS 是什么意思?" | 基于 `references/index.md` 的 ADaM 概念部分回答 |
| "生成 30 个受试者的 ADSL dummy 数据" | Bash: `Rscript .../generate_dummy.R ADSL 30` |
| "我要测试 ADAE 模块,造一份 dummy" | Bash: `Rscript .../generate_dummy.R ADAE` |
| "ADTTE 怎么衍生生存时间?" | Read `references/ADTTE.md` → 查 AVAL/CNSR/STARTDT 衍生方法 |

## 输出要求

- 一律使用**中文(简体)**回答
- 若回答涉及变量列表,优先使用表格(Variable / Label / Type / 用途)
- 引用源时给出具体 md 文件路径,方便用户跳转查看
- 生成 dummy 数据后,告知输出路径与文件大小,并给出 R 中读取该文件的代码片段


