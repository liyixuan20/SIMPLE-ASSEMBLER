;TODO data_tokenizer code_tokenizer instruction_tokenizer
.386
.MODEL flat, stdcall

include tokenizer.inc
include data_proc.inc
include functions.inc
include Irvine32.inc
includelib Irvine32.lib
.data
standard_opeator        BYTE 10 DUP(0)
standard_operand_one    Operand <0, 0, 0>
standard_operand_two    Operand <0, 0, 0>
operand_one_buffer      Operand <0, 0, 0>
operand_two_buffer      Operand <0, 0, 0>

register_to_binary_list register_string_to_standard<"AL", bitlow8 shl 4 + EAX_NUM>
register_string_to_standard<"BL", bitlow8 shl 4 + EBX_NUM>
register_string_to_standard<"CL", bitlow8 shl 4 + ECX_NUM>
register_string_to_standard<"DL", bitlow8 shl 4 + EDX_NUM>
register_string_to_standard<"AH", bithigh8 shl 4 + EAX_NUM>
register_string_to_standard<"BH", bithigh8 shl 4 + EBX_NUM>
register_string_to_standard<"CH", bithigh8 shl 4 + ECX_NUM>
register_string_to_standard<"DH", bithigh8 shl 4 + EDX_NUM>
register_string_to_standard<"AX", bit16 shl 4 + EAX_NUM>
register_string_to_standard<"BX", bit16 shl 4 + EBX_NUM>
register_string_to_standard<"CX", bit16 shl 4 + ECX_NUM>
register_string_to_standard<"DX", bit16 shl 4 + EDX_NUM>
register_string_to_standard<"SI", bit16 shl 4 + ESI_NUM>
register_string_to_standard<"DI", bit16 shl 4 + EDI_NUM>
register_string_to_standard<"SP", bit16 shl 4 + ESP_NUM>
register_string_to_standard<"BP", bit16 shl 4 + EBP_NUM>
register_string_to_standard<"EAX",bit32 shl 4 + EAX_NUM>
register_string_to_standard<"EBX",bit32 shl 4 + EBX_NUM>
register_string_to_standard<"ECX",bit32 shl 4 + ECX_NUM>
register_string_to_standard<"EDX",bit32 shl 4 + EDX_NUM>
register_string_to_standard<"ESI",bit32 shl 4 + ESI_NUM>
register_string_to_standard<"EDI",bit32 shl 4 + EDI_NUM>
register_string_to_standard<"ESP",bit32 shl 4 + ESP_NUM>
register_string_to_standard<"EBP",bit32 shl 4 + EBP_NUM>
.code
ClearString PROC,
    start_address   :DWORD,
    len             :BYTE

    pushad
    mov cl, 0
    mov esi, start_address
    .while cl < len
        mov al, 0
        mov BYTE PTR[esi], al
        inc esi
        inc cl
    .endw
	popad
	ret
ClearString ENDP
register_name_to_standard_operand PROC,
    operand_pointer     :DWORD,
    operand_name_pointer:DWORD,
    indirect_flag       :BYTE

    mov eax, operand_pointer
    mov ebx, operand_name_pointer
    .if indirect_flag == 0
        mov (Operand PTR[eax]).op_type, reg_type
    .elseif indirect_flag == 1

        mov (Operand PTR[eax]).op_type, indirect_type ;TODO


    .endif
    mov ecx, 0
    mov edx, offset register_to_binary_list
    .while ecx < 24
        lea edi, (register_string_to_standard PTR[edx]).string_name
        invoke Str_compare ,ebx, edi
        je next
        inc ecx
        add edx, sizeof register_string_to_standard
    .endw
next:
    .if indirect_flag == 0
        .if ecx < 8
            mov (Operand PTR[eax]).op_size, 1
        .elseif ecx < 16
            mov (Operand PTR[eax]).op_size, 2
        .elseif ecx < 32
            mov(Operand PTR[eax]).op_size, 4
        .endif
    .elseif indirect_flag == 1
        mov (Operand PTR[eax]).op_size, 4
    .endif

    mov esi, (Operand PTR[eax]).address
    mov dl, (register_string_to_standard PTR[edx]).binary_name
    mov (RegOperand PTR[esi]).reg, dl


    ret
register_name_to_standard_operand ENDP
imm_to_standard_operand PROC,
    operand_pointer     :DWORD,
    imm_name_pointer    :DWORD,
    imm_name_len        :DWORD

    mov ecx, imm_name_len
    mov edx, imm_name_pointer
    invoke ParseInteger32

    mov ebx, operand_pointer
    mov (operand PTR[ebx]).op_type, imm_type
    mov (operand PTR[ebx]).op_size, 4   ;Simplified--all treated as bit32 integer
    
    mov esi, (operand PTR[ebx]).address
    mov (ImmOperand PTR[esi]).value, eax
    ret
imm_to_standard_operand ENDP

data_name_to_standard_operand PROC,
	operand_address	:DWORD,
	operand_name_address :DWORD
	;TODO
	ret
data_name_to_standard_operand ENDP

process_jump_label PROC,
	operand_name_address :DWORD,
	operand_name_index	:DWORD,
	current_address		:DWORD
process_jump_label ENDP

process_operand PROC,
    operand_name        :DWORD,
    operand_name_len    :BYTE,
    operand_position    :BYTE,   ; 1 or 2
    indirect_flag       :BYTE   ;0 or 1
    
    invoke find_symbol, addr data_symbol_list, addr operand_name
    .if ebx != 0
        .if operand_position == 1
            invoke data_name_to_standard_operand, addr standard_operand_one, addr operand_name
            ret
        .elseif operand_position == 2
            invoke data_name_to_standard_operand, addr standard_operand_two, addr operand_name
            ret
        .endif
    .endif
    invoke find_symbol, addr proc_symbol_list, addr operand_name
    .if ebx != 0
    ;TODO
    .endif
    invoke find_symbol, addr code_symbol_list, addr operand_name
    .if ebx != 0
    ;TODO
    .endif
    .if operand_position == 1
        invoke register_name_to_standard_operand, addr standard_operand_one, addr operand_name, indirect_flag
        ret
    .elseif operand_position == 2
        invoke register_name_to_standard_operand, addr standard_operand_two, addr operand_name, indirect_flag
        ret
    .endif
    ;process error
    ret
process_operand ENDP

check_proc_label PROC,   ;True:eax=1   False:eax=0
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
check_endp PROC,
    operand_name    :DWORD

    mov esi, operand_name
    mov eax, 0
	mov al, [esi]
	mov ah, [esi+1]
	mov bl, [esi+2]
	mov bh, [esi+3]
    .if al == 'E' && ah == 'N' && bl == 'D' && bh == 'P'
        mov eax, 1
    .elseif al == 'e' && ah == 'n' && bl == 'd' && bh == 'p'
        mov eax, 1
    .endif
    ret
check_endp ENDP
Write_at PROC,
	base :DWORD,
	index:BYTE,
	char :BYTE

	pushad
	mov ebx, base
	mov eax, 0
	mov al, index
	add ebx, eax
	mov cl, char
	mov BYTE PTR[ebx], cl
	popad
	ret
Write_at ENDP

instruction_tokenizer PROC,
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
    mov eax, offset operand_two_buffer
    mov standard_operand_two.address, eax

    mov Operator_name_index, 0
    mov Operand_name_index, 0
    mov edx, proc_start_context
    mov current_status, start_status
    mov indirect_flag, 0
    .while edx < code_end_context
		push eax
		mov al, [edx]
        mov char, al
		pop eax

        inc edx
        .if current_status == start_status
            .if (char >= 'a' && char <= 'z') || (char >= 'A' && char <= 'Z')
                mov current_status, operator_status
				invoke Write_at, addr Operator_name, Operator_name_index, char
                inc Operator_name_index
            .endif
        .elseif current_status == operator_status
            .if (char >= 'a' && char <= 'z') || (char >= 'A' && char <= 'Z')
                invoke Write_at, addr Operator_name, Operator_name_index, char
                inc Operator_name_index
            .elseif char == ' '
                mov current_status, after_operator_status
                
            .elseif char == ':'
                mov current_status, start_status
                invoke process_jump_label, addr Operator_name, Operator_name_index, current_address_pointer
            
            .endif
        .elseif current_status == after_operator_status
            .if (char >= 'a' && char <= 'z') || (char >= 'A' && char <= 'Z')
                mov current_status, operand_one_status
                invoke Write_at, addr Operand_name, Operand_name_index, char
                inc Operand_name_index
                mov Operand_type, reg_or_mem_type ;eax data

                lea esi, Operator_name
                mov edi, offset standard_opeator
                mov cl, 0
                .while cl < Operator_name_index
                    mov al, BYTE PTR[esi]
                    mov BYTE PTR[edi], al
                    inc esi
                    inc edi
                    inc cl
                .endw
            .elseif char >= '0' && char <='9'
                mov current_status, operand_one_status
                invoke Write_at, addr Operand_name, Operand_name_index, char
                inc Operand_name_index
                mov Operand_type, imm_type ;12

                lea esi, Operator_name
                mov edi, offset standard_opeator
                mov cl, 0
                .while cl < Operator_name_index
                    mov al, [esi]
                    mov [edi], al
                    inc esi
                    inc edi
                    inc cl
                .endw
            .elseif char == '['
                mov current_status, operand_one_status
                mov indirect_flag, 1    ;indirect
            .elseif char == ':'
                mov current_status, start_status
                invoke process_jump_label, addr Operator_name, Operator_name_index, current_address_pointer
                
            .endif
        .elseif current_status == operand_one_status
            .if (char >= 'a' && char <= 'z') || (char >= 'A' && char <= 'Z')
                invoke Write_at, addr Operand_name, Operand_name_index, char
                inc Operand_name_index
            .elseif char >= '0' && char <='9'
                invoke Write_at, addr Operand_name, Operand_name_index, char
                inc Operand_name_index
            .elseif (char == ' ') || (char == ',') || (char == ']')
                invoke check_endp, Operand_name
                .if eax == 1
                    jmp final
                .endif
                mov current_status, after_operand_one_status
                invoke process_operand, addr Operand_name, Operand_name_index, Operand_type, indirect_flag

                invoke ClearString, addr Operand_name, Operand_name_index
                mov Operand_name_index, 0
                mov indirect_flag, 0
            .elseif char == 0 || char == 10 || char == 13
                mov current_status, start_status
                invoke process_operand, addr Operand_name, Operand_name_index, Operand_type, indirect_flag
                invoke ClearString, addr Operand_name, Operand_name_index
                mov Operand_name_index, 0


                invoke generate_binary_code, offset standard_opeator, offset standard_operand_one, offset standard_operand_two, 1, current_address_pointer; TODO

            .endif
        .elseif current_status == after_operand_one_status
            .if (char >= 'a' && char <= 'z') || (char >= 'A' && char <= 'Z')
                mov current_status, operand_two_status
                 invoke Write_at, addr Operand_name, Operand_name_index, char
                inc Operand_name_index
                mov Operand_type, reg_or_mem_type
            .elseif (char >= '0' && char <= '9')
                mov current_status, operand_two_status
                 invoke Write_at, addr Operand_name, Operand_name_index, char
                inc Operand_name_index
                mov Operand_type, imm_type
            .elseif char == '['
                mov current_status, operand_two_status
                mov indirect_flag, 1
            .elseif char == 0 || char == 10 || char == 13
                mov current_status, start_status

                invoke generate_binary_code, offset standard_opeator, offset standard_operand_one, offset standard_operand_two, 1, current_address_pointer; TODO

            .endif
        .elseif current_status == operand_two_status
            .if (char >= 'a' && char <= 'z') || (char >= 'A' && char <= 'Z')
                 invoke Write_at, addr Operand_name, Operand_name_index, char
                inc Operand_name_index
            .elseif (char >= '0' && char <= '9')
                 invoke Write_at, addr Operand_name, Operand_name_index, char
                inc Operand_name_index
            .elseif char == ' ' || char == 0 || char == 10 || char == 13 || char == ']'
                mov current_status, start_status
                invoke process_operand, addr Operand_name, Operand_name_index, Operand_type, indirect_flag

                invoke ClearString, addr Operand_name, Operand_name_index
                mov Operand_name_index, 0
                mov indirect_flag, 0

                invoke generate_binary_code, offset standard_opeator, offset standard_operand_one, offset standard_operand_two, 2, current_address_pointer; TODO

            .endif
        .endif
    .endw
final:
        ret
instruction_tokenizer ENDP

code_tokenizer PROC,
    start_context: DWORD,
    max_length: DWORD

    LOCAL address_space     :DWORD,
          proc_name[20]     :BYTE,
          proc_label[10]    :BYTE,
          current_status    :BYTE,
          char              :BYTE,
          proc_name_index   :BYTE,
          proc_label_index  :BYTE

    mov address_space, 0
    mov proc_name_index, 0
    mov proc_label_index, 0
    mov edx, start_context
    mov ecx, 0
    mov current_status, start_status
L1:
		push eax
		mov al, BYTE PTR[edx]
        mov char, al
		pop eax
        .if( current_status == start_status)
            .if (char >= 'a' && char <= 'z') || (char >= 'A' && char <= 'Z')
                mov current_status, proc_name_status
                 invoke Write_at, addr proc_name, proc_name_index, char
                inc proc_name_index
            .endif;Error process
        .elseif (current_status == proc_name_status)
            .if (char >= 'a' && char <= 'z') || (char >= 'A' && char <= 'Z')
                invoke Write_at, addr proc_name, proc_name_index, char
                inc proc_name_index
            .elseif (char == ' ')
                mov current_status, after_proc_name_status
            .endif
        .elseif (current_status == after_proc_name_status)
            .if (char >= 'a' && char <= 'z') || (char >= 'A' && char <= 'Z')
                mov current_status, proc_label_status
                invoke Write_at, addr proc_name, proc_name_index, char
                inc proc_label_index
            .endif
        .elseif (current_status == proc_label_status)
            .if (char >= 'a' && char <= 'z') || (char >= 'A' && char <= 'Z')
                invoke Write_at, addr proc_name, proc_name_index, char
                inc proc_label_index
            .elseif (char == ' ') || (char == 0) || (char == 10) || (char == 13)
                mov current_status, start_status
                invoke check_proc_label, addr proc_label
                .if (eax == 1)
                    mov edi, start_context
                    add edi, max_length

                    invoke instruction_tokenizer, edx, edi, addr address_space; Pay attention to the following inc ecx

                .endif
			.endif
        .else
        .endif 
        inc ecx
        inc edx
    cmp ecx, max_length
    jne L1
	ret
code_tokenizer ENDP

END
