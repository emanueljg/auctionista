#!/bin/sh

. "$(dirname $0)/lib.sh"
. "$(dirname $0)/auth.sh"

auction_object_1='{"title": "Eggs",'`
                 `'"description": "Eggs o'\'' dozen.",'`
                 `'"date_end": "2001-05-31"}'

auction_object_2='{"title": "Bacon",'`
                 `'"description": "Mmm... Bacon.",'`
                 `'"date_end": "1997-01-01"}'

auction_object_3='{"title": "Spam",'`
                 `'"description": "Spam, spam, spam, spam...",'`
                 `'"date_end": "1993-01-01"}'

req_create_auction_object_1 () {
    req "auction_objects" "POST" "${auction_object_1}" 
}

req_create_auction_object_2 () {
    req "auction_objects" "POST" "${auction_object_2}" 
}

req_create_auction_object_3 () {
    req "auction_objects" "POST" "${auction_object_3}" 
}

req_create_auction_objects () {
    req_create_auction_object_1   
    req_create_auction_object_2   
    req_create_auction_object_3   
}


test_create_auction_object () {
    teardown
    quiet req_foobar_login
    unit \
        "Test creating an auction object" \
        "$(req_create_auction_object_1)" \
        '201 {"created_auction_object":1}'
}

test_show_auction_object () {
    teardown
    quiet req_foobar_login
    quiet req_create_auction_object_1
    response="$( \
        req "auction_objects/1" "GET" \
        | cut -c5- \
        | jq -S 'del(.date_start, .date_end)')"
    unit \
        "Test showing an auction object" \
        "$response" \
        "$(echo "$auction_object_1" \
        | jq -S 'del(.date_end) + {"bids" : [], "id": 1, "owner": 1}')"
}

test_list_auction_objects () {
    teardown
    quiet req_foobar_login
    quiet req_create_auction_objects
    response="$(req "auction_objects" "GET")"
    unit \
        "Test listing auction objects" \
        "$(get_status_code "$response")" \
        "200"
}

test_bid_on_new_auction_object() {
    teardown
    quiet req_foobar_login
    quiet req_create_auction_object_1
    unit \
        "Test bidding on a new auction object" \
        "$(req "auction_objects/1/bid" "POST" '{"amount": 500}')" \
        '201 {"bid_created":1}'
}

test_same_bidder_on_auction_object() {
    teardown
    quiet req_foobar_login
    quiet req_create_auction_object_1
    req 
}

test_too_low_bid_on_auction_object() {
    teardown
    
    quiet req_foobar_login
    quiet req_create_auction_object_1
    quiet req "logout" "POST" 


    quiet req_foobar_login
    quiet req_create_auction_object_1
}

