.386
.MODEL flat, stdcall

ExitProcess PROTO, dwExitCode: DWORD
process_file PROTO,
    file_path : PTR BYTE

push_symbol_list PROTO,
    list_offset: DWORD,
    symbolname: DWORD,
    address: DWORD,
    op_size: BYTE

find_symbol PROTO,
    list_offset: DWORD,
    symbolname: DWORD

;检测是否是数据段or代码段，数据段al返回1，代码段返回2，否则返回0
judge_segment PROTO,
    address : PTR BYTE

tokenize_data_segment PROTO,
    start_address: DWORD,
    max_bytes: DWORD

ClearString PROTO,
    start_address   :DWORD,
    len             :BYTE

    
judge_string_type PROTO, 
    part_order: BYTE,
    string_len: DWORD,
    flag: PTR BYTE

get_reg_num PROTO,
    start_address: PTR BYTE

parse_index_scale PROTO,
    start_addr:PTR BYTE,
    string_len:DWORD,
    index: PTR BYTE,
    scale: PTR BYTE

add_byte_to_string PROTO,
    value:BYTE,
    pos:DWORD,
    count:BYTE

parse_indirect_address PROTO,
    start_addr: PTR BYTE,
    ind_operand: PTR LocalOperand

register_name_to_standard_operand PROTO,
    operand_pointer     :DWORD,
    operand_name_pointer:DWORD,
    indirect_flag       :BYTE

imm_to_standard_operand PROTO,
    operand_pointer     :DWORD,
    imm_name_pointer    :DWORD,
    imm_name_len        :DWORD

process_operand PROTO,
    operand_name        :DWORD,
    operand_name_len    :BYTE,
    operand_position    :BYTE,  
    indirect_flag       :BYTE

check_proc_label PROTO,  ;True:eax=1   False:eax=0
    proc_label_address: DWORD

check_endp PROTO,
    operand_name    :DWORD

instruction_tokenizer PROTO,
    proc_start_context   :DWORD,
    code_end_context     :DWORD,
    current_address      :DWORD

code_tokenizer PROTO,
    start_context: DWORD,
    max_length: DWORD

;translator
;--------------------------
find_opcode PROTO,
    operator_address    :PTR BYTE,
    operand_one_type    :BYTE,
    operand_two_type    :BYTE,
    operand_one_size    :BYTE,
    operand_two_size    :BYTE

generate_binary_code PROTO,
    operator_address    :PTR BYTE,
    operand_one_address :PTR Operand,
    operand_two_address :PTR Operand,
    valid_oprand_count  :DWORD


;--------------------------
