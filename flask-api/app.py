import os
from flask import Flask, jsonify
from flaskext.mysql import MySQL
from flask_cors import CORS, cross_origin
from flask_restful import Resource, Api, reqparse
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
cors = CORS(app)
mysql = MySQL()
api = Api(app)
parser = reqparse.RequestParser()

# CORS configurations
app.config['CORS_HEADERS'] = 'Content-Type'

# MySQL configurations
app.config['MYSQL_DATABASE_USER'] = 'root'
app.config['MYSQL_DATABASE_PASSWORD'] = 'password'
app.config['MYSQL_DATABASE_DB'] = 'CoProManager'
app.config['MYSQL_DATABASE_HOST'] = os.getenv('MYSQL_DATABASE_HOST')

mysql.init_app(app)
conn = mysql.connect()
cursor = conn.cursor()

class CreateUser(Resource):
    def post(self):
        try:
            # Parse the arguments
            parser = reqparse.RequestParser()
            parser.add_argument('username', type=str, help='Username address to create user')
            parser.add_argument('password', type=str, help='Password to create user')
            parser.add_argument('fname', type=str, help='First name to create user')
            parser.add_argument('lname', type=str, help='Last name to create user')
            parser.add_argument('email', type=str, help='Email name to create user')
            parser.add_argument('usertype', type=str, help='Type name to create user')

            args = parser.parse_args()

            _userName = args['username']
            _userPassword = args['password']
            _userFName = args['fname']
            _userLName = args['lname']
            _userEmail = args['email']
            _userType = args['usertype']

            cursor.callproc('spCreateUser',(_userName,_userPassword, _userFName, _userLName, _userEmail, _userType))
            data = cursor.fetchall()

            if len(data) is 0:
                conn.commit()
                return {'StatusCode':'200','Message': 'User creation success'}
            else:
                return {'StatusCode':'1000','Message': str(data[0])}

        except Exception as e:
            return {'error': str(e)}

api.add_resource(CreateUser, '/CreateUser')

class AuthenticateUser(Resource):
    def post(self):
        try:
            # Parse the arguments
            parser = reqparse.RequestParser()
            parser.add_argument('username', type=str, help='Username address to create user')
            parser.add_argument('password', type=str, help='Password to create user')

            args = parser.parse_args()

            _userName = args['username']
            _userPassword = args['password']

            cursor.callproc('spAuthentication',(_userName,_userPassword))
            data = cursor.fetchall()

            if(len(data)>0):
                if(str(data[0][4])==_userPassword):
                    return {'status':200,'UserId':str(data[0][0])}
                else:
                    return {'status':100,'message':'Authentication failure'}

        except Exception as e:
            return {'error': str(e)}

api.add_resource(AuthenticateUser, '/AuthenticateUser')

@app.route('/')
def hello():
    return 'Hello world!'

if __name__ == '__main__':
    app.run(debug=True)