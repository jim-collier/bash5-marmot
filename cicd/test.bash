#!/bin/bash

## Active shellchecks
# shellcheck disable=1090
# shellcheck disable=1091
# shellcheck disable=2001   ## Complaining about use of sed istead of bash search & replace.
# shellcheck disable=2002   ## Useless use of cat. This works well though and I don't want to break it for the sake of syntax purity.
# shellcheck disable=2004   ## Inappropriate complaining of "$/${} is unnecessary on arithmetic variables."
# shellcheck disable=2119   ## Disable confusing and inapplicable warning about function's $1 meaning script's $1.
# shellcheck disable=2120   ## OK with declaring variables that accept arguments, without calling with arguments (this is 'overloading').
# shellcheck disable=2143   ## Used grep -q instead of echo | grep
# shellcheck disable=2154
# shellcheck disable=2155   ## Disable check to 'Declare and assign separately to avoid masking return values'.
# shellcheck disable=2162
# shellcheck disable=2181
# shellcheck disable=2207
# shellcheck disable=2317   ## Can't reach

## Inactive shellchecks
# shellcheck disable=2034  ## Unused variables.

##	Purpose:
##		- CI/CD-friendly test harness that passes or fails.
##		- Tests random output and round-trips through v2 to make sure the initial output was correct (at least if v2 is also correct).
##		- This is NOT part of cicd script, as it's not a requirement to have v2 installed.
##	History: At bottom of this file. (Note: History for this is maintained outside of [or in addition to] git project.)

##	Copyright © 2026 Jim Collier (ID: 1cv◂‡Vᛦ)
##	Licensed under The MIT License (MIT). Full text at:
##		https://mit-license.org/
##	SPDX-License-Identifier: MIT


## Global settings
declare doLongTest=0 ; [[ "${CICDTEST_DO_LONGTEST}" == "1" ]] && doLongTest=1


##•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
## For testing n8_mod_* modules

if [[ ! -v exe1 ]]; then
	## Setting for this script.
	## Paths will be evaluated relative to this script's folder.
	declare exe1="../bin/template.bash"
fi
if [[ ! -v THIS_FILEPATH ]]; then
	## Required by n8mod_core_v1
	declare -gr  THIS_FILEPATH="$(realpath -e "${0}")"
	declare -gr  THIS_FILENAME="$(basename "${THIS_FILEPATH}")"
	declare -gr  THIS_DIRPATH="$(dirname "${THIS_FILEPATH}")"
	declare -gri DO_CHAIN_SUDO=1  ## Only used by fChainToFunction(), which you don't have to use even if this is 1.
	## Populated by n8mod_core_v1
	declare -g   SERIAL_DATETIME
	declare -g   RELAUNCH_SENTINELVAL
fi
if [[ ! -v THIS_VERSION ]]; then
	## Required by n8mod_user_v1
	declare -gi doQuietly=0
	declare -gi doPromptToContinue=1
	declare -gr THIS_VERSION="1.0.0-beta1"
	declare -gr THIS_BUILD="1n0pagv"
	declare -gr THIS_COPYRIGHT_YEARS="2011-2026"
	declare -gr THIS_AUTHOR="Jim Collier"
	declare -gr LICENSE_SPDX="MIT"
fi

fShowAbout_Local(){ :; }   ## Required by n8mod_interact_v1
fShowSyntax_Local(){ :; }  ## Required by n8mod_interact_v1


##•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
## Logged testing, no interactivity.
## Runs second in invocations at the bottom of this script, unless fMain_Test_Interactive()
##   is commented out.
fMain_Test(){
	fEcho_Clean

	## Environment overrides
	local LANG="C.UTF-8"  ## Splitting won't work correctly without this

	## Variables
	local inputVal=""  expectVal=""  gotVal=""  tmpVal=""
	local -i loopCount=0

	##•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
	fUnitTest_PrintSectionHeader  "n8mod_core_v1"
	##•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
	fRunTest_ExecCmd_v1  'error'  'fIsFunction NOTAFUNC'
	fGetOgUserName inputVal ; fRunTest_Compare_v1  '=='  "${inputVal}"  "${USER}"
	fGetOgUserHome inputVal ; fRunTest_Compare_v1  '=='  "${inputVal}"  "${HOME}"



#	fUnitTest_PrintSectionHeader  "n8mod_number_v1"
#	fRunTest  '=='  "${expectVal}"  "fIsBool  ${inputVal}  128v1compat"
return 0


	fEcho; fEcho ">>> TESTSECTION: "; fEcho

	fRunTest  'error'  "${expectVal}"  "'${exe1}'  '${inputVal}'  bogusBaseName" #......: This one should fail
	fRunTest  '=='  "${expectVal}"  "'${exe1}'  ${inputVal}  128v1compat"
	fRunTest  '=='  "${expectVal}"  "'${exe1}'  ${inputVal}  128jc1"

	expectVal="FrĜЋŝĴR2§⁑⍤🝅⌲μr1ϟỹẼ⌲M§ỹλ🜥ψ🝅ᛘêᚼ75ĜᛝmÑ🜥Ĝλŝ▵ϠĜRλΞãᛎ8hÊᛯĝĵΩJĜ▿ĤxŴĵ£Cᛏẅ8ÂψvÉÉδPĝŷ"
	fRunTest  '!='  "${expectVal}"  "'${exe1}'  ${inputVal}  128jc1"

	fRunTest  'error'  "[anything or nothing]"  "'${exe1}'  --ibase 26  'ABCXYZ'  10"

	fRunChained_TestLast  '=='  "${expectVal}"  "'${exe1}'  --ibase 10  ${inputVal}  base16 ; '${exe1}'  --ibase 16  %CMD1_OUTPUT%  base10"

:;}


##•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
## Interactive testing, no logging.
## Runs first in invocations at the bottom of this script, unless commented out.
fMain_Test_Interactive(){

	## Once everything passes, return 0 so we can get straight to automated tests.
	return 0

	fEcho_Clean

	## Environment overrides
	local -r LANG="C.UTF-8"  ## Splitting won't work correctly without this

	## Variables
	local -i retVal=0

	####
	#### Test error setting combos enabled one at a time, on various types of errors; then comment them all out once it all passes.

	fError_DefineTrap_Fatal  ; fError_DefineBehavior_Return
#	fError_DefineTrap_Fatal  ; fError_DefineBehavior_Exit    ## Won't exit on case of 'return 0'.
#	fError_DefineTrap_Ignore ; fError_DefineBehavior_Return  ## Will ignore errors, but not explicit `exit`.
#	fError_DefineTrap_Ignore ; fError_DefineBehavior_Exit    ## fError_DefineBehavior_Exit() is overridden, if also ignoring errors, so it should behave no differently than above.
	## Test these error triggers one at a time, then comment out once all pass.
#	fEcho_Clean "Hit CTRL+C to test user break ..."; fEcho_IsInRawInlineMode_Set 1; _global_ExitLoopNow=0; for i in {1..10}; do sleep 1; ((_global_ExitLoopNow)) && break; echo -n "${i} "; done;:; _global_ExitLoopNow=0
#	rsync /DOESNT_EXIST/bogus
#	rsync /DOESNT_EXIST/bogus 2>/dev/null #.................................: Should not show any extra lines at all, swallow rsync error, but still show error handler text.
#	rsync /DOESNT_EXIST/bogus 2>/dev/null || true #.........................: Should look like nothing happened, even with `fError_DefineTrap_Fatal`.
#	echo "Hello Kitty, how are you?" | sed --bogus-flag 's/ Kitty,//'             | head -n 1
#	echo "Hello Kitty, how are you?" | sed --bogus-flag 's/ Kitty,//' 2>/dev/null | head -n 1
#	echo "Hello Kitty, how are you?" | sed --bogus-flag 's/ Kitty,//' 2>/dev/null | head -n 1 || true
	fThrowError "This is a test fThrowError message."
#	fThrowError "This is a test fThrowError message." 2>/dev/null
#	return 0
#	return 1
#	return $ERRNUM_MSG_ALREADY_SHOWN #...: Ditto `exit $ERRNUM_MSG_ALREADY_SHOWN` note below.
#	exit #............................: Can't ignore a explicit exit.
#	exit 1
#	exit $ERRNUM_MSG_ALREADY_SHOWN #.....: Should not show an error message. This is what a custom error message should exit with. [And what fThrowError() uses.]
#	exit 200

	####
	#### Will it even load at all

	fEcho_Clean
	fEcho_Clean "Exe source ...: ${exe1}"
	fEcho_Clean "Version ......: $("${exe1}" --version)"
	fEcho_Clean_Force
	sleep 1

	## Test template.bash fMain user prompt
	fEcho_Clean "Executing '${exe1}'"
	fEcho_Clean "  with no args, to test template's fShowVersion(), fShowCopyright(), fShowAbout(), fShowSyntax(), fMain(), and fCleanup();"
	fEcho_Clean "  and interactive prompt to continue."
	fEcho_Clean
	fEcho_Clean ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
	set +e ; "${exe1}"; retVal=$? ; : ; set -e
	fEcho_Clean "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
	fEcho_Clean
	fEcho_Clean "Script return value: ${retVal} (user chose to $( if ((retVal==0)); then echo "continue"; else echo "abort"; fi ))."
	fEcho_Clean
	fEcho_Clean "Continuing with tests ..."

	## Test n8mod_interact_v1 functions
	fEcho_Clean "Going to test n8mod_interact_v1.fPressAnyKeyToContinue() ...."
	fEcho_Clean
	fEcho_Clean ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
	fPressAnyKeyToContinue
	fEcho_Clean "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
	fEcho_Clean

}


##•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
## Generic boilerplate in every script

fLoadModule_v1(){
	## Purpose: Loads a module by name.
	## E.g.: fLoadModule_v1  'n8mod_core_v1'
	local -r arg_ModuleName="${1:-}"  # ; shift || :  ## Module name
	local resolvedPath
	fResolvePath_v1  resolvedPath  "${arg_ModuleName}"
	# shellcheck source=/dev/null
	[[ -f "${resolvedPath}" ]] && source "${resolvedPath}"
		## Note that since we're source'ing inside a function, and regular 'declare' in global
		## scope within those modules, will actually be local scope to this function. The fix
		## is to just idiomatically always declare global variables/constants with `-g`.
:;}

fResolvePath_v1(){
	## Purpose: Resolves an argument to a canonical full path, while being careful to not be too broad as to resolve to something else with the same name.
	## Searches common 'include|lib'-like sub-paths, then if arg is a single filename, the system $PATH.
	## Subshells and external tools are OK in this very early function that preceeds any modules being loaded.
	## Validate nameref args
	[[ -v 1 ]] || { echo -e "\nError in $(basename "${BASH_SOURCE[0]}")·${FUNCNAME[0]}(): Calling function must pass a nameref to receive this function's output, as arg1.\n"                           ; return ${ERRNUM_MSG_ALREADY_SHOWN}; }
	## Gather args
	local -n ref_Return_ResolvedPath_t4rej=$1  ; shift || :  ## Parent variable to store fully resolved path in.
	local -r nameOrPath="${1:-}"               ; shift || :  ## File or folder path (relative or absolute). If an executable file, can be just a name to search in $PATH, to fully resolve.
	local -i mustExist=${1:-1}                 ; shift || :  ## 1 [default]: path must exist or error occurs. 0: Just rationalize paths, doesn't have to exist.
	## Validate
	[[ "${nameOrPath}" ]] || { echo -e "\nError in $(basename "${BASH_SOURCE[0]}")·${FUNCNAME[0]}(): Path or executable name not specified.\n" ; return ${ERRNUM_MSG_ALREADY_SHOWN}; }
	## Init
	ref_Return_ResolvedPath_t4rej=""
	## Obvious test, as-is
	[[ -e "${nameOrPath}" ]] && { ref_Return_ResolvedPath_t4rej="$(realpath -e "${nameOrPath}")"; return 0; }
	## Test file with common sub-paths
	local -r mePath_t4rej="$(dirname "${BASH_SOURCE[0]}")"  ## Pathspec to this script.
	local -a tryRelSubs=('/'  '/lib/'  '/include/'  '/includes/') ; local -a tryRelPaths=()  ## Common generic library subdirs.
	for nextSub in "${tryRelSubs[@]}"; do tryRelPaths+=("${BASH_SOURCE[0]}.d${nextSub}${nameOrPath}") ; done  ## "[this script's full pathspec].d/[each common subdir]/[argument]".
	for nextSub in "${tryRelSubs[@]}"; do tryRelPaths+=("${mePath_t4rej}${nextSub}${nameOrPath}")     ; done  ## "[this script's folder]/[each common subdir]/[argument]".
	for nextPath in "${tryRelPaths[@]}"; do [[ -e "${nextPath}" ]] && { ref_Return_ResolvedPath_t4rej="$(realpath -e "${nextPath}")"; return 0; }; done  ## Return realpath if found in the first match.
	local testPath=""
	## Try 'which', if arg is a single file.
	if [[ "${nameOrPath}" != */* ]]; then
		testPath="$(which "${nameOrPath}" 2>/dev/null || true)"
		[[ -n "${testPath}" ]] && { ref_Return_ResolvedPath_t4rej="$(realpath -e "${testPath}")"; return 0; }  ## Return 'which'
	fi
	## Haven't matched yet: revert to original argument
	testPath="${nameOrPath}"
	if ((mustExist)); then
		testPath="$(realpath -e "${testPath}" 2>/dev/null || true)"
		[[ -n "${testPath}" && -e "${testPath}" ]] || { echo -e "\nError in $(basename "${BASH_SOURCE[0]}")·${FUNCNAME[0]}(): Could not resolve path '${nameOrPath}' [£ǝŔs].\n"; return ${ERRNUM_MSG_ALREADY_SHOWN}; }
	else
		testPath="$(realpath -m "${testPath}" 2>/dev/null || true)"
		[[ -n "${testPath}" ]] || { echo -e "\nError in $(basename "${BASH_SOURCE[0]}")·${FUNCNAME[0]}(): Could not resolve even optionally nonexistent path '${nameOrPath}' [£ǝŔs].\n"; return ${ERRNUM_MSG_ALREADY_SHOWN}; }
	fi
	## Success
	ref_Return_ResolvedPath_t4rej="${testPath}"
}


#••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
# Script entry point

## Bash environment settings
 set -u  #..................: Require variable declaration. Stronger than mere linting.
 set -e  #..................: Exit on errors.
 set -E  #..................: Propagate ERR trap settings into functions, command substitutions, and subshells.
 set   -o pipefail  #.......: Make sure all stages of piped commands also fail the same.
 shopt -s inherit_errexit  #: Propagate 'set -e' ........ into functions, command substitutions, and subshells. Will fail on Bash <4.4.
 shopt -s dotglob  #........: Include usually-hidden 'dotfiles' in '*' glob operations - usually desired.
 shopt -s globstar  #.......: ** matches more stuff including recursion.

## Check if sourced
declare -i isSourced_t5ja1=0; [[ "${BASH_SOURCE[0]}" == "${0}" ]] || isSourced_t5ja1=1
#((isSourced_t5ja1)) || { echo -e "\nError in $(basename "${BASH_SOURCE[0]}"): This script is meant to be 'sourced' from within another script.\n"; exit ${ERRNUM_MSG_ALREADY_SHOWN}; }
{ ((isSourced_t5ja1)) && [[ "${1:-}" != '--unit-test' ]]; }  &&  { echo -e "\nError in $(basename "${BASH_SOURCE[0]}"): This script is not meant to be 'sourced' from within another script, unless for unit-testing.\n"; exit ${ERRNUM_MSG_ALREADY_SHOWN}; }

## Make sure definitions for paths relative to this script work,
##   by making sure we're evaluating from it.
cd "${THIS_DIRPATH}"

## Source the generic script 'utility/n8test'.
declare n8test_resolved="utility/include/n8lib_test"
fResolvePath_v1  n8test_resolved  "${n8test_resolved}" ; readonly n8test_resolved
[[ -n "${n8test_resolved}" ]] && source "${n8test_resolved}"

## Load required core module
## Load before `exe1`, because the flags will prevent them from being reloaded, and we want our dev versions loaded.
[[ -v N8MOD_CORE_V1_IS_LOADED ]] || fLoadModule_v1  '../bin/include/n8mod_core_v1'

## Optional modules as needed
	[[ -v N8MOD_CORE_V1_IS_LOADED       ]] || fLoadModule_v1  '../bin/include/n8mod_core_v1'
	[[ -v N8MOD_INTERACT_V1_IS_LOADED   ]] || fLoadModule_v1  '../bin/include/n8mod_interact_v1'
	[[ -v N8MOD_STRING_V1_IS_LOADED     ]] || fLoadModule_v1  '../bin/include/n8mod_string_v1'
	[[ -v N8MOD_NUMBER_V1_IS_LOADED     ]] || fLoadModule_v1  '../bin/include/n8mod_number_v1'
	[[ -v N8MOD_FILESYS_V1_IS_LOADED    ]] || fLoadModule_v1  '../bin/include/n8mod_filesys_v1'
	[[ -v N8MOD_PROCESS_V1_IS_LOADED    ]] || fLoadModule_v1  '../bin/include/n8mod_process_v1'
	[[ -v N8MOD_LOGGING_V1_IS_LOADED    ]] || fLoadModule_v1  '../bin/include/n8mod_logging_v1'
	[[ -v N8MOD_UNITTEST_V1_IS_LOADED   ]] || fLoadModule_v1  '../bin/include/n8mod_unittest_v1'
#	[[ -v N8MOD_ARRAY_V1_IS_LOADED      ]] || fLoadModule_v1  '../bin/include/n8mod_array_v1'
#	[[ -v N8MOD_OOP_V1_IS_LOADED        ]] || fLoadModule_v1  '../bin/include/n8mod_oop_v1'
#	[[ -v N8MOD_ZFS_V1_IS_LOADED        ]] || fLoadModule_v1  '../bin/include/n8mod_zfs_v1'
#	[[ -v N8MOD_BTRFS_V1_IS_LOADED      ]] || fLoadModule_v1  '../bin/include/n8mod_btrfs_v1'
#	[[ -v N8MOD_SQL_V1_IS_LOADED        ]] || fLoadModule_v1  '../bin/include/n8mod_sql_v1'
#	[[ -v N8MOD_SQLITE3_V1_IS_LOADED    ]] || fLoadModule_v1  '../bin/include/n8mod_sqlite3_v1'
#	[[ -v N8MOD_POSTGRESQL_V1_IS_LOADED ]] || fLoadModule_v1  '../bin/include/n8mod_postgresql_v1'

## Source the generic template.
## Do this AFTER sourcing modules, because we want to source the modules being developed,
##   not the stable ones in $PATH.
fResolvePath_v1  exe1  "${exe1}" ; readonly exe1
[[ -n "${exe1}" ]] && source "${exe1}" --unit-test

##•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
## This is always triggered once by n8mod_core_v1 code, on final script exit,
##   whether due to normal script completion, or early exit due to error.
## Only put critical cleanup here, and/or final stdout message independent of
##   reason for exit.
## Define after loading $exe1, so that this definition wins.
fCleanup(){
	notify-send "Title" "$(basename "${BASH_SOURCE[0]}").${FUNCNAME[0]}(): Ran."  ##DEBUG
	if ((! doQuietly)); then :
		fEcho_Clean
	fi
}

## Initialize logging (fPipe_LogAndShowPartialOutput_InitLogfile() is defined in 'n8test')
declare logFile="${THIS_FILEPATH%.*}.log"
fResolvePath_v1  logFile    "${logFile}"  0
fPipe_LogAndShowPartialOutput_InitLogfile "${logFile}"

## Run interactive tests.
## Ran several times 20260521, commenting out for automation.
fMain_Test_Interactive

## Kick off logged testing (this will cause fMain_Test() to run).
fEntryPoint | fPipe_LogAndShowPartialOutput
fEcho_ResetBlankCounter  ## Pipe bypasses fEcho tracking; reset to neutral state



#••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
##	Script history:
##		- 20260518 JC: Copied from convert-base-v1b and updated for this project.
##		- 20260519-20 JC:
##			- Updated for updated n8lib_test.
##			- Changed license from GPL2 to MIT.
