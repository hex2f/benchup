module main

import net
import time
import os

struct Time {
	warmup	int
	hot		int
}

fn handle_connection(con net.Socket) ?Time {
	defer {
		con.close() or { }
	}

	con.send_string('warmup') or { panic('failed to send warmup command') }
	warmup := time.new_stopwatch()
	warmup.start()

	hot := time.new_stopwatch()

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
	suites := ['intarr']
	langs := [
		Lang{ name: 'v', exec: 'v -prod run ' },
		Lang{ name: 'js', exec: 'node ' }
	]
	mut out := ""
	for suite in suites {
		println("suite - $suite")
		out += "$suite\n"
		for lang in langs {
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
	os.write_file('results.txt', out)
	server.close() or { println("failed to close server, please do so manually.") }
}
