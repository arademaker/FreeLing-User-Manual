# Installing from binary packages {#install-from-binary-packages}

This installation procedure is the fastest and easiest. If you do not plan to modify the code, this is the option you should take.

Binary packages are available only for stable FreeLing versions. If you want to install a development version or the provided packages do not match your system, please see section [Installing from source](installation-source.md).

You'll find downloadable binary packages in [GitHub FreeLing Releases page](https://github.com/TALP-UPC/FreeLing/releases).
Packages for several Debian/Ubuntu versions are provided, as well as for MS-Windows.

## Install binary package on Linux {#install-package-linux}

Most debian-based systems will launch the apropriate installer if you just double click on the package file. The installer should solve the dependencies and install all required packages.

If that doesn't work, you can install it by hand (in Ubuntu or Debian) with the following procedure (will probably work for other debian-based distros):

1. Install FreeLing dependencies, as described in section [Install Requirements on Linux](requirements-linux.md#dependencies).

2. Install downloaded binary package
   ```
   sudo dpkg -i FreeLing-4.1.deb
   ```

In a Debian system, the above command must be issued as root and without `sudo`.
  
In other distributions, package names may differ.  You will  find further information in section [Install requirements on Linux](requirements-linux.md#dependencies).

After installing, you are ready to use FreeLing. See sections [Test FreeLing Installation on Linux](test-linux.md), [Execute FreeLing demo](#analyzer.md) and [Call FreeLing Library](apis-linux.md) to find out more on how to use FreeLing.        
  
## Install binary package on MS-Windows {#install-package-windows}

Get the zipfile `freeling-4.1-win.zip` from [GitHub FreeLing Releases page](https://github.com/TALP-UPC/FreeLing/releases) and uncompress it in a folder of your choice.

The zipfile already includes all third-party dependencies required by FreeLing (if you are curious you can find out how to install them yourself in section [Install from source on Windows](installation-windows.md) ).

After uncompressing, you are ready to use FreeLing. See sections [Test FreeLing Installation on Windows](test-windows.md), [Execute FreeLing demo](analyzer.md) and [Call FreeLing Library](apis-windows.md) to find out more on how to use FreeLing.


