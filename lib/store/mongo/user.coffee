Mongo = require 'mongodb'

module.exports = class StoreMongo
    constructor : (@configs)->
        _ = @
        @db = new require("node-promise").Promise()
        Mongo.connect(@configs.mongoUrl,(err,conn)->
            if err?
                _.log.error err
                return
            db =
                conn :conn
            loadCollection = (collectionName,db,cb)->
                conn.collection(collectionName,(err,col)->
                    if err?
                        _.log.error err
                        #app.log.error "Can not load collection "+collectionName
                        return
                    db[collectionName] = col
                    cb()
                )
            require('async').parallel([
                (cb)->
                    loadCollection('users',db,cb)
                ,(cb)->
                    loadCollection('groups',db,cb)
                ],()->
                    _.db.resolve(db)
            )
        )
    findUserById : (id,cb)->
        error = false
        try
            ObjectID = require('mongodb').ObjectID
            oid = new ObjectID(String(id))
            @db.then((db)->
                db.users.findOne({"_id":oid},{},(err,user)->
                    user.id = user._id
                    if err != null
                        cb(err,null)
                        return
                    if user == null
                        cb(['User not found'],null)
                        return
                    cb(null,user)
                )
            )
        catch err
            cb(['User Not found'],null)
            return
    addUser : (source, id, datas,cb)->
        @db.then((db)->
            user = {}
            user[source] = datas
            user[source].id = id #make sure we have the id set in the datas...
            db.users.insert(user,(err,users)->
                if err?
                    cb(err,null)
                    return
                users[0].id = users[0]._id
                cb(null,users[0])
            )
        )
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
