# IDE Empirical Performance Analysis

This repository contains all of the relevant scripts used in the completion of the analysis for the Vi, Vim, Emacs, Nano, and miniText editors.

## bench.sh

- Used to run both the miniText.sh and time.sh scripts in parallel
- Parameters:\
  \$1 = iterations\
  \$2 = file to open
- Usage:

```bash
$ ./bench.sh 10 <FolderName>
```

## fileCopy.sh

- Used to copy over all files based on file extension into a folder titled \<fileExtension\>\<EditorName\> (e.g. cVim, hVim).
- Usage:

```bash
$ ./fileCopy.sh
```

## miniText.sh

- Used to iterate through the numerous file sizes for miniText in specific extracting the average execution time, average CPU time, average number of CPU instructions, and average number of cache references made.
- Parameters:\
  \$1 = iterations\
  \$2 = file to open
- Usage:

```bash
$ ./miniText.sh 10 <FolderName>
```

## time.sh

- Used to iteratively run any of the 4 open-source editors (Vi, Vim, Nano, Emacs) extracting the average execution time, average CPU time, average number of CPU instructions, and average number of cache references made.
- Parameters:\
  \$1 = iterations\
  \$2 = file to open\
  \$3 = editors to use
- Usage:

```bash
$ ./time.sh 10 <FolderName> <comma,seperated,editor,list>
```
