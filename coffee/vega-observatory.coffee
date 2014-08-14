VegaClient = require('vega-client')

class VegaObservatory
  constructor: (@options) ->
    @vegaClient = new VegaClient(@options.url, @options.roomId, @options.badge)

  call: ->
    @vegaClient.call()

module.exports = VegaObservatory
