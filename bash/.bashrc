#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return
set -o vi

#alias ls='ls --color=auto'
#alias rb='bundle exec ruby'
#alias jv='java -jar'
#alias mm='mvn test'
#alias nn='npx mocha'
#alias ranger='ranger --choosedir=/tmp/.rangerdir; LASTDIR=`cat /tmp/.rangerdir`; cd "$LASTDIR"'
#alias postman='~/AUR/postman-bin/pkg/postman-bin/opt/postman/app/Postman'
#alias appium-desktop='/home/noodle/Android/squashfs-root/AppRun'
#alias appium-inspector='/home/noodle/Android/squashfs-root/AppRun'
#alias appium='appium --allow-cors'
#alias sonic-pi-d='jackd -d alsa -d hw:1'
#alias upwork='AUR/upwork/pkg/upwork/opt/Upwork/upwork'
#alias appimage='sudo ~/AUR/appimage/squashfs-root/AppRun'
#alias fff='flutter run -d linux'
#alias ffc='flutter run -d chrome --web-renderer=html'
#alias ffcc='flutter run -d chrome --web-renderer=canvaskit'
#alias ffe='flutter run -d emulator-5554'
#alias pp='python -m pytest test'
alias neofetch='neofetch --ascii_colors 8 --colors 7 8 7 8 8 7'
alias fp='sudo pacman --downloadonly --cachedir=/tmp -Sw'
alias ll='export JANCOK=1'

alias xx='xrandr --output DisplayPort-0 --mode 1680x1050 --scale 1x1 --rotate normal'



#PS1='[\u@\h \W]\$ '

parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
PS1='$(parse_git_branch)[\u@\h \W]$ '

export EDITOR="vim"
#export JAVA_HOME="/opt/android-studio/jre/"
export _JAVA_AWT_WM_NONREPARENTING=1
#export ANDROID_HOME="/home/noodle/Android/Sdk"
#export GH_DEBUG=true
#export MAVEN_HOME="~/AUR/apache-maven-3.9.0"
export PATH="${PATH}:/home/noodle/apps/bin"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/home/noodle/apps/lib"
#export PATH="${PATH}:${ANDROID_HOME}/build-tools"
#export PATH="${PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin"
#export PATH="${PATH}:${ANDROID_HOME}/emulator"
#export PATH="${PATH}:${ANDROID_HOME}/platform-tools"
#export PATH="${PATH}:${ANDROID_HOME}/tools"
#export PATH="${PATH}:${ANDROID_HOME}/tools/bin"
#export PATH="${PATH}:/opt/android-studio/jre/bin/"
#export PATH="${PATH}:~/AUR/flutter/bin/"
#export PATH="${PATH}:~/.local/ruby-2.7.0/bin/"
#export PATH="${PATH}:${MAVEN_HOME}/bin/"
#export CHROME_EXECUTABLE="/usr/bin/google-chrome-stable"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
#[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


#GIMP
#export PATH="${PATH}:~/winedoews/usr/bin"
#export LD_LIBRARY_PATH=~/winedoews/usr/lib
#export BABL_PATH=~/winedoews/usr/lib/babl-0.1
#export GEGL_PATH=~/winedoews/usr/lib/gegl-0.4/

