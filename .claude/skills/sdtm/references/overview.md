# SDTM Structure Overview

> 基于 CDISC SDTMIG v3.4 官方标准整理

---

## What is SDTM

Study Data Tabulation Model (SDTM) is the CDISC standard for organizing and formatting clinical study data submitted to regulatory agencies (FDA, PMDA). It organizes data into **domains** — datasets where each row represents one observation.

---

## General Observation Classes

SDTM domains belong to one of these classes:

| Class | Description | Examples |
|-------|-------------|---------|
| **Special Purpose** | Core study-level and subject-level metadata | DM, CO, SV, SE, SM, SB |
| **Interventions** | Treatments, medications, procedures given to subject | EX, CM, EC, SU, AG, ML, PR |
| **Events** | Occurrences/incidents during study | AE, MH, DS, DV, CE, BE, HO |
| **Findings** | Measurements, assessments, lab results | LB, VS, EG, PE, QS, PC, PP, RS, TR, TU, BS, FA, IS, SC, SS |
| **Trial Design** | Protocol-level information | TA, TE, TV, TD, TI, TM, TS |
| **Relationship** | Links and supplemental qualifiers | RELREC, RELSPEC, RELSUB, SUPP-- |
| **Study Reference** | Reference data not subject-specific | OI, PB |

---

## Dataset Naming Conventions

- Domain abbreviations: 2 characters, uppercase (e.g., `DM`, `AE`, `LB`)
- Supplemental qualifier datasets: `SUPP` + domain (e.g., `SUPPAE`, `SUPPLB`)
- General findings domains with custom suffixes: e.g., `FAAE`, `FACE`
- All variable names: uppercase, ≤8 characters

---

## Variable Roles

Every SDTM variable has a **Role** that defines its semantic function:

| Role | Description | Typical Variables |
|------|-------------|------------------|
| **Identifier** | Uniquely identify a record or subject | STUDYID, DOMAIN, USUBJID, --SEQ, --GRPID |
| **Topic** | Primary focus of the observation | AETERM, CMTRT, LBTESTCD, EXTRT |
| **Synonym Qualifier** | Alternative name/coding for Topic | AEDECOD, CMDECOD, LBTEST |
| **Record Qualifier** | Additional descriptors of the observation | AESER, AESEV, EXDOSE, LBORRES |
| **Variable Qualifier** | Qualifies another variable | EXDOSU (qualifies EXDOSE), LBSTRESU (qualifies LBSTRESN) |
| **Result Qualifier** | Result of a finding/test | LBORRES, LBSTRESC, LBSTRESN |
| **Grouping Qualifier** | Categorizes records | --CAT, --SCAT |
| **Timing** | Date/time context | VISITNUM, VISIT, --DTC, --STDTC, --ENDTC, --DY |
| **Rule** | Logic/algorithm description | TATRTORD |

---

## Core Designations

Each variable has a **Core** value that indicates whether it must be present:

| Core | Meaning |
|------|---------|
| **Req** | Required — must be present and non-null for all records |
| **Exp** | Expected — should be present; explain absence in Reviewer's Guide |
| **Perm** | Permissible — optional; include only when collected/applicable |

---

## Variable Data Types

| Type | Description | Example Variables |
|------|-------------|-----------------|
| `text` | Character string | AETERM, STUDYID, SEX |
| `integer` | Whole number | AESEQ, LBSTRESN (when integer), AGE |
| `float` | Decimal number | LBSTRESN, EXDOSE, VISITNUM |
| `datetime` | ISO 8601 date/time string | AESTDTC, LBDTC, RFSTDTC |

Note: In SDTM, all data are stored as either character or numeric; `datetime` values
are character strings in ISO 8601 format.

---

## Variable Origin

Indicates where the value comes from:

| Origin | Meaning |
|--------|---------|
| **CRF** | Collected directly on the case report form |
| **Derived** | Computed from other data |
| **Assigned** | Determined by sponsor (e.g., coding, mapping) |
| **Protocol** | Fixed value defined in the protocol |
| **eDT** | Electronic data transfer (e.g., central lab) |

---

## Standard Variable Ordering in Datasets

For most general observation class domains (non-Trial Design):
1. **Identifiers**: STUDYID, DOMAIN, USUBJID, [SUBJID], [--SEQ], [--GRPID], [--SPID]
2. **Topic**: --TERM / --TESTCD
3. **Qualifiers**: Synonym, Record, Variable, Grouping, Result qualifiers
4. **Timing**: VISITNUM, VISIT, VISITDY, [EPOCH], --DTC, --STDTC, --ENDTC, --DY

---

## Mandatory Identifier Variables

Every non-Trial Design domain (except CO, RELREC family) starts with these three **Req** variables, in this order:

```
STUDYID  →  DOMAIN  →  USUBJID
```

SUBJID follows as the 4th variable in most domains.

---

## Study Day Calculation

Study day (`--DY`, `--STDY`, `--ENDY`) is calculated from `RFSTDTC` (reference start date):

```
If observation date >= RFSTDTC:  --DY = date - RFSTDTC + 1
If observation date <  RFSTDTC:  --DY = date - RFSTDTC
```

Day 0 does not exist in SDTM — dates before reference start are negative.

---

## ISO 8601 Date Format

All dates stored as **character** variables in ISO 8601 format:

| Precision | Format | Example |
|-----------|--------|---------|
| Full datetime | `YYYY-MM-DDTHH:MM:SS` | `2024-03-15T08:30:00` |
| Date only | `YYYY-MM-DD` | `2024-03-15` |
| Partial year-month | `YYYY-MM` | `2024-03` |
| Year only | `YYYY` | `2024` |

Partial dates are allowed — never impute missing components.

---

## Reference Standards

| Standard | Description |
|----------|-------------|
| SDTMIG v3.4 | CDISC Study Data Tabulation Model Implementation Guide (human clinical trials) |
| SDTM v2.0 | Underlying general model behind the Implementation Guide |
| CDISC Controlled Terminology | NCI EVS-published codelists for SDTM variables |
| pharmaversesdtm | Open-source CDISC pilot test data for examples and QC |
