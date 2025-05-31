#!/usr/bin/env bash

# Install required packages
install_packages() {
  for pkg; do
    paru -S --needed --noconfirm "${pkg}" &>/dev/null
  done
}

packages_common_utils=(
  "git"
  "git-lfs"
  "lazygit"
  "intel-ucode"
  "pacman-contrib"
  "curl"
  "wget"
  "unzip"
  "rsync"
  "glibc"
  "cmake"
  "meson"
  "cpio"
  "uv"
  "go"
  "rustup"
  "luarocks"
  "nodejs"
  "npm"
  "podman"
  "pkgconf-pkg-config"
  "stow"
  "nwg-look"
  "zsh"
  "starship"
  "fzf"
  "zoxide"
  "lsd"
  "bat"
  "bat-extras"
  "cava"
  "brightnessctl"
  "playerctl"
  "pavucontrol"
  "alsa-utils"
  "pipewire"
  "lib32-pipewire"
  "pipewire-pulse"
  "pipewire-alsa"
  "pipewire-audio"
  "wireplumber"
  "btop"
  "network-manager-applet"
  "python3-pip"
  "python3-gobject"
  "gtk4"
  "fastfetch"
  "bluez"
  "bluez-utils"
  "blueman"
  "yt-dlp"
  "catppuccin-cursors-macchiato"
  "tela-circle-icon-theme-dracula"
  "ly"
  "ntfs-3g"
  "acpi"
  "libva-nvidia-driver"
  "zstd"
  "mlocate"
  "bind"
  "man-db"
  "man-pages"
  "tealdeer"
  "ark"
  "downgrade"
  "less"
  "ripgrep"
  "reflector"
  "pkgfile"
  "openvpn"
  "networkmanager-openvpn"
  "gvfs"
  "gvfs-mtp"
  "gvfs-smb"
  "ncdu"
  "dkms"
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
  "wofi"
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
  "ghostty"
  "firefox"
  "neovim"
  "vim"
  "nano"
  "vscodium-bin"
  "vscodium-bin-features"
  "vscodium-bin-marketplace"
  "mpd"
  "mpc"
  "mpv"
  "thunar"
  "thunar-archive-plugin"
  "thunar-media-tags-plugin"
  "thunar-shares-plugin"
  "thunar-vcs-plugin"
  "thunar-volman"
  "tumbler"
  "yazi"
  "imagemagick"
  "qbittorrent"
  "keepassxc"
  "calibre"
  "foliate"
  "okular"
  "discord"
  "filezilla"
  "filelight"
  "gnome-disk-utility"
)

packages_fonts=(
  "maplemono-ttf"
  "maplemono-nf-unhinted"
  "maplemono-nf-cn-unhinted"
  "gnu-free-fonts"
  "noto-fonts"
  "ttf-bitstream-vera"
  "ttf-croscore"
  "ttf-dejavu"
  "ttf-droid"
  "ttf-ibm-plex"
  "ttf-liberation"
  "wqy-zenhei"
  "ttf-mona-sans"
  "apple-fonts"
  "ttf-ms-fonts"
  "nerd-fonts"
)

packages_gaming=(
  "steam"
  "lutris"
  "umu-launcher"
)

packages_firmware=(
  "aic94xx-firmware"
  "ast-firmware"
  "linux-firmware-qlogic"
  "wd719x-firmware"
  "upd72020x-fw"
)

packages_nvidia=(
  "nvidia-dkms"
  "lib32-nvidia-utils"
  "nvidia-utils"
  "nvidia-settings"
)

select_window_managers() {
  IFS=', '
  read -p "→ Choose window managers to install (hyprland, niri, awesome, i3): " -a array
  for choice in "${array[@]}"; do
    case "$choice" in
    hyprland*) install_packages "${packages_hyprland[@]}" ;;
    niri*) install_packages "${packages_niri[@]}" ;;
    awesome*) install_packages "${packages_awesome[@]}" ;;
    i3*) install_packages "${packages_i3[@]}" ;;
    *) echo "→ Invalid window manager: $choice" ;;
    esac
  done
}

install_misc() {
  # RMPC Music player
  cargo install --git https://github.com/mierak/rmpc --locked

  # Wallust color scheme generator
  cargo install wallust

  # Ollama
  curl -fsSL https://ollama.com/install.sh | sh
}

install_gaming_tools() {
  read -p "Would you like to install gaming tools? (y/n): " answer
  case "$answer" in
  [Yy] | [Yy][Ee][Ss])
    echo "→ Installing gaming tools..."
    install_packages "${packages_gaming[@]}"
    ;;
  *) echo "→ Skipping installation of gaming tools..." ;;
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

install_flatpaks() {
  flatpak install flathub com.github.tchx84.Flatseal --assumeyes
  flatpak install flathub de.haeckerfelix.Shortwave --assumeyes
  flatpak install flathub io.gitlab.librewolf-community --assumeyes
  flatpak install flathub md.obsidian.Obsidian --assumeyes
  flatpak install flathub com.github.vikdevelop.photopea_app --assumeyes
}

install_ags() {
  paru -S --needed --noconfirm libastal-io-git libastal-git aylurs-gtk-shell
}

install_dotfiles() {
  read -p "Would you like to install Noir Dotfiles? (y/n): " answer_dotfiles
  case "$answer_dotfiles" in
  [Yy] | [Yy][Ee][Ss])
    echo "→ Installing Noir Dotfiles..."
    read -p "Would you like to install Noir Wallpapers? (y/n): " answer_wallpapers

    cd ~ || exit
    case "$answer_wallpapers" in
    [Yy] | [Yy][Ee][Ss])
      git clone --depth 1 --recurse-submodules https://github.com/somanoir/.noir-dotfiles.git
      ;;
    [Nn] | [Nn][Oo])
      git clone --depth 1 https://github.com/somanoir/.noir-dotfiles.git
      ;;
    esac
    cd .noir-dotfiles || exit
    stow .

    bat cache --build
    sudo flatpak override --filesystem=xdg-data/themes

    return 0
    ;;
  [Nn] | [Nn][Oo])
    echo "→ Skipping installation of Noir Dotfiles..."

    return 0
    ;;
  *)
    return 1
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

# Create user folders
mkdir /home/$USER/{Code,Games,Media,Misc,Mounts,My}
mkdir -p /home/$USER/.local/{bin,share/backgrounds,share/icons}

# Boot backup hook
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
sudo sed -Ei 's/^#(Color)$/\1/;s/^#(ParallelDownloads).*/\1 = 10/' /etc/pacman.conf

# Install paru AUR Helper
echo "→ Installing paru..."
sudo pacman -S --needed --noconfirm base-devel
git clone https://aur.archlinux.org/paru.git /tmp/paru
cd /tmp/paru
makepkg -si

# Do an initial update
echo "→ Updating the system..."
paru -Syu --needed --noconfirm

# Install required packages
echo "→ Installing utilities, WMs and applications.."
install_packages "${packages_common_utils[@]}"
install_packages "${packages_common_x11[@]}"
install_packages "${packages_common_wayland[@]}"

# Install window managers
select_window_managers

# Install fonts and apps
echo "→ Installing fonts..."
install_packages "${packages_fonts[@]}"
echo "→ Installing applications..."
install_packages "${packages_apps[@]}"
echo "→ Installing potentially missing firmware..."
install_packages "${packages_firmware[@]}"

# Switch user and root shell to Zsh
echo "→ Switching user and root shell to Zsh..."
sudo chsh -s /usr/bin/zsh $USER
sudo chsh -s /usr/bin/zsh root

# Setup rust
rustup default stable

# Install miscellaneous packages
install_misc

# Setup Nvidia drivers
echo "→ Installing Nvidia drivers..."
install_packages "${packages_nvidia[@]}"

# Install gaming tools
install_gaming_tools

# Setup mandatory mpd folders and files
echo "→ Setting up MPD..."
setup_mpd

# Install flatpaks
echo "→ Installing flatpaks..."
sudo pacman -S --needed --noconfirm flatpak
install_flatpaks

# Install AGS (Astal widgets)
echo "→ Installing AGS (Astal widgets)..."
install_ags

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
sudo systemctl enable podman
sudo systemctl enable ollama

# Install Noir Dotfiles
until install_dotfiles; do :; done
