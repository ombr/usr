Store = require './store'
module.exports = class User extends Store
    constructor : (@configs)->
        _ = @
        @db = new require("node-promise").Promise()
        Mongo = require 'mongodb'
        Mongo.connect(@configs.mongoUrl,(err,conn)->
            if err?
                console.log err
                return
            db =
                conn :conn
            loadCollection = (collectionName,db,cb)->
                conn.collection(collectionName,(err,col)->
                    if err?
                        console.log err
                        return
                    db[collectionName] = col
                    cb()
                )
            require('async').parallel([
                (cb)->
                    loadCollection('users',db,cb)
                ,(cb)->
                    loadCollection('groups',db,cb)
                ,(cb)->
                    loadCollection('tokens',db,cb)
                ],()->
                    _.db.resolve(db)
            )
        )
    addUser : (source, id, datas,cb)->
        user = {}
        datas.id = id
        user[source] = datas
        @_addItem("users", user, cb)

    findUserById : (id,cb)->
        @_getItem("users", id, cb)

    findUserBySourceAndId : (source, id, cb)->
        @db.then((db)->
            query = {}
            query[ source + ".login" ] = id
            db.users.findOne(query,{},(err,user)->
                if err != null
                    cb(err,null)
                    return
                if user == null
                    cb(['User not found'],null)
                    return
                user.id = user._id
                cb(null,user)
            )
        )
