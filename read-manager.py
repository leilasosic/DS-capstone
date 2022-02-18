import psycopg2

#set up db connection
conn = psycopg2.connect('dbname=ratemymanager user=postgres host=localhost password=Samila68$')
cursor = conn.cursor()

#pass the name of the stored procedure
cursor.execute("CALL insert_sector(%s, %s);", ('16', 'Real Estate'))

#commit
conn.commit()

#closer
conn.close()