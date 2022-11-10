.386
.MODEL flat, stdcall

include data_proc.inc
include functions.inc
include Irvine32.inc
include translator.inc
includelib Irvine32.lib

.data
add_table  operand_mapping_element<80h, reg_or_mem_type, 1, imm_type, 1, 0, 0>
operand_mapping_element<81h, reg_or_mem_type, 2, imm_type, 2, 0, 0>
operand_mapping_element<81h, reg_or_mem_type, 4, imm_type, 4, 0, 0>
operand_mapping_element<83h, reg_or_mem_type, 2, imm_type, 1, 0, 0>
operand_mapping_element<83h, reg_or_mem_type, 4, imm_type, 1, 0, 0>

operand_mapping_element<00h, reg_or_mem_type, 1, reg_type, 1, 0, 0>
operand_mapping_element<01h, reg_or_mem_type, 2, reg_type, 2, 0, 0>
operand_mapping_element<01h, reg_or_mem_type, 4, reg_type, 4, 0, 0>

operand_mapping_element<02h, reg_type, 1, reg_or_mem_type, 1, 0, 0>
operand_mapping_element<03h, reg_type, 2, reg_or_mem_type, 2, 0, 0>
operand_mapping_element<03h, reg_type, 4, reg_or_mem_type, 4, 0, 0>


inter_table operator_mapping_element <"ADD", 11, offset add_table>

aggregate_table operator_mapping_list <1, offset inter_table>

.code
operator_compare PROC,
	op1	:DWORD,
	op2	:DWORD

	LOCAL flag :DWORD

	pushad
	mov ecx, 3
	mov edi, op1
	mov esi, op2
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
	popad
	mov ebx, flag
	ret
operator_compare ENDP

find_opcode PROC,
    operator_address    :PTR BYTE,
    operand_one_type    :BYTE,
    operand_two_type    :BYTE,
    operand_one_size    :BYTE,
    operand_two_size    :BYTE

    LOCAL   opcode      :BYTE,
            encoded     :BYTE,
            digit       :BYTE
     
    pushad
	mov esi, offset aggregate_table
    mov ecx, (operator_mapping_list PTR[esi]).len
    mov esi, (operator_mapping_list PTR[esi]).start_of_list
    mov edx, 0

    mov eax, operator_address
    .while edx < ecx
        invoke operator_compare, eax, esi 
        .if ebx == 1
			jmp next
		.endif
        inc edx
        add esi, sizeof operator_mapping_element
    .endw
    ;process error TODO
next:
    ;esi points to the correct concrete table
    mov ecx, [esi + 8] ;len of MOV list
    mov esi, [esi + 12] ;start of MOV list

    mov al, operand_one_type
    mov ah, operand_two_type
    .if al == indirect_type
        mov al, reg_or_mem_type
    .endif
    .if ah == indirect_type
        mov ah, reg_or_mem_type
    .endif
   
    mov edx, 0
    .while edx < ecx
        mov bl, [esi+1];type
        mov bh, [esi+3]
        .if (al == bl) && (ah == bh)
            mov bl, [esi+2]
            mov bh, [esi+4]
            .if (operand_one_size == bl) && (operand_two_size == bh)
                jmp next2
            .endif
        .elseif (bl == reg_or_mem_type && (al == reg_type || al == mem_type)) && (ah == bh)
            mov bl, [esi+2]
            mov bh, [esi+4]
            .if (operand_one_size == bl) && (operand_two_size == bh)
                jmp next2
            .endif
        .elseif (al == bl) && ((ah == reg_type || ah == mem_type) && bh == reg_or_mem_type)
            mov bl, [esi+2]
            mov bh, [esi+4]
            .if (operand_one_size == bl) && (operand_two_size == bh)
                jmp next2
            .endif
        .endif
        inc edx
        add esi, sizeof operand_mapping_element
    .endw
next2:
    ;esi points to the correct item

    mov bh, [esi]
    mov opcode, bh

    mov bh, [esi+5]
    mov encoded, bh

    mov bh, [esi+6]
    mov digit, bh
    popad  
    mov al, opcode
    mov ah, encoded
    mov bl, digit
    ret
find_opcode ENDP

generate_binary_code PROC,
    operator_address    :PTR BYTE,
    operand_one_address :PTR Operand,
    operand_two_address :PTR Operand,
    valid_oprand_count  :DWORD,
    current_address_pointer :DWORD

    LOCAL   opcode      :BYTE,
            encoded     :BYTE,
            digit       :BYTE,;
            mod_        :BYTE,
            reg_        :BYTE,
            rm_         :BYTE,
            modRM       :BYTE,
            displacement:DWORD,
            immediate   :DWORD,
            total_bytes :DWORD
    
	mov eax, 0
    mov total_bytes, eax
    .if valid_oprand_count == 2
        mov esi, operand_one_address
        mov edi, operand_two_address
        mov bl, (Operand PTR[esi]).op_type
        mov bh, (Operand PTR[edi]).op_type
        mov cl, (Operand PTR[esi]).op_size
        mov ch, (Operand PTR[edi]).op_size

		pushad
        invoke find_opcode, operator_address, bl, bh, cl, ch; return opcode:
        mov opcode, al
        mov encoded, ah
        mov digit, bl
		popad
        
        .if bl == reg_type && bh == reg_type
            mov mod_, 3 ;11b
            mov esi, (Operand PTR[esi]).address
            mov al, (RegOperand PTR[esi]).reg
            mov edi, (Operand PTR[edi]).address
            mov ah, (RegOperand PTR[edi]).reg
            mov reg_, al
            mov rm_, ah

            shl mod_, 6
            shl reg_, 3
            mov al, 0
            add al, mod_
            add al, reg_
            add al, rm_
            mov ah, opcode
            mov ebx, TYPE WORD
            invoke WriteHexB
            mov eax, 1
            mov total_bytes, eax
        .elseif bl == reg_type && bh == imm_type 
            mov edi, (Operand PTR[edi]).address; TODO store as 32bits value
            mov eax, (ImmOperand PTR[edi]).value
            mov immediate, eax
            mov esi, (Operand PTR[esi]).address
            mov al, (RegOperand PTR[esi]).reg
            add opcode, al
            
            mov al, opcode
            mov ebx, TYPE BYTE
            invoke WriteHexB

            mov eax, immediate
            mov ebx, TYPE DWORD
            invoke WriteHexB 
            mov eax, 5
            mov total_bytes, eax
            ;return ax
        .elseif (bl == mem_type && bh == reg_type) || (bl == reg_type && bh == mem_type)
            .if bl == mem_type
                mov esi, operand_two_address ; esi points to register
                mov edi, operand_one_address
            .endif
            mov esi, (Operand PTR[esi]).address
            mov edi, (Operand PTR[edi]).address ;global address

            mov al, 0
            mov mod_, al
            mov al, (RegOperand PTR[esi]).reg
            mov reg_, al
            mov al, 110b
            mov rm_, al

            shl mod_, 6
            shl reg_, 3
            mov al, 0
            add al, mod_
            add al, reg_
            add al, rm_
            mov modRM, al

            mov displacement, edi

            mov al, opcode
            mov ebx, TYPE BYTE
            invoke WriteHexB

            mov al, modRM
            mov ebx, TYPE BYTE
            invoke WriteHexB

            mov eax, displacement
            mov ebx, TYPE DWORD
            invoke WriteHexB 
            mov eax, 6
            mov total_bytes, eax
         ;TODO indirect type 在search table 中要处理为reg_or_mem_type
        .elseif bl == indirect_type && bh == imm_type; Whether valid

        .elseif (bl == indirect_type && bh == reg_type) || (bl == reg_type && bh == indirect_type)
            .if bl == indirect_type
                mov esi, operand_two_address    ;reg
                mov edi, operand_one_address
                mov al, 0
                mov mod_, al
                
                mov esi, (Operand PTR[esi]).address
                mov edi, (Operand PTR[edi]).address

                mov al, (RegOperand PTR[esi]).reg
                mov reg_, al 

                mov al, (RegOperand PTR[edi]).reg
                mov rm_, al

                shl mod_, 6
                shl reg_, 3
                mov al, 0
                add al, mod_
                add al, reg_
                add al, rm_
                mov modRM, al

                mov al, opcode
                mov ebx, TYPE BYTE
                invoke WriteHexB

                mov al, modRM
                mov ebx, TYPE BYTE
                invoke WriteHexB
                mov eax, 2
                mov total_bytes, eax
            .endif

        .endif
    .endif
    ;TODO return total bytes in eax
    mov eax, total_bytes

    ret
generate_binary_code ENDP

END