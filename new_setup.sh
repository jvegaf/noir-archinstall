#!/usr/bin/env bash
set -euo pipefail

# VARIABLES GLOBALES
USER_HOME="/home/$USER"
OPT_USER="/opt/$USER"
TMP_PARU="/tmp/paru"

# FUNCIONES DE MANEJO DE ERRORES
error_exit() {
  echo "Error en la línea $1: $2"
  exit 1
}
trap 'error_exit $LINENO "$BASH_COMMAND"' ERR

# COMPROBAR QUE ES ARCH LINUX
# if ! grep -qi "arch" /etc/os-release; then
#   echo "Este script solo funciona en Arch Linux."
#   exit 1
# fi

# COMPROBAR DEPENDENCIAS
for dep in gum git curl; do
  if ! command -v "$dep" &>/dev/null; then
    echo "Instalando dependencia: $dep"
    sudo pacman -Syu --needed --noconfirm "$dep"
  fi
done

# INSTALAR PARU SI NO EXISTE
if ! command -v paru &>/dev/null; then
  echo "Instalando paru (AUR Helper)..."
  sudo pacman -Syu --needed --noconfirm base-devel
  git clone https://aur.archlinux.org/paru.git "$TMP_PARU"
  cd "$TMP_PARU" || exit
  makepkg -si --needed --noconfirm
  cd - || exit
  rm -rf "$TMP_PARU"
fi

# FUNCION PARA INSTALAR PAQUETES
install_packages() {
  local pkgs=("$@")
  for pkg in "${pkgs[@]}"; do
    paru -Syu --needed --noconfirm "$pkg" || echo "Error instalando $pkg, continuando..."
  done
}

# ARRAYS DE PAQUETES (revisar duplicados antes)
packages_common_utils=(
  "acpi"
  "adw-gtk-theme"
  "alsa-utils"
  "archlinux-xdg-menu"
  "ark"
  "bat"
  "bat-extras"
  "bibata-cursor-theme"
  "bind"
  "blueman"
  "bluez"
  "bluez-utils"
  "brightnessctl"
  "btop"
  "cava"
  "cmake"
  "cpio"
  "curl"
  "dkms"
  "docker"
  "docker-compose"
  "downgrade"
  "eww-git"
  "eza"
  "fastfetch"
  "fzf"
  "git"
  "git-lfs"
  "github-cli"
  "glibc"
  "gnome-keyring"
  "go"
  "gtk4"
  "gvfs"
  "gvfs-mtp"
  "gvfs-smb"
  "kitty"
  "lazygit"
  "less"
  "lib32-pipewire"
  "libva-nvidia-driver"
  "lsd"
  "luarocks"
  "ly"
  "man-db"
  "man-pages"
  "matugen-bin"
  "meson"
  "mise"
  "mlocate"
  "ncdu"
  "net-tools"
  "network-manager-applet"
  "networkmanager-openvpn"
  "ntfs-3g"
  "nwg-look"
  "pacman-contrib"
  "pavucontrol"
  "pipewire"
  "pipewire-alsa"
  "pipewire-audio"
  "pipewire-pulse"
  "pkgconf-pkg-config"
  "pkgfile"
  "playerctl"
  "python-pywalfox"
  "python-gobject"
  "python-pip"
  "python-pipx"
  "python-pynvim"
  "qt5ct-kde"
  "qt6ct-kde"
  "reflector"
  "ripgrep"
  "rsync"
  "sad"
  "sshfs"
  "superfile"
  "starship"
  "stow"
  "tealdeer"
  "tela-circle-icon-theme-dracula"
  "tmux"
  "unarchiver"
  "unzip"
  "uv"
  "wallust"
  "wget"
  "wireguard-tools"
  "wireplumber"
  "yt-dlp"
  "zoxide"
  "zsh"
  "zstd"
)

packages_common_x11=(
  "xorg"
  "xsel"
  "dex"
  "xdotool"
  "xclip"
  "cliphist"
  "xinput"
  "rofi"
  "polybar"
  "dunst"
  "feh"
  "maim"
  "picom"
)

packages_common_wayland=(
  "qt5-wayland"
  "qt6-wayland"
  "egl-wayland"
  "wlr-randr"
  "wlogout"
  "wl-clipboard"
  "copyq"
  "rofi-wayland"
  "waybar"
  "mako"
  "swww"
)

packages_hyprland=(
  "hyprland"
  "hyprutils"
  "hyprpicker"
  "hyprpolkitagent"
  "hyprshot"
  "xdg-desktop-portal-hyprland"
  "hyprlock"
  "pyprland"
  "hypridle"
  "uwsm"
)

packages_niri=(
  "niri"
  "xwayland-satellite"
  "xdg-desktop-portal-gnome"
)

packages_awesome=(
  "awesome"
  "lain"
  "polkit-gnome"
)

packages_i3=(
  "i3-wm"
  "i3lock"
  "autotiling"
)

packages_apps=(
  "clock-rs-git"
  "dolphin"
  "filelight"
  "firefox"
  "foliate"
  "ghostty"
  "gnome-disk-utility"
  "imagemagick"
  "lazydocker"
  "lazygit"
  "mpc"
  "mpd"
  "mpv"
  "nano"
  "neovim"
  "nomacs"
  "okular"
  "orca-slicer-unstable-bin"
  "qalculate-gtk"
  "qbittorrent"
  "rmpc"
  "shortwave"
  "superfile"
  "vim"
  "vscodium-bin"
  "vscodium-bin-marketplace"
  "yazi"
)

packages_fonts=(
  "maplemono-ttf"
  "noto-fonts"
  "noto-fonts-emoji"
  "apple-fonts"
  "ttf-ms-fonts"
  "otf-font-awesome"
)

packages_firmware=(
  "aic94xx-firmware"
)

packages_nvidia=(
  "nvidia-dkms"
  "lib32-nvidia-utils"
  "nvidia-utils"
  "nvidia-settings"
)

# OPCIONES INTERACTIVAS
choice_backup_hook=$(gum choose "Yes" "No" --header "¿Configurar hook de backup de /boot?")
choice_microcode=$(gum choose "Intel" "AMD" "None" --header "¿Instalar microcode del procesador?")
choice_nvidia=$(gum choose "Yes" "No" --header "¿Instalar drivers Nvidia?")
choice_wm=$(gum choose "hyprland" "niri" "awesome" "i3" --no-limit --header "Elige window managers a instalar.")
choice_apps=$(gum choose "Yes" "No" --header "¿Instalar aplicaciones?")
choice_dotfiles=$(gum choose "Yes" "No" --header "¿Instalar Noir Dotfiles?")
choice_wallpapers=$(gum choose "Yes" "No" --header "¿Instalar Noir Wallpapers?")

# FUNCIONES DE INSTALACIÓN
setup_backup_hook() {
  if [[ "$choice_backup_hook" == "Yes" ]]; then
    sudo mkdir -p /etc/pacman.d/hooks
    sudo tee /etc/pacman.d/hooks/50-bootbackup.hook >/dev/null <<EOF
[Trigger]
Operation = Upgrade
Operation = Install
Operation = Remove
Type = Path
Target = usr/lib/modules/*/vmlinuz
[Action]
Depends = rsync
Description = Backing up /boot...
When = PostTransaction
Exec = /usr/bin/rsync -a --delete /boot /.bootbackup
EOF
  fi
}

install_window_managers() {
  for choice in "${choice_wm[@]}"; do
    case "$choice" in
    hyprland) install_packages "${packages_hyprland[@]}" "${packages_common_wayland[@]}" ;;
    niri) install_packages "${packages_niri[@]}" "${packages_common_wayland[@]}" ;;
    awesome) install_packages "${packages_awesome[@]}" "${packages_common_x11[@]}" ;;
    i3) install_packages "${packages_i3[@]}" "${packages_common_x11[@]}" ;;
    esac
  done
}

install_misc() {
  curl -fsSL https://ollama.com/install.sh | sh
}

install_microcode() {
  case "$choice_microcode" in
  Intel) install_packages intel-ucode ;;
  AMD) install_packages amd-ucode ;;
  esac
}

install_nvidia_drivers() {
  [[ "$choice_nvidia" == "Yes" ]] && install_packages "${packages_nvidia[@]}"
}

install_apps() {
  [[ "$choice_apps" == "Yes" ]] && install_packages "${packages_apps[@]}"
}

install_dotfiles() {
  [[ "$choice_dotfiles" == "Yes" ]] || return
  cd "$USER_HOME"
  if [[ "$choice_wallpapers" == "Yes" ]]; then
    git clone --depth 1 --recurse-submodules https://github.com/jvegaf/.noir-dotfiles.git
  else
    git clone --depth 1 https://github.com/jvegaf/.noir-dotfiles.git
  fi
  cd .noir-dotfiles
  stow . --adopt
  ln -s ./gitconfig ~/.gitconfig
  sudo cp 50-udisks.rules /etc/polkit-1/rules.d/
}

# CREAR CARPETAS DE USUARIO
mkdir -p "$USER_HOME/Code" "$USER_HOME/.local/bin" "$USER_HOME/.local/share/backgrounds" "$USER_HOME/.local/share/icons"
sudo mkdir -p "$OPT_USER"
sudo chown -R "$USER:$USER" "$OPT_USER"

# INSTALACIONES PRINCIPALES
setup_backup_hook
install_packages "${packages_common_utils[@]}"
install_window_managers
install_packages "${packages_fonts[@]}"
install_packages "${packages_firmware[@]}"
install_misc
install_microcode
install_nvidia_drivers
install_apps
install_dotfiles

# CAMBIAR SHELL
sudo chsh -s /usr/bin/zsh "$USER"
sudo chsh -s /usr/bin/zsh root

# LOG Y SERVICIOS
echo "Habilitando servicios..."
systemctl --user enable pipewire
sudo systemctl enable bluetooth
sudo systemctl enable docker
sudo usermod -aG docker "$USER"
sudo systemctl enable ollama

echo "Script completado exitosamente."
