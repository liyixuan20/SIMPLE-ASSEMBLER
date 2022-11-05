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
    operator_address    :PTR BYTE
    operand_one_type    :BYTE
    operand_two_type    :BYTE
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
next:
    ;esi points to the correct concrete table
    mov ecx, [esi + 10]
    mov esi, [esi + 14]

    mov al, operand_one_type
    mov ah, operand_two_type

    mov edx, 0
    .while edx < ecx
        
    .endw
    popad   
find_opcode ENDP

generate_binary_code PROC
    operator_address    :PTR BYTE
    operand_one_address :PTR Operand
    operand_two_address :PTR Operand
    valid_oprand_count  :DWORD

    .if valid_oprand_count == 2
        mov esi, operand_one_address
        mov edi, operand_two_address
        mov bl, (Operand PTR[esi]).op_type
        mov bh, (Operand PTR[edi]).op_type
        invoke find_opcode, operator_address, bl, bh; return opcode:
    .endif

generate_binary_code ENDP