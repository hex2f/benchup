# intarr

Add all integers from 0 up to (but not including) 10000000 to an array.
```v
mut m := []int{}
for i in 0..10000000 {
  m << i
}
```

| Language | Compile Time | Cold Time | Hot Time |
|----------|--------------|-----------|----------|
| v (clang, prod) | 3835 | 140 | 135 |
| v (clang) | 1145 | 234 | 241 |
| js (node) | 98 | 496 | 593 |
| js (deno) | 84 | 359 | 381 |

*Averaged over 5 runs.*
# json_canada_decode

Read and parse all values in `suites/json_canada_decode/canada.json`, assert the following:
```v
assert(canada.type == 'FeatureCollection')
assert(canada.features[0].properties.name == 'Canada')
assert(canada.features[0].geometry.coordinates.len == 480)
```
| Language | Compile Time | Cold Time | Hot Time |
|----------|--------------|-----------|----------|
| v (clang, prod) | 8095 | 251 | 280 |
| v (clang) | 2781 | 371 | 455 |
| js (node) | 298 | 211 | 119 |
| js (deno) | 101 | 182 | 222 |

*Averaged over 5 runs.*
