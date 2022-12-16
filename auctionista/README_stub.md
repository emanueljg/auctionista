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

