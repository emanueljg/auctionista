#!/bin/sh

# Shellscript for testing the auctionista flask API.
# 
# Requirements: cURL and jq.
# The program aims to target POSIX sh but might by
# accident use bash-only syntax.
#
# All testing logic, all buildup and teardown,
# resides in this shellcode, NOT the main python code. 
# No magical endpoints should be used.
#
# Tests written here should be atomic and preferably be unit tests. 

URL="127.0.0.1:5000"
COOKIES="cookies.txt"

req () {
    ENDPOINT="$1"
    METHOD="$2"
    DATA="$3"

    # Fun fact about curl: using the --verbose flag, it outputs
    # debug info to stderr in additional to normal stdout output.
    # Inside this stderr debug info exists, amongst other things,
    # the status code for the request: 
    # something we can use in our test functions!
    ERROR_FILE=$(mktemp)
    OUT=$(curl \
        --verbose \
        --silent \
        --request "$METHOD" \
        --header "Content-Type: application/json" \
        --data "$DATA" \
        --cookie-jar "$COOKIES" \
        --cookie "$COOKIES" \
        -- "${URL}/${ENDPOINT}" 2>$ERROR_FILE)            
    ERR="$(cat $ERROR_FILE)"
    rm $ERROR_FILE
    STATUS_CODE=$( \
        echo "$ERR" \
        | grep -o "HTTP/1\.1 [[:digit:]]\{3\}" \
        | cut -d " " -f 2)
    echo $STATUS_CODE $OUT

}                

teardown() {
    # in the real world, we obviously
    # can't go around wiping the real database
    # every time we want to run tests as we do here.
    # 
    # Ideally you'd want to use a throwaway test database
    # for that, which would act as a sandbox for tests.
    mysql auctionista < "$(dirname "$0")/../auctionista.sql"
    rm "${COOKIES}"
}


TEST_RUNS=""

unit () {
    TEST_NAME="$1"
    GOT="$2"
    EXPECTED="$3"

    OUT="---${TEST_NAME}---\n"

    if [ "$GOT" = "$EXPECTED" ]; then
        OUT+="SUCCESS!"
    else
        OUT+="FAILURE."
        OUT+="\nexpected: $EXPECTED"
        OUT+="\ngot: $GOT"
    fi

    printf -- "${OUT}\n"
}

get_status_code () {
    echo "$1" | cut -d " " -f 1
}

get_content() {
    echo "$1" | cut -c5-
}

# helper for supressing command output
quiet () {
    "$@" > /dev/null 2>&1
}

