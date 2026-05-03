# 🧰 PS.Toolkit — PeekSecurity

> Toolkit central para Termux e Kali Linux — reunindo as ferramentas PS. em um único lugar.

---

## 📖 Sobre

O **PS.Toolkit** é o menu central da PeekSecurity, criado para reunir todas as ferramentas da série **PS.** em um único script interativo, com interface simples e didática para quem está aprendendo segurança, automação e uso do Termux no Android.

Cada módulo foi desenvolvido com foco em:
- Visual limpo e fácil de navegar
- Descrições do que cada função faz
- Compatibilidade com Termux e Kali Linux
- Comandos visíveis na tela para fins educativos

---

## 📱 Compatibilidade

| Ambiente | Suporte |
|---|---|
| Termux (Android) | ✅ |
| Kali Linux | ✅ |
| Ubuntu / Debian | ✅ |
| Outros Linux | ⚠️ Parcial |

---

## 🚀 Instalação

Clone o repositório:

```bash
git clone https://github.com/PSecurity/ps.toolkit
```

Entre na pasta:

```bash
cd ps.toolkit
```

Dê permissão de execução:

```bash
chmod +x ps_toolkit.sh
```

Execute:

```bash
bash ps_toolkit.sh
```

---

## 🧩 Módulos

### 🌐 [1] Tunelamento — PS.Ngrok

Instalação e configuração de túneis reversos para expor serviços locais à internet.

| Função | Descrição |
|---|---|
| Instalar Ngrok | Download e instalação automática por arquitetura |
| Instalar Cloudflare Tunnel | Alternativa ao Ngrok, sem limite de banda |
| Configurar Token Ngrok | Configura o authtoken da conta |
| Criar Túnel HTTP | Expõe porta HTTP para a internet |
| Criar Túnel TCP | Expõe porta TCP (ex: reverse shell, SSH) |

---

### 🔍 [2] Reconhecimento — PS.Nmap

Script educativo de reconhecimento de rede com Nmap. Cada função exibe o comando executado e uma descrição do que está fazendo.

| Função | Comando |
|---|---|
| Ping Scan | `nmap -sn` |
| Portas Comuns | `nmap` |
| Portas Completo | `nmap -p-` |
| Detecção de Versões | `nmap -sV` |
| Detecção de SO | `nmap -O` |
| Scan Agressivo | `nmap -A` |
| Scan Silencioso | `nmap -sS` |
| Vulnerabilidades NSE | `nmap --script vuln` |
| Scan Personalizado | parâmetros livres |

> ⚠️ Use apenas em redes e dispositivos que você tem permissão!

---

### 🔑 [3] Acesso Root — PS.Sudo

Wrapper sudo moderno para Termux, compatível com os principais gerenciadores de root do Android atual.

| Função | Descrição |
|---|---|
| Verificar Root | Testa se `su` está disponível e funcional |
| Info Root | Exibe gerenciador detectado, UID, kernel |
| Shell Root | Abre bash interativo como root |
| Executar Comando | Roda um comando pontual como root |
| Instalar PS.Sudo | Instala o sudo no `$PREFIX/bin` do Termux |

**Gerenciadores suportados:** Magisk, KernelSU, APatch e fallbacks legados.

---

### ⚙️ [4] Sistema / Setup

Utilitários gerais de manutenção e informações do dispositivo.

| Função | Descrição |
|---|---|
| Atualizar Sistema | `pkg upgrade` no Termux ou `apt upgrade` no Kali |
| Instalar Essenciais | wget, curl, git, python3, nmap e mais |
| Info do Dispositivo | SO, kernel, arch, IP local e externo |

---

## ⚙️ Detecção Automática

O PS.Toolkit detecta automaticamente o ambiente e a arquitetura do dispositivo:

- **Ambiente:** Termux ou Kali Linux
- **Arquitetura:** amd64, arm64, arm, 386
- Todos os módulos adaptam os comandos de instalação conforme o ambiente detectado

---

## 📦 Ferramentas da Série PS.

| Ferramenta | Repositório | Descrição |
|---|---|---|
| PS.Toolkit | [ps.toolkit](https://github.com/PSecurity/ps.toolkit) | Menu central |
| PS.Nmap | [ps.nmap](https://github.com/PSecurity/ps.nmap) | Reconhecimento com Nmap |
| PS.Ngrok | [ps.ngrok](https://github.com/PSecurity/ps.ngrok) | Tunelamento reverso |
| PS.Sudo | [ps.sudo](https://github.com/PSecurity/ps.sudo) | Acesso root no Termux |

---

## 👨‍💻 Autor

**PeekSecurity** — Peek

🎵 TikTok: [@PeekSecurity](https://www.tiktok.com/@peeksecurity)

📺 YouTube: [@PeekSecurity](https://m.youtube.com/channel/UC-EKtzSnSUZ8b0CgyUY-hvw)

🌐 Blog: [psecurity.github.io/PSecurity](https://psecurity.github.io/PSecurity)

📝 WordPress: [peeksecurity.wordpress.com](https://peeksecurity.wordpress.com)

---

## ⭐ Contribuição

Sinta-se à vontade para abrir issues, sugerir novos módulos ou enviar pull requests.

Toda contribuição é bem-vinda!

---

## 📜 Licença

Este projeto está sob a licença Apache 2.0.

---

> ⚠️ Todas as ferramentas da série PS. são destinadas a fins educacionais e devem ser usadas apenas em ambientes e dispositivos autorizados.

