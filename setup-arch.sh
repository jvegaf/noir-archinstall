#!/usr/bin/env bash

# Install required packages
install_packages() {
  paru -Syu --needed --noconfirm "$@"
  # for pkg; do
  #   paru -S --needed --noconfirm "${pkg}"
  # done
}

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

set_variables() {
  sudo pacman -Syu --needed --noconfirm gum

  choice_backup_hook=$(gum choose "Yes" "No" --header "Would you like to setup a pacman hook that creates a copy of the /boot directory?")
  choice_microcode=$(gum choose "Intel" "AMD" "None" --header "Would you like to install processor microcode?")
  choice_nvidia=$(gum choose "Yes" "No" --header "Would you like to install Nvidia drivers?")
  choice_wm=$(gum choose "hyprland" "niri" "awesome" "i3" --no-limit --header "Choose window managers to be installed.")
  choice_apps=$(gum choose "Yes" "No" --header "Would you like to install apps (browsers, file managers, terminal emulators, etc.)?")
  choice_dotfiles=$(gum choose "Yes" "No" --header "Would you like to install Noir Dotfiles?")
  choice_wallpapers=$(gum choose "Yes" "No" --header "Would you like to install Noir Wallpapers?")
}

setup_backup_hook() {
  case "$choice_backup_hook" in
  Yes)
    echo "→ Setting up pacman boot backup hook..."
    echo "→ Configuring /boot backup when pacman transactions are made..."
    sudo -i -u root /bin/bash <<EOF
mkdir /etc/pacman.d/hooks
echo "[Trigger]
Operation = Upgrade
Operation = Install
Operation = Remove
Type = Path
Target = usr/lib/modules/*/vmlinuz

[Action]
Depends = rsync
Description = Backing up /boot...
When = PostTransaction
Exec = /usr/bin/rsync -a --delete /boot /.bootbackup" > /etc/pacman.d/hooks/50-bootbackup.hook
EOF
    ;;
  No) echo "→ Skipping setup of pacman boot backup hook..." ;;
  esac
}

install_window_managers() {
  IFS=', '
  for choice in "${choice_wm[@]}"; do
    case "$choice" in
    hyprland*)
      install_packages "${packages_hyprland[@]}"
      install_packages "${packages_common_wayland[@]}"
      ;;
    niri*)
      install_packages "${packages_niri[@]}"
      install_packages "${packages_common_wayland[@]}"
      ;;
    awesome*)
      install_packages "${packages_awesome[@]}"
      install_packages "${packages_common_x11[@]}"
      ;;
    i3*)
      install_packages "${packages_i3[@]}"
      install_packages "${packages_common_x11[@]}"
      ;;
    esac
  done
}

install_misc() {
  # Ollama
  curl -fsSL https://ollama.com/install.sh | sh
}

install_microcode() {
  case "$choice_microcode" in
  Intel)
    echo "→ Installing Intel microcode..."
    paru -Syu --needed --noconfirm intel-ucode
    ;;
  AMD)
    echo "→ Installing AMD microcode..."
    paru -Syu --needed --noconfirm amd-ucode
    ;;
  None) echo "→ Skipping installation of microcode..." ;;
  esac
}

install_nvidia_drivers() {
  case "$choice_nvidia" in
  Yes)
    echo "→ Installing Nvidia drivers..."
    install_packages "${packages_nvidia[@]}"
    ;;
  No) echo "→ Skipping installation of Nvidia drivers..." ;;
  esac
}

install_apps() {
  case "$choice_apps" in
  Yes)
    echo "→ Installing applications..."
    install_packages "${packages_apps[@]}"
    ;;
  No) echo "→ Skipping installation of apps..." ;;
  esac
}

setup_mpd() {
  mkdir ~/.local/share/mpd
  touch ~/.local/share/mpd/database
  mkdir ~/.local/share/mpd/playlists
  touch ~/.local/share/mpd/state
  touch ~/.local/share/mpd/sticker.sql

  systemctl --user enable --now mpd.service
  mpc update
}

install_dotfiles() {
  case "$choice_dotfiles" in
  Yes)
    echo "→ Installing Noir Dotfiles..."

    cd ~ || exit
    case "$choice_wallpapers" in
    Yes)
      git clone --depth 1 --recurse-submodules https://github.com/jvegaf/.noir-dotfiles.git
      ;;
    No)
      git clone --depth 1 https://github.com/jvegaf/.noir-dotfiles.git
      ;;
    esac
    cd .noir-dotfiles || exit
    stow .

    bat cache --build

    # Link user configs with root configs
    sudo mkdir /root/.config
    sudo ln -sf /home/"$USER"/.noir-dotfiles/.zshrc /root/.zshrc
    sudo ln -s /home/"$USER"/.noir-dotfiles/.config/zsh /root/.config/zsh
    sudo ln -sf /home/"$USER"/.noir-dotfiles/.config/starship.toml /root/.config/starship.toml
    sudo ln -s /home/"$USER"/.noir-dotfiles/.config/nvim /root/.config/nvim
    sudo mkdir -p /root/.cache/wal
    sudo ln -s /home/"$USER"/.noir-dotfiles/.cache/wal/colors-wal.vim /root/.cache/wal/colors-wal.vim

    # Setup pywalfox
    sudo pywalfox install

    return 0
    ;;
  No)
    echo "→ Skipping installation of Noir Dotfiles..."
    return 0
    ;;
  esac
}

clear

cat <<"EOF"
                    _        _____      _
     /\            | |      / ____|    | |
    /  \   _ __ ___| |__   | (___   ___| |_ _   _ _ __
   / /\ \ | '__/ __| '_ \   \___ \ / _ \ __| | | | '_ \
  / ____ \| | | (__| | | |  ____) |  __/ |_| |_| | |_) |
 /_/    \_\_|  \___|_| |_| |_____/ \___|\__|\__,_| .__/
                                                 | |
                                                 |_|
EOF

while true; do
  read -rp "Would you like to proceed with setup? (y/n): " answer
  case "$answer" in
  [Yy]*) break ;; # Proceed with the script
  *)
    echo "Exiting."
    exit 1
    ;; # Exit the script
  esac
done

# Create user folders
mkdir /home/"$USER"/Code
mkdir -p /home/"$USER"/.local/{bin,share/backgrounds,share/icons}
sudo mkdir /opt/"$USER"
sudo chown -R "$USER":"$USER" /opt/"$USER"

# Set global variables
set_variables

# Boot backup hook
setup_backup_hook

# Fix laptop lid acting like airplane mode key
echo "→ Fixing laptop lid acting like airplane mode key..."
sudo -i -u root /bin/bash <<EOF
mkdir /etc/rc.d
echo "#!/usr/bin/env bash
# Fix laptop lid acting like airplane mode key
setkeycodes d7 240
setkeycodes e058 142" > /etc/rc.d/rc.local
EOF

# ZRAM configuration
echo "→ Configuring ZRAM..."
sudo echo "[zram0]
zram-size = min(ram, 8192)" >/etc/systemd/zram-generator.conf

# Pacman eye-candy features
echo "→ Enabling colours and parallel downloads for pacman..."
sudo sed -Ei 's/^#(Color)$/\1/;s/^#(ParallelDownloads).*/\1 = 20/' /etc/pacman.conf

# Setup rust
echo "→ Installing Rust..."
sudo pacman -Syu --needed --noconfirm rustup
rustup default stable
cargo install grip-grab

# Install paru AUR Helper
if ! sudo pacman -Qs paru &> /dev/null; then
    echo "→ Installing paru..."
    sudo pacman -Syu --needed --noconfirm base-devel
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    cd /tmp/paru || exit
    makepkg -si --needed --noconfirm
fi

# Do an initial update
echo "→ Updating the system..."
paru -Syu --needed --noconfirm

# Install required packages
echo "→ Installing utility packages..."
install_packages "${packages_common_utils[@]}"

# Install window managers
install_window_managers

# Install fonts and missing firmware
echo "→ Installing fonts..."
install_packages "${packages_fonts[@]}"
echo "→ Installing potentially missing firmware..."
install_packages "${packages_firmware[@]}"

# Switch user and root shell to Zsh
echo "→ Switching user and root shell to Zsh..."
sudo chsh -s /usr/bin/zsh "$USER"
sudo chsh -s /usr/bin/zsh root

# Install miscellaneous packages
install_misc

# Install processor microcode
install_microcode

# Setup Nvidia drivers
install_nvidia_drivers

# Install apps
install_apps


# Setup mandatory mpd folders and files
echo "→ Setting up MPD..."
setup_mpd

# Set right-click dragging to resize windows in GNOME
echo "→ Setting right-click dragging to resize windows in GNOME..."
gsettings set org.gnome.desktop.wm.preferences resize-with-right-button true

# Update tealdeer cache
echo "→ Updating tealdeer cache..."
tldr --update

# Enable services
echo "→ Enabling systemctl services..."
systemctl --user enable pipewire
sudo systemctl enable bluetooth
sudo systemctl enable docker
sudo usermod -aG docker $USER
sudo groupadd dialout
sudo usermod -aG dialout $USER
sudo systemctl enable ollama

# Install Noir Dotfiles
until install_dotfiles; do :; done
