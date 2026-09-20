#!/usr/bin/env bash
set -Eeuo pipefail

# Fedora fresh-install setup for the current user.
# Run with: bash /home/corox/Documents/fedora-post-install.sh

if [[ "${EUID}" -eq 0 ]]; then
    printf 'Run this script as your normal user, not root.\n' >&2
    exit 1
fi

if [[ ! -r /etc/fedora-release ]]; then
    printf 'This script is intended for Fedora. /etc/fedora-release was not found.\n' >&2
    exit 1
fi

if ! command -v sudo >/dev/null 2>&1; then
    printf 'sudo is required but was not found.\n' >&2
    exit 1
fi

printf 'Updating Fedora packages...\n'
sudo dnf --refresh upgrade -y

printf 'Installing setup tools and btop...\n'
sudo dnf install -y \
    btop \
    cabextract \
    curl \
    flatpak \
    gamemode \
    kde-cli-tools \
    mangohud \
    p7zip \
    p7zip-plugins \
    steam-devices \
    vulkan-tools \
    wine \
    winetricks

printf 'Installing 32-bit graphics libraries for gaming...\n'
if rpm -q xorg-x11-drv-nvidia-libs >/dev/null 2>&1; then
    sudo dnf install -y xorg-x11-drv-nvidia-libs.i686
else
    sudo dnf install -y \
        mesa-dri-drivers.i686 \
        mesa-vulkan-drivers.i686
fi

printf 'Configuring USB radio serial-port permissions...\n'
serial_groups=()
for serial_device in /dev/ttyUSB* /dev/ttyACM*; do
    if [[ -e "${serial_device}" ]]; then
        serial_group="$(stat -c '%G' "${serial_device}")"
        if [[ "${serial_group}" != "root" ]] && getent group "${serial_group}" >/dev/null 2>&1; then
            if [[ ! " ${serial_groups[*]} " =~ " ${serial_group} " ]]; then
                serial_groups+=("${serial_group}")
            fi
        fi
    fi
done

# Fedora normally assigns USB serial devices to dialout. Use it when the
# radio is not connected yet, and prefer the detected device group otherwise.
if [[ "${#serial_groups[@]}" -eq 0 ]] && getent group dialout >/dev/null 2>&1; then
    serial_groups+=(dialout)
fi

for serial_group in "${serial_groups[@]}"; do
    sudo usermod --append --groups "${serial_group}" "${USER}"
    printf 'Added %s to the %s group.\n' "${USER}" "${serial_group}"
done

printf 'Installing Brave Origin Nightly...\n'
curl -fsS https://dl.brave.com/install.sh | FLAVOR=origin CHANNEL=nightly sh

printf 'Enabling Flathub...\n'
if ! flatpak remote-list --user | awk '$1 == "flathub" { found = 1 } END { exit !found }'; then
    flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
fi

# Flatpak IDs provide stable, distribution-independent installs for these apps.
flatpak_apps=(
    org.keepassxc.KeePassXC
    com.giuspen.cherrytree
    com.visualstudio.code
    com.discordapp.Discord
    com.slack.Slack
    io.missioncenter.MissionCenter
    com.valvesoftware.Steam
    net.lutris.Lutris
    net.davidotek.pupgui2
    org.remmina.Remmina
    org.videolan.VLC
)

printf 'Installing desktop and gaming applications from Flathub...\n'
flatpak install --user -y flathub "${flatpak_apps[@]}"

printf 'Disabling KDE Wallet prompts...\n'
mkdir -p "${HOME}/.config"
if command -v kwriteconfig6 >/dev/null 2>&1; then
    kwriteconfig6 --file kwalletrc --group Wallet --key Enabled false
elif command -v kwriteconfig5 >/dev/null 2>&1; then
    kwriteconfig5 --file kwalletrc --group Wallet --key Enabled false
else
    config_file="${HOME}/.config/kwalletrc"
    if [[ -f "${config_file}" ]]; then
        sed -i '/^\[Wallet\]$/,/^\[/ { /^Enabled=/d; }' "${config_file}"
    else
        printf '[Wallet]\n' > "${config_file}"
    fi
    printf 'Enabled=false\n' >> "${config_file}"
fi

printf '\nSetup complete. Log out and back in, or restart KDE, for the wallet setting and serial-port permissions to fully take effect.\n'
