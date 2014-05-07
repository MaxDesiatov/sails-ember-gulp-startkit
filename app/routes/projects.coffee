ProjectsRoute = Ember.Route.extend
  model: -> @store.find 'project'

`export default ProjectsRoute`
