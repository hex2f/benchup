const net = require('net')

const client = new net.Socket()

client.connect(20522, '127.0.0.1', function() {
    console.log('Connected')
})

function execute() {
    let arr = []
    for (let i = 0; i < 1000000; i++) {
        arr.push(i)
    }
}

client.on('data', function(data) {
    console.log(data.toString())
    if (data.toString() == 'warmup') {
        execute()
        client.write('js start')
        execute()
        client.write('js finish')
    }
})