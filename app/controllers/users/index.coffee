UsersController = Ember.ArrayController.extend
  actions:
    createUser: ->
      user = @store.createRecord 'user',
        name: 'Learn Ember.js'
        firstName: 'x'
        lastName: 'y'
        group: 'kjlnsdlkv'
        isCompleted: true

      user.save()

`export default UsersController`
