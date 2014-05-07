###
Module dependencies
###

# Parameter used for jsonp callback is constant, as far as
# blueprints are concerned (for now.)

###
Utility methods used in built-in blueprint actions.

@type {Object}
###

###
Given a Waterline query, populate the appropriate/specified
association attributes and return it so it can be chained
further ( i.e. so you can .exec() it )

@param  {Query} query         [waterline query object]
@param  {Object} options
@return {Query}
###

# Only populate associations if `populate` is set
#
# Additionally, allow an object to be specified, where the key is the name
# of the association attribute, and value is true/false (true to populate,
# false to not)

###
Subscribe deep (associations)

@param  {[type]} associations [description]
@param  {[type]} record       [description]
@return {[type]}              [description]
###

# Look up identity of associated model

# Subscribe to each associated model instance

###
Parse primary key value for use in a Waterline criteria
(e.g. for `find`, `update`, or `destroy`)

@param  {Request} req
@return {Integer|String}
###

# TODO: make this smarter...
# (e.g. look for actual primary key of model and look for it
#  in the absence of `id`.)
# See coercePK for reference (although be aware it is not currently in use)

###
Parse primary key value from parameters.
Throw an error if it cannot be retrieved.

@param  {Request} req
@return {Integer|String}
###

# Validate the required `id` parameter

###
Parse `criteria` for a Waterline `find` or `update` from all
request parameters.

@param  {Request} req
@return {Object}            the WHERE criteria object
###

# Allow customizable blacklist for params NOT to include as criteria.

# Validate blacklist to provide a more helpful error msg.

# Look for explicitly specified `where` parameter.

# If `where` parameter is a string, try to interpret it as JSON

# If `where` has not been specified, but other unbound parameter variables
# **ARE** specified, build the `where` option using them.

# Prune params which aren't fit to be used as `where` criteria
# to build a proper where query

# Omit built-in runtime config (like query modifiers)

# Omit any params w/ undefined values

# Omit jsonp callback param (but only if jsonp is enabled)

# Merge w/ req.options.where and return

###
Parse `values` for a Waterline `create` or `update` from all
request parameters.

@param  {Request} req
@return {Object}
###

# Allow customizable blacklist for params NOT to include as values.

# Validate blacklist to provide a more helpful error msg.

# Prune params which aren't fit to be used as `values`

# Omit built-in runtime config (like query modifiers)

# Omit any params w/ undefined values

# Omit jsonp callback param (but only if jsonp is enabled)

###
Determine the model class to use w/ this blueprint action.
@param  {Request} req
@return {WLCollection}
###

# Ensure a model can be deduced from the request options.

###
@param  {Request} req
###

###
@param  {Request} req
###

###
@param  {Request} req
###

# TODO:
#
# Replace the following helper with the version in sails.util:

# Attempt to parse JSON
# If the parse fails, return the error object
# If JSON is falsey, return null
# (this is so that it will be ignored if not specified)
tryToParseJSON = (json) ->
  return null  unless _.isString(json)
  try
    return JSON.parse(json)
  catch e
    return e
  return
_ = require("lodash")
util = require("util")
JSONP_CALLBACK_PARAM = "callback"
module.exports =
  populateEach: (query, options) ->
    _(options.associations).reduce (populateEachAssociation = (query, association) ->
      if options.populate
        query.populate association.alias

      else
        query
    ), query

  subscribeDeep: (req, record) ->
    _.each req.options.associations, (assoc) ->
      ident = assoc[assoc.type]
      AssociatedModel = sails.models[ident]
      AssociatedModel.watch req  if req.options.autoWatch
      if assoc.type is "collection"
        _.each record[assoc.alias], (associatedInstance) ->
          AssociatedModel.subscribe req, associatedInstance
          return

      else AssociatedModel.subscribe req, record[assoc.alias]  if assoc.type is "model"
      return

    return

  parsePk: (req) ->
    req.param "id"

  requirePk: (req) ->
    pk = module.exports.parsePk(req)
    unless pk
      err = new Error("No `id` parameter provided." + "(Note: even if the model's primary key is not named `id`- " + "`id` should be used as the name of the parameter- it will be " + "mapped to the proper primary key name)")
      err.status = 400
      throw err
    pk

  parseCriteria: (req) ->
    req.options.criteria = req.options.criteria or {}
    req.options.criteria.blacklist = req.options.criteria.blacklist or [
      "limit"
      "skip"
      "sort"
    ]
    blacklist = req.options.criteria and req.options.criteria.blacklist
    throw new Error("Invalid `req.options.criteria.blacklist`. Should be an array of strings (parameter names.)")  if blacklist and not _.isArray(blacklist)
    where = req.params.all().where
    where = tryToParseJSON(where)  if _.isString(where)
    unless where
      where = req.params.all()
      where = _.omit(where, blacklist or [
        "limit"
        "skip"
        "sort"
      ])
      where = _.omit(where, (p) ->
        true  if _.isUndefined(p)
      )
      jsonpOpts = req.options.jsonp and not req.isSocket
      jsonpOpts = (if _.isObject(jsonpOpts) then jsonpOpts else callback: JSONP_CALLBACK_PARAM)
      where = _.omit(where, [jsonpOpts.callback])  if jsonpOpts
    where = _.merge({}, req.options.where or {}, where) or `undefined`
    where

  parseValues: (req) ->
    req.options.values = req.options.values or {}
    req.options.values.blacklist = req.options.values.blacklist
    blacklist = req.options.values.blacklist
    throw new Error("Invalid `req.options.values.blacklist`. Should be an array of strings (parameter names.)")  if blacklist and not _.isArray(blacklist)
    values = req.params.all()
    values = _.omit(values, blacklist or [])
    values = _.omit(values, (p) ->
      true  if _.isUndefined(p)
    )
    jsonpOpts = req.options.jsonp and not req.isSocket
    jsonpOpts = (if _.isObject(jsonpOpts) then jsonpOpts else callback: JSONP_CALLBACK_PARAM)
    values = _.omit(values, [jsonpOpts.callback])  if jsonpOpts
    values

  parseModel: (req) ->
    model = req.options.model or req.options.controller
    throw new Error(util.format("No \"model\" specified in route options."))  unless model
    Model = req._sails.models[model]
    throw new Error(util.format("Invalid route option, \"model\".\nI don't know about any models named: `%s`", model))  unless Model
    Model

  parseSort: (req) ->
    req.param("sort") or req.options.sort or `undefined`

  parseLimit: (req) ->
    DEFAULT_LIMIT = 30
    limit = req.param("limit") or ((if typeof req.options.limit isnt "undefined" then req.options.limit else DEFAULT_LIMIT))
    limit = +limit  if limit
    limit

  parseSkip: (req) ->
    DEFAULT_SKIP = 0
    skip = req.param("skip") or ((if typeof req.options.skip isnt "undefined" then req.options.skip else DEFAULT_SKIP))
    skip = +skip  if skip
    skip
