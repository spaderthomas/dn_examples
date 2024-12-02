@echo off
set project=SdfClock

@echo on
mkdir intermediate
copy ..\..\thirdparty\doublenickel\external\lib\debug\steam_api64.dll .

@echo on
cl.exe ^
/Zi /Od /JMC ^
/Fe%project%.exe /Fo.\intermediate\ /Fd.\intermediate\ ^
..\source\main.cpp ^
/I..\..\thirdparty\doublenickel\ /I..\..\thirdparty\doublenickel\external\include\ /I..\..\thirdparty\doublenickel\external\include\imgui\ /I..\..\thirdparty\doublenickel\external\include\freetype\ ^
/MDd ^
/std:c++20 ^
/Zc:wchar_t /Zc:forScope /Zc:inline ^
/EHa ^
/W3 /wd"4530" /wd"4201" /wd"4577" /wd"4310" /wd"4624" /wd"4099" /wd"4068" /wd"4267" /wd"4244" /wd"4018" ^
/D "FM_DEBUG" /D "_CRT_SECURE_NO_WARNINGS" /D "_SILENCE_CXX17_ALL_DEPRECATION_WARNINGS" ^
/link /LIBPATH:"../../thirdparty/doublenickel/external/lib/debug" /DEBUG:FULL /MACHINE:X64 /NOLOGO /SUBSYSTEM:CONSOLE /INCREMENTAL:NO /NOIMPLIB /NOEXP /PDB:.\intermediate\ ^
"freetype-2.10.4-windows-x64.lib" "glfw-3.3.8-windows-x64.lib" "luajit-2.1.0.3-windows-x64.lib" "steam_api64.lib" "user32.lib" "opengl32.lib" "gdi32.lib" "Shell32.lib" "Kernel32.lib" "Advapi32.lib" "Ole32.lib" "OleAut32.lib" 

@echo off
if %errorlevel% neq 0 (
    pause
)