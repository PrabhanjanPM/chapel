/* The Computer Language Benchmarks Game
 * http://benchmarksgame.alioth.debian.org/
 *
 * contributed by Ben Harshbarger
 * based on Go implementation by Oleg Mazurov
 *
 */

use DynamicIters;

config const n = 7;

config const nchunks = 720;
var Fact : [0..n] int;

proc main() {
  Fact[0] = 1;
  for i in 1..n do
    Fact[i] = Fact[i-1] * i;

  var chunksz = (Fact[n] + nchunks - 1) / nchunks;
  chunksz += chunksz%2;

  const work = 0 .. (Fact[n] - chunksz) by chunksz;

  var checkSum: int;
  var maxFlips = 1;

  forall idx in dynamic(work, 1) with ( + reduce checkSum, max reduce maxFlips) {
    for (i, flips) in fannkuch(idx, idx+chunksz) {
      maxFlips = max(maxFlips, flips);
      checkSum += if i % 2 == 0 then flips else -flips;
    }
  }
  
  writeln(checkSum, "\nPfannkuchen(", n, ") = ", maxFlips);
}

iter fannkuch(idxMin:int, idxMax:int) {
  var p, pp, count : [0..#n] int;
  p = 0..#n;

  // first permutation
  var idx = idxMin;
  for i in 1..n-1 by -1 {
    const d = idx / Fact[i];
    count[i] = d;
    idx = idx % Fact[i];

    const slice = 0..i;
    pp[slice] = p[slice];
    for j in 0..i {
      if j + d <= i then
        p[j] = pp[j+d];
      else
        p[j] = pp[j+d-i-1];
    }
  }

  var maxFlips = 1;
  var checkSum = 0;

  idx = idxMin;

  while true {
    if p[0] != 0 {
      //countFlips
      var locflips = 1;
      var first = p[0];

      if p[first] != 0 {
        pp = p;
        do {
          locflips += 1;
          var lo = 1, hi = first - 1;
          while lo < hi {
            pp[lo] <=> pp[hi];
            lo += 1;
            hi -= 1;
          }
          pp[first] <=> first;
        } while pp[first] != 0;
      }

      yield (idx, locflips);
    }

    idx += 1;

    if idx == idxMax then break;

    // nextPerm
    var first = p[1];
    p[1] = p[0];
    p[0] = first;

    var i = 1;
    count[i] += 1;
    while count[i] > i {
      count[i] = 0;
      i += 1;
      const next = p[1];
      p[0] = p[1];
      for j in 1..i-1 do p[j] = p[j+1];
      p[i] = first;
      first = next;
      
      count[i] += 1;
    }
  }
}
