#!/usr/bin/env bash
# Apply SweetPotato colors to /etc/ly/config.ini and enable ly@tty2
set -euo pipefail

CFG="${1:-/etc/ly/config.ini}"
SUDO="${SUDO:-}"
[[ "$(id -u)" -eq 0 ]] && SUDO=""

if [[ ! -f "${CFG}" ]]; then
  echo "ly config missing: ${CFG} (is ly installed?)" >&2
  exit 1
fi

set_kv() {
  local key="$1" val="$2"
  if grep -q "^${key} = " "${CFG}"; then
    ${SUDO} sed -i "s|^${key} = .*|${key} = ${val}|" "${CFG}"
  else
    echo "${key} = ${val}" | ${SUDO} tee -a "${CFG}" >/dev/null
  fi
}

set_kv allow_empty_password false
set_kv animation none
set_kv asterisk '*'
set_kv bg 0x001d1f21
set_kv blank_box true
set_kv border_fg 0x00ffffff
set_kv box_title null
set_kv 'clock' '%H:%M'
set_kv default_input login
set_kv error_bg 0x001d1f21
set_kv error_fg 0x01a73b50
set_kv fg 0x00f5e6e8
set_kv full_color true
set_kv save true
set_kv shell false
set_kv xinitrc null
set_kv waylandsessions /etc/ly/wayland-sessions
set_kv xsessions null

echo "SweetPotato Ly theme applied to ${CFG}"
