# Installing from binary packages 

This installation procedure is the fastest and easiest. If you do not plan to modify the code, this is the option you should take.

Binary packages are available only for stable FreeLing versions. If you want to install a development version or the provided packages do not match your system, please see section [Installing from source](installation-source.md).

You'll find downloadable binary packages in [GitHub FreeLing Releases page](https://github.com/TALP-UPC/FreeLing/releases).
Packages for several Debian/Ubuntu versions are provided, as well as for MacOS and MS-Windows.

## Install binary package on Linux 

Most debian-based systems will launch the apropriate installer if you just double click on the package file. The installer should solve the dependencies and install all required packages.

If that doesn't work, you can install it by hand (in Ubuntu or Debian) with the following procedure (will probably work for other debian-based distros):

1. Install FreeLing dependencies, as described in section [Install Requirements on Linux](requirements-linux.md#install-dependencies).
2. Install downloaded binary package for your distribution (e.g. Ubuntu bionic, Debian buster, etc)
   ```
   sudo dpkg -i freeling-4.2-bionic-amd64.deb
   ```
3. The main package includes only the linguistic data for English, Spanish, and Portuguese. If you want to process any other of the languages supported by FreeLing, you need to install also the language package
   ```
   sudo dpkg -i freeling-langs-4.2-bionic-amd64.deb
   ```

In a Debian system, the above command must be issued as root and without `sudo`.
  
In other distributions, package names may differ.  You will  find further information in section [Install requirements on Linux](requirements-linux.md#install-dependencies).

After installing, you are ready to use FreeLing. See sections [Test FreeLing Installation on Linux](test-linux.md), [Execute FreeLing demo](../analyzer.md) and [Call FreeLing Library](apis-linux.md) to find out more on how to use FreeLing.
  
## Install binary package on MacOS

Before installing FreeLing, you need to install required dependencies, as described in section [Install Requirements on MacOS](requirements-mac.md#install-dependencies).

Get the pkg file `freeling-4.2-macOSX.pkg` from [GitHub FreeLing Releases page](https://github.com/TALP-UPC/FreeLing/releases), double click on it, and follow the installer indications.

The main package includes only the linguistic data for English, Spanish, and Portuguese. If you want to process any other of the languages supported by FreeLing, you need to install also the language package `freeling-langs-4.2-macOSX.pkg`


## Install binary package on MS-Windows 

Get the zipfile `winfreeling-4.2.zip` from [GitHub FreeLing Releases page](https://github.com/TALP-UPC/FreeLing/releases) and uncompress it in a folder of your choice. Check the README.txt inside the zipfile.

Get the zipfile `winfreeling-4.2-dependencies.zip` and uncompress it in the same folder. Check the README.txt inside the zipfile.

If you want support for languages other than English, Spanish, or Portuguese, get the zipfile `winfreeling-langs-4.2.zip` and uncompress it in the same folder. Check the README.txt inside the zipfile.

After uncompressing, you are ready to use FreeLing. See sections [Test FreeLing Installation on Windows](test-windows.md), [Execute FreeLing demo](../analyzer.md) and [Call FreeLing Library](apis-windows.md) to find out more on how to use FreeLing.


