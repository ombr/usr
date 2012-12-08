# Usr Authentification and role management REST OAuth2 WebService

Just deploy usr app on heroku and use it to authenticate and manage your users.

## Installation

`
git clone https://github.com/ombr/usr.git usr
cd usr
heroku create name-of-your-app
git remote add heroku git@heroku.com:name-of-your-app.git
git push heroku master
`

## Usage :

Use your service to authenticate your users with oauth2.
You can check the examples for more details.

## Configuration

You configure usr application by setting Environement variables :

### authentification :

- FACEBOOK_KEY, FACEBOOK_SECRET for Facebook
- GOOGLE_KEY, GOOGLE_SECRET for google
- TWITTER_KEY, TWITTER_SECRET for twitter

## Status

Currently there is not much working on, but you can user
`make test` to see the status


## Service deployment :
You need npm and vmc (cloudfoundry-client)

`
npm install usr
cd node_modules/usr
vmc target api.cloudfoundry.com (or your own cloudfoundry server)
vmc login --email yourcloudfoundry@email.com --passwd yourcloudfoundrypass
vmc push ./
`

You service is now up and running, you can access and try it. 
But there is no persistent storage and you can not login throug providers.

The service configuration is stored in the environement, here are some example of service customisation :

### Configuring providers

In order to enable facebook (or any other provider) you need to give your application id and your application secret to the service. you do it just by setting the environement variables.

With cloudfoundry :
`
vmc env-add APPNAME FACEBOOK_KEY=""
vmc env-add APPNAME FACEBOOK_SECRET=""
`

### Configuring stores

`
vmc env-add APPNAME STORE_USER=""
vmc env-add APPNAME STORE_TOKEN=""
vmc env-add APPNAME STORE_GROUP=""
`
# Features/Status :

In this first dev release you can find :
- the beginning of the local storage (usefull for testing)
- a Makefile
- Some event capabilities with socket io
- a bad version of authentification with token (will be replace quickly with oauth2)
- Basic and non crypted user authentification
- a bit of group management
- Some tests
- first ideas on access management

Next priorities :
- OAuth2
- Configuration form environement variables. ( easy management from web services)
- More test
- Design
- coffee lint



Some futures priorities :

- Refactoring modules to include self described module.
- Group and access management
- Full restfull interface
- logs
- Events with socket.io
- MongoDb/CouchDb/Redis stores
- Admin interface

More is coming....



##Modules

The application is composed of module, each module declare some routes and do something independant.
Some module depend on other module.

### Access
The access module is used to check if a user can do something. There is no route declared.

### Auth
The Auth module is used to manage user authentification, it provide the /login route.

### event
The event module provide a real time socket.io events. Any client authorized can connect to the server and listen to the events (new user, user added to a group, user loggued in,...)
You can listen to what is happening on the service in real time

### Group
The group module provide the group management system and the route to manage the group in rest.

### Store
The stores are used by other module to save the datas. The store are an abstractation so you can store your user in MySQL or MongoDb or files... there are different kind of store.

### Token
Token should disapear soon replaced by oauth2

### User
User provide a restfull interface for client to query users.

