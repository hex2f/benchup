const net = require('net')
const fs = require('fs')

const client = new net.Socket()

client.connect(20522, '127.0.0.1', function() {
    console.log('Connected')
    client.write('hello\n')
})

function execute() {
  let data = fs.readFileSync('suites/json_canada_decode/canada.json').toString('utf-8')
  let canada = JSON.parse(data)
  assert(canada.type == 'FeatureCollection')
  assert(canada.features[0].properties.name == 'Canada')
  assert(canada.features[0].geometry.coordinates.length == 480)
}

function assert(a) { if (!a) { throw new Error('assertion failed.') } }

client.on('data', function(data) {
    console.log(data.toString())
    if (data.toString() == 'warmup\n') {
        execute()
        client.write('start\n')
        execute()
        client.write('finish\n')
    }
})