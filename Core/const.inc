
; размер кода реального режима
RMODE_CODE_SIZE equ 100h

; фиксированный базовый адрес кода реального режима
BASE_RMODE_STAGE2 equ 1000h

; фиксированный физический адрес промежуточного кода защищённого режима
BASE_PMOD equ BASE_RMODE_STAGE2 + RMODE_CODE_SIZE

; фиксированный физический адрес каталога страниц
BASE_PA_PD equ 10000h

; фиксированные физические адреса таблиц страниц
BASE_PA_TABLE_CORE equ 11000h
BASE_PA_TABLE_USER equ 12000h
BASE_PA_TABLE_FF equ 13000h
BASE_PA_TABLE_SF equ 14000h


; фиксированный физически/виртуальный адрес стека
BASE_STACK equ 200000h

; размер промежуточного кода инициализации защищённого режима
INIT_PMODE_CODE_SIZE equ 300h

; начальный виртуальный адрес, с которого будут располагаться данные нулевого кольца
BASE_VA_RING0 equ 80000000h
BASE_VA_RING3 equ 00000000h

BASE_VA_1_FUNC equ 0B400000h
BASE_VA_2_FUNC equ 0A800000h

; фиксированный виртуальный адрес основного кода защищённого режима
BASE_VA_MAIN_PMODE_CODE equ BASE_VA_RING0 + BASE_PMOD + INIT_PMODE_CODE_SIZE

; фиксированный виртуальный адрес стека основного кода защищённого режима
BASE_VA_RING0_STACK equ BASE_VA_RING0 + 200000h
BASE_VA_RING3_STACK equ BASE_VA_RING3 + 200000h
BASE_VA_1F_STACK equ BASE_VA_RING3 + 210000h
BASE_VA_2F_STACK equ BASE_VA_RING3 + 220000h

; физический адрес кода 3 кольца
BASE_RING3_ENTRY equ 80000000h

; фиксированный виртуальный адрес очереди задач
BASE_TSQUEUE_VA equ BASE_VA_RING0 + 300000h

MAX_TASK_STATES_VA equ BASE_TSQUEUE_VA + 5 * sizeof(TaskState)