cd %1
del WritePadReco.dll
del WinRT_CPPLayer.dll
copy "..\Debug\Win32\WinRT_CPPLayer.dll" .
copy "..\..\lib-windows-metro\Win32\WritePadReco.dll" .

