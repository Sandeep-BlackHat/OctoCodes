#Simple code to connect to db and check connection
import mysql.connector
mydb = mysql.connector.connect(
	host="Your <aws,azure,gcp> host address",
	user="admin",
	password="<Set any password>")
print(mydb)
