# Getting it to work {#getting-it-to-work}

This chapter describes how to install and execute FreeLing. The setps to follow may be differnt depending on your needs and platform.

* [Requirements](#requirements)
* Installation
   * [Install from <tt>.deb</tt> binary packages](#install-from-deb-binary-packages)
   * [Install from <tt>.tar.gz</tt> source packages](#install-from-tar-gz-source-packages)
   * [Install from <tt>GitHub</tt> repositories](#install-from-github-repositories)
* [Reducing needed disk space](#reducing-disk)
* [Locale-related problems when installing](#locale-related-problems-when-installing)
* [Installing on MacOS](#installing-on-macos)
* [Executing](#executing)
* [Porting to other platforms](#porting-to-other-platforms)
* [APIs for languages other than C++](#apis-other-languages)


## Requirements {#requirements}

To install FreeLing you'll need:

*   A typical Linux box with usual development tools:
    *   bash
    *   make
    *   C++ compiler with STL and C++11 support (e.g. g++ 4.6 or newer)
*   Enough hard disk space -about 3 Gb for source and temporary compilation files (which you can delete later if needed), plus some 1.1Gb for final installation.
*   Some external libraries are required to compile FreeLing:
    *   <tt>libboost</tt> & <tt>libicu</tt> libraries. Included in all Linux distributions. You probably do not have all neeeded components installed. Make sure to install both runtime and development packages for:
        *   libicu
        *   libboost-regex
        *   libboost-system
        *   libboost-thread
        *   libboost-program-options
        *   libboost-locale (only required for MacOSX or FreeBSD, not required in Linux)
    *   <tt>libz</tt> compression library. Included in all Linux distributions. You probably do not have all neeeded components installed. Make sure to install both runtime and development packages for:
        *   zlib

### Orientative package names {#orientative-package-names}

The name of the packages containing the dependencies listed above vary depending on your linux distribution.

Please check the package manager in your system, and use its package search capabilities to install the needed dependencies.

As an orientation, here are the names of these packages in some popular distributions. (Note that this may change over time too)

*   Ubuntu/Debian: `libboost-dev libboost-regex-dev libicu-dev libboost-system-dev libboost-program-options-dev libboost-thread-dev zlib1g-dev`
*   OpenSuse/Fedora/Mandriva: `boost-devel boost-regex-devel libicu-devel boost-system-devel boost-program-options-devel boost-thread-dev zlib-devel`
*   Slackware: `boost icu4c zlib`

Note that you need to install both the binary libraries and the development packages (usually sufixed as `-dev` or `-devel`). Most package managers will install both binary and development packages when the `-dev` package is required. If this is not your case, you'll need to manually select both packages.

See details on the installation procedure in section [Installation](#installation).

## Installation {#installation}

This section provides a detailed guide on different options to install FreeLing (and all its required packages).

### Install from <tt>.deb</tt> binary packages {#install-from-deb-binary-packages}

This installation procedure is the fastest and easiest. If you do not plan to modify the code, this is the option you should take.

Binary packages are available only for stable FreeLing versions. If you want to install an alpha or beta version, please see section about [installing from GitHub](#install-from-github-repositories).

The provided packages will only work on debian-based distributions. They have been tested in Ubuntu (12.04-LTS Precise, 14.04-LTS Trusty, 16.04-LTS Xenial) and Debian (7.0 Wheezy, 8.3 Jessy, 9.0 Strecht).

Most debian-based systems will launch the apropriate installer if you just double click on the package file. The installer should solve the dependencies and install all required packages.

If that doesn't work, you can install it by hand (in Ubuntu or Debian) with the following procedure (will probably work for other debian-based distros):

1.  Install required system libraries.
  
    The following commands should install *both* header packages and binary libraries. If they don't, use your package manager to install all required packages as described in section [Requirements](#orientative-package-names).    
    `sudo apt-get install libboost-regex-dev libicu-dev zlib1g-dev`    
    `sudo apt-get install libboost-system-dev libboost-program-options-dev libboost-thread-dev`

*   Install freeling package  
    `sudo dpkg -i freeling-4.0.deb`

    In a Debian system, the above commands must be issued as root and without `sudo`.

### Install from <tt>.tar.gz</tt> source packages {#install-from-tar-gz-source-packages}

Installation from source follows standard GNU autoconfigure installation procedures (that is, the usual `./configure && make && make install` stuff).

Installing from source is slower and harder, but it will work in any Linux box, even if you have library versions different than those required by the <tt>.deb</tt> package.

1.  Install development tools

    You'll need to install the C++ compiler and other developer tools:  
    `sudo apt-get install build-essential automake autoconf libtool`

    In Debian, use the same command as root, without `sudo`. In other distributions, check the distribution package manager to install a working C++ compiler and autotools.

*  Install packaged requirements

    All required libraries are standard packages in all Linux distributions. Just open your favorite software package manager and install them.

    Package names may vary slightly in different distributions. See section [Requirements](#orientative-package-names) for some hints on possible package names.

    As an example, commands to install the packages from command line in Ubuntu and Debian are provided, though you can do the same using synaptic, or aptitude. If you have another distribution, use your package manager to locate and install the appropriate library packages.

    Both in Debian and in Ubuntu you need to do:  
    `sudo apt-get install libboost-regex-dev libicu-dev zlib1g-dev`  
    `sudo apt-get install libboost-system-dev libboost-program-options-dev`

*   Download and Install FreeLing

    Download source package `freeling-4.0.tar.gz` from FreeLing webpage download section, and then execute:          
    `tar xzvf freeling-4.0.tar.gz`  
    `cd freeling-4.0`  
    `autoreconf --install`  
    `./configure`  
    `make`  
    `sudo make install`

    FreeLing library is entirely contained in the file `libfreeling.so` installed in `/usr/local/lib` by default.

    Sample program `analyze` is installed in `/usr/local/bin`. See chapter about [`analyzer`](#using-the-sample-main-program-to-process-corpora) for details.

    See `./configure --help` for options about installing in non-default directories or disabling some FreeLing options.

### Install from <tt>GitHub</tt> repositories {#install-from-github-repositories}

Installing from GitHub is very similar to installing from source, but you'll have the chance to easily update your FreeLing to the latest development version.

1.  Install development tools

    You'll need to install the C++ compiler, the GNU autotools, plus a <tt>git</tt> client.  
    `sudo apt-get install build-essential automake autoconf libtool git`

    If you use a distribution different than Debian or Ubuntu, these packages may have different names. Use your package manager to locate and install the appropriate ones.

*  Install packaged requirements

    Follow the same procedure described in section about [Source Installation](#install-from-tar-gz-source-packages) for this step.

*   Checkout FreeLing sources

   If you want the latest development version, do:  
    `git clone https://github.com/TALP-UPC/FreeLing.git mysrc`

    (you can replace `mysrc` with the directory name of your choice).

    If you want a previous release, after cloning the repository with the above command, you can checkout any previous tagged version with something like:  
    `git checkout -b mybranch-v4 4.0-beta1`

    (that will create a new branch `mybranch-v4` in your local repository that will contain the version tagged as `4.0-beta1` in GitHub).

    You can find out the available tags at [https://github.com/TALP-UPC/freeling](https://github.com/TALP-UPC/freeling).

    Versions older than 4.0 are available at the [old SVN repository](http://devel.cpl.upc.edu/freeling/svn/versions)
    
*   Prepare local repositories for compilation  
     `cd mysrc`  
     `autoreconf --install`  

*   Build and install FreeLing  
    `./configure`  
    `make`  
    `sudo make install`

If you keep the source directories, you will be able to update to newer versions at any moment with:  
 `cd mysrc`  
 `git pull`  
 `./configure`  
 `make`
 `sudo make install`

Depending on what changed in the repository, you may need to issue `autoreconf --install` after `git pull`. You may also need to issue `make distclean` and repeat the process from `./configure` onwards.

## Reducing needed disk space {#reducing-disk}

FreeLing packages include linguistic data for all supported languages, which total up over 1Gb of disk space.

It is possible to safely remove data for languages that are not needed, saving that space.

* If installing from a `.deb` package, you can simply remove the unneeded language directories from `/usr/share/freeling/XX`. Make sure to keep 
`/usr/share/freeling/common`, `/usr/share/freeling/config`, and `/usr/share/freeling/XX` for any language XX you want to process.

* If installing from source (either from source package or from git repository) you can remove the unneeded data after installing, but it may be easier to remove it from source:
     * Remove the directories `data/XX` for any unneeded language. Make sure to keep directories `data/common`, `data/config`, and `data/XX` for any language XX you want to process.
     * After removing the unneeded directories, install normaly.


## Locale-related problems when installing {#locale-related-problems-when-installing}

If you get an error about <tt>bad locale</tt> when you enter `make install` or when you try to execute the `analyzer` sample program, you probably need to generate some locales in your system.

FreeLing uses <tt>en_US.UTF8</tt> locale as default during installation. If this locale is not installed in your system, you'll get an error during dictionary installation.

all languages in FreeLing should work with this locale, though Russian may need to have its own locale installed in the system.

The procedure to install a locale in your system varies depending on your distribution. For instance:

*   In Ubuntu, you must use the `locale-get` command. E.g.:   
    `sudo locale-gen en_US.UTF8`  
    `sudo locale-gen pt_BR.UTF8`  
    `sudo locale-gen ru_RU.UTF8`   
    `...`
    
*   In Debian, you need to run the command:   
    `dpkg-reconfigure locales`   
    and select the desired locales from the list.

## Installing on MacOS {#installing-on-macos}

Installing on MacOS is very similar to installing on Linux. The main difference is how to install the dependencies and required development tools, which is greatly eased by MacPorts or Homebrew (you only need one of them, not both).

### Install Apple development tools

First of all, you need to install XCode to be able to compile in MacOS:
    * Download and install `XCode` from Apple AppStore
    * Configure it with: 
           sudo xcodebuild -license 
           sudo xcode-select --install

### Get FreeLing source code

Then, you need to get FreeLing source, either from a tar file or from GitHub.

##### Getting source from tar.gz file
*   Download source package `freeling-4.0.tar.gz` from FreeLing webpage download section, and then execute:  
        tar xzvf freeling-4.0.tar.gz
        cd freeling-4.0
    
##### Getting source from GitHub repository
*   Clone latest development version (to clone other stable versions, see section [Install from <tt>GitHub</tt> repositories](#install-from-github-repositories)):
         git clone https://github.com/TALP-UPC/FreeLing.git freeling-4.0
         cd freeling-4.0

### Install using Homebrew
 
*   Download and install [Homebrew](http://brew.sh) if you don't have it already.

*   Use Homebrew to install required developer tools:  
    `brew install automake`
    `brew install autoconf`
    `brew install libtool`
    `brew install boost —with-icu4c`

*   Build and install FreeLing  
    `./configure CPPFLAGS="-I/usr/local/opt/icu4c/include" LDFLAGS="-L/usr/local/opt/icu4c/lib"`
    `make`  
    `sudo make install`

    You can add to `configure` any extra options you wish (`-enable-traces`, `-prefix`, etc). Use `./configure --help` to find out available options.

### Install using MacPorts

*   Install `MacPorts` if you don't have it already
    * Download and install [MacPorts](http://www.macports.org/install.php)
    * Update and configure:  
          sudo port -v selfupdate

*   Use MacPorts to install required developer tools:  
    `sudo port install automake`  
    `sudo port install autoconf`  
    `sudo port install libtool`  
    `sudo port install git`

*   Use MacPorts to install required dependencies:  
    `sudo port install boost`

    This will install also `libicu` and `zlib`. If configure below complains about it not being there, you can install it with `sudo port install zlib`.

*   Build and install FreeLing  
    `./configure CPPFLAGS="-I/opt/local/include" LDFLAGS="-L/opt/local/lib"`
    `make`  
    `sudo make install`

    You can add to `configure` any extra options you wish (`-enable-traces`, `-prefix`, etc). Use `./configure --help` to find out available options.

## Executing {#executing}

FreeLing is a library, which means that it not a final-user oriented executable program but a tool to develop new programs that require linguistic analysis services.

Nevertheless, a sample main program is included in the package for those who just want a text analyzer. This program may be adapted to fit your needs up to certain point (e.g. customized input/output formats, desired level of analysis) but very specific adaptations will require that you write your own main program, or adapt one of the existing examples.

The usage and options of this main program is described in [this chapter](#using-the-sample-main-program-to-process-corpora).

Please take into account that this program is only a friendly interface to demonstrate FreeLing abilities, but that there are many other potential usages of FreeLing.

Thus, the question is not *why this program doesn't offer functionality X?*, *why it doesn't output information Y?*, or *why it doesn't present results in format Z?*, but *How should I use FreeLing library to write a program that does exactly what I need?*.

In the directory `src/main/simple_examples` in the tarball, you can find simpler sample programs that illustrate how to call the library, and that can be used as a starting point to develop your own application.

## Porting to other platforms {#porting-to-other-platforms}

FreeLing library is entirely written in C++, so it is possible to compile it on non-unix platforms with a reasonable effort.

FreeLing can be successfully built for MacOS, as described above.

It can also be built for MS-Windows using project files included in the tarball. You'll find the solution/project files and a README in the `msvc` folder inside FreeLing tarball.
Binary packages for Windows can be found in [GitHub FreeLing Releases page](https://github.com/TALP-UPC/FreeLing/releases).

You can visit the [Forum](http://nlp.lsi.upc.edu/freeling/forum) in FreeLing webpage for further help and details.

## APIs for languages other than C++ {#apis-other-languages}

To call FreeLing library from a language different than C++ you will need to build the appropriate API.

FreeLing source includes APIs for Java, Python, perl, ruby, and PHP. A [Dockerfile](https://www.docker.com/) can also be found in the same subdirectory.

APIs are generated using [SWIG](http://www.swig.org). The completeness of the API varies from one language to another depending on the coverage of SWIG for STL structures in that language. Java and python APIs are almost fully-functional. Perl is a little behind, and ruby and PHP are experimental.

To build your API, first you need to install SWIG. Then, check the subdirectory `APIs` in FreeLing source. If you installed FreeLing from a binary package, make sure you get the source package corresponding to the same version you installed.

Each API has a `README` file, a `Makefile`, and a sample program to test it.  Follow the README instructions to build the API.

MacOS users may need to slightly adapt the Makefile.
Windows users will need to replicate the Makefile steps by hand.





