class Obj {
  Object me;
  Obj (String ct) {
    me = ct;
  }
  Obj () {
  }
  String toString() {
    if (me == null) return "null";
    return me.toString();
  }
  boolean truthy() {
    return me != null;
  }
}
class Str extends Obj {
  Str (String contents) {
    me = contents;
  }
  boolean truthy() {
    return !me.equals("");
  }
}
Num NumZERO = new Num("0");
Num NumONE = new Num("1");
class Num extends Obj {
  //TODO make ints used where possible
  BigDecimal bd;
  Num () { }//java y u need this 4 extention
  Num (BigDecimal contents) {
    bd = contents;
    me = bd;
  }
  Num (String contents) {
    bd = new BigDecimal(contents);
    me = bd;
  }
  Num plus (Num inp) {
    return new Num((bd).add(inp.bd));
  }
  Num times (Num inp) {
    return new Num(bd.multiply(inp.bd));
  }
  Num dividedby (Num inp) {
    try {
      return new Num(bd.divide(inp.bd));
    } catch (ArithmeticException e) {
      return new Num(bd.divide(inp.bd, max(20, bd.scale()+10, inp.bd.scale()+10), RoundingMode.HALF_UP));
    }
  }
  Num minus (Num inp) {
    return new Num((bd).subtract(inp.bd));
  }
  Num pow (Num inp) {
    //TODO do
    return new Num("-1");
  }
  boolean truthy() {
    return !bd.equals(BigDecimal.ZERO);
  }
  boolean equals(Object o) {
    return compareTo(o) == 0;
  }
  int compareTo (Object o) {
    //println(this.bd, ((Num)o).bd);
    if (o instanceof Integer) return bd.compareTo(new BigDecimal((int)o));
    if (o instanceof BigDecimal) return bd.compareTo((BigDecimal)o);
    if (o instanceof Num) return bd.compareTo(((Num)o).bd);
    return 2;
  }
  String toString() {
    return bd.toString();
  }
}
class Bool extends Num {
  Bool (boolean val) {
    //println("dsa");
    me = bd = val? BigDecimal.ONE : BigDecimal.ZERO;
  }
  String toString() {
    if (truthy()) return "true";
    else return "false";
  }
  boolean truthy() {
    //println("FALSE!!",me, this.compareTo(NumZERO));
    return !((Num)this).equals(NumZERO);
  }
}
class Arr extends Obj {
  ArrayList<Obj> arr;
  Arr () {
    arr = new ArrayList<Obj>();
    me = arr;
  }
  Arr (ArrayList<Obj> contents) {
    arr = contents;
    me = arr;
  }
  Obj add (Obj item) {
    arr.add(item);
    me = arr;
    return item;
  }
}
class Var extends Obj {
  String name;
  Scope scope;
  Var (String name, Scope scope) {
    this.name = name;
    this.scope = scope;
  }
  //Var (String name, Scope iscope, boolean parentScopes) throws Exception {
  //  this(name, iscope);
  //  while (!scope.privateVars.containsKey(name)) {
  //    if (scope.parent == null) throw new Exception ("No variable called "+ name +" found");
  //    scope = scope.parent;
  //  }
  //}
  Obj get() {
    return scope.privateVars.get(name);
  }
  Obj set (Obj val) {
    //println("variable set", name, val);
    scope.privateVars.put(name, val);
    return val;
  }
  String toString() {
    try {
      return scope.privateVars.get(name).toString();
    } catch (Exception e) {
      //return scope.privateVars.containsKey(name)+"";
      return new Obj().toString();
    }
  }
}
/*ORETclass Return extends Obj {
  Scope scope;
  Obj val;
  boolean nextReturn = false;
  Return (Scope towhere, Obj returnwhat) {
    scope = towhere;
    val = returnwhat;
  }
}*/