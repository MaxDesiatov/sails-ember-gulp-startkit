`import EditableController from "appkit/controllers/removable"`

JobController = EditableController.extend
  progressWidth:
    Em.computed ->
      c = @get 'content.currentProgress'
      t = @get 'content.totalProgress'
      w = c/t * 100
      if not ((w > 0) and (w <= 100))
        w = 0
      "width: #{w}%;"
    .property 'currentProgress', 'totalProgress'

`export default JobController`
