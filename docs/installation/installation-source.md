# Installing from source 

Unless you have a special interest in compiling FreeLing, [installing it from a binary package](installation-packages.md) is recommended.

Installing FreeLing from source makes sense only in one of the following cases:
  - Provided packages are not installable in your distribution.
  - You want to use a development FreeLing version for which there is no binary package yet.
  - You want to modify or extend FreeLing.
  
To install from source, you need to follow three steps:

1. Download FreeLing source:
   This step is the same for all systems, and can be performed in two ways:
   
    * Go to [GitHub FreeLing Releases page](https://github.com/TALP-UPC/FreeLing/releases), download the source package (e.g. `FreeLing-4.2.tar.gz` or `FreeLing-4.2.zip`) and uncompress it in a folder of your choice.
    
    * Alternatively, clone FreeLing GitHub repository (either a stable version tag such as "v4.2", or the development version "master"). If you don't know what a git repository is, you probably should stick with the first option above.

    * The base package includes language data only for English, Spanish, and Portuguese. If you want to use another of the languages supported by FreeLing, dowload also the language file or `FreeLing-langs-4.2.tar.gz` or `FreeLing-langs-4.2.zip` and uncompres it **on the same folder than the main package**.

2. Install development tools and FreeLing dependencies:

    * [Install requirements on Linux](requirements-linux.md)
    * [Install requirements on Windows](requirements-windows.md)
    * [Install requirements on MacOS](requirements-mac.md)
    
3. Build FreeLing

    * [Build FreeLing on Linux](installation-linux.md)
    * [Build FreeLing on Windows](installation-windows.md)
    * [Build FreeLing on MacOS](installation-mac.md)


