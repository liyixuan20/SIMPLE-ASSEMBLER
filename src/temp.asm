.code
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
                mov esi, offset proc_name
                add esi, proc_name_index
                mov al, char
                mov BYTE PTR[esi], al
                inc proc_name_index
            .endif;Error process
        .elseif (current_status == proc_name_status)
            .if (char >= 'a' && char <= 'z') || (char >= 'A' && char <= 'Z')
                mov esi, offset proc_name
                add esi, proc_name_index
                mov al, char
                mov BYTE PTR[esi], al
                inc proc_name_index
            .elseif (char == ' ')
                mov current_status, after_proc_name_status
            .endif
        .elseif (current_status == after_proc_name_status)
            .if (char >= 'a' && char <= 'z') || (char >= 'A' && char <= 'Z')
                mov current_status, proc_label_status
                mov esi, offset proc_label
                add esi, proc_label_index
                mov al, char
                mov BYTE PTR[esi], al
                inc proc_label_index
            .endif
        .elseif (current_status == proc_label_status)
            .if (char >= 'a' && char <= 'z') || (char >= 'A' && char <= 'Z')
                mov esi, offset proc_label
                add esi, proc_label_index
                mov al, char
                mov BYTE PTR[esi], al
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
