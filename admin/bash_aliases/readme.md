# Compatibility

- Tested on Debian 11 (Bullseye) native and WSL
- The [web] section is intended for Plesk 18 (Obsidian)


# How to install

`wget -O ~/.bash_aliases https://raw.githubusercontent.com/germain-italic/stuff/main/admin/bash_aliases/.bash_aliases && source ~/.bash_aliases`


# How to test

Run `al` to show the version and the list of aliases.
The version number will show up:

![](https://files.italic.fr/debian_Bw8VE9kj1d.png)


To make the bash_aliases addons persistent, make sure that you have added or uncommented this in your `~/.bashrc`  file, otherwie the aliases will be reset at every reconnection.

```
if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi
```

# How to test/contribute using Windows 11 / Debian WSL

If you use Windows and you want to test into a real distro, [install Linux on Windows](https://learn.microsoft.com/en-us/windows/wsl/install) and create a symbolic link **from** the source file on the Windows host **to** the guest distro aliases file.

E.g. if you have cloned this repo inside `C:\Users\germain\Documents\Sites\stuff`, the symlink in the guest distro will be created like this:

`ln -s /mnt/c/Users/$USER/Documents/Sites/stuff/admin/bash_aliases/.bash_aliases ~/.bash_aliases`

Then source the file once:
`source ~/.bash_aliases`


If your shell returns multiple errors like: `-bash: $'\r': command not found`, run the command below to fix your line endings:
`sed -i 's/\r//' ~/.bash_aliases`


# Groups and help

To show the list of aliases, run `all`.
Aliases are grouped by categories.
To create a new category called mygroup, create a comment like:
`# group: mygroup`

To show a help comment / description after the alias name in `all`,
write a single-line comment immediately above the alias definition:

```
# helper text for alias foo
alias foo=''
```


# How to update (re-sync from repo) the aliases to a newer version?

- Remote system: simply run the `aliases` command to re-download from GitHub, override, and re-source the aliases.
- Local (using a symlink) : run the `als` command to re-source the aliases


---

# The `bak` and `dup` functions

- use `bak [source]` to create a `source.bak` file/folder
- use `dup [source] [destination]` to copy a source file/folder in a sibling destination file/folder without retyping the full path (similar to `cp path/{origin,copy}` but easier to type)


# Tests (handmade!)

## Test `bak` (create .bak version of a file/folder)

```bash
pwd
~/test

touch foo.file
mkdir foodir
ls
foodir/      foo.file

# source filename is required
bak
Missing source filename

# source must exist
bak foo
foo not found

# create .bak file and list current dir content
bak foo.file
foodir/      foo.file      foo.file.bak

# create .bak folder and list current dir content
bak foodir/
foodir/  foodir.bak/  foo.file  foo.file.bak

# same test without trailing slash
rmdir foodir.bak/
bak foodir
foodir/  foodir.bak/  foo.file  foo.file.bak

mkdir -p some/sub/directory
touch some/sub/directory/foo.file

# create .bak file in subfolder and cd + ls into it afterwards
bak some/sub/directory/foo.file
foo.file  foo.file.bak
pwd
~/test/some/sub/directory

# create .bak folder in subfolder and cd + ls into its parent afterwards
cd ~/test
bak some/sub/directory/
directory/  directory.bak/
pwd
/home/germain/test/some/sub
```

## Test `dup` (copy a file/folder)

```bash
rm -rf *.bak
ls
foodir  foo.file

# source is required
dup
Missing source filename

# dest filename is required
dup foo.file
Missing destination filename

# copy file in same folder with new name
# same as cp foo.file foo.file2
dup foo.file foo.file2
foodir/  foo.file  foo.file2

# copy subfolder with new name
# same as cp foodir foodir2
dup foodir/ foodir2
foodir/  foodir2/  foo.file  foo.file2

# same test without folder trailing slash
dup foodir foodir3
foodir/  foodir2/  foodir3/  foo.file  foo.file2

# copy subdirectory inside its parent without retyping
# the parent path and cd + ls into its parent
dup some/sub/directory directory2
directory/  directory2/  directory.bak/

# same test with folder trailing slash
dup some/sub/directory/ directory3
directory/  directory2/  directory3/  directory.bak/

# check that target is unique
dup some/sub/directory/ directory3
some/sub/directory3 already exists
```