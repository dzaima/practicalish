class Interpreter {
  Node parsed;
  Interpreter (String program) {
    parsed = new Parser(program).parse();
    println("PARSED:\n" + parsed.toString(0) + "\n"+ctr+"\n--------------------------------------------------------------------------------------------------------------------------\n");
  }
  void run () throws Exception {
    Scope globalScope = new Scope(parsed);
    globalScope.addFunction(new Func("print"));
    globalScope.addFunction(new Func("println"));
    globalScope.addFunction(new Func("printscope"));
    globalScope.addFunction(new Func("for"));
    globalScope.addFunction(new Func("while"));
    globalScope.addFunction(new Func("if"));
    globalScope.addFunction(new Func("return"));
    globalScope.load("builtinops");
    globalScope.run();
  }
}