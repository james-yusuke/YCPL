#!/usr/bin/env bash
set -euo pipefail

KEY_PATH="${GITHUB_SSH_KEY_PATH:-$HOME/.ssh/id_ed25519_github}"
GENERATE_KEY=0
PRINT_KEY=0
CONFIGURE_REMOTE=1
KEY_COMMENT=""

usage() {
    printf '%s\n' \
        "Usage: bash .devcontainer/github-ssh.sh [options]" \
        "" \
        "Options:" \
        "  --generate          Generate the GitHub SSH key if it does not exist." \
        "  --print             Print the public key." \
        "  --email EMAIL       Use EMAIL as the SSH key comment and git user.email." \
        "  --name NAME         Set git user.name." \
        "  --configure-only    Only prepare SSH config and Git remote." \
        "  --no-remote         Do not rewrite origin from HTTPS to SSH." \
        "  --help              Show this help."
}

ensure_ssh_dir() {
    mkdir -p "$HOME/.ssh"

    if [ ! -w "$HOME/.ssh" ] && command -v sudo >/dev/null 2>&1; then
        sudo chown -R "$(id -u):$(id -g)" "$HOME/.ssh"
    fi

    chmod 700 "$HOME/.ssh"
}

ensure_github_ssh_config() {
    local config="$HOME/.ssh/config"

    touch "$config"
    chmod 600 "$config"

    if ! grep -Eq '^[[:space:]]*Host[[:space:]]+github.com([[:space:]]|$)' "$config"; then
        {
            printf '\nHost github.com\n'
            printf '    HostName github.com\n'
            printf '    User git\n'
            printf '    IdentityFile %s\n' "$KEY_PATH"
            printf '    IdentitiesOnly yes\n'
            printf '    AddKeysToAgent yes\n'
            printf '    StrictHostKeyChecking accept-new\n'
        } >> "$config"
    fi
}

configure_git_identity() {
    local name="${1:-}"
    local email="${2:-}"

    if [ -n "$name" ]; then
        git config --global user.name "$name"
    fi

    if [ -n "$email" ]; then
        git config --global user.email "$email"
    fi
}

convert_github_remote_to_ssh() {
    if [ "$CONFIGURE_REMOTE" -ne 1 ]; then
        return 0
    fi

    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        return 0
    fi

    local url repo ssh_url
    url="$(git remote get-url origin 2>/dev/null || true)"

    case "$url" in
        https://github.com/*)
            repo="${url#https://github.com/}"
            repo="${repo%.git}"
            ssh_url="git@github.com:${repo}.git"
            git remote set-url origin "$ssh_url"
            printf 'Updated origin remote to %s\n' "$ssh_url"
            ;;
    esac
}

generate_key() {
    local comment="$KEY_COMMENT"

    if [ -z "$comment" ]; then
        comment="$(git config --global --get user.email 2>/dev/null || true)"
    fi

    if [ -z "$comment" ]; then
        comment="github"
    fi

    if [ -f "$KEY_PATH" ]; then
        printf 'SSH key already exists: %s\n' "$KEY_PATH"
    else
        ssh-keygen -t ed25519 -C "$comment" -f "$KEY_PATH" -N ""
        chmod 600 "$KEY_PATH"
        chmod 644 "$KEY_PATH.pub"
        printf 'Generated SSH key: %s\n' "$KEY_PATH"
    fi
}

print_public_key() {
    if [ ! -f "$KEY_PATH.pub" ]; then
        printf 'Public key not found: %s.pub\n' "$KEY_PATH" >&2
        printf 'Run: bash .devcontainer/github-ssh.sh --generate\n' >&2
        return 1
    fi

    printf '\nCopy this public key to GitHub SSH keys:\n\n'
    cat "$KEY_PATH.pub"
    printf '\n\nAfter adding it to GitHub, test with:\n'
    printf '  ssh -T git@github.com\n'
}

NAME_ARG=""
EMAIL_ARG=""

while [ "$#" -gt 0 ]; do
    case "$1" in
        --generate)
            GENERATE_KEY=1
            PRINT_KEY=1
            ;;
        --print)
            PRINT_KEY=1
            ;;
        --email)
            shift
            EMAIL_ARG="${1:-}"
            KEY_COMMENT="$EMAIL_ARG"
            ;;
        --name)
            shift
            NAME_ARG="${1:-}"
            ;;
        --configure-only)
            GENERATE_KEY=0
            PRINT_KEY=0
            ;;
        --no-remote)
            CONFIGURE_REMOTE=0
            ;;
        --help)
            usage
            exit 0
            ;;
        *)
            printf 'Unknown option: %s\n' "$1" >&2
            usage >&2
            exit 1
            ;;
    esac
    shift
done

ensure_ssh_dir
ensure_github_ssh_config
configure_git_identity "$NAME_ARG" "$EMAIL_ARG"
convert_github_remote_to_ssh

if [ "$GENERATE_KEY" -eq 1 ]; then
    generate_key
fi

if [ "$PRINT_KEY" -eq 1 ]; then
    print_public_key
fi

if [ "$GENERATE_KEY" -eq 0 ] && [ "$PRINT_KEY" -eq 0 ]; then
    printf 'GitHub SSH config is ready. Generate a key with:\n'
    printf '  bash .devcontainer/github-ssh.sh --generate --email you@example.com\n'
fi
