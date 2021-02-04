# Microsoft Developer Studio Generated NMAKE File, Based on CallMon.dsp
!IF "$(CFG)" == ""
CFG=CallMon - Win32 Debug
!MESSAGE No configuration specified. Defaulting to CallMon - Win32 Debug.
!ENDIF 

!IF "$(CFG)" != "CallMon - Win32 Release" && "$(CFG)" != "CallMon - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "CallMon.mak" CFG="CallMon - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "CallMon - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "CallMon - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 
!ERROR An invalid configuration is specified.
!ENDIF 

!IF "$(OS)" == "Windows_NT"
NULL=
!ELSE 
NULL=nul
!ENDIF 

CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "CallMon - Win32 Release"

OUTDIR=.\Release
INTDIR=.\Release
# Begin Custom Macros
OutDir=.\Release
# End Custom Macros

ALL : "$(OUTDIR)\CallMon.dll"


CLEAN :
	-@erase "$(INTDIR)\CallMon.obj"
	-@erase "$(INTDIR)\DllMain.obj"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(OUTDIR)\CallMon.dll"
	-@erase "$(OUTDIR)\CallMon.exp"
	-@erase "$(OUTDIR)\CallMon.lib"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP_PROJ=/nologo /MD /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /Fp"$(INTDIR)\CallMon.pch" /YX /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 
MTL_PROJ=/nologo /D "NDEBUG" /mktyplib203 /o "NUL" /win32 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\CallMon.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=imagehlp.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /incremental:no /pdb:"$(OUTDIR)\CallMon.pdb" /machine:I386 /out:"$(OUTDIR)\CallMon.dll" /implib:"$(OUTDIR)\CallMon.lib" 
LINK32_OBJS= \
	"$(INTDIR)\CallMon.obj" \
	"$(INTDIR)\DllMain.obj"

"$(OUTDIR)\CallMon.dll" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "CallMon - Win32 Debug"

OUTDIR=.\Debug
INTDIR=.\Debug
# Begin Custom Macros
OutDir=.\Debug
# End Custom Macros

ALL : "$(OUTDIR)\CallMon.dll"


CLEAN :
	-@erase "$(INTDIR)\CallMon.obj"
	-@erase "$(INTDIR)\DllMain.obj"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(INTDIR)\vc60.pdb"
	-@erase "$(OUTDIR)\CallMon.dll"
	-@erase "$(OUTDIR)\CallMon.exp"
	-@erase "$(OUTDIR)\CallMon.ilk"
	-@erase "$(OUTDIR)\CallMon.lib"
	-@erase "$(OUTDIR)\CallMon.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP_PROJ=/nologo /MDd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /Fp"$(INTDIR)\CallMon.pch" /YX /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 
MTL_PROJ=/nologo /D "_DEBUG" /mktyplib203 /o "NUL" /win32 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\CallMon.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=imagehlp.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /incremental:yes /pdb:"$(OUTDIR)\CallMon.pdb" /debug /machine:I386 /out:"$(OUTDIR)\CallMon.dll" /implib:"$(OUTDIR)\CallMon.lib" /pdbtype:sept 
LINK32_OBJS= \
	"$(INTDIR)\CallMon.obj" \
	"$(INTDIR)\DllMain.obj"

"$(OUTDIR)\CallMon.dll" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ENDIF 

.c{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.c{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<


!IF "$(NO_EXTERNAL_DEPS)" != "1"
!IF EXISTS("CallMon.dep")
!INCLUDE "CallMon.dep"
!ELSE 
!MESSAGE Warning: cannot find "CallMon.dep"
!ENDIF 
!ENDIF 


!IF "$(CFG)" == "CallMon - Win32 Release" || "$(CFG)" == "CallMon - Win32 Debug"
SOURCE=.\CallMon.cpp

"$(INTDIR)\CallMon.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\DllMain.cpp

"$(INTDIR)\DllMain.obj" : $(SOURCE) "$(INTDIR)"



!ENDIF 

