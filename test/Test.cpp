// Test driver for CallMon

#include <windows.h>
#include <iostream>

using namespace std;

void child2(bool doThrow)
{
    Sleep(5);
    if (doThrow) throw "random exception";
}

void child1(bool doThrow)
{
    child2(false);
    child2(doThrow);
}

// Waits a bit, then calls a child function
// that might throw an exception
DWORD WINAPI threadFunc(LPVOID param)
{
    Sleep(1);
    try {
        child1(param ? true : false);
    } catch (char *) {
        child1(false);
    }
    return 0;
}

// Starts argv[1] threads running, of which argv[2] throw
// exceptions.
void main(int argc,char *argv[])
{
    if (argc!=3)
    {
        cout << "Usage: " << argv[0] << " <number of threads, or 0> <number of exceptions>" << endl;
        cout << "  Pass 0 for number of threads for simple nonthreaded test" << endl;
        cout << "  Pass the number of threads which should throw exceptions as the second arg" << endl;
        cout << "  Note: The test output for the multithreaded case gives " << endl;
        cout << "        nearly unreadable output." << endl;
        return;
    }
    const int MAX_THREADS=MAXIMUM_WAIT_OBJECTS;
    DWORD id;
    HANDLE th[MAX_THREADS];
    int numThreads = atol(argv[1]);
    int numExc = atol(argv[2]);
    if (numThreads == 0)
    {
        threadFunc((void*)(numExc));
    }
    else
    {
        for(int i=0;i<numThreads;i++)
        {
            void * param= (void*)(i < numExc ? 1 : 0);
            th[i] = CreateThread(NULL,0,threadFunc,param,0,&id);
        }
        WaitForMultipleObjects(numThreads,th,TRUE,50000);
        for(i=0;i<numThreads;i++)
        {
            CloseHandle(th[i]);
        }
    }
}
