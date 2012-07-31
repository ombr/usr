configs = {}
module.exports = configs

###
#Application
###
configs.app =
    port : process.env.VCAP_APP_PORT or 3001

###
#MONGO
###
if process.env.VCAP_SERVICES
  env = JSON.parse(process.env.VCAP_SERVICES)
  mongo = env["mongodb-1.8"][0]["credentials"]
else
  mongo =
    hostname: "localhost"
    port: 27017
    username: ""
    password: ""
    name: ""
    db: "db"
generate_mongo_url = (obj) ->
  obj.hostname = (obj.hostname or "localhost")
  obj.port = (obj.port or 27017)
  obj.db = (obj.db or "test")
  if obj.username and obj.password
    "mongodb://" + obj.username + ":" + obj.password + "@" + obj.hostname + ":" + obj.port + "/" + obj.db
  else
    "mongodb://" + obj.hostname + ":" + obj.port + "/" + obj.db

###
#Stores
###
configs.stores =
    user :
        class : "./lib/store/local/user"
    token :
        class : "./lib/store/local/token"
    group :
        class : "./lib/store/local/group"

###
#EveryAuth
###

configs.everyAuth =
  facebook:
    appId: "111565172259433"
    appSecret: "85f7e0a0cc804886180b887c1f04a3c1"

  twitter:
    consumerKey: "JLCGyLzuOK1BjnKPKGyQ"
    consumerSecret: "GNqKfPqtzOcsCtFbGTMqinoATHvBcy1nzCTimeA9M0"

  github:
    appId: "11932f2b6d05d2a5fa18"
    appSecret: "2603d1bc663b74d6732500c1e9ad05b0f4013593"

  instagram:
    appId: "be147b077ddf49368d6fb5cf3112b9e0"
    appSecret: "b65ad83daed242c0aa059ffae42feddd"

  foursquare:
    appId: "VUGE4VHJMKWALKDKIOH1HLD1OQNHTC0PBZZBUQSHJ3WKW04K"
    appSecret: "0LVAGARGUN05DEDDRVWNIMH4RFIHEFV0CERU3OITAZW1CXGX"

  gowalla:
    appId: "11cf666912004d709fa4bbf21718a82e"
    appSecret: "e1e23f135776452898a6d268129bf153"

  linkedin:
    consumerKey: "pv6AWspODUeHIPNZfA531OYcFyB1v23u3y-KIADJdpyw54BXh-ciiQnduWf6FNRH"
    consumerSecret: "Pdx7DCoJRdAk0ai3joXsslZvK1DPCQwsLn-T17Opkae22ZYDP5R7gmAoFes9TNHy"

  google:
    appId: "3335216477.apps.googleusercontent.com"
    appSecret: "PJMW_uP39nogdu0WpBuqMhtB"

  
  #  , googlehybrid: {
  #        consumerKey: 'YOUR CONSUMER KEY HERE'
  #      , consumerSecret: 'YOUR CONSUMER SECRET HERE'
  #    }
  angellist:
    appId: "e5feda9308f55f16b0ef0e848f5b1e41"
    appSecret: "e0ec367efb9d59fa10bdd53ba268b81f"

  yahoo:
    consumerKey: "dj0yJmk9RVExRlhPRE9rV1hSJmQ9WVdrOWEyRTBVMUJoTm1zbWNHbzlNVE13TURFeU9UTTJNZy0tJnM9Y29uc3VtZXJzZWNyZXQmeD1iYg--"
    consumerSecret: "efe6ae4982217630fe3aebf6e6fa1e82c02eba0b"

  readability:
    consumerKey: "Alfrednerstu"
    consumerSecret: "MXGftcxrRNMYn66CVmADR3KRnygCdYSk"

  justintv:
    consumerKey: "enter your consumer key here"
    consumerSecret: "enter your consumer secret here"

  tumblr:
    consumerKey: "TAofjqRz9iKiAjtPMnXzHELIeQAw8cqKCZVXaEFSAxBrrvV99f"
    consumerSecret: "s8ldFtirtsnWGSiBjwpUwMct8Yh4sliS9Uiocqsv3bw0ovMtlR"

  dropbox:
    consumerKey: "uhfqnbely5stdtm"
    consumerSecret: "jr7ofuwo32l7vkd"

  vimeo:
    consumerKey: "Enter your consumer key here"
    consumerSecret: "Enter your consumer secret here"

  box:
    apiKey: "5hl66lbfy0quj8qhhzcn57dflb55y4rg"

  dwolla:
    appId: "Enter your consumer key here"
    appSecret: "Enter your consumer secret here"

  vkontakte:
    appId: "Enter your app id here"
    appSecret: "Enter your app secret here"

  skyrock:
    consumerKey: "a0ae943e20c5af88"
    consumerSecret: "cjucy86r0fg4uxx3"

  evernote:
    oauthHost: "https://www.evernote.com"
    consumerKey: "Enter your consumer key here"
    consumerSecret: "Enter your consumer secret here"

  tripit:
    consumerKey: "a59bb58479f80e24dc6da1b1e61a107db743bc4c"
    consumerSecret: "41dc4c0c39ac3ab162269a79f399eb180f753c66"

  mixi:
    appId: "Enter your consumer key here"
    appSecret: "Enter your consumer secret here"
