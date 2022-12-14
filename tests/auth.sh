#!/bin/sh

. "$(dirname $0)/lib.sh"

foobar_user='{"email": "foo@bar.com", "password": "password123"}'
foobar_user_bad_pass='{"email": "foo@bar.com", "password": "wrong"}'
foobar2_user='{"email": "foo2@bar.com", "password". "password123"}'

req_foobar_register () {
    req "register" "POST" "$foobar_user" 
}

req_foobar_login () {
    req_foobar_register
    req "login" "POST" "$foobar_user"
}

test_register() {
    teardown
    unit \
        "Simple registration test" \
        "$(req_foobar_register)" \
        '201 {"created_account":1}'
}

test_duplicate_registration() {
    teardown
    quiet req_foobar_register
    # since we have already registed once now,
    # the following request should be denied
    # due to duplicate email adresses
    unit \
        "Test registering with duplicate emails" \
        "$(req_foobar_register)" \
        '409 Account already exists'
}

test_good_login() {
    teardown
    quiet req_foobar_register
    unit \
        "Successful login test" \
        "$(req "login" "POST" "$foobar_user")" \
        "200 Logged in as: foo@bar.com"
}

test_bad_login() {
    teardown
    quiet req_foobar_register
    unit \
        "Bad login test" \
        "$(req "login" "POST" "$foobar_user_bad_pass")" \
        "400 Bad login"
}

test_unauthorized_access() {
    teardown
    quiet req_foobar_register
    unit \
        "Test unauthorized access" \
        "$(req "whoami" "GET")" \
        "401 Unauthorized"
}

test_authorized_access() {
    teardown
    quiet req_foobar_login
    unit \
        "Test authorized access" \
        "$(req "whoami" "GET")" \
        "200 foo@bar.com"
}

test_logout() {
    teardown
    quiet req_foobar_login
    unit \
        "Test logging out" \
        "$(req "logout" "GET")" \
        "200 Logged out"
}

test_unauthorized_access_post_logout () {
    teardown
    quiet req_foobar_login
    quiet req "logout" "GET" &> /dev/null
    unit \
        "Test unauthorized access post-logout" \
        "$(req "whoami" "GET")" \
        "401 Unauthorized"
}
