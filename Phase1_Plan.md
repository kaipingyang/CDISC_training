# Phase 1 计划书：CDISC Training Skill 开发

## 项目背景

**目标受众**：对 AI 和 R 了解不深的临床数据人员  
**核心目标**：通过 Claude Code skill，让用户能用自然语言驱动生成 SDTM 和 ADaM 数据集  
**参考起点**：[pharmaverse/examples](https://github.com/pharmaverse/examples) — 使用 sdtm.oak + admiral 的完整示例

---

## Phase 1 范围

将 pharmaverse/examples 的 SDTM 和 ADaM 脚本改造成可复用的 Claude Code skill，并配套 renv 锁定版本。

---

## 步骤计划

### Step 1：搭建项目结构 + renv 环境

```
CDISC_training/
├── renv.lock              # 版本锁定
├── renv/
├── .Rprofile              # renv 自动激活
├── DESCRIPTION            # 依赖声明
├── data/
│   └── raw/               # 原始 CDISC pilot 数据 (sdtm.oak 内置)
├── sdtm/
│   ├── dm.R
│   ├── ae.R
│   └── vs.R
├── adam/
│   ├── adsl.R
│   ├── adae.R
│   └── advs.R
└── .claude/
    └── skills/
        ├── sdtm-domain/   # SDTM skill
        └── adam-domain/   # ADaM skill
```

**关键包**：
- `sdtm.oak` — SDTM 映射引擎
- `admiral` — ADaM 构建框架
- `metacore` — 元数据/规格驱动
- `metatools` — 数据集验证
- `xportr` — 导出 XPT 文件

**操作**：
1. `renv::init()` 初始化
2. 安装上述包
3. `renv::snapshot()` 锁定版本

---

### Step 2：下载并整理 pharmaverse/examples 参考脚本

从 GitHub 获取：
- `sdtm/dm.R`, `sdtm/ae.R`, `sdtm/vs.R`
- `adam/adsl.R`, `adam/adae.R`, `adam/advs.R`, `adam/adtte.R`

**整理工作**：
- 注释关键步骤（中文注释，方便受众理解）
- 拆分为可独立运行的模块
- 确认数据路径使用 pharmaverse 内置测试数据（`pharmaverseadam`、`pharmaversesdtm` 包）

---

### Step 3：开发 `sdtm-domain` Skill

**Skill 功能**：用户描述域名和数据特征，skill 生成对应 SDTM 映射代码

```
触发关键词：sdtm、SDTM、域映射、DM域、AE域、VS域、
           create sdtm、生成SDTM、sdtm.oak
```

**Skill 内容结构**：
1. 询问目标域（DM/AE/VS/CM等）
2. 提示用户确认原始数据变量名
3. 生成 sdtm.oak 映射模板代码
4. 提供 metatools 验证步骤
5. 生成 xportr 导出代码

**文件**：`~/.claude/skills/sdtm-domain/SKILL.md`

---

### Step 4：开发 `adam-domain` Skill

**Skill 功能**：用户描述需要的 ADaM 数据集，skill 生成 admiral 代码框架

```
触发关键词：adam、ADaM、adsl、adae、advs、adtte、
           create adam、生成ADaM、admiral
```

**Skill 内容结构**：
1. 询问目标数据集（ADSL/ADAE/ADVS等）
2. 引导用户提供 SDTM 输入域
3. 生成 admiral derive_* 函数调用框架
4. 提供变量级别验证检查点
5. 生成 xportr 导出和标签设置

**文件**：`~/.claude/skills/adam-domain/SKILL.md`

---

### Step 5：端到端测试 + 文档

**测试流程**（使用内置测试数据）：
1. 运行 `sdtm/dm.R` → 生成 DM.xpt
2. 运行 `sdtm/ae.R` → 生成 AE.xpt  
3. 运行 `adam/adsl.R`（依赖DM） → 生成 ADSL.xpt
4. 运行 `adam/adae.R`（依赖ADSL+AE） → 生成 ADAE.xpt

**文档**：
- `README.md` — 项目说明 + 环境搭建步骤
- 每个 skill 内嵌使用示例（中文）

---

## 成功标准

- [ ] `renv.lock` 存在，`renv::restore()` 可复现环境
- [ ] sdtm/dm.R、ae.R、vs.R 可无错运行，输出有效 XPT
- [ ] adam/adsl.R、adae.R 可无错运行，输出有效 XPT
- [ ] `sdtm-domain` skill 触发后能生成可运行的 sdtm.oak 代码
- [ ] `adam-domain` skill 触发后能生成可运行的 admiral 代码
- [ ] 非专业用户能按 README 完成环境搭建

---

## Phase 2 预留接口

Phase 2 将基于 pharmaverse.org 完整电子提交流程扩展：
- 更多域：LB、CM、EX、MH 等
- 更多 ADaM：ADPC、ADPPK、ADRS
- Pinnacle 21 验证集成
- Quarto 报告生成

---

## 时间估算

| 步骤 | 工作量 |
|------|--------|
| Step 1: renv + 结构 | 1-2小时 |
| Step 2: 整理参考脚本 | 2-3小时 |
| Step 3: sdtm skill | 2-3小时 |
| Step 4: adam skill | 2-3小时 |
| Step 5: 测试 + 文档 | 1-2小时 |
| **合计** | **8-13小时** |
