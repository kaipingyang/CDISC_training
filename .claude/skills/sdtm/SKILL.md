---
name: sdtm
description: 回答 SDTM 结构问题，或生成指定域的 dummy SDTM 数据（R tibble 格式）。当用户询问 SDTM domain、变量、结构、SUPPQUAL，或要求生成 dummy SDTM 数据时触发。
trigger: 用户提到 SDTM domain、SDTM 变量、SUPPQUAL、生成 dummy SDTM、SDTM 结构、SDTM 数据格式、AE/DM/EX/LB/VS/DS/MH/TR/TU/RS/PC/PP/EG/CM 等关键词
argument-hint: "[问题或域名，例如：sdtm ae structure | generate dummy DM | what is SUPPQUAL]"
---

# SDTM Skill

两种用途：
1. **回答 SDTM 结构问题** — 解释 domain 含义、变量角色/类型/Core、SUPPQUAL 结构等
2. **生成 dummy SDTM 数据** — 生成指定域的 R tibble 示例数据（含正确变量和真实值）

---

## 文档结构

所有 SDTM 知识存放于 skill 目录下的 `references/`：

| 文件 | 内容 |
|------|------|
| `references/index.md` | **入口**：所有域按 class 分组的导航表，通用变量规则，Core/Role 说明 |
| `references/overview.md` | 变量 Role/Type/Origin、ISO 8601 日期格式、Study Day 计算、命名规则 |
| `references/SUPPQUAL.md` | 10 固定变量、IDVAR 关联逻辑、常见 SUPP 变量示例 |
| `references/DM.md` / `references/AE.md` / `references/EX.md` 等 | 各域完整变量表、Codelist 值、R dummy 数据示例 |

---

## 用户请求

$ARGUMENTS

---

## 执行流程

### Step 1：读取 index.md

**必须首先读取** skill 目录下的 `references/index.md`，获取：
- 目标域所属 Class（Special Purpose / Events / Interventions / Findings / Trial Design）
- 该域的链接文件名（如 `AE.md`、`LB.md`）
- 通用变量规则和 Core/Role 含义

### Step 2：根据用户意图定向读取

| 用户问题类型 | 读取文件 |
|------------|---------|
| 某个域的变量、结构、Codelist | `references/index.md` → `references/{DOMAIN}.md`（如 `references/AE.md`） |
| SUPPQUAL / SUPP-- 关联方式 | `references/SUPPQUAL.md` |
| 变量 Role / Core / Type / Origin 概念 | `references/overview.md` |
| 跨域关系（如 TU→TR→RS 链路） | `references/index.md`（底部有肿瘤域组合说明） |
| 生成 dummy 数据 | `references/{DOMAIN}.md`（参考文件末尾的 R dummy 示例） |

### Step 3：回答或生成代码

**模式 A：回答结构问题**

- 给出域描述、Class、Structure、关键变量
- 附变量表（Variable / Label / Type / Core / Codelist）
- 附常用 Codelist 值（来自域 .md 文件）
- 如涉及多域关联（如 TU/TR/RS），说明 LinkID 关联逻辑

**模式 B：生成 dummy SDTM 数据（R 代码）**

参考 `references/{DOMAIN}.md` 末尾的 R dummy 数据示例，按以下原则生成：

1. 只包含 Req + Exp 变量（Perm 变量选 2-3 个代表性的）
2. 生成 3-5 行真实感强的示例数据
3. 变量类型正确：datetime → ISO 8601 字符串，integer → `as.integer()`，float → 数字
4. STUDYID = `"CDISCPILOT01"`，USUBJID = `"01-701-1015"` 格式（沿用 CDISC pilot 示例）
5. 日期基准：RFSTDTC = `"2024-01-15"`
6. SEQ 变量从 1 开始递增
7. 使用 `library(tibble)` + `tibble()`

**生成后检查：**
- 变量名对照 `references/{DOMAIN}.md` 变量表核查拼写
- Findings class 每行一个 test result，Events class 每行一个事件

---

## 输出规范

- 中文解释 + 英文 / R 代码
- 关键信息用表格展示
- R 代码可直接运行
