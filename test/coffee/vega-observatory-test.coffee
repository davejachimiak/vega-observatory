describe 'VegaObservatory', ->
  beforeEach ->
    class window.RTCSessionDescription
    class window.RTCIceCandidate

    @peerConnectionConfig = new Object
    @peerConnectionFactory = create: ->
    @sessionDescriptionCreator =
      forOffer: ->
      forAnswer: ->
    options =
      url: 'ws://0.0.0.0:3000'
      roomId: '/abc123'
      badge: {}
      peerConnectionConfig: @peerConnectionConfig
      peerConnectionFactory: @peerConnectionFactory
      sessionDescriptionCreator: @sessionDescriptionCreator
    @vegaObservatory = new VegaObservatory options
    @vegaClient = @vegaObservatory.vegaClient

  afterEach ->
    sinon.collection.restore()

  describe '#call', ->
    it 'delegates to the vega client', ->
      call = sinon.collection.stub @vegaClient, 'call'

      @vegaObservatory.call()

      expect(call).to.have.been.called

  describe '#sendOffer', ->
    it 'delegates to the vega client', ->
      theOffer = new Object
      peerId   = 'peerId'
      offer = sinon.collection.stub @vegaClient, 'offer'

      @vegaObservatory.sendOffer theOffer, peerId

      expect(offer).to.have.been.calledWith theOffer, peerId

  describe '#sendAnswer', ->
    it 'delegates to the vega client', ->
      theAnswer = new Object
      peerId    = 'peerId'
      answer = sinon.collection.stub @vegaClient, 'answer'

      @vegaObservatory.sendAnswer theAnswer, peerId

      expect(answer).to.have.been.calledWith theAnswer, peerId

  describe '#hangUp', ->
    it 'sends a hangUp message to the vega client', ->
      hangUp = sinon.collection.stub @vegaClient, 'hangUp'

      @vegaObservatory.hangUp()

      expect(hangUp).to.have.been.called

  describe '#sendCandidate', ->
    it 'delegates to the vega client', ->
      theCandidate = new Object
      peerId       = 'peerId'
      candidate    = sinon.collection.stub @vegaClient, 'candidate'

      @vegaObservatory.sendCandidate theCandidate, peerId

      expect(candidate).to.have.been.calledWith theCandidate, peerId

  describe '#createOffer', ->
    it 'creates an offer on the peer connection with success and failure callbacks', ->
      @peerId = 'peerId'
      @peerConnection = new Object
      @vegaObservatory.peerStore =
        'peerId':
          badge: { name: 'Dave' }
          peerConnection: @peerConnection
      forOffer = sinon.collection.stub @sessionDescriptionCreator, 'forOffer'

      @vegaObservatory.createOffer(@peerId)

      expect(forOffer).to.have.been.calledWith @vegaObservatory, @peerId, @peerConnection

  describe '#createAnswer', ->
    it 'creates a session description for an answer', ->
      @peerId = 'peerId'
      @peerConnection = new Object
      @vegaObservatory.peerStore =
        'peerId':
          badge: { name: 'Dave' }
          peerConnection: @peerConnection
      forAnswer = sinon.collection.stub @sessionDescriptionCreator, 'forAnswer'

      @vegaObservatory.createAnswer(@peerId)

      expect(forAnswer).to.have.been.calledWith @vegaObservatory, @peerId, @peerConnection

  describe 'vega client callbacks', ->
    beforeEach ->
      @peerConnection = setRemoteDescription: ->
      @createPeerConnection = sinon.collection.stub(@peerConnectionFactory, 'create')

    describe 'on callAccepted', ->
      beforeEach ->
        @peer1 = { peerId: 'peerId1', badge: { name: 'Dave' } }
        @peer2 = { peerId: 'peerId2', badge: { name: 'Allie' } }
        @peers = [@peer1, @peer2]

        @peers.forEach (peer) =>
          @createPeerConnection.withArgs(
            @vegaObservatory,
            peer,
            @peerConnectionConfig
          ).returns @peerConnection

      it 'saves references to all peers in the response', ->
        @vegaClient.trigger('callAccepted', @peers)

        expect(@vegaObservatory.peerStore).to.eql
          "peerId1":
            badge: @peer1.badge
            peerConnection: @peerConnection
          "peerId2":
            badge: @peer2.badge
            peerConnection: @peerConnection

      it 'triggers a callAccepted event on the observatory', ->
        object = {}

        @vegaObservatory.on 'callAccepted', (payload) ->
          object.peers = payload

        @vegaClient.trigger('callAccepted', @peers)

        expect(object.peers).to.eq @peers

    describe 'on offer', ->
      beforeEach ->
        @badge = { name: 'Dave' }
        peer =
          peerId: 'peerId'
          badge: @badge
        @payload = peer
        offer = { 'offer key': 'offer value' }
        @payload.offer = offer

        @createPeerConnection.withArgs(
          @vegaObservatory,
          peer,
          @peerConnectionConfig
        ).returns @peerConnection

        @setRemoteDescription =
          sinon.collection.stub @peerConnection, 'setRemoteDescription'

        @rtcSessionDescription = sinon.createStubInstance(window.RTCSessionDescription)

      it 'saves a reference to the peer', ->
        @vegaClient.trigger 'offer', @payload

        expect(@vegaObservatory.peerStore).to.eql
          "peerId":
            badge: @badge
            peerConnection: @peerConnection

      it 'sets the offer on the peer connection via session description', ->
        @vegaClient.trigger 'offer', @payload

        expect(@setRemoteDescription).to.have.been.calledWith @rtcSessionDescription

      it 'triggers an offer event', ->
        object = {}

        @vegaObservatory.on 'offer', (payload) ->
          object.payload = payload

        @vegaClient.trigger('offer', @payload)

        expect(object.payload).to.eq @payload

    describe 'on answer', ->
      beforeEach ->
        @peerId = 'peerId'
        @peerConnection = setRemoteDescription: ->
        @badge = { name: 'Dave' }
        @vegaObservatory.peerStore =
          'peerId':
            badge: @badge
            peerConnection: @peerConnection

        @payload =
          answer: { an: 'answer' }
          peerId: @peerId

        @setRemoteDescription =
          sinon.collection.stub @peerConnection, 'setRemoteDescription'

        @rtcSessionDescription = sinon.createStubInstance(window.RTCSessionDescription)

      it 'sets the answer on the peer connection via session description', ->
        @vegaClient.trigger('answer', @payload)

        expect(@setRemoteDescription).to.have.been.calledWith @rtcSessionDescription

      it 'triggers an answer event', ->
        object = {}

        @vegaObservatory.on 'answer', (payload) ->
          object.payload = payload

        @vegaClient.trigger('answer', @payload)

        expect(object.payload).to.eq @payload

    describe 'on candidate', ->
      beforeEach ->
        @peerConnection = addIceCandidate: ->
        @badge = { name: 'Dave' }
        @peerId = 'peerId'
        @vegaObservatory.peerStore =
          'peerId':
            badge: @badge
            peerConnection: @peerConnection

        @payload =
          candidate: { an: 'candidate' }
          peerId: @peerId

        @addIceCandidate =
          sinon.collection.stub @peerConnection, 'addIceCandidate'

        @rtcIceCandidate = sinon.createStubInstance(window.RTCIceCandidate)

      it 'adds the ice candidate to the proper peer connection', ->
        @vegaClient.trigger 'candidate', @payload

        expect(@addIceCandidate).to.have.been.calledWith @rtcIceCandidate

      it 'triggers a candidate event with the payload', ->
        object = {}

        @vegaObservatory.on 'candidate', (payload) ->
          object.payload = payload

        @vegaClient.trigger 'candidate', @payload

        expect(object.payload).to.eq @payload

    describe 'on peerHangUp', ->
      beforeEach ->
        @badge = { name: 'Dave' }
        @peerId = 'peerId'
        @vegaObservatory.peerStore =
          'peerId':
            badge: @badge
            peerConnection: @peerConnection

        @payload =
          peerId: @peerId

      it 'triggers a peerHangUp event', ->
        object = {}

        @vegaObservatory.on 'peerHangUp', (payload) ->
          object.payload = payload

        @vegaClient.trigger 'peerHangUp', @payload

        expect(object.payload).to.eq @payload

      it 'removes the peer from the peer store', ->
        @vegaClient.trigger 'peerHangUp', @payload

        expect(@vegaObservatory.peerStore).to.eql {}
