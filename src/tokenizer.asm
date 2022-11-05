;TODO data_tokenizer code_tokenizer instruction_tokenizer
.386
.MODEL flat, stdcall

include tokenizer.inc
include data_proc.inc
include functions.inc
.data
standard_opeator    :DWORD
srandard_operand_one:Operand
standard_operand_two:Operand

register_to_binary_list register_string_to_standard<"AX", >
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

process_operand PROC
    operand_name        :DWORD
    operand_name_len    :BYTE
    operand_position    :BYTE   ; 1 or 2
    
    invoke find_symbol, offset data_name_list, offset operand_name
    .if ebx != 0
        invoke data_name_to_standard_operand, ebx, operand_position
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

instruction_tokenizer PROC
    proc_start_context   :DWORD,
    code_end_context     :DWORD,
    current_address      :DWORD,

    LOCAL   current_status      :BYTE,
            char                :BYTE,
            Operator_name[10]   :BYTE,
            Operand_name[20]    :BYTE,
            Operand_one_info    :Operand,
            Operand_two_info    :Operand,
            Operator_name_index :BYTE,
            Operand_name_index  :BYTE,
            Operand_type        :BYTE,
    pushad
    mov Operator_name_index, 0
    mov Operand_name_index, 0
    mov edx, proc_start_context
    mov current_status, start_status
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
            .elseif char == ' '
                mov current_status, after_operand_one_status
                invoke process_operand, offset Operand_name, Operand_name_index, Operand_type

                invoke ClearString, offset Operand_name, Operand_name_index
                mov Operand_name_index, 0
            .endif
        .elseif current_status == after_operand_one_status
            .if (char >= 'a' && char <= 'z') || (char >= 'A' && char <= 'Z')
                mov current_status, operand_two_status
                mov esi, offset Operand_name
                add esi, Operator_name_index
                mov al, char
                mov [esi], al
                inc Operand_name_index
            .elseif char == 0 | char == 10 || char == 13
                mov current_status, start_status
                invoke generate_binary_code; TODO
            .endif
        .elseif current_status == operand_two_status
            .if (char >= 'a' && char <= 'z') || (char >= 'A' && char <= 'Z')
                mov esi, offset Operand_name
                add esi, Operator_name_index
                mov al, char
                mov [esi], al
                inc Operand_name_index
            .elseif char == ' ' || char == 0 | char == 10 || char == 13
                mov current_status, start_status
                invoke process_operand, offset Operand_name, Operand_name_index, Operand_type

                invoke ClearString, offset Operand_name, Operand_name_index
                mov Operand_name_index, 0
                invoke generate_binary_code; TODO
            .endif
        .endif
    .endw



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
                    invoke instruction_tokenizer, edx, edi, address_space; Pay attention to the following inc ecx
                .endif
        .endif 
        inc ecx
        inc edx
    .endw
code_tokenizer ENDP