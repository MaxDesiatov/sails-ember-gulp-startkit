MetadataRoute = Ember.Route.extend
  model: ->
    c = @controllerFor @routeName
    c.set 'modelName', @modelName

    c.queryData()

`export default MetadataRoute`
