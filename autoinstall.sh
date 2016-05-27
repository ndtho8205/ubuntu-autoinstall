#!/bin/sh
if [ `id -u` != 0 ]
    then echo "Please run as root."
    exit
fi

# Black        0;30     Dark Gray     1;30
# Red          0;31     Light Red     1;31
# Green        0;32     Light Green   1;32
# Brown/Orange 0;33     Yellow        1;33
# Blue         0;34     Light Blue    1;34
# Purple       0;35     Light Purple  1;35
# Cyan         0;36     Light Cyan    1;36
# Light Gray   0;37     White         1;37
#

#------------------------------------------------------------------------------
#   Resources
#------------------------------------------------------------------------------
BOLD='\033[1m'
LBLUE='\033[1;34m'
LGREEN='\033[1;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'
#------------------------------------------------------------------------------
#   Variables
#------------------------------------------------------------------------------
TITLE=$YELLOW
H1=$BOLD$LBLUE
STT=$LGREEN
NC=$RESET
#------------------------------------------------------------------------------
#   Enviroments
#------------------------------------------------------------------------------
LOG_FILE='log_autoinstall.log'

PROGRAM='AutoInstall v1.1'
AUTHOR='Nguyen Duc Tho'
DESC='Tu dong cai dat software cho Ubuntu'

SETTING='Settings for Ubuntu...'
SET_1='Disable Guest login account'

PREPARE='Preparing for installation...'
PRE_1='Update the package lists'
PRE_2='Install the newest versions of all packages currently installed'

INSTALL_SOFTWARE='Installing softwares...'
INSTALL_INDICATOR='Installing indicators...'
INSTALL_THEME_ICON='Installing themes and icons...'
INSTALL_DEVENV="Installing games..."

CLEAN='Deleting temporary files...'

#------------------------------------------------------------------------------
#   Creation log file
#------------------------------------------------------------------------------
logit()
{
    echo "[${USER}][`date +'%D %H:%M:%S'`] - ${*}" >> ${LOG_FILE}
}

step()
{
    printf "${H1}${*}${NC}\n"
    logit ${*}
}

task()
{
    printf "${STT}[    ]${NC} ${*}"
    logit ${*}
}

status()
{
    printf "\r${STT}[DONE]${NC}\n"
}

execute()
{
    xterm -e "${*} | tee -a ${LOG_FILE}"
}

run()
{
    task $1
    execute $2
    status
}

add_ppa()
{
    grep -h "^deb.*$1" /etc/apt/sources.list.d/* > /dev/null 2>&1
    if [ $? -ne 0 ];
    then
        task "$1"
        execute "sudo add-apt-repository -y ppa:$1"
    else
        task "$1 already exists"
    fi
    status
    return 1
}

apt_install()
{
    # if [ $(dpkg-query -W -f='${Status}' $3 2>/dev/null | grep -c "ok installed") -eq $2 ];
    # then
    #     # task "$1"
    #     # execute "sudo apt-get install -y $3"
    #     echo "install"
    # fi
    # # else
	task "$1"
	execute "sudo apt-get install -y $2"
	status
}

#------------------------------------------------------------------------------
#   Begin
#------------------------------------------------------------------------------
echo
echo "${TITLE}${PROGRAM}${NC} - ${AUTHOR}"
echo "${DESC}"
echo
echo > ${LOG_FILE}
logit "${PROGRAM} - ${AUTHOR}"
#------------------------------------------------------------------------------
#   Settings
#------------------------------------------------------------------------------
step ${SETTING}
task ${SET_1}
# echo "allow-guest=false" | sudo tee -a /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf
logit "/usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf"
cat /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf >> ${LOG_FILE}
status
#------------------------------------------------------------------------------
#   Preparation
#------------------------------------------------------------------------------
step ${PREPARE}
run "${PRE_1}" "sudo apt-get update"
run "${PRE_2}" "sudo apt-get upgrade"
#------------------------------------------------------------------------------
#   Repositories
#------------------------------------------------------------------------------
step "Adding repositories..."
add_ppa "otto-kesselgulasch/gimp"
add_ppa "webupd8team/java"
add_ppa "wine/wine-builds"
add_ppa "webupd8team/y-ppa-manager"
add_ppa "linrunner/tlp"
add_ppa "umang/indicator-stickynotes"
add_ppa "fossfreedom/indicator-sysmonitor"
add_ppa "numix/ppa"
run "${PRE_1}" "sudo apt-get update"

#------------------------------------------------------------------------------
#   Installing
#------------------------------------------------------------------------------
step ${INSTALL_SOFTWARE}
apt_install "Ubuntu Restricted Extras" "ubuntu-restricted-extras ubuntu-restricted-addons"
apt_install "Codecs and Enable DVD Playback" "ffmpeg gxine libdvdread4 icedax tagtool libdvd-pkg easytag id3tool lame libxine2-ffmpeg nautilus-script-audio-convert libmad0 mpg321 libavcodec-extra gstreamer1.0-libav"
# sudo dpkg-reconfigure libdvd-pkg
apt_install "Compression/Decompression tools" "p7zip-rar p7zip-full unace unrar zip unzip sharutils rar uudeview mpack arj cabextract file-roller"
run "Remove openjdk packages" "sudo apt-get purge openjdk*"
apt_install "Java support" "oracle-java8-installer"
run "Config Java" "sudo update-alternatives --config java"
apt_install "Git" "git"
if [ $(getconf LONG_BIT) = "64" ];
    then
        run "Downloading Google Chrome..." "wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
        run "Google Chrome" "sudo dpkg -i google-chrome-stable_current_amd64.deb"
    else
        run "Downloading Google Chrome..." "wget https://dl.google.com/linux/direct/google-chrome-stable_current_i386.deb"
        run "Google Chrome" "sudo dpkg -i google-chrome-stable_current_i386.deb"
fi
apt_install "VLC media Player" "vlc"
apt_install "Gimp" "gimp gimp-data gimp-plugin-registry gimp-data-extras"
apt_install "Skype" "skype"
apt_install "GoldenDict" "goldendict"
apt_install "Synaptic" "synaptic"
apt_install "Gdebi" "gdebi"
apt_install "wine-staging" "--install-recommends wine-staging"
apt_install "winehq-staging" "winehq-staging"
apt_install "Y PPA Manager" "y-ppa-manager"
apt_install "TLP" "tlp tlp-rdw" && run "Start tlp" "sudo tlp start"
apt_install "Bleachbit" "bleachbit"
apt_install "Unity Tweak Tool" "unity-tweak-tool"
step ${INSTALL_INDICATOR}
apt_install "Sticky Notes" "indicator-stickynotes"
apt_install "SysMonitor" "indicator-sysmonitor"
step ${INSTALL_THEME_ICON}
apt_install "Numix icons" "numix-icon-theme-circle"
apt_install "Arc theme" "gnome-themes-standard gtk2-engines-murrine libgtk-3-dev autoconf automake"
execute "sudo rm -rf /usr/share/themes/{Arc,Arc-Darker,Arc-Dark}"
execute "rm -rf ~/.local/share/themes/{Arc,Arc-Darker,Arc-Dark}"
execute "rm -rf ~/.themes/{Arc,Arc-Darker,Arc-Dark}"
execute "git clone https://github.com/horst3180/arc-theme --depth 1"
execute "cd $(pwd)/arc-theme && ./autogen.sh --prefix=/usr"
execute "cd $(pwd)/arc-theme && sudo make install"
# cmake fcitx
step ${INSTALL_GAMES}
apt_install "Chess" "chess"
#------------------------------------------------------------------------------
#   After
#------------------------------------------------------------------------------
step ${CLEAN}
execute "sudo apt-get -y autoremove"
execute "sudo apt-get -y autoclean"
execute "sudo apt-get -y clean"
