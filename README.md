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
# Bash 5 modular library

This template and dynamic library for Bash 5 provides the easiest way to get up and running with a simple script that has access to a powerful library that is fast and 100% bash-native - with no subshells, pipes, or process spawning. It includes powerful (for Bash), bulletproof features and functions with minimal fuss.

<!-- TOC ignore:true -->
## Table of contents

<!-- TOC -->

- [Why Bash 5 and not earlier for compatibility](#why-bash-5-and-not-earlier-for-compatibility)
	- [BSD](#bsd)
	- [macOS](#macos)
	- [POSIX](#posix)
- [Example features and functions](#example-features-and-functions)
- [Installation](#installation)
	- [Install to unprivileged per-user location](#install-to-unprivileged-per-user-location)
	- [Install system-wide](#install-system-wide)
- [Using it](#using-it)
- [Coding style](#coding-style)
- [Copyright and license](#copyright-and-license)

<!-- /TOC -->

## Why Bash 5 and not earlier for compatibility

Bash 5 has been widely available by default on all modern Linux distros since 2020.

Prior to v5, Bash 4.3 - which is mostly compatible with Bash 5 - has shipped with most Linux distros since 2015.

If you are running Linux, and aren't writing simple system init scripts that require `sh` POSIX compatibility, there aren't many good arguments to *not* target Bash 5.

### BSD

By default, BSD doesn't ship with Bash at all. But with `ports` or `pkg`, it's trivially easy to install Bash v5.

### macOS

MacOS uses Zsh as the default shell, only because Bash switched to a license after v3.2 that was incompatible with Darwin. (GPL 2 -> GPL 3.) Apple still gives Bash 3.2 security updates, but functionally it's frozen at v3.2 from 2006. That is absolutely ancient. (20 years old as of 2026.)

To target v3.2 just for macOS compatibility, is to unnecessarily hamstring a project. It's trivially easy (and legal) to upgrade Bash on macOS to v5 with `ports` or `brew`, and perfectly reasonable for a script to require it. Any serious terminal user on macOS has almost certainly already done this; and if the user can install your script, they can certainly install `brew` and Bash 5.

### POSIX

The Linux boot process still uses the original Bourne shell for some startup init scripts. (Actually since the Bourne shell is a proprietary UNIX shell, most Linuxes either use Dash, or Bash in pseudo-"POSIX-compatibility" mode, symbolically linked to `sh`.) Such init scripts generally need to be very simple in scope, and so aren't a good candidate for this template and module library anyway - unless forked to its own process that it can't abort or block the main init thread.

The POSIX standard for shell scripting was reverse-engineered to define whatever the Bourne shell supported at the time, in 1988. (38 years old as of 2026.) That's even older than the Windows NT CMD "language" (extended from DOS BAT), and almost as terrible.

POSIX doesn't even support arrays, and nearly everything requires a performance-crippling subshell - even trivial test conditions for if/then. While there may be some other obscure edge-cases, the *only* good reason to absolutely kneecap a project with "POSIX compatibility", is for inclusion in the system init process. (Or for the misguided notion that "POSIX Compatibility" ⊎ "Standards-Compliant".)

## Example features and functions

## Installation

You don't *have* to run the installer script, you can just download the files from the latest stable release and use them. In a nutshell:

- Download `0_x9bash5-template.bash`. It can go anywhere.

	- Specific implementation copies would ideally go somewhere in your `$PATH`, with the `+x` execute attribute set.

- Download `include/n8_module_*` files, put them somewhere such as an `./include/` directory next to your renamed template script, or in a common Linux place like `/usr/local/lib/n8` or `~/.local/bin/lib/n8`.

	- *They don't have to go specifically there. The module loader works hard to quickly find them in common "module", "library", or "include" locations; either in or under common Linux FSH locations, or relative to the loading script. And don't have to be in `$PATH`.*

But if you'd like an automated install, run the installer script.

By default (which can be changed by downloading and editing the installer before running), the installer script installs the following files to the following locations:

| File(s)                  | Per-user install location   | System-wide install location
| :--                      | :--                         | :--
| 0_x9bash5-template.bash  | ~/.local/**bin**            | /usr/local/**bin**
| include/n8mod_*          | ~/.local/**bin/lib**/n8     | /usr/local/**lib**/n8

> ⚠️ *Before running one of the `curl` commands below, make sure you inspect the `install.bash` script to make sure it's safe. (It's pretty simple.)*

### Install to unprivileged per-user location

As a general security "best-practice" (and for no other reason), this is usually the recommended way.

~~~bash
curl -fsSL https://raw.githubusercontent.com/jim-collier/x9bash5-template/main/install.bash | bash
~~~

### Install system-wide

The only difference from above, is the `sudo` in front of the `bash` - so that the installer can copy the main template to `/usr/local/bin`, and the `n8_module_*`s to `/usr/local/lib` (by default). It will auto-detect that it's running as root and choose those locations.

This is a convenient long-term approach even for user-level scripts, as the template can remain "immutable" (and copy/renamed to a user directory `$PATH` location for specific implementations), and the read-only modules can just remain in the system location.

Even with this approach, the command below will still update existing older versions.

~~~bash
curl -fsSL https://raw.githubusercontent.com/jim-collier/x9bash5-template/main/install.bash | sudo bash
~~~

## Using it

Look in the function `fMain()` inside `0_x9bash5-template.bash`, for examples.

> ⚠️ *As with any scripts downloaded from the internet, before executing any new module code for the first time, be sure to review it and every dependent function it calls. Pay special attention to network, disk, and/or system call access, especially in functions that don't seem like they would need it (which should be nonexistent in this codebase), and any use of `sudo` that is not explicitly part of the function name and/or obvious and commented purpose (which should also be nonexistent).*

## Coding style

Here is the author's [Bash 5 Ultimate Guide](https://github.com/jim-collier/bash-5-ultimate-guide/blob/main/bash-5-ultimate-guide.md).

This template helps you follow those best-practices.

## Copyright and license

> Copyright © 2026 Jim Collier (ID: 1cv◂‡Vᛦ)<br />
> Licensed under [The MIT License (MIT)](https://mit-license.org/). No warranty.