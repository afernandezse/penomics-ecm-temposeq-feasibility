# Prespecified technical and biological analysis framework (research plan, not findings)

## 1. Technical signature feasibility (covered in this repository)

1. Obtain the licensed original MSigDB Human **v2026.2.Hs** GMT for `REACTOME_EXTRACELLULAR_MATRIX_ORGANIZATION` and `NABA_CORE_MATRISOME`.
2. Preserve gene names and set membership exactly as downloaded and freeze input checksums internally.
3. Compare the distinct gene symbols mapped to the laboratory TempO-Seq WHT reference count matrix with each signature. Summarize nominal presence, missing symbols and signature overlap.
4. Treat `SSPOP` as absent: **do not** infer it is the same as `SSPO` without an explicit, supported gene-identity decision.
5. Keep *gene presence in assay* distinct from *detectable expression in individual specimens*.

## 2. Future patient analysis (not performed here)

* Population: 67 independent FFPE penile squamous cell carcinoma cases, subject to QC and study authorization.
* Technical processing: map WHT probes to gene symbols, sum probe-level raw counts per gene, filter technically invalid features following frozen QC rules; calculate DESeq2 size factors (`poscounts` selected here for robustness to zero-rich matrices), divide counts by size factors, and use `log2(count + 1)`.
* Signature scoring: GSVA ssGSEA, `alpha=0.25`, **`normalize=FALSE`**. The same data universe and filtering must be applied to both gene sets. Freeze versions/parameters before examining genome associations.
* Primary outcome: Reactome ECM ssGSEA score (standardized across cases for interpretation); explanatory predictor: FGA, continuous, expressed per 10 percentage points; two-sided linear regression with beta/95% CI/p-value. Include HPV, TP53 alterations and tumor cellularity where missingness, event distribution and model stability permit; assess histologic stromal proportion as a sensitivity analysis.
* Prespecified sensitivity: NABA Core Matrisome, not an additional primary contrast.
* Secondary/exploratory: IFN/cytotoxic immunity, epithelial plasticity, IHC and fibroblast-associated processes with appropriate multiple-testing control. Spatial analysis in eight selected FFPE cases is mechanistic exploration, not an independent statistical validation cohort.
* Null FGA–ECM association does not invalidate independently supported spatial or functional exploratory work.

## 3. Interpretation guardrails

1. FGA is **fraction of genome altered**, not the gene symbol `FGA` (fibrinogen alpha chain); do not confuse them.
2. Neither nominal signature coverage nor ssGSEA in a demonstration dataset constitutes a clinical biomarker.
3. Distinguish tumor-intrinsic regulation from stromal cellular admixture and FFPE quality.
4. Without treated ICI cohorts, no clinical ICI response prediction can be claimed.
5. Do not label transcriptomic or imaging hypotheses as proven causal mechanisms.
