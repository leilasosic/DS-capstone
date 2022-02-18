import psycopg2

#set up db connection
conn = psycopg2.connect('dbname=ratemymanager user=postgres host=localhost password=Samila68$')
cursor = conn.cursor()

#create and run transactions - INSERTS
manager_one = [
    [8, 'Jason Smith', 806, 31, 186],
    [9, 'Madison Rogers', 405, 21, 940]
]
cols = ['manager_id', 'manager_name', 'rating_id', 'review_id', 'company_id']
for manager in manager_one:
    SQL = "INSERT INTO manager (manager_id, manager_name, rating_id, review_id, company_id) VALUES (%s, %s, %s, %s, %s);"
    cursor.execute(SQL, manager)

#commit the transactions
conn.commit()

#close the db
conn.close()