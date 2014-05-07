Router = Ember.Router.extend()

Router.reopen
  location: 'auto'

Router.map ->
  @resource 'users', path: '/', ->

`export default Router`
