# GitHub/Zenodo release checklist

## Before first public commit

- [ ] Confirm institution's authorization for public dissemination of the **original code and aggregate coverage results**.
- [ ] Verify that the two preliminary numbers and MSigDB release label match the frozen internal study record.
- [ ] Run `python3 scripts/check_publication.py` at repository root and review its output.
- [ ] Run `Rscript tests/test_coverage.R` locally (requires R; it does **not** require any private data).
- [ ] Ensure git history contains no confidential data; starting with a **new** public repository is safest.
- [ ] Review contributor/ownership/copyright attribution under local institutional policy.
- [ ] Do not upload the internal GMT, probe-level or gene-level matrices, patient-level scores, or sample metadata.
- [ ] Verify the project reference and the funding status wording in the README.

## Suggested publication flow (order matters for Zenodo)

1. Confirm laboratory/institutional authorization to publish the original code and aggregate coverage summary; confirm named software contributors and copyright/license ownership. Review `CITATION.cff` and `LICENSE` accordingly.
2. Audit *all tracked Git history*, current files, and existing GitHub Actions logs for potentially sensitive information. Use the separately supplied **ignored local-only** `local_private/audit_publication.py` and manually review any warnings. A `PASS` cannot establish legal publication rights or anonymity.
3. Run the publication checker and synthetic R tests. Verify both GitHub Actions workflows are green for the intended release commit.
4. Make the repository **public** only after author/rights/security review; GitHub makes past Git history and Actions logs available when changing visibility.
5. **Connect GitHub to Zenodo and enable this repository before publishing a release**; the integration archives newly published GitHub releases, not mere tags. See https://help.zenodo.org/docs/github/enable-repository/ .
6. Commit approved citation metadata and push. Create and publish GitHub Release **v0.1.0** (not merely a `git tag`); use release notes explicitly delimiting synthetic reproducibility vs biological validation.
7. Check Zenodo created an archive, inspect its **software author metadata**, public files and version-specific DOI. If the deposit was not triggered, do not invent a DOI; resolve the integration or deposit separately.
8. Insert the verified software citation/DOI in the scientific-technical AEI memorandum, never presenting this repository as validated patient-derived biology.

## Example commands

```bash
python3 scripts/check_publication.py
Rscript tests/test_coverage.R
# On an empty repository, after reviewing content:
git init
git add .
git status --short
git commit -m "Initial technical feasibility workflow and aggregate coverage summary"
# Replace USER with the actual GitHub username or approved organization:
git branch -M main
git remote add origin https://github.com/USER/penomics-ecm-temposeq-feasibility.git
git push -u origin main
```

**Do not** paste a personal access token into this chat or commit it in the repository. Use the GitHub sign-in flow or local `gh auth login`.
