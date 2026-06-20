#!/bin/bash
# Hermes Agent Runner — Docker or Podman

set -e

PROJECT_NAME="hermes"
COMPOSE_FILE="docker-compose.yml"
FORCE_RUNTIME=""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

wait_for_health() {
    local service=$1
    local url=$2
    local max_attempts=${3:-30}
    local attempt=1

    echo -n "  Waiting for $service..."
    while [ $attempt -le $max_attempts ]; do
        if curl -sf "$url" >/dev/null 2>&1; then
            echo -e " ${GREEN}✓${NC}"
            return 0
        fi
        echo -n "."
        sleep 2
        attempt=$((attempt + 1))
    done
    echo -e " ${RED}✗${NC} Timeout waiting for $service"
    return 1
}

install_podman() {
    log_step "Installing Podman..."

    if [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            log_info "Installing Podman via Homebrew..."
            brew install podman
            log_info "Initializing Podman machine..."
            podman machine init
            podman machine start
        else
            log_error "Homebrew not found. Install Homebrew first:"
            echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            exit 1
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get &> /dev/null; then
            log_info "Installing Podman via apt..."
            sudo apt-get update
            sudo apt-get install -y podman
        elif command -v dnf &> /dev/null; then
            log_info "Installing Podman via dnf..."
            sudo dnf install -y podman
        elif command -v yum &> /dev/null; then
            log_info "Installing Podman via yum..."
            sudo yum install -y podman
        else
            log_error "Unsupported package manager. Install Podman manually."
            exit 1
        fi
    else
        log_error "Unsupported OS. Install Podman manually from: https://podman.io/getting-started/installation"
        exit 1
    fi

    log_info "Podman installed successfully!"
}

set_forced_runtime() {
    local runtime="$1"
    case "$runtime" in
        docker)
            RUNTIME="docker"
            COMPOSE_FILE="docker-compose.yml"
            COMPOSE_CMD="docker compose"
            ;;
        podman)
            RUNTIME="podman"
            COMPOSE_FILE="podman-compose.yml"
            if podman compose version &> /dev/null; then
                COMPOSE_CMD="podman compose"
            else
                COMPOSE_CMD="podman-compose"
            fi
            ;;
    esac
    log_info "Using $RUNTIME"
}

detect_runtime() {
    if [[ -n "$FORCE_RUNTIME" ]]; then
        set_forced_runtime "$FORCE_RUNTIME"
        return
    fi

    RUNTIME=""
    COMPOSE_FILE="docker-compose.yml"

    if command -v podman &> /dev/null; then
        RUNTIME="podman"
        COMPOSE_FILE="podman-compose.yml"
        if podman compose version &> /dev/null; then
            COMPOSE_CMD="podman compose"
        else
            COMPOSE_CMD="podman-compose"
        fi
    elif command -v docker &> /dev/null; then
        RUNTIME="docker"
        COMPOSE_FILE="docker-compose.yml"
        COMPOSE_CMD="docker compose"
    fi
}

choose_runtime() {
    if [ -n "$RUNTIME" ]; then
        case "$RUNTIME" in
            podman)
                COMPOSE_FILE="podman-compose.yml"
                if podman compose version &> /dev/null; then
                    COMPOSE_CMD="podman compose"
                else
                    COMPOSE_CMD="podman-compose"
                fi
                log_info "Using Podman"
                ;;
            docker)
                COMPOSE_FILE="docker-compose.yml"
                COMPOSE_CMD="docker compose"
                log_info "Using Docker"
                ;;
        esac
        return
    fi

    if command -v podman &> /dev/null; then
        RUNTIME="podman"
        COMPOSE_FILE="podman-compose.yml"
        if podman compose version &> /dev/null; then
            COMPOSE_CMD="podman compose"
        else
            COMPOSE_CMD="podman-compose"
        fi
        log_info "Using Podman (auto-detected)"
        return
    elif command -v docker &> /dev/null; then
        RUNTIME="docker"
        COMPOSE_FILE="docker-compose.yml"
        COMPOSE_CMD="docker compose"
        log_info "Using Docker (auto-detected)"
        return
    fi

    echo ""
    echo -e "${CYAN}────────────────────────────────────────────${NC}"
    echo -e "  Choose Container Runtime"
    echo -e "${CYAN}────────────────────────────────────────────${NC}"
    echo ""
    echo "   1) Podman (Recommended - Free, native)"
    echo "   2) Docker (Requires installation)"
    echo ""
    echo -e "${CYAN}────────────────────────────────────────────${NC}"
    echo ""

    read -p "Enter your choice [1-2]: " choice

    case $choice in
        1)
            if command -v podman &> /dev/null; then
                RUNTIME="podman"
                COMPOSE_FILE="podman-compose.yml"
                if podman compose version &> /dev/null; then
                    COMPOSE_CMD="podman compose"
                else
                    COMPOSE_CMD="podman-compose"
                fi
                log_info "Using Podman"
            else
                log_warn "Podman not installed"
                read -p "Install Podman now? [y/n]: " install_choice
                if [[ "$install_choice" == "y" || "$install_choice" == "Y" ]]; then
                    install_podman
                    RUNTIME="podman"
                    COMPOSE_FILE="podman-compose.yml"
                    if podman compose version &> /dev/null; then
                        COMPOSE_CMD="podman compose"
                    else
                        COMPOSE_CMD="podman-compose"
                    fi
                else
                    log_error "Podman is required to run Hermes"
                    exit 1
                fi
            fi
            ;;
        2)
            if command -v docker &> /dev/null; then
                RUNTIME="docker"
                COMPOSE_FILE="docker-compose.yml"
                COMPOSE_CMD="docker compose"
                log_info "Using Docker"
            else
                log_error "Docker is not installed!"
                echo ""
                echo -e "${YELLOW}Please install Docker Desktop:${NC}"
                echo "  macOS:  https://www.docker.com/products/docker-desktop"
                echo "  Linux:  https://docs.docker.com/engine/install/"
                echo ""
                exit 1
            fi
            ;;
        *)
            log_error "Invalid choice. Please enter 1 or 2"
            exit 1
            ;;
    esac

    echo ""
    log_info "Runtime: $RUNTIME"
    log_info "Config: $COMPOSE_FILE"
    echo ""
}

check_env() {
    if [ ! -f .env.ollama ]; then
        if [ -f sample.env.ollama ]; then
            cp sample.env.ollama .env.ollama
            log_warn ".env.ollama created from sample.env.ollama"
        fi
    fi
    if [ ! -f hermes-config/.env.hermes ]; then
        if [ -f hermes-config/sample.env.hermes ]; then
            cp hermes-config/sample.env.hermes hermes-config/.env.hermes
            log_warn "hermes-config/.env.hermes created from hermes-config/sample.env.hermes"
        fi
    fi
    if [ ! -f hermes-config/.env ]; then
        if [ -f hermes-config/.env.hermes ]; then
            cp hermes-config/.env.hermes hermes-config/.env
            log_warn "hermes-config/.env created from hermes-config/.env.hermes"
            log_warn "Edit hermes-config/.env.hermes and hermes-config/.env with your actual API keys"
        fi
    fi
}

setup_config() {
    if [ ! -d hermes-config ]; then
        mkdir -p hermes-config
    fi
}

require_runtime() {
    if [ -z "$RUNTIME" ]; then
        choose_runtime
    else
        choose_runtime
    fi
}

# Parse optional runtime argument ($2 = "docker" or "podman")
if [[ $# -ge 2 ]]; then
    case "$2" in
        docker|podman) FORCE_RUNTIME="$2" ;;
    esac
fi

case "${1:-help}" in
    start|install)
        detect_runtime
        require_runtime
        check_env
        setup_config
        log_info "Building custom Ollama image..."
        $COMPOSE_CMD -f "$COMPOSE_FILE" build ollama 2>/dev/null || log_warn "Image build skipped (already exists)"
        log_info "Pulling Hermes Agent image..."
        $COMPOSE_CMD -f "$COMPOSE_FILE" pull hermes-gateway hermes-chat
        log_info "Starting services..."
        $COMPOSE_CMD -f "$COMPOSE_FILE" up -d

        wait_for_health "Ollama" "http://localhost:11434/api/tags" 60

        log_info "Pulling default model to Ollama..."
        $COMPOSE_CMD -f "$COMPOSE_FILE" exec -T ollama ollama pull gemma4:8b 2>&1 || log_warn "Model pull may take time, continuing..."

        wait_for_health "Hermes" "http://localhost:9119" 30

        log_info "Hermes Agent started!"
        log_info "Dashboard: http://localhost:9119"
        log_info "Ollama: http://localhost:11434"
        echo ""
        log_info "To chat via CLI:"
        echo "  $COMPOSE_CMD exec hermes-chat sh -c '. /opt/hermes/.venv/bin/activate && hermes chat'"
        ;;
    down|stop)
        detect_runtime
        require_runtime
        log_info "Stopping Hermes..."
        $COMPOSE_CMD -f "$COMPOSE_FILE" down
        ;;
    restart)
        detect_runtime
        require_runtime
        $0 down
        sleep 1
        $0 start
        ;;
    logs)
        detect_runtime
        require_runtime
        $COMPOSE_CMD -f "$COMPOSE_FILE" logs -f
        ;;
    exec)
        shift
        if [ $# -eq 0 ]; then
            log_error "Usage: $0 exec <command>"
            exit 1
        fi
        detect_runtime
        require_runtime
        $COMPOSE_CMD -f "$COMPOSE_FILE" exec -T hermes-chat sh -c '. /opt/hermes/.venv/bin/activate && exec "$@"' -- "$@"
        ;;
    chat)
        shift
        detect_runtime
        require_runtime
        $COMPOSE_CMD -f "$COMPOSE_FILE" exec -T hermes-chat sh -c '. /opt/hermes/.venv/bin/activate && exec hermes chat -q "$1"' -- "${1:-}"
        ;;
    status|ps)
        detect_runtime
        require_runtime
        echo ""
        echo -e "${CYAN}────────────────────────────────────────────${NC}"
        echo -e "  Hermes Status"
        echo -e "${CYAN}────────────────────────────────────────────${NC}"
        echo ""
        $COMPOSE_CMD -f "$COMPOSE_FILE" ps
        echo ""
        echo -e "${CYAN}────────────────────────────────────────────${NC}"
        echo -e "  Health Checks"
        echo -e "${CYAN}────────────────────────────────────────────${NC}"
        echo ""

        if curl -sf http://localhost:11434/api/tags >/dev/null 2>&1; then
            echo -e "  ${GREEN}✓${NC} Ollama (localhost:11434)    - Running"
        else
            echo -e "  ${RED}✗${NC} Ollama (localhost:11434)    - Not responding"
        fi

        if curl -sf http://localhost:9119 >/dev/null 2>&1; then
            echo -e "  ${GREEN}✓${NC} Hermes (localhost:9119)     - Running"
        else
            echo -e "  ${RED}✗${NC} Hermes (localhost:9119)     - Not responding"
        fi

        echo ""
        ;;
    build)
        detect_runtime
        require_runtime
        log_info "Building images..."
        $COMPOSE_CMD -f "$COMPOSE_FILE" build
        ;;
    pull)
        detect_runtime
        require_runtime
        log_info "Pulling images..."
        $COMPOSE_CMD -f "$COMPOSE_FILE" pull
        ;;
    clean)
        detect_runtime
        require_runtime
        log_warn "Cleaning up..."
        $COMPOSE_CMD -f "$COMPOSE_FILE" down -v --remove-orphans 2>/dev/null || true
        ;;
    choose)
        choose_runtime
        echo ""
        log_info "Runtime set to: $RUNTIME"
        ;;
    help|--help|-h|"")
        echo ""
        echo -e "${CYAN}────────────────────────────────────────────${NC}"
        echo -e "  Hermes Runner Help"
        echo -e "${CYAN}────────────────────────────────────────────${NC}"
        echo ""
        echo "  ${GREEN}./run.sh start${NC}           Build & Start services"
        echo "  ${GREEN}./run.sh start docker${NC}     Start with Docker"
        echo "  ${GREEN}./run.sh start podman${NC}     Start with Podman"
        echo "  ${GREEN}./run.sh down${NC}            Stop Hermes"
        echo "  ${GREEN}./run.sh restart${NC}         Restart"
        echo "  ${GREEN}./run.sh logs${NC}            View logs"
        echo "  ${GREEN}./run.sh status${NC}          Show service status"
        echo "  ${GREEN}./run.sh chat${NC}            Open Hermes chat"
        echo "  ${GREEN}./run.sh exec${NC}            Run command inside container"
        echo "  ${GREEN}./run.sh build${NC}           Build images"
        echo "  ${GREEN}./run.sh clean${NC}           Clean volumes"
        echo ""
        echo -e "${CYAN}────────────────────────────────────────────${NC}"
        echo ""
        ;;
    *)
        log_error "Unknown command: $1"
        $0 help
        exit 1
        ;;
esac
