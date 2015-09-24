cd %1
del WritePadReco.dll
del Windows_CPPLayer.dll
copy "..\x64\Release\Windows_CPPLayer.dll" .
copy "..\..\lib-windows\x64\WritePadReco.dll" .

