module main

import net
import time
import x.json2

struct Person {
	name string
	age  int
}

pub fn (p Person) to_json() string {
    mut obj := map[string]json2.Any
    obj['name'] = p.name
    obj['age'] = p.age
    return obj.str()
}

fn execute() {
	mut people := []string{}
	for i in 0..1000000 {
		mut me := Person {
			name: 'Bob',
			age: i%100
		}

		encoded := json2.encode<Person>(me)
		people << encoded
	}
}

fn main () {
	server_port := 20522
	for {
	println('Connecting to port: $server_port')
	con := net.dial('127.0.0.1', server_port) or {
		println('Connection failed')
		time.sleep(1)
		continue
	}
	println('Connected')
	for {
		line := con.read_line()
		if line.len == 0 { exit(0) }
		println('read: $line')
		match line.split('\r')[0] {
			"warmup" {
				execute()
				con.send_string("v start") or { panic('failed to send start command') }
				execute()
				con.send_string("v finish") or { panic('failed to send finish command') }
				con.close() or { panic(err) }
			}
			else {}
		}
	}
	}
}