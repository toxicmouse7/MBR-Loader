SplitCS proto stdcall csAddress: word
CHStoLBA proto stdcall head: byte, csAddress: word
MergeCS proto stdcall cylinder: word, sector: byte
WriteLBA proto stdcall numOfSec: word, address: dword, lbaIndex: dword, drive: byte
ReadLBA proto stdcall numOfSec: word, address: dword, lbaIndex: dword, drive: byte

DiskAddressPacket struct

    dapSize db ?
    unused db ?
    numberOfSectorsToRead dw ?
    buffer dd ?
    lbaAddressLDW dd ?
    lbaAddressHDW dd ?

DiskAddressPacket ends