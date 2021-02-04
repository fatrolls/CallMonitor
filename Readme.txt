CallMon

To test the CallMon library, load CallMon.dsw into Visual C++ 6.0,
and build the Test project (Win32 Debug configuration).  Alternatively,
from the command line run "build.bat". 

Run Test.exe (in the Debug subdirectory) either from the IDE or the command
line. It takes two arguments, the number of threads to use (0-63) and the
number of exceptions to throw (0 - number of threads).  
"Test 0 0" runs a simple test which traces a couple of function 
calls with no multithreading and no exceptions.  "Test 20 10" runs
20 threads simultaneously, the first 10 of which will throw 
exceptions.  (The trace output for the multithreaded test is 
unreadable since the outputs are interleaved.  Normally outputs
from multiple threads would be tagged or redirected to different
files.)

The current version of CallMon has been tested with VC5 and VC6,
Professional and Enterprise Editions.  It has not been tested with
the Standard Edition, so there is a possibility that the /Gh
compiler flag it relies on will not work with that edition.

The CallMon::getFuncInfo method relies on the IMAGEHLP library,
which is available in Windows NT 3.51 and higher and Windows 98,
but which requires installation for Windows 95.  If you are running
Windows 95 and need to get the additional information this function
provides, it should be available as a redistributable library from
Microsoft.  The CallMon library will work without IMAGEHLP, but
the trace functions will not be able to report module or function
names.

The IMAGEHLP functions rely on having COFF format debug information
available in the modules being instrumented.  Use the /debugtype:both
linker flag to set this; the Test project is an example.

This code differs slightly from the code published in CUJ. It includes
the option to use the Pentium RDTSC instruction for timing instead
of the QueryPerformanceCounter call.  If you are building for a
non-Pentium target, or want to disable the RDTSC code for any other
reason, comment out the "#define PENTIUM" line at the top of
CallMon.h.

If you have questions, please e-mail me at jpanzer@acm.org.

John Panzer
