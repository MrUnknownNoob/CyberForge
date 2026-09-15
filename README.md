# 🛡️ Local CTF AI Agent

> A lightweight, privacy-focused local AI agent environment for Cybersecurity, CTFs, Code Analysis, Digital Forensics, Reverse Engineering, and Security Labs.

Local CTF AI Agent combines **OpenCode**, **Ollama**, and lightweight local coding models to provide an AI-assisted cybersecurity workspace that can run locally on Linux.

## ✨ Features

- 🧠 Local AI inference with Ollama
- 🤖 OpenCode terminal AI agent
- 🔒 Privacy-friendly local workflow
- 💻 CPU-friendly lightweight models
- 🧩 Automatic RAM-based model selection
- 💾 Disk-space preflight check
- 🐧 Kali Linux / Debian / Ubuntu support
- ⚡ One-command deployment
- 🗂️ Pre-configured CTF workspace
- 🔍 CTF-focused `AGENTS.md`
- 🐍 Python and shell scripting support
- 🔄 Safe to re-run after failed installation
- 🛠️ Built-in health checks
- 🌐 Internet required only for initial installation/model download

## 🧠 Architecture

```text
                    ┌──────────────────────┐
                    │      CTF Player      │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │       OpenCode       │
                    │     AI Agent Layer   │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │        Ollama        │
                    │    Local LLM Runtime │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │   Local Coding LLM   │
                    │  Qwen2.5-Coder etc.  │
                    └──────────┬───────────┘
                               │
                ┌──────────────┼──────────────┐
                ▼              ▼              ▼
             Python         Terminal       Files
                │              │              │
                └──────────────┼──────────────┘
                               ▼
                    ┌──────────────────────┐
                    │     CTF Workspace    │
                    ├──────────────────────┤
                    │ Web / Crypto / RE    │
                    │ Pwn / Forensics      │
                    │ Network / OSINT      │
                    │ Malware / Scripts    │
                    └──────────────────────┘
```

## 🚀 Quick Start

```bash
git clone https://github.com/MrUnknownNoob/CyberForge
cd CyberForge
chmod +x install_ctf_agent.sh
bash -n install_ctf_agent.sh
./install_ctf_agent.sh
```

If `bash -n` produces no output, the script passed the syntax check.

> Do **not** run the entire installer with `sudo`. It requests elevated privileges only when needed.

## 📦 What the Installer Does

1. Detects the Linux distribution
2. Detects available RAM
3. Checks free disk space
4. Installs missing base dependencies
5. Installs/configures Ollama
6. Starts the Ollama service
7. Selects a suitable lightweight model
8. Downloads the model
9. Installs OpenCode
10. Creates a CTF workspace
11. Creates CTF-focused `AGENTS.md`
12. Creates the `ctf-ai` launcher
13. Runs health checks

## 🧠 Automatic Model Selection

| Available RAM | Selected Model |
|---|---|
| < 3 GB | `qwen2.5-coder:0.5b` |
| 3–6 GB | `qwen2.5-coder:1.5b` |
| 6 GB+ | `qwen2.5-coder:3b` |

For a 4 GB Kali VM, the installer selects:

```text
qwen2.5-coder:1.5b
```

Model performance depends on RAM, CPU, GPU/VRAM, context size, and workload complexity.

## 💻 Hardware

### Minimum

```text
OS:       Kali / Debian / Ubuntu
RAM:      4 GB
CPU:      2 cores
Storage:  5+ GB free
GPU:      Not required
```

### Recommended

```text
RAM:      8–16 GB
CPU:      4+ cores
Storage:  30+ GB free
GPU:      Optional
```

## 🛠️ Components

### OpenCode
Provides the AI agent interface for project and terminal-oriented workflows.

### Ollama
Provides the local LLM runtime.

### Qwen2.5-Coder
Provides the lightweight local coding model selected by the installer.

## 📁 CTF Workspace

```text
~/CTF-AI/
│
├── AGENTS.md
├── README.md
├── web/
├── crypto/
├── reverse/
├── pwn/
├── forensics/
├── network/
├── osint/
├── malware/
├── scripts/
├── notes/
├── tools/
├── samples/
└── reports/
```

## ▶️ Start the Agent

```bash
source ~/.bashrc
ctf-ai
```

Or:

```bash
cd ~/CTF-AI
opencode
```

## 🔍 CTF Use Cases

### Web Security
- Source-code analysis
- HTTP request analysis
- Authentication logic
- Input validation
- JavaScript analysis
- API analysis
- Route analysis

### Cryptography
- Encoding identification
- XOR analysis
- Weak randomness
- RSA challenge analysis
- Mathematical calculations
- Python solver development

### Reverse Engineering
- ELF analysis
- Strings analysis
- Assembly explanation
- Control-flow reasoning
- Ghidra/radare2 assistance
- Python automation

### Pwn
- Binary protection analysis
- Crash analysis
- Memory corruption reasoning
- GDB assistance
- pwntools scripting

### Digital Forensics
- Log analysis
- File analysis
- Metadata
- PCAP investigation
- Timeline reasoning
- Memory-analysis scripting

### Network Analysis
- PCAP analysis
- DNS
- HTTP
- TCP/UDP
- Protocol identification
- tshark workflow generation

### Malware Analysis
- Static analysis
- Strings
- IOC extraction
- YARA rule development
- Script analysis

Unknown malware should only be executed in an isolated environment.

## 🔒 Privacy

The primary architecture is:

```text
User
  ↓
OpenCode
  ↓
Ollama
  ↓
Local Model
```

The local model runs on the user's machine. After the model is downloaded, inference can operate locally without sending CTF files or prompts to a cloud AI provider.

Initial installation and model downloads require Internet access.

## 🌐 Offline Usage

After all required components and model files have been downloaded, local inference can run without Internet access.

For a truly air-gapped deployment, all installers, packages, binaries, and model files must be transferred to the offline system beforehand.

## ⚙️ Installer Options

Normal installation:

```bash
./install_ctf_agent.sh
```

System check:

```bash
./install_ctf_agent.sh --check
```

Select a model manually:

```bash
./install_ctf_agent.sh --model qwen2.5-coder:1.5b
```

Skip model download:

```bash
./install_ctf_agent.sh --skip-model
```

Help:

```bash
./install_ctf_agent.sh --help
```

## 🦙 Ollama Commands

```bash
ollama list
ollama ps
ollama run qwen2.5-coder:1.5b
ollama --version
curl http://127.0.0.1:11434/api/tags
systemctl status ollama
```

## 🤖 OpenCode

```bash
opencode --version
cd ~/CTF-AI
opencode
```

If OpenCode is not found:

```bash
export PATH="$HOME/.opencode/bin:$HOME/.local/bin:$HOME/bin:$PATH"
```

## 🩺 Troubleshooting

### No space left on device

```bash
df -h
du -hxd1 ~ 2>/dev/null | sort -h
du -hxd2 ~/.ollama 2>/dev/null | sort -h
```

Free disk space and rerun the installer.

### Ollama is not running

```bash
systemctl status ollama
sudo systemctl restart ollama
curl http://127.0.0.1:11434/api/tags
```

### Model not found

```bash
ollama list
ollama pull qwen2.5-coder:1.5b
ollama run qwen2.5-coder:1.5b
```

## 🛡️ Security & Legal Disclaimer

This project is intended for:

- Capture The Flag competitions
- Cybersecurity education
- Security laboratories
- Authorized penetration testing
- Malware-analysis labs
- Intentionally vulnerable applications
- Local code and log analysis

Do not use this project against systems without authorization.

Unknown malware should only be analyzed in isolated environments.

The authors are not responsible for misuse of this software.

## 🗺️ Roadmap

- [x] Ollama integration
- [x] OpenCode integration
- [x] Lightweight model selection
- [x] RAM detection
- [x] Disk-space validation
- [x] CTF workspace generation
- [x] CTF-focused `AGENTS.md`
- [x] Health checks
- [x] Kali Linux support
- [ ] GPU-aware model selection
- [ ] Automatic CTF tool detection
- [ ] Ghidra integration
- [ ] radare2 integration
- [ ] Wireshark/tshark workflow
- [ ] Volatility workflow
- [ ] pwntools workflow
- [ ] YARA integration
- [ ] Docker-based isolation
- [ ] Offline model bundle support
- [ ] CTF prompt library
- [ ] Automated investigation reports
- [ ] Specialized CTF agents

## 🤝 Contributing

Fork the repository, create a feature branch, make your changes, and open a Pull Request.

```bash
git checkout -b feature/my-feature
git add .
git commit -m "Add new feature"
git push origin feature/my-feature
```

### 👨‍💻 Club Leadership

| **Role** | **Name** |
|----------|----------|
| **Vice President (Technical)** | **Zaber Mahmud** |
| **Title** | Cyber Security Researcher |
| **Organization** | **EWU Cybersecurity Club** |

This project is dedicated to the juniors of **EWU Cybersecurity Club**, with the goal of helping the next generation of cybersecurity learners explore **CTFs, ethical hacking, Linux, and security research** through a practical and offline AI-powered environment.

---

### ⭐ Star this repo if you find it helpful!

If you find this project useful, please consider giving it a **⭐ Star** and **🍴 Fork** it. Your support motivates us to keep improving and building more resources for the cybersecurity community.

> *From zero to cyber hero — one module at a time.*

**Made with 🔐 for the next generation of cybersecurity learners — EWU Cybersecurity Club**

---

> **Learn. Analyze. Automate. Solve CTFs — Locally.**
