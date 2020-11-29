module main

import net
import time
import io

fn execute() {
	mut m := []int{}
	for i in 0..1000000 {
		m << i
	}
}

fn main () {
	server_port := 20522
	for {
		println('Connecting to port: $server_port')
		con := net.dial_tcp('127.0.0.1:$server_port') or {
			println('Connection failed')
			continue
		}
		mut reader := io.new_buffered_reader({
			reader: io.make_reader(con)
		})
		println('Connected')
		con.write_str('hello\n') or { panic('failed to send hello command') }
		for {
			line := reader.read_line() or { continue }
			if line.len == 0 { exit(0) }
			match line.split('\r')[0] {
				'warmup' {
					execute()
					con.write_str('start\n') or { panic('failed to send start command') }
					execute()
					con.write_str('finish\n') or { panic('failed to send finish command') }
					con.close() or { panic(err) }
					exit(0)
				}
				else {}
			}
		}
	}
}