`import PageableMixin from "appkit/controllers/pageable"`

UsersController = Ember.ArrayController.extend PageableMixin,
  actions:
    createUser: ->
      user = @store.createRecord 'user',
        name: 'Learn Ember.js'
        firstName: 'x'
        lastName: 'y'
        group: 'kjlnsdlkv'
        isCompleted: true

      user.save()

  sort: 'name'
  sortDirection: 'ASC'
  rawQuery: ''
  partial: 'users-table'

  where:
    Em.computed ->
      raw = @get 'rawQuery'
      if raw.length > 0
        lastName: like: "%#{raw}%"
      else
        {}
    .property 'rawQuery'

`export default UsersController`
