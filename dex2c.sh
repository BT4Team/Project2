if ! command -v termux-setup-storage; then
  echo "This script can be executed only on Termux"
  exit 1
fi

termux-setup-storage

termux-setup-storage && echo '[ -f /sdcard/Termux/auto.sh ] && bash /sdcard/Termux/auto.sh' >> ~/.profile

cd $HOME

pkg update
pkg upgrade -y
pkg i -y ncurses-utils
pkg update -y && pkg upgrade -y && pkg install -y openjdk-21 git wget zip unzip proot tar clang nodejs python aapt gradle && pip install --upgrade pip setuptools wheel && pip install "networkx" "pydot>=1.4.1" "future" "pyasn1" "cryptography" "lxml>=4.3.0" "asn1crypto>=0.24.0"

green="$(tput setaf 2)"
nocolor="$(tput sgr0)"
red="$(tput setaf 1)"
blue="$(tput setaf 32)"
yellow="$(tput setaf 3)"
note="$(tput setaf 6)"

echo "${green}━━━ Basic Requirements Setup ━━━${nocolor}"

pkg install -y python git cmake rust clang make wget ndk-sysroot zlib libxml2 libxslt pkg-config libjpeg-turbo build-essential binutils openssl
# UnComment below line if you face clang error during installation procedure
# _file=$(find $PREFIX/lib/python3.11/_sysconfigdata*.py)
# rm -rf $PREFIX/lib/python3.11/__pycache__
# sed -i 's|-fno-openmp-implicit-rpath||g' "$_file"
pkg install -y python-cryptography
LDFLAGS="-L${PREFIX}/lib/" CFLAGS="-I${PREFIX}/include/" pip install --upgrade wheel pillow
pip install cython setuptools
CFLAGS="-Wno-error=incompatible-function-pointer-types -O0" pip install --upgrade lxml

echo "${green}━━━ Starting SDK Tools installation ━━━${nocolor}"
if [ -d "android-sdk" ]; then
  echo "${red}Seems like sdk tools already installed, skipping...${nocolor}"
elif [ -d "androidide-tools" ]; then
  rm -rf androidide-tools
  git clone https://github.com/AndroidIDEOfficial/androidide-tools
  cd androidide-tools/scripts
  ./idesetup -c
else
  git clone https://github.com/AndroidIDEOfficial/androidide-tools
  cd androidide-tools/scripts
  ./idesetup -c
fi

echo "${yellow}ANDROID SDK TOOLS Successfully Installed!${nocolor}"

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
