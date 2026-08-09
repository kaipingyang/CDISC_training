---
name: adam-derive
description: 用 admiral 创建 ADaM 分析数据集代码。用户描述目标数据集，自动生成 derive_* 框架代码。
trigger: adam、ADaM、adsl、ADSL、adae、ADAE、advs、ADVS、adtte、ADTTE、create adam、生成ADaM、admiral、分析数据集
---

# ADaM 数据集代码生成助手

本 skill 帮助不熟悉 R 的临床数据人员，用自然语言描述目标数据集，自动生成基于 admiral 框架的 ADaM 代码模板。ADaM（Analysis Data Model）是建立在 SDTM 基础上、供统计分析直接使用的标准化数据集格式。本 skill 适合刚接触 R 的临床数据经理、统计程序员助手，以及需要快速原型的分析人员。

---

## ADaM 数据集类型一览

| 数据集 | 全称 | 用途 |
|--------|------|------|
| **ADSL** | Subject-Level Analysis Dataset | 受试者级别数据集（每人一行），包含治疗组、人口学、随访状态，是所有其他 ADaM 数据集的基础 |
| **ADAE** | Adverse Events Analysis Dataset | 不良事件分析数据集，标记 TRTEMFL（治疗期间出现的不良事件，即 TEAE） |
| **ADVS** | Vital Signs Analysis Dataset | 生命体征分析数据集，含基线值（BASE）、变化量（CHG）、百分变化（PCHG） |
| **ADTTE** | Time-to-Event Analysis Dataset | 时间-事件数据集，用于生存分析（如总生存期 OS、无进展生存期 PFS） |
| **ADPC** | PK Concentration Analysis Dataset | 药代动力学浓度数据集，分析药物暴露量 |
| **ADLB** | Laboratory Analysis Dataset | 实验室检查分析数据集，含正常范围标志、毒性分级 |

---

## 使用流程

### Step 1 - 确认目标数据集

询问用户要创建哪个 ADaM 数据集：
- 是 ADSL、ADAE、ADVS、ADTTE，还是其他？
- 是否已有项目本地脚本可以参考（见下方"项目本地脚本"）？

### Step 2 - 确认 SDTM 输入

询问：
- 已有哪些 SDTM 域（如 DM、AE、VS、EX 等）？
- 数据文件存放在哪个路径（XPT 格式还是 R 对象）？
- 如果没有真实数据，可先用 `pharmaversesdtm` 包的测试数据练习。

### Step 3 - 生成代码模板

根据用户需求，从下方模板中选择对应的代码提供给用户。

---

#### ADSL 模板（受试者级别数据集）

```r
# ── 加载包 ──────────────────────────────────────────────────────────────
library(admiral)
library(dplyr)
library(haven)
library(pharmaversesdtm)   # SDTM 测试数据（练习用）
library(pharmaverseadam)   # ADaM 测试数据（参考对比用）

# ── 读取 SDTM 输入 ────────────────────────────────────────────────────────
# 使用 pharmaverse 内置测试数据（实际项目请替换为真实路径）
dm <- pharmaversesdtm::dm
ex <- pharmaversesdtm::ex

# ── 构建 ADSL ────────────────────────────────────────────────────────────
adsl <- dm |>
  # 筛除筛选失败受试者（Screen Failure）
  filter(ARMCD != "Scrnfail") |>
  # 派生治疗组变量
  mutate(
    TRT01P = ARM,     # 计划治疗（Protocol-specified Treatment）
    TRT01A = ACTARM   # 实际治疗（Actual Treatment）
  ) |>
  # 派生年龄组（用于分层分析）
  derive_var_age_impute(
    age_var = AGE,
    new_var = AGEGR1,
    age_cuts = c(0, 65),
    age_labels = c("<65", ">=65")
  ) |>
  # 派生入组日期（字符型 ISO 日期 → SAS 数字日期）
  derive_vars_dt(
    new_vars_prefix = "TRTS",
    dtc = RFSTDTC
  ) |>
  # 派生结束日期
  derive_vars_dt(
    new_vars_prefix = "TRTE",
    dtc = RFENDTC
  )

# ── 导出 XPT ──────────────────────────────────────────────────────────────
library(xportr)
adsl |> xportr_write("adsl.xpt", label = "Subject-Level Analysis Dataset")
```

---

#### ADAE 模板（不良事件分析数据集）

```r
# ── 加载包 ──────────────────────────────────────────────────────────────
library(admiral)
library(dplyr)
library(pharmaversesdtm)
library(pharmaverseadam)

# ── 读取输入 ──────────────────────────────────────────────────────────────
ae   <- pharmaversesdtm::ae
adsl <- pharmaverseadam::adsl  # 需先建好 ADSL

# ── 构建 ADAE ────────────────────────────────────────────────────────────
adae <- ae |>
  # 从 ADSL 合并治疗期间信息（用于判断 TEAE）
  derive_vars_merged(
    dataset_add = adsl,
    new_vars = exprs(TRTSDT, TRTEDT, TRT01P, TRT01A),
    by_vars = exprs(STUDYID, USUBJID)
  ) |>
  # 派生 AE 开始日期（字符型 → SAS 数字日期）
  derive_vars_dt(new_vars_prefix = "AST", dtc = AESTDTC) |>
  # 派生 AE 结束日期
  derive_vars_dt(new_vars_prefix = "AEN", dtc = AEENDTC) |>
  # 标记治疗期间出现的不良事件（Treatment-Emergent AE Flag）
  derive_var_trtemfl(
    new_var    = TRTEMFL,
    start_date = ASTDT,
    end_date   = AENDT,
    trt_start_date = TRTSDT,
    trt_end_date   = TRTEDT
  )

# ── 导出 XPT ──────────────────────────────────────────────────────────────
library(xportr)
adae |> xportr_write("adae.xpt", label = "Adverse Events Analysis Dataset")
```

---

#### ADTTE 模板（时间-事件数据集，生存分析）

```r
# ── 加载包 ──────────────────────────────────────────────────────────────
library(admiral)
library(dplyr)
library(pharmaversesdtm)
library(pharmaverseadam)

# ── 读取输入 ──────────────────────────────────────────────────────────────
adsl <- pharmaverseadam::adsl
ae   <- pharmaversesdtm::ae  # 可替换为死亡/进展事件数据

# ── 构建 ADTTE（总生存期 OS）────────────────────────────────────────────
adtte <- adsl |>
  # 派生生存事件参数：发生事件=1，删失=0
  derive_param_tte(
    dataset_adsl = adsl,
    start_date   = TRTSDT,
    event_conditions = list(
      event_source(
        dataset_name = "ae",
        date = AESTDTC,
        set_values_to = exprs(
          EVNTDESC  = "Death",
          CNSDTDESC = NA_character_
        )
      )
    ),
    censor_conditions = list(
      censor_source(
        dataset_name = "adsl",
        date = TRTEDT,
        set_values_to = exprs(
          EVNTDESC  = NA_character_,
          CNSDTDESC = "Last Known Alive"
        )
      )
    ),
    source_datasets = list(ae = ae, adsl = adsl),
    set_values_to = exprs(
      PARAMCD = "OS",
      PARAM   = "Overall Survival"
    )
  )

# ── 导出 XPT ──────────────────────────────────────────────────────────────
library(xportr)
adtte |> xportr_write("adtte.xpt", label = "Time-to-Event Analysis Dataset")
```

---

### Step 4 - 常用 derive_* 函数速查

| 函数 | 用途 | 典型场景 |
|------|------|---------|
| `derive_vars_dt()` | 字符日期转 SAS 数字日期 | RFSTDTC → TRTSDT |
| `derive_vars_merged()` | 合并其他数据集的变量 | 从 ADSL 取治疗日期 |
| `derive_var_trtemfl()` | 标记治疗期间 TEAE | TRTEMFL = "Y" |
| `derive_var_age_impute()` | 年龄分组 | <65 / >=65 |
| `derive_param_tte()` | 时间-事件参数 | OS、PFS |
| `derive_vars_basetype()` | 定义基线类型 | BASETYPE = "LAST" |
| `derive_var_base()` | 计算基线值 | BASE |
| `derive_var_chg()` | 计算变化量 | CHG = AVAL - BASE |
| `derive_var_pchg()` | 计算百分变化 | PCHG = CHG / BASE * 100 |

---

### Step 5 - 验证检查代码

生成数据集后，建议运行以下检查：

```r
# 检查 TRTEMFL 标志（应只有 "Y" 和 NA，没有其他值）
adae |> count(TRTEMFL)

# 检查 ADSL 每人一行（结果应为空 tibble）
adsl |> count(USUBJID) |> filter(n > 1)

# 检查日期变量是否成功派生（不应全为 NA）
adsl |> summarise(
  n_trtsdt = sum(!is.na(TRTSDT)),
  n_total  = n()
)
```

---

### Step 6 - 下一步引导

完成 ADaM 数据集后，可以：
- 使用 **TLG 包**（如 `rtables`、`tern`）基于 ADaM 生成统计报告表格
- 参考项目本地脚本查看完整实现（见下方）
- 访问 admiral 官方文档获取更多函数说明：https://pharmaverse.github.io/admiral/

---

## 常见问题解答

**Q：没有 SDTM 数据怎么练习？**
A：安装 `pharmaversesdtm` 包，直接用 `pharmaversesdtm::dm`、`pharmaversesdtm::ae` 等内置测试数据，无需真实数据即可运行所有模板。

```r
install.packages("pharmaversesdtm")
install.packages("pharmaverseadam")
```

**Q：日期格式不对怎么办？**
A：ADaM 要求 ISO 8601 字符日期（如 `"2023-01-15"`）转为 SAS 数字日期。统一用 `derive_vars_dt()` 处理，不要手动计算。

**Q：TRTEMFL 全是 NA 怎么排查？**
A：按以下顺序检查：
1. 确认 TRTSDT / TRTEDT 是否成功从 ADSL 合并（不是 NA）
2. 确认 ASTDT 是否成功从 AESTDTC 派生
3. 检查日期逻辑：AE 开始日期是否在治疗期间内

**Q：需要更多 admiral 函数怎么查？**
A：在 R 中运行 `?admiral` 或访问官方文档：https://pharmaverse.github.io/admiral/reference/

**Q：如何处理多时期（Multiple Period）研究？**
A：使用 `derive_vars_period()` 函数，admiral 文档中有专门的 vignette 说明。

---

## 项目本地脚本参考

项目中已有完整实现脚本，可作为参考：
- `adam/adsl.R` - ADSL 完整示例
- `adam/adae.R` - ADAE 完整示例
- `adam/advs.R` - ADVS 完整示例
- `adam/adtte.R` - ADTTE 完整示例

如果本地脚本与模板有差异，以本地脚本为准——它已针对项目实际 SDTM 结构做了调整。
