from flask import Flask, render_template, request, jsonify
import connection
from flask_mysqldb import MySQL
app = Flask(__name__)

app.config['MYSQL_HOST'] = '192.168.100.165'
app.config['MYSQL_USER'] = 'daxiong'
app.config['MYSQL_PASSWORD'] = 'Da123!@#'
app.config['MYSQL_DB'] = 'maplaos_db'

mysql = MySQL(app)


@app.route('/')
def index():
    cur = mysql.connection.cursor()
    cur.execute("select * from user")
    mysql.connection.commit()
    rv = cur.fetchall()
    return  jsonify(rv)
    cur.close()

if __name__ == '__main__':
    app.run(debug=True)