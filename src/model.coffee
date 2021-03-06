uuid = require 'node-uuid'

class SynthModel extends (require './object')
  @set synth: 'model', name: undefined, records: undefined

  @instanceof = (x) ->
    return false unless x?
    x instanceof this or x instanceof this.__super__?.constructor

  @modelof = (x) ->
    return false unless x instanceof Object
    for k of x
      return false unless (@get "bindings.#{k}")?
    return true

  @mixin (require 'events').EventEmitter

  @belongsTo = (model, opts) ->
    class extends (require './property/belongsTo')
      @set model: model
      @merge opts

  @hasMany = (model, opts) ->
    class extends (require './property/hasMany')
      @set model: model
      @merge opts

  constructor: ->
    # register a default 'save' and 'destroy' handler event (can be overridden)
    @attach 'save',    (resolve, reject) -> return resolve this
    @attach 'destroy', (resolve, reject) -> return resolve this
    super
    @name = @meta 'name'
    unless @name?
      throw new Error "Model must have a 'name' metadata specified for construction"
    @store = @parent # every model should have a parent that is it's datastore
    @id = (@get 'id') ? @uuid() # every model instance has a unique ID

  uuid: -> uuid.v4()

  fetch: (key) -> @meta "records.#{key}"

  find:  (query) -> (v for k, v of (@meta 'records')).where query
  match: (query) ->
    for k, v of query
      x = (@access k)?.normalize (@get k)
      x = "#{x}" if typeof x is 'boolean' and typeof v is 'string'
      return false unless x is v
    return true

  toString: -> "#{@meta 'name'}:#{@id}"

  save: ->
    @emit 'saving'
    @invoke 'save', arguments...
    .then (res) =>
      @id = (@get 'id') ? @id
      @set 'id', @id
      super
      @constructor.set "records.#{@id}", this
      @emit 'saved'
      return res

  rollback: ->
    # TBD
    super

  destroy: ->
    @emit 'destroying'
    @invoke 'destroy', arguments...
    .then (res) =>
      #record.destroy() for record in @get '_bindings'
      @constructor.delete "records.#{@id}"
      @emit 'destroyed'
      return res

  RelationshipProperty = (require './property/relationship')

  getRelationships: (kind) ->
    @everyProperty (key) -> this if this instanceof RelationshipProperty
    .filter (x) -> x? and (not kind? or kind is (x.constructor.get 'kind'))

module.exports = SynthModel
