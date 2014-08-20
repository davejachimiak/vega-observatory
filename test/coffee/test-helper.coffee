sinon     = require('sinon')
chai      = require('chai')
expect    = chai.expect
sinonChai = require('sinon-chai')

chai.use sinonChai

global.sinon  = sinon
global.expect = expect
