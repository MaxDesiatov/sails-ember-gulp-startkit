RemovableController = Ember.ObjectController.extend
  actions:
    removeModel: ->
      model = @get 'model'
      model.deleteRecord()
      model.save()

`export default RemovableController`
