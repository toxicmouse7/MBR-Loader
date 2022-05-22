.686P
.model flat, stdcall
option casemap:none

include intel.inc

include const.inc

assume fs:nothing

c16 segment use16 byte

include code16.inc

org BASE_RMODE_STAGE2

stage:
    
    ; настройка сегментных регистров
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, BASE_RMODE_STAGE2
    mov bp, sp
 
    ; активация линии A20 через порт А контроллера клавиатуры
    in al, 92h
    or al, 2
    out 92h, al
 
    ; запрет маскируемых прерываний
    cli
    ; запрет немаскируемых прерываний (NMI)
    in al, 70h
    or al, 80h
    out 70h, al

    ; инициализация регистра GDTR
    lgdt fword ptr [GDTR]

    ; перепрограммирование базового номера вектора для IRQ0-IRQ7 на 0x20
    invoke InitMasterInterruptController, 20h
    ; перепрограммирование базового номера вектора для IRQ8-IRQ15 на 0x28
    invoke InitSlaveInterruptController, 28h

    ; перевод процессора в защищённый режим (установка бита PE)
    mov eax, cr0
    or al, 1
    mov cr0, eax

    ; длинный переход на код защищённого режима
    db 0EAh
    dw offset BASE_PMOD
    dw 08h

    include code16.asm

stage_end:
db RMODE_CODE_SIZE - (stage_end - stage) dup (0)

c16 ends




c32 segment use32 byte
org BASE_PMOD

include code32_1.inc
include task_queue.inc

init_va:
    mov ax, 10h
    mov ds, ax
    mov ss, ax
    mov ax, 18h
    mov es, ax
    mov esp, BASE_STACK

    invoke memcpy, 80000000h, 4000h, 512 
    invoke memcpy, 80001000h, 4200h, 512
    invoke memcpy, 80002000h, 4400h, 512

    ; инициализируем нулевую запись адресом таблицы
    invoke InitPageTableEntry, BASE_PA_PD, 0, BASE_PA_TABLE_CORE, 0, 1
    invoke InitPageTableEntry, BASE_PA_PD, 512, BASE_PA_TABLE_CORE, 0, 1
    
    ; инициализируем все записи таблицы последовательными физическими адресами с 0
    invoke InitAllPageTable, BASE_PA_TABLE_CORE, 00000000h, 0, 1
    
    ; заносим адрес каталога страниц в cr3
    mov eax, BASE_PA_PD
    mov cr3, eax

    ; активируем механизм виртуальной памяти
    mov eax, cr0
    or eax, 80000000h
    mov cr0, eax

    mov eax, BASE_VA_MAIN_PMODE_CODE
    jmp eax

include code32_1.asm

; Global Descriptor Table
GDT:
    dd 0, 0
    DefineUsualCodeSegmentDescriptor 0, 0FFFFFh, 0          ; код  (селектор = 8h)
    DefineUsualDataSegmentDescriptor 0, 0FFFFFh, 0       ; данные (селектор = 10h)
    DefineUsualDataSegmentDescriptor 0B8000h, 0FFFFFh, 0    ; видеобуфер (селектор = 18h)
GDT_size equ $ - GDT
GDTR:
    dw GDT_size - 1
    dd GDT

init_va_end:
db INIT_PMODE_CODE_SIZE - (init_va_end - init_va) dup (0)

c32 ends

end