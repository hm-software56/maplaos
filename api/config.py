
import pymysql
MYSQL_HOST = 'localhost'
#MYSQL_HOST = '192.168.43.114'
MYSQL_USER = 'root'
MYSQL_PASSWORD = 'Da123!@#'
MYSQL_DB = 'maplaos_db'

def connect_db():
    conn=pymysql.connect(MYSQL_HOST,MYSQL_USER,MYSQL_PASSWORD,MYSQL_DB)
    return conn