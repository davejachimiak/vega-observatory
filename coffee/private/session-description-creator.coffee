class SessionDescriptionCreator
  @forOffer: (observatory, peerId, peerConnection) ->
    creator = new SessionDescriptionCreator(observatory, peerId, peerConnection)
    creator.forOffer()

  @forAnswer: (observatory, peerId, peerConnection) ->
    creator = new SessionDescriptionCreator(observatory, peerId, peerConnection)
    creator.forAnswer()

  constructor: (@observatory, @peerId, @peerConnection) ->

  forOffer: ->
    @peerConnection.createOffer @successCallback(@sendOffer), @failureCallback

  forAnswer: (observatory, peerId, peerConnection) ->
    @peerConnection.createAnswer @successCallback(@sendAnswer), @failureCallback

  successCallback: (onLocalDescriptionSuccess) ->
    (description) =>
      @peerConnection.setLocalDescription(
        description,
        onLocalDescriptionSuccess,
        @failureCallback
      )

  failureCallback: (error) ->
    console.error error

  sendOffer: =>
    @observatory.sendOffer(@peerConnection.localDescription, @peerId)

  sendAnswer: =>
    @observatory.sendAnswer(@peerConnection.localDescription, @peerId)

module.exports = SessionDescriptionCreator
