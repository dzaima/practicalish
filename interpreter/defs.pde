String[][] codestringCode = {{"\\(", ")"}, {"$(", ")"}};
String literal = "[a-zA-Z0-9_$]";
String spacing = "[\t \n;]";
String operatorRegex;
String[] optypes = {"prefix", "infix", "postfix", "infix RTL", "repeating", "ternary"};
String[] nodeTypeNames = {"", "group", "function", "operation group", "function call", "literal", "string", "codestring", "array", null, "prefix operator", "infix operator", "postfix operator", "operator", "ternary operator", null, null, null, null, null, "spacing", "semicolon"};
int[] object = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 14};

JSONArray precDefs;
ArrayList<Operator> ops;
ArrayList<ArrayList<Operator>> opgs;//operator groups
HashMap<String, String[]> funcData = new HashMap<String, String[]>();

void defsSetup() {
  precDefs = loadJSONArray(dataPath("operators.json"));
  ops = new ArrayList<Operator>();
  ArrayList<String> ops4regex = new ArrayList<String>();
  for (int i = 0; i < precDefs.size(); i++) {
    JSONObject co = precDefs.getJSONObject(i);
    int type = co.getInt("t");
    if (type != 5) {
      String v = co.getString("v");
      ops4regex.add(v);

      ops.add(new Operator(type, v, co.getInt("p"), co.getString("b")));
    } else {
      JSONArray vsraw = co.getJSONArray("v");
      String[] vs = new String[vsraw.size()];
      for (int j = 0; j < vsraw.size(); j++) {
        vs[j] = vsraw.getString(j);
        ops4regex.add(vs[j]);
      }

      ops.add(new Operator(type, vs, co.getInt("p"), co.getString("b")));
    }
  }

  Collections.sort(ops4regex, new Comparator<String>() {
    @Override
    public int compare (String o1, String o2) {
      return -((Integer)o1.length()).compareTo((Integer)o2.length());
    }
  });
  
  operatorRegex = "^(";
  for (String cs : ops4regex) {
    operatorRegex+= regexEscape(cs);
    if (cs != ops4regex.get(ops4regex.size()-1)) operatorRegex+= "|";
  }
  operatorRegex+= ")";
  //println(operatorRegex);
  Collections.sort(ops, new Comparator<Operator>() {
    @Override
    public int compare (Operator o1, Operator o2) {
      return ((Integer)o1.prec).compareTo((Integer)o2.prec);
    }
  });
  int lprec = -1;
  opgs = new ArrayList();
  ArrayList<Operator> cops = new ArrayList<Operator>();//current operators
  for (Operator op : ops) {
    if (op.prec != lprec) {
      lprec = op.prec;
      if (cops.size() > 0) {
        opgs.add(0, cops);
        cops = new ArrayList<Operator>();
      }
    }
    cops.add(op);
  }
  opgs.add(0, cops);
  ///for (ArrayList<Operator> cpo : opgs) {
  ///  println(cpo);
  ///}
}
String regexEscape (String str) {
  return str.replaceAll("([|()+*\\[\\]{}.^$?])", "\\\\$1");
}