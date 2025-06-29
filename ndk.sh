cd $HOME
echo
echo "${green}━━━ Starting NDK installation ━━━${nocolor}"
echo "Now You'll be asked about which version of NDK to install"
echo "${note}If your Android Version is 9 or above then choose ${red}'9'${nocolor}"
echo "${note}If your Android Version is below 9 or if you faced issues with '9' (A9 and above users) then choose ${red}'8'${nocolor}"
echo "${red} If you're choosing other options then you're on your own and experiment yourself ¯⁠\⁠_⁠ಠ⁠_⁠ಠ⁠_⁠/⁠¯${nocolor}"

# Create $HOME directory if it doesn't exist
mkdir -p "$HOME"

if [ -f "ndk-install.sh" ]; then
  chmod +x ndk-install.sh && bash ndk-install.sh
else
  # Retry logic for wget with proper error handling
  if ! wget https://github.com/MrIkso/AndroidIDE-NDK/raw/main/ndk-install.sh --no-verbose --show-progress -N; then
    echo "${red}Failed to download ndk-install.sh, retrying...${nocolor}"
    sleep 2
    if ! wget https://github.com/MrIkso/AndroidIDE-NDK/raw/main/ndk-install.sh --no-verbose --show-progress -N; then
      echo "${red}Error: Could not download NDK installer${nocolor}"
      exit 1
    fi
  fi
  
  # Verify the file was downloaded
  if [ ! -f "ndk-install.sh" ]; then
    echo "${red}Error: NDK installer download failed${nocolor}"
    exit 1
  fi
  
  chmod +x ndk-install.sh && bash ndk-install.sh
fi

# Cleanup only if file exists
if [ -f "ndk-install.sh" ]; then
  rm ndk-install.sh
fi

if [ -d "$HOME/android-sdk/ndk/17.2.4988734" ]; then
  ndk_version="17.2.4988734"
elif [ -d "$HOME/android-sdk/ndk/18.1.5063045" ]; then
  ndk_version="18.1.5063045"
elif [ -d "$HOME/android-sdk/ndk/19.2.5345600" ]; then
  ndk_version="19.2.5345600"
elif [ -d "$HOME/android-sdk/ndk/20.1.5948944" ]; then
  ndk_version="20.1.5948944"
elif [ -d "$HOME/android-sdk/ndk/21.4.7075529" ]; then
  ndk_version="21.4.7075529"
elif [ -d "$HOME/android-sdk/ndk/22.1.7171670" ]; then
  ndk_version="22.1.7171670"
elif [ -d "$HOME/android-sdk/ndk/23.2.8568313" ]; then
  ndk_version="23.2.8568313"
elif [ -d "$HOME/android-sdk/ndk/24.0.8215888" ]; then
  ndk_version="24.0.8215888"
elif [ -d "$HOME/android-sdk/ndk/26.1.10909125" ]; then
  ndk_version="26.1.10909125"
elif [ -d "$HOME/android-sdk/ndk/27.1.12297006" ]; then
  ndk_version="27.1.12297006"
else
  echo "${red}You didn't Installed any ndk terminating!"
  exit 1
fi
echo "${yellow}ANDROID NDK Successfully Installed!${nocolor}"

cd $HOME
echo
echo "${green}━━━ Setting up apktool ━━━${nocolor}"
if [ -f "$PREFIX/bin/apktool.jar" ]; then
  echo "${blue}apktool is already installed${nocolor}"
else
  sh -c 'wget https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.10.0.jar -O $PREFIX/bin/apktool.jar'

  chmod +r $PREFIX/bin/apktool.jar

  sh -c 'wget https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool -O $PREFIX/bin/apktool' && chmod +x $PREFIX/bin/apktool || exit 2
fi

cd $HOME
if [ -d "BT4-Dex2c" ]; then
  cd BT4-Dex2c
elif [ -f "dcc.py" ] && [ -d "tools" ]; then
  :
else
  git clone https://github.com/BT4Team/BT4-Dex2c || exit 2
  cd BT4-Dex2c || exit 2
fi

if [ -f "$HOME/BT4-Dex2c/tools/apktool.jar" ]; then
  rm $HOME/BT4-Dex2c/tools/apktool.jar
  cp $PREFIX/bin/apktool.jar $HOME/BT4-Dex2c/tools/apktool.jar
else
  sh -c 'wget https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.10.0.jar -O $HOME/BT4-Dex2c/tools/apktool.jar'
fi

cd ~/BT4-Dex2c
python3 -m pip install -r needed.txt || exit 2

if [ -f "$HOME/.bashrc" ]; then
  echo -e "export ANDROID_HOME=$HOME/android-sdk\nexport PATH=\$PATH:$HOME/android-sdk/cmdline-tools/latest/bin\nexport PATH=\$PATH:$HOME/android-sdk/platform-tools\nexport PATH=\$PATH:$HOME/android-sdk/build-tools/34.0.4\nexport PATH=\$PATH:$HOME/android-sdk/ndk/$ndk_version\nexport ANDROID_NDK_ROOT=$HOME/android-sdk/ndk/$ndk_version" >> ~/.bashrc
elif [ -f "$HOME/.zshrc" ]; then
  echo -e "export ANDROID_HOME=$HOME/android-sdk\nexport PATH=\$PATH:$HOME/android-sdk/cmdline-tools/latest/bin\nexport PATH=\$PATH:$HOME/android-sdk/platform-tools\nexport PATH=\$PATH:$HOME/android-sdk/build-tools/34.0.4\nexport PATH=\$PATH:$HOME/android-sdk/ndk/$ndk_version\nexport ANDROID_NDK_ROOT=$HOME/android-sdk/ndk/$ndk_version" >> ~/.zshrc
else
  echo -e "export ANDROID_HOME=$HOME/android-sdk\nexport PATH=\$PATH:$HOME/android-sdk/cmdline-tools/latest/bin\nexport PATH=\$PATH:$HOME/android-sdk/platform-tools\nexport PATH=\$PATH:$HOME/android-sdk/build-tools/34.0.4\nexport PATH=\$PATH:$HOME/android-sdk/ndk/$ndk_version\nexport ANDROID_NDK_ROOT=$HOME/android-sdk/ndk/$ndk_version" >> $PREFIX/etc/bash.bashrc
fi

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

echo "${green}============================"
echo "Great! Dex2c Installed Successfully!"
echo "============================${nocolor}"
