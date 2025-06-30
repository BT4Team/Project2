#!/bin/bash

# Colors
green='\033[1;32m'
yellow='\033[1;33m'
red='\033[1;31m'
blue='\033[1;34m'
nocolor='\033[0m'

cd $HOME
echo
echo -e "${green}━━━ Starting NDK installation ━━━${nocolor}"
echo "Installing NDK version 21.4.7075529 directly"

# Create directories if they don't exist
mkdir -p "$HOME/android-sdk/ndk"

# Download NDK 21
echo -e "${yellow}Downloading NDK 21.4.7075529...${nocolor}"
ndk_url="https://dl.google.com/android/repository/android-ndk-r21e-linux-x86_64.zip"
ndk_zip="$HOME/android-ndk-r21e-linux-x86_64.zip"

# Try multiple download methods
download_success=false

if command -v wget &> /dev/null; then
    echo "Trying wget..."
    if wget "$ndk_url" -O "$ndk_zip" --no-verbose --show-progress; then
        download_success=true
    else
        echo -e "${red}wget failed, trying curl...${nocolor}"
        rm -f "$ndk_zip"
    fi
fi

if [ "$download_success" = false ] && command -v curl &> /dev/null; then
    echo "Trying curl..."
    if curl -L "$ndk_url" -o "$ndk_zip" --progress-bar; then
        download_success=true
    else
        echo -e "${red}curl failed${nocolor}"
        rm -f "$ndk_zip"
    fi
fi

if [ "$download_success" = false ]; then
    echo -e "${red}Error: Could not download NDK 21 using either wget or curl${nocolor}"
    echo -e "${yellow}Please try one of these solutions:${nocolor}"
    echo "1. Make sure you have a stable internet connection"
    echo "2. Try installing wget or curl first: pkg install wget curl"
    echo "3. Download the file manually from:"
    echo "   https://dl.google.com/android/repository/android-ndk-r21e-linux-x86_64.zip"
    echo "   Then place it in $HOME and run the script again"
    exit 1
fi

# Verify the download
if [ ! -f "$ndk_zip" ]; then
    echo -e "${red}Error: NDK download failed - file not found${nocolor}"
    exit 1
fi

file_size=$(stat -c%s "$ndk_zip")
if [ "$file_size" -lt 100000000 ]; then  # Check if file is too small (likely incomplete)
    echo -e "${red}Error: Downloaded file seems too small (might be incomplete)${nocolor}"
    rm -f "$ndk_zip"
    exit 1
fi

# Extract NDK
echo -e "${yellow}Extracting NDK...${nocolor}"
if ! unzip -q "$ndk_zip" -d "$HOME/android-sdk/ndk"; then
    echo -e "${red}Error: Failed to extract NDK${nocolor}"
    rm -f "$ndk_zip"
    exit 1
fi

mv "$HOME/android-sdk/ndk/android-ndk-r21e" "$HOME/android-sdk/ndk/21.4.7075529"

# Clean up
rm -f "$ndk_zip"

ndk_version="21.4.7075529"
echo -e "${yellow}ANDROID NDK Successfully Installed!${nocolor}"

# Rest of your original script continues here...
echo -e "${green}━━━ Setting up apktool ━━━${nocolor}"
if [ -f "$PREFIX/bin/apktool.jar" ]; then
  echo -e "${blue}apktool is already installed${nocolor}"
else
  if ! wget https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.10.0.jar -O $PREFIX/bin/apktool.jar; then
      echo -e "${red}Failed to download apktool.jar${nocolor}"
      exit 2
  fi

  chmod +r $PREFIX/bin/apktool.jar

  if ! wget https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool -O $PREFIX/bin/apktool; then
      echo -e "${red}Failed to download apktool script${nocolor}"
      exit 2
  fi
  chmod +x $PREFIX/bin/apktool
fi

cd $HOME
if [ -d "BT4-Dex2c" ]; then
  cd BT4-Dex2c
elif [ -f "dcc.py" ] && [ -d "tools" ]; then
  :
else
  if ! git clone https://github.com/BT4Team/BT4-Dex2c; then
      echo -e "${red}Failed to clone BT4-Dex2c repository${nocolor}"
      exit 2
  fi
  cd BT4-Dex2c || exit 2
fi

if [ -f "$HOME/BT4-Dex2c/tools/apktool.jar" ]; then
  rm $HOME/BT4-Dex2c/tools/apktool.jar
  cp $PREFIX/bin/apktool.jar $HOME/BT4-Dex2c/tools/apktool.jar
else
  if ! wget https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.10.0.jar -O $HOME/BT4-Dex2c/tools/apktool.jar; then
      echo -e "${red}Failed to download apktool.jar for BT4-Dex2c${nocolor}"
      exit 2
  fi
fi

cd ~/BT4-Dex2c
if ! python3 -m pip install -r needed.txt; then
  echo -e "${red}Failed to install Python dependencies${nocolor}"
  exit 2
fi

# Add to shell rc
ndk_path_export="export ANDROID_HOME=$HOME/android-sdk\nexport PATH=\$PATH:$HOME/android-sdk/cmdline-tools/latest/bin\nexport PATH=\$PATH:$HOME/android-sdk/platform-tools\nexport PATH=\$PATH:$HOME/android-sdk/build-tools/34.0.4\nexport PATH=\$PATH:$HOME/android-sdk/ndk/$ndk_version\nexport ANDROID_NDK_ROOT=$HOME/android-sdk/ndk/$ndk_version"

if [ -f "$HOME/.bashrc" ]; then
  if ! grep -q "ANDROID_NDK_ROOT" "$HOME/.bashrc"; then
      echo -e "$ndk_path_export" >> ~/.bashrc
  fi
elif [ -f "$HOME/.zshrc" ]; then
  if ! grep -q "ANDROID_NDK_ROOT" "$HOME/.zshrc"; then
      echo -e "$ndk_path_export" >> ~/.zshrc
  fi
else
  if ! grep -q "ANDROID_NDK_ROOT" "$PREFIX/etc/bash.bashrc"; then
      echo -e "$ndk_path_export" >> $PREFIX/etc/bash.bashrc
  fi
fi

# Create dcc.cfg
cat > $HOME/BT4-Dex2c/dcc.cfg << EOL
{
    "apktool": "tools/apktool.jar",
    "ndk_dir": "$HOME/android-sdk/ndk/${ndk_version}",
    "signature": {
        "keystore_path": "keystore/debug.keystore",
        "alias": "BT4Team",
        "keystore_pass": "Dex2c@BT4",
        "store_pass": "Dex2c@BT4",
        "v1_enabled": true,
        "v2_enabled": true,
        "v3_enabled": true
    }
}
EOL

echo -e "${green}============================"
echo "Great! Dex2c Installed Successfully!"
echo -e "============================${nocolor}"