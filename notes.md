#Specifications 

## Client identifier Size : Regex ?  public/private key pair ?  ## Client authentification Using HTTP BASIC AUTH using TLS Application password ?  client_id ## Applications needs : Password Callback Url ? Many redirection end point ? Or Only one ? Accept query parameters ?  Callback Url Failure...  Grants authorized ??? As a group ?  ## Authorisation end-point GET (Bonnus post) TLS response_type = "token" or others code separated by spaces...  ## Endpoint request confidentiality Non TLS should warn the client.

Many 

## Authorisation request :
Add the redirect_uri => Must be compared and matched. With String comparaison 6.2.1

## Warning redirection end point response
Need to remove the credentials from the redirection end point response


## Token end point

Client must authentificate with credentials
return scope
we present an authorization grant or refresh token.
Works with auhorization grant but can also generate a client token.

## Grants
authorization code : confidential clients,
    - redirect with scope, clientId, redirection uri, local state ?  4.1.1.
    - redirected back with localstate + authorization code 4.1.2.
    - client request an access token with the authorization code and redirection URI used for code verification
    - If ok, return an access token and a refresh token ?


implicit
ressource owner and password credentials
client credentials
refrech tokens ?

fragment component ??

Inside of an user, we have :
_scope_group = [ array_of_application ] 

Example of scope : 
    Same concept as groups ? Decomposition ?
        nameOfGroup_metagroup
    user_id_read ? => User Visisbility ?
    user_name_read -> read a variable
    user_name_add -> Add a field ?
    user_name_remove -> remove a field ?
    user_name_write -> rewrite the value
    user_post_read....
    group__group_add -> ??? 


Token
Refrech Token
Authorization Code
Scope ~ Groups ?
