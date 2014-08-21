require('../test-helper')

PeerStore = require('../../private/peer-store')

describe 'PeerStore', ->
  beforeEach ->
    @peerStore = new PeerStore

  afterEach ->
    delete @thePeer
    @peerStore.peers = []

  describe '#add', ->
    beforeEach ->
      @peer = new Object

    it 'adds a peer to the stores', ->
      @peerStore.add(@peer)

      expect(@peerStore.peers).to.eql [@peer]

    it 'triggers an add event', ->
      @peerStore.on 'add', (peer) =>
        @thePeer = peer

      @peerStore.add(@peer)

      expect(@thePeer).to.eq @peer

  describe '#remove', ->
    beforeEach ->
      @peerId = 'peerId'
      @peer = { peerId: @peerId }
      @peerStore.peers = [@peer]

    it 'removes the peer with the peerId from the peers', ->
      @peerStore.remove(@peerId)

      expect(@peerStore.peers).to.be.empty

    it 'triggers a remove event', ->
      @peerStore.on 'remove', (peer) =>
        @thePeer = peer

      @peerStore.remove(@peerId)

      expect(@thePeer).to.eq @peer

  describe '#addStream', ->
    beforeEach ->
      @peerId = 'peerId'
      @peer = { peerId: @peerId }
      @peerStore.peers = [@peer]
      @stream = new Object

    it 'attaches the stream to the peer of the id', ->
      @peerStore.addStream(@peerId, @stream)

      expect(@peer.stream).to.eq @stream

      @peerStore.peers = []

    it 'triggers a streamAdded event', ->
      @peerStore.on 'streamAdded', (peer) =>
        @thePeer = peer
      peer = new Object @peer
      peer.stream = @stream

      @peerStore.addStream(@peerId, @stream)

      expect(@thePeer).to.eql peer

  describe 'queries', ->
    beforeEach ->
      @peerWithStreamId = '1'
      @peerWithoutStreamId = '2'
      @peerWithStream = { peerId: @peerWithStreamId, stream: new Object }
      @peerWithoutStream = { peerId: @peerWithoutStreamId }
      @peerStore.peers = [@peerWithStream, @peerWithoutStream]

    describe '#peersWithStreams', ->
      it 'returns peers that have streams', ->
        expect(@peerStore.peersWithStreams()).to.eql [@peerWithStream]

    describe '#peersWithoutStreams', ->
      it 'returns peers that do not have streams', ->
        expect(@peerStore.peersWithoutStreams()).to.eql [@peerWithoutStream]

    describe '#find', ->
      it 'returns the peer of the peer id', ->
        expect(@peerStore.find(@peerWithStreamId)).to.eq @peerWithStream
        expect(@peerStore.find(@peerWithoutStreamId)).to.eq @peerWithoutStream
