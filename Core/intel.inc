; структура дескриптора сегмента
SegmentDescriptor struct
    limit_low           dw ?
    base_low            dw ?
    base_medium         db ?
    security_byte       db ?
    limit_hi_and_bits   db ?
    base_hi             db ?
SegmentDescriptor ends

; определение и инициализация переменной с типом SegmentDescriptor
DefineSegmentDescriptor macro base, limit, security, bits
    SegmentDescriptor <limit and 0FFFFh, base and 0FFFFh, (base shr 16) and 0FFh, security and 0FFh, ((limit shr 16) and 00Fh) or (bits shl 4), (base shr 24) and 0FFh>
endm


DefineDataSegmentDescriptor macro base, limit, W, E, DPL, P, B, G 
    DefineSegmentDescriptor base, limit, ((W shl 1) or (E shl 2) or (DPL shl 5) or (P shl 7) or 00010000b), ((B shl 2) or (G shl 3))
endm


DefineUsualDataSegmentDescriptor macro base, limit, DPL 
    DefineDataSegmentDescriptor base, limit, 1, 0, DPL, 1, 1, 1
endm


DefineCodeSegmentDescriptor macro base, limit, R, C, DPL, P, D, G
    DefineSegmentDescriptor base, limit, ((R shl 1) or (C shl 2) or (DPL shl 5) or (P shl 7) or 00011000b), ((D shl 2) or (G shl 3))
endm


DefineUsualCodeSegmentDescriptor macro base, limit, DPL
    DefineCodeSegmentDescriptor base, limit, 1, 0, DPL, 1, 1, 1
endm


DefineTaskStateSegmentDescriptor macro base, limit, DPL
    DefineSegmentDescriptor base, limit, 10000000b or (DPL shl 5) or TYPE_AVAILABLE_TSS_386, 1000b
endm



; типы шлюзов
TYPE_CALLGATE_286 = 4
TYPE_TASKGATE = 5
TYPE_INTERRUPTGATE_286 = 6
TYPE_TRAPGATE_286 = 7
TYPE_CALLGATE_386 = 12
TYPE_GATE_RESERVED = 13
TYPE_INTERRUPTGATE = 14
TYPE_TRAPGATE_386 = 15

; типы системных дескрипторов
TYPE_AVAILABLE_TSS_286 = 1  ; свободный TSS-286
TYPE_LDT = 2                ; LDT
TYPE_BUZY_TSS_286 = 3       ; занятый TSS-286
TYPE_AVAILABLE_TSS_386 = 9  ; свободный TSS-386
TYPE_RESERVED = 10          ; зарезервировано
TYPE_BUZY_TSS_386 = 11      ; занятый TSS-386


; структура шлюза
Gate struct
    offset_low      dw ?
    selector        dw ?
    count           db ?
    security_byte   db ?
    offset_hi       dw ?
Gate ends

; определение и инициализация переменной с типом Gate
DefineGate macro selector, dstOffset, DPL, gateType, count
    Gate <dstOffset and 0FFFFh, selector, count and 00011111b, (gateType and 0Fh) or (DPL shl 5) or 10000000b, (dstOffset shr 16) and 0FFFFh>
endm


DefineCallGate macro selector, dstOffset, DPL, count
    DefineGate selector, dstOffset, DPL, TYPE_CALLGATE_386, count
endm


DefineTrapGate macro selector, dstOffset, DPL
    DefineGate selector, dstOffset, DPL, TYPE_TRAPGATE_386, 0
endm


DefineInterruptGate macro selector, dstOffset, DPL
    DefineGate selector, dstOffset, DPL, TYPE_INTERRUPTGATE, 0
endm


DefineTaskGate macro selector, dstOffset, DPL
    DefineGate selector, dstOffset, DPL, TYPE_TASKGATE, 0
endm

TSS struct

	link    dw      ?           ; 00h
	null1   dw      ?           ; 02h
	esp0    dd      ?           ; 04h
	ss0     dw      ?           ; 08h
	null2   dw      ?           ; 0Ah
	esp1    dd      ?           ; 0Ch
	ss1     dw      ?           ; 10h
	null3   dw      ?           ; 12h
	esp2    dd      ?           ; 14h
	ss2     dw      ?           ; 18h
	null4   dw      ?           ; 1Ah

	cr3Reg  dd      ?           ; 1Ch
	eipReg  dd      ?           ; 20h
	eflagsReg   dd  ?           ; 24h
	eaxReg  dd      ?           ; 28h
	ecxReg  dd      ?           ; 2Ch
	edxREg  dd      ?           ; 30h
	ebxReg  dd      ?           ; 34h
	espReg  dd      ?           ; 38h
	ebpReg  dd      ?           ; 3Ch
	esiReg  dd      ?           ; 40h
	ediReg  dd      ?           ; 44h

	esReg   dw      ?           ; 48h
	null5   dw      ?           ; 4Ah
	csReg   dw      ?           ; 4Ch
	null6   dw      ?           ; 4Eh
	ssReg   dw      ?           ; 50h
	null7   dw      ?           ; 52h
	dsReg   dw      ?           ; 54h
	null8   dw      ?           ; 56h
	fsReg   dw      ?           ; 58h
	null9   dw      ?           ; 5Ah
	gsReg   dw      ?           ; 5Ch
	null10  dw      ?           ; 5Eh
	ldtr    dw      ?           ; 60h
	null11  dw      ?           ; 62h

	null12  dw      ?           ; 64h
	bitMapOffset    dw  ?       ; 66h
	
TSS ends


DefineTssDescriptor macro base, limit, DPL
    DefineSegmentDescriptor base, limit, (TYPE_AVAILABLE_TSS_386 or (DPL shl 5) or (1 shl 7)), 0
endm

MASTER8259A = 20h ; первый контроллер прерываний
SLAVE8259A = 0A0h  ; второй контроллер прерываний
