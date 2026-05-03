#!/bin/bash

# =====================================
# PS.Toolkit - PeekSecurity
# Toolkit central para Termux e Kali
# Autor: Peek | @PeekSecurity
# GitHub: https://psecurity.github.io/PSecurity
# =====================================

# ====== CORES ======
verde="\e[32m"
vermelho="\e[31m"
amarelo="\e[33m"
azul="\e[34m"
ciano="\e[36m"
branco="\e[1;37m"
reset="\e[0m"

# ====== DETECÇÃO DE AMBIENTE ======
detectar_ambiente() {
  if [[ -d "/data/data/com.termux" ]]; then
    echo "termux"
  elif grep -qi "kali" /etc/os-release 2>/dev/null; then
    echo "kali"
  else
    echo "desconhecido"
  fi
}

ambiente=$(detectar_ambiente)

# ====== DETECÇÃO DE ARCH ======
detectar_arch() {
  ARCH=$(uname -m)
  case "$ARCH" in
    x86_64)   ARCH_LABEL="amd64" ;;
    aarch64)  ARCH_LABEL="arm64" ;;
    armv7l)   ARCH_LABEL="arm"   ;;
    i686)     ARCH_LABEL="386"   ;;
    *)
      echo -e "${vermelho}[!] Arquitetura não suportada: $ARCH${reset}"
      exit 1
      ;;
  esac
}

# ====== LOADING ======
loading() {
  echo -ne "${amarelo}Processando"
  for i in {1..3}; do
    echo -ne "."
    sleep 0.4
  done
  echo -e "${reset}"
}

# ====== BANNER ======
banner() {
  clear
  echo -e "${ciano}"
  echo "  ██████╗ ███████╗    ████████╗ ██████╗  ██████╗ ██╗     ██╗  ██╗██╗████████╗"
  echo "  ██╔══██╗██╔════╝       ██╔══╝██╔═══██╗██╔═══██╗██║     ██║ ██╔╝██║╚══██╔══╝"
  echo "  ██████╔╝███████╗       ██║   ██║   ██║██║   ██║██║     █████╔╝ ██║   ██║   "
  echo "  ██╔═══╝ ╚════██║       ██║   ██║   ██║██║   ██║██║     ██╔═██╗ ██║   ██║   "
  echo "  ██║     ███████║       ██║   ╚██████╔╝╚██████╔╝███████╗██║  ██╗██║   ██║   "
  echo "  ╚═╝     ╚══════╝       ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝   ╚═╝   "
  echo -e "${reset}"
  echo -e "  ${branco}Autor:${reset}     Peek | @PeekSecurity"
  echo -e "  ${branco}GitHub:${reset}    psecurity.github.io/PSecurity"
  echo -e "  ${branco}Ambiente:${reset}  ${verde}$ambiente${reset}  |  ${branco}Arch:${reset} ${verde}$(uname -m)${reset}"
  echo -e "  ${amarelo}⚠️  Use apenas em ambientes autorizados!${reset}"
  echo ""
}

# ====================================
# ====== MÓDULO 1: TUNELAMENTO ======
# ====================================

# ------ INSTALAR NGROK ------
instalar_ngrok() {
  detectar_arch
  local NGROK_URL=""

  case "$ARCH_LABEL" in
    amd64) NGROK_URL="https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz" ;;
    arm64) NGROK_URL="https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-arm64.tgz" ;;
    arm)   NGROK_URL="https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-arm.tgz"   ;;
    386)
      echo -e "${amarelo}[!] 32 bits → Ngrok não suportado${reset}"
      return
      ;;
  esac

  # Verifica se já está instalado e funcionando
  if command -v ngrok >/dev/null 2>&1 && ngrok version >/dev/null 2>&1; then
    echo -e "${verde}✔ Ngrok já está instalado!${reset}"
    ngrok version
    return
  fi

  echo -e "${amarelo}[*] Baixando ngrok para $ARCH_LABEL...${reset}"
  wget -O ngrok.tgz "$NGROK_URL" || { echo -e "${vermelho}[!] Erro no download${reset}"; return; }
  tar -xzf ngrok.tgz && chmod +x ngrok && rm -f ngrok.tgz

  [[ "$ambiente" == "kali" ]] && sudo mv ngrok /usr/local/bin/ || mv ngrok $PREFIX/bin/

  ngrok version >/dev/null 2>&1 \
    && echo -e "${verde}✔ Ngrok instalado com sucesso!${reset}" \
    || echo -e "${vermelho}[!] Erro ao instalar ngrok${reset}"
}

# ------ INSTALAR CLOUDFLARE ------
instalar_cloudflare() {
  detectar_arch
  local CF_URL="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${ARCH_LABEL}"

  if command -v cloudflared >/dev/null 2>&1; then
    echo -e "${verde}✔ Cloudflared já instalado!${reset}"
    cloudflared --version
    return
  fi

  echo -e "${amarelo}[*] Baixando Cloudflare Tunnel...${reset}"
  wget -O cloudflared "$CF_URL" || { echo -e "${vermelho}[!] Erro no download${reset}"; return; }
  chmod +x cloudflared

  [[ "$ambiente" == "kali" ]] && sudo mv cloudflared /usr/local/bin/ || mv cloudflared $PREFIX/bin/

  cloudflared --version >/dev/null 2>&1 \
    && echo -e "${verde}✔ Cloudflare instalado com sucesso!${reset}" \
    || echo -e "${vermelho}[!] Erro ao instalar cloudflared${reset}"
}

# ------ CONFIGURAR TOKEN NGROK ------
configurar_token_ngrok() {
  if ! command -v ngrok >/dev/null 2>&1; then
    echo -e "${vermelho}[!] Ngrok não instalado. Instale primeiro!${reset}"
    return
  fi
  echo -e "${ciano}[?] Cole seu authtoken do ngrok:${reset}"
  echo -e "${amarelo}    Acesse: https://dashboard.ngrok.com/get-started/your-authtoken${reset}"
  echo -ne "  Token: "
  read token
  ngrok config add-authtoken "$token" \
    && echo -e "${verde}✔ Token configurado!${reset}" \
    || echo -e "${vermelho}[!] Erro ao configurar token${reset}"
}

# ------ CRIAR TÚNEL HTTP ------
criar_tunel_http() {
  if ! command -v ngrok >/dev/null 2>&1; then
    echo -e "${vermelho}[!] Ngrok não instalado!${reset}"
    return
  fi
  echo -ne "${ciano}[?] Porta para o túnel HTTP (ex: 8080): ${reset}"
  read porta
  echo -e "${amarelo}[*] Iniciando túnel HTTP na porta $porta...${reset}"
  echo -e "${amarelo}    Pressione CTRL+C para encerrar${reset}\n"
  ngrok http "$porta"
}

# ------ CRIAR TÚNEL TCP ------
criar_tunel_tcp() {
  if ! command -v ngrok >/dev/null 2>&1; then
    echo -e "${vermelho}[!] Ngrok não instalado!${reset}"
    return
  fi
  echo -ne "${ciano}[?] Porta para o túnel TCP (ex: 4444): ${reset}"
  read porta
  echo -e "${amarelo}[*] Iniciando túnel TCP na porta $porta...${reset}"
  echo -e "${amarelo}    Pressione CTRL+C para encerrar${reset}\n"
  ngrok tcp "$porta"
}

# ------ MENU TUNELAMENTO ------
menu_tunelamento() {
  while true; do
    banner
    echo -e "${azul}╔══════════════════════════════════════╗"
    echo -e "║      🌐 MÓDULO: TUNELAMENTO          ║"
    echo -e "╚══════════════════════════════════════╝${reset}"
    echo ""
    echo -e "  ${verde}[1]${reset} 📦 Instalar Ngrok"
    echo -e "  ${verde}[2]${reset} ☁️  Instalar Cloudflare Tunnel"
    echo -e "  ${verde}[3]${reset} 🔑 Configurar Token Ngrok"
    echo -e "  ${verde}[4]${reset} 🌐 Criar Túnel HTTP"
    echo -e "  ${verde}[5]${reset} 🔌 Criar Túnel TCP"
    echo ""
    echo -e "  ${vermelho}[0]${reset} ↩️  Voltar ao menu principal"
    echo ""
    echo -ne "  ${branco}Opção: ${reset}"
    read op

    case $op in
      1) instalar_ngrok      ; rodape ;;
      2) instalar_cloudflare ; rodape ;;
      3) configurar_token_ngrok ; rodape ;;
      4) criar_tunel_http    ;;
      5) criar_tunel_tcp     ;;
      0) return ;;
      *) echo -e "${vermelho}[!] Opção inválida!${reset}"; sleep 1 ;;
    esac
  done
}

# ============================================================
# ====== MÓDULO 2: PS.NMAP - PeekSecurity ======
# Script educativo de reconhecimento com Nmap
# ============================================================

# ------ VERIFICAR / INSTALAR NMAP ------
verificar_nmap() {
  if ! command -v nmap &> /dev/null; then
    echo -e "${vermelho}[!] Nmap não encontrado!${reset}"
    echo -e "${amarelo}[*] Instalando nmap...${reset}"
    if [[ "$ambiente" == "termux" ]]; then
      pkg update -y && pkg install nmap -y
    else
      sudo apt update && sudo apt install nmap -y
    fi
    echo -e "${verde}[✓] Nmap instalado com sucesso!${reset}"
    sleep 1
  fi
}

# ------ SOLICITA O ALVO ------
pedir_alvo() {
  echo -e "${ciano}[?] Digite o IP ou domínio alvo:${reset}"
  echo -e "${amarelo}    Exemplo: 192.168.1.1 ou exemplo.com${reset}"
  echo -ne "  ${branco}Alvo: ${reset}"
  read ALVO
  if [[ -z "$ALVO" ]]; then
    echo -e "${vermelho}[!] Alvo não pode ser vazio!${reset}"
    sleep 1
    return 1
  fi
  return 0
}

# ------ FUNÇÃO 1 - PING SCAN ------
# Verifica quais hosts estão ativos na rede
# Não escaneia portas, só descobre dispositivos vivos
scan_ping() {
  banner
  echo -e "${azul}╔══════════════════════════════════════╗"
  echo -e "║        🔍 SCAN DE PING (HOST)        ║"
  echo -e "╚══════════════════════════════════════╝${reset}"
  echo ""
  echo -e "${branco}📖 O que faz:${reset}"
  echo -e "   Descobre quais dispositivos estão ONLINE"
  echo -e "   na rede, sem escanear portas."
  echo -e "   Útil para mapear hosts ativos rapidamente.\n"
  pedir_alvo || return
  echo -e "\n${amarelo}[*] Executando Ping Scan em: ${ALVO}${reset}"
  echo -e "${ciano}[CMD] nmap -sn ${ALVO}${reset}\n"
  nmap -sn "$ALVO"
  rodape_nmap
}

# ------ FUNÇÃO 2 - SCAN DE PORTAS COMUNS ------
# Escaneia as 1000 portas mais usadas
scan_portas_comuns() {
  banner
  echo -e "${azul}╔══════════════════════════════════════╗"
  echo -e "║      🚪 SCAN DE PORTAS COMUNS        ║"
  echo -e "╚══════════════════════════════════════╝${reset}"
  echo ""
  echo -e "${branco}📖 O que faz:${reset}"
  echo -e "   Escaneia as 1000 portas mais comuns (padrão nmap)."
  echo -e "   Identifica serviços como HTTP, SSH, FTP, etc."
  echo -e "   Boa escolha para um primeiro reconhecimento.\n"
  pedir_alvo || return
  echo -e "\n${amarelo}[*] Escaneando portas comuns em: ${ALVO}${reset}"
  echo -e "${ciano}[CMD] nmap ${ALVO}${reset}\n"
  nmap "$ALVO"
  rodape_nmap
}

# ------ FUNÇÃO 3 - SCAN COMPLETO DE PORTAS ------
# Varre todas as 65535 portas do alvo
scan_portas_completo() {
  banner
  echo -e "${azul}╔══════════════════════════════════════╗"
  echo -e "║     🔓 SCAN COMPLETO DE PORTAS       ║"
  echo -e "╚══════════════════════════════════════╝${reset}"
  echo ""
  echo -e "${branco}📖 O que faz:${reset}"
  echo -e "   Varre TODAS as 65535 portas do alvo."
  echo -e "   Encontra serviços em portas não convencionais."
  echo -e "   ⏳ Mais lento — tenha paciência!\n"
  pedir_alvo || return
  echo -e "\n${amarelo}[*] Escaneando todas as portas em: ${ALVO}${reset}"
  echo -e "${ciano}[CMD] nmap -p- ${ALVO}${reset}\n"
  nmap -p- "$ALVO"
  rodape_nmap
}

# ------ FUNÇÃO 4 - DETECÇÃO DE VERSÕES ------
# Identifica qual software está rodando em cada porta
scan_versoes() {
  banner
  echo -e "${azul}╔══════════════════════════════════════╗"
  echo -e "║     🧠 DETECÇÃO DE VERSÕES           ║"
  echo -e "╚══════════════════════════════════════╝${reset}"
  echo ""
  echo -e "${branco}📖 O que faz:${reset}"
  echo -e "   Identifica QUAL software está rodando em cada porta."
  echo -e "   Exemplo: Apache 2.4.41, OpenSSH 8.2, MySQL 5.7"
  echo -e "   Essencial para identificar versões vulneráveis.\n"
  pedir_alvo || return
  echo -e "\n${amarelo}[*] Detectando versões em: ${ALVO}${reset}"
  echo -e "${ciano}[CMD] nmap -sV ${ALVO}${reset}\n"
  nmap -sV "$ALVO"
  rodape_nmap
}

# ------ FUNÇÃO 5 - DETECÇÃO DE SO ------
# Tenta identificar o SO do alvo
scan_os() {
  banner
  echo -e "${azul}╔══════════════════════════════════════╗"
  echo -e "║     💻 DETECÇÃO DE SO (OS)           ║"
  echo -e "╚══════════════════════════════════════╝${reset}"
  echo ""
  echo -e "${branco}📖 O que faz:${reset}"
  echo -e "   Tenta identificar o Sistema Operacional do alvo."
  echo -e "   Exemplo: Linux 5.x, Windows 10, Android."
  echo -e "   ⚠️  Pode precisar de permissão root para funcionar.\n"
  pedir_alvo || return
  echo -e "\n${amarelo}[*] Detectando SO em: ${ALVO}${reset}"
  echo -e "${ciano}[CMD] nmap -O ${ALVO}${reset}\n"
  nmap -O "$ALVO"
  rodape_nmap
}

# ------ FUNÇÃO 6 - SCAN AGRESSIVO ------
# Combina: versões + OS + scripts + traceroute
scan_agressivo() {
  banner
  echo -e "${azul}╔══════════════════════════════════════╗"
  echo -e "║       💥 SCAN AGRESSIVO (FULL)       ║"
  echo -e "╚══════════════════════════════════════╝${reset}"
  echo ""
  echo -e "${branco}📖 O que faz:${reset}"
  echo -e "   Combina: versões + OS + scripts NSE + traceroute."
  echo -e "   É o scan mais COMPLETO disponível no nmap."
  echo -e "   ⚠️  Gera muito tráfego — pode ser detectado!\n"
  pedir_alvo || return
  echo -e "\n${amarelo}[*] Executando scan agressivo em: ${ALVO}${reset}"
  echo -e "${ciano}[CMD] nmap -A ${ALVO}${reset}\n"
  nmap -A "$ALVO"
  rodape_nmap
}

# ------ FUNÇÃO 7 - SCAN SILENCIOSO (SYN) ------
# Scan mais discreto, não completa o handshake TCP
scan_silencioso() {
  banner
  echo -e "${azul}╔══════════════════════════════════════╗"
  echo -e "║       🥷 SCAN SILENCIOSO (SYN)       ║"
  echo -e "╚══════════════════════════════════════╝${reset}"
  echo ""
  echo -e "${branco}📖 O que faz:${reset}"
  echo -e "   Usa SYN Scan — não completa o handshake TCP."
  echo -e "   Mais discreto e rápido que o scan padrão."
  echo -e "   ⚠️  Requer permissão root (sudo/tsu).\n"
  pedir_alvo || return
  echo -e "\n${amarelo}[*] Executando SYN Scan em: ${ALVO}${reset}"
  echo -e "${ciano}[CMD] nmap -sS ${ALVO}${reset}\n"
  nmap -sS "$ALVO"
  rodape_nmap
}

# ------ FUNÇÃO 8 - SCAN DE VULNERABILIDADES (NSE) ------
# Usa scripts do Nmap para detectar vulns conhecidas
scan_vulns() {
  banner
  echo -e "${azul}╔══════════════════════════════════════╗"
  echo -e "║    🛡️  SCAN DE VULNERABILIDADES      ║"
  echo -e "╚══════════════════════════════════════╝${reset}"
  echo ""
  echo -e "${branco}📖 O que faz:${reset}"
  echo -e "   Usa os scripts NSE (Nmap Scripting Engine)"
  echo -e "   para detectar vulnerabilidades conhecidas."
  echo -e "   Identifica CVEs, configurações fracas, etc.\n"
  pedir_alvo || return
  echo -e "\n${amarelo}[*] Buscando vulnerabilidades em: ${ALVO}${reset}"
  echo -e "${ciano}[CMD] nmap --script vuln ${ALVO}${reset}\n"
  nmap --script vuln "$ALVO"
  rodape_nmap
}

# ------ FUNÇÃO 9 - SCAN PERSONALIZADO ------
# O usuário digita os próprios parâmetros do nmap
scan_custom() {
  banner
  echo -e "${azul}╔══════════════════════════════════════╗"
  echo -e "║      ⚙️  SCAN PERSONALIZADO           ║"
  echo -e "╚══════════════════════════════════════╝${reset}"
  echo ""
  echo -e "${branco}📖 O que faz:${reset}"
  echo -e "   Você escolhe os parâmetros do nmap manualmente."
  echo -e "   Ideal para quem já tem experiência com a ferramenta.\n"
  echo -e "${amarelo}   Exemplos de parâmetros:${reset}"
  echo -e "   -p 80,443       → portas específicas"
  echo -e "   -sU             → scan UDP"
  echo -e "   --script http-* → scripts HTTP\n"
  pedir_alvo || return
  echo -ne "${ciano}[?] Parâmetros nmap: ${reset}"
  read PARAMS
  echo -e "\n${amarelo}[*] Executando scan personalizado em: ${ALVO}${reset}"
  echo -e "${ciano}[CMD] nmap ${PARAMS} ${ALVO}${reset}\n"
  nmap $PARAMS "$ALVO"
  rodape_nmap
}

# ------ RODAPÉ DO PS.NMAP ------
rodape_nmap() {
  echo ""
  echo -e "${verde}[✓] Scan finalizado!${reset}"
  echo -e "${ciano}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${reset}"
  echo -ne "${branco}[?] Pressione ENTER para voltar ao menu...${reset}"
  read
}

# ------ MENU PS.NMAP ------
menu_reconhecimento() {
  verificar_nmap
  while true; do
    banner
    echo -e "${azul}╔══════════════════════════════════════╗"
    echo -e "║     🔍 MÓDULO: PS.NMAP               ║"
    echo -e "╚══════════════════════════════════════╝${reset}"
    echo ""
    echo -e "  ${verde}[1]${reset} 🔍 Ping Scan          ${amarelo}→ Hosts ativos na rede${reset}"
    echo -e "  ${verde}[2]${reset} 🚪 Portas Comuns       ${amarelo}→ 1000 portas padrão${reset}"
    echo -e "  ${verde}[3]${reset} 🔓 Portas Completo     ${amarelo}→ Todas as 65535 portas${reset}"
    echo -e "  ${verde}[4]${reset} 🧠 Detecção de Versões ${amarelo}→ Software em cada porta${reset}"
    echo -e "  ${verde}[5]${reset} 💻 Detecção de SO      ${amarelo}→ Sistema Operacional${reset}"
    echo -e "  ${verde}[6]${reset} 💥 Scan Agressivo      ${amarelo}→ Tudo de uma vez${reset}"
    echo -e "  ${verde}[7]${reset} 🥷 Scan Silencioso     ${amarelo}→ SYN Scan (discreto)${reset}"
    echo -e "  ${verde}[8]${reset} 🛡️  Vulnerabilidades    ${amarelo}→ Scripts NSE vuln${reset}"
    echo -e "  ${verde}[9]${reset} ⚙️  Scan Personalizado  ${amarelo}→ Seus próprios parâmetros${reset}"
    echo ""
    echo -e "  ${vermelho}[0]${reset} ↩️  Voltar ao menu principal"
    echo ""
    echo -ne "  ${branco}Opção: ${reset}"
    read op

    case $op in
      1) scan_ping           ;;
      2) scan_portas_comuns  ;;
      3) scan_portas_completo ;;
      4) scan_versoes        ;;
      5) scan_os             ;;
      6) scan_agressivo      ;;
      7) scan_silencioso     ;;
      8) scan_vulns          ;;
      9) scan_custom         ;;
      0) return ;;
      *) echo -e "${vermelho}[!] Opção inválida!${reset}"; sleep 1 ;;
    esac
  done
}

# ============================================================
# ====== MÓDULO 3: PS.SUDO - PeekSecurity ======
# Wrapper sudo moderno para Termux (Magisk / KernelSU / APatch)
# ============================================================

# ------ LOCALIZA O SU DISPONÍVEL ------
# Suporte: Magisk moderno, KernelSU, APatch, fallback PATH
localizar_su() {
  if command -v su >/dev/null 2>&1; then
    SU="su"; return 0
  fi
  if [ -x /data/adb/ksu/bin/su ]; then
    SU=/data/adb/ksu/bin/su; return 0
  fi
  if [ -x /data/adb/ap/bin/su ]; then
    SU=/data/adb/ap/bin/su; return 0
  fi
  for path in /sbin/su /system/xbin/su /system/bin/su /su/bin/su /magisk/.core/bin/su; do
    if [ -x "$path" ]; then SU="$path"; return 0; fi
  done
  return 1
}

# ------ SETUP DO ROOT HOME (sem remount, Android 10+) ------
sudo_setup_root_home() {
  local PRE=/data/data/com.termux/files
  local ROOT_HOME=$PRE/home/.suroot
  if [ ! -d "$ROOT_HOME" ]; then
    $SU -c "mkdir -p $ROOT_HOME && chmod 700 $ROOT_HOME" 2>/dev/null
    local bashrc="PS1='# '\nexport TERM=$TERM\nexport PATH=$PATH\nexport LD_LIBRARY_PATH=$PRE/usr/lib"
    $SU -c "printf '$bashrc\n' > $ROOT_HOME/.bashrc && chmod 700 $ROOT_HOME/.bashrc" 2>/dev/null
  fi
  echo "$ROOT_HOME"
}

# ------ VERIFICAR ROOT ------
sudo_check() {
  banner
  echo -e "${azul}╔══════════════════════════════════════╗"
  echo -e "║      🔑 PS.SUDO — VERIFICAR ROOT     ║"
  echo -e "╚══════════════════════════════════════╝${reset}"
  echo ""
  echo -e "${branco}📖 O que faz:${reset}"
  echo -e "   Verifica se o root está disponível e funcional."
  echo -e "   Detecta Magisk, KernelSU e APatch automaticamente.\n"

  echo -e "${amarelo}[*] Procurando binário su...${reset}"

  if ! localizar_su; then
    echo -e "${vermelho}[✗] su não encontrado!${reset}"
    echo -e "${amarelo}    Instale Magisk, KernelSU ou APatch no dispositivo.${reset}"
    rodape; return
  fi

  echo -e "${verde}[✓] su encontrado: ${branco}$SU${reset}"
  echo -e "${amarelo}[*] Testando acesso root real...${reset}"

  local uid=$($SU -c "id -u" 2>/dev/null)
  if [ "$uid" = "0" ]; then
    echo -e "${verde}[✓] Root funcional! UID = 0${reset}"
  else
    echo -e "${vermelho}[✗] Root negado pelo gerenciador.${reset}"
    echo -e "${amarelo}    Conceda permissão ao Termux no Magisk/KernelSU.${reset}"
  fi
  rodape
}

# ------ INFO DO AMBIENTE ROOT ------
sudo_info() {
  banner
  echo -e "${azul}╔══════════════════════════════════════╗"
  echo -e "║      🔑 PS.SUDO — INFO ROOT          ║"
  echo -e "╚══════════════════════════════════════╝${reset}"
  echo ""

  if ! localizar_su; then
    echo -e "${vermelho}[✗] su não encontrado!${reset}"
    rodape; return
  fi

  local uid=$($SU -c "id -u" 2>/dev/null)
  local whoami_root=$($SU -c "whoami" 2>/dev/null)
  local kernel=$($SU -c "uname -r" 2>/dev/null)

  echo -e "${ciano}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${reset}"
  echo -e "  ${amarelo}su:${reset}        $SU"
  echo -e "  ${amarelo}UID root:${reset}  ${uid:-N/A}"
  echo -e "  ${amarelo}Whoami:${reset}    ${whoami_root:-N/A}"
  echo -e "  ${amarelo}Kernel:${reset}    ${kernel:-N/A}"
  echo -e "${ciano}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${reset}"
  rodape
}

# ------ INSTALAR PS.SUDO NO PATH ------
sudo_instalar() {
  banner
  echo -e "${azul}╔══════════════════════════════════════╗"
  echo -e "║      🔑 PS.SUDO — INSTALAR           ║"
  echo -e "╚══════════════════════════════════════╝${reset}"
  echo ""
  echo -e "${branco}📖 O que faz:${reset}"
  echo -e "   Instala o PS.Sudo no PATH do Termux."
  echo -e "   Após instalar, use 'sudo <comando>' normalmente.\n"

  local DEST="$PREFIX/bin/sudo"

  # Baixa do repositório
  echo -e "${amarelo}[*] Baixando PS.Sudo...${reset}"
  if wget -q -O "$DEST" "https://raw.githubusercontent.com/PSecurity/ps.sudo/master/sudo"; then
    chmod +x "$DEST"
    echo -e "${verde}[✓] PS.Sudo instalado em: ${branco}$DEST${reset}"
    echo -e "${verde}[✓] Use: sudo --check para testar${reset}"
  else
    echo -e "${vermelho}[!] Erro no download. Verifique sua conexão.${reset}"
  fi
  rodape
}

# ------ SHELL ROOT INTERATIVO ------
sudo_shell() {
  banner
  echo -e "${azul}╔══════════════════════════════════════╗"
  echo -e "║      🔑 PS.SUDO — SHELL ROOT         ║"
  echo -e "╚══════════════════════════════════════╝${reset}"
  echo ""
  echo -e "${branco}📖 O que faz:${reset}"
  echo -e "   Abre um shell interativo como root."
  echo -e "   Digite 'exit' para voltar ao Termux.\n"

  if ! localizar_su; then
    echo -e "${vermelho}[!] su não encontrado!${reset}"
    rodape; return
  fi

  local PRE=/data/data/com.termux/files
  local ROOT_HOME=$(sudo_setup_root_home)
  local BINPRE=$PRE/usr/bin

  echo -e "${amarelo}[*] Abrindo shell root...${reset}"
  echo -e "${amarelo}    Digite 'exit' para voltar ao toolkit.${reset}\n"

  $SU -c "export HOME=$ROOT_HOME; export PATH=$PATH; export LD_LIBRARY_PATH=$PRE/usr/lib; cd $PWD; exec $BINPRE/bash --rcfile $ROOT_HOME/.bashrc"

  stty sane 2>/dev/null
  rodape
}

# ------ EXECUTAR COMANDO COMO ROOT ------
sudo_executar() {
  banner
  echo -e "${azul}╔══════════════════════════════════════╗"
  echo -e "║      🔑 PS.SUDO — EXECUTAR CMD       ║"
  echo -e "╚══════════════════════════════════════╝${reset}"
  echo ""
  echo -e "${branco}📖 O que faz:${reset}"
  echo -e "   Executa um comando pontual como root.\n"
  echo -e "${amarelo}   Exemplos:${reset}"
  echo -e "   nmap -sS 192.168.1.1"
  echo -e "   ls /data/data\n"

  if ! localizar_su; then
    echo -e "${vermelho}[!] su não encontrado!${reset}"
    rodape; return
  fi

  echo -ne "${ciano}[?] Comando para executar como root: ${reset}"
  read CMD

  [[ -z "$CMD" ]] && echo -e "${vermelho}[!] Comando vazio!${reset}" && rodape && return

  local PRE=/data/data/com.termux/files
  local ROOT_HOME=$(sudo_setup_root_home)

  echo -e "\n${amarelo}[CMD] sudo $CMD${reset}\n"
  $SU -c "export HOME=$ROOT_HOME; export PATH=$PATH; export LD_LIBRARY_PATH=$PRE/usr/lib; cd $PWD; $CMD"

  stty sane 2>/dev/null
  rodape
}

# ------ MENU PS.SUDO ------
menu_sudo() {
  while true; do
    banner
    echo -e "${azul}╔══════════════════════════════════════╗"
    echo -e "║      🔑 MÓDULO: PS.SUDO              ║"
    echo -e "╚══════════════════════════════════════╝${reset}"
    echo ""
    echo -e "  ${verde}[1]${reset} ✅ Verificar Root      ${amarelo}→ Testa se root funciona${reset}"
    echo -e "  ${verde}[2]${reset} 📋 Info Root           ${amarelo}→ Detalhes do ambiente${reset}"
    echo -e "  ${verde}[3]${reset} 🐚 Shell Root          ${amarelo}→ Terminal interativo root${reset}"
    echo -e "  ${verde}[4]${reset} ⚡ Executar Comando    ${amarelo}→ Roda comando como root${reset}"
    echo -e "  ${verde}[5]${reset} 📦 Instalar PS.Sudo    ${amarelo}→ Instala no PATH do Termux${reset}"
    echo ""
    echo -e "  ${vermelho}[0]${reset} ↩️  Voltar ao menu principal"
    echo ""
    echo -ne "  ${branco}Opção: ${reset}"
    read op

    case $op in
      1) sudo_check    ;;
      2) sudo_info     ;;
      3) sudo_shell    ;;
      4) sudo_executar ;;
      5) sudo_instalar ;;
      0) return ;;
      *) echo -e "${vermelho}[!] Opção inválida!${reset}"; sleep 1 ;;
    esac
  done
}

# ====================================
# ====== MÓDULO 4: SISTEMA/SETUP ======
# ====================================

# ------ ATUALIZAR SISTEMA ------
atualizar_sistema() {
  echo -e "${amarelo}[*] Atualizando sistema ($ambiente)...${reset}"
  loading
  if [[ "$ambiente" == "termux" ]]; then
    pkg update -y && pkg upgrade -y
  else
    sudo apt update && sudo apt upgrade -y
  fi
  echo -e "${verde}✔ Sistema atualizado!${reset}"
}

# ------ INSTALAR ESSENCIAIS ------
instalar_essenciais() {
  echo -e "${amarelo}[*] Instalando pacotes essenciais...${reset}"
  loading

  local pkgs="wget curl git tar python3 nmap"

  if [[ "$ambiente" == "termux" ]]; then
    pkg install $pkgs -y
  else
    sudo apt install $pkgs -y
  fi

  echo -e "${verde}✔ Pacotes instalados!${reset}"
}

# ------ INFO DO DISPOSITIVO ------
info_dispositivo() {
  echo -e "${ciano}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${reset}"
  echo -e "  ${branco}📱 Informações do Dispositivo${reset}"
  echo -e "${ciano}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${reset}"
  echo -e "  ${amarelo}SO:${reset}        $(uname -o 2>/dev/null || uname -s)"
  echo -e "  ${amarelo}Kernel:${reset}    $(uname -r)"
  echo -e "  ${amarelo}Arch:${reset}      $(uname -m)"
  echo -e "  ${amarelo}Hostname:${reset}  $(hostname)"
  echo -e "  ${amarelo}Usuário:${reset}   $(whoami)"
  echo -e "  ${amarelo}IP Local:${reset}  $(hostname -I 2>/dev/null | awk '{print $1}')"
  echo -e "  ${amarelo}IP Externo:${reset} $(curl -s ifconfig.me 2>/dev/null || echo 'N/A')"
  echo -e "${ciano}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${reset}"
}

# ------ MENU SISTEMA ------
menu_sistema() {
  while true; do
    banner
    echo -e "${azul}╔══════════════════════════════════════╗"
    echo -e "║      ⚙️  MÓDULO: SISTEMA / SETUP      ║"
    echo -e "╚══════════════════════════════════════╝${reset}"
    echo ""
    echo -e "  ${verde}[1]${reset} 🔄 Atualizar Sistema"
    echo -e "  ${verde}[2]${reset} 📦 Instalar Pacotes Essenciais"
    echo -e "  ${verde}[3]${reset} 📱 Info do Dispositivo"
    echo ""
    echo -e "  ${vermelho}[0]${reset} ↩️  Voltar ao menu principal"
    echo ""
    echo -ne "  ${branco}Opção: ${reset}"
    read op

    case $op in
      1) atualizar_sistema    ; rodape ;;
      2) instalar_essenciais  ; rodape ;;
      3) info_dispositivo     ; rodape ;;
      0) return ;;
      *) echo -e "${vermelho}[!] Opção inválida!${reset}"; sleep 1 ;;
    esac
  done
}

# ============================
# ====== RODAPÉ PADRÃO ======
# ============================
rodape() {
  echo ""
  echo -e "${verde}[✓] Concluído!${reset}"
  echo -e "${ciano}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${reset}"
  echo -ne "${branco}[?] Pressione ENTER para continuar...${reset}"
  read
}

# ==============================
# ====== MENU PRINCIPAL ========
# ==============================
menu_principal() {
  while true; do
    banner
    echo -e "${ciano}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${reset}"
    echo -e "  ${branco}MENU PRINCIPAL${reset}"
    echo -e "${ciano}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${reset}"
    echo ""
    echo -e "  ${verde}[1]${reset} 🌐 Tunelamento       ${amarelo}→ Ngrok / Cloudflare${reset}"
    echo -e "  ${verde}[2]${reset} 🔍 PS.Nmap            ${amarelo}→ Reconhecimento completo${reset}"
    echo -e "  ${verde}[3]${reset} 🔑 PS.Sudo            ${amarelo}→ Acesso root no Termux${reset}"
    echo -e "  ${verde}[4]${reset} ⚙️  Sistema / Setup   ${amarelo}→ Update / Info${reset}"
    echo ""
    echo -e "  ${vermelho}[0]${reset} 🚪 Sair"
    echo ""
    echo -e "${ciano}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${reset}"
    echo -ne "  ${branco}Opção: ${reset}"
    read op

    case $op in
      1) menu_tunelamento    ;;
      2) menu_reconhecimento ;;
      3) menu_sudo           ;;
      4) menu_sistema        ;;
      0)
        echo ""
        echo -e "  ${ciano}Valeu rapaziada! Até a próxima! 👾${reset}"
        echo -e "  ${branco}@PeekSecurity${reset}"
        echo ""
        exit 0
        ;;
      *) echo -e "${vermelho}[!] Opção inválida!${reset}"; sleep 1 ;;
    esac
  done
}

# ====== INICIALIZAÇÃO ======
menu_principal
