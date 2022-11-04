;TODO data_tokenizer code_tokenizer instruction_tokenizer
.386
.MODEL flat, stdcall

include tokenizer.inc
include data_proc.inc
.data

.code
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
    address_space        :DWORD,

    LOCAL   current_status      :BYTE,
            char                :BYTE,
            Operator_info[10]   :BYTE,
            Operand_one_info    :Operand,
            Operand_two_info    :Operand,
    pushad
    mov edx, proc_start_context
    .while edx < code_end_context
        mov char, [edx]
        inc edx
        .if char
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