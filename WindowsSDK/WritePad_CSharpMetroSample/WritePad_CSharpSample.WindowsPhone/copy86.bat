cd %1
del WritePadReco.dll
del WinRT_CPPLayer.dll
copy "..\Release\wp-Win32\WinRT_CPPLayer.dll" .
copy "..\..\lib-windows-phone\Win32\WritePadReco.dll" .

