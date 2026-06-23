# =============================================================================
# 数据集名称：ADTTE（Time-to-Event Analysis Dataset，生存分析数据集）
# =============================================================================
# 功能说明：
#   构建 ADTTE 用于生存分析（Kaplan-Meier 曲线、Cox 回归等），
#   包含两个主要终点：OS（总生存期）和 PFS（无进展生存期）。
#   每个受试者每个终点一行，记录事件是否发生及事件/删失日期。
#
# 使用的包：
#   - admiral        : ADaM 构建核心工具包
#   - admiralonco    : 肿瘤学 ADaM 扩展包（提供 PFS 等肿瘤特定功能）
#   - metacore/metatools : 规格书驱动的变量校验
#   - xportr         : 导出为 SAS 传输文件
#   - pharmaverseadam : ADaM 示例数据（ADSL、ADRS）
#
# 输入数据来源：
#   - pharmaverseadam::adsl       : ADSL（提供随机化日期 RANDDT、末次存活日期等）
#   - pharmaverseadam::adrs_onco  : ADRS（肿瘤缓解数据，含 DEATH/PD/LSTA 等记录）
#   - metadata/onco_spec.xlsx     : ADTTE 规格书
#
# 输出文件：
#   - adtte.xpt（SAS 传输文件，写入 tempdir()）
#
# 关键概念说明：
#   生存分析核心概念：
#   - 事件（event）：感兴趣的终点发生（如死亡、疾病进展）
#   - 删失（censor）：观察期结束时事件尚未发生（如末次随访仍存活）
#   - AVAL：从随机化到事件/删失的天数（生存时间）
#   - EVNTDESC/CNSDTDSC：事件/删失原因描述
#   OS（总生存期）：从随机化到死亡的时间（死亡=事件，末次存活=删失）
#   PFS（无进展生存期）：从随机化到疾病进展或死亡的时间（二者先发生者为事件）
#   事件优先级：先检查 ADRS 中的 PD 记录，再检查死亡；多个来源时取最早发生的
# =============================================================================

## ----r message=FALSE, warning=FALSE-------------------------------------------
library(admiral)
library(admiralonco)
library(dplyr)
library(lubridate)
library(metacore)
library(metatools)
library(xportr)
library(pharmaverseadam)

## ----r read-specs-------------------------------------------------------------
# Load metacore specifications
# 读取 ADTTE 规格书，定义终点变量、受控术语等
metacore <- spec_to_metacore("./metadata/onco_spec.xlsx") %>%
  select_dataset("ADTTE")

# Load source datasets
adsl <- pharmaverseadam::adsl
adrs <- pharmaverseadam::adrs_onco

# 将 adrs_onco 赋值给 adrs（简化后续引用）
adrs <- adrs_onco

## ----r------------------------------------------------------------------------
# 定义事件来源和删失来源
# 这是生存分析的核心配置：告诉程序从哪些数据集、哪些记录判断事件/删失

# 死亡事件：ADRS 中 PARAMCD=="DEATH" 且 AVALC=="Y" 且分析标志="Y" 的记录
death_event <- event_source(
  dataset_name = "adrs",
  filter = PARAMCD == "DEATH" & AVALC == "Y" & ANL01FL == "Y",
  date = ADT,
  set_values_to = exprs(
    EVNTDESC = "Death",
    SRCDOM = "ADRS",
    SRCVAR = "ADT"
  )
)

# 疾病进展事件（PD）：ADRS 中 PARAMCD=="PD" 且分析标志="Y" 的记录
pd_event <- event_source(
  dataset_name = "adrs",
  filter = PARAMCD == "PD" & ANL01FL == "Y",
  date = ADT,
  set_values_to = exprs(
    EVNTDESC = "Progressive Disease",
    SRCDOM = "ADRS",
    SRCVAR = "ADT"
  )
)

# OS 删失1：末次已知存活（来自 ADSL.LSTALVDT）
# 当患者未死亡时，以末次存活日作为删失时间
lastalive_censor <- censor_source(
  dataset_name = "adsl",
  date = LSTALVDT,
  set_values_to = exprs(
    EVNTDESC = "Last Known Alive",
    CNSDTDSC = "Last Known Alive Date",
    SRCDOM = "ADSL",
    SRCVAR = "LSTALVDT"
  )
)

# PFS 删失1：末次肿瘤评估（PARAMCD=="LSTA"，Last Tumor Assessment）
# 当患者既无进展也未死亡时，以末次评估日作为删失时间
lasta_censor <- censor_source(
  dataset_name = "adrs",
  filter = PARAMCD == "LSTA" & ANL01FL == "Y",
  date = ADT,
  set_values_to = exprs(
    EVNTDESC = "Progression Free Alive",
    CNSDTDSC = "Last Tumor Assessment",
    SRCDOM = "ADRS",
    SRCVAR = "ADT"
  )
)

# 随机化日期删失：极端情况下，若没有任何存活证据，以随机化日期作为删失
rand_censor <- censor_source(
  dataset_name = "adsl",
  date = RANDDT,
  set_values_to = exprs(
    EVNTDESC = "Randomization Date",
    CNSDTDSC = "Randomization Date",
    SRCDOM = "ADSL",
    SRCVAR = "RANDDT"
  )
)

## ----r------------------------------------------------------------------------
# Derive Overall Survival (OS)
# 从随机化日（RANDDT）开始，
# 死亡为事件（death_event），末次存活或随机化日为删失（顺序重要：先lastalive再rand）
adtte <- derive_param_tte(
  dataset_adsl = adsl,
  start_date = RANDDT,
  event_conditions = list(death_event),
  censor_conditions = list(lastalive_censor, rand_censor),
  source_datasets = list(adsl = adsl, adrs = adrs),
  set_values_to = exprs(PARAMCD = "OS", PARAM = "Overall Survival")
)

# Derive Progression-Free Survival (PFS)
# PFS 事件：疾病进展（PD）或死亡，以先发生者为准
# 删失：末次肿瘤评估或随机化日
adtte_pfs <- adtte %>%
  derive_param_tte(
    dataset_adsl = adsl,
    start_date = RANDDT,
    event_conditions = list(pd_event, death_event),
    censor_conditions = list(lasta_censor, rand_censor),
    source_datasets = list(adsl = adsl, adrs = adrs),
    set_values_to = exprs(PARAMCD = "PFS", PARAM = "Progression-Free Survival")
  )

## ----r------------------------------------------------------------------------
# Derive analysis value
# AVAL：从随机化到事件/删失日（ADT）的天数，这是 Kaplan-Meier 分析的输入值
adtte_aval <- adtte_pfs %>%
  derive_vars_duration(
    new_var = AVAL,
    start_date = STARTDT,
    end_date = ADT
  )

## ----r------------------------------------------------------------------------
# Derive analysis sequence number
# ASEQ：每个受试者内记录的序号（OS和PFS各一行，所以每个受试者应有2条记录）
adtte_aseq <- adtte_aval %>%
  derive_var_obs_number(
    by_vars = exprs(STUDYID, USUBJID),
    order = exprs(PARAMCD),
    check_type = "error"
  )

## ----r------------------------------------------------------------------------
# Add ADSL variables
# 将 ADSL 中的人口学和治疗变量合并入 ADTTE，供分层分析使用
adtte_adsl <- adtte_aseq %>%
  derive_vars_merged(
    dataset_add = adsl,
    by_vars = exprs(STUDYID, USUBJID)
  )

## ----r, message=FALSE, warning=FALSE------------------------------------------
# Apply metadata and perform checks
# 质控：补全规格变量、删除多余变量、检查受控术语合规、排列列和行顺序
adtte_adsl_checked <- adtte_adsl %>%
  add_variables(metacore) %>%
  drop_unspec_vars(metacore) %>%
  check_variables(metacore) %>%
  check_ct_data(metacore) %>%
  order_cols(metacore) %>%
  sort_by_key(metacore)

# Apply apply labels, formats, and export the dataset to an XPT file.
# 设置 SAS 格式属性（类型/长度/标签/数据集标签）准备提交
adtte_final <- adtte_adsl_checked %>%
  xportr_type(metacore, domain = "ADTTE") %>%
  xportr_length(metacore) %>%
  xportr_label(metacore) %>%
  xportr_df_label(metacore)

# Write dataset to XPT file (optional)
# 导出为 SAS 传输文件（.xpt），用于统计分析软件（SAS/R）读取
dir <- tempdir()
xportr_write(adtte_final, file.path(dir, "adtte.xpt"))
