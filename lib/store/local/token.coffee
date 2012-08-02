Store = require './store'
module.exports = class Token extends Store
    constructor : (configs)->
        @_tokens = {}
        return
    addToken : (datas, cb)->
        token = @._generateId()
        @_tokens[token] = datas
        cb(null,token)

    getToken : (token,cb)->
        if @_tokens[token]?
            cb(null,@_tokens[token])
            return
        cb(['Not found'],null)

    deleteToken : (token,cb)->
        if @_tokens[token]?
            delete(@_tokens[token])
            cb(null,true)
            return
        cb(null,false)
