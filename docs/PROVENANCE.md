# Reproducibility and provenance

## Findings to describe accurately

* Assessment date: **2026-11-19**.
* Upstream gene sets: **MSigDB Human v2026.2.Hs** (two prespecified sets).
* Reactome: `REACTOME_EXTRACELLULAR_MATRIX_ORGANIZATION` (M610; 321 nominal gene symbols, 321 with at least one reference probe).
* NABA: `NABA_CORE_MATRISOME` (M5884; 275 nominal gene symbols, 274 with at least one reference probe; `SSPOP` absent).
* Laboratory reference matrix: **22,575 probe rows** representing **19,683 distinct gene symbols**. Neither the counts matrix nor the original probe map is redistributed.
* These are nominal target-presence checks, **not estimates of per-FFPE-sample detectability, signal quality, biological performance, or clinical utility**.

## Data that must remain non-public

1. Original sequencing/count matrices, including the 23-column technical reference export and all patient-level results.
2. Clinical metadata and identifiers, tissue images, spatial data, sample labels, and internal institution-only methods.
3. MSigDB GMT membership files and other third-party files unless downstream redistribution rights have been affirmatively verified.
4. Gene-level abundance summaries derived from non-public matrices, even if they do not contain patient identifiers.

## Exact reproducibility boundary

The script here is reproducible on the included **synthetic** input. Recomputing the 2026-11-19 real-world coverage requires access to (a) the exact licensed MSigDB v2026.2.Hs GMT, (b) the frozen laboratory reference gene mapping, and (c) any contemporaneous transformations of gene identifiers. SHA-256 checksums of those restricted inputs should be recorded in an internal study record; **do not publish the files**. No internal checksum value is invented in this repository.

For the primary analysis, sample-level QC, feature filtering, software environments, and parameter configuration must be frozen before FGA outcome association testing.

## Source pages

* [MSigDB v2026.2.Hs release](https://docs.gsea-msigdb.org/MSigDB/Release_Notes/MSigDB_2026.2.Hs/)
* [MSigDB license terms](https://www.gsea-msigdb.org/gsea/msigdb_license_terms.jsp)
* [Reactome ECM Organization](https://www.gsea-msigdb.org/gsea/msigdb/human/geneset/REACTOME_EXTRACELLULAR_MATRIX_ORGANIZATION.html)
* [NABA Core Matrisome](https://www.gsea-msigdb.org/gsea/msigdb/human/geneset/NABA_CORE_MATRISOME.html)
* [GSVA](https://bioconductor.org/packages/GSVA)
* [DESeq2](https://bioconductor.org/packages/DESeq2)
