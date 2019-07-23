# Install FreeLing Requirements on Windows

## Install development tools {#development-tools}

* Install MSVC (MS Visual Studio, with C++ compiler)

* Install CMake (3.8 or newer) using installer available at [https://cmake.org/download/](https://cmake.org/download/)

## Install dependencies {#dependencies}

Some external libraries are required to compile FreeLing.
Next sections describe how to install them. Some can be installed from binary packages, others have to be compiled.

***IMPORTANT***:  All sections below assume that you decided where you will install FreeLing  (e.g. `C:\FreeLing`, `C:\Program Files\FreeLing`, etc.) and will install the dependencies in the same place.
 You can install the dependencies anywhere else, but then you'll need to adjust the paths used in this installation guide. See [Install dependencies in a different folder](#dependencies-location) for details.

For short, we will refer to this installation folder as `%FLINSTALL%`.

#### Install ZLIB

1. Download zlib source from [http://www.zlib.net/](http://www.zlib.net/), and unzip the source file somewhere you know where it is.

2. From the start menu, open a "Visual Studio x64 Native Tools Command Prompt" (or "x86" if your system is 32 bits)

3. Change to the folder where you unzipped the source, and execute the commands:
   ```
   mkdir build
   cd build
   cmake .. -DCMAKE_INSTALL_PREFIX=%FLINSTALL%\dependencies\zlib -G "NMake Makefiles"
   nmake install
   ```
  
#### Install Boost and ICU

The easiest way to install these dependencies is to get precompiled binary packages.

* Get boost binaries from: [https://www.npcglib.org/~stathis/blog/precompiled-boost/](https://www.npcglib.org/~stathis/blog/precompiled-boost/)
  Select a package that matches your MSVC version (2014, 2015, ...) and architecture (32/64 bits)

* Uncompress boost packages in `%FLINSTALL%\dependencies`

* Each boost binary package has associated an ICU version, which is mentioned in the rightmost column of the table ("Notes") in the *precompiled-boost* webpage.
  Follow the link to the associated ICU version, and download the package.  Make sure you are getting the right version (you may need to go to "past builds" page [https://www.npcglib.org/~stathis/blog/precompiled-icu-past/](https://www.npcglib.org/~stathis/blog/precompiled-icu-past/) to find it).
  Also, make sure the package matches your MSVC version and architecture.
    
* Uncompress icu package in `%FLINSTALL%\dependencies`.

After this, the content of your `%FLINSTALL%` folder should look like (version numbers may differ):
```
   %FLINSTALL%\dependencies\zlib
              \boost64-1.61.0-vs2015
              \icu-57.1-vs2015
```

You can keep these names or change them to "boost" and "icu". 
From now on we will assume you changed them, so if you keep the full names, you'll need to change some paths in the commands described in further steps.
Now your installation folder looks like:
```
   %FLINSTALL%\dependencies\zlib
                           \boost
                           \icu
```

Now you can continue to section [Install from source on Windows](installation-windows.md).



## Installing dependencies in a different folder {#dependencies-location}

You can install zlib, boost, and icu anywhere (that is, they don't *have* to be in `%FLINSTALL%\dependencies`).

If you install them somewhere else, you'll need to set the right paths for variables `ZLIB_INCLUDE_DIR`, `ZLIB_LIBRARY`, `BOOST_ROOT`, and `ICU_ROOT`  in the `CMake` command in the procedure described in [Install from source on Windows](installation-windows.md), as well as adjusting the `%PATH%` definition if you plan to use an API (see [Building and using APIs on Windows](apis-windows.md) for details).

Also, if you plan to use the `analyzer.bat` script, you'll need to edit it and adjust the paths to those libraries too.

