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

# =====================================
# ====== MÓDULO 2: RECONHECIMENTO ======
# =====================================

# ------ INSTALAR NMAP ------
instalar_nmap() {
  if command -v nmap >/dev/null 2>&1; then
    echo -e "${verde}✔ Nmap já instalado!${reset}"
    nmap --version | head -1
    return
  fi
  loading
  [[ "$ambiente" == "termux" ]] && pkg install nmap -y || sudo apt install nmap -y
  command -v nmap >/dev/null 2>&1 \
    && echo -e "${verde}✔ Nmap instalado!${reset}" \
    || echo -e "${vermelho}[!] Erro ao instalar nmap${reset}"
}

# ------ SCAN RÁPIDO ------
scan_rapido() {
  echo -ne "${ciano}[?] Alvo (IP ou domínio): ${reset}"
  read alvo
  [[ -z "$alvo" ]] && echo -e "${vermelho}[!] Alvo vazio!${reset}" && return
  echo -e "\n${amarelo}[CMD] nmap -sV --open $alvo${reset}\n"
  nmap -sV --open "$alvo"
}

# ------ SCAN DE REDE LOCAL ------
scan_rede_local() {
  local gateway=$(ip route | grep default | awk '{print $3}' 2>/dev/null)
  local rede=$(echo "$gateway" | cut -d'.' -f1-3).0/24
  echo -e "${amarelo}[*] Rede detectada: ${verde}$rede${reset}"
  echo -e "${amarelo}[CMD] nmap -sn $rede${reset}\n"
  nmap -sn "$rede"
}

# ------ WHOIS ------
info_whois() {
  if ! command -v whois >/dev/null 2>&1; then
    echo -e "${amarelo}[*] Instalando whois...${reset}"
    [[ "$ambiente" == "termux" ]] && pkg install whois -y || sudo apt install whois -y
  fi
  echo -ne "${ciano}[?] Domínio ou IP para whois: ${reset}"
  read alvo
  [[ -z "$alvo" ]] && echo -e "${vermelho}[!] Alvo vazio!${reset}" && return
  echo -e "\n${amarelo}[CMD] whois $alvo${reset}\n"
  whois "$alvo"
}

# ------ MENU RECONHECIMENTO ------
menu_reconhecimento() {
  while true; do
    banner
    echo -e "${azul}╔══════════════════════════════════════╗"
    echo -e "║     🔍 MÓDULO: RECONHECIMENTO        ║"
    echo -e "╚══════════════════════════════════════╝${reset}"
    echo ""
    echo -e "  ${verde}[1]${reset} 📦 Instalar Nmap"
    echo -e "  ${verde}[2]${reset} ⚡ Scan Rápido (portas + versões)"
    echo -e "  ${verde}[3]${reset} 🏠 Scan Rede Local"
    echo -e "  ${verde}[4]${reset} 🌐 Whois (info de domínio/IP)"
    echo ""
    echo -e "  ${vermelho}[0]${reset} ↩️  Voltar ao menu principal"
    echo ""
    echo -ne "  ${branco}Opção: ${reset}"
    read op

    case $op in
      1) instalar_nmap     ; rodape ;;
      2) scan_rapido       ; rodape ;;
      3) scan_rede_local   ; rodape ;;
      4) info_whois        ; rodape ;;
      0) return ;;
      *) echo -e "${vermelho}[!] Opção inválida!${reset}"; sleep 1 ;;
    esac
  done
}

# ====================================
# ====== MÓDULO 3: SISTEMA/SETUP ======
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
    echo -e "  ${verde}[2]${reset} 🔍 Reconhecimento    ${amarelo}→ Nmap / Whois${reset}"
    echo -e "  ${verde}[3]${reset} ⚙️  Sistema / Setup   ${amarelo}→ Update / Info${reset}"
    echo ""
    echo -e "  ${vermelho}[0]${reset} 🚪 Sair"
    echo ""
    echo -e "${ciano}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${reset}"
    echo -ne "  ${branco}Opção: ${reset}"
    read op

    case $op in
      1) menu_tunelamento    ;;
      2) menu_reconhecimento ;;
      3) menu_sistema        ;;
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
