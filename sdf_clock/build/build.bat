@echo off
if not defined DevEnvDir (
  call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat" x86_amd64
)

set "project=SdfClock"
set "DN_EXAMPLES_DIR=..\.."
set "PROJECT_DIR=%DN_EXAMPLES_DIR%\sdf_clock"
set "SOURCE_DIR=%PROJECT_DIR%\source"
set "THIRD_PARTY=%DN_EXAMPLES_DIR%\thirdparty"
set "DN=%THIRD_PARTY%\doublenickel"
set "DN_EXTERNAL=%THIRD_PARTY%\doublenickel\external\include"
set "DN_IMGUI=%THIRD_PARTY%\doublenickel\external\include\imgui"
set "DN_FREETYPE=%THIRD_PARTY%\doublenickel\external\include\freetype"
set "DN_LIB=%THIRD_PARTY%\doublenickel\external\lib\debug"


@echo on
mkdir intermediate
copy "%THIRD_PARTY%\doublenickel\external\lib\debug\steam_api64.dll" .

@echo on
cl.exe ^
/Zi /Od /JMC ^
/Fe%project%.exe /Fo.\intermediate\ /Fd.\intermediate\ ^
%SOURCE_DIR%\main.cpp ^
/I%DN% /I%DN_EXTERNAL% /I%DN_IMGUI% /I%DN_FREETYPE% ^
/MDd ^
/std:c++20 ^
/Zc:wchar_t /Zc:forScope /Zc:inline ^
/EHa ^
/W3 /wd"4530" /wd"4201" /wd"4577" /wd"4310" /wd"4624" /wd"4099" /wd"4068" /wd"4267" /wd"4244" /wd"4018" ^
/D "DN_EDITOR" /D "_CRT_SECURE_NO_WARNINGS" /D "_SILENCE_CXX17_ALL_DEPRECATION_WARNINGS" ^
/link /LIBPATH:%DN_LIB% /DEBUG:FULL /MACHINE:X64 /NOLOGO /SUBSYSTEM:CONSOLE /INCREMENTAL:NO /NOIMPLIB /NOEXP /PDB:.\intermediate\ ^
"freetype-2.10.4-windows-x64.lib" "glfw-3.3.8-windows-x64.lib" "luajit-2.1.0.3-windows-x64.lib" "steam_api64.lib" "user32.lib" "opengl32.lib" "gdi32.lib" "Shell32.lib" "Kernel32.lib" "Advapi32.lib" "Ole32.lib" "OleAut32.lib" 

pause
