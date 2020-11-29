Read and parse all values in `suites/json_canada_decode/canada.json`, assert the following:
```v
assert(canada.type == 'FeatureCollection')
assert(canada.features[0].properties.name == 'Canada')
assert(canada.features[0].geometry.coordinates.len == 480)
```