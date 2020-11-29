const encoder = new TextEncoder()
const decoder = new TextDecoder()

const client = await Deno.connect({ hostname: "127.0.0.1", port: 20522 })
console.log('Connected')
await client.write(encoder.encode('hello\n'))

function execute() {
    let arr = []
    for (let i = 0; i < 10000000; i++) {
        arr.push(i)
    }
}

let finished = false

while (!finished) {
    const buf = new Uint8Array(16)
    await client.read(buf)
    const data = decoder.decode(buf)
    if (data.startsWith('warmup\n')) {
        execute()
        await client.write(encoder.encode('start\n'))
        execute()
        await client.write(encoder.encode('finish\n'))
        finished = true
    } else if (data[0] == '\x00') {
       finished = true
    }
}
