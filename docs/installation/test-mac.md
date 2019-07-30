# Execute FreeLing on MacOS

FreeLing provides a main program that allows to execute most of its capabilities. However, remember that FreeLing is a library and that many more functionalities are accessible writting your own main program.

The provided main program can be executed running the command:
```
   FREELINGDIR/analyze -f en.cfg < myfile.txt
```
Where the folder `FREELINGDIR` is:

* If you installed from a binary package, `FREELINGDIR` is `/usr/local`.
* If you installed on Linux compiling from source, `FREELINGDIR` is `/usr/local`, unless you specified a custom installation directory with `CMAKE_INSTALL_PREFIX`, in which case `FREELINGDIR` is that directory.

Check FreeLing manual ([https://talp-upc.gitbooks.io/freeling-user-manual/](https://talp-upc.gitbooks.io/freeling-user-manual/)), section "Using the analyze script", to find out the parameters it accepts.

Note that the input text in `myfile.txt` must be UTF8 encoded.  
You can also provide input from the terminal and end it with ctl-D.

See sections [Execute FreeLing demo](#execute-analyzer) and [Call FreeLing Library](#call-library) to find out more on how to use FreeLing.        
