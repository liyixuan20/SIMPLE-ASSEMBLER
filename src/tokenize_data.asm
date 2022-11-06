.386
.MODEL flat, stdcall

include tokenizer.inc
include data_proc.inc
include functions.inc
include Irvine32.inc
includelib Irvine32.lib
.data
var_name BYTE 256 DUP(0)
var_type BYTE 16 DUP(0)

byte_name BYTE "BYTE", 0
word_name BYTE "WORD", 0
dword_name BYTE "DWORD", 0
data_num BYTE 16 DUP(0)
.code
;return al = corresponding size
convert_type_to_size PROC USES ebx ecx edx esi,
    start_addr: DWORD
    INVOKE Str_ucase, start_addr
    mov al, 0
    INVOKE Str_compare, start_addr, ADDR byte_name
    je byte_type
	INVOKE Str_compare, start_addr, ADDR word_name
	je word_type
	INVOKE Str_compare, start_addr, ADDR dword_name
	je dword_type
	mov al, 0
	ret
byte_type:
	mov al, 1
	ret
word_type:
	mov al, 2
	ret
dword_type:
	mov al, 4
	ret
convert_type_to_size ENDP   

Clear_String_DWORD PROC,
	start_address   :DWORD,
    len             :DWORD

    pushad
    mov ecx, 0
    mov esi, start_address
    .while ecx < len
        mov al, 0
        mov [esi], al
        inc esi
        inc ecx
    .endw
	popad
	ret
Clear_String_DWORD ENDP


tokenize_data_segment PROC USES ebx ecx edx esi edi,
    start_address: DWORD,
    max_bytes: DWORD

    LOCAL data_address: DWORD, line_section: BYTE, number_count: DWORD,
		  is_line_start:BYTE, name_length:DWORD, type_length:DWORD,
		  type_size : BYTE, flag_quote:BYTE, flag_dot:BYTE, size_count:DWORD,data_size:BYTE,
		  is_digit:BYTE, dup_length:DWORD

    mov ecx, max_bytes
	mov esi, start_address

	;对数据初始化为0
	mov data_address, 0
	mov line_section, 0
	mov number_count, 0
	mov is_line_start, 0
	mov name_length, 0
	mov type_length, 0
	mov type_size, 0
    mov flag_quote, 0
    mov flag_dot, 0
    mov size_count, 0
    mov data_size, 0
	mov is_digit, 0
	mov dup_length, 0
data_process:
    mov bl, [esi]
    inc number_count
	.IF bl == 32 ;space
		.IF is_line_start
			inc line_section
		.ENDIF
	.ELSEIF bl == 46 ; .
		.IF flag_quote == 0
			INVOKE judge_segment, esi
			.IF al == 2
				add number_count, 4
				jmp end_tokenize
			.ENDIF
		.ENDIF
	.ELSEIF bl == 10 || bl == 13 ; 换行后将该行的内容存储到data_label_list中
		.IF is_line_start
			mov is_line_start, 0
			mov line_section, 0
			mov name_length, 0
			mov type_length, 0
			mov data_size, 0

			mov dl, type_size
			INVOKE push_symbol_list,
				ADDR data_symbol_list,
				ADDR var_name,
				data_address,
				dl
			INVOKE Clear_String_DWORD, offset var_name, name_length
			INVOKE Clear_String_DWORD, offset var_type, type_length
			.IF size_count == 0
				inc size_count
			.ENDIF
			mov eax, size_count
			mul type_size
			add data_address, eax
			mov size_count, 0
			mov type_size, 0
		.ENDIF
	.ELSE 
		.IF is_line_start == 0
			mov is_line_start, 1
		.ENDIF

		.IF line_section == 0
			mov edi, OFFSET var_name
			add edi, name_length
			inc name_length
			mov [edi], bl
		.ELSEIF line_section == 1
			mov edi, OFFSET var_type
			add edi, type_length
			inc type_length
			mov [edi], bl
		.ELSEIF line_section == 2
			.IF (bl >= '0' && bl <= '9') && (flag_quote == 0)
				.IF is_digit == 0
					mov is_digit, 1
				.ENDIF
				mov edi, OFFSET data_num
				add edi, dup_length
				inc dup_length
				mov [edi], bl
			.ENDIF
			.IF type_size == 0
				; append \0
				mov edi, OFFSET var_name
				add edi, name_length
				mov dl, 0
				mov [edi], dl
				mov edi, OFFSET var_type
				add edi, type_length
				mov [edi], dl
				
				INVOKE convert_type_to_size, ADDR var_type
				
				mov type_size, al
			.ENDIF
			.IF type_size == 1 ; 处理字符串
				.IF bl == 34 ; quote
					.IF flag_quote == 0
						mov flag_quote, 1
					.ELSE
						mov flag_quote, 0
					.ENDIF
				.ELSEIF flag_quote
					inc size_count
				.ELSEIF bl == 44 ;comma
					.IF size_count == 0
						inc size_count
					.ENDIF
					inc size_count
				.ELSE
					jmp loop_L1
				.ENDIF
			.ENDIF	
		.ELSEIF line_section >= 3
			.IF bl == 44
				.IF size_count == 0
					inc size_count
				.ENDIF
				inc size_count
			.ENDIF
			.IF bl == 'D'
				push eax
				push edx
				push ecx
				mov dl, [esi+1]
				mov cl, [esi+2]
				.IF (dl == 'U') && (cl == 'P') && (is_digit == 1)
					mov edx, OFFSET data_num
					mov ecx, dup_length
					invoke ParseInteger32
					add size_count, eax
				.ENDIF
				INVOKE Clear_String_DWORD, offset data_num, dup_length
				mov is_digit, 0
				mov dup_length, 0
				
				pop ecx
				pop edx
				pop eax
			.ENDIF
		.ENDIF
	.ENDIF
loop_L1:
	inc esi
	dec ecx
	cmp ecx, 0
	jne data_process

end_tokenize:
	mov eax, number_count
	ret
tokenize_data_segment ENDP

END

				
