#!/bin/sh

. "$(dirname $0)/auth.sh"

test_register
test_duplicate_registration
test_good_login
test_bad_login
test_unauthorized_access
test_authorized_access
test_logout
test_unauthorized_access_post_logout


. "$(dirname $0)/auction_objects.sh"

test_create_auction_object
test_show_auction_object
test_list_auction_objects
test_bid_on_new_auction_object
