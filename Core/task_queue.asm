InitTSQueue proc uses ebx pTSQueue: ptr TSQueue

    mov ebx, [pTSQueue]
    mov [ebx].TSQueue.tasksBegin, dword ptr BASE_TSQUEUE_VA
    mov [ebx].TSQueue.tasksEnd, dword ptr BASE_TSQUEUE_VA

    ret

InitTSQueue endp

PushTask proc uses eax ebx esi pTSQueue: ptr TSQueue, Task: ptr TaskState

    mov ebx, [pTSQueue]
    mov esi, [Task]

    mov ebx, [ebx].TSQueue.tasksEnd

    mov al, [esi].TaskState.tSS
    mov [ebx].TaskState.tSS, al

    mov eax, [esi].TaskState.tESP
    mov [ebx].TaskState.tESP, eax

    mov eax, [esi].TaskState.tEFLAGS
    mov [ebx].TaskState.tEFLAGS, eax

    mov al, [esi].TaskState.tCS
    mov [ebx].TaskState.tCS, al

    mov eax, [esi].TaskState.tEIP
    mov [ebx].TaskState.tEIP, eax

    mov eax, [esi].TaskState.tEAX
    mov [ebx].TaskState.tEAX, eax

    mov eax, [esi].TaskState.tEBX
    mov [ebx].TaskState.tEBX, eax

    mov eax, [esi].TaskState.tECX
    mov [ebx].TaskState.tECX, eax

    mov eax, [esi].TaskState.tEDX
    mov [ebx].TaskState.tEDX, eax

    mov eax, [esi].TaskState.tESI
    mov [ebx].TaskState.tESI, eax

    mov eax, [esi].TaskState.tEDI
    mov [ebx].TaskState.tEDI, eax

    mov eax, [esi].TaskState.tEBP
    mov [ebx].TaskState.tEBP, eax

    mov eax, [esi].TaskState.tCR3
    mov [ebx].TaskState.tCR3, eax

    mov eax, [esi].TaskState.cursor
    mov [ebx].TaskState.cursor, eax

    mov ebx, [pTSQueue]
    add [ebx].TSQueue.tasksEnd, sizeof(TaskState)

    .if [ebx].TSQueue.tasksEnd == MAX_TASK_STATES_VA
        mov [ebx].TSQueue.tasksEnd, BASE_TSQUEUE_VA
    .endif

    ret

PushTask endp

PopTask proc uses eax ebx esi pTSQueue: ptr TSQueue

    mov ebx, [pTSQueue]
    mov esi, [ebx].TSQueue.tasksBegin

    .if esi == [ebx].TSQueue.tasksEnd
        ret
    .endif

    movzx eax, [esi].TaskState.tSS
    mov [ebx].TSQueue.popedTask.TaskState.tSS, al

    mov eax, [esi].TaskState.tESP
    mov [ebx].TSQueue.popedTask.TaskState.tESP, eax

    mov eax, [esi].TaskState.tEFLAGS
    mov [ebx].TSQueue.popedTask.TaskState.tEFLAGS, eax

    movzx eax, [esi].TaskState.tCS
    mov [ebx].TSQueue.popedTask.TaskState.tCS, al

    mov eax, [esi].TaskState.tEIP
    mov [ebx].TSQueue.popedTask.TaskState.tEIP, eax

    mov eax, [esi].TaskState.tEAX
    mov [ebx].TSQueue.popedTask.TaskState.tEAX, eax

    mov eax, [esi].TaskState.tEBX
    mov [ebx].TSQueue.popedTask.TaskState.tEBX, eax

    mov eax, [esi].TaskState.tECX
    mov [ebx].TSQueue.popedTask.TaskState.tECX, eax

    mov eax, [esi].TaskState.tEDX
    mov [ebx].TSQueue.popedTask.TaskState.tEDX, eax

    mov eax, [esi].TaskState.tESI
    mov [ebx].TSQueue.popedTask.TaskState.tESI, eax

    mov eax, [esi].TaskState.tEDI
    mov [ebx].TSQueue.popedTask.TaskState.tEDI, eax

    mov eax, [esi].TaskState.tEBP
    mov [ebx].TSQueue.popedTask.TaskState.tEBP, eax

    mov eax, [esi].TaskState.tCR3
    mov [ebx].TSQueue.popedTask.TaskState.tCR3, eax

    mov eax, [esi].TaskState.cursor
    mov [ebx].TSQueue.popedTask.TaskState.cursor, eax

    add [ebx].TSQueue.tasksBegin, sizeof(TaskState)

    .if [ebx].TSQueue.tasksBegin == MAX_TASK_STATES_VA
        mov [ebx].TSQueue.tasksBegin, BASE_TSQUEUE_VA
    .endif

    ret

PopTask endp