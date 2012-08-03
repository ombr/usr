class Tool

    app:()->
        configs = require './configs'

        express = require 'express'
        app = express.createServer(
            express.bodyParser(),
            express.static(__dirname + "/public"),
            express.favicon(),
            express.cookieParser(),
            express.session({ secret: 'supersecret'}),
        )

        Auth = require '../lib/app'
        auth = new Auth(app,configs)

        app.get('/', (req, res)->
            res.render('index.jade')
        )

        app.configure(()->
          app.set('view engine', 'jade')
          app.set('views', __dirname + '/../views')
        )
        app.listen(configs.app.port)
        return auth
    #Will Return the user or a new user
    user : (app, cb, name)->
        if not name?
            name = @_uniq('user')
        app.auth.addUser('local',name,{},(err,userId)->
            if err != null
                throw "An Error occured"
            cb(userId)
        )
    group: (app, cb, name)->
        if not name?
            name = @_uniq('user')
        app.stores.group.findByName(name,(err,group)->
            if err != null
                app.stores.group.add(name, (err,groupId)->
                    cb(groupId)
                )
                return
            cb(group.id)
        )

    token : (app,userId,cb)->
        app.token.add(userId,{}, (err,token)->
            if err != null
                throw "An Error occured"
            cb(token)
        )

    _uniq:(prefix = '')->
        timestamp = new Date().getTime()
        id = Math.round( timestamp+""+Math.round(Math.random()*1000))
        return prefix+id

module.exports = new Tool()
