#!/bin/bash

# Run Bandit on touched .py files in a Pull Request. Do a full scan otherwise.
# Defaults will ignoring tests and the local settings file.
# NOTE: Bandit's file exclusion seems to be kind of busted: https://github.com/PyCQA/bandit/issues/488
# Using Git to exclude test files instead for the PR check.

BANDIT_CONFIGSTRING="--verbose"
FULLRUN_TARGET=${TARGET_DIR:-""}
EXCLUDED=${BANDIT_EXCLUDE:-"*/tests/*,*/settings/local.py"}
MSG_TEMPLATE="::error file={relpath},line={line}::[{test_id}] {msg}%0A(Severity: {severity}, Confidence: {confidence})%0AMore info: https://bandit.readthedocs.io/en/latest/search.html?q={test_id}"
BANDIT_REPORT=${BANDIT_REPORT:-"$HOME/bandit_report.out"}
RC=0

pushd $GITHUB_WORKSPACE &>/dev/null
bandit --version

[[ ! -z "$BANDIT_DEBUG" ]] && set -x

touch bandit_stdout

if [ -z "$GITHUB_HEAD_REF" ]; then
  # No different commits, not a PR
  # Check everything, not just a PR diff (there is no PR diff in this context).
  # NOTE: this file scope may need to be expanded or refined further.
  echo "Running Bandit on all files, excluding \"$EXCLUDED\""
  bandit $BANDIT_CONFIGSTRING -r "./$FULLRUN_TARGET" -x "$EXCLUDED" -o $BANDIT_REPORT -f txt
  RC=$?
else
    git fetch ${GITHUB_BASE_REF/#/'origin '} &>/dev/null
    git fetch ${GITHUB_HEAD_REF/#/'origin '} &>/dev/null
    BASE_REF=$(git rev-parse ${GITHUB_BASE_REF/#/'origin/'})
    HEAD_REF=$(git rev-parse ${GITHUB_HEAD_REF/#/'origin/'})
    FILES=$(git diff --name-only $BASE_REF $HEAD_REF -- '*.py')

    if [ -z "$FILES" ]; then
      echo "No files for Bandit to check" | tee $BANDIT_REPORT bandit_stdout
      RC=0
    else
      echo "Running Bandit on $FILES"
      bandit $BANDIT_CONFIGSTRING -x "$EXCLUDED" -o $BANDIT_REPORT -f txt $FILES
      bandit $BANDIT_CONFIGSTRING -x "$EXCLUDED" -o bandit_stdout  -f custom --msg-template "$MSG_TEMPLATE" $FILES
      RC=$?
    fi
fi
echo "======================"
cat $BANDIT_REPORT
echo "======================"
echo "::set-output name=<bandit_stdout>::$(cat bandit_stdout)"
echo "exiting script: $RC"
exit $RC
