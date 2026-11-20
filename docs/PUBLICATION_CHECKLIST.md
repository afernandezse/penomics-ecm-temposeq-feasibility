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

## Suggested publication flow

1. Create a new GitHub repository named `penomics-ecm-temposeq-feasibility`, initially **Private** until the checklist is complete.
2. Unpack this folder and commit its contents. Keep `.gitignore` from the first commit.
3. Review the tracked file list (`git ls-files`) and the safety scan.
4. Make the repository Public only after institutional approval and safety checks.
5. Create an annotated release `v0.1.0` marked **technical feasibility only**.
6. Optionally connect GitHub to Zenodo and archive the *tagged release* for a DOI. Verify that Zenodo does not accidentally include non-public data.
7. Do not cite a DOI or assert a Zenodo record until an actual DOI has been minted.

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
