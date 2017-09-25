/*
 operators.json:
 t - type:
 0 - prefix
 1 - infix
 2 - postfix
 v - value - the actual thing in the code
 p - precendence - the lower the more stuff it'll encapsulate
 */
 class Operator {
  int fix;
  String repr;
  String builtinname;
  String[] reprs;
  int prec;
  Operator (int t, String v, int p, String bin) {
    fix = t;
    repr = v;
    prec = p;
    builtinname = bin;
  }
  Operator (int t, String[] v, int p, String bin) {
    fix = t;
    reprs = v;
    prec = p;
    builtinname = bin;
  }
  boolean isNT (int nodetype) {//is node type
    return fix == nodetype-10 || (fix == 4 && nodetype == 14) || fix == 3 && nodetype == 11 || nodetype == 13;
  }
  String toString () {
    return (optypes[fix] +" op "+ (repr==null? arrToString(reprs) : "\""+repr+"\"") +", prec "+ prec);
  }
}