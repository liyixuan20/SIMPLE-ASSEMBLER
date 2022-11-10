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

register_to_binary_list register_string_to_standard<"al", 0>
register_string_to_standard<"bl", 3>
register_string_to_standard<"cl", 1>
register_string_to_standard<"dl", 2>
register_string_to_standard<"ah", 4>
register_string_to_standard<"bh", 7>
register_string_to_standard<"ch", 5>
register_string_to_standard<"dh", 6>
register_string_to_standard<"ax", 0>
register_string_to_standard<"bx", 3>
register_string_to_standard<"cx", 1>
register_string_to_standard<"dx", 2>
register_string_to_standard<"si", 6>
register_string_to_standard<"di", 7>
register_string_to_standard<"sp", 4>
register_string_to_standard<"bp", 5>
register_string_to_standard<"eax",0>
register_string_to_standard<"ebx",3>
register_string_to_standard<"ecx",1>
register_string_to_standard<"edx",2>
register_string_to_standard<"esi",6>
register_string_to_standard<"edi",7>
register_string_to_standard<"esp",4>
register_string_to_standard<"ebp",5>
.code

myStringCompare PROC USES eax ecx edi ebx,
	start_address	:DWORD,
	start_address_t	:DWORD
	
	LOCAL flag		:DWORD
	
    mov edi, start_address
    mov esi, start_address_t

    mov al, [edi]
    .if al == 'e'
        mov ecx, 3
    .else
        mov ecx, 2
    .endif
    mov ebx, 1
    L1:
    mov al, [edi]
    mov ah, [esi]
    .if al != ah
        mov ebx, 0
    .endif
	inc edi
	inc esi
    loop L1
    mov flag, ebx
    
    mov esi, flag
    ret

myStringCompare ENDP

ClearString PROC USES ecx eax esi,
    start_address   :DWORD,
    len             :BYTE

    
    mov cl, 0
    mov esi, start_address
    .while cl < len
        mov al, 0
        mov BYTE PTR[esi], al
        inc esi
        inc cl
    .endw
	
	ret
ClearString ENDP

register_name_to_standard_operand PROC USES eax ebx ecx edx edi esi,
    operand_pointer      :DWORD,
    operand_name_pointer :DWORD,
    indirect_flag        :BYTE
	

    mov eax, operand_pointer
    mov ebx, operand_name_pointer


    .if indirect_flag == 0
        mov (Operand PTR[eax]).op_type, reg_type
    .elseif indirect_flag == 1
        mov (Operand PTR[eax]).op_type, indirect_type ;TODO
    .endif
    mov ecx, 0
    mov edi, offset register_to_binary_list

    .while ecx < 24
        invoke myStringCompare ,ebx, edi
        .if esi == 1
            jmp next
        .endif
        inc ecx
        add edi, sizeof register_string_to_standard
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
    mov dl, (register_string_to_standard PTR[edi]).binary_name
    mov (RegOperand PTR[esi]).reg, dl
    ret
register_name_to_standard_operand ENDP

imm_to_standard_operand PROC USES ecx edx ebx esi eax,
    operand_pointer     :DWORD,
    imm_name_pointer    :DWORD,
    imm_name_len        :BYTE

    mov ecx, 0
    mov cl, imm_name_len
    mov edx, imm_name_pointer
    invoke ParseInteger32   ;return value in eax

    mov ebx, operand_pointer
    mov (operand PTR[ebx]).op_type, imm_type
    mov (operand PTR[ebx]).op_size, 4   ;Simplified--all treated as 32bits integer
    
    mov esi, (operand PTR[ebx]).address
    mov (ImmOperand PTR[esi]).value, eax
    ret
imm_to_standard_operand ENDP

data_name_to_standard_operand PROC USES edi esi eax,
	operand_address	:DWORD,
	operand_info    :DWORD

    mov edi, operand_address
    mov esi, operand_info

    mov (Operand PTR[edi]).op_type, data_type;op_type
    mov eax, (Symbol_Elem PTR[esi]).op_size ;op_size
    mov (Operand PTR[edi]).op_size, eax
    mov eax, (Symbol_Elem PTR[esi]).address ;address
    mov (Operand PTR[edi]).address, eax
	ret
data_name_to_standard_operand ENDP

process_jump_label PROC,
	operand_name_address :DWORD,
	operand_name_index	:DWORD,
	current_address		:DWORD
process_jump_label ENDP

process_operand PROC USES ebx,
    operand_name        :DWORD,
    operand_name_len    :BYTE,
    operand_position    :BYTE,  
    indirect_flag       :BYTE,
    operand_type        :BYTE

	
    
	mov ebx,0
    ;Case 1:imm_type
    .if operand_type == imm_type
        .if operand_position == 1
            invoke imm_to_standard_operand, addr standard_operand_one, operand_name, operand_name_len
        .elseif operand_position == 2
            invoke imm_to_standard_operand, addr standard_operand_two, operand_name, operand_name_len
        .endif
        ret
    .endif
    ;Case 2:data_label
    invoke find_symbol, addr data_symbol_list, addr operand_name
    .if ebx != 0
        .if operand_position == 1
            invoke data_name_to_standard_operand, addr standard_operand_one, ebx
            ret
        .elseif operand_position == 2
            invoke data_name_to_standard_operand, addr standard_operand_two, ebx
            ret
        .endif
    .endif
    ;invoke find_symbol, addr proc_symbol_list, addr operand_name;TODO
    ;.if ebx != 0
    ;TODO
    ;.endif
    ;invoke find_symbol, addr code_symbol_list, addr operand_name
    .if ebx != 0
    ;TODO
    .endif
    .if operand_position == 1
        invoke register_name_to_standard_operand, addr standard_operand_one, operand_name, indirect_flag
        ret
    .elseif operand_position == 2
        invoke register_name_to_standard_operand, addr standard_operand_two, operand_name, indirect_flag
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

check_endp PROC USES eax,
    operand_name    :DWORD
	push ebx
	push ecx
    mov esi, operand_name
	mov ah, [esi]
	mov bh, [esi+1]
	mov bl, [esi+2]
	mov bh, [esi+3]
    .if cl == 'E' && ch == 'N' && bl == 'D' && bh == 'P'
        mov eax, 1
    .elseif cl == 'e' && ch == 'n' && bl == 'd' && bh == 'p'
        mov eax, 1
    .endif
	pop ecx
	pop ebx
	
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

instruction_tokenizer PROC USES eax ebx ecx edx esi edi,
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
            indirect_flag       :BYTE,
			endp_flag			:BYTE
    
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
                ;invoke check_endp, Operand_name
				mov al, 0
				mov endp_flag, al
				push ebx
				push edi
				lea edi, Operand_name
				mov al, [edi]
				mov ah, [edi+1]
				mov bl, [edi+2]
				mov bh, [edi+3]
				.if (al == 'E') && (ah == 'N') && (bl == 'D') && (bh == 'P')
					mov al, 1
					mov endp_flag, al
				.elseif (al == 'e') && (ah == 'n') && (bl == 'd') && (bh == 'p')
					mov al, 1
					mov endp_flag, al
				.endif
				pop edi
				pop ebx
                .if endp_flag == 1
                    jmp final
                .endif
                push edx
                invoke process_operand, addr Operand_name, Operand_name_index, 1,  indirect_flag, Operand_type
                invoke ClearString, addr Operand_name, Operand_name_index
                mov Operand_name_index, 0
                mov indirect_flag, 0
				mov current_status, after_operand_one_status
				pop edx
            .elseif char == 0 || char == 10 || char == 13
            ;todo maybe endp
                mov current_status, start_status
                invoke process_operand, addr Operand_name, Operand_name_index, 1 , indirect_flag, Operand_type
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
                invoke process_operand, addr Operand_name, Operand_name_index, 2, indirect_flag, Operand_type

                invoke ClearString, addr Operand_name, Operand_name_index
                mov Operand_name_index, 0
                mov indirect_flag, 0
                invoke generate_binary_code, offset standard_opeator, offset standard_operand_one, offset standard_operand_two, 2, current_address_pointer; TODO
				ret
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
                invoke Write_at, addr proc_label, proc_label_index, char
                inc proc_label_index
            .endif
        .elseif (current_status == proc_label_status)
            .if (char >= 'a' && char <= 'z') || (char >= 'A' && char <= 'Z')
                invoke Write_at, addr proc_label, proc_label_index, char
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
    jle L1
	ret
code_tokenizer ENDP

END
