# py3-bandit-action
GitHub action to run [python Bandit](https://pypi.org/project/bandit/ "PyPi Bandit")

If triggered through a PullRequest, this action will run bandit only on changed files. On merge to your release branch, this action will run bandit on the entire code-base.

# Usage
To use this github action, configure a YAML workflow file, e.g. `.github/workflows/bandit.yml`, with the following:
```yaml
name: Bandit
on:
  pull_request:
  push:
    branches:
      - master #dev, release, etc.
  release:
    types:
      - created

jobs:
  bandit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
        with:
          fetch-depth: 0 #get fuller history
      - name: Run Bandit Report
        uses: libertyy/py3-bandit-check@v1
      - name: Save Bandit txt Report
        if: ${{ always() }}
        uses: actions/upload-artifact@v2
        with:
          path: ${{ RUNNER.temp }}/_github_home/bandit_report.out
```

## Inputs
This action uses environment variables to override some of the defaults used to invoke bandit

| Name | Description | Default |
|------|-------------|---------|
|TARGET_DIR | On full run, target this directory and its contents | "./" |
|BANDIT_EXCLUDE| Bandit exclude pattern | '*/tests/*,*/settings/local.py' |
| BANDIT_REPORT| Fully Qualified path for the bandit txt report| "$HOME/_github_home/bandit_report.out" |
|BANDIT_DEBUG| Run bandit with `set -x`| empty |
