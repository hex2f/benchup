# intarr

Add all integers from 0 up to (but not including) 10000000 to an array.
```v
mut m := []int{}
for i in 0..1000000 {
  m << i
}
```

| Language | Compile Time | Cold Time | Hot Time |
|----------|--------------|-----------|----------|
| v (clang, prod) | 2948 | 12 | 13 |
| v (clang) | 676 | 17 | 19 |
| js (node) | 114 | 383 | 430 |
| js (deno) | 58 | 193 | 224 |

*Averaged over 5 runs.*
