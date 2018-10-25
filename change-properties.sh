#!/bin/bash

FILENAME="application*.properties"
PROJECT_PATH=$1
CMS_PREFIX=$3
ADDRESS=$2
CHANGE=0
REVERT=0
USAGE="This script will help you to change application.properties files for local development purposes"

function find_properties_files {
  FILE_LIST="$(find $PROJECT_PATH -name $FILENAME | grep src)"
  echo "Found given application.properties files: $FILE_LIST"
}

function change_properties {
    for file in $FILE_LIST
    do
        echo "Changing $file"
        cp $file $file.backup
        sed -i.bak '/^spring\.redis\.port/s#.*#spring\.redis\.port='$CMS_PREFIX'637#g' $file
        sed -i.bak "/^spring\.redis\.host/s#.*#spring\.redis\.host=$ADDRESS#g" $file
        sed -i.bak '/^spring.datasource.url=/s#.*edgesync#spring.datasource.url=jdbc:postgresql://'$ADDRESS':'$CMS_PREFIX'401/edgesync#g' $file
        sed -i.bak '/^spring.datasource.url=/s#.*differential_generator#spring.datasource.url=jdbc:postgresql://'$ADDRESS':'$CMS_PREFIX'402/differential_generator#g' $file	
        sed -i.bak "/^cassandra.contact-points/s#.*#cassandra.contact-points=$ADDRESS#g" $file
        sed -i.bak '/^cassandra.port/s#.*#cassandra.port='$CMS_PREFIX'742#g' $file
        sed -i.bak '/^kafka.bootstrap.servers/s#.*#kafka.bootstrap.servers=eskafka:'$CMS_PREFIX'092#g' $file
        sed -i.bak '/^zookeeper.connectionString/s#.*#zookeeper.connectionString='$ADDRESS':'$CMS_PREFIX'181#g' $file
        sed -i.bak '/^update.files.url.prefix/s#.*#update.files.url.prefix=https://'$ADDRESS':'$CMS_PREFIX'103/packages#g' $file
    done

}

function revert_old_files {
    echo "Restoring commited files"
    for file in $FILE_LIST
    do
        cp "$file.backup" "$file"
    done
}

#TODO invoke function
function show_diff_between_files {
    echo "Checking if properties file was changed"
    diff $file $file.backup
}

while (( "$#" )); do
        PARAM=$1
        shift
        case $PARAM in
        "-c"|"--change" )
                CHANGE=1
        ;;
        "-r"|"--revert")
                REVERT=1
        ;;
        "-h"|"--help" )
                echo -e "$USAGE"
                exit 0
        ;;
    esac
done

find_properties_files
if [ "$REVERT" -eq 1 ]; then
        revert_old_files
elif [ "$CHANGE" -eq 1 ]; then
        change_properties
fi
#TODO get ADDRESS from system
