ngrok_module() {

echo "🚀 Iniciando CORE PS.NGROK..."

cd $HOME/PeekToolkit/ps.ngrok || {
	echo "❌ ps.ngrok não encontrado"
	return
}

bash ngrok.sh
}
