#!/data/data/com.termux/files/usr/bin/bash

clear

source ./config.sh

source ./modules/sudo.sh
source ./modules/ngrok.sh
source ./modules/cloud.sh
source ./modules/fire.sh

banner() {
echo "============================"
echo "   👾 PeekToolkit"
echo "============================"
echo
}

menu() {
banner

echo "1) 🚀 Ngrok"
echo "2) ☁️ Cloud Sync"
echo "3) 🔥 Fire Server"
echo "4) 🧠 Root Shell (sudo_mode)"
echo "0) Sair"

read -p "Escolha: " op

case $op in
1) ngrok_menu ;;
2) cloud_menu ;;
3) fire_menu ;;
4) sudo_mode ;;
0) exit ;;
*) echo "Opção inválida" ;;
esac
}

while true; do
menu
done
