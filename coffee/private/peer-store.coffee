class PeerStore
  peers: []
  callbacks: {}

  add: (peer) ->
    @peers.push peer
    @trigger 'add', peer

  on: (event, callback) ->
    @callbacks[event] ||= []
    @callbacks[event].push callback

  trigger: (event) ->
    args = Array.prototype.slice.call(arguments, 1)

    if callbacks = @callbacks[event]
      callbacks.forEach (callback) ->
        callback.apply(this, args)

module.exports = PeerStore
