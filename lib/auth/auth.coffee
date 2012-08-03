Component = require '../component'
module.exports = class Auth extends Component
    constructor : (app)->
        @app = app
        @._everyAuth()
        @._routes()

    #No Check on addUser, everybody can register or create a new user
    addUser : (source='', id='', datas={},cb)->
        _ = @
        store = @app.stores.user
        store.addUser(source,id,datas,(err,userId)->
            _.checkErr(err)
            cb(null,userId)
            _.emit('user/new',
                userId : userId
                source : source
                id : id
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
            store.findUserBySourceAndId(source,id,(err,user)->
                if err?
                    if err[0] == 'Not found'
                        store.addUser(source,id,datas,(err,userId)->
                            #find a better way ?
                            store.findUserById(userId,(err,user)->
                                cb(null,user)
                                _.app.event.emit('user/login',
                                    userId:user.id
                                )
                                return
                            )
                        )
                    else
                        cb(err,null)
                        return
                else
                    if source == 'local'
                        #!TODO password hash with a good method....
                        if datas.password != user[source].password
                            cb(['Wrong Password'],null)
                            return
                    _.app.event.emit('user/login',
                        userId:user.id
                    )
                    cb(null,user)
                    return
            )

    _routes : ()->
        _ = @

        #Add a Are you sure on the logout ?
        @routeGet('/logout/*', (req, res)->
            req.logout()
            delete(req.session.token)
            if req.params? and req.params[0]? and req.params[0] != ''
                res.redirect(req.params[0])
                return
            #!TODO redirect you from where you are coming ?
            res.redirect('/')#!TODO RENDER LOGIN PAGE
        )
        @routeGet('/login/*', (req, res)->
            if req.params? and req.params[0]? and req.params[0] != ''
                req.session.url = req.params[0]
            if req.user?
                res.redirect('/redirect/')
                return
            res.redirect('/auth/local')#!TODO RENDER LOGIN PAGE
        )


        #!TODO Check on AppToken
        @routeGet('/info/:token/:appToken', (req, res)->
            json = {}
            _.app.token.getInfo(req.params.token,req.params.appToken,(err,info)->
                _.checkErr(err)
                res.json(info)
            )

        )
        @routeGet('/redirect', (req, res)->
            if not req.loggedIn
                res.redirect('/login/')
                return
            tokenCallback = (err,token)->
                req.session.token = token
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
                tokenCallback(null,req.session.token)
            else
                _.app.token.add(req.user.id, {}, tokenCallback)
        )
    _everyAuth : ()->
        _ = @
        store = @app.stores.user
        @everyAuth = require 'everyauth'
        #@everyAuth.debug = true
        @everyAuth.everymodule.findUserById((id, cb)->
            store.findUserById(id,cb)
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
                    _.login('local',login,
                        login:login
                        password:password
                        ,null#!TODO put here user from session
                        ,(err,user)->
                            if err != null
                                promise.fulfill(err)
                                return
                            promise.fulfill(user)
                    )
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
        @express().use(@everyAuth.middleware())
        @everyAuth.helpExpress(@express())

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
