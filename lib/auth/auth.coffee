Q = require 'q'

module.exports = class Auth
  authenticate :(provider)->
    _ = @
    return (req, res, next)->
      console.log "Auth authenticate "+provider
      _.passport.authenticate(provider,{
        scope:'email'
      })(req, res, next)
  auth: (provider)->
    _ = @
    return (req, res, next)->
      _.passport.authenticate(provider, (err, user, info)->
        if err?
          return res.render('error', error:err)
        if (!user)
          #Display the login view
          console.log "TEST RENSER LOGIN? "
          return res.render 'login'
        req.logIn(user,{}, (err)->
          if err?
            res.render('error', error:err)
          else
            next()
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
