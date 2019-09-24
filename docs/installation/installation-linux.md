# Install from source on Linux

This section assumes you already downloaded and uncompressed FreeLing sources in a folder of your choice.
If not, please read Section [Installing from source](installation-source.md) before continuing.

It also assumes you installed development tools and FreeLing dependencies. 
If not, please read Section [Install FreeLing Requirements on Linux](requirements-linux.md)

Finally, it assumes you know where you want to install FreeLing (e.g. `/home/user/freeling`, `/home/user/programs/freeling`). You can omit this, and FreeLing will be installed in the default location `/usr/local`.
***IMPORTANT***: From this point on, we will refer to FreeLing installation folder (either chosen by you or the default location) as `$FLINSTALL`.

## Build FreeLing

* Open a terminal and change to the folder where you uncompressed or cloned the downloaded FreeLing source.

* Execute the commands:  
  ```
  mkdir build
  cd build
  cmake .. 
  make install
  ```
  This will install FreeLing in `/usr/local`.  
  
You can speed up compilation using several processors with, e.g.,  `make -j 4 install` (you can replace `4` with the number of processors you want to use).
  
To change the destination directory, add option `-DCMAKE_INSTALL_PREFIX=$FLINSTALL` to the `cmake` command (where `$FLINSTALL` is the path where you want to install FreeLing).

Note that cmake does not create an "uninstall" target. So, if you install in `/usr/local`, you may need to selectively remove files when you want to uninstall FreeLing.

If you installed in a custom folder and want a clean re-install, you can delete folder `$FLINSTALL` (be careful if it is  `/usr/local`, there may be other software installed there), and run `make install` again from the `build` folder.

If you want a clean re-build, you can delete the `build` folder, and repeat the  whole procedure.

Available options that can be added to the `cmake` command:

| Option  | Effect  |
| :---    | :---    |
|`-DCMAKE_INSTALL_PREFIX=<path>`| Install FreeLing in given location (default: `/usr/local`) |
|`-DTRACES=ON`      | Build FreeLing with debugging traces (default: `OFF`) |
|`-DWARNINGS=OFF`   | Build FreeLing without warning messages (default: `ON`)|
|`-DXPRESSIVE=ON`   |  Build FreeLing using boost::xpressive regexps instead of boost::regex (default: `OFF`) |
|`-DEMBEDDINGS=ON`  | Download word embeddings files when installing (default: `OFF`). Warning: Adds 2Gb to required installation space. |
| `-DJAVA_API=ON`   | Build Java API (default: `OFF`. See [Building and using APIs on Linux](apis-linux.md) for details). |
|`-DPYTHON2_API=ON` | Build Python 2 API (default: `OFF`. See [Building and using APIs on Linux](apis-linux.md) for details).|
|`-DPYTHON3_API=ON` | Build Python 3 API (default: `OFF`. See [Building and using APIs on Linux](apis-linux.md) for details).|

## Test FreeLing
After installing, you are ready to use FreeLing. See sections [Test FreeLing Installation on Linux](test-linux.md), [Execute FreeLing demo](#analyzer.md) and [Call FreeLing Library](apis-linux.md) to find out more on how to use FreeLing.     


## Locale-related problems when installing

If you get an error about `bad locale` when you enter `make install` or when you try to execute the `analyzer` sample program, you probably need to generate some locales in your system.

FreeLing uses `en_US.UTF8` locale as default during installation. If this locale is not installed in your system, you'll get an error during dictionary installation.

all languages in FreeLing should work with this locale, though Russian may need to have its own locale installed in the system.

The procedure to install a locale in your system varies depending on your distribution. For instance:

* In Ubuntu, you must use the `locale-get` command. E.g.:  
  `sudo locale-gen en_US.UTF8`  
  `sudo locale-gen pt_BR.UTF8`  
  `sudo locale-gen ru_RU.UTF8`  
  `...`

* In Debian, you need to run the command:  
  `dpkg-reconfigure locales`  
  and select the desired locales from the list.

## Test FreeLing
After installing, you are ready to use FreeLing. See sections [Test FreeLing Installation on Linux](test-linux.md), [Execute FreeLing demo](../analyzer.md) and [Call FreeLing Library](apis-linux.md) to find out more on how to use FreeLing.     

