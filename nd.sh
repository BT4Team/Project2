cd $HOME
echo
echo "${green}━━━ Starting NDK installation ━━━${nocolor}"
echo "Installing NDK version 21.4.7075529 directly"

# Create $HOME directory if it doesn't exist
mkdir -p "$HOME"

# Create android-sdk directory if it doesn't exist
mkdir -p "$HOME/android-sdk/ndk"

# Download and extract NDK 21 directly
echo "${yellow}Downloading NDK 21.4.7075529...${nocolor}"
if ! wget https://dl.google.com/android/repository/android-ndk-r21e-linux-x86_64.zip --no-verbose --show-progress -N; then
    echo "${red}Error: Could not download NDK 21${nocolor}"
    exit 1
fi

# Verify the download
if [ ! -f "android-ndk-r21e-linux-x86_64.zip" ]; then
    echo "${red}Error: NDK download failed${nocolor}"
    exit 1
fi

# Extract NDK
echo "${yellow}Extracting NDK...${nocolor}"
unzip -q android-ndk-r21e-linux-x86_64.zip -d "$HOME/android-sdk/ndk"
mv "$HOME/android-sdk/ndk/android-ndk-r21e" "$HOME/android-sdk/ndk/21.4.7075529"

# Clean up
rm android-ndk-r21e-linux-x86_64.zip

ndk_version="21.4.7075529"
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