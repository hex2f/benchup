module benchup

import os

pub fn mdgen(suite string, langs []Lang, reps int, runs []Run) string {
	mut out := '# $suite\n'

	desc := os.read_file('suites/$suite/desc.md') or { 'No description provided for this suite. Please open a PR.' }
	out += '\n$desc\n'
	
	out += '| Language | Compile Time | Cold Time | Hot Time |\n'
	out += '|----------|--------------|-----------|----------|\n'
		println('~ generating markdown')
	for lang in langs {
		mut sum := RunTime{0,0,0}
		for run in runs.filter(it.name == lang.name) {
			sum.hello += run.hello
			sum.warmup += run.warmup
			sum.hot += run.hot
		}
		sum.hello /= reps
		sum.warmup /= reps
		sum.hot /= reps
		results := '| $lang.name | $sum.hello | $sum.warmup | $sum.hot |'
		println('~ $results')
		out += results + '\n'
	}
	out += '\n*Averaged over $reps runs.*\n'
	return out
}