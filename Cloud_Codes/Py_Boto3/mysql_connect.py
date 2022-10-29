import mysql.connector      #connect to mysql database
mydb = mysql.connector.connect(
	host="Your <aws,azure,gcp> host address",
	user="admin",
	password="<Set any password>")
print(mydb)
#This a simple code to connect to db and check connection
