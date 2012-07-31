should = require('chai').should()

describe('Events', ()->

    describe('Server',()->
        describe('ready',()->
            it('')
        )
    )
    describe('User',()->
        describe('logout',()->
            it('Should be emitted when a user logout')
        )
        describe('login',()->
            it('Should be emitted when a user log in')
        )
        describe('new',()->
            it('Should be emitted when a new user is added')
        )
        describe('delete',()->
            it('Should be emitted when a new user is deleted')
        )
        describe('token',()->
            it('Should be emitted when a new token is generated')
        )
    )
    describe('Group',()->
        describe('new',()->
            it('')
        )
        describe('delete',()->
            it('')
        )
        describe('addUser',()->
            it('')
        )
        describe('removeUser',()->
            it('')
        )
        describe('addGroup',()->
            it('')
        )
        describe('removeGroup',()->
            it('')
        )
    )

    describe('Access',()->
        describe('token',()->
            it('')
        )
        describe('user',()->
            it('')
        )
        describe('group',()->
            it('')
        )
    )

)
