.386
.MODEL flat, stdcall

include Irvine32.inc
include functions.inc
include data_proc.inc
include tokenizer.inc
includelib Irvine32.lib
;间接寻址的字段最多可分成三段，开辟三个变量储存
.data
string_part_fir BYTE 32 DUP(0)
string_part_sec BYTE 32 DUP(0)
string_part_thir BYTE 32 DUP(0)

str_scale BYTE 16 DUP(0)
str_index BYTE 16 DUP(0)
.code
;判断该间接寻址字段的类型，base、index*scale、displacement
judge_string_type PROC USES eax ebx ecx edx esi, 
    part_order: BYTE,
    string_len: BYTE,
    flag: PTR BYTE

    LOCAL tmp_flag: BYTE, tmp_flagn:BYTE, address:PTR BYTE
    mov tmp_flag, 0
    mov tmp_flagn, 0
    mov tmp_terminal, 0
    .IF part_order == 0
        mov esi, OFFSET string_part_fir
    .ELSEIF part_order == 1
        mov esi, OFFSET string_part_sec
    .ELSEIF part_order == 2
        mov esi, OFFSET string_part_thir
    .ELSE
        ret
    .ENDIF
    mov ecx, string_len
    mov address, esi
    invoke Str_ucase, address
L1:
    mov bl, [esi]
    .IF (bl >= 65) && (bl <= 90) && (tmp_flagn == 0)
        tmp_flag = 1
        tmp_terminal = 1
    .ELSEIF (bl >=48) && (bl <= 57) && (tmp_flag == 0)
        tmp_flagn = 1
        tmp_terminal = 2
    .ELSEIF (bl >= 65) && (bl <= 90) && (tmp_flagn == 1)
        tmp_terminal = 3
    .ELSEIF (bl >=48) && (bl <= 57) && (tmp_flag == 1)
        tmp_terminal = 3
    .ELSE
        inc esi
        loop L1
    .ENDIF

    inc esi
    loop L1

    mov esi, flag
    mov bl, tmp_terminal
    mov [esi], bl
    ret
judge_string_type ENDP
        
;分析string字段，判断对应的寄存器名字获得对应的值（之后用于MODRM寻址）
;return al = reg_num
get_reg_num PROC USES ebx ecx edx esi,
    start_address: PTR BYTE

    mov esi, start_address
    mov bl, [esi]
    mov cl, [esi+1]
    mov dl, [esi+2]

    .IF bl == 'E'
        .IF (cl == 'A') && (dl == 'X')
            mov al, EAX_NUM
        .ELSEIF (cl == 'C') && (dl == 'X')
            mov al, ECX_NUM
        .ELSEIF (cl == 'B') && (dl == 'X')
            mov al, EBX_NUM 
          .ELSEIF (cl == 'D') && (dl == 'X')
            mov al, EDX_NUM  
        .ELSEIF (cl == 'B') && (dl == 'P')
            mov al, EBP_NUM
        .ELSEIF (cl == 'S') && (dl == 'P')
            mov al, ESP_NUM
        .ELSEIF (cl == 'S') && (dl == 'I')
            mov al, ESI_NUM
        .ELSEIF (cl == 'D') && (dl == 'I')
            mov al, EDI_NUM
        .ELSE
            mov al, 1000b
        .ENDIF
    .ELSE
        mov al, 1000b

    .ENDIF
    ret
get_reg_num ENDP
parse_index_scale PROC USES eax ebx ecx edx esi edi,
    start_addr:PTR BYTE,
    string_len:DWORD,
    index: PTR BYTE,
    scale: PTR BYTE
    
    LOCAL is_num_front: BYTE, pos_len:DWORD, pos_lenp:DWORD
    mov eax, 0
    mov esi, start_addr
    mov is_num_front, 0
    mov pos_len, 0
    mov pos_lenp, 0
    mov ecx, string_len
    mov edx, OFFSET str_scale
    mov edi, OFFSET str_index
    INVOKE ClearString, edi
    INVOKE ClearString, edx
L1:
    mov bl, [esi]
    .IF (bl >= '0') && (bl <= '9')
        .IF pos_len == 0
            mov is_num_front, 1
        .ENDIF
        mov [edx], bl
        inc edx
        inc pos_len
        jmp NextL1
    .ELSEIF (bl >= 'A') && (bl <= 'Z')
        mov [edi], bl
        inc edi
        inc pos_lenp
        jmp NextL1
    .ELSE
        jmp NextL1
    .ENDIF
NextL1:
    inc esi
    dec ecx
    cmp ecx, 0
    jne L1
    
    
    sub edx, pos_len
    
    sub edi, pos_lenp
    mov ecx, pos_len
    INVOKE ParseInteger32
    
    mov esi, scale
    mov [esi], al

    mov esi, OFFSET str_index
    INVOKE get_reg_num, esi
    mov esi, index
    mov [esi], al

    ret
parse_index_scale ENDP

add_byte_to_string PROC USES ebx esi,
    value:BYTE
    pos:DWORD
    count:BYTE

    .IF count == 0
        mov esi, OFFSET string_part_fir
    .ELSEIF count == 1
        mov esi, OFFSET string_part_sec
    .ELSEIF count == 2
        mov esi, OFFSET string_part_thir
    .ELSE
        ret
        ;todo: error count
    .ENDIF

    add esi, pos
    mov bl, value
    mov [esi], bl
    ret
add_byte_to_string ENDP



    

parse_indirect_address PROC USES eax ebx ecx edx esi,
    start_addr: PTR BYTE,
    ind_operand: PTR LocalOperand