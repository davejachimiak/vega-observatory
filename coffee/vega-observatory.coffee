VegaClient            = require('vega-client')
PeerConnectionFactory = require('./private/peer-connection-factory')

class VegaObservatory
  constructor: (@options) ->
    @vegaClient = new VegaClient(@options.url, @options.roomId, @options.badge)
    @peerConnectionFactory = PeerConnectionFactory
    @callbacks = {}
    @peerStore = {}
    @_setClientCallbacks()

  call: ->
    @vegaClient.call()

  on: (event, callback) ->
    @callbacks[event] ||= []
    @callbacks[event].push(callback)

  trigger: (event) ->
    args = Array.prototype.slice.call(arguments, 1)

    if callbacks = @callbacks[event]
      callbacks.forEach (callback) ->
        callback.apply(this, args)

  _setClientCallbacks: ->
    @vegaClient.on 'callAccepted', (payload) =>
      @_handleCallAccepted(payload)

    @vegaClient.on 'offer', (payload) =>
      peerConnection = @_addPeerToStore payload
      @_setDescription(peerConnection, 'offer', payload)

    @vegaClient.on 'answer', (payload) =>
      peerConnection = @peerStore[payload.peerId].peerConnection
      @_setDescription(peerConnection, 'answer', payload)

  _handleCallAccepted: (peers) =>
    peers.forEach (peer) =>
      @_addPeerToStore(peer)

    @trigger 'callAccepted', peers

  _setDescription: (peerConnection, descriptionType, payload) ->
    sessionDescription = new RTCSessionDescription(payload[descriptionType])

    peerConnection.setRemoteDescription(sessionDescription)

    @trigger descriptionType, payload

  _handleOffer: (payload) =>
    peerConnection     = @_addPeerToStore payload
    sessionDescription = new RTCSessionDescription(payload.offer)

    peerConnection.setRemoteDescription(sessionDescription)

    @trigger 'offer', payload

  _handleAnswer: (payload) =>
    peerConnection = @peerStore[payload.peerId].peerConnection
    sessionDescription = new RTCSessionDescription(payload.answer)

    peerConnection.setRemoteDescription(sessionDescription)

    @trigger 'answer', payload

  _addPeerToStore: (peer) ->
    peerConnection = @peerConnectionFactory.create()

    @peerStore[peer.peerId] =
      badge: peer.badge
      peerConnection: peerConnection

    peerConnection

module.exports = VegaObservatory
