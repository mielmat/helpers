#!/bin/bash
set -x
PROJECT_PATH="/home/mmielczarek/tmp/edgesync.differential.generator.backend/"

copyright_pattern="/**\n * Copyright (c) %s Wind River Systems, Inc.\n *\n * The right to copy, distribute, modify, or otherwise make use of this software may be licensed only pursuant to the terms\n * of an applicable Wind River license agreement.\n*/\n"
wr_tag="/*WR-Reference::10199*/\n"

FILE_LIST="$(find $PROJECT_PATH -name *.java)"
local IFS=$'\n'
for file in $FILE_LIST
do
    YEAR=$(grep Copyright $file | grep -o -P '(?<=\(C\)\ ).*(?=\ Intel)')
    header_lines=$(sed -n '1,/package/p' $file | wc -l)
    lines_to_be_removed=$(($header_lines-1))
    sed -i '1,'$lines_to_be_removed'd' $file
    header=$(printf "$copyright_pattern" $YEAR)
    mv $file $file.bak
    printf "$header" > $file
    printf "\n" >> $file
    printf "$wr_tag" >> $file
    cat $file.bak >> $file
    rm $file.bak
done
