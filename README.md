# auctionista
An exercise in building a REST API in Flask.

## Requirements
For running it:
- Python 3.x (tested on 3.11.0)
- some python packages: `pip install -r requirements.txt`
- mysql 8.x

For testing it:
- POSIX sh
- curl
- jq

## Running it
1. Setup a mysql database (hereby named *auctionista*) 
   and a user that has all permissions to it.
2. **You must change code in app.get_conn() to suit your setup.**
   The `unix_socket` kwarg is only needed if you authenticate your
   db user through a socket.
2. Load the .sql file into your database: 
   `mysql auctionista < auctionista.sql`
3. Run the flask server: `flask run`

## Testing it
`sh tests/test.sh`



## API Usage

### /auction_objects (GET)
Gets a list of auction objects.

### /auction_objects/<id> (GET)
Get an auction object with id `id`.

### /register (POST)
Register a user.

Parameters: email, password

### /login (POST)
Login a user.

Parameters: email, password

### /logout (GET)
*login required*
Logout a user.

Yes, it's weird that this is a GET-method --
I just have it like this because 
that's how the flask-login readme quickstart 
does its logout route.

### /whoami (GET)
*login required*
Show the current logged-in user's username

### /auction_objects (POST)
*login required*
Create an auction object.

Paramaters: title, description, date_end
(date_end accepts most datetime-y formatted things)

### /auction_objects/<id>/bid (POST)
*login required*
Bid on the auction object with id `id`.

Parameters: amount
