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
| v (clang, prod) | 2930 | 99 | 102 |
| v (clang) | 671 | 140 | 155 |
| js (node) | 118 | 423 | 433 |
| js (deno) | 60 | 194 | 217 |

*Averaged over 5 runs.*
