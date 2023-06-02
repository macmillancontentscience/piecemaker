# Resubmission

## Changes

* Streamlined `validate_utf8()` to work consistently across OS and R versions.

## R CMD check results

0 errors | 0 warnings | 0 notes

## Test environments

* local R installation, R 4.3.0 (Windows 11)
* win-builder (devel)
* Windows Server 2022, R-devel, 64 bit (rhub)
* Ubuntu Linux 20.04.1 LTS, R-release, GCC (rhub)
* Fedora Linux, R-devel, clang, gfortran (rhub)

### Windows

There are NOTEs when testing for Windows Server:

```
* checking for non-standard things in the check directory ... NOTE
Found the following files/directories:
  ''NULL''
* checking for detritus in the temp directory ... NOTE
Found the following files/directories:
  'lastMiKTeXException'
```

I cannot reproduce these errors on my Windows machine, and a web search indicated that it is likely nothing. I can't find anything that could possibly trigger that error.

### Linux

Both Linux checks also returned this note:

```
* checking HTML version of manual ... NOTE
Skipping checking HTML validation: no command 'tidy' found
```

This note also appears to be a false alarm.

## revdepcheck results

We checked 2 reverse dependencies, comparing R CMD check results across CRAN and dev versions of this package.

 * We saw 0 new problems
 * We failed to check 0 packages
