#!/usr/bin/env bash
set -Eeuo pipefail

APP_NAME="Local CTF AI Agent"
CTF_DIR="${HOME}/CTF-AI"
OLLAMA_HOST_DEFAULT="127.0.0.1:11434"

MODEL_05B="qwen2.5-coder:0.5b"
MODEL_15B="qwen2.5-coder:1.5b"
MODEL_3B="qwen2.5-coder:3b"

MIN_FREE_MB=1500
MODEL=""

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; NC='\033[0m'

log(){ echo -e "${BLUE}[+]${NC} $1"; }
ok(){ echo -e "${GREEN}[✓]${NC} $1"; }
warn(){ echo -e "${YELLOW}[!]${NC} $1"; }
fail(){ echo -e "${RED}[✗]${NC} $1"; }
die(){ fail "$1"; exit 1; }

banner(){
    clear 2>/dev/null || true
    echo
    echo "============================================================"
    echo "              LOCAL CTF AI AGENT"
    echo "============================================================"
    echo
    echo "          Ollama + OpenCode + Local Model"
    echo
    echo "============================================================"
    echo
}

error_handler(){
    echo
    fail "Installation stopped because an error occurred."
    echo "Run: $0 --check"
}
trap error_handler ERR

check_user(){
    [[ "${EUID}" -ne 0 ]] || die "Do not run this installer as root."
    ok "Running as user: ${USER}"
}

detect_os(){
    [[ -f /etc/os-release ]] || die "/etc/os-release not found."
    . /etc/os-release
    echo
    log "Operating system: ${PRETTY_NAME}"
    case "${ID}" in
        kali|debian|ubuntu|linuxmint) ok "Supported Linux distribution." ;;
        *)
            warn "Designed for Kali/Debian/Ubuntu. Detected: ${ID}"
            read -r -p "Continue? [y/N]: " answer
            [[ "${answer}" =~ ^[Yy]$ ]] || exit 1
            ;;
    esac
}

detect_ram(){
    RAM_MB="$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo)"
    RAM_GB=$((RAM_MB / 1024))
    echo
    log "RAM detected: ${RAM_GB} GB"
    if (( RAM_MB < 3072 )); then
        MODEL="${MODEL_05B}"
    elif (( RAM_MB < 6144 )); then
        MODEL="${MODEL_15B}"
    else
        MODEL="${MODEL_3B}"
    fi
    ok "Selected model: ${MODEL}"
}

check_disk(){
    echo
    FREE_KB="$(df -Pk "${HOME}" | awk 'NR==2 {print $4}')"
    FREE_MB=$((FREE_KB / 1024))
    log "Free disk space: ${FREE_MB} MB"
    (( FREE_MB >= MIN_FREE_MB )) || die "At least ${MIN_FREE_MB} MB free disk space is recommended."
    ok "Disk space check passed."
}

command_exists(){ command -v "$1" >/dev/null 2>&1; }

install_dependencies(){
    echo
    log "Checking required dependencies..."
    local packages=()
    command_exists curl || packages+=("curl")
    command_exists git || packages+=("git")
    command_exists jq || packages+=("jq")
    command_exists python3 || packages+=("python3")
    command_exists rg || packages+=("ripgrep")

    if (( ${#packages[@]} == 0 )); then
        ok "Required dependencies already installed."
        return
    fi

    warn "Missing packages: ${packages[*]}"
    command_exists apt-get || die "apt-get is not available."
    sudo apt-get update
    sudo apt-get install -y "${packages[@]}"
    ok "Dependencies installed."
}

install_ollama(){
    echo
    if command_exists ollama; then
        ok "Ollama already installed."
        ollama --version || true
        return
    fi
    log "Installing Ollama..."
    curl -fsSL https://ollama.com/install.sh | sh
    export PATH="/usr/local/bin:${HOME}/.local/bin:${PATH}"
    command_exists ollama || die "Ollama installation failed."
    ok "Ollama installed."
}

start_ollama(){
    echo
    log "Starting Ollama..."
    export OLLAMA_HOST="${OLLAMA_HOST_DEFAULT}"

    if command_exists systemctl && systemctl list-unit-files 2>/dev/null | grep -q '^ollama.service'; then
        sudo systemctl enable ollama >/dev/null 2>&1 || true
        sudo systemctl start ollama >/dev/null 2>&1 || true
    fi

    if curl -fs "http://${OLLAMA_HOST_DEFAULT}/api/tags" >/dev/null 2>&1; then
        ok "Ollama API is running."
        return
    fi

    if ! pgrep -x ollama >/dev/null 2>&1; then
        log "Starting Ollama manually..."
        nohup ollama serve >"${HOME}/.ollama-server.log" 2>&1 &
        sleep 5
    fi

    curl -fs "http://${OLLAMA_HOST_DEFAULT}/api/tags" >/dev/null 2>&1 \
        || die "Ollama API did not start. Check: systemctl status ollama"
    ok "Ollama API is running."
}

install_model(){
    echo
    log "Checking model: ${MODEL}"
    if ollama list 2>/dev/null | awk 'NR>1 {print $1}' | grep -Fxq "${MODEL}"; then
        ok "Model already installed: ${MODEL}"
        return
    fi

    warn "Model is not installed: ${MODEL}"
    read -r -p "Download model now? [Y/n]: " answer
    [[ "${answer}" =~ ^[Nn]$ ]] && { warn "Skipping model download."; return; }

    log "Downloading ${MODEL}..."
    ollama pull "${MODEL}"
    ok "Model downloaded."
}

find_opencode(){
    export PATH="${HOME}/.opencode/bin:${HOME}/.local/bin:${HOME}/bin:${PATH}"
    command_exists opencode
}

install_opencode(){
    echo
    if find_opencode; then
        ok "OpenCode already installed."
        opencode --version || true
        return
    fi

    log "Installing OpenCode..."
    curl -fsSL https://opencode.ai/install | bash
    export PATH="${HOME}/.opencode/bin:${HOME}/.local/bin:${HOME}/bin:${PATH}"
    hash -r

    if find_opencode; then
        ok "OpenCode installed."
        opencode --version || true
    else
        warn "OpenCode was installed but is not currently in PATH."
        warn "Try: export PATH=\"\$HOME/.opencode/bin:\$HOME/.local/bin:\$PATH\""
    fi
}

create_workspace(){
    echo
    log "Creating CTF workspace..."
    local dirs=(web crypto reverse pwn forensics network osint malware scripts notes tools samples reports)
    mkdir -p "${CTF_DIR}"
    for dir in "${dirs[@]}"; do mkdir -p "${CTF_DIR}/${dir}"; done
    ok "Workspace created: ${CTF_DIR}"
}

create_agent_instructions(){
    cat > "${CTF_DIR}/AGENTS.md" <<'EOF'
# Local CTF AI Agent Instructions

You are assisting with authorized CTFs, cyber ranges, labs,
malware-analysis samples, intentionally vulnerable applications,
and cybersecurity education.

## General Rules

1. Prefer explaining reasoning before complex actions.
2. Work inside the current CTF workspace.
3. Do not target real-world systems without authorization.
4. Do not expose secrets, credentials, API keys, or private data.
5. Avoid destructive commands.
6. Prefer read-only analysis before modifying files.
7. Explain commands before risky operations.

## CTF Workflow

### Web
Inspect source code, HTTP requests, parameters, cookies, headers,
routes, JavaScript, and authentication logic.

### Crypto
Identify algorithms, encodings, key reuse, weak randomness,
mathematical weaknesses, and build Python solvers.

### Forensics
Inspect files, metadata, logs, PCAP, memory dumps, registry
artifacts, and timestamps.

### Reverse Engineering
Use strings, file, objdump, readelf, radare2, Ghidra, and Python.

### Pwn
Analyze architecture, protections, crashes, memory corruption,
stack layout, and input handling in authorized CTFs.

### Network
Analyze PCAP, protocols, IPs, ports, DNS, HTTP, and TLS metadata.

### Malware
Treat unknown binaries as untrusted. Prefer static analysis and
use isolated environments for execution.

## Output

For CTF problems, provide:
1. Observation
2. Analysis
3. Evidence
4. Hypothesis
5. Verification
6. Solution
7. Learning point
EOF
    ok "AGENTS.md created."
}

create_workspace_readme(){
    cat > "${CTF_DIR}/README.md" <<EOF
# Local CTF AI Workspace

Agent: OpenCode
Runtime: Ollama
Model: ${MODEL}

Directories:
web/
crypto/
reverse/
pwn/
forensics/
network/
osint/
malware/
scripts/
notes/
tools/
samples/
reports/

Start:
cd ~/CTF-AI
opencode
EOF
    ok "Workspace README created."
}

create_launcher(){
    echo
    log "Creating ctf-ai launcher..."
    local bin_dir="${HOME}/.local/bin"
    mkdir -p "${bin_dir}"

    cat > "${bin_dir}/ctf-ai" <<'EOF'
#!/usr/bin/env bash
set -e
export PATH="$HOME/.opencode/bin:$HOME/.local/bin:$HOME/bin:$PATH"

if ! command -v ollama >/dev/null 2>&1; then
    echo "[!] Ollama is not installed."
    exit 1
fi

if ! pgrep -x ollama >/dev/null 2>&1; then
    echo "[+] Starting Ollama..."
    nohup ollama serve >"$HOME/.ollama-server.log" 2>&1 &
    sleep 5
fi

mkdir -p "$HOME/CTF-AI"
cd "$HOME/CTF-AI"

if ! command -v opencode >/dev/null 2>&1; then
    echo "[!] OpenCode is not available."
    exit 1
fi

exec opencode
EOF

    chmod +x "${bin_dir}/ctf-ai"
    ok "Launcher created: ${bin_dir}/ctf-ai"
}

setup_path(){
    local rc="${HOME}/.bashrc"
    if [[ -f "${rc}" ]] && ! grep -qF '$HOME/.opencode/bin' "${rc}"; then
        cat >> "${rc}" <<'EOF'

# Local CTF AI Agent
export PATH="$HOME/.opencode/bin:$HOME/.local/bin:$HOME/bin:$PATH"
EOF
    fi
    export PATH="${HOME}/.opencode/bin:${HOME}/.local/bin:${HOME}/bin:${PATH}"
    ok "PATH configured."
}

health_check(){
    echo
    echo "============================================================"
    echo "                     HEALTH CHECK"
    echo "============================================================"
    echo

    command_exists ollama && ok "Ollama: installed" || warn "Ollama: missing"
    curl -fs "http://${OLLAMA_HOST_DEFAULT}/api/tags" >/dev/null 2>&1 \
        && ok "Ollama API: running" || warn "Ollama API: not responding"

    ollama list 2>/dev/null | awk 'NR>1 {print $1}' | grep -Fxq "${MODEL}" \
        && ok "Model: ${MODEL}" || warn "Model: ${MODEL} not installed"

    find_opencode && ok "OpenCode: installed" || warn "OpenCode: not found"
    [[ -d "${CTF_DIR}" ]] && ok "CTF workspace: ${CTF_DIR}" || warn "CTF workspace missing"
    echo
}

system_info(){
    echo
    echo "============================================================"
    echo "                  SYSTEM INFORMATION"
    echo "============================================================"
    echo
    grep PRETTY_NAME /etc/os-release || true
    echo "Kernel: $(uname -r)"
    echo "CPU: $(nproc) cores"
    echo "RAM:"
    free -h
    echo "Disk:"
    df -h "${HOME}"
    echo
}

check_mode(){
    banner
    check_user
    detect_os
    detect_ram
    check_disk
    system_info
}

parse_args(){
    SKIP_MODEL="no"
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --check) check_mode; exit 0 ;;
            --model) [[ -n "${2:-}" ]] || die "--model requires a value"; MODEL="$2"; shift 2 ;;
            --skip-model) SKIP_MODEL="yes"; shift ;;
            --help|-h)
                echo "Usage:"
                echo "  $0"
                echo "  $0 --check"
                echo "  $0 --model MODEL"
                echo "  $0 --skip-model"
                exit 0
                ;;
            *) die "Unknown option: $1" ;;
        esac
    done
}

main(){
    parse_args "$@"
    banner
    check_user
    detect_os
    [[ -n "${MODEL}" ]] || detect_ram
    check_disk
    install_dependencies
    install_ollama
    start_ollama

    if [[ "${SKIP_MODEL}" != "yes" ]]; then
        install_model
    else
        warn "Model download skipped."
    fi

    install_opencode
    create_workspace
    create_agent_instructions
    create_workspace_readme
    create_launcher
    setup_path
    health_check

    echo
    echo "============================================================"
    echo "              INSTALLATION COMPLETE"
    echo "============================================================"
    echo
    echo "Start:"
    echo "  source ~/.bashrc"
    echo "  ctf-ai"
    echo
}

main "$@"
