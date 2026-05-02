fire_menu() {
echo "🔥 Fire Toolkit"
echo "1) HTTP Server (Python)"
echo "2) File Share rápido"

read -p "Escolha: " f

case $f in
1)
	echo "Iniciando server..."
	cd /sdcard
	python3 -m http.server 8080
	;;
2)
	echo "Link local:"
	ip addr show wlan0 | grep inet
	;;
esac
}
