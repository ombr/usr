
Q = require 'q'
module.exports = class Init
  init:(@deps)->
    EventEmitter = require('eventemitter2').EventEmitter2
    @_events = new EventEmitter(
      wildcard:true
    )
    return Q.when(true)
  on:(event,func)->
    return @_events.on(event,func)

  once:(event,func)->
    return @_events.once(event,func)

  emit:(event,data)->
    return @_events.emit(event,data)

  #_init_socket:()->
    #_ = @
    #SUBSCRIBE TO EVENTS
    #@channel.on('connection', (socket)->
      #socket.on('ping',(datas)->
        #socket.emit('pong',datas)
      #)
      #socket.on('subscribe',(datas)->
        #!TODO Check on datas.event
        #_.app.access.check(
          #datas.token,
          #['_event_'+datas.event,'_event_*','_root'],
          #(err,userId)->
            #_.checkErr(err)
            #_.on(datas.event,(datas)->
              #socket.emit(this.event, datas)
            #)
            #_.emit('event/subscribe',
              #token : datas.token
              #userId : userId
              #event : datas.event
            #)
            #!TODO Remove listener if socket close ?
          #,'event/subscribe'
        #)
      #)
    #)
