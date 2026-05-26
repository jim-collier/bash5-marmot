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


## Setting for this script.
## Paths will be evaluated relative to this script's folder.
declare doLongTest=0 ; [[ "${CICDTEST_DO_LONGTEST}" == "1" ]] && doLongTest=1
[[ -v exe1 ]] || declare exe1="../bin/0_x9bash5-template.bash"

## Required by n8mod_core_v1
if [[ ! -v THIS_FILEPATH ]]; then
	declare -gr  THIS_FILEPATH="$(realpath -e "${0}")"
	declare -gr  THIS_FILENAME="$(basename "${THIS_FILEPATH}")"
	declare -gr  THIS_DIRPATH="$(dirname "${THIS_FILEPATH}")"
	declare -gri DO_CHAIN_SUDO=1  ## Only used by fChainToFunction(), which you don't have to use even if this is 1.
fi

## Also populated by n8mod_core_v1
[[ -v ERRNUM_MSG_ALREADY_SHOWN     ]] || declare -gri ERRNUM_MSG_ALREADY_SHOWN=3

## Required by n8mod_user_v1
if [[ ! -v THIS_VERSION ]]; then
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
	local -r LANG="C.UTF-8"  ## Splitting won't work correctly without this

	## Constants
	local -r BREAKABLE_LOOP_SLEEP=0.001

	## Variables
	local    inputStr=""  outputStr=""  expectStr=""  bigStr=""
	local -i outputInt=0  expectInt=0  loopCount=0

	##•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
	fUnitTest_PrintSectionHeader  "n8mod_core_v1.fIsFunction()"
	##•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
	fRunTest_ExecCmd_v1  'error'    'fIsFunction  NOTAFUNC'
	fRunTest_ExecCmd_v1  'noerror'  'fIsFunction  fMain_Test'

	##•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
	fUnitTest_PrintSectionHeader  "n8mod_core_v1.fGetOgUserName()"
	##•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
	fGetOgUserName outputStr ; fRunTest_Compare_v1  '=='  "${outputStr}"  "${USER}"

	##•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
	fUnitTest_PrintSectionHeader  "n8mod_core_v1.fGetOgUserHome()"
	##•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
	fGetOgUserHome outputStr ; fRunTest_Compare_v1  '=='  "${outputStr}"  "${HOME}"

	##•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
	fUnitTest_PrintSectionHeader  "n8mod_number_v1.fIsBool()"
	##•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
	fRunTest_ExecCmd_v1  'error'    'fIsBool  0.32'
	fRunTest_ExecCmd_v1  'error'    'fIsBool  xyz'
	fRunTest_ExecCmd_v1  'noerror'  'fIsBool  0'
	fRunTest_ExecCmd_v1  'noerror'  'fIsBool  1'
	fRunTest_ExecCmd_v1  'noerror'  'fIsBool  100'
	fRunTest_ExecCmd_v1  'noerror'  'fIsBool  f'
	fRunTest_ExecCmd_v1  'noerror'  'fIsBool  false'
	fRunTest_ExecCmd_v1  'noerror'  'fIsBool  no'
	fRunTest_ExecCmd_v1  'noerror'  'fIsBool  true'
	fRunTest_ExecCmd_v1  'noerror'  'fIsBool  y'

	##•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
	fUnitTest_PrintSectionHeader  "n8mod_number_v1.fIsBoolTrue()"
	##•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
	fRunTest_ExecCmd_v1  'error'    'fIsBoolTrue  '
	fRunTest_ExecCmd_v1  'error'    'fIsBoolTrue  0'
	fRunTest_ExecCmd_v1  'error'    'fIsBoolTrue  BOGUSVAL'
	fRunTest_ExecCmd_v1  'error'    'fIsBoolTrue  F'
	fRunTest_ExecCmd_v1  'error'    'fIsBoolTrue  no'
	fRunTest_ExecCmd_v1  'noerror'  'fIsBoolTrue  1'
	fRunTest_ExecCmd_v1  'noerror'  'fIsBoolTrue  50'
	fRunTest_ExecCmd_v1  'noerror'  'fIsBoolTrue  T'
	fRunTest_ExecCmd_v1  'noerror'  'fIsBoolTrue  true'
	fRunTest_ExecCmd_v1  'noerror'  'fIsBoolTrue  y'
	fRunTest_ExecCmd_v1  'noerror'  'fIsBoolTrue  Y'
	fRunTest_ExecCmd_v1  'noerror'  'fIsBoolTrue  yes'

	##•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
	fUnitTest_PrintSectionHeader  "n8mod_number_v1.fGetRandomInt()"
	##•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
	fRunTest_ExecCmd_v1  'noerror'  'fGetRandomInt  outputInt   100         10'
	fRunTest_ExecCmd_v1  'noerror'  'fGetRandomInt  outputInt  -100        100'
	fRunTest_ExecCmd_v1  'noerror'  'fGetRandomInt  outputInt   1      1000000'
	fRunTest_ExecCmd_v1  'noerror'  'fGetRandomInt  outputInt  -1   1000000000'
	fRunTest_ExecCmd_v1  'error'    'fGetRandomInt  outputInt   1  10000000000'  ## Range is too large.
	fEcho_Clean "Fuzz-testing 'fGetRandomInt  outputInt  0  0'"
		fEcho_IsInRawInlineMode_Set 1 ; _global_ExitLoopNow=0
		for i in {1..10}; do
			((_global_ExitLoopNow)) && break ; sleep 0.0001 ; fGetRandomInt  outputInt  0  0 ; echo -n "${outputInt}, "
		done;:; fEcho_Clean_Force
	fEcho_Clean "Fuzz-testing 'fGetRandomInt  outputInt  0  1'"
		fEcho_IsInRawInlineMode_Set 1 ; _global_ExitLoopNow=0
		for i in {1..10}; do
			((_global_ExitLoopNow)) && break ; sleep ${BREAKABLE_LOOP_SLEEP} ; fGetRandomInt  outputInt  0  1 ; echo -n "${outputInt}, "
		done;:; fEcho_Clean_Force
	fEcho_Clean "Fuzz-testing 'fGetRandomInt  outputInt  10  0'"
		fEcho_IsInRawInlineMode_Set 1 ; _global_ExitLoopNow=0
		for i in {1..100}; do
			((_global_ExitLoopNow)) && break ; sleep ${BREAKABLE_LOOP_SLEEP} ; fGetRandomInt  outputInt  10  0 ; echo -n "${outputInt}, "
		done;:; fEcho_Clean_Force
	fEcho_Clean "Fuzz-testing 'fGetRandomInt  outputInt  -100  100'"
		fEcho_IsInRawInlineMode_Set 1 ; _global_ExitLoopNow=0
		for i in {1..100}; do
			((_global_ExitLoopNow)) && break ; sleep ${BREAKABLE_LOOP_SLEEP} ; fGetRandomInt  outputInt  -100  100 ; echo -n "${outputInt}, "
		done;:; fEcho_Clean_Force
	fEcho_Clean "Fuzz-testing 'fGetRandomInt  outputInt  0  1000000'"
		fEcho_IsInRawInlineMode_Set 1 ; _global_ExitLoopNow=0
		for i in {1..100}; do
			((_global_ExitLoopNow)) && break ; sleep ${BREAKABLE_LOOP_SLEEP} ; fGetRandomInt  outputInt  0  1000000 ; echo -n "${outputInt}, "
		done;:; fEcho_Clean_Force


	##•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
	fUnitTest_PrintSectionHeader  "n8mod_string_v1.fBgrep()"
	##•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
	inputStr='foobar'     ;  fBgrep  outputStr  --   'foo'                     inputStr;  fRunTest_Compare_v1  '=='  "${outputStr}"  'foobar'  ## No flags
	inputStr='foobar'     ;  fBgrep  outputStr  ''   'foo'                     inputStr;  fRunTest_Compare_v1  '=='  "${outputStr}"  'foobar'  ## No flags
	inputStr='FooBar'     ;  fBgrep  outputStr  -i   'foo'                     inputStr;  fRunTest_Compare_v1  '=='  "${outputStr}"  'FooBar'
	inputStr='Fo0123Ba'   ;  fBgrep  outputStr  -o   '[0-9]+'                  inputStr;  fRunTest_Compare_v1  '=='  "${outputStr}"  '0123'
	inputStr='1230'       ;  fBgrep  outputStr  -o   "${FBGREP_REGEX_NUMBER}"  inputStr;  fRunTest_Compare_v1  '=='  "${outputStr}"  '1230'
	inputStr='-1230'      ;  fBgrep  outputStr  -o   "${FBGREP_REGEX_NUMBER}"  inputStr;  fRunTest_Compare_v1  '=='  "${outputStr}"  '-1230'
	inputStr='-1230.7890' ;  fBgrep  outputStr  -o   "${FBGREP_REGEX_NUMBER}"  inputStr;  fRunTest_Compare_v1  '=='  "${outputStr}"  '-1230.7890'
	inputStr='foobar'     ;  fRunTest_ExecCmd_v1  'error'    "fBgrep             -i  'foo'  inputStr"  ## Missing output nameref.
	inputStr='foobar'     ;  fRunTest_ExecCmd_v1  'error'    "fBgrep  outputStr  -i  'foo'          "  ## Missing input nameref.
	inputStr='foobar'     ;  fRunTest_ExecCmd_v1  'error'    "fBgrep  NOTVALID   -i  'foo'  inputStr"  ## Bogus output nameref.

	##•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
	fUnitTest_PrintSectionHeader  "n8mod_string_v1.fBgrepQ()"
	##•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
	inputStr='foobar'     ;  fRunTest_ExecCmd_v1  'noerror'    "fBgrepQ -i  'Foo'  inputStr"
	inputStr='foobar'     ;  fRunTest_ExecCmd_v1  'noerror'    "fBgrepQ -o  'foo'  inputStr"
	inputStr='foobar'     ;  fRunTest_ExecCmd_v1  'error'      "fBgrepQ -v  'foo'  inputStr"  ## NOT match
	inputStr='foobar'     ;  fRunTest_ExecCmd_v1  'error'      "fBgrepQ --  'Foo'  inputStr"  ## No regex match
	inputStr='foobar'     ;  fRunTest_ExecCmd_v1  'error'      "fBgrepQ --  'Foo'  "          ## Missing input nameref
	inputStr=''           ;  fRunTest_ExecCmd_v1  'error'      "fBgrepQ --  'foo'  inputStr"  ## Empty input
	inputStr='foobar'     ;  fRunTest_ExecCmd_v1  'noerror'    "fBgrepQ --  ''     inputStr"  ## Empty regex (OK)
	inputStr='foobar'     ;  fRunTest_ExecCmd_v1  'error'      "fBgrepQ -v  ''     inputStr"  ## Empty regex and -v (not OK)
	inputStr='foobar'     ;  fRunTest_ExecCmd_v1  'noerror'    "fBgrepQ -o  ''     inputStr"  ## Empty regex and -o (OK)

	##•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
	fUnitTest_PrintSectionHeader  "n8mod_string_v1.fGetStrMatchPos()"
	##•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
	bigStr="Now is the time for all good sentient life to come to the aid of their solar system, is it not."
	fGetStrMatchPos  outputInt  bigStr  'is'     ; fRunTest_Compare_v1  '=='     "${outputInt}"  5
	fGetStrMatchPos  outputInt  bigStr  'woohoo' ; fRunTest_Compare_v1  '=='     "${outputInt}"  0
	fGetStrMatchPos  outputInt  bigStr  ''       ; fRunTest_Compare_v1  '=='     "${outputInt}"  0
	fRunTest_ExecCmd_v1  'error'  "fGetStrMatchPos             bigStr  'woohoo'"  ## Missing output nameref.
	fRunTest_ExecCmd_v1  'error'  "fGetStrMatchPos  outputInt          'woohoo'"  ## Missing input nameref.
	bigStr=""
	fGetStrMatchPos  outputInt  bigStr  'woohoo' ; fRunTest_Compare_v1  '=='     "${outputInt}"  0
	fGetStrMatchPos  outputInt  bigStr  ''       ; fRunTest_Compare_v1  '=='     "${outputInt}"  0

	##•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
	fUnitTest_PrintSectionHeader  "n8mod_string_v1.fBhead()"
	##•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
	bigStr="Now is the\ntime for all good\nsentient life\nto come to the aid\nof their solar\nsystem, is it not."
	fBhead  outputStr  -n 1 bigStr ; fRunTest_Compare_v1  '=='  "${outputStr}"  'Now is the'$'\n'
	fBhead  outputStr  -n 3 bigStr ; fRunTest_Compare_v1  '=='  "${outputStr}"  'Now is the'$'\ntime for all good'$'\nsentient life'$'\n'
	bigStr="$(echo -e "${bigStr}")"
	fBhead  outputStr  -n 3 bigStr ; fRunTest_Compare_v1  '=='  "${outputStr}"  'Now is the'$'\ntime for all good'$'\nsentient life'$'\n'

:;}


##•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
## Interactive testing, no logging.
## Runs first in invocations at the bottom of this script, unless commented out.
fMain_Test_Interactive(){

	## Once everything passes, return 0 so we can get straight to automated tests.
	#return 0

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
#	fEcho_Clean "Hit CTRL+C to test user break ..."; fEcho_IsInRawInlineMode_Set 1 ; _global_ExitLoopNow=0; for i in {1..10}; do sleep 1; ((_global_ExitLoopNow)) && break; echo -n "${i} "; done;:; _global_ExitLoopNow=0
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

declare __fResolvePath_v1_PreviousDir=""
fResolvePath_v1(){
	## Purpose: Resolves an argument to a canonical full path, while being careful to not be too broad as to resolve to something else with the same name.
	## Searches common 'include|lib'-like sub-paths; then if arg is a single filename, seraches the system $PATH.
	## Subshells and external tools are OK in this very early function that preceeds any modules being loaded.
	## Validate nameref args (with no modules loaded yet to help)
	nref="${1:-}"; { [[ -n "${nref}" ]] && [[ ${nref} =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] && declare -p "${nref}" &>/dev/null; }  || { echo -e "\nError in $(basename "${BASH_SOURCE[0]}")·${FUNCNAME[0]}(): Invalid nameref argument '${nref}'. Are one or more arguments missing?.\n" ; return ${ERRNUM_MSG_ALREADY_SHOWN}; }
	## Gather args
	local -n ref_Return_ResolvedPath_t4rej=$1  ; shift || :  ## Parent variable to store fully resolved path in.
	local -r nameOrPath="${1:-}"               ; shift || :  ## File or folder path (relative or absolute). If an executable file, can be just a name to search in $PATH, to fully resolve.
	local -i mustExist=${1:-1}                 ; shift || :  ## 1 [default]: path must exist or error occurs. 0: Just rationalize paths, doesn't have to exist.
	## Validate
	[[ "${nameOrPath}" ]] || { echo -e "\nError in $(basename "${BASH_SOURCE[0]}")·${FUNCNAME[0]}(): Path or executable name not specified.\n" ; return ${ERRNUM_MSG_ALREADY_SHOWN}; }
	## Init
	ref_Return_ResolvedPath_t4rej=""
	## Variables
	local testPath=""
	## Obvious test, as-is
	if [[ -e "${nameOrPath}" ]]; then
		testPath="$(realpath -e "${nameOrPath}" 2>/dev/null || true)"
		[[ -e "${testPath}" ]] && { __fResolvePath_v1_PreviousDir="$(dirname "${testPath}")"; ref_Return_ResolvedPath_t4rej="${testPath}"; return 0; }
	fi
	## Constants
	local -r meMePath_t4rej="$(realpath -e "${BASH_SOURCE[0]}")"  ## Pathspec to this script.
	local -r meMeName_t4rej="$(basename "${meMePath_t4rej}")"
	local    meMeName_Simple_t4rej="${meMeName_t4rej//'0_'/''}"; meMeName_Simple_t4rej="${meMeName_Simple_t4rej//'.bash'/''}"; readonly meMeName_Simple_t4rej
	local -r meDirPath_t4rej="$(dirname "${meMePath_t4rej}")"  ## Path to script container dir.
	## Common path primitives (listed in order of likelihood and/or desired first-match if in multiple places).
	local -a tryBaseDirs=("${meDirPath_t4rej}/"  "${meMePath_t4rej}.d/"  "${meDirPath_t4rej}/${meMeName_Simple_t4rej}/"  "${meDirPath_t4rej}/${meMeName_Simple_t4rej}.d/"  "${HOME}/synced/0-0/common/exec/util/linux/bash/"  '/opt/'  '/usr/local/'  '/usr/local/'  "${HOME}/opt/"  "${HOME}/.local/"  "${HOME}/.local/")
	local -a tryRelSubs1=('include/'  'lib/'  'mod/'  'bin/'  'bin/lib/'  'bin/include/'  'inc/'  'includes/'  'module/'  'modules/'  '')  ## Common generic library subdirs (NOT relative to root), in order of likelihood.
	local -a tryRelSubs2=(''  'n8/'  'x9/'  "${meMeName_t4rej}/"  "${meMeName_Simple_t4rej}/")
	local -a tryPaths=()
	## Build common paths to check from primitives (starting with the last path for previous match)
	[[ -n "${__fResolvePath_v1_PreviousDir}" ]] && tryPaths+=("${__fResolvePath_v1_PreviousDir}/${nameOrPath}")  ## Add previous found dir to the top of the list
	for tryBaseDir in "${tryBaseDirs[@]}"; do
		for tryRelSub1 in "${tryRelSubs1[@]}"; do
			for tryRelSub2 in "${tryRelSubs2[@]}"; do
				testPath="${tryBaseDir}${tryRelSub1}${tryRelSub2}${nameOrPath}"; testPath="${testPath%%/}"; testPath="${testPath//'//'/'/'}"; tryPaths+=("${testPath}")
			done
		done
	done
	## Return first match.
	#{ for nextPath in "${tryPaths[@]}"; do echo "${nextPath}"; done; } | less  ## DEBUG
	for nextPath in "${tryPaths[@]}"; do [[ -e "${nextPath}" ]] && { __fResolvePath_v1_PreviousDir="$(dirname "${nextPath}")"; ref_Return_ResolvedPath_t4rej="${nextPath}"; return 0; }; done
	## No match; try 'which', if arg is a single file.
	if [[ "${nameOrPath}" != */* ]]; then
		testPath="$(which "${nameOrPath}" 2>/dev/null || true)"
		[[ -n "${testPath}" ]] && { testPath="$(realpath -e "${testPath}")"; __fResolvePath_v1_PreviousDir="$(dirname "${testPath}")"; ref_Return_ResolvedPath_t4rej="${testPath}"; return 0; }  ## Return 'which'
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
	## If haven't returned with success or error by now, then we return what we have, which is either a real match, or valid hypothetical.
	__fResolvePath_v1_PreviousDir="$(dirname "${testPath}")"; ref_Return_ResolvedPath_t4rej="${testPath}"
}


#••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
# Script entry point

## Bash environment settings.
## This should in theory be the only place these are set.
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

## Source our own copy of the generic script 'n8lib_test'.
declare n8test_resolved="utility/include/n8lib_test"
fResolvePath_v1  n8test_resolved  "${n8test_resolved}" ; readonly n8test_resolved
[[ -n "${n8test_resolved}" ]] && source "${n8test_resolved}"

## Load required core module
## Load before `exe1`, because the flags will prevent them from being reloaded, and we want our dev versions loaded.
[[ -v N8MOD_ISLOADED_CORE_V1 ]] || fLoadModule_v1  '../bin/include/n8mod_core_v1'

## Optional modules as needed
	[[ -v N8MOD_ISLOADED_CORE_V1       ]] || fLoadModule_v1  '../bin/include/n8mod_core_v1'
	[[ -v N8MOD_ISLOADED_INTERACT_V1   ]] || fLoadModule_v1  '../bin/include/n8mod_interact_v1'
	[[ -v N8MOD_ISLOADED_STRING_V1     ]] || fLoadModule_v1  '../bin/include/n8mod_string_v1'
	[[ -v N8MOD_ISLOADED_NUMBER_V1     ]] || fLoadModule_v1  '../bin/include/n8mod_number_v1'
	[[ -v N8MOD_ISLOADED_FILESYS_V1    ]] || fLoadModule_v1  '../bin/include/n8mod_filesys_v1'
	[[ -v N8MOD_ISLOADED_PROCESS_V1    ]] || fLoadModule_v1  '../bin/include/n8mod_process_v1'
	[[ -v N8MOD_ISLOADED_LOGGING_V1    ]] || fLoadModule_v1  '../bin/include/n8mod_logging_v1'
	[[ -v N8MOD_ISLOADED_UNITTEST_V1   ]] || fLoadModule_v1  '../bin/include/n8mod_unittest_v1'
#	[[ -v N8MOD_ISLOADED_ARRAY_V1      ]] || fLoadModule_v1  '../bin/include/n8mod_array_v1'
#	[[ -v N8MOD_ISLOADED_OOP_V1        ]] || fLoadModule_v1  '../bin/include/n8mod_oop_v1'
#	[[ -v N8MOD_ISLOADED_ZFS_V1        ]] || fLoadModule_v1  '../bin/include/n8mod_zfs_v1'
#	[[ -v N8MOD_ISLOADED_BTRFS_V1      ]] || fLoadModule_v1  '../bin/include/n8mod_btrfs_v1'
#	[[ -v N8MOD_ISLOADED_SQL_V1        ]] || fLoadModule_v1  '../bin/include/n8mod_sql_v1'
#	[[ -v N8MOD_ISLOADED_SQLITE3_V1    ]] || fLoadModule_v1  '../bin/include/n8mod_sqlite3_v1'
#	[[ -v N8MOD_ISLOADED_POSTGRESQL_V1 ]] || fLoadModule_v1  '../bin/include/n8mod_postgresql_v1'

## Source the generic template.
## Do this AFTER sourcing modules, because we want to source the modules being developed,
##   not the stable ones in $PATH. Normally the last-loaded wins, but in this case it
##   checks whether the namespace has already been loaded, and will only load once.
##   (Otherwise modules could be loaded numerous times, wasting time at startup.)
##   In other words, it enforces its own FIRST-loaded wins.
fResolvePath_v1  exe1  "${exe1}" ; readonly exe1
[[ -n "${exe1}" ]] && source "${exe1}" --unit-test

##•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
## This is always triggered once by n8mod_core_v1 code, on final script exit,
##   whether due to normal script completion, or early exit due to error.
## Only put critical cleanup here, and/or final stdout message independent of
##   reason for exit.
## Define after sourcing $exe1, so that this definition wins in the global
##   namespace.
fCleanup(){
	notify-send "Title" "$(basename "${BASH_SOURCE[0]}").${FUNCNAME[0]}(): Ran."  ##DEBUG
	if ((!doQuietly)); then
		((_exitCode==0)) && { fEcho; fEcho "Done."; }
		fEcho_Clean
	fi
}

## Run non-logged interactive tests.
## Ran several times 20260521, commenting out for automation.
#fMain_Test_Interactive

## Initialize logging (fPipe_LogAndShowPartialOutput_InitLogfile() is defined in 'n8test')
declare logFile="${THIS_FILEPATH%.*}.log"
fResolvePath_v1  logFile    "${logFile}"  0
fPipe_LogAndShowPartialOutput_InitLogfile "${logFile}"

## Call fMain_Test() directly, for better error messages.
fMain_Test

## Kick off logged testing (this will cause fMain_Test() to run).
#fEntryPoint | fPipe_LogAndShowPartialOutput
#fEcho_ResetBlankCounter  ## Pipe bypasses fEcho tracking; reset to neutral state



#••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
##	Script history:
##		- 20260518 JC: Copied from convert-base-v1b and updated for this project.
##		- 20260519-20 JC:
##			- Updated for updated n8lib_test.
##			- Changed license from GPL2 to MIT.
##		- 20260521-22 JC: Debugging.
