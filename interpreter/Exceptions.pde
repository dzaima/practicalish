class ReturnE extends Exception {
  Obj res;
  ReturnE (Obj toReturn) {
    res = toReturn;
  }
}