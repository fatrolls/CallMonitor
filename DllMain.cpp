// Listing 2: Sample DllMain
#include <windows.h>
#include "CallMon.h"
// Include derived class header here

BOOL WINAPI DllMain(
    HINSTANCE hinstDLL,  
    DWORD fdwReason,     
    LPVOID lpvReserved   
    )
{
    CallMonitor::TICKS frequency=0;
    switch (fdwReason)
    {
    case DLL_PROCESS_ATTACH: // fall through
        CallMonitor::queryTickFreq(&frequency); // Initialize frequency ratio
    case DLL_THREAD_ATTACH:
        // Create instance of derived class below
        CallMonitor::threadAttach(new CallMonitor);
        break;
    case DLL_THREAD_DETACH:  // fall through
    case DLL_PROCESS_DETACH:
        CallMonitor::threadDetach();
        break;
    }
    return TRUE;
}
//End of file