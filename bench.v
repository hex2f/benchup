module main

import net
import time
import os

struct Time {
	warmup	i64
	hot		i64
}

fn handle_connection(con net.Socket) ?Time {
	defer {
		con.close() or { }
	}

	con.send_string('warmup') or { panic('failed to send warmup command') }
	mut warmup := time.new_stopwatch({})
	warmup.start()

	mut hot := time.new_stopwatch({})

	for {
		line := con.read_line()
		if line.len == 0 { return error("empty line") }
		parts := line.split('\r')[0].split(' ')
		
		match parts[1] {
			"start" {
				warmup.stop()
				hot.start()
			}
			"finish" {
				hot.stop()
				run := Time { warmup: warmup.elapsed().milliseconds(), hot: hot.elapsed().milliseconds() }
				return run
			}
			else {}
		}
	}
}

struct Lang {
	name string
	exec string
}

fn main() {
	server_port := 20522
	println('Starting server on port: $server_port')
	server := net.listen(server_port) or { panic(err) }
	suites := ['xjson2-encode', 'json-encode']
	langs := [
		Lang{ name: 'v', exec: 'v -prod run ' }
		//Lang{ name: 'js', exec: 'node ' }
	]
	mut out := ""
	for suite in suites {
		println("suite - $suite")
		out += "$suite\n"
		for lang in langs {
			for _ in 0..5 {
				p := "${lang.exec}suites/$suite/${suite}.$lang.name"
				println('running - $p')
				go os.exec(p)
				con := server.accept() or {
					server.close() or { }
					panic(err)
				}
				run := handle_connection(con) or {
					out += "\t$lang.name DNF DNF\n"
					continue
				}
				out += "\t$lang.name $run.warmup $run.hot\n"
			}
		}
	}
	os.write_file('results.txt', out)
	server.close() or { println("failed to close server, please do so manually.") }
}
