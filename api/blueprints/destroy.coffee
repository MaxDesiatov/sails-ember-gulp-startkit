###
Module dependencies
###
util = require("util")
actionUtil = require("../actionUtil")

###
Destroy One Record

delete  /:modelIdentity/:id
/:modelIdentity/destroy/:id

Destroys the single model instance with the specified `id` from
the data adapter for the given model if it exists.

Required:
@param {Integer|String} id  - the unique id of the particular instance you'd like to delete

Optional:
@param {String} callback - default jsonp callback param (i.e. the name of the js function returned)
###
module.exports = destroyOneRecord = (req, res) ->
  Model = actionUtil.parseModel(req)
  pk = actionUtil.requirePk(req)
  query = Model.findOne(pk)
  query = actionUtil.populateEach(query, req.options)
  query.exec foundRecord = (err, record) ->
    return res.serverError(err)  if err
    return res.notFound("No record found with the specified `id`.")  unless record
    Model.destroy(pk).exec destroyedRecord = (err) ->
      return res.negotiate(err)  if err
      if sails.hooks.pubsub
        Model.publishDestroy pk, not sails.config.blueprints.mirror and req,
          previous: record

        if req.isSocket
          Model.unsubscribe req, record
          Model.retire record
      res.send {}, 204
