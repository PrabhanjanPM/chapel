module module1 {
  config var x = 1;

  function main() {
    writeln("x is: ", x);
  }
}

module module2 {
  config var x = 2;
  config var z: float = 999;
}

