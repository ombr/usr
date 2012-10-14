should = require('chai').should()
expect = require('chai').expect()

describe('Login Logout', ()->

  browser = {}
  app = {}
  server = {}
  client = {}
  clientUrl = ''
  clientServer = {}
  url = ""
  Tool = require './tool'
  tool = new Tool()

  before((done)->
    tool.start().then((res)->
      browser = res.browser
      app = res.app
      server = res.server
      url = res.url
      tool.clientApp().then((res)->
        clientServer = res.server
        clientUrl = res.url
        done()
      )
    ).end()
  )

  after(()->
    tool.delete(clientServer)
    tool.delete(server)
  )

  ###
  describe('/login', ()->
    it('A user should be able to login/register',(done)->
      console.log url+'/login'
      browser.visit(url+'/login').then(
        ()->
          browser.
            fill("login", "luc@boissaye.fr").
            fill("password", "MyPassword").
            pressButton("#go",
              ()->
                return done()
            )
      ).fail((error)->
        console.log error
      )
    )
  )
  ###

  describe('Client App integration', ()->
    it('A user should be able to log in for a client',(done)->
      console.log "BROWSER VISIT #{clientUrl}"
      browser.visit(clientUrl).then(
        ()->
          console.log "BROWSER TEST :"
          console.log browser.location.pathname
          browser.
            fill("login", "luc@boissaye.fr").
            fill("password", "MyPassword").
            pressButton("#go",
              ()->
                return done()
            )
      ).fail((error)->
        console.log error
      )
    )
  )

  #describe('Client App integration', ()->
    #it('A user should be able to log in for a client',(done)->
      #tobi = require('tobi')
      #browser = tobi.createBrowser(3001,'local.host')
      #browser.get('/', (res, $)->
        #console.log res
        #console.log $
        #$('form').fill(
            #login:'luc@boissaye.fr'
            #password:'MyPassword'
        #).submit((res,$)->
            #done()
        #)
      #)
    #)
  #)

)
