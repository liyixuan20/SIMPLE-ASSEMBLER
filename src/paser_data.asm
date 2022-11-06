.386
.MODEL flat, stdcall

include data_proc.inc
include functions.inc
include Irvine32.inc
includelib Irvine32.lib

.data
proc_labels Symbol_Elem 256 DUP(<256 DUP(0), 0, 0>)
proc_symbol_list Symbol_List <0, offset proc_labels>

code_labels Symbol_Elem 256 DUP(<256 DUP(0), 0, 0>)
code_symbol_list Symbol_List <0, offset code_labels>

data_labels Symbol_Elem 256 DUP(<256 DUP(0), 0, 0>)
data_symbol_list Symbol_List <0, offset data_labels>

.code

;将symbol push 到相应list中， 如已满返回eax-1
push_symbol_list PROC USES ebx  edx esi edi,
    list_offset: DWORD,
    symbolname: DWORD,
    address: DWORD,
    op_size: BYTE

    LOCAL len:dword
    mov edx, list_offset

    inc (Symbol_List PTR[edx]).len
    mov eax, (Symbol_List PTR[edx]).len
    mov len, eax
    .IF len > 256
        mov eax, -1
        ret
    .ENDIF
    
    mov ebx, (Symbol_List PTR[edx]).address
    mov eax, 0
    mov eax, sizeof Symbol_Elem
    mul len 
    add ebx, eax
    

    lea edi, (Symbol_Elem PTR[ebx]).symbol_name
    invoke Str_copy, symbolname, edi

    
    mov eax, address
    mov (Symbol_Elem PTR[ebx]).address, eax
    
    
    mov al, op_size
    mov (Symbol_Elem PTR[ebx]).op_size, al

    mov eax, 0
    ret
push_symbol_list ENDP

find_symbol PROC USES eax ecx edx esi edi,  ;return the address stored in ebx
    list_offset:dword,
    symbolname: dword

    LOCAL len:dword

    mov edx, list_offset
    mov eax, (Symbol_List PTR[edx]).len
    mov len, eax
    
    mov ecx, 0
    mov ecx, len
    mov eax, 0
    mov ebx, (Symbol_List PTR[edx]).address

    L1:
        lea esi, (Symbol_Elem PTR[ebx]).symbol_name
        invoke Str_compare, esi, symbolname
        je find

        add ebx, sizeof Symbol_Elem

    LOOP L1
    
    mov ebx, 0
    ret
    find:
        ret
 find_symbol   ENDP


end