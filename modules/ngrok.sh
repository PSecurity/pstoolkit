ngrok_menu() {
echo "🚀 Ngrok Toolkit"
echo "1) Start HTTP tunnel"
echo "2) Start custom port"
read -p "Escolha: " n

case $n in
1)
	sudo_mode "pkill ngrok"
	sudo_mode "./ngrok http 8080"
	;;
2)
	read -p "Porta: " p
	sudo_mode "./ngrok http $p"
	;;
esac
}
