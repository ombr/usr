# User Authentification and role management REST Webservice

## Description

Usr provides you a webservice to authenticate and manage your users with a REST API :

- Using EveryAuth to enable your users to login with any credentials
- Using REST to be shared within multiples service.

## Authentification of a user :

1/ You deploy your service to auth.yourdomain.com
2/ On your application, to authentificate a user, just need to :
    - redirect the user to http://auth.yourdomain.com/login/http://mynewapp.com/loguedId/
    - The user will come back to http://mynewapp.com/loguedId/SUPERTOKEN with a token
    - Send a request to get all the details about your user.

