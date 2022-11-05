.386
.MODEL flat, stdcall

include Irvine32.inc
include functions.inc
includelib Irvine32.lib

.data
BUFFER_SIZE = 4096
buffer BYTE BUFFER_SIZE DUP(0)

.code

judge_segment PROC USES ebx ecx esi ,
    address: PTR BYTE

    mov esi, address
    mov bh, [esi + 1]
    mov bl, [esi + 2]
    mov ch, [esi + 3]
    mov cl, [esi + 4]

    .IF (bh == 'd') && (bl == 'a') && (ch == 'd') && (cl == 'a')
        mov al, 1
    .ELSEIF (bh == 'c') && (bl == 'o') && (ch == 'd') && (cl == 'e')
        mov al, 2
    .ELSE
        mov al, 0
    .ENDIF

    ret
judge_segment ENDP

process_file PROC USES eax ebx ecx edx esi,
    file_path : PTR BYTE
    
    LOCAL max_bytes : DWORD

    mov max_bytes, 0
    mov edx, file_path
    call OpenInputFile
    .IF eax = INVALID_HANDLE_VALUE
        call WriteWindowMsg
        ret
    .ENDIF

    mov edx, OFFSET buffer
    mov ecx, BUFFER_SIZE
    call ReadFromeFile
    jnc success_read
    call WriteWindowMsg
    ret

success_read:
    mov esi, OFFSET buffer
    mov max_bytes, eax
    mov ecx, max_bytes
read_file:
    mov ebx, 0
    mov bl, [esi]
    .IF bl == 46;.
        INVOKE judge_segment, esi
        .IF al == 1
            add esi, 5
            jmp process_dataseg
        .ELSEIF al == 2
            add esi, 5
            jmp process_codeseg
        .ENDIF
    .ENDIF
    inc esi
    loop read_file

process_dataseg:
    INVOKE tokenize_data_segment, esi, max_bytes
    add esi, eax
process_codeseg:
    INVOKE tokenize_code_segment, esi, max_bytes
    ret
process_file ENDP
end

    

