---
name: sdtm-map
description: 用 sdtm.oak 创建 SDTM 域映射代码。用户描述目标域和数据，自动生成映射脚本。
trigger: sdtm、SDTM、域映射、DM域、AE域、VS域、CM域、LB域、EX域、create sdtm、生成SDTM、sdtm.oak、原始数据映射
---

# SDTM 域映射助手（sdtm.oak 框架）

这个 skill 帮助临床数据人员用自然语言描述需求，自动生成符合 CDISC 规范的 SDTM 域映射代码。不需要深厚的 R 编程基础，只需告诉我你想创建哪个域、原始数据长什么样，我来生成可运行的脚本。

---

## 使用流程

### Step 1 — 确认目标域

首先询问用户要创建哪个 SDTM 域。常见域及用途：

| 域代码 | 域名称 | 存放内容 |
|--------|--------|----------|
| DM | Demographics（人口学） | 年龄、性别、种族、入组日期 |
| AE | Adverse Events（不良事件） | 不良事件名称、严重程度、开始/结束日期 |
| VS | Vital Signs（生命体征） | 血压、心率、体温、体重、身高 |
| CM | Concomitant Medications（合并用药） | 合并使用的药物名称、剂量、用药日期 |
| LB | Laboratory Tests（实验室检查） | 血常规、生化指标等检验结果 |
| EX | Exposure（药物暴露） | 研究药物的给药剂量、频率、日期 |

提示语示例：
> 你好！请告诉我你想创建哪个 SDTM 域？如果不确定，可以描述你的数据内容，我来帮你判断。

---

### Step 2 — 了解原始数据

在用户确认目标域后，询问以下信息：

1. **原始数据来源**：是 SAS XPT 文件、CSV 文件，还是用 pharmaverse 内置测试数据？
2. **关键变量名**：原始数据中有哪些关键变量（比如受试者编号叫 `SUBJID` 还是 `PATID`）？
3. **特殊要求**：是否需要单位转换？是否有特殊编码规则？

如果用户不确定，默认使用 `pharmaversesdtm` 包提供的测试数据，直接生成可运行示例。

---

### Step 3 — 生成代码模板

根据用户选择的域，生成对应的完整可运行代码。

---

#### DM 域（人口学信息）完整模板

```r
# ── 加载必要包 ──────────────────────────────────────────────────────────────
library(sdtm.oak)       # SDTM 映射核心包
library(dplyr)          # 数据处理
library(haven)          # 读取 SAS XPT 文件
library(pharmaversesdtm) # pharmaverse 官方测试数据

# ── 读取原始数据 ─────────────────────────────────────────────────────────────
# 使用 pharmaverse 内置测试数据，可替换为实际文件路径
# 例如：raw_dm <- haven::read_xpt("path/to/your/dm_raw.xpt")
raw_dm <- read_xpt(system.file("extdata/dm.xpt", package = "pharmaversesdtm"))

# 查看原始数据结构（调试用）
glimpse(raw_dm)

# ── SDTM DM 域映射 ────────────────────────────────────────────────────────────
dm <- raw_dm |>
  # 研究编号：直接复制原始变量
  assign_no_ct(
    raw_dat = raw_dm,
    raw_var = "STUDYID",
    tgt_var = "STUDYID"
  ) |>
  # 固定值：域代码
  mutate(DOMAIN = "DM") |>
  # 受试者编号
  assign_no_ct(
    raw_dat = raw_dm,
    raw_var = "SUBJID",
    tgt_var = "SUBJID"
  ) |>
  # 唯一受试者标识符（通常是研究编号 + 受试者编号拼接）
  mutate(USUBJID = paste0(STUDYID, "-", SUBJID)) |>
  # 年龄
  assign_no_ct(
    raw_dat = raw_dm,
    raw_var = "AGE",
    tgt_var = "AGE"
  ) |>
  # 年龄单位（固定值）
  mutate(AGEU = "YEARS") |>
  # 性别（使用受控术语 CT）
  assign_ct(
    raw_dat = raw_dm,
    raw_var = "SEX",
    tgt_var = "SEX",
    ct_spec = NULL  # 替换为你的 CT spec 对象
  ) |>
  # 种族
  assign_ct(
    raw_dat = raw_dm,
    raw_var = "RACE",
    tgt_var = "RACE",
    ct_spec = NULL
  ) |>
  # 入组日期
  assign_no_ct(
    raw_dat = raw_dm,
    raw_var = "RFSTDTC",
    tgt_var = "RFSTDTC"
  )

# ── 检查结果 ──────────────────────────────────────────────────────────────────
glimpse(dm)
head(dm)

# ── 导出 XPT 文件 ──────────────────────────────────────────────────────────────
library(xportr)
dm |>
  xportr_write("dm.xpt", label = "Demographics")

message("DM 域生成完成！文件已保存为 dm.xpt")
```

---

#### AE 域（不良事件）完整模板

```r
# ── 加载包 ──────────────────────────────────────────────────────────────────
library(sdtm.oak)
library(dplyr)
library(haven)
library(pharmaversesdtm)

# ── 读取原始数据 ──────────────────────────────────────────────────────────────
raw_ae <- read_xpt(system.file("extdata/ae.xpt", package = "pharmaversesdtm"))
glimpse(raw_ae)

# ── AE 域映射 ─────────────────────────────────────────────────────────────────
ae <- raw_ae |>
  # 基础标识变量
  assign_no_ct(raw_dat = raw_ae, raw_var = "STUDYID", tgt_var = "STUDYID") |>
  mutate(DOMAIN = "AE") |>
  assign_no_ct(raw_dat = raw_ae, raw_var = "USUBJID", tgt_var = "USUBJID") |>
  # 序列号（每个受试者内的 AE 编号）
  derive_seq(tgt_var = "AESEQ", rec_vars = "USUBJID") |>
  # 不良事件名称（原始词）
  assign_no_ct(raw_dat = raw_ae, raw_var = "AETERM", tgt_var = "AETERM") |>
  # 严重程度（使用受控术语：MILD/MODERATE/SEVERE）
  assign_ct(
    raw_dat = raw_ae,
    raw_var = "AESEV",
    tgt_var = "AESEV",
    ct_spec = NULL  # 替换为实际 CT spec
  ) |>
  # 是否严重不良事件（Y/N）
  assign_ct(
    raw_dat = raw_ae,
    raw_var = "AESER",
    tgt_var = "AESER",
    ct_spec = NULL
  ) |>
  # 开始日期（ISO 8601 格式，如 2024-01-15）
  assign_no_ct(raw_dat = raw_ae, raw_var = "AESTDTC", tgt_var = "AESTDTC") |>
  # 结束日期
  assign_no_ct(raw_dat = raw_ae, raw_var = "AEENDTC", tgt_var = "AEENDTC") |>
  # 与研究药物的因果关系
  assign_ct(
    raw_dat = raw_ae,
    raw_var = "AEREL",
    tgt_var = "AEREL",
    ct_spec = NULL
  )

# ── 检查结果 ──────────────────────────────────────────────────────────────────
glimpse(ae)

# ── 导出 ──────────────────────────────────────────────────────────────────────
library(xportr)
ae |> xportr_write("ae.xpt", label = "Adverse Events")

message("AE 域生成完成！")
```

---

#### VS 域（生命体征）完整模板

VS 域的特点是原始数据通常是"宽格式"（每个指标一列），需要转为 SDTM 要求的"长格式"（每行一条记录）。

```r
# ── 加载包 ──────────────────────────────────────────────────────────────────
library(sdtm.oak)
library(dplyr)
library(tidyr)
library(haven)

# ── 读取原始数据（示例：宽格式）─────────────────────────────────────────────
# 假设原始数据每列是一个生命体征指标
# 替换为你的实际数据路径
raw_vs <- read_xpt("path/to/vs_raw.xpt")
# 或使用测试数据：
# raw_vs <- read_xpt(system.file("extdata/vs.xpt", package = "pharmaversesdtm"))

# ── 宽格式转长格式 ────────────────────────────────────────────────────────────
vs <- raw_vs |>
  # 将生命体征各列转为参数化长格式
  pivot_longer(
    cols = c(SYSBP, DIABP, PULSE, TEMP, WEIGHT, HEIGHT),
    names_to  = "VSTESTCD",   # 检测项目代码
    values_to = "VSSTRESN"    # 数值型结果
  ) |>
  # 域代码
  mutate(DOMAIN = "VS") |>
  # 检测项目中文全称
  mutate(
    VSTEST = case_when(
      VSTESTCD == "SYSBP"  ~ "Systolic Blood Pressure",   # 收缩压
      VSTESTCD == "DIABP"  ~ "Diastolic Blood Pressure",  # 舒张压
      VSTESTCD == "PULSE"  ~ "Pulse Rate",                # 脉搏
      VSTESTCD == "TEMP"   ~ "Temperature",               # 体温
      VSTESTCD == "WEIGHT" ~ "Weight",                    # 体重
      VSTESTCD == "HEIGHT" ~ "Height"                     # 身高
    )
  ) |>
  # 标准单位
  mutate(
    VSSTRESU = case_when(
      VSTESTCD %in% c("SYSBP", "DIABP") ~ "mmHg",
      VSTESTCD == "PULSE"  ~ "beats/min",
      VSTESTCD == "TEMP"   ~ "C",
      VSTESTCD == "WEIGHT" ~ "kg",
      VSTESTCD == "HEIGHT" ~ "cm"
    )
  ) |>
  # 字符型结果（数值转字符）
  mutate(VSSTRESC = as.character(VSSTRESN)) |>
  # 序列号
  derive_seq(tgt_var = "VSSEQ", rec_vars = c("USUBJID", "VSTESTCD"))

# ── 导出 ──────────────────────────────────────────────────────────────────────
library(xportr)
vs |> xportr_write("vs.xpt", label = "Vital Signs")

message("VS 域生成完成！")
```

---

#### CM 域（合并用药）模板

```r
library(sdtm.oak)
library(dplyr)
library(haven)

raw_cm <- read_xpt("path/to/cm_raw.xpt")

cm <- raw_cm |>
  assign_no_ct(raw_dat = raw_cm, raw_var = "STUDYID", tgt_var = "STUDYID") |>
  mutate(DOMAIN = "CM") |>
  assign_no_ct(raw_dat = raw_cm, raw_var = "USUBJID", tgt_var = "USUBJID") |>
  derive_seq(tgt_var = "CMSEQ", rec_vars = "USUBJID") |>
  # 药物名称（原始记录）
  assign_no_ct(raw_dat = raw_cm, raw_var = "CMTRT", tgt_var = "CMTRT") |>
  # 剂量
  assign_no_ct(raw_dat = raw_cm, raw_var = "CMDOSE", tgt_var = "CMDOSE") |>
  # 剂量单位
  assign_no_ct(raw_dat = raw_cm, raw_var = "CMDOSU", tgt_var = "CMDOSU") |>
  # 给药途径
  assign_ct(
    raw_dat = raw_cm,
    raw_var = "CMROUTE",
    tgt_var = "CMROUTE",
    ct_spec = NULL
  ) |>
  # 开始日期
  assign_no_ct(raw_dat = raw_cm, raw_var = "CMSTDTC", tgt_var = "CMSTDTC")

library(xportr)
cm |> xportr_write("cm.xpt", label = "Concomitant Medications")
```

---

#### LB 域（实验室检查）模板

```r
library(sdtm.oak)
library(dplyr)
library(haven)

raw_lb <- read_xpt("path/to/lb_raw.xpt")

lb <- raw_lb |>
  assign_no_ct(raw_dat = raw_lb, raw_var = "STUDYID", tgt_var = "STUDYID") |>
  mutate(DOMAIN = "LB") |>
  assign_no_ct(raw_dat = raw_lb, raw_var = "USUBJID", tgt_var = "USUBJID") |>
  derive_seq(tgt_var = "LBSEQ", rec_vars = c("USUBJID", "LBTESTCD")) |>
  # 检验项目代码（如 ALT、AST、WBC）
  assign_no_ct(raw_dat = raw_lb, raw_var = "LBTESTCD", tgt_var = "LBTESTCD") |>
  # 检验项目全称
  assign_no_ct(raw_dat = raw_lb, raw_var = "LBTEST", tgt_var = "LBTEST") |>
  # 数值结果
  assign_no_ct(raw_dat = raw_lb, raw_var = "LBSTRESN", tgt_var = "LBSTRESN") |>
  # 单位
  assign_no_ct(raw_dat = raw_lb, raw_var = "LBSTRESU", tgt_var = "LBSTRESU") |>
  # 正常范围低值
  assign_no_ct(raw_dat = raw_lb, raw_var = "LBSTNRLO", tgt_var = "LBSTNRLO") |>
  # 正常范围高值
  assign_no_ct(raw_dat = raw_lb, raw_var = "LBSTNRHI", tgt_var = "LBSTNRHI") |>
  # 采样日期
  assign_no_ct(raw_dat = raw_lb, raw_var = "LBDTC", tgt_var = "LBDTC")

library(xportr)
lb |> xportr_write("lb.xpt", label = "Laboratory Tests")
```

---

#### EX 域（药物暴露）模板

```r
library(sdtm.oak)
library(dplyr)
library(haven)

raw_ex <- read_xpt("path/to/ex_raw.xpt")

ex <- raw_ex |>
  assign_no_ct(raw_dat = raw_ex, raw_var = "STUDYID", tgt_var = "STUDYID") |>
  mutate(DOMAIN = "EX") |>
  assign_no_ct(raw_dat = raw_ex, raw_var = "USUBJID", tgt_var = "USUBJID") |>
  derive_seq(tgt_var = "EXSEQ", rec_vars = "USUBJID") |>
  # 研究药物名称
  assign_no_ct(raw_dat = raw_ex, raw_var = "EXTRT", tgt_var = "EXTRT") |>
  # 给药剂量
  assign_no_ct(raw_dat = raw_ex, raw_var = "EXDOSE", tgt_var = "EXDOSE") |>
  # 剂量单位
  assign_no_ct(raw_dat = raw_ex, raw_var = "EXDOSU", tgt_var = "EXDOSU") |>
  # 给药频率（QD、BID 等）
  assign_ct(
    raw_dat = raw_ex,
    raw_var = "EXDOSFRQ",
    tgt_var = "EXDOSFRQ",
    ct_spec = NULL
  ) |>
  # 给药开始日期
  assign_no_ct(raw_dat = raw_ex, raw_var = "EXSTDTC", tgt_var = "EXSTDTC") |>
  # 给药结束日期
  assign_no_ct(raw_dat = raw_ex, raw_var = "EXENDTC", tgt_var = "EXENDTC")

library(xportr)
ex |> xportr_write("ex.xpt", label = "Exposure")
```

---

### Step 4 — 验证提示

代码运行后，提醒用户如何验证结果：

```r
# 方法 1：检查变量数量和内容
glimpse(dm)
summary(dm)

# 方法 2：检查必填变量是否存在
required_vars <- c("STUDYID", "DOMAIN", "USUBJID")
all(required_vars %in% names(dm))  # 应返回 TRUE

# 方法 3：检查缺失值
colSums(is.na(dm))

# 方法 4：用 Pinnacle 21 Community 软件验证生成的 XPT 文件
# 下载地址：https://www.pinnacle21.com/trials
```

---

### Step 5 — 下一步引导

SDTM 映射完成后，提示用户：

1. **其他域**：用相同的方式继续创建 AE、VS、CM 等其他域
2. **ADaM 数据集**：SDTM 是分析数据的基础，下一步可以用 SDTM 派生 ADaM 数据集
3. **提交包检查**：用 Pinnacle 21 Community 对所有 XPT 文件进行合规性检查

---

## 常见问题解答

### Q1：运行代码时提示"找不到某个变量"怎么办？

原始数据中的变量名可能与模板中不同。先运行以下代码查看实际变量名：

```r
# 查看所有变量名
names(raw_dm)

# 或者
colnames(raw_dm)
```

然后把模板中的 `raw_var = "STUDYID"` 改为你数据里实际的变量名。

---

### Q2：如何处理缺失值（NA）？

sdtm.oak 的 `assign_no_ct()` 和 `assign_ct()` 默认保留缺失值。如果需要填充或过滤：

```r
# 过滤掉某变量为 NA 的行
dm <- dm |> filter(!is.na(AGE))

# 用固定值填充缺失
dm <- dm |> mutate(AGEU = if_else(is.na(AGEU), "YEARS", AGEU))
```

---

### Q3：如何使用受控术语（Controlled Terminology，CT）？

CT 是 CDISC 规定的标准编码表，确保数值标准化。使用方式：

```r
# 方式 1：使用 CDISC CT 包（如果有的话）
library(cdisc.ct)  # 需要安装

# 方式 2：手动创建简单的映射
# 例如：把原始的 "M"/"F" 映射为 SDTM 标准的 "M"/"F"
dm <- dm |>
  mutate(SEX = case_when(
    SEX == "Male"   ~ "M",
    SEX == "Female" ~ "F",
    TRUE ~ NA_character_
  ))
```

---

### Q4：`assign_no_ct()` 和 `assign_ct()` 有什么区别？

- **`assign_no_ct()`**：直接复制原始值，不做任何转换。用于数字、日期、自由文本等不需要标准化的变量。
- **`assign_ct()`**：按照受控术语（CT）映射表转换值。用于性别、种族、严重程度等有固定编码规范的变量。

---

### Q5：生成的 XPT 文件在哪里？

默认保存在当前 R 工作目录下。运行以下代码查看：

```r
getwd()  # 显示当前工作目录
```

可以用 `xportr_write("path/to/output/dm.xpt", ...)` 指定完整路径。

---

## 项目本地参考脚本

如果项目目录中已有以下文件，优先参考这些完整示例：

- `sdtm/dm.R` — DM 域（人口学）完整映射脚本
- `sdtm/ae.R` — AE 域（不良事件）完整映射脚本
- `sdtm/vs.R` — VS 域（生命体征）完整映射脚本

这些脚本包含实际项目的变量映射逻辑，比上面的模板更贴近你的数据结构。

---

## 快速安装所需包

如果还没有安装 sdtm.oak 相关包，运行以下命令：

```r
# 安装 CDISC pharmaverse 相关包
install.packages(c("sdtm.oak", "xportr", "pharmaversesdtm", "haven", "dplyr", "tidyr"))

# 验证安装
library(sdtm.oak)
packageVersion("sdtm.oak")
```
