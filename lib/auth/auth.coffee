Q = require 'q'

module.exports = class Auth
  getLogin : (req,res)->
    res.render('login')
  authenticate :(provider)->
    _ = @
    return (req, res, next)->
      console.log "Auth authenticate "+provider
      _.passport.authenticate(provider,{
        scope:'email'
      })(req, res, next)
  endAuthenticate : (provider)->
    _ = @
    return (req, res, next)->
      _.passport.authenticate(provider, (err, user, info)->
        console.log "endAuthentificate"
        if err?
          return res.send "ERROR : #{err}"
        if (!user)
          return res.redirect("/login/?err=#{info.message}")
        req.logIn(user,{}, (err)->
          if err?
            #!TODO How do we manage this erorr ?
            console.log "LOG IN ERORR :"
            console.log err
          else
            _.deps.usr.module('oauth2/oauth2').then((oauth2)->
              oauth2.endAuthorize(req,res,next)
            )
        )
      )(req, res, next)
  init : (@deps)->
    _ = @
    usr = @.deps.usr
    passportReference = require 'passport'
    Passport = passportReference.Passport
    @passport = new Passport()
    passport = @passport

    @deps.usr._middleware.push(@passport.initialize())
    @deps.usr._middleware.push(@passport.session())
    @passport.serializeUser((user, done)->
      console.log "serialize"
      console.log user
      if user.usr_id?
        done(null, user.usr_id)
      else
        done(new Error("usr_id not defined in User"), null)
    )

    @passport.deserializeUser((id, done)->
      console.log "deserialize"
      console.log id
      usr.module('store/user').then((users)->
        return users.get(id)
      ).then((user)->
        done(null,user)
      ).fail((error)->
        done(error,null)
      )
    )
    # Facebook :
    providers = []
    for provider in ['facebook']
      providers.push(@init_provider(provider))
    Q.all(providers).then(()->
      console.log "ALL PROVIDERS LOADED :-D"
    )

    # Email/Password
    LocalStrategy = require('passport-local').Strategy
    @passport.use(
      new LocalStrategy(
        {
          usernameField: 'login',
        },
        (login, password, done)->
          Q.all([
            usr.validate(login,'login'),
            usr.validate(password,'password')
          ]).then((validated)->
            [login, password] = validated
            return Q.all([
              usr.module('store/user'),
              usr.module('store/password')
              usr.module('tool/crypt')
            ]).then((stores)->
              [users,passwords,Crypt] = stores
              users.findOneBy(login:login).then(
                (user)->
                  return Crypt.hash(password, user.salt).then((hash1)->
                    passwords.findOneBy(hash:hash1).then((data)->
                      return Crypt.hash(password,data.salt).then((hash2)->
                        if user.hash != hash2
                          throw new Error("Wrong Password")
                        done(null, user)
                      )
                    ).fail((error)->
                      done(null, false, { message: 'Wrong password'})
                    )
                  ).fail((error)->
                    done(null, false, { message: "Crypt Error"})
                  )
              ).fail((error)->
                salt = ()->
                  defered = Q.defer()
                  Crypt.salt().then((salt)->
                    return Crypt.hash(password,salt).then((hash)->
                      defered.resolve(
                        hash:hash
                        salt:salt
                      )
                    )
                  ).fail((error)->
                    defer.reject(error)
                  )
                  return defered.promise
                Q.all([
                  salt(),
                  salt()
                ]).then((hashs)->
                  user =
                    login:login
                    salt:hashs[0].salt
                    hash:hashs[1].hash
                  Q.all([
                    users.add(user),
                    passwords.add(
                      salt:hashs[1].salt
                      hash:hashs[0].hash
                    )
                  ]).then((results)->
                    [userId,password] = results
                    user.usr_id = userId
                    done(null,user)
                  ).fail((error)->
                    console.log "Auth>Local"
                    console.log error
                    done(null, false, { message: "Database error."})
                  )
                ).fail((error)->
                  console.log "Auth>Local"
                  console.log error
                  done(null, false, { message: "Crypt Error"})
                )
              )
            )
          ).fail((error)->
            console.log "Auth>Local"
            console.log error
            done(null, false, { message: error.message})
          )
      )
    )
    return Q.when(true)
  init_provider : (provider)->
    usr = @deps.usr
    defered = Q.defer()
    usr.config(
      'provider_'+provider+'_enabled',
      false,
      "Is the provider #{provider} enabled"
    ).then((enabled)=>
      if enabled
        Q.all([
          usr.config(
            'provider_'+provider+'_id',
            null,
            "#{provider} app id"
          ),
          usr.config(
            'provider_'+provider+'_secret',
            null,
            "#{provider} app id"
          ),
          usr.config(
            'host',
            'http://local.host:3000',
            "host local link"
          )
        ]).then((configs)=>
          [id,secret,host] = configs
          Strategy = require('passport-'+provider).Strategy
          @passport.use(
            'facebook',
            new Strategy(
              clientID: id,
              clientSecret: secret,
              callbackURL: host+"/auth/facebook/callback"
            ,
            (accessToken, refreshToken, profile, done)->
              datas = {}
              datas[provider] = profile.id
              query = {}
              usr.module('store/user').then((users)->
                query[provider] = datas[provider]
                users.findOneBy(query).then((user)->
                  console.log "FACEBOOK WELCOME BACK"
                  done(null, user)
                ).fail((error)->
                  user = profile
                  user[provider] = datas[provider]
                  #user[provider+"_datas"] = profile
                  users.add(user).then((id)->
                    console.log "FACEBOOK CREATED"
                    user.usr_id = id
                    done(null,user)
                  )
                )
              ).fail((error)->
                console.log "ERORR"
                console.log error
              )
              #datas[provider+"_datas"] = profile
            )
          )
        defered.resolve(true)
        console.log "STRATEGIE FACEBOOK ON "
        )
    )
    return defered.promise
          #usr.validate('login',login).then((login)->
            #usr.module('store-user').then((store)->
              #store.findOneBy(login:login).then((user)->
                #console.log "user found"
              #).fail(()->
                #console.log "user not found"
                #store.add(
                  #login:login
                  #password:password
                #).then((id)->
                  #console.log "new user"+id
                  #return done(null,
                    #{
                      #login:login
                      #pass:password
                    #}
                  #)
                #).fail((error)->
                  #done(null, false, { message: 'Unknown user' })
                #)

              #)
            #)
            #return store.get(login).then
          #)

          #return done(null, false, { message: 'Unknown user' })
          #return done(new Error("TEST"), null, null)
###
          console.log "TEST"
          return true
          usr.validate('login',login).then((login)->
            usr.module('store-user').then((store)->
              store.findOneBy(login:login).then((user)->
                console.log "user found"
              ).fail(()->
                console.log "user not found"
                store.add(
                  login:login
                ).then((id)->
                  console.log "new user"+id
                  return done(null,
                    {
                      login:login
                      pass:password
                    }
                  )
                ).fail((error)->
                  done(null, false, { message: 'Unknown user' })
                )

              )
            )
            return store.get(login).then
          )
          #return done(null, false, { message: 'Invalid password' })
          #return done(null,
            #login :"dsfsdF"
            #password:"asdasd"
          #)
      )
    )
    @._everyAuth()
    @._routes()

  #No Check on addUser, everybody can register or create a new user
  addUser : (source='', id='', datas={}, cb)->
    _ = @
    store = @app.stores.user
    store.addUser(source, id, datas, (err, userId)->
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
      store.findUserBySourceAndId(source, id, (err,user)->
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

###
