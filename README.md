# PEN-OMICS | ECM signatures in TempO-Seq WHT

[![Validation](https://img.shields.io/badge/status-technical%20feasibility%20only-blue)](#scope-and-limitations)

**Reproducible technical feasibility assessment** of extracellular matrix (ECM) and stromal gene signatures in a TempO-Seq Whole Transcriptome (WHT) reference count matrix, designed for the **PEN-OMICS: From Genome to Niche** research proposal.

> **Scope:** This repository contains an analysis workflow, a small *synthetic* demonstration, and aggregate assay-coverage findings. It contains **no patient-level data, clinical records, internal count matrices, genuine probe annotations, or redistributed MSigDB gene-set membership files**.

## Preliminary technical feasibility findings (19 November 2026)

| Prespecified signature | MSigDB version | Gene-set size | Represented gene symbols in reference matrix | Coverage | Not represented |
|---|---|---:|---:|---:|---|
| `REACTOME_EXTRACELLULAR_MATRIX_ORGANIZATION` (M610) | v2026.2.Hs | 321 | 321 | 100.00% | none |
| `NABA_CORE_MATRISOME` (M5884) | v2026.2.Hs | 275 | 274 | 99.64% | `SSPOP` |

The reference matrix contained **22,575 probe rows** representing **19,683 distinct gene symbols**. These are properties of the supplied laboratory reference export, **not universal specifications** of the TempO-Seq WHT assay or claims about clinical PSCC sample performance. The reference export is not distributed here. `SSPOP` was not silently mapped to `SSPO`.

**Gene represented** means at least one mapped probe/gene symbol is present in the reference matrix. It does **not** mean gene expression is detectable in each sample, that signal is above a threshold, or that a signature has clinical validity. The preliminary survey used a separate reference export and does **not** report findings from the prospective/retrospective PEN-OMICS study cohort.

## Repository contents

```text
scripts/
  coverage.R             # Gene-set presence, missing genes and set overlap (base R)
  normalize_ssgsea.R     # Local-only probe aggregation, DESeq2 and GSVA::ssGSEA
  common.R               # Input validation and helper functions
  check_publication.py   # Safety scan of tracked files before publication
tests/
  test_coverage.R        # Base-R deterministic synthetic integration test
examples/
  synthetic_panel.csv    # Invented symbols (not a real signature or patient data)
  synthetic_counts.csv   # Invented probe-by-sample counts
  synthetic_probe_map.csv
  synthetic_sets.gmt
results/
  public_summary.csv     # Aggregate *preliminary* findings only
config/
  signatures.tsv         # Signature/version/size manifest (no membership genes)
docs/
  ANALYSIS_PLAN.md       # Frozen proposed workflow and limits of inference
  PROVENANCE.md          # Origin, licensing and reproducibility boundaries
  PUBLICATION_CHECKLIST.md
```

## Quick start: presence/coverage audit (no Bioconductor dependencies)

Requirements: **R >= 4.3**. The examples use invented genes and are not an attempt to reproduce the numerical findings above.

```bash
Rscript scripts/coverage.R \
  --panel examples/synthetic_panel.csv \
  --gmt examples/synthetic_sets.gmt \
  --out local_results/synthetic_coverage
Rscript tests/test_coverage.R
```

To check the **actual, licensed signatures** locally, download the exact **Human MSigDB v2026.2.Hs** sets through the [MSigDB website](https://www.gsea-msigdb.org/gsea/msigdb/) under its applicable terms, preserving the original GMT and its checksum outside this repository. Prepare a local, **non-public** CSV with a `gene_symbol` column listing the reference WHT panel's gene mappings; these symbols may repeat if multiple probes target a gene.

```bash
Rscript scripts/coverage.R \
  --panel local_private/reference_gene_symbols.csv \
  --gmt local_private/msigdb_v2026.2.Hs_ECM_NABA.gmt \
  --out local_results/real_coverage
```

The script writes `coverage_summary.csv`, `per_gene_coverage.csv`, `missing_genes.csv`, `signature_overlap.csv`, and `provenance.txt` **only to ignored local directories**. The original full gene-set membership is not included in the GitHub release.

## Optional local ssGSEA workflow (requires R/Bioconductor)

Install dependencies in your local R environment:

```r
install.packages("BiocManager")
BiocManager::install(c("DESeq2", "GSVA"), ask = FALSE)
```

Then run the entirely **synthetic** example:

```bash
Rscript scripts/normalize_ssgsea.R \
  --counts examples/synthetic_counts.csv \
  --probe-map examples/synthetic_probe_map.csv \
  --gmt examples/synthetic_sets.gmt \
  --out local_results/synthetic_scores
```

For local real data use a CSV with `probe_id` as the first header and one sample per remaining column, plus a two-column probe-to-gene map (`probe_id,gene_symbol`). Alternatively, a gene-level count matrix with `gene_symbol` as its first column can be provided **without** `--probe-map`. Only **raw, non-negative integer counts** are accepted. The script aggregates probes by gene (sum), estimates sample-wise DESeq2 size factors using the `poscounts` method, computes `log2(normalized_counts + 1)`, and uses `GSVA::ssgseaParam(alpha=0.25, normalize=FALSE)`. It reports per-sample scores **locally**, which must never be committed.

**Important:** the synthetic demonstration checks workflow behavior, not reproducibility of the preliminary real-data coverage totals. Reproducing the latter requires the original licensed signatures and reference gene/probe mapping held by the laboratory.

## Verification of the synthetic ssGSEA processing chain

After installing `DESeq2` and `GSVA`, run:

```bash
Rscript tests/test_ssgsea.R
```

The test runs the synthetic workflow twice in `local_results/`, checks deterministic
scores, positive DESeq2 size factors, expected signature coverage and provenance.
For **GSVA 1.50.5**, it also compares scores against a recorded numeric reference
obtained using R 4.3.3 / DESeq2 1.42.1. This is a *synthetic workflow regression
check*, not a clinical or biological validation.

For a separate, **manually triggered** cloud check, open GitHub **Actions** and
select **ssgsea-synthetic-manual** → **Run workflow**. Dependency provisioning on
GitHub-hosted runners uses external package services and may fail independently
of the tested analysis. The original automatic coverage workflow is unchanged.

## Scope and limitations

* **Technical coverage, not biological or clinical validation.** No differential expression, FGA association, response prediction, classifier, ICI signature validation, or functional result is reported here.
* The reported reference coverage does not establish coverage or expression in the **67-patient PEN-OMICS FFPE cohort**. The planned **8-sample spatial substudy** is separate.
* No patient-derived analysis outputs will be published without appropriate consent/legal review, pseudonymization assessment, and institutional approvals.
* The planned primary biological contrast (continuous FGA vs the prespecified Reactome ECM ssGSEA score) is **a hypothesis**, not an observed association. NABA is a predefined **sensitivity analysis**, not a second primary test.
* ssGSEA scores depend on sample processing, available gene universe, filtering, and software versions. For actual study analyses, versions and thresholds must be frozen and documented before looking at FGA associations.

## Citation and reproducible release

The repository includes [`CITATION.cff`](CITATION.cff) for GitHub's **Cite this repository** feature. The author field initially reflects the existing group attribution **PEN-OMICS contributors**; **confirm the approved named authors and institutional ownership before making the repository public or depositing it in Zenodo**. The first reviewed software release is intended to be **v0.1.0**; the actual Zenodo DOI must be added **only once a deposit exists**. Cite the *version-specific DOI* in the PEN-OMICS application when available.

The successful synthetic GitHub Actions checks establish computational execution in separate environments, not clinical reproducibility or independent confirmation of the aggregate reference-panel coverage. No real sample-level measurements are distributed.

## Citation, references and rights

The R/Python code authored for this repository is distributed under the MIT license. **This does not apply to MSigDB content, the original TempO-Seq matrices, third-party datasets, or clinical data.** Obtain and use upstream sets under the [MSigDB license](https://www.gsea-msigdb.org/gsea/msigdb_license_terms.jsp). Source pages: [Reactome ECM](https://www.gsea-msigdb.org/gsea/msigdb/human/geneset/REACTOME_EXTRACELLULAR_MATRIX_ORGANIZATION.html), [NABA Core Matrisome](https://www.gsea-msigdb.org/gsea/msigdb/human/geneset/NABA_CORE_MATRISOME.html). Software: [GSVA](https://bioconductor.org/packages/GSVA) and [DESeq2](https://bioconductor.org/packages/DESeq2). See [docs/PROVENANCE.md](docs/PROVENANCE.md).

This repository is a **technical feasibility supplement** and does not imply that PEN-OMICS results have been produced or that the funding proposal has been awarded.
