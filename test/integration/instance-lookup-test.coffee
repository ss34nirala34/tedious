fs = require('fs')
InstanceLookup = require('../../src/instance-lookup').InstanceLookup

RESERVED_IP_ADDRESS = '192.0.2.0'     # Can never be used, so guaranteed to fail.

getConfig = ->
  server: JSON.parse(fs.readFileSync(process.env.HOME + '/.tedious/test-connection.json', 'utf8')).config.server
  instanceName: JSON.parse(fs.readFileSync(process.env.HOME + '/.tedious/test-connection.json', 'utf8')).instanceName

exports.goodInstance = (test) ->
  config = getConfig()

  if !config.instanceName
    # Config says don't do this test (probably because SQL Server Browser is not available).
    console.log('Skipping goodInstance test')
    test.done()
    return

  callback = (err, port) ->
    test.ifError(err)
    test.ok(port)

    test.done()

  new InstanceLookup().instanceLookup({ server: config.server, instanceName: config.instanceName }, callback)

exports.badInstance = (test) ->
  config = getConfig()

  callback = (err, port) ->
    test.ok(err)
    test.ok(!port)

    test.done()

  new InstanceLookup().instanceLookup({ server: config.server, instanceName: 'badInstanceName', timeout: 100, retries: 1 }, callback)

exports.badServer = (test) ->
  config = getConfig()

  callback = (err, port) ->
    test.ok(err)
    test.ok(!port)

    test.done()

  new InstanceLookup().instanceLookup({ server: RESERVED_IP_ADDRESS, instanceName: 'badInstanceName', timeout: 100, retries: 1 }, callback)