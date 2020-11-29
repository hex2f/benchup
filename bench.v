module main

import net
import time
import os
import io

struct Time {
	hello		i64
	warmup	i64
	hot			i64
}

fn handle_connection(con net.TcpConn, mut hello time.StopWatch) ?Time {
	defer {
		con.close() or { }
	}

	mut reader := io.new_buffered_reader({
		reader: io.make_reader(con)
	})

	mut warmup := time.new_stopwatch({})
	mut hot := time.new_stopwatch({})

	for {
		line := reader.read_line() or { continue }
		if line.len == 0 { return error("empty line") }
		part := line.split('\r')[0]
		
		match part {
			"hello" {
				hello.stop()
				println('< hello')
				warmup.start()
				con.write_str('warmup\n') or { panic('failed to send warmup command') }
				println('> warmup')
			}
			"start" {
				warmup.stop()
				hot.start()
				println('< start')
			}
			"finish" {
				hot.stop()
				run := Time { hello: hello.elapsed().milliseconds(), warmup: warmup.elapsed().milliseconds(), hot: hot.elapsed().milliseconds() }
				println('< finish')
				return run
			}
			else {}
		}
	}
}

struct Lang {
	ext  string
	name string
	exec string
}

fn exec(path string) {
	println('~ running - $path')
	os.exec(path) or {
		println('Failed to exec "$path"')
		panic(err)
	}
}

const (
	suites = ['intarr']
	langs = [
		Lang{ ext: 'v', name: 'v (clang, prod)', exec: 'v -prod run ' }
		Lang{ ext: 'v', name: 'v (clang)', exec: 'v run ' }
		//Lang{ ext: 'v', name: 'v (tcc)', exec: 'v -cc /usr/local/bin/tcc run ' }
		Lang{ ext: 'js', name: 'js (node)', exec: 'node ' }
		Lang{ ext: 'deno.js', name: 'js (deno)', exec: 'deno run --allow-net ' }
	]
	runs = 3
)

fn main() {
	server_port := 20522
	println('Starting server on port: $server_port')
	server := net.listen_tcp(server_port) or { panic(err) }
	mut out := ""
	for suite in suites {
		println("~ suite - $suite")
		out += "$suite\n"
		for lang in langs {
			for i in 0..runs {
				println('~ $suite | $lang.name | ${i+1}/$runs')
				// time to hello
				mut hello := time.new_stopwatch({})
				hello.start()
				go exec("${lang.exec}suites/$suite/${suite}.$lang.ext")
				println('~ waiting for connection')
				con := server.accept() or {
					server.close() or { }
					panic(err)
				}
				println('~ connected')
				run := handle_connection(con, mut hello) or {
					hello.stop()
					out += "\t$lang.name ${hello.elapsed().milliseconds()} DNF DNF\n"
					println('~ dnf')
					continue
				}
				out += "\t$lang.name $run.hello $run.warmup $run.hot\n"
			}
		}
	}
	os.write_file('results.txt', out)
	server.close() or { panic("failed to close server, please do so manually.") }
}
