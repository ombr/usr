
Component = require '../component'
module.exports = class Token extends Component
    constructor : (app)->
        @app = app
        @store = app.stores.token
        @._routes()

    _routes : ()->
        _ = @
        #!TODO change this route...
        @routeGet('/token/:token/:auth', (req, res)->
            #SECURITY : You can only check your own token
            if req.params['token'] != req.params['auth']
                _.app._error(req,res)
                return
            userId = _.app.stores.token.getToken(req.params['token'],(err,datas)->
                if datas == null
                    _.app._error(req,res)
                    return
                _.app.stores.user.findUserById(datas.userId,(err,user)->
                    if user != null
                        res.json(user)
                        return
                    _.app._error(req,res)
                    return
                )
            )
        )

    get : (token, cb)->
        @store.get(token, cb)
    add : (userId, options, cb)->
        _ = @
        _.app.stores.token.addToken(
            {
                userId : userId
            },
            (err,token)->
                _.checkErr(err)
                cb(err,token)
                _.emit('token/new',
                    token: token
                    userId : userId
                )
        )
