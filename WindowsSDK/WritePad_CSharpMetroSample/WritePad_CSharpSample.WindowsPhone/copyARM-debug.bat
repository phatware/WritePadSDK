cd %1
del WritePadReco.dll
del WinRT_CPPLayer.dll
copy "..\Debug\wp-ARM\WinRT_CPPLayer.dll" .
copy "..\..\lib-windows-phone\ARM\WritePadReco.dll" .