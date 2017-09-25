import java.math.RoundingMode;
import java.math.BigDecimal;
import java.util.Map;
import java.util.regex.Pattern;
import java.util.LinkedHashMap;
import java.util.Comparator;
import java.util.Collections;
//import java.util.regex.*;
int ctr = 0;
int testing = 0;
void setup() {
  defsSetup();
  String program = "``$(print(`Calculate: $(`2+2` + ` = $(2+int(`$(1+1)`))!`)`)) == `12*2`, \\\\\\`` ``;print(\"hello, \"+   (1 + 2*3)  +  4+5 * 6  +  (9 + 8 - 7 + 6 - five - 4 + 3 + 2 - 1)  +  4^3^2  +  4*3*2)";
       //change the file name here to choose different programs
  program = join(loadStrings("primes.jcn"), '\n');
  
  
  
  
  ///println(operatorRegex);
  //BigDecimal b = new BigDecimal("0.000000000000000000000000003");
  //println(b.scale(),b.precision());
  //           b = new BigDecimal("7128372819738921789372189792.00000");
  //println(b.scale(),b.precision());
  //if(1>0)throw null;
  //program = "{fact(a@+1)} = {fact(a)*(a+1)}";
  //program = "```calculate: `2+2\\(`` = \\(2+2)`!``) ```";
  //program = "2+2 * 2  + 2+2*2   +``Math: `2+2` = $(2/*calculates math!*/\n+//line comment\n2)``+''";
  //program = "1+//comment\n2;";
  //program = "print(2+2 * 2  + 2+2*2   +``Math: `2+2` = $(2+2)``+'')";
  //program = "print(\"Hello, World!\" if 1==2 else \"Goodbye \" + \"Cruel World!\")";
  //program = "for (x : range(6))";
  //program = "for (x? f : z : a? b : c)";
  //program = "var i = 0; var j = 2\nwhile i<10{\n  i++; j^=i\n}\nprintln j";
  //program = "println('Hello, World!')\nprintln '2+2 = ' + 2+2\nprint(`4^4`,\"= \")\nprintln(4^4)";
  //program = "if args.size ~> 0 local i=0 else i=1";
  //println(program);
  //printArray(match("123\nhello", "^hel"));
  //program = "print'Hello, World!'";
  //program = "o = 'no'\nf = a => o = 'yes'\nprintln(o)\nf()\nprintln(o)";
  try {
    new Interpreter(program).run();
  } catch (Exception e) {
    e.printStackTrace();
  } catch (Error e) {
    e.printStackTrace();
  }
  exit();
}