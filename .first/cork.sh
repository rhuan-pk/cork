#!/usr/bin/env bash

# ===========================================================
#
# Script para instalação automatizada dos programas
# de cada usuário
#
# ===========================================================

# ===========================================================
#
# Sessão de declaração de funções
#
# ===========================================================

# Passa a senha para o comando sudo

auto_sudo() {

	echo -e "${password}\n" | sudo -S $1

}

# CHROME

fun0() {

	wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	auto_sudo "dpkg -i ./google*.deb"

}

# VS-CODE

fun1() {

	wget -O- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
	auto_sudo "install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/"
	echo -e "${password}\n" | sudo -S sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
	rm -f packages.microsoft.gpg
	auto_sudo "apt install apt-transport-https -y"
	auto_sudo "apt update -y"
	auto_sudo "apt install code -y"
	# auto_sudo "apt install code-insiders -y"

}

# DISCORD

fun2() {

	wget -O discord_tmp.deb "https://discord.com/api/download?platform=linux&format=deb"
	sleep 10
	auto_sudo "dpkg -i ./discord*.deb"
	auto_sudo "apt install -f -y"
	# Talvez haverá a necessidade de descomentar a linha a baixo
	# auto_sudo "dpkg -i ./discord*.deb"

}

# FILEZILLA

fun3() {

	auto_sudo "apt install filezilla -y"

}

# ANYDESK

fun4() {

	echo -e "${password}\n" | sudo -S su -c "wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | apt-key add - 2>> /dev/null"
	echo -e "${password}\n" | sudo -S su -c "echo 'deb http://deb.anydesk.com/ all main' > /etc/apt/sources.list.d/anydesk-stable.list"
	auto_sudo "apt update -y"
	auto_sudo "apt install anydesk -y"

}

# POSTMAN

fun5() {

	wget https://dl.pstmn.io/download/latest/linux64 -O postman_temp.tar.gz
	auto_sudo "tar -zxvf postman*.tar.gz -C /opt/"
	auto_sudo "ln -s /opt/Postman/Postman /usr/bin/postman"
	echo -e "[Desktop Entry]\n\tEncoding=UTF-8\n\tName=Postman\n\tComment=Postman API Client\n\tIcon=/opt/Postman/app/resources/app/assets/icon.png\n\tExec=/usr/bin/postman\n\tTerminal=false\n\tType=Application\n\tCategories=Desenvolvimento" > ${HOME}/.local/share/applications/postman.desktop
	chmod +x ${HOME}/.local/share/applications/postman.desktop

}

# MY-SQL/WORKBENCH

fun6() {

	auto_sudo "apt install mysql-server -y"

	echo ""
	echo "--- workbench ---"
	echo ""

	auto_sudo "snap install mysql-workbench-community"

}

# SIMPLESCREENRECORDER

fun7() {

	auto_sudo "apt install simplescreenrecorder -y"

}

# FLAMESHOT

fun8() {

	auto_sudo "apt install flameshot -y"

}

# KOLOURPAINT

fun9() {

	auto_sudo "apt install kolourpaint -y"

}

# NPM

fun10() {

	auto_sudo "apt install npm -y"

}

# Cria o arquivo que conterá os programas instalados

arquivo_programas() {

	for ((i=0; i<${#array_program[@]}; ++i)); do

		echo "${array_program[$i]}:${array_answer[$i]^^}" >> ./temp.txt

	done

	arq=./temp.txt

	printf '\n%23s %9s\n\n' 'PROGRAMS' 'YES/NO'
	printf '%23s ---- %1s\n' $(cut -d':' -f1- --output-delimiter=' ' $arq)
	printf '\n'

}

# Imprime o modo de uso do programa (usado no GETOPTS)

print_usage() {

   echo -e "For usage, run: $ ./$(basename $0)"

}

# ===========================================================
#
# Sessão de declaração de variáveis
#
# ===========================================================

readonly version="2.4.4"

array_program=("CHROME" "VS-CODE" "DISCORD" "FILEZILLA" "ANYDESK" "POSTMAN" "MY-SQL/WORKBENCH" "SIMPLESCREENRECORDER" "FLAMESHOT" "KOLOURPAINT" "NPM")

# ===========================================================
#
# Inicio do programa
#
# ===========================================================

# ===========================================================

# Sessão de captura de argumentso (GETOPTS)

while getopts 'vh' opts 2> /dev/null; do
   case ${opts} in
      v)
         echo -e "cork version ${version}"
         exit
         ;;
      h)
         print_usage
         exit
         ;;
      ?)
         print_usage
         exit 1
         ;;
      esac
done

shift $((OPTIND - 1))

# ===========================================================

# Sessão de captura de informações

ress="n"

while [ "${ress,,}" == "n" ]; do

	clear

	echo ""
	echo "======================   CONFIGURAÇÃO   ======================"
	echo ""

	read -p "Usuário git: " usergit
	read -p "E-mail git: " emailgit

	echo ""

	read -s -p "Password [sudo]: " password

	echo ""
	echo ""

	read -p "As informações estão corretas (y/n)? " ress

	clear

done

ress="n"

while [ "${ress,,}" == "n" ]; do

	echo ""
	echo "======================   PROGRAMAS   ======================"
	echo ""

	for ((i=0; i<${#array_program[@]}; ++i)); do

		read -p "Deseja instalar ${array_program[$i]} (y/n)? " array_answer[$i]

	done

	echo ""

	read -p "Programas a serem instalados estão corretos (y/n)? " ress

	clear

done

arquivo_programas > programas.txt

rm ./temp.txt

# ===========================================================

# Sessão de atualização do sistema

sleep 1.5

echo ""
echo ">>>>>>>>>>>>>>>>>>>>>>   ATUALIZAÇÃO   <<<<<<<<<<<<<<<<<<<<<<"
echo ""

auto_sudo "apt update -y"
auto_sudo "apt upgrade -y"
auto_sudo "apt full-upgrade -y"

echo ""
echo ">>>>>>>>>>>>>>>>>>>>>>   FINALIZADO   <<<<<<<<<<<<<<<<<<<<<<"
echo ""

sleep 1.5

clear

# ===========================================================

# Sessão de instalação e configuração do git

echo ""
echo "======================   GIT   ======================"
echo ""

auto_sudo "apt install git -y"

echo ""
echo "--- switch ---"
echo ""

git --version

echo ""
echo "--- switch ---"
echo ""

git config --global user.name "$usergit"
git config --global user.email "$emailgit"

echo ">>> Usuario git para normal user criado !"

echo ""
echo ">>> Finalizado !"
echo ""

sleep 1.5

# ===========================================================

# Sessão de instalação dos gerenciados de pacotes

echo "======================   GERENCIADORES-DE-PACOTES   ======================"
echo ""

echo ">>> SNAP <<<"
echo ""

auto_sudo "apt install snapd -y"

echo ""
echo ">>> FLATPAK <<<"
echo ""

auto_sudo "apt install flatpak -y"

echo ""
echo ">>> CURL <<<"
echo ""

auto_sudo "apt install curl -y"

sleep 5

clear

# ===========================================================

# Sessão de instalação dos programas selecionados

echo ""
echo ">>>>>>>>>>>>>>>>>>>>>>   INSTALAÇÃO   <<<<<<<<<<<<<<<<<<<<<<"
echo ""
echo ""

for ((i=0; i<${#array_program[@]}; ++i)); do

	if [ "${array_answer[$i],,}" == "y" ]; then
		
		echo "======================   ${array_program[$i]}   ======================"
		echo ""
		fun"$i"
		echo ""
		echo ">>> Finalizado !"
		echo ""

	fi

done

# ===========================================================

# Sessão de limpeza de pacotes que possam estar sobrando
# e possivelmente quebrados também

echo ""
echo ">>>>>>>>>>>>>>>>>>>>>>   LIMPAR   <<<<<<<<<<<<<<<<<<<<<<"
echo ""

auto_sudo "apt install -f"
auto_sudo "apt --fix-broken install"

echo ""
echo "--- switch ---"
echo ""

auto_sudo "apt clean -y"
auto_sudo "apt autoclean -y"
auto_sudo "apt autoremove -y"

echo ""
echo "======================   Version ${version}   ======================"
echo ""
echo ""
echo "A simple solution..."
echo ""
echo "Created by: Crazy Group Inc © (CG)"
echo ""
echo ""
echo "================================================================"

rm ./*.deb

rm ./*.tar.gz

rm ./cork.sh

echo ""
echo "Reiniciando em 30s (cancelar o reboot: ctrl+c)"
echo ""

seconds=30

sif=$(( $(date +%s) + ${seconds} )) #seconds in the future

while [ ${sif} -ge $(date +%s) ]; do 
	
	sifdiff=$(( ${sif} - $(date +%s) ))
	echo -ne "$(date -u --date @${sifdiff} +%H:%M:%S)\r"
	
done

reboot

# ===========================================================
