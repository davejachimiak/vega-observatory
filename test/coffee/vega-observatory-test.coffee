describe 'VegaObserver', ->
  beforeEach ->
    @vegaObservatory = new VegaObservatory
    @vegaClient   = @vegaObserver.vegaClient

  describe '#call', ->
    it 'delegates to the vega client', ->
      call = sinon.collection.stub @vegaClient, 'call'

      @vegaObservatory.call()

      expect(call).to.have.been.called
