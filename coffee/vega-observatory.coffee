VegaClient = require('vega-client')
PeerConnectionFactory = require('./private/peer-connection-factory')
SessionDescriptionCreator = require('./private/session-description-creator')
WebRTCInterop = require('../webrtc-interop/webrtc-interop.js')

class VegaObservatory
  constructor: (@options) ->
    @vegaClient = new VegaClient(@options.url, @options.roomId, @options.badge)
    @peerConnectionFactory =
      @options.peerConnectionFactory || PeerConnectionFactory
    @sessionDescriptionCreator =
      @options.sessionDescriptionCreator || SessionDescriptionCreator
    @webRTCInterop = @options.webRTCInterop || WebRTCInterop
    @callbacks = {}
    @peerStore = {}

    @webRTCInterop.infectGlobal()
    @_setClientCallbacks()

  call: ->
    @vegaClient.call()

  sendOffer: (offer, peerId) ->
    @vegaClient.offer(offer, peerId)

  sendAnswer: (answer, peerId) ->
    @vegaClient.answer(answer, peerId)

  sendCandidate: (candidate, peerId) ->
    @vegaClient.candidate(candidate, peerId)

  hangUp: ->
    @vegaClient.hangUp()

  createOffer: (peerId) ->
    peerConnection = @_peerConnection(peerId)

    @sessionDescriptionCreator.forOffer(
      this, peerId, peerConnection
    )

  createAnswer: (peerId) ->
    peerConnection = @_peerConnection(peerId)

    @sessionDescriptionCreator.forAnswer(
      this, peerId, peerConnection
    )

  _setClientCallbacks: ->
    @vegaClient.on 'callAccepted', (payload) =>
      @_handleCallAccepted payload

    @vegaClient.on 'offer', (payload) =>
      @_handleOffer payload

    @vegaClient.on 'answer', (payload) =>
      @_handleAnswer payload

    @vegaClient.on 'candidate', (payload) =>
      @_handleCandidate payload

    @vegaClient.on 'peerHangUp', (payload) =>
      @_handlePeerHangUp payload

  _handleCallAccepted: (peers) ->
    peers.forEach (peer) =>
      @_addPeerToStore peer

    @trigger 'callAccepted', peers

  _handleOffer: (payload) ->
    peer       = new Object(payload)
    peer.offer = null
    peerConnection = @_addPeerToStore peer
    @_handleSessionDescription(peerConnection, 'offer', payload)

  _handleAnswer: (payload) ->
    peerConnection = @_peerConnection(payload.peerId)
    @_handleSessionDescription(peerConnection, 'answer', payload)

  _handleSessionDescription: (peerConnection, descriptionType, payload) ->
    sessionDescription = new RTCSessionDescription(payload[descriptionType])

    peerConnection.setRemoteDescription(sessionDescription)

    @trigger descriptionType, payload

  _handleCandidate: (payload) ->
    peerConnection = @_peerConnection(payload.peerId)
    iceCandidate   = new RTCIceCandidate(payload.candidate)

    peerConnection.addIceCandidate(iceCandidate)

    @trigger 'candidate', payload

  _handlePeerHangUp: (payload) ->
    @trigger 'peerHangUp', payload
    delete @peerStore[payload.peerId]

  _addPeerToStore: (peer) ->
    peerConnection = @peerConnectionFactory.create(
      this,
      peer,
      @options.peerConnectionConfig
    )

    @peerStore[peer.peerId] =
      badge: peer.badge
      peerConnection: peerConnection

    peerConnection

  _peerConnection: (peerId) ->
    @peerStore[peerId].peerConnection

  on: (event, callback) ->
    @callbacks[event] ||= []
    @callbacks[event].push(callback)

  trigger: (event) ->
    args = Array.prototype.slice.call(arguments, 1)

    if callbacks = @callbacks[event]
      callbacks.forEach (callback) ->
        callback.apply(this, args)

module.exports = VegaObservatory
