# SynthStore

The `SynthStore` represents the primary container construct for managing various `Models`.

    #ModelRegistry = require './registry/model'

    class SynthStore extends (require './model')
      @set synth: 'store', models: [], controllers: []
      @mixin (require 'events').EventEmitter

      @schema
        models: @computed (-> (@constructor.get 'models') ), type: 'array', private: true

The below `register` for DataStore accepts one or more models and adds
to internal `ModelRegistry` instance.

      register: (models...) ->
        (@constructor.get 'registry').register model for model in models

PUBLIC access methods for working directly with PRIVATE _models registry

      create: (type, data) -> null
      find:   (type, query) -> @_models.find type, query
      update: (type, id, data) -> null
      delete: (type, query) -> model.destroy() for model in (@find type, query)

      contains: (key) ->
        prop = @access key
        prop if prop instanceof Model.Registry.Property

      infuse: (opts) ->
        console.log "using: #{opts?.source}"

    module.exports = SynthStore