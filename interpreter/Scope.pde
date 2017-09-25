class Scope {
  HashMap<String, Obj> privateVars = new HashMap<String, Obj>();
  HashMap<String, Func> privateFuncs = new HashMap<String, Func>();
  Node n;
  Obj toReturn;
  Scope parent = null;
  Scope global = null;
  Scope local = null;
  Scope closure = null;
  static final int GLOBAL = 0;
  static final int LOCAL = 1;
  static final int SCOPE = 2;
  static final int SET = 3;
  int varCreateMode;
  int cloopPart;
  //creating the first - global scope
  Scope (Node contents) {
    //println("new global scope");
    n = contents;
    global = this;
    local = this;
    varCreateMode = SET;
  }
  Scope (Node contents, Scope parent) {
    //println("new scope");
    n = contents;
    this.parent = parent;
    global = parent.global;
    local = parent.local;
    varCreateMode = parent.varCreateMode;
  }
  //for when the contents are known only later
  Scope (Scope parent) {
    this.parent = parent;
    global = parent.global;
    local = parent.local;
    varCreateMode = parent.varCreateMode;
  }
  Obj run() throws Exception {
    Obj creturn = new Obj();
    //println("\nEX# "+n.type+" # "+n.children+" #");
    switch (n.type) {
      case 1: case 3:
        for (cloopPart = 0; cloopPart < n.size(); cloopPart++) {
          Node c = n.get(cloopPart);
          creturn = new Scope(c, this).run();
          /*ORETif (toReturn instanceof Return) {
            if (((Return)toReturn).scope == this) ((Return)toReturn).nextReturn = true;
            return toReturn;
          }*/
        }
      break;
      case 4:
        if (n.content.equals("")) {
          //((Func)callFunction("_lambda_", n.get(0).children)).call(new Parameter(n.get(1).children, this), this);
          Scope getfunc = new Scope(n.get(0), this);
          Obj func = getfunc.run();
          if (!(func instanceof Func)) throw new Exception("Called isn't a function: " + func + " from \n" + n.get(0));
          return ((Func)func).call(new Parameter(parametrize(n.get(1)).children, this), this);
        } else creturn = callFunction(n.content, n.children);
      break;
      case 5:
        if (n.content.matches("\\d+\\.?|\\d*\\.\\d+"))
          creturn = new Num(n.content);
        else {
          creturn = getVarVal(n.content);
          //println(n.content, this.treeify());
        }
      break;
      case 6: case 7:
        //TODO function strings
        creturn = new Obj(n.content);
      break;
      case 9:
        String[] paramNames = new String[n.get(1).size()];
        for (int i = 0; i < n.get(1).size(); i++) {
          paramNames[i] = n.get(1).get(i).content;
        }
        Func function = new Func(n.get(0).content, n.get(2), this, paramNames);
        
        parent.addFunction(function);
        creturn = function;
      break;
      case 10: case 11: case 12: case 14:
        boolean found = false;
        if (!n.content.equals("")) {
          for (Operator op : ops) {
            if (op.isNT(n.type) && op.repr.equals(n.content)) {
              creturn = callFunction(op.builtinname, n.children);
              found = true;
              break;
            }
          }
          if (!found) throw new Exception("No operator \""+n.content +"\" found");
        } else {
          Node last = n.get(0);
          for (int i = 2; i < n.size(); i+= 2) {
            Node current = n.get(i);
            found = false;
            Node operator = n.get(i-1);
            for (Operator op : ops) {
              if (op.repr != null && op.repr.equals(operator.content)) {
                ArrayList<Node> operands = new ArrayList<Node>();
                operands.add(last);
                operands.add(current);
                //println("SENDING #", op.builtinname, operands, "#");
                creturn = callFunction(op.builtinname, operands);
                found = true;
                break;
              }
            }
            if (!found) throw new Exception("No "+ nodeTypeNames[operator.type] +" \""+operator.content +"\" found");
          }
        }
      break;
      case 2: case 21: break;
      default:
        throw new Exception("invalid type " + n.type + " node called");
    }
    return creturn;
  }
  void addFunction (Func function) throws Exception {
    //if (privateFuncs.containsKey(function.name)) throw new Exception("Function "+ function.name +" already exists!");
    privateFuncs.put(function.name, function);
  }
  Func getFunction (String name, boolean searchClosure) {
    searchClosure = true;
    if (privateFuncs.containsKey(name)) return privateFuncs.get(name);
    if (searchClosure && closure != null) {
      Func closureFind = closure.getFunction(name, true);
      if (closureFind != null) return closureFind;
    }
    if (parent != null) return parent.getFunction(name, false);
    return null;
  }
  Var createVariable (String name, Obj contents) throws Exception {
    Scope varScope;
    if (varCreateMode == SCOPE) varScope = this;
    else if (varCreateMode == LOCAL) varScope = local;
    else if (varCreateMode == GLOBAL || varCreateMode == SET) varScope = global;
    else throw new Exception("invalid varCreateMode: "+ varCreateMode);//this should never happen but eh
    if (varCreateMode != SET && varScope.privateVars.containsKey(name)) throw new Exception("Variable "+ name +" already exists!");
    Var var = new Var(name, varScope);
    var.set(contents);
    //println("created variable "+ name +", scopetype "+ varCreateMode +": "+ contents);
    return var;
  }
  Obj setVariable (String name, Obj value) throws Exception {
    if (varCreateMode != SET) return createVariable(name, value);
    Var foundVar = getVarOrNull(name);
    if (foundVar == null) return createVariable(name, value);
    else return foundVar.set(value);
  }
  Obj getVarVal (String name) throws Exception {
    Var res = getVarOrNull(name);
    if (res != null) {
      return res.get();
    } else {
      return getFunction(name, true);
    }
  }
  Node getNextObj() {
    cloopPart++;
    Node out = n.get(cloopPart);
    return out;
  }
  Var getVariable (String name) throws Exception {
    Var res = getVarOrNull(name);
    if (res != null) return res;
    else throw new Exception("No variable "+ name +" found");
  }
  Var getVarOrNull (String name) throws Exception {
    if (privateVars.containsKey(name)) return new Var(name, this);
    if (closure != null) {
      Var closureFind = closure.getVarOrNull(name);
      if (closureFind != null) return closureFind;
    }
    if (parent != null) return parent.getVarOrNull(name);
    return null;
  }
  Obj callFunction (String name, ArrayList<Node> params) throws Exception {
    return callFunction(name, new Parameter(params, this));
  }
  Obj callFunction (String name, Parameter params) throws Exception {
    Func function = getFunction(name, true);
    if (function == null) {
      Obj funcVar;
      try {
        funcVar = getVariable(name).get();
      } catch (Exception e) {
        throw new Exception("No function/variable named \""+ name +"\" was found");
      }
      //print(funcVar);
      if (!(funcVar instanceof Func)) throw new Exception("Variable \""+ name +"\" isn't a function");
        function = (Func)funcVar;
    }
    Obj res = function.call(params, this);
    //ORETif (res instanceof Return) toReturn = (Return)res;
    return res;
  }
  void load (String libname) throws Exception {
    switch (libname) {
      case "builtinops":
        for (Operator op : ops) {
          if (!privateFuncs.containsKey(op.builtinname)) {
            addFunction(new Func(op.builtinname));
          }
        }
      break;
    }
  }
  String[] allVars() {
    StringList allvars = new StringList();
    Scope cc = this;
    while (cc != null) {
      for (String s : cc.privateVars.keySet()) allvars.append("'"+ s +"\': {"+ cc.privateVars.get(s).toString().replace("\n", "  \\n  ") +"}");
      cc = cc.parent;
    }
    return allvars.array();
  }
  String toString() {
    return "Scope ["+ join(allVars(), ", ") +"]: {\n"+ n +"}";
  }
  String treeify() {
    return treeify(local, global);
  }
  String treeify(Scope ilocal, Scope iglobal) {
    String res = "{vars:"+privateVars;
    /*for (String ck : privateVars.keySet()) {
      Obj cvv = privateVars.get(ck);
      res+= ck+""
    }*/
    if (this == ilocal) res+= ", LOCAL";
    if (this == iglobal) res+= ", GLOBAL";
    if (parent != null) res+= ", parent:"+parent.treeify(ilocal, iglobal);
    if (closure != null) res+= ", closure:"+closure.treeify(ilocal, iglobal);
    return res+"}";
  }
}