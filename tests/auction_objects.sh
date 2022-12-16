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
    unit \
        "Test showing an auction object" \
        "$( \
            req "auction_objects/1" "GET" \
            | cut -c5- \
            | jq -S 'del(.date_start, .date_end)')" \
        "$( \
            echo "$auction_object_1" \
            | jq -S 'del(.date_end) + {'`
                    `'"bids" : [], '` 
                    `'"id": 1, '`
                    `'"owner": 1}')"
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
    quiet req "logout" "GET"

    quiet req "register" "POST" "$foobar2_user"
    quiet req "login" "POST" "$foobar2_user"
    unit \
        "Test bidding on a new auction object" \
        "$(req "auction_objects/1/bid" "POST" '{"amount": 500}')" \
        '201 {"bid_created":1}'
    quiet req "logout" "GET"
}

test_same_bidder_on_auction_object() {
    teardown
    quiet req_foobar_login
    quiet req_create_auction_object_1
    quiet req "logout" "POST"
    unit \
        "Test that user can't bid on their own auctions" \
        "$(req "auction_objects/1/bid" "POST" '{"amount": 500}')" \
        "400 Bid 500 refused; can't bid on own auction"
        
    quiet req "logout" "POST" 
}

test_too_low_bid_on_auction_object () {
    teardown
    quiet req_foobar_login
    quiet req_create_auction_object_1
    quiet req "logout" "GET"

    quiet req "register" "POST" "$foobar2_user"
    quiet req "login" "POST" "$foobar2_user"

    quiet req "auction_objects/1/bid" "POST" \
              '{"amount": 500}'

    unit \
        "Test that user must bid higher than leading bid" \
        "$(req "auction_objects/1/bid" "POST" \
               '{"amount": 500}')" \
        "409 Bid 500 refused; must be higher than 500"

    quiet req "logout" "GET"
}

# this isn't a real test, 
# just an ad-hoc thing to see that bid list works
show_bids () {
    teardown
    quiet req_foobar_login
    quiet req_create_auction_object_1
    quiet req "logout" "GET"

    quiet req "register" "POST" "$foobar2_user"
    quiet req "login" "POST" "$foobar2_user"

    quiet req "auction_objects/1/bid" "POST" \
              '{"amount": 500}'
    
    quiet req "auction_objects/1/bid" "POST" \
              '{"amount": 501}'
    req "auction_objects/1" "GET"
    quiet req "logout" "GET"
}
