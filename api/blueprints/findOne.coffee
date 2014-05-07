###
Module dependencies
###
util = require("util")
actionUtil = require("../actionUtil")

###
Find One Record

get /:modelIdentity/:id

An API call to find and return a single model instance from the data adapter
using the specified id.

Required:
@param {Integer|String} id  - the unique id of the particular instance you'd like to look up *

Optional:
@param {String} callback - default jsonp callback param (i.e. the name of the js function returned)
###
module.exports = findOneRecord = (req, res) ->
  Model = actionUtil.parseModel(req)
  pk = actionUtil.requirePk(req)
  query = Model.findOne(pk)
  query = actionUtil.populateEach(query, req.options)
  query.exec found = (err, matchingRecord) ->
    return res.serverError(err)  if err
    return res.notFound("No record found with the specified `id`.")  unless matchingRecord
    if sails.hooks.pubsub and req.isSocket
      Model.subscribe req, matchingRecord
      actionUtil.subscribeDeep req, matchingRecord
    res.ok matchingRecord
    return

  return
