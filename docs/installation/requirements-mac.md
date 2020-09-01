# Install FreeLing Requirements on MacOS

## Install HomeBrew

Some needed tools and libraries can be easily installed using HomeBrew.
Go to https://brew.sh and follow the instructions there to install it.

## Install required HomeBrew packages
    
* Install boost and icu libraries:  
  `brew install boost icu4c`  

## Languages other than C++

  If you plan to call FreeLing from a language other than C++, such as python, perl, or Java, make sure you have installed the development libraries for that language:

  `brew install python3`  
  `brew install perl`  
  (and/or install your preferred Java JDK with JNI support)


## If you plan to compile FreeLing from source:

* Install CMake \(3.8 or newer\):  
  `brew install cmake`  

* Make sure clang is installed, either via XCode or via homebrew.

## If you plan to build from source FreeLing APIs to non-C++ languages:

* Install SWIG:
  `brew install swig`  

