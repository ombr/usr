Component = require '../component'
module.exports = class Event extends Component
  constructor : (app)->
    return
    @app = app
    @access = app.access
    io = require('socket.io').listen(server)
    io.set('log level', 1)
    
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
        #!TODO Check on datas.event
        _.app.access.check(
          datas.token,
          ['_event_'+datas.event,'_event_*','_root'],
          (err,userId)->
            _.checkErr(err)
            _.on(datas.event,(datas)->
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
      )
    )
