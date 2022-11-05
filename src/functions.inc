.386
.MODEL flat, stdcall

ExitProcess PROTO, dwExitCode: DWORD

push_symbol_list PROTO,
    list_offset: DWORD,
    symbolname: DWORD,
    address DWORD,
    op_size BYTE

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

    