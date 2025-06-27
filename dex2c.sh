if ! command -v termux-setup-storage; then
  echo "This script can be executed only on Termux"
  exit 1
fi

termux-setup-storage

cd $HOME
if [ -d "dex2c" ]; then
  cd dex2c
elif [ -f "dcc.py" ] && [ -d "tools" ]; then
  :
else
  git clone https://github.com/BT4Team/BT4-Dex2c || exit 2
  cd dex2c || exit 2
fi

echo "${green}============================"
echo "Great! Dex2c Installed Successfully!"
echo "============================${nocolor}"
