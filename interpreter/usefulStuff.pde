String repeat (String tor, int count) {
  String res = "";
  for (int i = 0; i < count; i++) {
    res += tor;
  }
  return res;
}
String escape (String toEscape) {
  toEscape = toEscape.replace("\\", "\\\\");
  toEscape = toEscape.replace("\n", "\\n");
  toEscape = toEscape.replace("\"", "\\\"");
  return toEscape;
}
String arrToString (String[] arr) {
  String res = "[";
  for (String s : arr) {
    res+= "'"+escape(s)+"'";
    if (s != arr[arr.length-1]) res+= ", ";
  }
  res+= "]";
  return res;
}
String joins (Object[] os, String joiner) {
  String out = "";
  for (Object o : os) {
    if (out.length() > 0) out+= joiner;
    out+= o;
  }
  return out;
}
Node parametrize (Node n) {
  if (n.size()==1 && n.get(0).is(14) && n.get(0).iss(",")) {
    Node nn = new Node(n.type);
    for (int j = 0; j < n.get(0).size(); j+= 2) 
      nn.addChild(n.get(0).get(j));
    return nn;
  } else if (n.size() == 0 && !n.iss("")) {
    Node nn = new Node(1);
    nn.addChild(n);
    return nn;
  } else if (!n.is(1)) {
    Node nn = new Node(1);
    nn.addChild(n);
    return nn;
  } else return n;
}
//processing y u have multiline regex matching -_- wasted 30 minutes of debugging
static Pattern matchPattern(String regexp) {
  Pattern p = null;
  if (matchPatterns == null) {
    matchPatterns = new LinkedHashMap<String, Pattern>(16, 0.75f, true) {
      @Override
      protected boolean removeEldestEntry(Map.Entry<String, Pattern> eldest) {
        // Limit the number of match patterns at 10 most recently used
        return size() == 10;
      }
    };
  } else {
    p = matchPatterns.get(regexp);
  }
  if (p == null) {
    p = Pattern.compile(regexp, Pattern.DOTALL);
    matchPatterns.put(regexp, p);
  }
  return p;
}
String[] matchy (String str, String regexp) {
  matchPattern(regexp);
  return match(str, regexp);
}
boolean PO(){println("CALLED");return true;}
boolean PO(Object o){println("CALLED", o, o.getClass());return true;}