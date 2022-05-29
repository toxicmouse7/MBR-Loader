PrintString proto stdcall stringPtr: ptr word
PrintSymbol proto stdcall symbol: byte
PrintBackspace proto stdcall
hex proto stdcall param: byte, number: dword
hexb proto stdcall number: dword
hexw proto stdcall number: dword
hexd proto stdcall number: dword
decimal proto stdcall number: dword
StringToWord proto stdcall stringAddress: ptr byte
StringLength proto stdcall stringAddress: ptr byte
ReadNumber proto stdcall buffer: ptr byte