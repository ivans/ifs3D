module ivan.ifs3d.consolethread;

import global = ivan.ifs3d.global;
import core.thread;
import std.string;
import std.stdio;
import std.c.time;
import std.c.stdio;
import std.cstream;

public class ConsoleThread : Thread {

  public int run() {
    global.o.writefln("Starting console thread...");
    while(term != true) {
      char[] line = din.readLine();
      global.o.writefln("Command is %s", line);
      char [][] parts = line.split();
      if(parts.length == 2)
      {
        try {
          global.conf.setIntParam(cast(string)parts[0], std.conv.to!(int)(parts[1]));
        }
        catch(Exception e) {
          global.o.writefln(e.msg);
        }
      }
      global.conf.printParams(global.o);
    }
    return 1;
  }

  //TODO D2 problem sa shared
  //synchronized 
  void terminate(bool term) {
    this.term = term;
    global.o.writefln("Terminating console thread...");
  }

  bool term = false;

}