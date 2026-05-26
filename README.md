<!-- markdownlint-disable MD007 -- Unordered list indentation -->
<!-- markdownlint-disable MD010 -- No hard tabs -->
<!-- markdownlint-disable MD033 -- No inline html -->
<!-- markdownlint-disable MD055 -- Table pipe style [Expected: leading_and_trailing; Actual: leading_only; Missing trailing pipe] -->
<!-- markdownlint-disable MD041 -- First line in a file should be a top-level heading -->

<div align="center">

[![!#/bin/bash](https://img.shields.io/badge/-%23!%2Fbin%2Fbash-1f425f.svg?logo=gnu-bash)](https://www.gnu.org/software/bash/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![Lifecycle](https://img.shields.io/badge/Lifecycle-RC-blue)
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
# Bash 5 Modular Marmot

A modular Bash framework that takes full advantage of v5 features. Mostly free of expensive forks, subshells, and pipes. Has native functions that optionally fill in for external tools like grep, sed, tr, etc. - for faster performance especially in long-running loops.

<!-- TOC ignore:true -->
## Table of contents

<!-- TOC -->

- [Introduction](#introduction)
- [Why Bash 5 and not earlier for compatibility](#why-bash-5-and-not-earlier-for-compatibility)
	- [BSD compatibility](#bsd-compatibility)
	- [macOS compatibility](#macos-compatibility)
	- [POSIX compliance](#posix-compliance)
		- [POSIX is 34 years old as of 2026](#posix-is-34-years-old-as-of-2026)
		- [POSIX compliance is a crippling tradeoff to reluctantly adopt only if required by forces beyond your control - not an inherent virtue to strive for](#posix-compliance-is-a-crippling-tradeoff-to-reluctantly-adopt-only-if-required-by-forces-beyond-your-control---not-an-inherent-virtue-to-strive-for)
- [Why Bash at all and not Python or a compiled language](#why-bash-at-all-and-not-python-or-a-compiled-language)
- [Example features and functions](#example-features-and-functions)
- [Installation](#installation)
	- [Install to unprivileged per-user location](#install-to-unprivileged-per-user-location)
	- [Install system-wide](#install-system-wide)
- [Using it](#using-it)
- [Coding style](#coding-style)
- [Copyright and license](#copyright-and-license)

<!-- /TOC -->

## Introduction

This dynamic modular library and template for Bash 5 provides an easy way to get up and running with a relatively simple main script that has access to a powerful modular library. It's fast and almost completely bash-native - free of forking, subshells, pipes, process spawning, etc. It includes powerful (for Bash), bulletproof features and functions with minimal fuss.

- *There are **some** subshells and external tools - but mostly for bootstrapping at script startup. But once underway, it's almost all bash-native, except for modules that imply or explicitly state external tool use (e.g. `exiftool`). However, for your specific implementation, obviously you can use as much forking, subshelling, piping, and external tools as necessary - after all that's usually the point of a **system shell script**, otherwise you'd be better off with a "real" language like Rust, Go, etc.*

## Why Bash 5 and not earlier for compatibility

What do we really mean by "earlier"? Bash 5 has been widely available by default on all modern Linux distros since 2020.

Prior to v5, Bash 4.3 - which is mostly compatible with Bash 5 - has shipped with most Linux distros since 2015. That's 11 years ago as of 2026.

If you are running Linux, and aren't writing simple system init scripts that require `sh` POSIX compatibility, there are few to no good arguments to *not* target Bash 5.

### BSD compatibility

By default, BSD doesn't ship with Bash at all.

However, with native BSD package managers `ports` or `pkg`, it's trivially easy to install a recent Bash v5, and takes seconds.

BSD users don't need to change their default shell - that's what script shebang lines are for, running scripts under the correct interpreter.

> Below is an example FreeBSD command to install Bash 5, from its native package manager and default repository. You could offer to execute this in your script as a user convenience, if you've found it to be necessary - and if elevated privileges fits with your script's permission model:

~~~bash
doas pkg install bash
~~~

### macOS compatibility

MacOS uses Zsh as the default shell, only because Bash switched to a license that was incompatible with Darwin, after Bash v3.2. (GPL 2 ➙ GPL 3.) Apple still gives Bash 3.2 security updates, but functionally it's frozen at v3.2 from 2006. That is absolutely ancient. (20 years old as of 2026.)

To target v3.2 just for "macOS compatibility", is to hamstring a project unnecessarily. It's easy (and legal) to upgrade Bash on macOS to v5 with `ports` or `brew`, and is perfectly reasonable for a script to require it - like any other program or script that has required dependencies. That's been part of installing software, since there was software.

With `brew`, Bash can be installed without administrator rights. And any serious terminal user on macOS has almost certainly already already done this, even if they prefer Zsh, Fish, Nushell, etc.

Either way, if a user can install and execute your script, they already have the necessary "skills" required to copy and paste a single one-liner command to install Bash 5. (And any other updated GNU tools your script may rely on, and version-check.)

> Below is an example one-liner to install Bash 5 on macOS without root access, that you could write into your script as a user convenience feature, if the tested current version isn't high enough:

~~~bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; brew install bash
~~~

This installs Bash 5 at the user-level in a way that bash scripts run by the user from the terminal, will default to v5. (Unless hard-coded to `#!/bin/bash`.) There are other ways to install it, including at the system level, in ways that preempt Bash 3.2 in most or all user-facing contexts. Scripts and system utilities that hardcode `/bin/bash` will still invoke 3.2; SIP prevents replacing it.

And again - macOS users don't need to change their default shell from Zsh, nor run Bash themselves in the terminal, in order to run Bash 5 scripts from any shell environment.

Also if you want to absolutely guarantee running under bash 5 no matter how unknown your target macOS environment is, with just a few lines of guard code your script can first execute under *any* version of bash (even `#!/bin/bash`), test if it's v5, find v5 if it's not, and re-execute itself under that v5. (Or warn the user if it's not installed.)

### POSIX compliance

#### POSIX is 34 years old as of 2026

That's a year older than the Windows NT CMD "language" (extended from DOS BAT), and almost as terrible.

The POSIX standard was settled in 1992, but mostly comes from 1988 with the original UNIX Bourne shell.

We're over a quarter of the way through the current century. POSIX comes from the last 10% of the *previous century*.

If POSIX were a person, she could be a *grandparent* by now, legally in every country and US state along the way.

#### POSIX compliance is a crippling tradeoff to reluctantly adopt only if required by forces beyond your control - not an inherent virtue to strive for

POSIX has no support for some *basic* entry-level features, protections, and syntax sugar of programming and shell-scripting from this century - such arrays, local variables, built-in arithmetic comparison ergonomics (e.g. `((variable >= 1))`), C-style semantics, and many other basic features.

The Linux boot process still uses POSIX compatibility for some startup init scripts, that haven't been retooled in decades because they work. Such init scripts generally need to be very simple in scope, and so aren't a good candidate for this template and module library anyway (unless forked in a way that can't abort or block the main init thread).

While there may be some other obscure edge-cases, the *only* good reason to absolutely kneecap a project with "POSIX compliance", is usually if you are specifically targeting the system init process.

> It might be helpful to try to get clear with yourself on whether or not you agree with this opinion:<br /><br />*The notion that "I'd like my script to be able to easily run on random macOS and/or BSD installations", doesn't constitute "forces beyond your control". POSIX compliance might be a choice you freely decide to adopt, but at least make it with the knowledge that it could significantly add to the coding burden (depending on how complex your project is), and may also be unfairly dismissing your users' capacity to copy and paste a one-liner required to install one among potentially other dependencies - which they've presumably already done at least once in some form or another, to install your script in the first place.*

## Why Bash at all and not Python or a compiled language

That's a good question that isn't up to this author to answer for you. But hopefully, the problem you're trying to solve is in a clear enough problem domain, that the answer is obvious. (Or the scope at least significantly narrowed-down.)

I've written a deeper dive into this question - a [System shell script language comparison](https://github.com/jim-collier/bash5-marmot/blob/main/shell_script_comparison.md), in this same repo, to try to help address the pros and cons of other solutions - including Python-based solutions, and compiled languages.

This document section from another project - "TOOBLIN: True Object-Oriented Bash": ['But no really...Why?'](https://github.com/jim-collier/tooblin#but-no-reallywhy) - dives into great detail on the advantages of Bash over other options, for certain problem domains. (Particularly that of system shell scripting.)

There's also the insidious shibboleth that goes something like, "After 100 lines use Python not Bash." A trite bromide that has no meaningful or useful value in real-life, practical domain-specific problem-solving. The problem domains where one is more obviously appropriate than the other, are often starkly different and have nothing to do with lines of code. Furthermore, there are numerous high-quality open-source projects written in Bash that span hundreds of modular files, tens of thousands of lines of code, and dozens to hundreds of active contributors. (Specific examples are listed in the same file linked above, in the section "[Myths and realities of Bash](https://github.com/jim-collier/tooblin#myths-and-realities-of-bash)".) Python may be an obviously superior choice in many problem spaces - possibly even for some of those examples listed (where Bash seems like an odd choice in at least one case), but usually not for general system shell scripting - reasonably independent of scope, scale, or complexity.

## Example features and functions

## Installation

You don't *have* to run the installer script, you can just download the files from the latest stable release and use them. In a nutshell:

- Download `0_bash5-marmot.bash`. It can go anywhere.

	- Specific implementation copies would ideally go somewhere in your `$PATH`, with the `+x` execute attribute set.

- Download `include/n8_module_*` files, put them somewhere such as an `./include/` directory next to your renamed template script, or in a common Linux place like `/usr/local/lib/n8` or `~/.local/bin/lib/n8`.

	- *They don't have to go specifically there. The module loader works hard to quickly find them in common "module", "library", or "include" locations; either in or under common Linux FSH locations, or relative to the loading script. And don't have to be in `$PATH`.*

But if you'd like an automated install, run the installer script.

By default (which can be changed by downloading and editing the installer before running), the installer script installs the following files to the following locations:

| File(s)                  | Per-user install location   | System-wide install location
| :--                      | :--                         | :--
| 0_bash5-marmot.bash  | ~/.local/**bin**            | /usr/local/**bin**
| include/n8mod_*          | ~/.local/**bin/lib**/n8     | /usr/local/**lib**/n8

> ⚠️ *Before running one of the `curl` commands below, make sure you inspect the `install.bash` script to make sure it's safe. (It's pretty simple.)*

### Install to unprivileged per-user location

As a general security "best-practice" (and for no other reason), this is usually the recommended way.

~~~bash
curl -fsSL https://raw.githubusercontent.com/jim-collier/bash5-marmot/main/install.bash | bash
~~~

### Install system-wide

The only difference from above, is the `sudo` in front of the `bash` - so that the installer can copy the main template to `/usr/local/bin`, and the `n8_module_*`s to `/usr/local/lib` (by default). It will auto-detect that it's running as root and choose those locations.

This is a convenient long-term approach even for user-level scripts, as the template can remain "immutable" (and copy/renamed to a user directory `$PATH` location for specific implementations), and the read-only modules can just remain in the system location.

Even with this approach, the command below will still update existing older versions.

~~~bash
curl -fsSL https://raw.githubusercontent.com/jim-collier/bash5-marmot/main/install.bash | sudo bash
~~~

## Using it

Look in the function `fMain()` inside `0_bash5-marmot.bash`, for examples.

> ⚠️ *As with any scripts downloaded from the internet, before executing any new module code for the first time, be sure to review it and every dependent function it calls. Pay special attention to network, disk, and/or system call access, especially in functions that don't seem like they would need it (which should be nonexistent in this codebase), and any use of `sudo` that is not explicitly part of the function name and/or obvious and commented purpose (which should also be nonexistent).*

## Coding style

Here is the author's [Bash 5 Ultimate Guide](https://github.com/jim-collier/bash-5-ultimate-guide/blob/main/bash-5-ultimate-guide.md).

This template helps you follow those best-practices.

## Copyright and license

> Copyright © 2026 Jim Collier (ID: 1cv◂‡Vᛦ)<br />
> Licensed under [The MIT License (MIT)](https://mit-license.org/). No warranty.
