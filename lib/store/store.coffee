Q = require 'q'

#console.log "TEST"
#console.log "TEST"
#console.log "TEST"
#Q.fcall(()->
  #throw new Error('World')
  #return "Hello"
#).then((test)->
  #console.log test
#,(test)->
  #console.log test
#).end()





module.exports = class Store
  init : ()->
    @._store = {}
    Q.when(true)

  _generateId:()->
    timestamp = new Date().getTime()
    id = Math.round( timestamp+""+Math.round(Math.random()*1000))
    return id

  add:(datas)->
    _ = @
    return Q.fcall(()->
      id = _._generateId()
      if _._store[id]?
        throw new Error("Id Collision")
      datas.id = id
      _._store[id] = datas
      return datas
    )

  get:(id)->
    _ = @
    return Q.fcall(()->
      if not _._store[id]?
        throw new Error("Not Found")
      return _._store[id]
    )

  delete:(id)->
    _ = @
    return Q.fcall(()->
      if not _._store[id]?
        throw new Error("Not found.")
      delete(_._store[id])
      return true
    )

  findOneBy:(datas)->
    _ = @
    return Q.fcall(()->
      for id,obj  of _._store
        valid = true
        for field,value of datas
          if obj[field] != value
            valid = false
            continue
        if valid
          return obj
      throw new Error("Not Found")
    )
