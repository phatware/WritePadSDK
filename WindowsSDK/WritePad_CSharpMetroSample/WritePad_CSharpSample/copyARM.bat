cd %1
del WritePadReco.dll
del WinRT_CPPLayer.dll
copy "..\Release\ARM\WinRT_CPPLayer.dll" .
copy "..\..\lib-windows-metro\ARM\WritePadReco.dll" .