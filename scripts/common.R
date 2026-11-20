# Original PEN-OMICS technical-feasibility utilities (base R).
parse_cli <- function(args) {
  if (length(args) %% 2L != 0L) stop("Every flag needs a value, e.g. --gmt file.gmt")
  if (length(args) == 0L) stop("Missing arguments. See README.md")
  keys <- args[seq.int(1L, length(args), by = 2L)]
  vals <- args[seq.int(2L, length(args), by = 2L)]
  if (any(!grepl("^--[a-z][a-z-]*$", keys))) stop("Malformed CLI flag")
  if (anyDuplicated(keys)) stop("Repeated CLI flag")
  setNames(as.list(vals), sub("^--", "", keys))
}
required <- function(opts, field) {
  result <- opts[[field]]
  if (is.null(result) || !nzchar(result)) stop(paste("Required --", field, " is missing", sep=""))
  result
}
script_directory <- function() {
  args <- commandArgs(trailingOnly=FALSE)
  hit <- grep("^--file=", args, value=TRUE)
  if (!length(hit)) stop("Run this program via Rscript")
  dirname(normalizePath(sub("^--file=", "", hit[[1]]), mustWork=TRUE))
}
read_gmt <- function(path) {
  if (!file.exists(path)) stop("GMT file not found: ", path)
  x <- readLines(path, warn=FALSE, encoding="UTF-8")
  x <- x[nzchar(trimws(x))]
  if (!length(x)) stop("Empty GMT")
  out <- lapply(seq_along(x), function(i) {
    fields <- strsplit(x[[i]], "\t", fixed=TRUE)[[1]]
    if (length(fields) < 3L) stop("Invalid GMT line ", i)
    genes <- trimws(fields[-c(1,2)])
    genes <- genes[nzchar(genes)]
    if (!length(genes)) stop("GMT has no genes at line ", i)
    if (anyDuplicated(genes)) stop("Repeated gene in GMT set: ", fields[[1]])
    genes
  })
  names(out) <- vapply(x, function(s) strsplit(s, "\t", fixed=TRUE)[[1]][[1]], "")
  if (anyDuplicated(names(out))) stop("Repeated GMT signature name")
  out
}
write_csv <- function(x, path) {
  utils::write.csv(x, path, row.names=FALSE, na="")
}
find_col <- function(x, wanted) {
  hits <- which(tolower(names(x)) == tolower(wanted))
  if (length(hits) != 1L) stop("Expected exactly one column named: ", wanted)
  hits
}
read_csv_strict <- function(path) {
  if (!file.exists(path)) stop("File not found: ", path)
  d <- utils::read.csv(path, check.names=FALSE, stringsAsFactors=FALSE,
                       na.strings=c("NA"), fileEncoding="UTF-8")
  if (!nrow(d) || !ncol(d)) stop("Empty CSV: ", path)
  if (anyDuplicated(names(d))) stop("Duplicated column headers in: ", path)
  d
}
valid_gene_symbols <- function(x) {
  # No case conversion, alias expansion, or cross-species remapping is done.
  if (any(is.na(x)) || any(!nzchar(trimws(x)))) stop("Missing/empty gene symbol")
  trimws(as.character(x))
}
read_count_matrix <- function(path, first_column_name) {
  d <- read_csv_strict(path)
  gene_idx <- find_col(d, first_column_name)
  if (gene_idx != 1L) stop("The identifier column must be the FIRST CSV column")
  ids <- valid_gene_symbols(d[[1]])
  if (anyDuplicated(ids) && first_column_name == "probe_id") stop("Duplicated probe IDs")
  x <- as.matrix(d[-1])
  suppressWarnings(storage.mode(x) <- "double")
  if (ncol(x) < 2L) stop("At least two samples are required for DESeq2 normalisation")
  if (anyNA(x) || any(!is.finite(x)) || any(x < 0) || any(x != floor(x))) {
    stop("Count matrix must contain finite non-negative integers only")
  }
  if (anyDuplicated(colnames(x)) || any(!nzchar(colnames(x)))) stop("Invalid sample columns")
  rownames(x) <- ids
  x
}
