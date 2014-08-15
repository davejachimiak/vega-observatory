VegaClient         = require('vega-client')
PeerConnectionUtil = require('./private/peer-connection-util')

class VegaObservatory
  constructor: (@options) ->
    @vegaClient = new VegaClient(@options.url, @options.roomId, @options.badge)
    @peerConnectionUtil = PeerConnectionUtil
    @callbacks = {}
    @peerStore = {}
    @_setClientCallbacks()

  call: ->
    @vegaClient.call()

  createOffer: (peerId) ->
    peerConnection = @peerStore[peerId].peerConnection

    [successCallback, errorCallback] =
      @peerConnectionUtil.descriptionCallbacks(@vegaClient, peerId, peerConnection, 'offer')

    peerConnection.createOffer(successCallback, errorCallback)

  createAnswer: (peerId) ->
    peerConnection = @peerStore[peerId].peerConnection

    [successCallback, errorCallback] =
      @peerConnectionUtil.descriptionCallbacks(@vegaClient, peerId, peerConnection, 'answer')

    peerConnection.createAnswer(successCallback, errorCallback)

  _setClientCallbacks: ->
    @vegaClient.on 'callAccepted', (payload) =>
      @_handleCallAccepted(payload)

    @vegaClient.on 'offer', (payload) =>
      peerConnection = @_addPeerToStore payload
      @_handleSessionDescription(peerConnection, 'offer', payload)

    @vegaClient.on 'answer', (payload) =>
      peerConnection = @peerStore[payload.peerId].peerConnection
      @_handleSessionDescription(peerConnection, 'answer', payload)

    @vegaClient.on 'candidate', (payload) =>
      @_handleCandidate(payload)

    @vegaClient.on 'peerHangUp', (payload) =>
      @_handlePeerHangUp(payload)

  _handleCallAccepted: (peers) ->
    peers.forEach (peer) =>
      @_addPeerToStore(peer)

    @trigger 'callAccepted', peers

  _handleSessionDescription: (peerConnection, descriptionType, payload) ->
    sessionDescription = new RTCSessionDescription(payload[descriptionType])

    peerConnection.setRemoteDescription(sessionDescription)

    @trigger descriptionType, payload

  _handleCandidate: (payload) ->
    peerConnection = @peerStore[payload.peerId].peerConnection
    iceCandidate   = new RTCIceCandidate(payload.candidate)

    peerConnection.addIceCandidate(iceCandidate)

    @trigger 'candidate', payload

  _handlePeerHangUp: (payload) ->
    @trigger 'peerHangUp', payload
    delete @peerStore[payload.peerId]

  _addPeerToStore: (peer) ->
    peerConnection = @peerConnectionUtil.createPeerConnection()

    @peerStore[peer.peerId] =
      badge: peer.badge
      peerConnection: peerConnection

    peerConnection

  on: (event, callback) ->
    @callbacks[event] ||= []
    @callbacks[event].push(callback)

  trigger: (event) ->
    args = Array.prototype.slice.call(arguments, 1)

    if callbacks = @callbacks[event]
      callbacks.forEach (callback) ->
        callback.apply(this, args)

module.exports = VegaObservatory
