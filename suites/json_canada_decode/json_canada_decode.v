module main

import net
import io

import os

import json

struct FeatureCollection {
	typ string [json:"type"]
	features []Feature
}

struct Feature {
	typ string [json:"type"]
	properties FeatureProperties
	geometry Geometry
}

struct FeatureProperties {
	name string
}

struct Geometry {
	typ string [json:"type"]
	coordinates [][][]f32
}

fn execute() ? {
	data := os.read_file('suites/json_canada_decode/canada.json') or { panic('Failed to open json sample data.') }
	canada := json.decode(FeatureCollection, data) or { panic('Failed to parse json sample data.') }
	assert(canada.typ == 'FeatureCollection')
	assert(canada.features[0].properties.name == 'Canada')
	assert(canada.features[0].geometry.coordinates.len == 480)
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