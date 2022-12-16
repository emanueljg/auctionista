import flask
from flask import Flask, request, jsonify, has_request_context
import pymysql
from flaskext.mysql import MySQL
import os
import flask_login
from flask_login import LoginManager, UserMixin, login_user, login_required, current_user


def get_conn():
    # TODO CHANGEME
    return pymysql.connect(user='ejg',
                           host='localhost',
                           database='auctionista',
                           unix_socket='/var/run/mysqld/mysqld.sock',
                           cursorclass=pymysql.cursors.DictCursor,
                           autocommit=True)

app = Flask(__name__)
app.secret_key = '606d1277468c0f187f3a0ea2f08970ae3777795e21d11d1e01e2537343b3d8eb'

# auth plugin
login_manager = LoginManager()
login_manager.init_app(app)


class User(UserMixin):
    def __init__(self, id): 
        self._id = id

    @property
    def id(self):
        return str(self._id)

    def __getattr__(self, key):
        with get_conn() as conn, conn.cursor() as cursor:
            query = f'SELECT {key} FROM account WHERE id = %s'
            cursor.execute(query, args=(self.id))
            return cursor.fetchone()[key]


def get_users():
    with get_conn() as conn, conn.cursor() as cursor:
        cursor.execute('SELECT * FROM account')
        return cursor.fetchall()

def user_with_attrs(**kwargs):
    return next((user for user in get_users()
                      if all(user[k] == v for k, v in kwargs.items())), 
                None)

def request_params(*args):
    return tuple(request.json[arg] for arg in args)

def get_auction_object_bidding(id, 
                               order_by='amount', 
                               order_by_order='DESC',
                               only_first=False):
    query = (
        'SELECT * FROM bid'
        ' WHERE auction_object = %s' 
        f' ORDER BY {order_by} {order_by_order}' if order_by else '')
    print(query)
    with get_conn() as conn, conn.cursor() as cursor:
        cursor.execute(query, args=(id,))
        return cursor.fetchone() if only_first else cursor.fetchall()

@login_manager.user_loader
def user_loader(id):
    if user_with_attrs(id=int(id)): 
        return User(id)
    
@login_manager.unauthorized_handler
def unauthorized_handler():
    return 'Unauthorized', 401

@app.route('/auction_objects', methods=(['GET']))
def get_auction_objects():
    """Gets a list of auction objects."""
    with get_conn() as conn, conn.cursor() as cursor:
        cursor.execute('SELECT * FROM auction_object')
        result = cursor.fetchall()

    # patch in highest bid of all entries 
    for ao in result:
        leading_bid = get_auction_object_bidding(
            ao['id'], only_first=True)
        ao['leading_bid'] = leading_bid['amount'] if leading_bid else None

    return jsonify(result)

@app.route('/auction_objects/<id>', methods=(['GET']))
def get_auction_object(id):
    """Get an auction object with id `id`."""
    query = 'SELECT * FROM auction_object WHERE id = %s'
    with get_conn() as conn, conn.cursor() as cursor:
        cursor.execute(query, args=(id,))
        ao = cursor.fetchone()

    # patch in bids list of 5 latest entries
    ao['bids'] = get_auction_object_bidding(ao['id'])[:5]
    return jsonify(ao) 

@app.route('/register', methods=(['POST']))
def register():
    """Register a user.
    
    Parameters: email, password
    """
    query = ('INSERT INTO account (email, password) VALUES (%s, %s)')
    params = request_params('email', 'password')

    if user_with_attrs(email=params[0]):
        return 'Account already exists', 409

    with get_conn() as conn, conn.cursor() as cursor:
        cursor.execute(query, params)
        return jsonify({'created_account': cursor.lastrowid}), 201

@app.route('/login', methods=['POST'])
def login():
    """Login a user.

    Parameters: email, password
    """
    email = request.json['email']
    password = request.json['password']
    found_user = user_with_attrs(email=email, password=password)
    if found_user: 
        flask_login.login_user(User(found_user['id']))
        return 'Logged in as: ' + current_user.email
    else:
        return 'Bad login', 400

@app.route('/logout')
@login_required
def logout():
    """Logout a user.

    Yes, it's weird that this is a GET-method --
    I just have it like this because 
    that's how the flask-login readme quickstart 
    does its logout route.
    """
    flask_login.logout_user()
    return 'Logged out'

@app.route('/whoami', methods=['GET'])
@login_required
def whoami():
    """Show the current logged-in user's username"""
    return current_user.email 

@app.route('/auction_objects', methods=(['POST']))
@login_required
def create_auction_object():
    """Create an auction object.

    Paramaters: title, description, date_end
    (date_end accepts most datetime-y formatted things)
    """
    query = (
        'INSERT INTO auction_object'
        ' (owner, title, description, date_end) VALUES'
        ' (%s, %s, %s, %s)')
    owner = int(current_user.id)
    params = (owner,) + request_params('title', 'description', 'date_end')
    with get_conn() as conn, conn.cursor() as cursor:
        cursor.execute(query, params)
        return jsonify({'created_auction_object': cursor.lastrowid}), 201

    

@app.route('/auction_objects/<id>/bid', methods=(['POST']))
@login_required
def bid(id):
    """Bid on the auction object with id `id`.

    Parameters: amount
    """
    # first check if bidded amount is valid...
    requested = request.json['amount']
    leading_bid = get_auction_object_bidding(
        id, order_by='amount', only_first=True)
    if leading_bid and requested <= (need := leading_bid['amount']):
        return f'Bid {requested} refused; must be higher than {need}', \
               409
    # and then that it's not the person who posted the action...
    with get_conn() as conn, conn.cursor() as cursor:
        query = ('SELECT * FROM auction_object'
                 f' WHERE id = %s')
        cursor.execute(query, args=(id))
        #print(cursor.fetchone())
        if int(current_user.id) == cursor.fetchone()['owner']:
            return f"Bid {requested} refused; can't bid on own auction", \
                   400

    # good to go!
    query = (
        'INSERT INTO bid'
        ' (bidder, auction_object, amount) VALUES (%s, %s, %s)')
    bidder = int(current_user.id)
    auction_object = id
    with get_conn() as conn, conn.cursor() as cursor:
        cursor.execute(query, args=(bidder, auction_object, requested))
        return jsonify({'bid_created': cursor.lastrowid}), 201 

if __name__ == '__main__':
    app.run(host='localhost', port=5000)



