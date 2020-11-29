const net = require('net')

const client = new net.Socket()

client.connect(20522, '127.0.0.1', function() {
    console.log('Connected')
    client.write('hello\n')
})

function execute() {
    let arr = []
    for (let i = 0; i < 10000000; i++) {
        arr.push(i)
    }
}

client.on('data', function(data) {
    console.log(data.toString())
    if (data.toString() == 'warmup\n') {
        execute()
        client.write('start\n')
        execute()
        client.write('finish\n')
    }
})