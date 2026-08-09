#!/usr/bin/env Rscript
# generate_dummy.R — Generate dummy ADaM dataset based on:
#   1. Variable structure from references/<DATASET>.md (relative to this script)
#   2. Optional reference dummy data via env var ADAM_REF_DIR (if set and file present)
#
# Usage:
#   Rscript generate_dummy.R <DATASET> [n_subjects=30] [out_dir=/tmp/adam_dummy/]
# Examples:
#   Rscript generate_dummy.R ADSL
#   Rscript generate_dummy.R ADAE 50 /tmp/my_dummy/

suppressPackageStartupMessages({
  library(haven)
  library(dplyr)
  library(stringr)
})
# qs is optional (second output format); degrade gracefully if not installed
has_qs <- requireNamespace("qs", quietly = TRUE)

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1) {
  stop("Usage: Rscript generate_dummy.R <DATASET> [n_subjects] [out_dir]")
}
dataset   <- toupper(args[1])
n_subj    <- if (length(args) >= 2) as.integer(args[2]) else 30L
out_dir   <- if (length(args) >= 3) args[3] else "/tmp/adam_dummy/"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

# Resolve paths relative to THIS script, so it works wherever the repo is cloned
get_script_dir <- function() {
  ca <- commandArgs(trailingOnly = FALSE)
  f <- sub("^--file=", "", ca[grepl("^--file=", ca)])
  if (length(f)) return(dirname(normalizePath(f)))
  getwd()
}
SCRIPT_DIR <- get_script_dir()
DOC_DIR  <- file.path(SCRIPT_DIR, "references")
# Optional reference-data directory: set env ADAM_REF_DIR to a folder of <dataset>.sas7bdat
REF_DIR  <- Sys.getenv("ADAM_REF_DIR", unset = "")

# ---- 1. Locate MD spec file --------------------------------------------------
md_file <- file.path(DOC_DIR, paste0(dataset, ".md"))
if (!file.exists(md_file)) {
  # Try ADTTEAE_HEME / ADTTEAE_IO style
  candidates <- list.files(DOC_DIR, pattern = paste0("^", dataset, "(_.*)?\\.md$"), full.names = TRUE)
  if (length(candidates) == 0) {
    stop("Spec MD not found for dataset: ", dataset, " in ", DOC_DIR)
  }
  md_file <- candidates[1]
  message("Using spec: ", basename(md_file))
}

# ---- 2. Parse variable table from MD ----------------------------------------
md_lines <- readLines(md_file, warn = FALSE)
var_section_start <- grep("^## 变量列表", md_lines)
if (length(var_section_start) == 0) {
  stop("No variable section found in ", md_file)
}
# Find the table header. New template uses "| Variable | Label | Type | ..."
hdr_idx <- grep("^\\| Variable \\|", md_lines)
hdr_idx <- hdr_idx[hdr_idx > var_section_start[1]][1]
if (is.na(hdr_idx)) stop("No variable table header in ", md_file)

# Read until blank line / next section
end_idx <- hdr_idx + 2
while (end_idx <= length(md_lines) &&
       grepl("^\\|", md_lines[end_idx]) &&
       !grepl("^## ", md_lines[end_idx])) {
  end_idx <- end_idx + 1
}
table_rows <- md_lines[(hdr_idx + 2):(end_idx - 1)]

parse_row <- function(s) {
  # Markdown table row: "| a | b | c |" - split by |, drop leading/trailing empties only
  cells <- str_split(s, "\\|", simplify = TRUE)[1, ]
  cells <- str_trim(cells)
  # Drop the first and last empty cells caused by leading/trailing |
  if (length(cells) >= 2 && cells[1] == "") cells <- cells[-1]
  if (length(cells) >= 1 && cells[length(cells)] == "") cells <- cells[-length(cells)]
  cells
}
hdr_cells <- parse_row(md_lines[hdr_idx])
varspec <- do.call(rbind, lapply(table_rows, function(s) {
  c <- parse_row(s)
  if (length(c) < length(hdr_cells)) c <- c(c, rep("", length(hdr_cells) - length(c)))
  c[seq_along(hdr_cells)]
}))
colnames(varspec) <- hdr_cells
varspec <- as.data.frame(varspec, stringsAsFactors = FALSE)
varspec$Variable <- gsub("\\*\\*", "", varspec$Variable)
# Keep only valid SAS variable names (letters/digits/underscore, ≤32 chars, starting with letter or _)
valid <- grepl("^[A-Za-z_][A-Za-z0-9_]{0,31}$", varspec$Variable)
if (any(!valid)) {
  cat(sprintf("Filtered out %d rows with invalid Variable names\n", sum(!valid)))
}
varspec <- varspec[valid, , drop = FALSE]
varspec <- varspec[!duplicated(varspec$Variable), , drop = FALSE]

cat(sprintf("Loaded spec for %s: %d variables\n", dataset, nrow(varspec)))

# ---- 3. Try to load reference dummy (only if ADAM_REF_DIR is set) --------------
ref_df <- NULL
if (nzchar(REF_DIR)) {
  ref_file <- file.path(REF_DIR, paste0(tolower(dataset), ".sas7bdat"))
  if (file.exists(ref_file)) {
    ref_df <- tryCatch(haven::read_sas(ref_file), error = function(e) NULL)
    if (!is.null(ref_df)) {
      cat(sprintf("Reference data found: %s (%d rows, %d cols)\n",
                  ref_file, nrow(ref_df), ncol(ref_df)))
    }
  }
}

# ---- 4. Build subject pool ---------------------------------------------------
make_usubjid <- function(n) sprintf("STUDY-001-%04d", seq_len(n))
usubjids <- make_usubjid(n_subj)

# Determine number of rows needed based on dataset structure
ds_overview_idx <- grep("^\\| 结构", md_lines)
structure_str <- ""
if (length(ds_overview_idx)) {
  m <- regmatches(md_lines[ds_overview_idx[1]],
                  regexec("\\| (.+) \\|$", md_lines[ds_overview_idx[1]]))[[1]]
  if (length(m) >= 2) structure_str <- m[2]
}
cat("Structure:", structure_str, "\n")

# Heuristic: rows per subject
rows_per_subj <- 1
sl <- tolower(structure_str)
if (grepl("one record per subject per", sl)) {
  if (grepl("visit", sl) || grepl("timepoint", sl)) rows_per_subj <- 5
  if (grepl("parameter.*visit|visit.*parameter", sl)) rows_per_subj <- 8
  if (grepl("event|adverse|medication|deviation|history", sl)) rows_per_subj <- 4
} else if (grepl("multiple records per subject|>=? 1 record per subject", sl)) {
  rows_per_subj <- 4
}
# Override using ref data if available
if (!is.null(ref_df) && "USUBJID" %in% names(ref_df)) {
  rps <- nrow(ref_df) / length(unique(ref_df$USUBJID))
  rows_per_subj <- max(1L, round(rps))
}
n_rows <- if (dataset == "ADSL") n_subj else n_subj * rows_per_subj
cat(sprintf("Generating %d rows (rows per subject: %d)\n", n_rows, rows_per_subj))

# ---- 5. Generate values for each variable -----------------------------------
gen_value <- function(vname, vtype, vlength, ref_df, n) {
  # Strategy: prefer sampling from ref data; else type-based fallback
  if (!is.null(ref_df) && vname %in% names(ref_df)) {
    pool <- ref_df[[vname]]
    pool <- pool[!is.na(pool)]
    if (length(pool) > 0) {
      return(sample(pool, n, replace = TRUE))
    }
  }
  vtype_l <- tolower(vtype)
  vlen <- suppressWarnings(as.integer(vlength))
  if (is.na(vlen)) vlen <- 8L

  # Type-based generation
  if (grepl("char", vtype_l)) {
    # Smart defaults for known variable names
    switch(vname,
      "STUDYID"  = return(rep("STUDY-001", n)),
      "USUBJID"  = return(sample(usubjids, n, replace = TRUE)),
      "SUBJID"   = return(sprintf("%04d", sample.int(n_subj, n, replace = TRUE))),
      "SITEID"   = return(sample(sprintf("%03d", 1:5), n, replace = TRUE)),
      "COUNTRY"  = return(sample(c("CHN", "USA", "GBR", "AUS"), n, replace = TRUE)),
      "SEX"      = return(sample(c("M", "F"), n, replace = TRUE)),
      "RACE"     = return(sample(c("ASIAN", "WHITE", "BLACK OR AFRICAN AMERICAN", "OTHER"), n, replace = TRUE)),
      "ETHNIC"   = return(sample(c("HISPANIC OR LATINO", "NOT HISPANIC OR LATINO"), n, replace = TRUE)),
      "ARM"      = return(sample(c("Treatment A", "Treatment B", "Placebo"), n, replace = TRUE)),
      "TRT01P"   = return(sample(c("Treatment A", "Treatment B", "Placebo"), n, replace = TRUE)),
      "TRT01A"   = return(sample(c("Treatment A", "Treatment B", "Placebo"), n, replace = TRUE)),
      "ACTARM"   = return(sample(c("Treatment A", "Treatment B", "Placebo"), n, replace = TRUE))
    )
    if (grepl("FL$", vname)) return(sample(c("Y", "N"), n, replace = TRUE, prob = c(0.8, 0.2)))
    if (grepl("DT$|DTC$", vname)) return(sample(format(seq.Date(as.Date("2024-01-01"), as.Date("2025-12-31"), by = "day"), "%Y-%m-%d"), n, replace = TRUE))
    if (grepl("PARAMCD$", vname)) return(sample(c("PARAM1", "PARAM2", "PARAM3"), n, replace = TRUE))
    if (grepl("PARAM$", vname))   return(sample(c("Parameter 1", "Parameter 2", "Parameter 3"), n, replace = TRUE))
    # Generic char
    nchar_use <- min(vlen, 12L)
    return(sapply(seq_len(n), function(i) paste0(sample(LETTERS, nchar_use, replace = TRUE), collapse = "")))
  }

  # Numeric
  switch(vname,
    "AGE"   = return(round(runif(n, 18, 85))),
    "AAGE"  = return(round(runif(n, 18, 85))),
    "WEIGHT" = , "WEIGHTBL" = return(round(runif(n, 50, 100), 1)),
    "HEIGHT" = , "HEIGHTBL" = return(round(runif(n, 150, 195), 1)),
    "BMI"   = , "BMIBL"     = return(round(runif(n, 18, 35), 1)),
    "AVAL"  = return(round(rnorm(n, 50, 15), 2)),
    "BASE"  = return(round(rnorm(n, 50, 15), 2)),
    "CHG"   = return(round(rnorm(n, 0, 5), 2)),
    "PCHG"  = return(round(rnorm(n, 0, 10), 2)),
    "AVISITN" = return(sample(c(1, 2, 3, 4, 5), n, replace = TRUE)),
    "ADY"     = return(sample(seq.int(-7, 365), n, replace = TRUE))
  )
  if (grepl("DT$", vname)) return(as.numeric(sample(seq.Date(as.Date("2024-01-01"), as.Date("2025-12-31"), by = "day"), n, replace = TRUE)))
  round(rnorm(n, 0, 1), 3)
}

# Build data.frame with correct number of rows pre-allocated
df <- data.frame(.row_id = seq_len(n_rows), stringsAsFactors = FALSE)

# Always seed USUBJID first if present
if ("USUBJID" %in% varspec$Variable) {
  if (dataset == "ADSL") {
    usubj_col <- usubjids
  } else {
    usubj_col <- rep(usubjids, each = rows_per_subj)[seq_len(n_rows)]
  }
}

# Tolerate templates without a Length column (new CDISC-based format omits it)
if (is.null(varspec$Length)) varspec$Length <- NA_character_

set.seed(42)
for (i in seq_len(nrow(varspec))) {
  v <- varspec$Variable[i]
  if (v == "USUBJID" && exists("usubj_col")) {
    df[[v]] <- usubj_col
    next
  }
  df[[v]] <- gen_value(v, varspec$Type[i], varspec$Length[i], ref_df, n_rows)
}
df$.row_id <- NULL

# Apply variable labels (from spec)
for (i in seq_len(nrow(varspec))) {
  v <- varspec$Variable[i]; lab <- varspec$Label[i]
  if (v %in% names(df) && nzchar(lab)) {
    attr(df[[v]], "label") <- lab
  }
}

# ---- 6. Write output --------------------------------------------------------
sas_file <- file.path(out_dir, paste0(tolower(dataset), ".sas7bdat"))
qs_file  <- file.path(out_dir, paste0(tolower(dataset), ".qs"))
tryCatch(haven::write_sas(df, sas_file), error = function(e) {
  warning("write_sas failed: ", conditionMessage(e))
})
if (has_qs) qs::qsave(df, qs_file)

cat("\n=== Dummy data generated ===\n")
cat(sprintf("Dataset    : %s\n", dataset))
cat(sprintf("Rows       : %d\n", nrow(df)))
cat(sprintf("Variables  : %d\n", ncol(df)))
cat(sprintf("Subjects   : %d\n", n_subj))
cat(sprintf("SAS file   : %s (%.1f KB)\n", sas_file, file.info(sas_file)$size/1024))
if (has_qs) {
  cat(sprintf("QS file    : %s (%.1f KB)\n", qs_file,  file.info(qs_file)$size/1024))
}
cat("\nLoad in R:\n")
cat(sprintf("  haven::read_sas(\"%s\")\n", sas_file))
if (has_qs) cat(sprintf("  qs::qread(\"%s\")\n", qs_file))
