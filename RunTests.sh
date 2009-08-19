#!/bin/sh
#
# RunTests.sh
# WOHotKey
#
# Created by Wincent Colaiuta on 01 March 2006.
# Copyright 2006-2007 Wincent Colaiuta.
#

#
# Defaults
#

# test bundle path relative to this script
TEST_BUNDLE="WOHotKeyTests.bundle"

# WOTest.framework path relative to this script
TEST_FRAMEWORK="../../../../WOTest.framework"

#
# Functions
#

check_error_status()
{
  ERR=$?
  if [ $ERR -ne 0 ]; then
    FAILURE=$ERR
  fi
}

#
# Main
#

set -e

STARTING_DIRECTORY=`/bin/pwd`
builtin echo "Saved current working directory: ${STARTING_DIRECTORY}"

SCRIPT_DIRECTORY=$(/usr/bin/dirname "$0")
builtin echo "Changing to script directory: ${SCRIPT_DIRECTORY}"
cd "${SCRIPT_DIRECTORY}"
SCRIPT_DIRECTORY=$(/bin/pwd)
builtin echo "Script directory with symlinks resolved: ${SCRIPT_DIRECTORY}"

if [ "${DYLD_FRAMEWORK_PATH}" != "" ]; then
  SAVE_DLYD_FRAMEWORK_PATH=`declare -p DYLD_FRAMEWORK_PATH`
  builtin echo "Saved old DYLD_FRAMEWORK_PATH: ${SAVE_DLYD_FRAMEWORK_PATH}"
else
  SAVE_DLYD_FRAMEWORK_PATH=""
fi

DYLD_FRAMEWORK_PATH=$(/usr/bin/dirname "${SCRIPT_DIRECTORY}/${TEST_FRAMEWORK}")
cd "${DYLD_FRAMEWORK_PATH}"
export DYLD_FRAMEWORK_PATH=$(/bin/pwd)
cd -
builtin echo "DYLD_FRAMEWORK_PATH set to ${DYLD_FRAMEWORK_PATH}"

builtin echo "Launching test runner for bundle: ${SCRIPT_DIRECTORY}/${TEST_BUNDLE}"
"${SCRIPT_DIRECTORY}/${TEST_FRAMEWORK}/Versions/A/Resources/WOTestRunner" --test-bundle="${SCRIPT_DIRECTORY}/${TEST_BUNDLE}"
check_error_status
builtin echo "Test run complete"

builtin echo "Restoring old DYLD_FRAMEWORK_PATH"
eval "${SAVE_DLYD_FRAMEWORK_PATH}"

builtin echo "Returning to old working directory"
cd "${STARTING_DIRECTORY}"

if [ $FAILURE ]; then
  exit $FAILURE
else
  exit 0
fi
