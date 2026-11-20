#!/usr/bin/env python3
"""Fail closed on unexpected public files, large or binary artifacts.

This is an independent belt-and-suspenders check, NOT a guarantee of anonymity.
Every proposed public file must still be reviewed manually and institutionally.
"""
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
ALLOWED = {
    '.gitignore', 'LICENSE', 'README.md',
    '.github/workflows/validate.yml',
    'config/signatures.tsv', 'results/public_summary.csv',
    'scripts/common.R', 'scripts/coverage.R', 'scripts/normalize_ssgsea.R',
    'scripts/check_publication.py', 'tests/test_coverage.R',
    'examples/synthetic_panel.csv', 'examples/synthetic_sets.gmt',
    'examples/synthetic_probe_map.csv', 'examples/synthetic_counts.csv',
    'docs/PROVENANCE.md', 'docs/ANALYSIS_PLAN.md', 'docs/PUBLICATION_CHECKLIST.md'
}
LIMIT_BYTES = 150_000


def files_for_review():
    if (ROOT / '.git').exists():
        run = subprocess.run(['git', '-C', str(ROOT), 'ls-files', '-z'],
                             capture_output=True, check=True)
        return [Path(s.decode()) for s in run.stdout.split(b'\0') if s]
    return [p.relative_to(ROOT) for p in ROOT.rglob('*')
            if p.is_file() and '.git' not in p.relative_to(ROOT).parts and
            not any(x.startswith('local_') for x in p.relative_to(ROOT).parts)]


def main():
    listed = {p.as_posix() for p in files_for_review()}
    errors = []
    extras = listed - ALLOWED
    if extras:
        errors.append('Files not in strict allowlist: ' + ', '.join(sorted(extras)))
    missing = ALLOWED - listed
    if missing:
        errors.append('Expected release files missing: ' + ', '.join(sorted(missing)))
    for rel in sorted(listed & ALLOWED):
        p = ROOT / rel
        if not p.is_file():
            errors.append(f'Missing: {rel}')
            continue
        payload = p.read_bytes()
        if len(payload) > LIMIT_BYTES:
            errors.append(f'Too large for approved package: {rel}')
        if b'\x00' in payload:
            errors.append(f'Binary content found: {rel}')
        try:
            payload.decode('utf-8')
        except UnicodeDecodeError:
            errors.append(f'Non UTF-8 content: {rel}')
    if errors:
        print('BLOCKED: publication safety check FAILED')
        print('\n'.join(errors))
        return 1
    print(f'PASS: {len(listed)} allowlisted, text-only, small publication files')
    print('Manual rights/privacy review is still required before making the repo public.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
