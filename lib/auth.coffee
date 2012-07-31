module.exports = class Auth
    constructor : (app)->
        @app = app
        @._everyAuth()
        @._routes()

    _routes : ()->
        _ = @
        @app.get('/login/*', (req, res)->
            if req.params? and req.params[0]? and req.params[0] != ''
                req.session.url = req.params[0]
            if req.user?
                res.redirect('/redirect/')
                return
            res.redirect('/auth/local')#!TODO RENDER LOGIN PAGE
        )

        @app.get('/token/:token/:auth', (req, res)->
            #SECURITY : You can only check your own token
            if req.params['token'] != req.params['auth']
                _.app._error(req,res)
                return
            userId = _.app.stores.token.getToken(req.params['token'],(datas)->
                if datas == null
                    _.app._error(req,res)
                    return
                _.app.stores.user.findUserById(datas.userId,(user)->
                    if user != null
                        res.json(user)
                        return
                    _.app._error(req,res)
                    return
                )
            )
        )
        @app.get('/redirect', (req, res)->
            if not req.loggedIn
                res.redirect('/login/')
                return
            tokenCallback = (token)->
                if req.session.url?
                    #_.app.log.debug "Redirect "+url
                    url = req.session.url+token
                    req.session.url = null
                    res.redirect(url)
                    return
                else
                    #_.app.log.debug "Display token "+token
                    res.json(
                        token : token
                    )
                    return
            if req.session.token?
                tokenCallback(req.session.token)
            else
                _.app.stores.token.addToken(
                    userId :req.user.id
                    ,(newToken)->
                        req.session.token = newToken
                        tokenCallback(newToken)
                        _.app.event.emit('user/token',
                            token:newToken
                        )
                )
        )

    login : (source, id, datas, user, cb)->
        _ = @
        store = @app.stores.user
        #Check on user :  Does the user is already logged in ?
        if user != null
            #   Is it a new way of connection ?
            #@log.debug "User Is already in, let's add a way of login !"
        else
            try
                store.findUserBySourceAndId(source,id,(user)->
                    if source == 'local'
                        #!TODO password hash with a good method....
                        if datas.password != user[source].password
                            throw 'Wrong Password'
                            return
                    _.app.event.emit('user/login',
                        userId:user.id
                    )
                    cb(user)
                )
            catch e
                if e == 'Not found'
                    store.addUser(source,id,datas,(userId)->
                        #find a better way ?
                        store.findUserById(userId,(user)->
                            cb(user)
                            return
                            #_.app.event.emit('user/new',
                            #    userId:userId
                            #)
                        )
                    )
                else
                    throw e

    _everyAuth : ()->
        _ = @
        store = @app.stores.user
        @everyAuth = require 'everyauth'
        #@everyAuth.debug = true
        @everyAuth.everymodule.findUserById((id, cb)->
            try
                store.findUserById(id,(user)->
                    cb(null,user)
                )
            catch e
                cb([e],null)
        )
        #PASSWORD :
        @everyAuth
            .password
                .loginWith('email')
                .getLoginPath('/auth/local')
                .postLoginPath('/auth/local')
                .loginView('login')
                .authenticate((login, password)->
                    promise = this.Promise()
                    try
                        _.login('local',login,
                            login:login
                            password:password
                            ,null#!TODO put here user from session
                            ,(user)->
                                promise.fulfill(user)
                        )
                    catch e
                        promise.fulfill([e])

                    return promise
                )
                .getRegisterPath('/register')
                .postRegisterPath('/register')
                .registerView('register.jade')
                .validateRegistration((newUserAttrs, errors)->
                    return null
                )
                .registerUser((newUserAttrs)->
                    return null
                )
            .loginSuccessRedirect('/redirect')
            .registerSuccessRedirect('/redirect')
        for providerName, providerConfigs of _.app.configs.everyAuth
            @._everyAuth_Providers(providerName, providerConfigs)
        #Register EveryAuth
        @app.app.use(@everyAuth.middleware())
        @everyAuth.helpExpress(@app.app)

    _everyAuth_Providers:(providerName, providerConfigs)->
        _ = @
        for key, value of providerConfigs
            @everyAuth[providerName][key](value)
            @everyAuth[providerName].redirectPath('/redirect')
            @everyAuth[providerName].findOrCreateUser(
                (session, accessToken, accessTokenExtra, datas)->
                    datas.accessToken = accessToken
                    datas.accessTokenExtra = accessTokenExtra
                    promise = _.everyAuth.password.Promise()
                    _.login(
                        providerName,
                        accessToken,
                        datas,
                        null,#!TODO Need to put here the user
                        (err,user)->
                            if err?
                                promise.fulfill(err)
                                return
                            promise.fulfill(user)
                        ,
                        session)
                    return promise
            )
