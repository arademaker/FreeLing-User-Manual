# Install FreeLing Requirements on MacOS


## Install development tools {#development-tools}

MacOS development tools can be easily installed. Open a terminal, and write the command:
  `xcode-select --install`  
A window will pop-up, where you must click "*Install command-line tools*".

If you need XCode for your developments, you can install it too, but you don't need it if you just want to compile FreeLing

## Install HomeBrew

Some needed tools and libraries can be easily installed using HomeBrew.
Go to https://brew.sh and follow the instructions there to install it.

## Install required HomeBrew packages
    
* Install CMake \(3.8 or newer\):  
  `brew install cmake`  

* Install boost and icu libraries:  
  `brew install boost --with-icu4c`  


