
import pymysql
MYSQL_HOST = '183.182.107.122'
#MYSQL_HOST = '192.168.100.247'
MYSQL_USER = 'daxiong'
MYSQL_PASSWORD = 'Da123!@#'
MYSQL_DB = 'maplaos_db'

def connect_db():
    conn=pymysql.connect(MYSQL_HOST,MYSQL_USER,MYSQL_PASSWORD,MYSQL_DB)
    return conn