should = require('chai').should()
expect = require('chai').expect()

describe('OAuth2', ()->
  Tool = require './../tool'
  tool = new Tool()

  describe('Authentification End Points', ()->
    it('If the app is could not be authentified, the user should be redirected')
    it('If the callback url is wrong, the user whould be warned and redirected')
    it('If the response type is not registred for this app, the user should '+
      'be warned and redirected')
    it('If the scope is not valid, the user should be warned and redirected')
    it('If the state is not valid, the user should be warned and redirected')
  )
  
  describe('State',()->
    it('Should be stored and given back')
  )

  describe('Should be able to login.', ()->
    it('A user should be able to log in from a client for the first time',
      (done)->
        tool.tool().then((t)->
          browser = t.browser
          browser.visit(t.clientUrl).then(()->
            console.log "ICI"
            console.log browser.text('body')
            browser.
              fill("login", "luc@boissaye.fr").
              fill("password", "MyPassword").
              pressButton("#go",
                ()->
                  browser.location.hostname.should.equals('127.0.0.1')
                  browser.text('#login').should.equals('luc@boissaye.fr')
                  return t.end(done)
              )
          ).fail((error)->
            console.log error
          )
        )
    )
  )

  describe('Should be able to login from another browser.', ()->
    it('A user should be able to log in from a client for the first time',
      (done)->
        tool.tool().then((t)->
          browser = t.browser
          browser.visit(t.clientUrl).then(()->
            browser.
              fill("login", "luc@boissaye.fr").
              fill("password", "MyPassword").
              pressButton("#go",
                ()->
                  browser.location.hostname.should.equals('127.0.0.1')
                  browser.text('#login').should.equals('luc@boissaye.fr')
                  Browser = require 'zombie'
                  browser = new Browser()
                  browser.visit(t.clientUrl).then(()->
                    browser.
                      fill("login", "luc@boissaye.fr").
                      fill("password", "MyPassword").
                      pressButton("#go",
                        ()->
                          browser.location.hostname.should.equals('127.0.0.1')
                          browser.text('#login').should.
                            equals('luc@boissaye.fr')
                          return t.end(done)
                      )
                  )
              )
          ).fail((error)->
            console.log error
          )
        )
    )
  )
)

###
      it('A user should be able to log in from a client for the second time',
        (done)->
          Browser = require 'zombie'
          browser = new Browser()
          browser.visit(t.clientUrl).then(()->
            console.log "ICI"
            console.log browser.text('body')
            browser.
              fill("login", "luc@boissaye.fr").
              fill("password", "MyPassword").
              pressButton("#go",
                ()->
                  browser.location.hostname.should.equals('127.0.0.1')
                  browser.text('#login').should.equals('luc@boissaye.fr')
                  return t.end(done())
              )
          ).fail((error)->
            console.log error
          )
      )

      it('A user should not be able to log in with a wrong password...',
        (done)->
          Browser = require 'zombie'
          browser = new Browser()
          browser.visit(t.clientUrl).then(()->
            console.log "ICI"
            console.log browser.text('body')
            browser.
              fill("login", "luc@boissaye.fr").
              fill("password", "MyPassword3").
              pressButton("#go",
                ()->
                  browser.location.hostname.should.equals('127.0.0.1')
                  browser.text('#login').should.equals('luc@boissaye.fr')
                  return t.end(done())
              )
          ).fail((error)->
            console.log error
          )
      )

    )
  )
)

    it('A user should not need to log in again (Client side)',
      (done)->
        browser.reload().then(
          ()->
            browser.text('#login').should.equals('luc@boissaye.fr')
            browser.location.hostname.should.equals('local.host2')
            return done()
        ).fail((error)->
          console.log error
        )
    )

    it('A user should not need to log in again (Usr side session)',
      (done)->
        #We restart the cliend to kill sessions
        tool.clientApp(clientServer).then((res)->
          clientServer = res.server
          clientUrl = res.url
          browser.reload().then(
            ()->
              browser.text('#login').should.equals('luc@boissaye.fr')
              browser.location.hostname.should.equals('local.host2')
              return done()
          ).fail((error)->
            throw error
          )
        )
    )
  )
)

