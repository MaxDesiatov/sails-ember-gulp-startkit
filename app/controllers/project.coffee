`import EditableController from "appkit/controllers/editable"`

ProjectController = EditableController.extend
  actions:
    expand: ->
      @set 'isExpanded', true

    collapse: ->
      @set 'isExpanded', false

    createConfiguration: ->
      project = @get 'model'
      conf = @store.createRecord 'configuration',
        name: 'testConf'
        project: project

      conf.save().then ->
        project.get('configurations')
      .then (configurations) ->
        configurations.pushObject conf
        project.save()

  isExpanded: false

`export default ProjectController`
