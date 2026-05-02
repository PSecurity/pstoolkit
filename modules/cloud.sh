
cloud_menu() {
echo "☁️ Cloud Toolkit"
echo "1) Backup Termux"
echo "2) Sync pasta Downloads"

read -p "Escolha: " c

case $c in
1)
	sudo_mode "termux-setup-storage"
	cp -r $HOME $HOME/cloud_backup
	echo "Backup feito"
	;;
2)
	sudo_mode "termux-setup-storage"
	cp -r /sdcard/Download $HOME/cloud_sync
	echo "Sync concluído"
	;;
esac
}
