#!/usr/bin/env Rscript
source(file.path(dirname(normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value=TRUE)[1]))), "common.R"))
opts <- parse_cli(commandArgs(trailingOnly=TRUE))
for (pkg in c("DESeq2","GSVA")) {
  if (!requireNamespace(pkg,quietly=TRUE)) stop("Missing required Bioconductor package: ",pkg)
}
out <- required(opts,"out")
if (!grepl("(^|/)(local_results|local_private)(/|$)", gsub("\\\\", "/", out))) {
  stop("Safety guard: per-sample outputs must remain in an ignored local_results/ or local_private/ directory")
}
gmt <- read_gmt(required(opts,"gmt"))
counts_file <- required(opts,"counts")
probe_file <- opts[["probe-map"]]
if (!is.null(probe_file)) {
  counts <- read_count_matrix(counts_file,"probe_id")
  m <- read_csv_strict(probe_file)
  if (ncol(m)!=2L || !setequal(tolower(names(m)),c("probe_id","gene_symbol"))) {
    stop("Probe mapping file must contain exactly probe_id,gene_symbol")
  }
  probes <- valid_gene_symbols(m[[find_col(m,"probe_id")]])
  genes <- valid_gene_symbols(m[[find_col(m,"gene_symbol")]])
  if (anyDuplicated(probes)) stop("Duplicate probe-to-gene mapping")
  if (!all(rownames(counts) %in% probes)) stop("Unmapped probes in count matrix")
  gene_symbol <- genes[match(rownames(counts), probes)]
  # rowsum preserves the sum of raw counts and creates one row per gene.
  gene_counts <- rowsum(counts, group=gene_symbol, reorder=TRUE)
  mode <- "sum_raw_probe_counts_per_gene"
} else {
  counts <- read_count_matrix(counts_file,"gene_symbol")
  if (anyDuplicated(rownames(counts))) stop("Duplicate gene symbols: supply unique gene-level counts or probe mapping")
  gene_counts <- counts
  mode <- "already_gene_aggregated"
}
keep <- rowSums(gene_counts) > 0
removed <- sum(!keep)
gene_counts <- gene_counts[keep,,drop=FALSE]
if (nrow(gene_counts) < 2L) stop("Insufficient nonzero genes for normalization")
# The selected 'poscounts' method is explicit and robust when many genes include zero counts.
sf <- DESeq2::estimateSizeFactorsForMatrix(gene_counts, type="poscounts")
if (any(!is.finite(sf)) || any(sf <= 0)) stop("Invalid size factors")
norm <- sweep(gene_counts,2,sf,"/")
expr <- log2(norm + 1)
intersections <- lapply(gmt,intersect,y=rownames(expr))
if (any(lengths(intersections) < 2L)) {
  stop("Every signature needs >=2 represented nonzero genes for this analysis; check signatures and mapping")
}
param <- GSVA::ssgseaParam(exprData=expr,geneSets=gmt,alpha=0.25,normalize=FALSE,
                           minSize=2,maxSize=Inf)
scores <- GSVA::gsva(param,verbose=FALSE)
if (!is.matrix(scores) && !is.data.frame(scores)) stop("Unexpected GSVA output")
dir.create(out,recursive=TRUE,showWarnings=FALSE)
write_csv(data.frame(sample_id=colnames(gene_counts),
                     size_factor=as.numeric(sf)),file.path(out,"size_factors.csv"))
write_csv(data.frame(signature=rownames(scores),as.data.frame(scores,check.names=FALSE),
                     check.names=FALSE),file.path(out,"ssgsea_scores.csv"))
write_csv(data.frame(signature=names(intersections),
                     original_members=lengths(gmt),
                     nonzero_members=lengths(intersections)),
          file.path(out,"gene_set_coverage_after_filtering.csv"))
writeLines(c(
  paste0("Source matrix: ",normalizePath(counts_file)),
  paste0("Probe mapping: ",if(is.null(probe_file)) "not supplied" else normalizePath(probe_file)),
  paste0("Aggregation: ",mode),
  paste0("Genes with zero total counts excluded: ",removed),
  "Normalization: DESeq2::estimateSizeFactorsForMatrix(type='poscounts'); log2(count/sizeFactor+1)",
  "ssGSEA: GSVA::ssgseaParam(alpha=0.25,normalize=FALSE,minSize=2)",
  paste0("R version: ",getRversion()),
  paste0("GSVA version: ",as.character(utils::packageVersion("GSVA"))),
  paste0("DESeq2 version: ",as.character(utils::packageVersion("DESeq2"))),
  "WARNING: output includes sample-level measurements; NEVER commit/publicly distribute"
),file.path(out,"analysis_provenance.txt"))
cat("Local ssGSEA completed for ",ncol(expr)," samples; output: ",out,"\n",sep="")
