from flask import Flask, request, jsonify
import pymysql
from flaskext.mysql import MySQL
from flask import Flask, request, jsonify
import pymysql
from flaskext.mysql import MySQL

app = Flask(__name__)

mysql = MySQL()
app.config['MYSQL_DATABASE_USER'] = 'root'
app.config['MYSQL_DATABASE_PASSWORD'] = 'rootroot'
app.config['MYSQL_DATABASE_DB'] = 'folk'
app.config['MYSQL_DATABASE_HOST'] = '127.0.0.1'
mysql.init_app(app)

@app.get("/")
def hello():
    return "Hello World!"

if __name__ == "__main__":
    app.run()
