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