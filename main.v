module main

import benchup

const (
	suites = [
		benchup.Suite {
			name: 'intarr',
			langs: [
				benchup.Lang{ ext: 'v', name: 'v (clang, prod)', exec: 'v -prod run ' }
				benchup.Lang{ ext: 'v', name: 'v (clang)', exec: 'v run ' }
				//benchup.Lang{ ext: 'v', name: 'v (tcc)', exec: 'v -cc /usr/local/bin/tcc run ' }
				benchup.Lang{ ext: 'js', name: 'js (node)', exec: 'node ' }
				benchup.Lang{ ext: 'deno.js', name: 'js (deno)', exec: 'deno run --allow-net ' }
			]
		}

		benchup.Suite {
			name: 'json_canada_decode',
			langs: [
				benchup.Lang{ ext: 'v', name: 'v (clang, prod)', exec: 'v -prod run ' }
				benchup.Lang{ ext: 'v', name: 'v (clang)', exec: 'v run ' }
				//benchup.Lang{ ext: 'v', name: 'v (tcc)', exec: 'v -cc /usr/local/bin/tcc run ' }
				benchup.Lang{ ext: 'js', name: 'js (node)', exec: 'node ' }
				benchup.Lang{ ext: 'deno.js', name: 'js (deno)', exec: 'deno run --allow-all ' }
			]
		}
	]
	reps = 5
)

fn main() {
	benchup.run(suites, reps, 'RESULTS.md')
}