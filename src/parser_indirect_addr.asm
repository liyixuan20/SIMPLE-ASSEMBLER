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
errormsg1 BYTE "Error:No Base!"
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



    
;把诸如[eax+2*esi+100]的间接取值方式进行分析，并分别获得base index scale displacement存储于相应的localOperand中
parse_indirect_address PROC USES eax ebx ecx edx esi,
    start_addr: PTR BYTE,
    ind_operand: PTR LocalOperand


    LOCAL count:BYTE, str0:DWORD, str1:DWORD, str2:DWORD,
        base:BYTE, index:BYTE, scale:BYTE, disp:SDWORD,
        type0:BYTE, type1:BYTE, type2:BYTE,
        flag_disp:BYTE,flag_base:BYTE, flag_ind:BYTE

        INVOKE Str_ucase, start_addr
        INVOKE Str_length, start_addr

        mov ecx, eax
        mov esi, start_addr
        mov bl, [esi]
        mov count,0
        mov str0, 0
        mov str1, 0
        mov str2, 0
        mov base, 0
        mov index, 0
        mov disp, 0
        mov scale, 0
        mov type0, 0
        mov type1, 0
        mov type2, 0
        mov flag_disp, 0
        mov flag_base, 0
        mov flag_ind, 0

        .IF ((bl >= 'A') && (bl <= 'Z')) || ((bl >= '0') && (bl <= '9')) || (bl == '*') || (bl == '+') || (bl == '-')
            .IF ((bl == '+') || (bl == '-')) && (str1 != 0)
                inc count
                jmp Next_L1
            .ENDIF

            .IF count == 0
                INVOKE add_byte_to_string, bl, str0, count
            .ELSEIF count == 1
                INVOKE add_byte_to_string, bl, str1, count
            .ELSEIF count == 2
                INVOKE add_byte_to_string, bl, str2, count
            .ELSE
                ret ;todo: error count
            .ENDIF
        .ELSEIF (bl == 32)
            jmp Next_L1
        .ELSE 
            ret
        .ENDIF

Next_L1:
    
    inc ESI
    dec ecx
    cmp ecx, 0
    jne L1

    INVOKE judge_string_type, 0, str0, ADDR type0
    .IF type0 == 1
        mov flag_base == 1
        INVOKE get_reg_num, ADDR string_part_fir
        .IF al >= 8
            ret
        .ELSE 
            mov base, al

        .ENDIF
    .ELSEIF type0 == 2
        mov flag_disp, 1
        mov ecx, str0
        mov edx, OFFSET string_part_fir
        INVOKE ParseInteger32
        mov disp, eax

    .ELSEIF type0 == 3
        mov flag_ind, 1
        INVOKE parse_index_scale, ADDR string_part_fir, str0,ADDR index, ADDR scale
    .ELSE 
        ret
    .ENDIF

    .IF count >= 1

        INVOKE judge_string_type, 1, str1, ADDR type1
        .IF type1 == 1
            mov flag_base == 1
            INVOKE get_reg_num, ADDR string_part_sec
            .IF al >= 8
                ret
            .ELSE 
                mov base, al

            .ENDIF
        .ELSEIF type1 == 2
            mov flag_disp, 1
            mov ecx, str1
            mov edx, OFFSET string_part_sec
            INVOKE ParseInteger32
            mov disp, eax

        .ELSEIF type1 == 3
            mov flag_ind, 1
            INVOKE parse_index_scale, ADDR string_part_sec, str1, ADDR index, ADDR scale
        .ELSE 
            ret
        .ENDIF
    .ENDIF

    .IF count >= 2

        INVOKE judge_string_type, 2, str2, ADDR type2
        .IF type2 == 1
            mov flag_base == 1
            INVOKE get_reg_num, ADDR string_part_thir
            .IF al >= 8
                ret
            .ELSE 
                mov base, al

            .ENDIF
        .ELSEIF type2 == 2
            mov flag_disp, 1
            mov ecx, str2
            mov edx, OFFSET string_part_thir
            INVOKE ParseInteger32
            mov disp, eax

        .ELSEIF type2 == 3
            mov flag_ind, 1
            INVOKE parse_index_scale, ADDR string_part_thir, str2, ADDR index, ADDR scale
        .ELSE 
            ret
        .ENDIF
    .ENDIF


    .IF flag_base == 0
        INVOKE printf, offset errormsg1
        ret
    .ENDIF

    mov esi, ind_operand
    mov al, base
    mov [esi], al
    mov al, index
    mov [esi+1], al
    mov al, scale
    mov [esi+2], al
    mov eax, disp
    mov [esi+4], al

    ret
parse_index_scale ENDP

END