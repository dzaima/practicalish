class Func extends Obj {
  String name;
  boolean builtin = false;
  Node program;
  String[] paramNames;
  Scope closure;
  Func (String name, Node program, Scope scope, String[] paramNames) {
    this.name = name;
    this.program = program;
    if (program.is(2)) program.type = 1;
    closure = scope;
    //println("creating function "+name+" with paramnames ["+ join(paramNames, ", ") +"]:\n"+program);
    this.paramNames = paramNames;
  }
  Func (String name) {
    this.name = name;
    this.builtin = true;
  }
  Obj call (Parameter params, Scope scope) throws Exception {
    //println("calling "+name);
    if (builtin) {
      switch (name) {
        /*case "function":
          Func function = new Func(params.getRaw(0).content);
          scope.addFunction()
        break;*/
        case "print":
          for (int i = 0; i < params.size(); i++)
            print(i != 0? " " + params.getVal(i) : params.getVal(i));
        break;
        
        case "println":
          for (int i = 0; i < params.size(); i++)
            print(i != 0? " " + params.getVal(i) : params.getVal(i));
          println();
        break;
        
        case "printscope":
          print(scope.treeify());
        break;
        
        case "for":
          if (params.size() != 3) throw new Exception("for: Expected 3 parameters, got " + params.size());
          params.call(0);
          Node body = scope.parent.getNextObj();
          //println(body);
          Obj toReturn = new Obj();
          if (body.type == 2) body.type = 1;
          while (params.call(1).truthy()) {
            toReturn = new Scope(body, scope).run();
            //ORETif (toReturn instanceof Return && ((Return)toReturn).nextReturn) 
            params.call(2);
          }
          return toReturn;
        //break;
        
        case "if":
          if (params.size() != 1) throw new Exception("if: Expected 1 parameters, got " + params.size());
          body = scope.parent.getNextObj();
          if (body.type == 2) body.type = 1;
          Obj obj = params.call(0);
          //println("OBJ", obj, obj.truthy());
          if (obj.truthy()) {
            return new Scope(body, scope).run();
          }
        break;
        
        case "return":
          //println(scope.treeify());
          //return new Return(scope.local, params.getVal(0));
          throw new ReturnE(params.getVal(0));
        //break;
        
        
        
        //operators
        //math operators
        case "_add_":
          if (params.size() != 2) throw new Exception("+: Expected 2 parameters, got " + params.size());
          Obj p1 = params.getVal(0);
          Obj p2 = params.getVal(1);
          //println("ADDING "+ params +": "+ p1 +" & "+ p2);
          if (p1 instanceof Arr) {
            if (p2 instanceof Arr) {
              //TODO
            } else {
              //TODO
            }
          } else if (p2 instanceof Arr) {
            //TODO
          } 
          if (p1 instanceof Num && p2 instanceof Num) return ((Num)p1).plus((Num)p2);
          else return new Str(p1.toString() + p2.toString());
        //break;
        case "_smul_":
          p1 = params.getVal(0);
          p2 = params.getVal(1);
          Obj mulres = new Func("_mul_").call(params, scope);
          Obj[] nparams = {new Var(params.getVar(0), scope), mulres};
          return new Func("_set_").call(new Parameter(nparams, scope), scope);
        //break;
        case "_mul_":
          p1 = params.getVal(0);
          p2 = params.getVal(1);
          if (p1 instanceof Num) {
            if (p2 instanceof Num) {
              return ((Num)p1).times((Num)p2);
            } else {
              //TODO
            }
          } else if (p2 instanceof Num) {
            //TODO
          }
        break;
        case "_div_":
          p1 = params.getVal(0);
          p2 = params.getVal(1);
          if (p1 instanceof Num) {
            if (p2 instanceof Num) {
              return ((Num)p1).dividedby((Num)p2);
            } else {
              //TODO
            }
          } else if (p2 instanceof Num) {
            //TODO
          }
        break;
        case "_pow_":
          p1 = params.getVal(0);
          p2 = params.getVal(1);
          if (p1 instanceof Num && p2 instanceof Num) {
            return ((Num)p1).pow((Num)p2);
          } else throw new Exception ("_pow_ expects parameters like {Num, Num}, but got {" + p1.getClass() + ", " + p2.getClass() + "}");
        //break;
        case "_sub_":
          p1 = params.getVal(0);
          p2 = params.getVal(1);
          if (p1 instanceof Num && p2 instanceof Num) {
            return ((Num)p1).minus((Num)p2);
          } else throw new Exception ("_sub_ expects parameters like {Num, Num}, but got {" + p1.getClass() + ", " + p2.getClass() + "}");
        //break;
        case "_neg_":
          p1 = params.getVal(0);
          if (p1 instanceof Num) {
            return (NumZERO).minus((Num)p1);
          } else throw new Exception ("_neg_ expects parameters like {Num}, but got {" + p1.getClass() + "}");
        //break;
        
        
        //other stuff
        case "_postinc_":
          Var var = scope.getVariable(params.getVar(0));
          if (!(var.get() instanceof Num)) throw new Exception("_postinc_ expected variable of type {Num}, got type "+ var.get().getClass());
          BigDecimal num = ((Num)var.get()).bd;
          var.set(new Num(num.add(BigDecimal.ONE)));
          //println(var.get());
          return new Num(num);
        //break;
        case "_postdec_":
          var = scope.getVariable(params.getVar(0));
          if (!(var.get() instanceof Num)) throw new Exception("_postinc_ expected variable of type {Num}, got type "+ var.get().getClass());
          num = ((Num)var.get()).bd;
          var.set(new Num(num.subtract(BigDecimal.ONE)));
          //println(var.get());
          return new Num(num);
        //break;
        case "_lambda_":
          //println(params.getRaw(0));
          //println(params);
          Node inputs = parametrize(params.getRaw(0));
          String[] paramNames = new String[inputs.size()];
          for (int i = 0; i < inputs.size(); i++) {
            paramNames[i] = inputs.get(i).content;
          }
          Func function = new Func("lambda", params.getRaw(1), scope, paramNames);
          //println("lambda created:", function);
          return function;
        //break;
        
        
        
        //comparison
        case "_lt_":
          p1 = params.getVal(0);
          p2 = params.getVal(1);
          if (p1 instanceof Num && p2 instanceof Num) {
            return new Bool(((Num)p1).compareTo((Num)p2)<0);
          } else throw new Exception ("_lt_ expects parameters like {Num, Num}, but got {" + p1.getClass() + ", " + p2.getClass() + "}");
        //break;
        case "_gt_":
          p1 = params.getVal(0);
          p2 = params.getVal(1);
          if (p1 instanceof Num && p2 instanceof Num) {
            return new Bool(((Num)p1).compareTo((Num)p2)>0);
          } else throw new Exception ("_gt_ expects parameters like {Num, Num}, but got {" + p1.getClass() + ", " + p2.getClass() + "}");
        //break;
        case "_eq_":
          p1 = params.getVal(0);
          p2 = params.getVal(1);
          if (p1 instanceof Num && p2 instanceof Num) {
            return new Bool(((Num)p1).compareTo((Num)p2)==0);
          } else throw new Exception ("_eq_ expects parameters like {Num, Num}, but got {" + p1.getClass() + ", " + p2.getClass() + "}");
        //break;
        
        
        //variable stuff
        case "_set_":
          p2 = params.getVal(1);
          return scope.setVariable(params.getVar(0), p2);
        //break;
        case "_localvar_":
          Scope localSetScope = new Scope(scope);
          localSetScope.varCreateMode = Scope.LOCAL;
          return params.call(0, localSetScope);
        //break;
        case "_scopevar_":
          Scope scopeSetScope = new Scope(scope);
          scopeSetScope.varCreateMode = Scope.SCOPE;
          return params.call(0, scopeSetScope);
        
        
        case "_execmult_":
          Obj last = new Obj();
          for (int i = 0; i < params.size(); i++) {
            if (params.getRaw(i).is(13) && params.getRaw(i).iss(",")) continue;
            last = params.getVal(i);
          }
          return last;
        default:
          throw new Exception("Unknown built-in function "+name+" called");
      }
      //functions which don't return just return this
      return new Obj();
    } else {
      Scope funcScope = new Scope(program, scope);
      //println("["+join(paramNames, ", ")+"] ["+joins(params.all(),", ")+"]", funcScope.treeify());
      funcScope.local = funcScope;
      funcScope.closure = closure;
      //println("created closure for", name, ":", funcScope.treeify());
      funcScope.varCreateMode = Scope.SCOPE;
      for (int i = 0; i < min(paramNames.length, params.size()); i++) {
        funcScope.createVariable(paramNames[i], params.getVal(i));
      }
      Arr args = new Arr();
      for (Obj o : params.all()) args.add(o);
      funcScope.createVariable("arguments", args);
      funcScope.createVariable("args", args);
      funcScope.createVariable("$0", args);
      funcScope.varCreateMode = Scope.SET;
      //println("function result from", name+"("+join(paramNames, ", ")+")", scopeBefore, "is", res, "#");
      //println("["+join(paramNames, ", ")+"] ["+joins(params.all(),", ")+"]", funcScope.treeify());
      try {
        Obj res = funcScope.run();;
        //println("["+join(paramNames, ", ")+"] ["+joins(params.all(),", ")+"]", funcScope.treeify());
        return res;
      } catch (ReturnE robj) {
        return robj.res;
      }
    }
  }
  String toString() {
    String res = "function " + name + "(";
    for (String s : paramNames) res+= (res.endsWith("(")? "" : ", ") + s;
    res+= ") {" + program.oneline() + "}";
    //res="{%"+name+"}"; smallfunc
    return res;
  }
}