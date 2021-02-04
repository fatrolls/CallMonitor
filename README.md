# Automatic Code Instrumentation by John Panzer

Very good tool called CallMonitor which can log all calls for all functions in your program to see where it crashes.

Made in January 1999 still works in Visual Studio 2019

Profilers and coverage analyzers are useful tools that can help provide information about bottlenecks and control flow. Occasionally they can be critically important to a successful project. Although many development environments provide these tools, they lack the functionality necessary to solve all control-flow and timing problems. Commercial products can be costly and may not be customizable. Faced with problems like these, I created the CallMonitor utility framework. CallMonitor traces a client program's function calls and provides simple hooks for building more sophisticated tools.

The CallMonitor utility is implemented as a support DLL. It requires no client-code changes, just a recompile and relink. It can instrument only portions of a program if desired. It is thread safe and traces exceptions cleanly.

I used CallMonitor to implement a hierarchical call profiler, which pinpointed several bottlenecks in a large project. Other possible applications include a trace utility, a coverage analyzer, and an error test-case exerciser. Tools can extend CallMonitor by inheriting from class CallMonitor (Listing 1, callmon.h).

CallMonitor does have a couple of limitations. The mechanism it uses is limited to function-call tracing and cannot be used to trace the execution of individual statements. It makes use of a Microsoft-specific compiler switch to help insert instrumentation calls, so it is currently limited to Visual C++. CallMonitor has been tested under Visual C++ versions 5.0 and 6.0, Professional and Enterprise editions.

# How to Instrument Procedure Calls
A function profiler needs to know when each function call begins and ends. The Microsoft VC++ compiler provides half of the solution: the semi-documented /Gh compile flag makes the compiler insert a hidden call to a _penter function at the start of each client function. (The Win32 SDK Call Attributed Profiler uses this method as well.) Although the source code remains unchanged, the object code includes the hidden call as the first instruction in the function. For example, the function
void client() {}
generates the following assembly code on the Intel platform:
_client   PROC NEAR
call __penter
push ebp
mov  ebp, esp
pop  ebp
ret  0
The next step is to provide a _penter function in a support library and link it in. The prototype for _penter is:
extern "C" void _penter();
(see Figure 1, CallMonitor.cpp). Once inside the _penter function, CallMonitor needs to know the address of the client function that called it. The _penter function can deduce this with a small amount of inline assembly. It loads the current frame pointer, stored in the Intel CPU's ebp register, into a local variable. This gives access to the frame record, which provides the return address for the current _penter call. Subtracting five bytes yields the address of the client function. Of course, all of this is nonportable and is processor and compiler dependent. Fortunately, the nonportable code can be isolated to a handful of small functions.
The CallMonitor maintains a separate stack, called the shadow stack, where it records information pertaining to the client function call. This stack is a member of the CallMonitor class, callInfoStack, and is implemented as a vector of CallInfo objects (described later). The shadow stack stores the client function's address and the time of entry to the function. It also stores the client function's return address, which will eventually be used to return control from CallMonitor to the client function's caller.

Given the client function address, the support library can record the calls made to each function. This is enough for a coverage analyzer, but a profiler needs to know when the function ends as well. Unfortunately, the compiler doesn't generate a call to a _pexit function parallel to _penter. But given a little stack manipulation, it's possible to trick the client function into returning to a _pexit thunk instead of to its caller. The _pexit thunk calls instrumentation code and then returns to the original address (cached by _penter).

# Manipulating the Program Stack
Within the _penter function, the ebp register points at the current stack frame. _penter first moves the contents of ebp into a local variable, framePtr, for easier access (see Figure 1). Starting at framePtr, the stack contains three useful pieces of information:
framePtr[0]    Parent stack frame pointer
framePtr[1]    Return address of _penter function call
framePtr[2]    Return address of client function
The return address for the client is stored in framePtr[2]. Changing framePtr[2] to the address of a support library function (_pexitThunk, Figure 1) will make the client return to that function instead of to its caller. This gives the support library the needed hook to record the client function exit.
Since _pexitThunk gets control through a ret instruction instead of a call, it can't use a normal return sequence. The thunk first pushes a placeholder null value on the stack. The eax register contains the client function's return value, so the thunk saves this value temporarily by pushing eax onto the stack. Finally, the thunk routine calls a normal _pexit function to complete the exit processing. When _pexit returns, the thunk restores the eax register value and returns.

The _pexit function uses its frame pointer to find the address of the placeholder pushed onto the stack by _pexitThunk. It passes the address of this word to the exitProcedure method, which restores the client function's original return address from information stored in the CallMonitor object (see Figure 2, callmon.cpp). When _pexitThunk eventually returns, it pops this address from the program stack.

# Tracing Exceptions
The code for exitProcedure is complicated by client exceptions. When a function exits because of an exception, it does not return normally, so _pexitThunk never gets control. Usually, the exception is eventually handled by a higher-level function. When that function returns, it will be redirected through _pexitThunk. If there is no way of synchronizing the program stack with the shadow stack maintained by the support library, the code will insert the wrong return address and most likely crash the program.
In order to deal with this, exitProcedure doesn't just pop the top of the shadow stack. It walks the shadow stack looking for a record whose frame pointer matches the frame pointer on the program stack. Only when it finds a matching frame pointer does it restore the corresponding return address. This recovery scheme may fail under some unlikely circumstances (by incorrectly matching frame pointers). This has not been a problem in practice.

# The CallMonitor Class
The job of a CallMonitor object is to monitor and measure calls for a given thread. Each thread in the client process automatically gets its own CallMonitor object. This occurs when the CallMonitor::threadAttach function is executed (see Listing 2, dllmain.cpp).
Upon entry to a client function, control passes to the _penter function, which in turn calls the CallMonitor::enterProcedure function. Within this function, CallMonitor gathers information and performs housekeeping on its internal data structures and then calls function logEntry. The CallInfo structure passed into logEntry contains two useful pieces of information: funcAddr is the address of the client function, and entryTime is the approximate time the client function was called. (Times are measured in ticks, and are stored in variables of type TICKS. Both ticks and TICKS are platform-dependent entities.) Typically, not much needs to be done within method logEntry. The default implementation writes the information to stdout, which can be useful for testing.

The logExit function is called in two situations. Either a client function has returned normally, in which case normalRet is true, or the function exited via a client exception. In either case, for each logEntry, there is always a corresponding logExit. The CallInfo structure passed into logExit contains additional timing information. startTime contains the approximate time at which the body of the procedure began execution; endTime contains the approximate time at which the body finished execution. The elapsed time spent within the function and its children is (endTime-startTime).

CallMonitor's callInfoStack member contains the shadow call records, and is accessible to derived classes.

CallMonitor provides some useful static utility methods. threadObj returns a reference to the CallMonitor object for the current thread. getFuncInfo retrieves the name of a function from debugging information, given its address. This is useful for reporting statistics. queryTicks retrieves the value of a platform-dependent timer. queryTickFrequency retrieves the number of ticks per second for the current platform.

# Using CallMonitor
The most common way to use CallMonitor is to extend it via inheritance. To extend CallMonitor, create a derived class and instantiate objects of that class inside DllMain. In the derived class, override the logEntry and logExit methods.
To use CallMonitor as the basis for a new tool, first create a DLL to contain a class derived from CallMonitor. Within the DllMain procedure, create instances of the derived class and register them with threadAttach (see Listing 2). Include CallMonitor.cpp (Figure 1) in the DLL and build normally.

To use the DLL with a client program, modify the client program's build procedure to include the /Gh compile flag and to link with the DLL's import library. Then rebuild the client and run it normally. The client can consist of an executable and any number of related DLLs, either implicitly or dynamically loaded. (The latter situation is one where the built-in Visual C++ profiler falls short.)

# Applications
The most straightforward application of CallMonitor is a trace utility. The default implementations of logEntry and logExit already print a generic trace to the console. Additional useful features would be the ability to separate the output from different threads, display output in a graphical UI, or filter output based on depth, function address, or global flags.
## A Coverage Analyzer
By keeping a map of function addresses vs. call counts, it is simple to create a logEntry method that tracks the number of times each function was called. In combination with a .MAP file or by using IMAGEHLP functions, it would not be difficult to create a table of all available functions and then a report showing which functions were called and which weren't.
## An Error Simulator
Although a large percentage of production code is devoted to error handling, testing this code through black-box techniques can be difficult. Modifying code to insert special error conditions is a possibility [1], but does require modifying source code. The CallMonitor library provides a way to induce simulated errors into a program as part of a test suite.
Within logEntry and logExit methods, the exerciser can throw any client exception to simulate error conditions. By modifying the _pexitThunk code to pass the address of the client return value, the logExit method could also modify return values from selected functions to simulate errors. The utility could read a configuration file containing a table of functions and exceptions to throw when encountered, and then trigger the exceptions when necessary.

# A Call Time Profiler
A profiler needs to track the time spent within the body of each client function. It also needs to be able to differentiate between time spent in a function and time spent in the function's children. The CallMonitor framework provides the timing information needed for these tasks. The basic strategy is as follows.
In the logExit method, the profiler calculates the elapsed time as (ci.endTime-ci.startTime). It adds this elapsed time to a running total for the current function, ci.funcAddr. This enables the profiler to track the total amount of time spent in each client function overall. The profiler also needs to adjust times for the CallMonitor entry and exit overhead. The overhead of the CallMonitor entry code can be estimated by (ci.startTime-ci.entryTime). The overhead of the exit code is harder to estimate accurately, since part of the overhead of the exit code is the calculation and storage of the overhead itself. This means that a significant part of the overhead can't be measured directly. The profiler can get around this by using the overhead of the previous logExit call as an estimate for the current call.

The profiler needs to keep track of how much of each function's elapsed time is spent in its children, so that it can report both the overall time and also the time spent within the function itself. It can track this with an additional counter, childTimes, associated with each function. The parent address for the current function can be found on the callInfoStack.

Finally, the profiler needs to adjust all times for the overhead that instrumentation introduces into the program times. This can be a major source of error for small, frequently called functions. If the profiler is not calibrated correctly, these functions can appear to take orders of magnitude more time than they actually do. Since elapsed times also include the overhead for all children, calculating the correct adjustments can be quite tricky.

Of course, it helps to get the most accurate clock available. The Windows API function QueryPerformanceCounter accesses a moderately high-resolution timer. However, if CallMonitor is running on a Pentium processor, there is a much better alternative available. The RDTSC assembly instruction accesses a 64-bit cycle counter built into the chip [2]. The portable version of CallMonitor uses QueryPerformanceCounter, but the Pentium-specific version uses RDTSC to implement queryTicks.

When profiling a multithreaded program, function times will include time spent in other threads. This may be a problem or an advantage, depending on what is being profiled.

# Hierarchical Profiling
Although recording the total time spent within each function is useful, it may not provide all the necessary information. For example, it might not be useful to know that 30% of the program's time is spent in an optimized FastStrCpy function, but it could be helpful to see which functions call it heavily. Hierarchical profilers provide this. They display children and parents for each function, along with times and call counts in the context of that function.
Although the profiler can collect this information at run time, storing it is a problem. To keep track separately of all generations of descendants of a given call would be too slow for real-world programs. Fortunately, many of the benefits of a hierarchical profiler can be realized by storing only one additional level of information with each function record. By keeping track of the call times for each function's immediate children, the code provides a good picture of which children are taking the most time within that function. Drilling down to that child function, then, gives a picture of that child's average behavior.

Given the tables of function statistics, it is fairly simple to write out a basic report listing functions in order of total time. But it can be much more effective to see hierarchical-profiling information as a tree or graph. Some commercial products have extensive UI support for this, displaying a graph of function calls and allowing the user to simulate the effects of optimization. Lacking the time to create such a UI, I found that a simple HTML report was a great way to present this information. The report generator took only a short time to develop.

The HTML report displays each function in its own section. The children of each function appear in a table, along with the child times and call counts. Since each child function name is a hyperlink, the user can drill down into the most expensive child and see where it typically spends its time. Figure 3 shows the general layout of such a report.

When profiling, it's best to take measured times with a grain of salt. All profilers have measurement error, and the act of measurement affects performance as well. Profiling can impact processor cache hits, thread synchronization, and paging. The best approach is to profile using a modified release-mode build, with small, frequently called functions inlined. Use the profiler to identify likely candidates for optimization, and check the effects with the profiler disabled.

# Conclusion
The CallMonitor class provides an extensible way to monitor and measure procedure calls within a client program. It is a customizable and extensible framework. It is currently the basis for a hierarchical call profiler and can be used for other tools as well. o
# References
[1] Dave Pomerantz. "Testing Error Handlers by Simulating Errors." C/C++ Users Journal, June 1998.
[2] Mark Russinovich. "Performance Instrumenting Device Drivers." http://www.sysinternals.com/sysperf.htm.

John Panzer is a developer with Computer Associates in Sarasota, FL. He has nine years of experience in software development, specializing in C++, Windows, graphical interfaces, and software tools. John has an MS in Computer and Information Sciences from UC Santa Cruz. He can be reached at jpanzer@acm.org.
