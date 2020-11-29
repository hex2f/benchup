module benchup

import net
import time
import os
import io

struct RunTime {
mut:
	hello		i64
	warmup	i64
	hot			i64
}

pub struct Lang {
	ext  string
	name string
	exec string
}

struct Run {
	name string
	hello		i64
	warmup	i64
	hot			i64
}

fn handle_connection(con net.TcpConn, mut hello time.StopWatch) ?RunTime {
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
		if line.len == 0 { return error('empty line') }
		part := line.split('\r')[0]
		
		match part {
			'hello' {
				hello.stop()
				println('< hello')
				warmup.start()
				con.write_str('warmup\n') or { panic('failed to send warmup command') }
				println('> warmup')
			}
			'start' {
				warmup.stop()
				hot.start()
				println('< start')
			}
			'finish' {
				hot.stop()
				run := RunTime { hello: hello.elapsed().milliseconds(), warmup: warmup.elapsed().milliseconds(), hot: hot.elapsed().milliseconds() }
				println('< finish')
				return run
			}
			else {}
		}
	}
}

fn exec(path string) {
	println('~ running - $path')
	os.exec(path) or {
		println('Failed to exec "$path"')
		panic(err)
	}
}

pub fn run(suites []string, langs []Lang, reps int, outpath string) {
	server_port := 20522
	println('Starting server on port: $server_port')
	server := net.listen_tcp(server_port) or { panic(err) }

	mut mdout := ''

	for suite in suites {
		println('~ Running suite: $suite')
		mut runs := []Run{}
		
		for lang in langs {
			for i in 0..reps {
				println('~ $suite | $lang.name | ${i+1}/$reps')
				// time to hello
				mut hello := time.new_stopwatch({})
				hello.start()
				go exec('${lang.exec}suites/$suite/${suite}.$lang.ext')
				println('~ waiting for connection')
				con := server.accept() or {
					server.close() or { }
					panic(err)
				}
				println('~ connected')
				run := handle_connection(con, mut hello) or {
					hello.stop()
					println('~ dnf')
					continue
				}
				runs << Run{name: lang.name, hello: run.hello, warmup: run.warmup, hot: run.hot}
			}
		}

		mdout += mdgen(suite, langs, reps, runs)
	}
	os.write_file(outpath, mdout)
	server.close() or { panic('failed to close server, please do so manually.') }
}
