# Resubmission

## Changes

* Removed purrr dependency.

## Test environments

* local R installation, R 4.1.2 (Windows 10)
* win-builder (devel)
* Windows Server 2022, R-devel, 64 bit (rhub)
* Ubuntu Linux 20.04.1 LTS, R-release, GCC (rhub)
* Fedora Linux, R-devel, clang, gfortran (rhub)

There is a NOTE when testing for Windows Server:

```
* checking for detritus in the temp directory ... NOTE
Found the following files/directories:
  'lastMiKTeXException'
```

I cannot reproduce this error on my Windows machine, and a web search indicated that it is likely nothing. I can't find anything that could possibly trigger that error.

## R CMD check results

0 errors | 0 warnings | 0 notes

## Reverse dependencies

wordpiece and morphemepiece are not impacted by this change.
