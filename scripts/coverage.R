#!/usr/bin/env Rscript
source(file.path(dirname(normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value=TRUE)[1]))), "common.R"))
opts <- parse_cli(commandArgs(trailingOnly=TRUE))
panel <- read_csv_strict(required(opts, "panel"))
gene_symbols <- unique(valid_gene_symbols(panel[[find_col(panel, "gene_symbol")]]))
gmt_path <- required(opts, "gmt")
sets <- read_gmt(gmt_path)
out <- required(opts, "out")
if (!grepl("(^|/)(local_results|local_private)(/|$)", gsub("\\\\", "/", out))) {
  stop("Safety guard: output path must be under an ignored 'local_results/' or 'local_private/' directory")
}
dir.create(out, recursive=TRUE, showWarnings=FALSE)
summary <- do.call(rbind, lapply(names(sets), function(name) {
  genes <- sets[[name]]
  n <- sum(genes %in% gene_symbols)
  data.frame(signature=name,total_genes=length(genes),represented=n,
             missing=length(genes)-n,coverage_percent=round(100*n/length(genes),2))
}))
per_gene <- do.call(rbind, lapply(names(sets), function(name) {
  gs <- sets[[name]]
  data.frame(signature=name,gene_symbol=gs,represented=gs %in% gene_symbols)
}))
missing <- per_gene[!per_gene$represented,c("signature","gene_symbol"),drop=FALSE]
comb <- if (length(sets) >= 2L) utils::combn(names(sets),2,simplify=FALSE) else list()
overlap <- if (length(comb)) do.call(rbind, lapply(comb,function(pair) {
  shared <- intersect(sets[[pair[1]]], sets[[pair[2]]])
  data.frame(signature_a=pair[1],signature_b=pair[2],shared_genes=length(shared),
             shared_represented=sum(shared %in% gene_symbols),
             union_genes=length(union(sets[[pair[1]]],sets[[pair[2]]])))
})) else data.frame(signature_a=character(),signature_b=character(),
                   shared_genes=integer(),shared_represented=integer(),union_genes=integer())
write_csv(summary,file.path(out,"coverage_summary.csv"))
write_csv(per_gene,file.path(out,"per_gene_coverage.csv"))
write_csv(missing,file.path(out,"missing_genes.csv"))
write_csv(overlap,file.path(out,"signature_overlap.csv"))
writeLines(c(
  "Method: exact, case-sensitive, non-aliased gene symbol matching",
  paste0("Panel: ", normalizePath(required(opts,"panel"))),
  paste0("GMT: ", normalizePath(gmt_path)),
  paste0("Distinct panel symbols: ", length(gene_symbols)),
  paste0("GMT sets: ",length(sets)),
  paste0("R version: ",getRversion()),
  "Presence is not expression detectability, patient performance, or clinical validity"
),file.path(out,"provenance.txt"))
print(summary)
cat("Outputs written to ", out, " (local, ignored by git)\n",sep="")
