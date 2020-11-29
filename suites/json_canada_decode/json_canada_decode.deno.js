const encoder = new TextEncoder()
const decoder = new TextDecoder()

const client = await Deno.connect({ hostname: '127.0.0.1', port: 20522 })
console.log('Connected')
await client.write(encoder.encode('hello\n'))

async function execute() {
    let data = await Deno.readTextFile('./suites/json_canada_decode/canada.json')
    let canada = JSON.parse(data)
    assert(canada.type == 'FeatureCollection')
    assert(canada.features[0].properties.name == 'Canada')
    assert(canada.features[0].geometry.coordinates.length == 480)
}
  
function assert(a) { if (!a) { throw new Error('assertion failed.') } }  

while (true) {
    const buf = new Uint8Array(16)
    await client.read(buf)
    const data = decoder.decode(buf)
    if (data.startsWith('warmup\n')) {
        await execute()
        await client.write(encoder.encode('start\n'))
        await execute()
        await client.write(encoder.encode('finish\n'))
        process.exit()
    } else if (data[0] == '\x00') {
       process.exit()
    }
}