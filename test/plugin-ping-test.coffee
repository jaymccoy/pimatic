assert = require "cassert"

describe "pimatic-ping", ->

    # Setup the environment
  env =
    logger: require '../lib/logger'
    helper: require '../lib/helper'
    actuators: require '../lib/actuators'
    sensors: require '../lib/sensors'
    rules: require '../lib/rules'
    plugins: require '../lib/plugins'

  backend = (require 'pimatic-ping') env
  PingPresents = backend.PingPresents
  sessionDummy = null
  sensor = null

  beforeEach ->
    sessionDummy = 
      pingHost: (host, callback) ->
    config =
      id: 'test'
      name: 'test device'
      host: 'localhost'
      delay: 200
    sensor = new PingPresents(config, sessionDummy)

  describe '#parsePredicate()', ->

    it 'should parse "test is present"', ->
      info = sensor.parsePredicate "test is present"
      assert info?
      assert info.deviceId is "test"
      assert info.present is yes

    it 'should parse "test device is present"', ->
      info = sensor.parsePredicate "test device is present"
      assert info?
      assert info.deviceId is "test"
      assert info.present is yes

    it 'should parse "test is not present"', ->
      info = sensor.parsePredicate "test is not present"
      assert info?
      assert info.deviceId is "test"
      assert info.present is no

    it 'should return null if id is wrong', ->
      info = sensor.parsePredicate "foo is present"
      assert(not info?)

  describe '#notifyWhen()', ->

    it "should notify when device is present", (done) ->
      sessionDummy.pingHost = (host, callback) ->
        assert host is "localhost"
        setTimeout ->
          callback null, host
        ,22

      success = sensor.notifyWhen "test-id", "test is present", done
      assert success

    it "should notify when device is not present", (done) ->
      sessionDummy.pingHost = (host, callback) ->
        assert host is "localhost"
        setTimeout ->
          callback new Error('foo'), host
        ,22

      success = sensor.notifyWhen "test-id", "test is not present", done
      assert success
