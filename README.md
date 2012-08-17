# Usr Authentification and role management REST OAuth Webservice

Everytime you start a new project or create a new service. You need to code the user authentification and your group management in order to manage you users. With Usr you just have one service and easy rest methods to manage you users and their groups.

## Description

Usr provides you a webservice to authenticate and manage your users with a REST API :

- EveryAuth enable your users to login with any credentials or service (Facebook,...)
- Your users create a unique account for all your services.
- All your futures application can use usr to authentificate your user and get their roles.
- Use any storage (MongoDb, CouchDb, MySQL,..)

## Authentification of a user :

1/ You deploy your service to auth.yourdomain.com
2/ You can use Oauth2 to authentificate your user.


## Status

Currently there is not much working on, but you can user
`make test` to see the status


The goal of this project :

An easy to deploy on cloudfoundry webservice that you can use for any of your project to authenticate your user and manage their groups. I follow oAuth2 specs and maps the group user in the scope.

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
- More test
- Group and access management
- Full restfull interface
- logs
- coffee lint

Some futures priorities :

- Events with socket.io
- MongoDb/CouchDb/Redis stores
- Admin interface

More is coming....
