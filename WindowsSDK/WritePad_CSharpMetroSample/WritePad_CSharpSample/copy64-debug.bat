cd %1
del WritePadReco.dll
del WinRT_CPPLayer.dll
copy "..\Debug\x64\WinRT_CPPLayer.dll" .
copy "..\..\lib-windows-metro\x64\WritePadReco.dll" .