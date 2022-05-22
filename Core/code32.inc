int_stub proto
int_EOI proto
InitPageTableEntry proto baseTable:dword, indexEntry:dword, address:dword, U_S:dword, R_W:dword
InitAllPageTable proto baseTable:dword, startPhysAddress:dword, U_S:dword, R_W:dword
memcpy proto dst:dword, src:dword, srcSize:dword