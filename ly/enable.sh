#!/usr/bin/env bash
# Enable SweetPotato Ly login (disables SDDM). Requires root.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "${EUID}" -ne 0 ]]; then
  exec sudo "$0" "$@"
fi

pacman -S --needed --noconfirm ly

if [[ -f "${SCRIPT_DIR}/config.ini" ]]; then
  cp -f /etc/ly/config.ini /etc/ly/config.ini.bak.sweetpotato 2>/dev/null || true
  cp -f "${SCRIPT_DIR}/config.ini" /etc/ly/config.ini
fi

systemctl disable sddm.service 2>/dev/null || true
systemctl enable ly@tty2.service

echo
echo "Ly is enabled on tty2 with SweetPotato colors."
echo "Reboot to see the login screen. Pick the Sway session."
echo
