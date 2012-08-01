Component = require '../component'
module.exports = class Event extends Component
    constructor : (app)->
        @app = app
        @access = app.access
        io = require('socket.io').listen(app.app)
        @channel = io.of('/auth')#!TODO Put in configs...
        #@channel = io
        @_init_socket()
    _init_socket:()->
        _ = @
        #SUBSCRIBE TO EVENTS
        @channel.on('connection', (socket)->
            socket.on('ping',(datas)->
                socket.emit('pong',datas)
            )
            socket.on('subscribe',(datas)->
                try
                    #!TODO Check on datas.event
                    _.app.access.check(
                        datas.token,
                        ['_event_'+datas.event,'_event_*','_root'],
                        (userId)->
                            console.log "Event "+datas.event+" transfered to socket io"
                            _.on(datas.event,(datas)->
                                console.log "New Event to socketIO#{@.event}"
                                socket.emit(this.event, datas)
                            )
                            _.emit('event/subscribe',
                                token : datas.token
                                userId : userId
                                event : datas.event
                            )
                            #!TODO Remove listener if socket close ?
                        ,'event/subscribe'
                    )
                catch e
                    console.log "SUBSCRIVE ERROR :"+e
            )
        )

