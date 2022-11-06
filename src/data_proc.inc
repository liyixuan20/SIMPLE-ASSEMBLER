;存储symbol（即可能出现的codelabel proclabel datalabel等）
Symbol_List STRUCT
    len DWORD ?
    address DWORD ?
Symbol_List ENDS

;symbol_list中的元素
Symbol_Elem STRUCT
    symbol_name BYTE 256 DUP(0)
    op_size BYTE ?
    address DWORD ?
Symbol_Elem ENDS

externdef proc_symbol_list : Symbol_List
externdef code_symbol_list : Symbol_List
externdef data_symbol_list : Symbol_List

;操作数
Operand STRUCT
    op_type byte ?
    op_size byte ?
    align DWORD
    address DWORD ?
Operand ENDS

;操作数是立即数
ImmOperand STRUCT
    value sdword ?
ImmOperand ENDS

;操作数是寄存器
RegOperand STRUCT
    reg byte ?
RegOperand ENDS

;操作数是.data中定义
DataOperand STRUCT
    value sdword ?
DataOperand ENDS

;操作数是间接寻址
IndirectAddOperand STRUCT
    base byte ?
    index byte ?
    scale byte ?
    align dword
    bias sdword ?
IndirectAddOperand ENDS

;操作数等于求偏移量，如jmp 后的code label call 后的proc label
OffsetOperand STRUCT
    bias sdword ?
OffsetOperand ENDS


;对不同寄存器做一个数据映射，以便后续进行对照
EAX_NUM = 0000b
ECX_NUM = 0001b
EDX_NUM = 0010b
EBX_NUM = 0011b
ESP_NUM = 0100b
EBP_NUM = 0101b
ESI_NUM = 0110b
EDI_NUM = 0111b
FULL_NUM = 1111b ;做检查num值用
bit32 = 0000b
bit16 = 0001b 
bitlow8 = 0010b 
bithigh8 = 0011b

;operand types
null_type = 00000000b
reg_type = 00000001b
imm_type = 00000010b
data_type = 00000100b
indirect_type = 00001000b
offset_type = 00010000b
mem_type = 00001100b
reg_or_mem_type = 00001101b

 ;regmap size对应字节数而非位数   