###
Module dependencies
###
util = require("util")
actionUtil = require("../actionUtil")

###
Find Records

get   /:modelIdentity
/:modelIdentity/find

An API call to find and return model instances from the data adapter
using the specified criteria.  If an id was specified, just the instance
with that unique id will be returned.

Optional:
@param {Object} where       - the find criteria (passed directly to the ORM)
@param {Integer} limit      - the maximum number of records to send back (useful for pagination)
@param {Integer} skip       - the number of records to skip (useful for pagination)
@param {String} sort        - the order of returned records, e.g. `name ASC` or `age DESC`
@param {String} callback - default jsonp callback param (i.e. the name of the js function returned)
###
module.exports = findRecords = (req, res) ->
  # Look up the model
  Model = actionUtil.parseModel(req)

  # If an `id` param was specified, use the findOne blueprint action
  # to grab the particular instance with its primary key === the value
  # of the `id` param.   (mainly here for compatibility for 0.9, where
  # there was no separate `findOne` action)
  return require("./findOne")(req, res) if actionUtil.parsePk(req)

  # Lookup for records that match the specified criteria
  limit = actionUtil.parseLimit req
  skip = actionUtil.parseSkip req
  sort = actionUtil.parseSort req
  where = actionUtil.parseCriteria req
  query = Model.find().where(where).limit(limit)
    .skip(skip).sort(sort)

  # TODO: .populateEach(req.options);
  query = actionUtil.populateEach(query, req.options)
  query.exec found = (err, matchingRecords) ->
    return res.serverError(err) if err

    # Only `.watch()` for new instances of the model if
    # `autoWatch` is enabled.
    if req._sails.hooks.pubsub and req.isSocket
      Model.subscribe req, matchingRecords
      Model.watch req if req.options.autoWatch

      # Also subscribe to instances of all associated models
      _.each matchingRecords, (record) ->
        actionUtil.subscribeDeep req, record

    result =
      meta:
        limit: limit
        skip: skip
        sort: sort

    processRelationships = (s) ->
      (record) ->
        r = _.clone record.toObject()
        req.options.associations.forEach (a) ->
          name = a.alias
          relationship = record[a.alias]
          if relationship?
            if _.isArray relationship
              mapped = relationship.map (r) -> r.id
            else
              mapped = relationship.id
            r[a.alias] = mapped
            if s[name]
              if _.isArray relationship
                s[name] = s[name].concat relationship
              else
                s[name].push relationship
            else
              if _.isArray relationship
                s[name] = relationship
              else
                s[name] = [relationship]

        r

    sendRes = (c) ->
      result.meta.total = c
      sideload = {}
      result[req.options.model] =
        matchingRecords.map processRelationships(sideload)
      res.ok _.extend result, sideload

    if _.keys(where).length > 0
      sendRes matchingRecords.length
    else
      Model.count (err, count) ->
        return res.serverError(err) if err
        sendRes count
