Promise = require 'promise'

class SynthAction extends (require './object')
  @set synth: 'action'

  @schema
    input:  class extends (require './meta')
    output: class extends (require './meta')

  invoke: (origin, event=(@meta 'name'), parent=@parent) ->
    listeners = parent.listeners event
    console.log "invoking '#{event}' for handling by #{listeners.length} listeners"
    action = this
    promises =
      for listener in listeners
        do (listener) ->
          new Promise (resolve, reject) ->
            listener.apply parent, [
              (action.access 'input')
              (action.access 'output')
              (err) -> if err? then reject err else resolve action
              origin
            ]
    unless promises.length > 0
      promises.push Promise.reject "missing listeners for '#{event}' event"

    return Promise.all promises
      .then (res) ->
        for action in res
          console.log "got back #{action} from listener"
        return res

  trigger: (origin, event=(@meta 'name')) ->
    console.log "emit '#{event}' for handling by listeners"
    @parent.emit event, (@access 'input'), (@access 'output'), (err) -> 

module.exports = SynthAction
