#!bin/bash

# *
# * =====================================================================================
# *
# *       Filename:  setup.sh 
# *
# *    Description:  This bash script sets up my nominal development environment
# *    on MacOS Big Sur (11.5.2). It requires a network connection to obtain a
# *    package manager and various other utilities. 
# *
# *        Version:  1.0
# *        Created:  12/20/2021 07:46:40
# *       Revision:  none
# *
# *         Author:  NJKR
# *   Organization:  Personal Use 
# *
# * =====================================================================================
# *

set -um; 

# --- permissions 
if [ "$EUID" -ne 0 ]
  then echo "Please run as root... functionality will be limited.";
  ROOT=0; 
else
  ROOT=1; 
fi

# --- network resource locations 
ZSH_URL="https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh"; 
BREW_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"; 

# --- machine details
NODENAME=`uname -n`; 
ARCHITECTURE=`uname -p`; 
OS_RELEASE=`uname -r`; 
OS_NAME=`uname -s`; 
OS_VERSION=`uname -v`; 
HARDWARE_NAME=`uname -m`; 

# --- shell configuration 
echo "Configuring shell..." 
/bin/bash -c "$(curl -fsSL ${ZSH_URL})"

# --- package management (requires sudo)
if [ $ROOT == 1 ]
    then 
        echo "Obtaining package manager..."; 
        /bin/bash -c "$(curl -fsSL ${BREW_URL})"; 
    else 
        echo "Unable to obtain package manager, run as sudo"; 
fi 

# --- neovim 
