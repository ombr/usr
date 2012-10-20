Q = require 'q'
module.exports = class Crypt
  _store : {}
  salt : ()->
    return Q.when(Math.random())
  hash : (str,salt)->
    hash = str+salt
    return Q.when(hash)
  init : ()->
    Q.when(true)
