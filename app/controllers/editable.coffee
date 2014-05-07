`import RemovableController from "appkit/controllers/removable"`

EditableController = RemovableController.extend
  actions:
    startEdit: ->
      @set 'isEditing', true

    stopEdit: ->
      @set 'isEditing', false

    saveChanges: ->
      @get('model').save()
      @set 'isEditing', false

  isEditing: false

`export default EditableController`
