#import methods
from flask import Flask, render_template, request
from flask_sqlalchemy import SQLAlchemy
import psycopg2

#set up db connection
conn = psycopg2.connect('dbname=ratemymanager user=postgres host=localhost password=Samila68$')
cursor = conn.cursor()

#start of the configuration section
#configuring app parameters
app = Flask(__name__) #declaring the app
#connecting to the db - configure db connection for the app
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://postgres:Samila68$@localhost/ratemymanager'
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
app.secret_key = 'secret string'

db = SQLAlchemy(app)

#create class
class Users(db.Model):
    __tablename__='users'
    user_id=db.Column(db.Integer,primary_key=True)
    company_id=db.Column(db.Integer)
    review_id=db.Column(db.Integer)
    ratings_id=db.Column(db.Integer)
    job_id=db.Column(db.Integer)
    manager_id=db.Column(db.Integer)

    def __init__(self,user_id,company_id, review_id, ratings_id, job_id, manager_id):
        self.user_id=user_id
        self.company_id=company_id
        self.review_id=review_id
        self.ratings_id=ratings_id
        self.job_id=job_id
        self.manager_id=manager_id

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/submit', methods=['POST'])
def submit():
    user_id=request.form['user_id']
    job_id = request.form['job_id']
    manager_id= request.form['manager_id']
    company_id = request.form['company_id']
    review_id = request.form['review_id']
    ratings_id = request.form['ratings_id']

    user=Users(user_id, company_id, review_id, ratings_id, job_id, manager_id)
    db.session.add(user)
    db.session.commit()

#fetch a certain user2

    userResult=db.session.query(Users).filter(Users.user_id==1)
    for result in userResult:
        print(result.manager_id)
    
    return render_template('success.html', data=manager_id)

#this code runs the app in Flask
if __name__ == '__main__':
    app.run(debug=True)

###########at this point we can then access our app from terminal#######
###http://127.0.0.1:5000/###

#end of the configuration section






