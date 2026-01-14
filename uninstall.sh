#!/usr/bin/env bash
#
# Uninstall ainvestigate
#
# Removes:
#   - ~/.local/bin/ainvestigate (or $XDG_BIN_HOME/ainvestigate)
#   - ~/.ainvestigate.sh
#   - ~/.ainvestigate*.conf files

set -euo pipefail

INSTALL_DIR="${XDG_BIN_HOME:-${HOME}/.local/bin}"
INSTALL_PATH="${INSTALL_DIR}/ainvestigate"

removed_count=0

remove_file() {
    local file="${1}"
    local description="${2:-}"

    if [[ -f "${file}" ]]; then
        rm -f "${file}"
        echo "Removed: ${file}${description:+ (${description})}"
        ((++removed_count))
    fi
}

main() {
    echo "Uninstalling ainvestigate..."
    echo

    # Remove the main script
    remove_file "${INSTALL_PATH}" "main script"

    # Remove session setup script
    remove_file "${HOME}/.ainvestigate.sh" "session setup script"

    # Remove config files
    for conf_file in "${HOME}"/.ainvestigate*.conf; do
        [[ -f "${conf_file}" ]] || continue
        remove_file "${conf_file}" "config file"
    done

    echo
    if [[ ${removed_count} -eq 0 ]]; then
        echo "Nothing to remove - ainvestigate was not installed."
    else
        echo "Removed ${removed_count} file(s)."
        echo
        echo "NOTE: If you used the script variant, you may want to remove"
        echo "the sourcing line from your shell rc file (~/.bashrc, ~/.zshrc, etc.):"
        echo
        echo "  # ainvestigate session logging"
        echo "  [ -f \"\${HOME}/.ainvestigate.sh\" ] && . \"\${HOME}/.ainvestigate.sh\""
    fi
}

main "$@"
