class Parameter {
  ArrayList<Node> raw;
  Obj[] parsed;
  Scope scope;
  Parameter (ArrayList<Node> params, Scope parentScope) {
    raw = new ArrayList<Node>();
    for (Node c : params) {
      if (c.type != 21) raw.add(c);
    }
    parsed = new Obj[size()];
    this.scope = parentScope;
  }
  Parameter (Obj[] pparams, Scope parentScope) {
    parsed = pparams;
    this.scope = parentScope;
  }
  Obj getVal (int index) throws Exception {
    if (parsed[index] != null) return parsed[index];
    parsed[index] = new Scope(raw.get(index), scope).run();
    return parsed[index];
  }
  String getVar (int index) throws Exception {
    if (raw == null || raw.size() <= index) {
      if (parsed.length <= index) throw new Exception("Not enough parameters, searching for a variable at index "+ index);
      return ((Var)parsed[index]).name;
    }
    if (raw.get(index).is(5)) return raw.get(index).content;
    else throw new Exception("parameter isn't a variable");
  }
  Node getRaw (int index) throws Exception {
    return raw.get(index);
  }
  Obj call (int index) throws Exception {
    //println(this, " # ", index, " # ", scope);
    Scope cscope = new Scope(raw.get(index), scope);
    //println("START", raw.get(index), cscope);
    parsed[index] = cscope.run();
    return parsed[index];
  }
  Obj call (int index, Scope scope) throws Exception {
    scope.n = raw.get(index);
    parsed[index] = scope.run();
    //println(parsed[index], scope.n);
    return parsed[index];
  }
  Obj[] all() throws Exception {
    Obj[] out = new Obj[raw.size()];
    for (int i = 0; i < raw.size(); i++) {
      out[i] = getVal(i);
    }
    return out;
  }
  int size() {
    return raw.size();
  }
  String toString() {
    return raw.toString();
  }
}