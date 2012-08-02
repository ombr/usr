should = require('chai').should()
expect = require('chai').expect()
tobi = require 'tobi'

describe('Events', ()->

    app = {}
    browser = {}
    
    socket ={}
    before((done)->
        app = require('./app')()
        tobi.Browser.browsers = {}
        browser = tobi.createBrowser(3001, 'local.host')
        browser.userAgent = 'Mozilla/5.0 (X11; Linux i686) AppleWebKit/534.30 (KHTML, like Gecko) Chrome/12.0.742.100 Safari/534.30'
        io = require 'socket.io-client'
        socket = io.connect('http://local.host:3001/auth')
        done()
    )

    after(()->
        app.express.close()
    )

    describe('Ping', ()->
        it('Should answer pong',(done)->
            socket.on('',(datas)->
                console.log "EVENT RECIEVED !!"
                console.log datas
            )
            socket.on('pong',()->
                done()
            )
            socket.emit('ping',{})
        )
    )

    describe('Subscribe', ()->
        it('Should be able to subscribe to events',(done)->
            app.auth.addUser('local','ombr0',{},(err,userId)->
                app.token.add(userId,{},(err,token)->
                    socket.on('event/subscribe',(datas)->
                        console.log "Subscribed :-)"
                        console.log datas
                        done()
                    )
                    socket.emit('subscribe',
                        userId : userId
                        token : token
                        event : '*'
                    )
                )
            )
        )
    )
)
