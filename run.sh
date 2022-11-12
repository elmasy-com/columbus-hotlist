#!/bin/bash

# RUNFILE is used to check if run.sh is running
RUNFILE="/tmp/columbus-popular.pid"
# ISFAILED used to indicate that one of the scripts failed while running run.sh
ISFAILED=0
FILE=popular.domains

if [ -f "$RUNFILE" ]
then
    echo "Another instance is running!"
    exit 0
else
    touch "$RUNFILE"
fi

# Verify binaries
OUTPUT=$(sha256sum -c bins.sha)
if [ $? != 0 ]
then
    echo "Failed to verify binaries!"
    echo "$OUTPUT"
    exit 1
fi

while read DOMAIN
do

    if [[ "$DOMAIN" == *"//"* ]]
    then
        # Skip comments
        continue
    elif [[ "$DOMAIN" == "" ]]
    then
        # Skip empty lines
        continue
    fi

    if [ -f "uptimehook" ]
    then
        curl -s "$(cat uptimehook)" > /dev/null
    fi

    echo "Running $DOMAIN at $(date)"

    RESULT="${DOMAIN}.result"

    echo "  -> Running Amass..." 
    OUTPUT=$(./bin/amass enum -d "$DOMAIN" -o ${DOMAIN}.result 2>&1)
    if [ $? != 0 ]
    then
        echo "Amass failed:"
        echo $OUTPUT
        cat "$RESULT" >> failed.list
        $ISFAILED=1
        continue
    fi

    echo "  -> Running Subfinder..."
    OUTPUT=$(./bin/subfinder -silent -d "$DOMAIN" >> "${DOMAIN}.result")
    if [ $? != 0 ]
    then
        echo "Subfinder failed:"
        echo $OUTPUT
        cat "$RESULT" >> failed.list
        $ISFAILED=1
        continue
    fi

    echo "  -> Inserting..."
    OUTPUT=$(./bin/columbus insert file "${DOMAIN}.result")
    if [ $? != 0 ]
    then
        echo "Columbus failed:"
        echo $OUTPUT
        $ISFAILED=1
        continue
    fi

    rm "$RESULT"


done < "$FILE"

if [ -f "failed.list" ]
then
    echo "Inserting leftover..."
    OUTPUT=$(./bin/columbus insert file failed.list)
    if [ $? != 0 ]
    then
        echo "Columbus failed:"
        echo $OUTPUT
        $ISFAILED=1
    else
        rm failed.list
    fi
fi

rm "$RUNFILE"

if [ $ISFAILED == 1 ]
then
    exit 1
fi