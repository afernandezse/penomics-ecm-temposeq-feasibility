#!/usr/bin/env Rscript
# PEN-OMICS: deterministic end-to-end ssGSEA test using SYNTHETIC data only.
# Reference values were observed on R 4.3.3, DESeq2 1.42.1, GSVA 1.50.5.
cmd <- commandArgs(trailingOnly = FALSE)
file_flag <- grep('^--file=', cmd, value = TRUE)
if (length(file_flag) != 1L) stop('Run via Rscript tests/test_ssgsea.R')
file <- sub('^--file=', '', file_flag)
root <- dirname(dirname(normalizePath(file, mustWork = TRUE)))
setwd(root)

for (package in c('DESeq2', 'GSVA')) {
  if (!requireNamespace(package, quietly = TRUE)) {
    stop('Missing package: ', package)
  }
}

run_one <- function(out) {
  unlink(out, recursive = TRUE)  # remove stale synthetic results before running
  args <- c('scripts/normalize_ssgsea.R',
            '--counts', 'examples/synthetic_counts.csv',
            '--probe-map', 'examples/synthetic_probe_map.csv',
            '--gmt', 'examples/synthetic_sets.gmt',
            '--out', out)
  status <- system2('Rscript', args = args)
  stopifnot(identical(as.integer(status), 0L))
  required <- c('size_factors.csv', 'gene_set_coverage_after_filtering.csv',
                'ssgsea_scores.csv', 'analysis_provenance.txt')
  stopifnot(all(file.exists(file.path(out, required))))
  out
}

a <- run_one('local_results/ci_ssgsea_test_a')
b <- run_one('local_results/ci_ssgsea_test_b')

scores_a <- read.csv(file.path(a, 'ssgsea_scores.csv'), check.names = FALSE)
scores_b <- read.csv(file.path(b, 'ssgsea_scores.csv'), check.names = FALSE)
stopifnot(identical(scores_a, scores_b))
stopifnot(identical(scores_a$signature, c('SYN_ECM', 'SYN_STROMAL')))
stopifnot(identical(names(scores_a)[-1],
                    c('TOY_SAMPLE_01','TOY_SAMPLE_02','TOY_SAMPLE_03')))
values <- as.matrix(scores_a[-1])
stopifnot(all(is.finite(values)))

# Pinned numeric regression check only for the verified GSVA version. Other
# GSVA releases still undergo the structure/finite/repeatability checks above.
if (as.character(packageVersion('GSVA')) == '1.50.5') {
  expected <- matrix(c(
    0.465188645630431, 3.50963322528506,
    1.42705670153216, -1.31357276627411,
    1.86379419515482, -1.00298232860354
  ), nrow = 2L)
  stopifnot(isTRUE(all.equal(unname(values), expected, tolerance = 1e-6)))
} else {
  message('NOTE: numeric 1.50.5 golden-value assertion skipped for GSVA ',
          as.character(packageVersion('GSVA')))
}

cov <- read.csv(file.path(a, 'gene_set_coverage_after_filtering.csv'))
stopifnot(identical(cov$signature, c('SYN_ECM', 'SYN_STROMAL')))
stopifnot(identical(as.integer(cov$original_members), c(4L, 3L)))
stopifnot(identical(as.integer(cov$nonzero_members), c(3L, 2L)))

sf <- read.csv(file.path(a, 'size_factors.csv'))
stopifnot(identical(sf$sample_id, names(scores_a)[-1]))
stopifnot(all(is.finite(sf$size_factor)), all(sf$size_factor > 0))

prov <- readLines(file.path(a, 'analysis_provenance.txt'), warn = FALSE)
stopifnot(any(grepl('Genes with zero total counts excluded: 0', prov, fixed = TRUE)))
stopifnot(any(grepl('GSVA version:', prov, fixed = TRUE)))
stopifnot(any(grepl('DESeq2 version:', prov, fixed = TRUE)))

cat('PASS: synthetic DESeq2/GSVA ssGSEA; finite scores, verified gene-set ',
    'coverage, normalized size factors, reproducibility, and provenance\n', sep = '')
