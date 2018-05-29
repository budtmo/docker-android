# Completion scripts

To be more productive with GMTool, you can install a completion script for your
shell. We provide completion scripts for Bash and Zsh shells.

## Installation

In this document we refer to the directory containing your Genymotion
installation as `<GENYMOTION_DIR>`, the directory containing the `gmtool` binary
as `<GMTOOL_DIR>` and the directory containing completion scripts as
`<COMPLETION_DIR>`.

- Linux:
    - `<GENYMOTION_DIR>` is where you installed Genymotion
    - `<GMTOOL_DIR>` is the same as `<GENYMOTION_DIR>`
    - `<COMPLETION_DIR>` is `<GENYMOTION_DIR>/completion`
- Mac OS X:
    - `<GENYMOTION_DIR>` is `/Applications/Genymotion.app`
    - `<GMTOOL_DIR>` is `<GENYMOTION_DIR>/Contents/MacOS`
    - `<COMPLETION_DIR>` is `<GENYMOTION_DIR>/Contents/Resources/completion`

### Requirements

To take advantage of shell completion, the `gmtool` binary and the `vboxmanage`
binary (provided by VirtualBox) should be in your PATH.

- For gmtool, be sure to add `<GMTOOL_DIR>` to `$PATH`.
- For vboxmanage, add your VirtualBox installation directory to `$PATH`.

### Installing the Bash completion script

Add this line to the end of your `~/.bashrc`:

    . <COMPLETION_DIR>/bash/gmtool.bash

Completion works with Bash 3.2 or later, but we recommend using at least version
4.0, especially if you work with file names which contain spaces.

### Installing the Zsh completion script

Open your `~/.zshrc` and add this line *before* the call to `compinit`:

    fpath=(<COMPLETION_DIR>/zsh $fpath)
