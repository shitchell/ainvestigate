#!/usr/bin/env bash
#
# Install ainvestigate - AI-assisted terminal debugging
#
# Usage:
#   ./install.sh --tmux     # Install tmux variant (uses tmux scrollback)
#   ./install.sh --script   # Install script variant (uses script(1) logging)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${XDG_BIN_HOME:-${HOME}/.local/bin}"
INSTALL_PATH="${INSTALL_DIR}/ainvestigate"

usage() {
    cat << 'EOF'
Usage: ./install.sh [--tmux | --script]

Options:
    --tmux      Install tmux variant
                - Uses tmux scrollback buffer (zero overhead)
                - Only works inside tmux sessions

    --script    Install script variant
                - Uses script(1) for session logging
                - Works in any terminal
                - Sets up automatic session recording

If no option is provided, you will be prompted to choose.
EOF
}

prompt_variant() {
    echo "Which variant would you like to install?"
    echo
    echo "  1) tmux   - Uses tmux scrollback (zero overhead, tmux only)"
    echo "  2) script - Uses script(1) logging (works anywhere)"
    echo
    read -rp "Enter choice [1/2]: " choice
    case "${choice}" in
        1|tmux)   echo "tmux" ;;
        2|script) echo "script" ;;
        *)
            echo "error: invalid choice" >&2
            exit 1
            ;;
    esac
}

install_variant() {
    local variant="${1}"
    local source_script="${SCRIPT_DIR}/ainvestigate-${variant}"

    if [[ ! -f "${source_script}" ]]; then
        echo "error: ${source_script} not found" >&2
        exit 1
    fi

    # Create install directory if needed
    if [[ ! -d "${INSTALL_DIR}" ]]; then
        echo "Creating ${INSTALL_DIR}..."
        mkdir -p "${INSTALL_DIR}"
    fi

    # Check if already installed
    if [[ -f "${INSTALL_PATH}" ]]; then
        echo "Replacing existing installation at ${INSTALL_PATH}"
    fi

    # Copy the script
    cp "${source_script}" "${INSTALL_PATH}"
    chmod +x "${INSTALL_PATH}"
    echo "Installed ${variant} variant to ${INSTALL_PATH}"

    # For script variant, run --setup
    if [[ "${variant}" == "script" ]]; then
        echo
        echo "Running setup for script-based session logging..."
        "${INSTALL_PATH}" --setup
    fi

    echo
    echo "Installation complete!"

    # Check if install dir is in PATH
    if [[ ":${PATH}:" != *":${INSTALL_DIR}:"* ]]; then
        echo
        echo "NOTE: ${INSTALL_DIR} is not in your PATH."
        echo "Add this to your shell rc file:"
        echo "  export PATH=\"\${PATH}:${INSTALL_DIR}\""
    fi
}

main() {
    local variant=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "${1}" in
            --tmux)
                variant="tmux"
                ;;
            --script)
                variant="script"
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                echo "error: unknown option: ${1}" >&2
                usage >&2
                exit 1
                ;;
        esac
        shift
    done

    # Prompt if no variant specified
    if [[ -z "${variant}" ]]; then
        variant="$(prompt_variant)"
    fi

    install_variant "${variant}"
}

main "$@"
