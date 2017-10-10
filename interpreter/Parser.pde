class Parser {
  String toParse = "";
  int ptr = 0;
  int tplen;//toParse length
  String cpe = "Unknown error";//current possible error
  Node startingNode;
  Exception up = null;
  Parser (String inp) {
    toParse = inp;
    tplen = toParse.length();
  }
  Node parse () {
    Node tokenized = tokenize(1);
    println("TOKENIZED: \n" + tokenized);
    startingNode = tokenized;
    return parse(tokenized);
  }
  Node tokenize (int gtype) {
    Node cll = new Node(gtype);
    String myRecord = "";
    int ptrStart = ptr;
    try {
      char cc = 0;
      while (ptr < tplen) {
        cc = toParse.charAt(ptr);
        ///println("char "+ptrStart+" "+ptr+": "+ cc);
        if (cc=='`' || cc=='\'' || cc=='"') {
          if (cc != '`' && toParse.charAt(ptr+1) == cc && (ptr+2>=toParse.length() || toParse.charAt(ptr+2) != cc)) {
            ptr+=2;
            cll.addChild(new Node(5, ""));
            continue;
          }
          char qt = cc;//quote type
          int qc = 1;//quote count
          cpe = "Code ends before quotes";
          //count how many quote string this is
          while (toParse.charAt(ptr+qc) == qt) qc++;
          String quotes = repeat(String.valueOf(qt), qc);
          ptr+= qc;
          cpe = "No ending quote of multiquote string found";
          int cqc = 0;//current quote count
          String string = "";
          String maybeAdd = "";
        strcharloop: 
          while (cqc < qc) {
            cc = toParse.charAt(ptr);
            ///println("STRING", qt, cqc+"/"+qc, cc, ptr);
            if (cc == '\\') {
              cqc = 0;
              string+= maybeAdd;
              maybeAdd = "";
              if (swr("\\\\"+quotes)) ptr++;
              string+= toParse.charAt(ptr);
            } else if (cc == qt) {
              cqc++;
              maybeAdd+= cc;
            } else {
              cqc = 0;
              string+= maybeAdd;
              maybeAdd = "";
              if (qt == '`') {
                for (String[] ct : codestringCode) {
                  if (sw(ct[0])) {
                    ptr+= ct[0].length();
                    string+= ct[0] + tokenize(2).content;
                    ptr++;
                    continue strcharloop;
                  }
                }
              }
              string+= cc;
            }
            ptr++;
          }
          cll.addChild(new Node(qt=='`'? 7 : 6, string));
        } else if (cc == '(') {
          ptr++;
          cll.addChild(tokenize(1));
          ptr++;
        } else if (cc == '{') {
          ptr++;
          cll.addChild(tokenize(2));
          ptr++;
        } else if (cc == '}' || cc == ')') {
          break;
        } else if (sw ("/*")) {
          cpe = "Unended multiline comment";
          while (!sw("*/")) ptr++;
          ptr+= 2;
        } else if (sw("//")) {
          cpe = "Unended comment";
          while (ptr < tplen && !is('\n')) ptr++;
          ptr++;
        }  else if (swr(operatorRegex) || cc=='@') {
          boolean anyOrder = false;
          if (cc=='@') {
            ptr++;
            anyOrder = true;
          }
          cpe = "Operator not found";
          String co = srm(operatorRegex);//current operator
          cll.addChild(new Node(13, co).setAnyOrder(anyOrder));
          ptr+= co.length();
        } else if (swr(literal)) {
          /*String lname = "";
           while (swr(literal)) {
           lname+= toParse.charAt(ptr);
           ptr++;
           }*/
          String lname = srm(literal+"+");
          ptr+= lname.length();
          cll.addChild(new Node(5, lname));
        } else if (swr(spacing)) {
          int spaceam = 0;
          boolean semicolon = false;
          while (ptr < tplen && swr(spacing)) {
            switch (toParse.charAt(ptr)) {
              case ' ':
                spaceam+= 1;
              break;
              case ';':
                spaceam+= 1000;
                semicolon = true;
              break;
              case '\n':
                spaceam+= 1000000;
              break;
              case '\t':
                spaceam+= 4;
              break;
            }
            
            ptr++;
          }
          cll.addChild(new Node(20, str(spaceam)));
          if (semicolon) cll.addChild(new Node(21));
        } else {
          cpe = "Invalid Character";
          throw up;
          //ptr++;
        }
      }
      myRecord = toParse.substring(constrain(ptrStart, 0, toParse.length()-1), constrain(ptr, 0, toParse.length()-1));
    }
    catch (Exception e) {
      myRecord = toParse.substring(constrain(ptrStart, 0, toParse.length()-1), constrain(ptr+10, 0, toParse.length()-1));
      println(cpe);
      println(myRecord);
      println(repeat(" ", ptr-ptrStart)+"^");
      e.printStackTrace();
    }
    //TODO is V required?
    //cll.content = myRecord;
    return cll;
  }
  Node parse (Node tp) {//if(true)return tp;
    ///int testmid = floor(random(1000));
    ///println(tp, testmid);
    
    ///println(startingNode);
    //delay(1000);
    //find spacings and parse parentheses
    int mostSpaces = 0;
    for (int i = 0; i < tp.size(); i++) {
      Node c = tp.get(i);
      if (c.type == 20) {
        if (int(c.content) > mostSpaces) mostSpaces = int(c.content);
      }
      if (c.is(1) || c.is(2)) {
        Node cp = parse(c);
        /*if (cp.is(3) && cp.size() > 0 && false) {
         cns.remove(cp.get(0));
         for (Node cc : cp.children) {
         cns.add(i, cc);
         i++;
         }
         i--;
         } else*/
        tp.set(i, cp);
      }
    }
    //group if there are spacings
    if (mostSpaces > 0) {
      Node cp = new Node(3);//current part
      Node co = new Node(tp.type);
      for (Node c : tp.children) {//int j = 0; j < tp.children.size(); j++
        //Node c = tp.children.get(j);
        if (c.type == 20 && int(c.content) == mostSpaces) {
          co.addChildren(parse(cp));
          cp = new Node(3);
        } else {
          cp.addChild(c);
        }
      }
      if (cp.size() > 0) co.addChildren(parse(cp));
      tp = co;
    }
    
    //function definitions (e.g. function(){}, function fact (a,b) {})
    for (int i = 0; i < tp.size()-2; i++) {
      if (tp.get(i).is(5) && tp.get(i).content.equals("function")) {
        if (i < tp.size()-3 && tp.get(i+1).is(5) && tp.get(i+2).is(1) && tp.get(i+3).is(object)) {
          Node funcObj = new Node(9);
          funcObj.addChild(tp.get(i+1));
          Node paramNames = tp.get(i+2);
          paramNames = parametrize(paramNames);
          funcObj.addChild(paramNames);
          funcObj.addChild(tp.get(i+3));
          tp.set(i, funcObj);
          tp.remove(i+1);
          tp.remove(i+1);
          tp.remove(i+1);
        } else if (tp.get(i+1).is(1) && tp.get(i+2).is(object)) {
          Node lambdaObj = new Node(11, "=>");
          Node paramNames = tp.get(i+1);
          //paramNames = parametrize(paramNames); this is done in _lambda_
          lambdaObj.addChild(paramNames);
          lambdaObj.addChild(tp.get(i+2));
          tp.set(i, lambdaObj);
          tp.remove(i+1);
          tp.remove(i+1);
        }
      }
    }
    
    
    //add parentheses as a parameter for a literal
    for (int i = 0; i < tp.size()-1; i++) {
      if (tp.get(i+1).is(1) && tp.get(i).is(new int[]{5, 4}) && tp.get(i).size()==0) {
        Node name = tp.get(i);
        Node contents = tp.get(i+1);
        tp.remove(i+1);
        if (contents.size() == 1 && contents.get(0).is(14) && contents.get(0).content.equals(",")) {
          contents = contents.get(0);
          Node ncontents = new Node(3);
          for (int j = 0; j < contents.size(); j+= 2) 
            ncontents.addChild(contents.get(j));
          contents = ncontents;
        }
        contents.type = 3;
        name.type = 4;
        name.addChildren(contents);//TODO check should contents be parsed?
        tp.set(i, name);
        i--;
      }
    }
    
    
    
    for (ArrayList<Operator> copg : opgs) {//current operator group
      Operator base = copg.get(0);
      int bf = base.fix;
      if (bf < 4) {
        boolean rtl = bf==3;
        testing = 0;
        for (int i = rtl? tp.size()-2 : 0; rtl? (i > 0) : (i < tp.size()); i+= rtl? -1 : 1) {
          Node c = tp.get(i);
          ctr++;
          if (c.is(13)) {
            for (Operator cop : copg) {//current operator
              bf = cop.fix;
              int baseType = 10 + bf - (rtl? 2 : 0);
              boolean takePrev = baseType > 10;
              boolean takeNext = rtl? true : baseType < 12;
              if (takePrev && i==0 || takeNext && i >= tp.size()-1) continue;
              if (c.content.equals(cop.repr)) {
                //println("OPP","i:"+i,"size:"+tp.size(), "tp:"+takePrev, "tn:"+takeNext,"rtl:"+rtl,"cop:{"+cop+"}", testing++, baseType);
                Node prev = takePrev? tp.get(i-1) : null;
                Node next = takeNext? tp.get(i+1) : null;
                if (takePrev && !prev.is(object)) continue;//dammit there is do null pointer access bc it is null iif takePrev is false in which case that consumes && .-.
                if (takeNext && !next.is(object)) continue;
                Node nop = new Node(baseType, cop.repr);//new operator
                if (takeNext) {
                  nop.addChild(next);
                  tp.remove(i+1);
                }
                tp.remove(i);
                if (takePrev) {
                  nop.addChild(0, prev);
                  tp.remove(i-1);
                  i--;
                }
                tp.addChild(i, nop);
              }
            }
          }
        }
      } else {
        if (bf == 4) {
          //String repr = base.repr;
          for (int i = 1; i < tp.size()-1; i++) {
            Node c = tp.get(i);
            Node start;
            if (c.is(13) && (start = tp.get(i-1)).is(object) && tp.get(i+1).is(object)) {
              for (Operator cop : copg) {
                if (c.isop(cop)) {
                  Node cn;
                  if (copg.size() == 1) cn = new Node(14, copg.get(0).repr);
                  else cn = new Node(14);
                  cn.addChild(start);
                  tp.remove(i-1);
                  Node next;
                  i--;
                  
                  while (i < tp.size()-1 && (c = tp.get(i)).is(13) && (next = tp.get(i+1)).is(object)) {
                    for (Operator cop2 : copg) {
                      if (c.isop(cop2)) {
                        cn.addChild(c);
                        cn.addChild(next);
                        tp.remove(i+1);
                        tp.remove(i);
                        break;
                      }
                    }
                  }
                  tp.addChild(i, cn);
                  break;
                }
              }
            }
            /*if (c.is(13) && c.content.equals(repr)) {
             Node prev = tp.get(i-1);
             Node next = tp.get(i+1);
             if (prev.is(object) && next.is(object)) {
             tp.remove(i+1);
             tp.remove(--i);
             //1 , == == c == d
             //    ^  
             Node nop = new Node(12, repr);
             nop.addChild(prev);
             nop.addChild(next);
             print(i < tp.size()-2);
             if (i < tp.size()-2) print(" "+ tp.get(i+1).is(13) , tp.get(i+1).content.equals(repr) , (next = tp.get(i+2)).is(object));
             println(" "+testmid);
             while (i < tp.size()-2 && (tp.get(i+1).is(13) && tp.get(i+1).content.equals(repr)) && (next = tp.get(i+2)).is(object)) {
             tp.remove(i+1);
             tp.remove(i+1);
             nop.addChild(next);
             }
             tp.set(i, nop);
             }
             }*/
          }
        }
      }
    }
    
    
    //create function calling of anything
    for (int i = 0; i < tp.size()-1; i++) {
      if (tp.get(i+1).is(object) && tp.get(i).is(new int[]{1,5})) {
        Node func = tp.get(i);
        Node params = tp.get(i+1);
        if (func.is(5)) {
          func.type = 4;
          func.addChildren(params);
          tp.set(i, func);
          tp.remove(i+1);
        } else {
          Node nf = new Node(4);
          nf.addChild(func);
          nf.addChild(params);
          tp.set(i, nf);
          tp.remove(i+1);
        }
      }
    }//*/
    //add any object as a parameter for a literal
    /*for (int i = 0; i < tp.size()-1; i++) {
      if (tp.get(i+1).is(object) && tp.get(i).is(new int[]{5, 1}) && tp.get(i).size()==0) {
        Node name = tp.get(i);
        Node contents = tp.get(i+1);
        tp.remove(i+1);
        if (contents.type == 1 || contents.type == 3) {
          if (contents.size() == 1) contents = contents.get(0);
        } else {
          Node ncontents = new Node(3);
          ncontents.addChild(contents);
          contents = ncontents;
        }
        if (contents.type == 14 && contents.content.equals(",")) {
          Node ncontents = new Node(3);
          for (int j = 0; j < contents.size(); j+= 2) 
            ncontents.addChild(contents.get(j));
          contents = ncontents;
        }
        if (contents.type != 1 && contents.type != 3) {
          Node ncontents = new Node(contents.type);
          ncontents.addChild(contents);
          contents = ncontents;
        }
        contents.type = 3;
        name.type = 4;
        name.addChildren(contents);//TODO check should contents be parsed? probably not
        tp.set(i, name);
        i--;
      }
    }//*/
    
    //println(tp, testmid, "DONE");
    if (tp.size() == 1 && tp.is(3)) return tp.get(0);
    return tp;
  }
  boolean sw (String str) {
    //println(ptr);
    if (ptr >= tplen) toParse.charAt(ptr);
    return toParse.substring(ptr).startsWith(str);
  }
  //starts with regex
  boolean swr (String str) {
    //throw indexOutOfBounds error the cheap way :p
    if (ptr >= tplen) toParse.charAt(ptr);
    return matchy(toParse.substring(ptr), "^("+str+")") != null;
  }
  //starting regex match
  String srm (String str) {
    if (ptr >= tplen) toParse.charAt(ptr);
    return matchy(toParse.substring(ptr), "^("+str+")")[0];
  }
  boolean is (char chr) {
    return toParse.charAt(ptr) == chr;
  }
}