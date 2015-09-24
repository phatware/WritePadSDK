cd %1
del WritePadReco.dll
del Windows_CPPLayer.dll
copy "..\Debug\Windows_CPPLayer.dll" .
copy "..\..\lib-windows\Win32\WritePadReco.dll" .
