;TODO data_tokenizer code_tokenizer instruction_tokenizer
.386
.MODEL flat, stdcall

include tokenizer.inc
include data_proc.inc
include functions.inc
.data
standard_opeator        :BYTE 10 DUP(0)
srandard_operand_one    :Operand
standard_operand_two    :Operand
operand_one_buffer      :Operand
operand_two_buffer      :Operand

register_to_binary_list register_string_to_standard<"AL", 8bitlow shl 4 + EAX_NUM>
register_string_to_standard<"BL", 8bitlow shl 4 + EBX_NUM>
register_string_to_standard<"CL", 8bitlow shl 4 + ECX_NUM>
register_string_to_standard<"DL", 8bitlow shl 4 + EDX_NUM>
register_string_to_standard<"AH", 8bithigh shl 4 + EAX_NUM>
register_string_to_standard<"BH", 8bithigh shl 4 + EBX_NUM>
register_string_to_standard<"CH", 8bithigh shl 4 + ECX_NUM>
register_string_to_standard<"DH", 8bithigh shl 4 + EDX_NUM>
register_string_to_standard<"AX", 16bit shl 4 + EAX_NUM>
register_string_to_standard<"BX", 16bit shl 4 + EBX_NUM>
register_string_to_standard<"CX", 16bit shl 4 + ECX_NUM>
register_string_to_standard<"DX", 16bit shl 4 + EDX_NUM>
register_string_to_standard<"SI", 16bit shl 4 + ESI_NUM>
register_string_to_standard<"DI", 16bit shl 4 + EDI_NUM>
register_string_to_standard<"SP", 16bit shl 4 + ESP_NUM>
register_string_to_standard<"BP", 16bit shl 4 + EBP_NUM>
register_string_to_standard<"EAX",32bit shl 4 + EAX_NUM>
register_string_to_standard<"EBX",32bit shl 4 + EBX_NUM>
register_string_to_standard<"ECX",32bit shl 4 + ECX_NUM>
register_string_to_standard<"EDX",32bit shl 4 + EDX_NUM>
register_string_to_standard<"ESI",32bit shl 4 + ESI_NUM>
register_string_to_standard<"EDI",32bit shl 4 + EDI_NUM>
register_string_to_standard<"ESP",32bit shl 4 + ESP_NUM>
register_string_to_standard<"EBP",32bit shl 4 + EBP_NUM>
.code
ClearString PROC
    start_address   :DWORD
    len             :BYTE
    pushad
    mov ecx, 0
    mov esi, start_address
    .while ecx < len
        mov al, 0
        mov BYTE PTR[esi], al
        inc esi
        inc ecx
    .endw
ClearString ENDP
register_name_to_standard_operand PROC
    operand_pointer     :DWORD,
    operand_name_pointer:DWORD,
    indirect_flag       :BYTE

    mov eax, operand_pointer
    mov ebx, operand_name_pointer
    .if indirect_flag == 0
        mov [eax].op_type, reg_type
    .elseif indirect_flag == 1
        mov [eax].op_type, indirect_type ;TODO
    .endif
    mov ecx, 0
    mov edx, offset register_to_binary_list
    .while ecx < 24
        lea edi, (register_string_to_standard PTR[edx]).string_name
        invoke Str_compare ebx, edi
        je next
        inc ecx
        add edx, sizeof register_string_to_standards
    .endw
next:
    .if indirect_flag == 0
        .if ecx < 8
            mov [eax].op_size, 1
        .elseif ecx < 16
            mov [eax].op_size, 2
        .elseif ecx < 32
            mov[eax].op_size, 4
        .endif
    .elseif indirect_flag == 1
        mov [eax].op_size, 4
    .endif
    mov esi, [eax].address
    mov dl, (register_name_to_standard_operand PTR[edx]).binary_name
    mov RegOperand PTR[esi].reg, dl
    ret
register_name_to_standard_operand ENDP
imm_to_standard_operand PROC
    operand_pointer     :DWORD,
    imm_name_pointer    :DWORD,
    imm_name_len        :DWORD

    mov ecx, imm_name_len
    mov edx, imm_name_pointer
    invoke ParseInteger32

    mov ebx, operand_pointer
    mov (operand PTR[ebx]).op_type, imm_type
    mov (operand PTR[ebx]).op_size, 4   ;Simplified--all treated as 32bit integer
    
    mov esi, (operand PTR[ebx]).address
    mov (ImmOperand PTR[esi]).value, eax
    ret
imm_to_standard_operand ENDP
process_operand PROC

    operand_name        :DWORD,
    operand_name_len    :BYTE,
    operand_position    :BYTE,   ; 1 or 2

    indirect_flag       :BYTE   ;0 or 1
    
    invoke find_symbol, offset data_symbol_list, offset operand_name
    .if ebx != 0
        .if operand_position == 1
            invoke data_name_to_standard_operand, offset standard_operand_one, offset operand_name
            ret
        .elseif operand_position == 2
            invoke data_name_to_standard_operand, offset standard_operand_two, offset operand_name
            ret
        .endif
    .endif
    invoke find_symbol, offset proc_symbol_list, offset operand_name
    .if ebx != 0
    ;TODO
    .endif
    invoke find_symbol, offset code_symbol_list, offset operand_name
    .if ebx != 0
    ;TODO
    .endif
    .if operand_position == 1
        invoke register_name_to_standard_operand, offset standard_operand_one, offset operand_name, indirect_flag
        ret
    .elseif operand_position == 2
        invoke register_name_to_standard_operand, offset standard_operand_two, offset operand_name, indirect_flag
        ret
    .endif
    ;process error
    ret
process_operand ENDP

check_proc_label PROC   ;True:eax=1   False:eax=0
    proc_label_address: DWORD
    pushad
    mov edx, proc_label_address
    mov al, BYTE PTR[edx]
    mov ah, BYTE PTR[edx + 1]
    mov bl, BYTE PTR[edx + 2]
    mov bh, BYTE PTR[edx + 3]
    .if al == 'P' && ah == 'R' && bl == 'O' && bh == 'C'
        jmp ok
    .elseif al == 'p' && ah == 'r' && bl == 'o' && bh == 'c'
        jmp ok
    .else
        popad
        mov eax, 0
        ret
    .endif
    ok:
        popad
        mov eax, 1
        ret
check_proc_label ENDP
check_endp PROC

    operand_name    :DWORD

    mov esi, operand_name
    mov eax, 0
    .if [esi] == 'E' && [esi+1] == 'N' && [esi+2] == 'D' && [esi+3] == 'P'
        mov eax, 1
    .elseif [esi] == 'e' && [esi+1] == 'n' && [esi+2] == 'd' && [esi+3] == 'p'
        mov eax, 1
    ret
check_endp ENDP
instruction_tokenizer PROC
    proc_start_context   :DWORD,
    code_end_context     :DWORD,
    current_address_pointer     :DWORD

    LOCAL   current_status      :BYTE,
            char                :BYTE,
            Operator_name[10]   :BYTE,
            Operand_name[20]    :BYTE,
            Operand_one_info    :Operand,
            Operand_two_info    :Operand,
            Operator_name_index :BYTE,
            Operand_name_index  :BYTE,
            Operand_type        :BYTE,
            indirect_flag       :BYTE
    pushad
    mov eax, offset operand_one_buffer
    mov standard_operand_one.address, eax
    mov eax, offser operand_two_buffer
    mov standard_operand_two.address, eax

    mov Operator_name_index, 0
    mov Operand_name_index, 0
    mov edx, proc_start_context
    mov current_status, start_status
    mov indirect_flag, 0
    .while edx < code_end_context
        mov char, [edx]
        inc edx
        .if current_status == start_status
            .if (char >= 'a' && char <= 'z') || (char >= 'A' && char <= 'Z')
                mov current_status, operator_status
                mov esi, offset Operator_name
                add esi, Operator_name_index
                mov al, char
                mov [esi], al
                inc Operator_name_index
            .endif
        .elseif current_status == operator_status
            .if (char >= 'a' && char <= 'z') || (char >= 'A' && char <= 'Z')
                mov esi, offset Operator_name
                add esi, Operator_name_index
                mov al, char
                mov [esi], al
                inc Operator_name_index
            .elseif char == ' '
                mov current_status, after_operator_status
                
            .elseif char == ':'
                mov current_status, start_status
                invoke process_jump_label, offset Operator_name, Operator_name_index, current_address
            
            .endif
        .elseif current_status == after_operator_status
            .if (char >= 'a' && char <= 'z') || (char >= 'A' && char <= 'Z')
                mov current_status, operand_one_status
                mov esi, offset Operand_name
                add esi, Operator_name_index
                mov al, char
                mov [esi], al
                inc Operand_name_index
                mov Operand_type, reg_or_mem_type ;eax data

                mov esi, offset Operator_name
                mov edi, offset standard_opeator
                mov ecx, 0
                .while ecx < Operator_name_index
                    mov al, [esi]
                    mov [edi], al
                    inc esi
                    inc edi
                    inc ecx
                .endw
            .elseif char >= '0' && char <='9'
                mov current_status, operand_one_status
                mov esi, offset Operand_name
                add esi, Operator_name_index
                mov al, char
                mov [esi], al
                inc Operand_name_index
                mov Operand_type, imm_type ;12

                mov esi, offset Operator_name
                mov edi, offset standard_opeator
                mov ecx, 0
                .while ecx < Operator_name_index
                    mov al, [esi]
                    mov [edi], al
                    inc esi
                    inc edi
                    inc ecx
                .endw
            .elseif char == '['
                mov current_status, operand_one_status
                mov indirect_flag, 1    ;indirect
            .elseif char == ':'
                mov current_status, start_status
                invoke process_jump_label, offset Operator_name, Operator_name_index, current_address
                
            .endif
        .elseif current_status == operand_one_status
            .if (char >= 'a' && char <= 'z') || (char >= 'A' && char <= 'Z')
                mov esi, offset Operand_name
                add esi, Operator_name_index
                mov al, char
                mov [esi], al
                inc Operand_name_index
            .elseif char >= '0' && char <='9'
                mov esi, offset Operand_name
                add esi, Operator_name_index
                mov al, char
                mov [esi], al
                inc Operand_name_index
            .elseif (char == ' ') || (char == ',') || (char == ']')
                invoke check_endp, Operand_name, Operand_name_index
                .if eax == 1
                    .jmp final
                .endif
                mov current_status, after_operand_one_status
                invoke process_operand, offset Operand_name, Operand_name_index, Operand_type, indirect_flag

                invoke ClearString, offset Operand_name, Operand_name_index
                mov Operand_name_index, 0
                mov indirect_flag, 0
            .elseif char == 0 | char == 10 || char == 13
                mov current_status, start_status
                invoke process_operand, offset Operand_name, Operand_name_index, Operand_type, indirect_flag
                invoke ClearString, offset Operand_name, Operand_name_index
                mov Operand_name_index, 0

                invoke generate_binary_code, offset standard_opeator, offset srandard_operand_one, offset standard_operand_two, 1, current_address_pointer; TODO
            .endif
        .elseif current_status == after_operand_one_status
            .if (char >= 'a' && char <= 'z') || (char >= 'A' && char <= 'Z')
                mov current_status, operand_two_status
                mov esi, offset Operand_name
                add esi, Operator_name_index
                mov al, char
                mov [esi], al
                inc Operand_name_index
                mov Operand_type, reg_or_mem_type
            .elseif (char >= '0' && char <= '9')
                mov current_status, operand_two_status
                mov esi, offset Operand_name
                add esi, Operator_name_index
                mov al, char
                mov [esi], al
                inc Operand_name_index
                mov Operand_type, imm_type
            .elseif char == '['
                mov current_address, operand_two_address
                mov indirect_flag, 1
            .elseif char == 0 | char == 10 || char == 13
                mov current_status, start_status
                invoke generate_binary_code, offset standard_opeator, offset srandard_operand_one, offset standard_operand_two, 1, current_address_pointer; TODO
            .endif
        .elseif current_status == operand_two_status
            .if (char >= 'a' && char <= 'z') || (char >= 'A' && char <= 'Z')
                mov esi, offset Operand_name
                add esi, Operator_name_index
                mov al, char
                mov [esi], al
                inc Operand_name_index
            .elseif (char >= '0' && char <= '9')
                mov esi, offset Operand_name
                add esi, Operator_name_index
                mov al, char
                mov [esi], al
                inc Operand_name_index
            .elseif char == ' ' || char == 0 | char == 10 || char == 13 || char == ']'
                mov current_status, start_status
                invoke process_operand, offset Operand_name, Operand_name_index, Operand_type, indirect_flag

                invoke ClearString, offset Operand_name, Operand_name_index
                mov Operand_name_index, 0
                mov indirect_flag, 0
                invoke generate_binary_code, offset standard_opeator, offset srandard_operand_one, offset standard_operand_two, 2, current_address_pointer; TODO
            .endif
        .endif
    .endw
final:
        ret
instruction_tokenizer ENDP
code_tokenizer PROC
    start_context: DWORD,
    max_length: DWORD

    LOCAL address_space     :DWORD,
          proc_name[20]     :BYTE,
          proc_label[10]    :BYTE,
          current_status    :BYTE,
          char              :BYTE,
          proc_name_index   :BYTE,
          proc_label_index  :BYTE,

    mov address_space, 0
    mov proc_name_index, 0
    mov proc_label_index, 0
    mov edx, start_context
    mov ecx, 0
    mov current_status, start_status
    .while ecx < max_length
        mov char, BYTE PTR[edx]
        .if current_status == start_status
            .if (char >= 'a' && char <= 'z') || (char >= 'A' && char <= 'Z')
                mov current_status, proc_name_status
                mov esi, offset proc_name
                add esi, proc_name_index
                mov al, char
                mov BYTE PTR[esi], al
                inc proc_name_index
            .endif;Error process
        .elseif current_status == proc_name_status
            .if (char >= 'a' && char <= 'z') || (char >= 'A' && char <= 'Z')
                mov esi, offset proc_name
                add esi, proc_name_index
                mov al, char
                mov BYTE PTR[esi], al
                inc proc_name_index
            .elseif char == ' '
                mov current_status, after_proc_name_status
            .endif
        .elseif current_status == after_proc_name_status
            .if (char >= 'a' && char <= 'z') || (char >= 'A' && char <= 'Z')
                mov current_status, proc_label_status
                mov esi, offset proc_label
                add esi, proc_label_index
                mov al, char
                mov BYTE PTR[esi], al
                inc proc_label_index
            .endif
        .elseif current_status == proc_label_status
            .if (char >= 'a' && char <= 'z') || (char >= 'A' && char <= 'Z')
                mov esi, offset proc_label
                add esi, proc_label_index
                mov al, char
                mov BYTE PTR[esi], al
                inc proc_label_index
            .elseif char == ' ' || char == 0 || char == 10 || char == 13
                mov current_status, start_status
                invoke check_proc_label, offset proc_label
                .if eax == 1
                    mov edi, start_context
                    add edi, max_length
                    invoke instruction_tokenizer, edx, edi, offset address_space; Pay attention to the following inc ecx
                .endif
        .endif 
        inc ecx
        inc edx
    .endw
code_tokenizer ENDP