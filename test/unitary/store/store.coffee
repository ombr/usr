Q = require 'q'
should = require('chai').should()

describe('Store User', ()->
  testStore = (getStore)->
    describe('add', ()->
      it('Should be empty',(done)->
        getStore().then((store)->
          store.get(32432423432).fail(()->
            done()
          ).done()
        )
      )
      it('Some datas can be set and retrieve',(done)->
        getStore().then((store)->
          store.add(
            key:'lalal'
            key2:'value'
          ).then((id)->
            store.get(id)
          ).then((datas)->
            done()
          ).done()
        )
      )
    )
    describe('delete', ()->
      it('Some datas can be set delete and not retrieved',(done)->
        getStore().then((store)->
          store.add(
            key:'lalal'
            key2:'value'
          ).then((id)->
            return store.delete(id).then(()->
              store.get(id).fail(()->
                done()
              )
            )
          ).done()
        )
      )
      it('should not be able to delete twice',(done)->
        getStore().then((store)->
          store.add(
            key:'lalal'
            key2:'value'
          ).then((id)->
            return store.delete(id).then(()->
              store.delete(id).fail(()->
                done()
              )
            )
          ).done()
        )
      )
    )
    describe('findOneBy', ()->
      it('Should return a user which match',(done)->
        getStore().then((store)->
          obj =
            test: 'sdfsdf'
          store.add(
            key1:'lalal'
            key2:'value'
          ).then(()->
            return store.findOneBy(
              key1:'lalal'
            )
          ).then((res)->
            res.key2.should.equal("value")
            done()
          )
        )
      )
    )
    describe('Concurency of stores', ()->
      it('Two stores can be instanciated at the same time',(done)->
        Q.all([
            getStore(),
            getStore()
        ]).then((stores)->
          [store1,store2] = stores
          return Q.all([
            store1.add(key1:'test'),
            store2.add(key1:'yeah')
          ]).then((datas)->
            [data1,data2] = datas
            store1.findOneBy(key1:'yeah').then((data)->
              throw new Error "TEST FAILED"
            )
          )
        ).fail((error)->
          if error.message == "TEST FAILED"
            throw error
          else
            done()
        ).done()
      )
    )
      
  for path in ['../../../lib/store/store']
    testStore(()->
      defered = Q.defer()
      Store = require path
      store = new Store()
      store.init().then(()->
        defered.resolve(store)
      )
      return defered.promise
    )
)
