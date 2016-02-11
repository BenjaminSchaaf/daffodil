module dil.util.test;

import std.stdio;
import std.typecons;
import core.exception;

package struct Test {
    string target;
    string name;
    void function() testFn;
    string file;
    size_t line;
}

package Test[] tests;

template test(string name, void function() testFn, string file = __FILE__, size_t line = __LINE__) {
    alias test = test!("", name, testFn, file, line);
}
template test(alias target, string name, void function() testFn, string file = __FILE__, size_t line = __LINE__) {
    pragma(msg, file, ":", line, " test ", name);
    static this() {
        string tagetName;
        static if (__traits(compiles, target.stringof)) {
            tagetName = target.stringof;
        } else {
            tagetName = __traits(identifier, target);
        }
        tests ~= Test(tagetName, name, testFn, file, line);
    }
}

unittest {
    Tuple!(Test, AssertError)[] failed = [];

    foreach (test; tests) {
        try {
            writef("%s for %s ", test.name, test.target);
            test.testFn();
            writeln("SUCCESS");
        } catch(AssertError e) {
            writeln("FAILED");
            failed ~= tuple(test, e);
        }
    }

    foreach (fail; failed) {
        auto test = fail[0];
        auto e = fail[1];
        writeln();
        writefln("Failed: %s for %s", test.name, test.target);
        writefln("%s:%s", test.file, test.line);
        writefln("%s", e);
    }
}
