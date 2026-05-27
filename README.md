<!-- markdownlint-disable MD007 -- Unordered list indentation -->
<!-- markdownlint-disable MD010 -- No hard tabs -->
<!-- markdownlint-disable MD033 -- No inline html -->
<!-- markdownlint-disable MD055 -- Table pipe style [Expected: leading_and_trailing; Actual: leading_only; Missing trailing pipe] -->
<!-- markdownlint-disable MD041 -- First line in a file should be a top-level heading -->

<div align="center">

[![!#/bin/bash](https://img.shields.io/badge/-%23!%2Fbin%2Fbash-1f425f.svg?logo=gnu-bash)](https://www.gnu.org/software/bash/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![Lifecycle: Stable](https://img.shields.io/badge/Lifecycle-Stable-brightgreen)
![Support](https://img.shields.io/badge/Support-Maintained-brightgreen)
![Coverage](https://img.shields.io/badge/Coverage-75%25-yellow)
![Status: Passing](https://img.shields.io/badge/Status-Passing-brightgreen)

</div>
<!--
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)
![Lifecycle: Alpha](https://img.shields.io/badge/Lifecycle-Alpha-orange)
![Lifecycle: Beta](https://img.shields.io/badge/Lifecycle-Beta-yellow)
![Lifecycle: RC](https://img.shields.io/badge/Lifecycle-RC-blue)
![Lifecycle: Stable](https://img.shields.io/badge/Lifecycle-Stable-brightgreen)
![Lifecycle: Deprecated](https://img.shields.io/badge/Lifecycle-Deprecated-red)
![Status: Deprecated](https://img.shields.io/badge/Status-Deprecated-orange)
![Status: Archived](https://img.shields.io/badge/Status-Archived-lightgrey)
![Lifecycle: EOL](https://img.shields.io/badge/Lifecycle-EOL-lightgrey)
![Coverage](https://img.shields.io/badge/Coverage-25%25-red)
![Coverage](https://img.shields.io/badge/Coverage-50%25-orange)
![Coverage](https://img.shields.io/badge/Coverage-75%25-yellow)
![Coverage](https://img.shields.io/badge/Coverage-90%25-brightgreen)
![Status: Passing](https://img.shields.io/badge/Status-Passing-brightgreen)
![Status: Failing](https://img.shields.io/badge/Status-Failing-red)
-->

<!-- TOC ignore:true -->
# Bash5 Modular Marmot

<table>
	<tr>
		<td style="border: none;"><img src="https://github.com/jim-collier/bash5-marmot/blob/main/assets/mascot3.png?raw=true" alt="Modular Marmot" width="320"/></td>
		<td style="border: none;">Welcome to Bash5 Modular Marmot. It's a modular Bash framework that takes full advantage of v5 features. Mostly free of expensive forks, subshells, and pipes. Has native functions that optionally fill in for external tools like grep, sed, tr, etc. - for faster performance especially in long-running loops.</td>
	</tr>
</table>

<!-- TOC ignore:true -->
## Table of contents

<!-- TOC -->

- [Features](#features)
- [Why Bash 5 and not earlier for compatibility](#why-bash-5-and-not-earlier-for-compatibility)
	- [BSD](#bsd)
	- [macOS](#macos)
	- [POSIX](#posix)
		- [POSIX was 34 years old at the start of this project](#posix-was-34-years-old-at-the-start-of-this-project)
		- [POSIX compliance is a crippling tradeoff and often artificial constraint](#posix-compliance-is-a-crippling-tradeoff-and-often-artificial-constraint)
- [Why Bash at all and not Python or a compiled language](#why-bash-at-all-and-not-python-or-a-compiled-language)
- [Installation](#installation)
	- [Install to unprivileged per-user location](#install-to-unprivileged-per-user-location)
	- [Install system-wide](#install-system-wide)
- [Using it](#using-it)
- [Coding style](#coding-style)
- [Copyright and license](#copyright-and-license)

<!-- /TOC -->

## Features

| Feature | Advantage and/or benefit | Drawback
| :--     | :--                      | :--
|  |  |

## Why Bash 5 and not earlier for compatibility

Bash 5 has been widely available by default on all modern Linux distros since 2020.

Prior to v5, Bash 4.3 - which is mostly compatible with Bash 5 - has shipped with most Linux distros since 2015. That's 11 years ago as of 2026.

Therefore, by targeting a Bash version earlier than 5, implies some intention or external requirement other than "Linux compatibility".

If you are running Linux, and aren't writing simple system init scripts that require `sh` POSIX compatibility, there are few to no good arguments to *not* target Bash 5.

### BSD

By default, BSD doesn't ship with Bash at all. If you want your Bash script to be able to run on all BSDs without requiring the user install even a single dependency, that is usually going to *very* tall order for a script author - save for the most trivial of scripts. Because:

- For full coverage of all the BSDs, you would necessarily not be writing Bash at all, but 100% POSIX compliant `sh` script. (E.g. via Ash, Dash, or something else symlinked to `/bin/sh`.) This would *severely* hamstrings a non-trivial project, and tie it down to 1992. (See the section on POSIX below.)

- Every major core GNU utility of Linux is different on the BSDs (since GPLv3), some rewritten from scratch - and usually not as powerful - or at best with subtly different interfaces that must be individually detected, understood by the script author, and accounted for.

	- Writing Bash-native alternatives to many core utilities, that work on any platform, is possible in Bash v5. (For example, Bash `=~` with `${BASH_REMATCH[n]}` is shockingly powerful.) But that is generally not possible with any reasonable efficiency or hope of performance, in pure POSIX.

	- It's usually much easier, safer, and reasonable to simply require the user to install - via their native BSD package manager, a finite list of updated GNU core utilities. (Which by default install with a "g" prefix to avoid conflicting with existing system scripts that assume BSD variants.)

		But as long as you're doing that, you might as well have the user also install Bash. (Which will be GNU v5.) Or possibly *only* install Bash. It is usually not an unreasonable expectation that software has prior installation dependencies, especially when so trivially easily met and that has no package or system conflicts.

With native BSD package managers (e.g. `ports` or `pkg`), it takes seconds to install Bash 5.

BSD users don't need to change their default shell - that's what script shebang lines are for, running scripts under the correct interpreter.

> Below is an example FreeBSD command to install Bash 5, from the native package manager and standard repository. You could offer to execute this in your script as a user convenience, if you've found it to be necessary - and if elevated privileges fits with your script's permission model:

~~~bash
doas pkg install bash
~~~

### macOS

MacOS uses Zsh as the default shell, only because Bash switched to a license that was deemed incompatible with Darwin, after Bash v3.2. (GPL 2 ➙ GPL 3.) Apple still gives Bash 3.2 security updates, but functionally it's frozen at v3.2 from 2006. That is absolutely ancient. (20 years old as of 2026.)

To target v3.2 just for "macOS compatibility", is to hamstring a project unnecessarily - at which point you might as well just stick to POSIX.

But it's easy (and legal) for users to upgrade Bash on macOS to v5 with `ports` or `brew`, and is usually completely reasonable for a script to require it. "Installing dependencies" have been part of installing software, since there was software.

With `brew`, Bash can be installed without administrator rights. And most serious terminal users on macOS have already already done this, even if they prefer Zsh, Fish, Nushell, etc.

Either way, if a user can install and execute your script, they've already demonstrated the necessary "skills" required to copy and paste a single one-liner command to install Bash 5. (And any other updated GNU tools your script might rely on, and version-check.)

> Below is an example one-liner to install Bash 5 on macOS without root access, that you could write into your script as a user convenience feature, if the tested current version isn't high enough:

~~~bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; brew install bash
~~~

This installs Bash 5 at the user-level in a way that bash scripts run by the user from the terminal, will default to v5 (except for scripts hard-coded to use `#!/bin/bash`.) v5 is backwards-compatible with v3.2, so existing scripts won't break (except for rare edge-cases involving undefined behavior). There are other ways to install Bash 5, including at the system level (e.g. via `macports`), and in ways that preempt Bash 3.2 in most or all user-facing contexts. Scripts and system utilities that hardcode `/bin/bash` will still invoke 3.2; SIP prevents replacing it. (But that's arguably a good thing, as you can be confident that system scripts won't break.)

And again - macOS users don't need to change their default shell from Zsh, nor run Bash themselves in the terminal, in order to run Bash 5 scripts from any shell environment.

Also if you want to absolutely guarantee that your script runs under bash 5 on macOS (or BSD), no matter how unknown your target environment is: with just a few lines of guard code, your script can first execute under *any* version of bash (even `#!/bin/bash`), test if it's v5, find v5 if its not (or even safely install it fairly isolated), and re-execute itself under that v5. (Or just punt and warn the user if v5 is not installed, and abort.) Any decent LLM can write this for you (I tried it to make sure - including the safe automatic install), and would surely be easier than torturing yourself with POSIX.

Which brings us to...

### POSIX

#### POSIX was 34 years old at the start of this project

That's a year older than the Windows NT CMD "language" (extended from DOS BAT), and almost as crusty.

The POSIX standard was settled in 1992, but mostly dates to 1988 with ksh88 and the original UNIX Bourne shell.

We're over a quarter of the way through the current century. POSIX comes from about 10% back into the *previous century*.

If POSIX were a person, she could be a *grandparent* by now, legally in every country and US state along the way.

#### POSIX compliance is a crippling tradeoff and often artificial constraint

POSIX has no support for some *basic* entry-level features, protections, and syntax sugar of programming and shell-scripting from this century - such arrays, local variables, built-in arithmetic comparison ergonomics (e.g. `((variable >= 1))`), C-style semantics, and many other basic features.

Some Linux, BSD, and macOS boot processes still use POSIX compatibility for some init scripts, that haven't been retooled in decades because they still work fine.

Such init scripts, including custom ones you write and call from pluggable locations, generally need to be very simple in scope, and so aren't a good candidate for this template and module library anyway. (Unless forked in a way that can't abort or block the main init thread.)

While there may be some other obscure edge-cases, the *only* good reason to absolutely kneecap a project with "POSIX compliance", is usually if you are specifically targeting the system init process.

> It might be helpful to try to get clear with yourself on whether or not you agree with this opinion:<br /><br />*The idea that "I want my script to run on any macOS/BSD system without extra steps" is not an external constraint. POSIX compliance is a choice, but it adds complexity and may underestimate users' ability to handle simple dependency installations, which they've already demonstrated to get your script.*

## Why Bash at all and not Python or a compiled language

That's a good question that isn't up to this author to answer for you. But hopefully, the problem you're trying to solve is in a clear enough problem domain, that the answer is obvious. (Or the scope at least significantly narrowed-down.)

I've written a deeper dive into this question - a [System shell script language comparison](https://github.com/jim-collier/bash5-marmot/blob/main/shell_script_comparison.md), in this same repo, to try to help address the pros and cons of other solutions - including Python-based solutions, and compiled languages.

This document section from another project - "TOOBLIN: True Object-Oriented Bash": ['But no really...Why?'](https://github.com/jim-collier/tooblin#but-no-reallywhy) - dives into great detail on the advantages of Bash over other options, for certain problem domains. (Notably system shell scripting.)

There's also an insidious shibboleth that goes something like, "After 100 lines use Python not Bash." But such a bromide has no meaningful or useful value in real-life, practical domain-specific problem-solving. It's also ironic, since for system shell scripting specifically, Python almost always requires a few *multiples* of lines of code to do the same as in Bash, for the problems Bash was designed to solve. (Because those aren't the problems Python was designed to solve. The other way around would be equally true.) The problem domains where one is more appropriate than the other, are often obvious and stark - and have nothing to do with code line count. Furthermore, there are numerous high-quality open-source projects written in Bash that span hundreds of modular files, tens of thousands of lines of code, and dozens to hundreds of active contributors. (Specific examples are listed in the same file linked above, in the section "[Myths and realities of Bash](https://github.com/jim-collier/tooblin#myths-and-realities-of-bash)".)

Python is certainly a superior choice to Bash in many problem spaces - possibly even for one or more of those examples listed. (Bash seems like an odd choice in at least one case.) But it's not generally true for system shell scripting - reasonably independent of scope, scale, or complexity. (However the Python-based Xonsh shell may fill in some - but not all - of those gaps. See the comparison link above for that specifically.)

## Installation

You don't *have* to run the installer script, you can just download the files from the latest stable release and use them. In a nutshell:

- Download `bash5-marmot`. It can go anywhere.

	- Specific renamed implementation copies would ideally go somewhere in your `$PATH`, with the `+x` execute attribute set.

- Download `include/n8_module_*` files, put them somewhere such as an `include` or `lib` directory next to your renamed template script, or under a common Linux place like `/usr/local/lib/n8` or `~/.local/bin/lib`.

	- *They don't have to go specifically there. The module loader works hard to quickly find them in common "module", "library", or "include" -type locations; either in or under common Linux FSH locations, or relative to the loading script. It doesn't have to be in the `$PATH`, though the loader can also locate them there.*

But if you'd like an automated install, run the installer script.

By default (which can be changed by downloading and editing the installer before running), the installer script installs the following files to the following locations:

| File(s)                  | Per-user install location   | System-wide install location
| :--                      | :--                         | :--
| bash5-marmot  | ~/.local/**bin**            | /usr/local/**bin**
| include/n8mod_*          | ~/.local/**bin/lib**/n8     | /usr/local/**lib**/n8

> ⚠️ *Before running one of the `curl` commands below, make sure you inspect the `install.bash` script to make sure it's safe. (It's pretty simple.)*

### Install to unprivileged per-user location

As a general security "best-practice" (and for no other reason), this is usually the recommended way.

~~~bash
curl -fsSL https://raw.githubusercontent.com/jim-collier/bash5-marmot/main/install.bash | bash
~~~

### Install system-wide

The only difference from above, is the `sudo` in front of the `bash` - so that the installer can copy the main template to the system folders noted in the table above. It will auto-detect that it's running as root and will choose those locations.

This is a convenient long-term approach even for user-level scripts, as the template can remain "immutable" (and copy/renamed to a user directory `$PATH` location for specific implementations), and the read-only modules can just remain in the system location.

~~~bash
curl -fsSL https://raw.githubusercontent.com/jim-collier/bash5-marmot/main/install.bash | sudo bash
~~~

## Using it

Look in the function `fMain()` inside `bash5-marmot`, for examples.

> ⚠️ *As with any scripts downloaded from the internet, before executing any new template or module code for the first time, be sure to review it and every dependent function it calls. Pay special attention to network, disk, and/or system call access, especially in functions that don't seem like they would need it (which should be nonexistent in this codebase), and any use of `sudo` that is not explicitly part of the function name and/or obvious and commented purpose (which should also be nonexistent).*

## Coding style

Here is the author's [Bash 5 Ultimate Guide](https://github.com/jim-collier/bash-5-ultimate-guide/blob/main/bash-5-ultimate-guide.md).

This template helps you follow those best-practices.

## Copyright and license

> Copyright © 2026 Jim Collier (ID: 1cv◂‡Vᛦ)<br />
> Licensed under [The MIT License (MIT)](https://mit-license.org/). No warranty.
