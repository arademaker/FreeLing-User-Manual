# Install FreeLing Requirements on Linux

## Install development tools {#development-tools}

* Install g++ and related packages.  
   Installing meta-package "build-essential" will do the trick in most distributions.  
   `sudo apt-get install build-essential`  
   Make sure you have a C++11 capable compiler \(e.g. g++ version 4.6 or newer\)

* Install CMake \(3.8 or newer\).  
   `sudo apt-get install cmake`  
   If your distro has a version older than 3.8, do not install it. Instead, download the binary package for linux from [https://cmake.org/download/](https://cmake.org/download/)

## Install dependencies {#dependencies}

Some external libraries are required to compile FreeLing:

* `libboost`, `libicu`, and `libz` libraries. Included in all Linux distributions. You probably do not have all neeeded components installed. You need to install:

  * `libicu`
  * `libboost-regex`
  * `libboost-system`
  * `libboost-thread`
  * `libboost-program-options`
  * `libboost-locale` (only required for MacOSX or FreeBSD, not required in Linux)
  * `zlib`

If you are compiling FreeLing from source, you'll need to install **both** binary and development packages for all the libraries.

#### Orientative package names {#orientative-package-names}

The name of the packages containing the dependencies listed above vary depending on your linux distribution.

Please check the package manager in your system, and use its package search capabilities to install the needed dependencies.

As an orientation, here are the names of these packages in some popular distributions (Note that this may change over time).

* Ubuntu/Debian: `libboost libboost-regex libicu libboost-system libboost-program-options libboost-thread zlib1g`
* OpenSuse/Fedora/Mandriva: `boost boost-regex libicu boost-system boost-program-options boost-thread zlib`
* Slackware: `boost icu4c zlib`

If you are building FreeLing from source, you must install **also** the development packages for each library listed above. Development packages usually have the same name than the binary library, suffixed with `-dev` or `-devel`. 
Most package managers will install both binary and development packages when the `-dev` package is requested. If this is not your case, you'll need to manually select both packages.

