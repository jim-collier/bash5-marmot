#!/bin/env bash
#  shellcheck disable=2155  ## 'Declare and assign separately to avoid masking return values.' Cumbersome and unnecessary. For integers it's sometimes required to even come into existence for counters.
## shellcheck disable=2001  ## 'See if you can use ${variable//search/replace} instead.' Complains about good uses of sed.
## shellcheck disable=2002  ## 'Useless use of cat.'
## shellcheck disable=2016  ## 'Expressions don't expand in single quotes, use double quotes for that.' I know, and I often want an explicit '$'.
## shellcheck disable=2034  ## 'variable appears unused.' Complains about valid use of variable indirection (e.g. later use of local -n var=$1)
## shellcheck disable=2046  ## 'Quote to prevent word-splitting.' (OK for integers.)
## shellcheck disable=2086  ## 'Double quote to prevent globbing and word splitting.' (OK for integers.)
## shellcheck disable=2119  ## 'Use foo "$@" if function's $1 should mean script's $1.' Confusing and inapplicable.
## shellcheck disable=2120  ## 'Foo references arguments, but none are ever passed.' Valid function argument overloading.
## shellcheck disable=2128  ## 'Expanding an array without an index only gives the element in the index 0.' False hits on associative arrays.
## shellcheck disable=2143  ## 'Use grep -q instead of echo | grep'
## shellcheck disable=2162  ## 'read without -r will mangle backslashes.'
## shellcheck disable=2178  ## 'Variable was used as an array but is now assigned a string.' False hits on associative arrays with e.g. 'local -n assocArray=$1'.
## shellcheck disable=2181  ## 'Check exit code directly, not indirectly with $?.'
## shellcheck disable=2317  ## 'Can't reach.' (I.e. an 'exit' is used for debugging - and makes an unusable visual mess.)

##	Purpose:
##		- Installs bash5-marmot and include/n8mod_* modules from the latest dev (main branch) on GitHub.
##		- Similar to install.bash, but pulls individual files from the main branch instead of a release tarball.
##		- Warns first if any existing local files are newer.
##		- Installs system-wide, or per-user, depending of whether run as UID 0 (root or sudo) or not.
##			- System-wide location:
##				- Template: /usr/local/bin       [copy as new name for implementation, and possibly somewhere else]
##				- Modules : /usr/local/lib/n8
##			- Per-user location:
##				- Template: ~/.local/bin         [copy as new name for implementation, and possibly somewhere else]
##				- Modules : ~/.local/bin/lib/n8
##	Notes:
##		- You don't need to run this installer to use the template and modules. The modules can go in most common
##		  library/module/include folders, even if not in $PATH, including relative to the running script based on
##		  the template. E.g.:
##			- /usr/local/bin/include/
##			- /usr/local/bin/include/n8/
##			- /usr/local/lib/
##			- /usr/local/lib/n8/
##			- /usr/local/lib/[script name]/
##			- ~/.local/bin/lib/n8/
##			- [full script path].d/
##			- [script container directory]/include/
##		- Although /usr/local/lib/n8 and ~/.local/bin/lib/n8 are almost certainly not in your $PATH, modules will
##		  be found there my the module loader. (The loader also looks in many generic places like '.../include'.)
##		- To use the template, just copy it somewhere, give it a new name, uncomment the modules you'd like to load,
##		  and start using it.
##		- For security, before executing any new module code for the first time, be sure to review it and every
##		  dependent function it calls. Pay special attention to network and/or disk access especially in functions
##		  that don't seem like they would need it (which should be nonexistent), and any use of `sudo` that is
##		  not explicitly part of the function name or obvious and commented purpose (which should be nonexistent).
##	History: At bottom of script. (Maintained separately from and/or in addition to, cloud-based version control.)

##	Installer Copyright © 2026 Jim Collier (ID: 1cv◂‡Vᛦ)
##	Licensed under The MIT License (MIT). Full text at:
##		https://mit-license.org/
##	SPDX-License-Identifier: MIT

set -euo pipefail

## Repo
declare -r GITHUB_USER_AND_REPO='jim-collier/bash5-marmot'
declare -r FRIENDLY_NAME='Bash5 Modular Marmot'
declare -r GITHUB_BRANCH='main'
declare -r GITHUB_URL_DOWNLOAD_PREFIX="https://raw.githubusercontent.com/${GITHUB_USER_AND_REPO}/${GITHUB_BRANCH}/bin"
declare -r GITHUB_URL_API_TEMPLATE="https://api.github.com/repos/${GITHUB_USER_AND_REPO}/contents/bin?ref=${GITHUB_BRANCH}"
declare -r GITHUB_URL_API_MODULES="https://api.github.com/repos/${GITHUB_USER_AND_REPO}/contents/bin/include?ref=${GITHUB_BRANCH}"

## Define install locations depending on whether running as root or not
## Feel free to change.
declare TARGET_DIR_TEMPLATE=""
declare TARGET_DIR_MODULES=""
if [[ "$UID" == "0" ]]; then
	## Running as root; system-wide install
	TARGET_DIR_TEMPLATE="/usr/local/bin"
	TARGET_DIR_MODULES="/usr/local/lib/n8"
else
	## Running non-root; user-directory install
	TARGET_DIR_TEMPLATE="${HOME}/.local/bin"
	TARGET_DIR_MODULES="${HOME}/.local/bin/lib/n8"
fi
readonly  TARGET_DIR_TEMPLATE  TARGET_DIR_MODULES

## Query GitHub API for list of files to install
echo "[ Querying GitHub for file list... ]"
declare apiResponseTemplate=""
apiResponseTemplate="$(curl -fsSL "${GITHUB_URL_API_TEMPLATE}")" || { echo -e "\nERROR: Failed to query GitHub API for template.\n"; exit 1; }
declare apiResponseModules=""
apiResponseModules="$(curl -fsSL "${GITHUB_URL_API_MODULES}")" || { echo -e "\nERROR: Failed to query GitHub API for modules.\n"; exit 1; }

## Populate array of template file names (expect exactly 'bash5-marmot')
declare -a templateFiles=()
while IFS= read -r nextItem; do templateFiles+=("${nextItem}"); done < <(echo "${apiResponseTemplate}" | grep '"name"' | sed 's/.*"name": *"//;s/".*//' | grep '^bash5-marmot$')
[[ ${#templateFiles[@]} -gt 0 ]] || { echo -e "\nERROR: Template file 'bash5-marmot' not found at GitHub URL.\n"; exit 1; }
readonly templateFiles

## Populate array of module file names (n8mod_*)
declare -a moduleFiles=()
while IFS= read -r nextItem; do moduleFiles+=("${nextItem}"); done < <(echo "${apiResponseModules}" | grep '"name"' | sed 's/.*"name": *"//;s/".*//' | grep '^n8mod_')
[[ ${#moduleFiles[@]} -gt 0 ]] || { echo -e "\nERROR: No n8mod_* files found at GitHub URL.\n"; exit 1; }
readonly moduleFiles

## Warn if existing files will be overwritten
declare warnTemplate=""
declare warnModules=""
[[ -f "${TARGET_DIR_TEMPLATE}/bash5-marmot" ]]                                      &&  warnTemplate="  ** WARNING: Template file already exists and will be overwritten with latest dev version on github."
[[ -n "$(find "${TARGET_DIR_MODULES}" -maxdepth 1 -type f 2>/dev/null || true)" ]]  &&  warnModules="  ** WARNING: Existing module files will be overwritten with latest dev versions on github."

## Prompt user to continue
userInput=""
echo -e "\nGoing to install dev (main branch) of ${FRIENDLY_NAME}:\n"
echo "  - Source branch ..........: ${GITHUB_BRANCH}"
echo "  - Template install dir ...: ${TARGET_DIR_TEMPLATE}"
echo "  - Modules install dir ....: ${TARGET_DIR_MODULES}"
echo "  - Template file ..........: ${templateFiles[*]}"
echo "  - Module files ...........: ${moduleFiles[*]}"
echo "  - Current \$USER ..........: ${USER}"
[[ -z "${warnTemplate}${warnModules}" ]]  || echo
[[ -z "${warnTemplate}" ]]                || echo "${warnTemplate}"
[[ -z "${warnModules}" ]]                 || echo "${warnModules}"
echo
read -r -p "Continue? (y|n): " userInput < /dev/tty
[[ "${userInput,,}" == "y" ]] || { echo -e "[ User aborted. ]\n"; exit 1; }

## Make target dirs
[[ -d "${TARGET_DIR_TEMPLATE}" ]]  ||  mkdir -p "${TARGET_DIR_TEMPLATE}"
[[ -d "${TARGET_DIR_MODULES}" ]]   ||  mkdir -p "${TARGET_DIR_MODULES}"

## Download and install template
echo
for nextItem in "${templateFiles[@]}"; do
	echo "[ Downloading template: ${nextItem} ... ]"
	curl -fsSL -o "${TARGET_DIR_TEMPLATE}/${nextItem}"  "${GITHUB_URL_DOWNLOAD_PREFIX}/${nextItem}"
	chmod +x "${TARGET_DIR_TEMPLATE}/${nextItem}"
done

## Download and install modules
for nextItem in "${moduleFiles[@]}"; do
	echo "[ Downloading module: ${nextItem} ... ]"
	curl -fsSL -o "${TARGET_DIR_MODULES}/${nextItem}"  "${GITHUB_URL_DOWNLOAD_PREFIX}/include/${nextItem}"
	chmod +x "${TARGET_DIR_MODULES}/${nextItem}"
done

## Show installed files
echo -e "\nInstalled template file:"
ls -lA --color=always "${TARGET_DIR_TEMPLATE}/bash5-marmot"
echo -e "\nInstalled module files:"
ls -lA --color=always "${TARGET_DIR_MODULES}"/*

## Test
echo -e "\nTesting template and module installation via:"
echo -e "'${TARGET_DIR_TEMPLATE}/bash5-marmot' --version\n"
"${TARGET_DIR_TEMPLATE}/bash5-marmot" --version || { echo -e "\nError: Template test failed.\n"; exit 1; }

echo -e "\n[ Success. ]\n"



##•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
## History:
##		- 20260601 JC: Created (as tukzedo-linux dev installer).
##		- 20260614 JC: Refactored for bash5-marmot. Two-directory install (template + modules). Query GitHub API for file lists.
