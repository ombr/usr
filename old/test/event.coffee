should = require('chai').should()
expect = require('chai').expect()
tobi = require 'tobi'

describe('Events', ()->

    app = {}
    browser = {}
    socket ={}

    tool = require './tool'

    before((done)->
        app = tool.app()
        browser = tool.browser()
        io = require 'socket.io-client'
        socket = io.connect('http://local.host:3001/auth')
        done()
    )


    after(()->
        tool.delete(app)
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
