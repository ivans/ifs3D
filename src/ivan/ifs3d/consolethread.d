module ivan.ifs3d.consolethread;

import global = ivan.ifs3d.global;
import core.thread;
import std.conv : to;
import std.string;
import std.stdio : readln, writefln;
import core.stdc.time;
import core.stdc.stdio;

public class ConsoleThread: Thread {

	this() {
		super(&run);
	}

	private void run() {
		writefln("Starting console thread...");
		while(term != true) {
			string line = readln();
			writefln("Command is %s", line);
			string[] parts = line.split();
			if(parts.length == 2) {
				try {
					global.conf.setIntParam(cast(string) parts[0], to!(int)(parts[1]));
				} catch(Exception e) {
					writefln(e.msg);
				}
			}
			global.conf.printParams();
		}
	}

	//TODO D2 problem sa shared
	//synchronized 
	void terminate(bool term) {
		synchronized(this)
			this.term = term;
	}

	bool term = false;

}
