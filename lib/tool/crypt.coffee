Q = require 'q'
module.exports = class Crypt
  _store : {}
  salt : ()->
    return Q.when(Math.round(Math.random()*100000))
  hash : (str,salt)->
    hash = str+salt
    return Q.when(hash)
  init : ()->
    Q.when(true)
