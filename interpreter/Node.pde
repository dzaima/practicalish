class Node {
  int type;
  boolean anyOrder = false;
  /*
    types:
   0  - unknown
   1  - group (e.g. parentheses)
   2  - function repr (e.g. {a+b})      2 * 2*2
   3  - order of operations group (e.g. ^   ^^^)
   4  - function call (e.g. print "Hello, World!", fact(5))
   
   5  - literal (e.g. pi, 628)
   6  - string (e.g. "Hello, World!")
   7  - codestring (e.g. `2+2 = $(2+`$()`)`)
   8  - array definition (e.g. [3 -14], (7, 22))
   9  - function definition (e.g. function f (a,b) {return a+b})
   
   10 - prefix operator (e.g. ~, !, -)
   11 - infix operator, LTR & RTL (e.g. ^, !, +=)
   12 - postfix operator (e.g. !, [4], [1:-1:2] (that'd be the same as in python))
   13 - unknown operator (e.g. |, ^, +, !)
   14 - N-ary operator (e.g. 9 > b > 2, `,`, a? b : c)
   
   
   20 - spacing
   21 - semicolon
   */
  ArrayList<Node> children = new ArrayList<Node>();
  String content = "";
  Node (int t) {
    type = t;
  }
  Node (int t, String c) {
    type = t;
    content = c;
  }
  Node setAnyOrder (boolean ao) {
    anyOrder = ao;
    return this;
  }
  void addChild (Node n) {
    children.add(n);
  }
  void set (int pos, Node n) {
    children.set(pos, n);
  }
  void addChildren (Node n) {
    if (n.type==3 && n.size() > 0)
      for (Node c : n.children) addChild(c);
    else children.add(n);
  }
  void addChild (int pos, Node n) {
    children.add(pos, n);
  }
  String toString () {
    if (size() == 0) return "N{"+ type +" _"+ content +"_}"; 
    return toString(1);
  }
  String toString (int lvls) {
    String out = "";
    String prepend = "";
    for (int i = 0; i < lvls-1; i++) prepend+= "| ";
    out+= prepend + "|-" + type + (anyOrder? ": @_" : ": _") + content + "_\n";
    for (Node child : children) {
      out+= child.toString(lvls+1);
    }
    return out;
  }
  String oneline() {
    //if(1==1)return "nc";
    String res = "("+type;
    if (content != null) res+= " '"+content+"'";
    if (size() > 0) {
      res+= ":[";
      for (Node child : children) res+= (res.endsWith(")")? ", " : "") + child.oneline();
      res+= "]";
    }
    res+= ")";
    return res;
  }
  int size () {
    return children.size();
  }
  Node get (int pos) {
    //new Exception().printStackTrace();
    return children.get(pos);
  }
  void remove (int pos) {
    children.remove(pos);
  }
  boolean is (int t) {
    return type == t;
  }
  boolean is (int[] ts) {
    for (int c : ts) {
      if (type == c) return true;
    }
    return false;
  }
  boolean iss (String t) {
    return content.equals(t);
  }
  boolean isop (Operator op) {
    return content.equals(op.repr);
  }
}