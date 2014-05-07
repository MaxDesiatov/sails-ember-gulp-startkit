`import EditableController from "appkit/controllers/editable"`

ConfigurationController = EditableController.extend
  actions:
    removeModel: ->
      model = @get 'model'
      model.get('project').then (project) ->
        project.get('configurations').then (configurations) ->
          configurations.removeObject model
          project.save()
      .then ->
        model.deleteRecord()
        model.save()

`export default ConfigurationController`
