.386
.MODEL flat, stdcall

include data_proc.inc
include functions.inc
include Irvine32.inc
include translator.inc
includelib Irvine32.lib

.data
add_table 
operand_mapping_element<80h, reg_or_mem_type, 1, imm_type, 1, 0, 0>
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

sub_table
operator_mapping_element<"ADD", 11, offset add_table>

aggregate_table :operator_mapping_list <1, offset sub_table>

.code
find_opcode PROC
    operator_address    :PTR BYTE,
    operand_one_type    :BYTE,
    operand_two_type    :BYTE,
    operand_one_size    :BYTE,
    operand_two_size    :BYTE
    LOCAL   opcode      :BYTE,
            encoded     :BYTE,
            digit       :BYTE
     
    pushad
    mov ecx, aggregate_table.length
    mov esi, aggregate_table.start_of_list
    mov edx, 0

    mov eax, operator_address
    .while edx < ecx
        invoke Str_compare, eax, esi
        je next
        inc edx
        add esi, sizeof operator_mapping_element
    .endw
    ;process error TODO
next:
    ;esi points to the correct concrete table
    mov ecx, [esi + 10]
    mov esi, [esi + 14]

    mov al, operand_one_type
    mov ah, operand_two_type

    mov dl, [esi+2] ;size
    mov dh, [esi+4]
    .while edx < ecx
        mov bl, [esi+1];type
        mov bh, [esi+3]
        .if (al == bl) && (ah == bh)
            .if (operand_one_size == dl) && (operand_two_size == dh)
                jmp next2
            .endif
        .elseif (bl == reg_or_mem_type && (al == reg_type || al == mem_type)) && (ah == bh)
            .if (operand_one_size == dl) && (operand_two_size == dh)
                jmp next2
            .endif
        .elseif (al == bl) && ((ah == reg_type || ah == mem_type) && bh == reg_or_mem_type)
            .if (operand_one_size == dl) && (operand_two_size == dh)
                jmp next2
            .endif
        .endif
        inc edx
        add esi, sizeof operand_mapping_element
    .endw
next2:
    ;esi points to the correct item
    mov bl, [esi]
    mov opcode, bl

    mov bl, [esi+5]
    mov encoded, bl

    mov bl, [esi+6]
    mov digit, bl
    popad  
    mov al, opcode
    mov ah, encoded
    mov bl, digit
    ret
find_opcode ENDP

generate_binary_code PROC
    operator_address    :PTR BYTE,
    operand_one_address :PTR Operand,
    operand_two_address :PTR Operand,
    valid_oprand_count  :DWORD
    LOCAL   opcode      :BYTE,
            encoded     :BYTE,
            digit       :BYTE,
            mod_        :BYTE,
            reg_        :BYTE,
            rm_         :BYTE

    .if valid_oprand_count == 2
        mov esi, operand_one_address
        mov edi, operand_two_address
        mov bl, (Operand PTR[esi]).op_type
        mov bh, (Operand PTR[edi]).op_type
        mov cl, (Operand PTR[esi]).op_size
        mov ch, (Operand PTR[edi]).op_size

        invoke find_opcode, operator_address, bl, bh, cl, ch; return opcode:
        mov opcode, al
        mov encoded, ah
        mov digit, bl
        
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
            ret
        .elseif bl == mem_type
            ;return ax
        .endif
    .endif

generate_binary_code ENDP