#! /bin/env bash

text_bold="\e[1m"
text_reset="\e[0m"
text_faint="\e[2m"

if [[ -z $1 || $1 == "-h" || $1 == "--help" ]]; then
	echo "update.sh: installs or updates Eclipse's jdt.ls"
	echo -e "  Usage: $text_bold./update.sh [path]$text_reset where [path] is the path for jdt.ls's output to be."
	exit
fi

announce() {
	if [[ $2 == "--no-faint" ]]; then
		echo -e "$text_reset$text_bold$1$text_reset"
	else
		echo -e "$text_reset$text_bold$1$text_reset$text_faint"
	fi
}

announce "Entering $1..."

cd $1

filename="jdt.ls.tar.gz"
output_directory="jdtls"

announce "Removing old copy of jdt.ls..."

rm -r "$output_directory"

announce "Downloading new copying..."

wget --output-document "$filename" https://www.eclipse.org/downloads/download.php?file=/jdtls/snapshots/jdt-language-server-latest.tar.gz

announce "Creating new directory..."

mkdir "$output_directory"

announce "Extracting new copy into new directory..."

tar xf $filename --directory="$output_directory"

announce "Cleaning up..."

rm $filename

announce "All done!" --no-faint
