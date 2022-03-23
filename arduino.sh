#!/bin/bash

# Author           : dcPTR
# Created On       : 19.05.2020
# Last Modified By : dcPTR
# Last Modified On : 19.05.2020 
# Version          : 1.0
#
# Description      : It allows you to compile the source code, send the program to Arduino and read the results.
#
# Licensed under GPL (see /usr/share/common-licenses/GPL for more details
# or contact # the Free Software Foundation for a copy)


WORK_DIR="."
BOARD_TYPE="uno"
MONITOR="FALSE"
COMPILATION="FALSE"

BOARD_LIST=("atmega168" "atmega328" "atmega8" "bt328" "bt" "diecimila" "esplora" "ethernet" "fio" "leonardo" "lilypad328" "lilypad" "LilyPadUSB" "mega2560" "mega" "micro" "mini328" "mini" "nano328" "nano" "pro328" "pro5v328" "pro5v" "pro" "robotControl" "robotMotor" "uno")


if [[ ! $(dpkg -s arduino-mk 2>/dev/null) ]] || [[ ! -x $(which screen) ]] || [[ ! -x $(which yad) ]]; then
    echo "Missing dependencies. Install packages: arduino-mk screen yad" >&2
    exit 1
fi

help(){
cat << 'EOF'
Usage:
	[-h] - help
	[-v] - version
	[-s] - show result's monitor
	[-c] - show informations about a compilation
	[-b] - set a board type
	[-l] - list avaiable board types
	
To stop the monitor mode use: C-a \
EOF
	exit 0
}

version(){
	echo "Version 1.0"
	exit 0
}

setWorkDir(){
	if [ -n "$1" ]; then
		WORK_DIR=$OPTARG
	else
		WORK_DIR="."
	fi
}

unknown(){
	echo "Invalid option." >&2
	help
}

setBoardType(){
	if [[ "${BOARD_LIST[*]}" =~ $1 ]] && [[ -n "$1" ]]; then
    	BOARD_TYPE=$1
	else
		echo "Incorrect board type." >&2
		echo "Available board types:"
		listBoardTypes
	fi
}

listBoardTypes(){
cat << EOF
atmega168     Arduino NG or older w/ ATmega168
atmega328     Arduino Duemilanove w/ ATmega328
atmega8       Arduino NG or older w/ ATmega8
bt328         Arduino BT w/ ATmega328
bt            Arduino BT w/ ATmega168
diecimila     Arduino Diecimila or Duemilanove w/ ATmega168
esplora       Arduino Esplora
ethernet      Arduino Ethernet
fio           Arduino Fio
leonardo      Arduino Leonardo
lilypad328    LilyPad Arduino w/ ATmega328
lilypad       LilyPad Arduino w/ ATmega168
LilyPadUSB    LilyPad Arduino USB
mega2560      Arduino Mega 2560 or Mega ADK
mega          Arduino Mega (ATmega1280)
micro         Arduino Micro
mini328       Arduino Mini w/ ATmega328
mini          Arduino Mini w/ ATmega168
nano328       Arduino Nano w/ ATmega328
nano          Arduino Nano w/ ATmega168
pro328        Arduino Pro or Pro Mini (3.3V, 8 MHz) w/ ATmega328
pro5v328      Arduino Pro or Pro Mini (5V, 16 MHz) w/ ATmega328
pro5v         Arduino Pro or Pro Mini (5V, 16 MHz) w/ ATmega168
pro           Arduino Pro or Pro Mini (3.3V, 8 MHz) w/ ATmega168
robotControl  Arduino Robot Control
robotMotor    Arduino Robot Motor
uno           Arduino Uno
EOF
exit 0
}

showInterface(){
	OUTPUT=$(yad --separator="," --form --title='Arduino Uploader' --image="emblem-system" --text='Initial settings' --field="Directory" --field="Board type:CB" --field="Monitor mode:CHK" --field="Compilation info:CHK" $WORK_DIR $(IFS=! ; echo "${BOARD_LIST[*]}" | sed "s/$BOARD_TYPE/\^$BOARD_TYPE/g") $MONITOR $COMPILATION)

	WORK_DIR=$(awk -F, '{print $1}' <<< "$OUTPUT")
	BOARD_TYPE=$(awk -F, '{print $2}' <<< "$OUTPUT")
	MONITOR=$(awk -F, '{print $3}' <<< "$OUTPUT")
	COMPILATION=$(awk -F, '{print $4}' <<< "$OUTPUT")

	if [ -z "$WORK_DIR" ]; then
		WORK_DIR="."
	fi
}


while getopts hvscp:b:li OPT; do
	case $OPT in
		h) help;;
		v) version;;
		s) MONITOR="TRUE";;
		c) COMPILATION="TRUE";;
		p) setWorkDir "$OPTARG";;
		b) setBoardType "$OPTARG";;
		l) listBoardTypes;;
		i) showInterface;;
		*) unknown;;
	esac
done


FILES_COUNT=$(find $WORK_DIR -maxdepth 1 -name "*.ino"| wc -l)

if [[ $FILES_COUNT -gt 1 ]]; then
	echo "Select the file you want to be built."
	
	NR=1
	while read -d $'\0' file
	do
		FILES[$NR]="$file"
		echo "$NR) $file"
		NR=$((NR+1))
	done < <(find . -maxdepth 1 -name "*.ino" -print0 )

	SELECTED_INDEX=0

	while [[ $SELECTED_INDEX -lt 1 ]] || [[ $SELECTED_INDEX -gt $FILES_COUNT ]]; do
		printf "Choose a file: "
		read SELECTED_INDEX
	done

	SELECTED_FILE=${FILES[SELECTED_INDEX]}

	echo "Selected file is: $SELECTED_FILE"

	SELECTED_FILE=$(basename "$SELECTED_FILE")

	mv "$SELECTED_FILE" "${SELECTED_FILE}_WORKING"
	
	find . -maxdepth 1 -name "*.ino" -print0 | while read -d $'\0' file
	do
		TEMP_FILE=$(basename "$file")
		TEMP_NO_EXT=${TEMP_FILE%.*}
		mkdir -p "$TEMP_NO_EXT"
		mv --backup=t "$TEMP_FILE" "${TEMP_NO_EXT}/${TEMP_FILE}"
	done
	
	mv "${SELECTED_FILE}_WORKING" "$SELECTED_FILE"

elif [ "$FILES_COUNT" -eq 0 ]; then
	echo "Missing source file. Create a *.ino file." >&2
	exit 2
fi

touch "$WORK_DIR/Makefile"
mkdir -p "$WORK_DIR/libraries"

cat > "$WORK_DIR/Makefile" <<- EOM
include /usr/share/arduino/Arduino.mk

ARDUINO_DIR = /usr/share/arduino
ARDUINO_PORT = /dev/ttyUSB0*
USER_LIB_PATH = "$WORK_DIR/libraries"
BOARD_TAG = $BOARD_TYPE
EOM

cd $WORK_DIR || exit;

if [ $MONITOR == "TRUE" ]; then
	if [ $COMPILATION == "TRUE" ]; then
		make upload monitor clean
	else
		make upload monitor clean > /dev/null
	fi
else
	if [ $COMPILATION == "TRUE" ]; then
		make upload clean
	else
		make upload clean > /dev/null
	fi
fi