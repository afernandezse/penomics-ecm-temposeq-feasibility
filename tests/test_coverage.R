#!/usr/bin/env Rscript
# End-to-end integration test using invented, non-biological genes.
args <- commandArgs(FALSE)
file <- sub("^--file=","",grep("^--file=",args,value=TRUE)[1])
root <- dirname(dirname(normalizePath(file)))
setwd(root)
out <- file.path("local_results","ci_coverage_test")
status <- system2("Rscript",c("scripts/coverage.R","--panel","examples/synthetic_panel.csv",
                               "--gmt","examples/synthetic_sets.gmt","--out",out))
stopifnot(identical(as.integer(status),0L))
s <- read.csv(file.path(out,"coverage_summary.csv"))
stopifnot(nrow(s)==2L)
a <- s[s$signature=="SYN_ECM",]
b <- s[s$signature=="SYN_STROMAL",]
stopifnot(a$total_genes==4L,a$represented==3L,a$missing==1L,
          isTRUE(all.equal(a$coverage_percent,75)))
stopifnot(b$total_genes==3L,b$represented==2L,b$missing==1L)
missing <- read.csv(file.path(out,"missing_genes.csv"))
stopifnot(nrow(missing)==2L,identical(unique(missing$gene_symbol),"SYN_E"))
o <- read.csv(file.path(out,"signature_overlap.csv"))
stopifnot(nrow(o)==1L,o$shared_genes==2L,o$shared_represented==1L,o$union_genes==5L)
cat("PASS: synthetic coverage, missing targets, signature overlap\n")
