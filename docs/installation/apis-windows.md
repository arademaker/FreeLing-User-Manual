# Building and using APIs on Windows

If you don't want to write Python or Java programs that call Freeling, you can skip this section.

To be able to call FreeLing from Python or Java, you should have built it from source, using cmake options `-DPYTHON2_API`, `-DPYTHON3_API`, or `-DJAVA_API`, depending on your target.
If you haven't see [Install from source on Linux](installation-windows.md) to find out how to do so.

Next sections assume you compiled and installed FreeLing with the appropriate APIs for your target language.
***IMPORTANT***: From this point on, we will refer to FreeLing installation folder (either chosen by you or the default location) as `%FLINSTALL%`.

## APIs Requirements 

If you want to call FreeLing library from Python or Java, you need to install some
extra software before building FreeLing:

1. **Install SWIG**
   Download swigwin.zip package from http://swig.org and uncompress it anywhere you want (e.g. `C:\Program Files\swigwin`).
   ***IMPORTANT***: We will refer to this folder as `%SWIGDIR%` from now on.

2. Install target language, including interfaces, that is:
    * **For Python**: Install Python2 or Python3.
    
      FreeLing uses UTF8 encoding to support multilinguality. Python3 is native in UTF8, which provides a much smoother integration with FreeLing. You can use Python2, but if you have encoding problems, we told you so...

    * **For Java**: Install Java Development Kit.
    
3. Add the following options to the "cmake" command during the procedure described in [Install from source on Windows](installation-windows.md):

   `-DSWIG_DIR=%SWIGDIR%`             
   `-DSWIG_EXECUTABLE=%SWIGDIR%\swig.exe`
   `-DPYTHON2_API=ON`  (if you want to build Python 2 API. Not compatible with `-DPYTHON3_API`)
   `-DPYTHON3_API=ON`  (if you want to build Python 3 API. Not compatible with `-DPYTHON2_API`)
   `-DJAVA_API=ON`     (if you want to build Java API)



## PYTHON
  
If you built the Python2 (or Python3) API, you'll find in `%FLINSTALL%\freeling\share\freeling\APIs\python2` (or `...\python3`) the following files:

| File | Content |
| -- | -- |
| `pyfreeling.py`   | FreeLing python module, to be imported from your program.<br>It must be in the same folder than your program or in a folder included in `%PYTHONPATH%`. |
| `_pyfreeling.lib`<br>`_pyfreeling.pyd` | These two files are the actual API DLL, bridging between Python and C++.<br>They both must be in the same folder than your program, or in a folder included in `%PATH%`. | 
| `sample.py`       | An example of a python program that calls FreeLing. |
	
To run the example, do:
```
   cd %FLINSTALL%\freeling\share\freeling\APIs\python
   python sample.py < mytext.txt
```

- If you get "ImportError" about not found DLLs, you need to set %PATH% so all the required libraries (freeling and all its dependencies) are found. (You need to do this only once per session, or you can set it once and forever in your system-wide configuration):
  ```
  set PATH=%PATH%;%FLINSTALL%\freeling\bin;%FLINSTALL%\dependencies\boost\lib;%FLINSTALL%\dependencies\zlib\bin;%FLINSTALL%\dependencies\icu\bin64;
  ```
  
- If you get "FREELINGDIR not defined", you need to set the location where FreeLing was installed:
  ```     
  set FREELINGDIR=%FLINSTALL%\freeling
  ```
  (this is because the example program "sample.py" checks that variable, it is not a general requirement of the API or FreeLing)


## JAVA

If you built the Java API you'll find in `%FLINSTALL%\freeling\share\freeling\APIs\java` the following files:

| File | Content |
| -- | -- |
| Jfreeling.jar  | FreeLing Java module, to be imported from your program.<br>It must be included in `%CLASSPATH%` | 
| Jfreeling.lib<br>Jfreeling.dll  | The actual API DLL, bridging between Java and C++.<br>They both must be in the same folder than your program or in a folder included in `%PATH%` |
| Analyzer.java  | An example of a Java program that calls FreeLing. |
	
To run the example, do:
``` 
   cd %FLINSTALL%\freeling\share\freeling\APIs\java
   javac Analyzer.java
   java Analyzer < mytext.txt
```

- If you get "UnsatisfiedLinkError" about not found libraries, you need to set `%PATH%` so all the required libraries (freeling and all its dependencies) are found (you need to do this only once per session, or you can set it once and forever in your system-wide configuration):
  ```
      set PATH=%PATH%;%FLINSTALL%\freeling\bin;%FLINSTALL%\dependencies\boost\lib;%FLINSTALL%\dependencies\zlib\bin;%FLINSTALL%\dependencies\icu\bin64;
  ``` 
  
- If you get "FREELINGDIR not defined", you need to set the location where FreeLing was installed:
  ```       
     set FREELINGDIR=%FLINSTALL%\freeling
  ```
  (this is because the example program "Analyzer.java" checks that variable, it is not a general requirement of the API or FreeLing)

- If you get memory-related errors (allocation error, array out of range, etc), it  may be that your JVM has to not enough RAM for FreeLing.  Try with -Xmx1G or more.


