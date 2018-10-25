#!/bin/bash
IFS=$'\n'
declare -a COMMENTED_LINES
echo "Check commented code"
COMMENTED_LINES=($(git status --untracked-files=no --porcelain | awk {'print $2'} | xargs grep -nr '//' | grep -v -E 'given|when|then' ))
if [ -z $COMMENTED_LINES ]; then
	echo "There is no commented lines in code"; else
	echo "There is some commented code, please take a look"
        for item in ${COMMENTED_LINES[*]} ;
        do
		echo $item
        done
fi

