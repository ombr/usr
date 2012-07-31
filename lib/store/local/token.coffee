Store = require './store'
module.exports = class Token extends Store
    constructor : (configs)->
        @_tokens = {}
        return
    addToken : (datas, cb)->
        token = @._generateId()
        @_tokens[token] = datas
        cb(token)

    getToken : (token,cb)->
        if @_tokens[token]?
            cb(@_tokens[token])
            return
        cb(null)

    deleteToken : (token,cb)->
        if @_tokens[token]?
            delete(@_tokens[token])
            cb(true)
            return
        cb(false)
