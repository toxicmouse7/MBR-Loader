TaskState struct

    tSS db ?
    tESP dd ?
    tEFLAGS dd ?
    tCS db ?
    tEIP dd ?
    tEAX dd ?
    tEBX dd ?
    tECX dd ?
    tEDX dd ?
    tESI dd ?
    tEDI dd ?
    tEBP dd ?
    tCR3 dd ?
    tPTEIndex dd ?
    tPDEIndex dd ?

    cursor dd ?

TaskState ends

TSQueue struct

    tasksBegin dd ?         ; адрес начала массива указателей на TaskState
    tasksEnd dd ?           ; адрес конца массива указателей
    popedTask TaskState <>

TSQueue ends

InitTSQueue proto pTSQueue: ptr TSQueue