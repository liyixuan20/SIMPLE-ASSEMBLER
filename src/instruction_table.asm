.386
.MODEL flat, stdcall

include operand.inc
include instruction_table.inc

.data
; -------- tables begin here --------
; (the following code is just an example)

; ADD instruction
ADD_table_elems TableElem < 80h, reg_or_mem_type, 08h, imm_type, 08h, 0, 0 >
TableElem < 81h, reg_or_mem_type, 10h, imm_type, 10h, 0, 0 >
TableElem < 81h, reg_or_mem_type, 20h, imm_type, 20h, 0, 0 >
TableElem < 83h, reg_or_mem_type, 10h, imm_type, 08h, 0, 0 >
TableElem < 83h, reg_or_mem_type, 20h, imm_type, 08h, 0, 0 >
TableElem < 00h, reg_or_mem_type, 08h, reg_type, 08h, 0, 0 >
TableElem < 01h, reg_or_mem_type, 10h, reg_type, 10h, 0, 0 >
TableElem < 01h, reg_or_mem_type, 20h, reg_type, 20h, 0, 0 >
TableElem < 02h, reg_type, 08h, reg_or_mem_type, 08h, 0, 0 >
TableElem < 03h, reg_type, 10h, reg_or_mem_type, 10h, 0, 0 >
TableElem < 03h, reg_type, 20h, reg_or_mem_type, 20h, 0, 0 >

ADD_table Table < 11, OFFSET ADD_Table_elems>

; AND instruction
AND_table_elems TableElem < 80h, reg_or_mem_type, 08h, imm_type, 08h, 0, 4 >
TableElem < 81h, reg_or_mem_type, 10h, imm_type, 10h, 0, 4 >
TableElem < 81h, reg_or_mem_type, 20h, imm_type, 20h, 0, 4 >
TableElem < 83h, reg_or_mem_type, 10h, imm_type, 08h, 0, 4 >
TableElem < 83h, reg_or_mem_type, 20h, imm_type, 08h, 0, 4 >
TableElem < 20h, reg_or_mem_type, 08h, reg_type, 08h, 0, 0 >
TableElem < 21h, reg_or_mem_type, 10h, reg_type, 10h, 0, 0 >
TableElem < 21h, reg_or_mem_type, 20h, reg_type, 20h, 0, 0 >
TableElem < 22h, reg_type, 08h, reg_or_mem_type, 08h, 0, 0 >
TableElem < 23h, reg_type, 10h, reg_or_mem_type, 10h, 0, 0 >
TableElem < 23h, reg_type, 20h, reg_or_mem_type, 20h, 0, 0 >

AND_table Table < 11, OFFSET AND_table_elems>

; CALL instruction
CALL_table_elems TableElem < 0E8h, offset_type, 10h, null_type, 00h, 0, 0 > 
TableElem < 0E8h, offset_type, 20h, null_type, 00h, 0, 0 >
TableElem < 0FFh, reg_or_mem_type, 10h, null_type, 00h, 0, 0 >
TableElem < 0FFh, reg_or_mem_type, 20h, null_type, 00h, 0, 0 >

CALL_table Table < 4, OFFSET CALL_table_elems>

; CMP instruction
CMP_table_elems TableElem < 80h, reg_or_mem_type, 08h, imm_type, 08h, 0, 7 >
TableElem < 81h, reg_or_mem_type, 10h, imm_type, 10h, 0, 7 >
TableElem < 81h, reg_or_mem_type, 20h, imm_type, 20h, 0, 7 >
TableElem < 83h, reg_or_mem_type, 10h, imm_type, 08h, 0, 7 >
TableElem < 83h, reg_or_mem_type, 20h, imm_type, 08h, 0, 7 >
TableElem < 38h, reg_or_mem_type, 08h, reg_type, 08h, 0, 0 >
TableElem < 39h, reg_or_mem_type, 10h, reg_type, 10h, 0, 0 >
TableElem < 39h, reg_or_mem_type, 20h, reg_type, 20h, 0, 0 >
TableElem < 3Ah, reg_type, 08h, reg_or_mem_type, 08h, 0, 0 >
TableElem < 3Bh, reg_type, 10h, reg_or_mem_type, 10h, 0, 0 >
TableElem < 3Bh, reg_type, 20h, reg_or_mem_type, 20h, 0, 0 >

CMP_table Table < 11, OFFSET CMP_table_elems>

; DEC instruction
DEC_table_elems TableElem < 0FEh, reg_or_mem_type, 08h, null_type, 00h, 0, 1 >
TableElem < 0FFh, reg_or_mem_type, 10h, null_type, 00h, 0, 1 >
TableElem < 0FFh, reg_or_mem_type, 20h, null_type, 00h, 0, 1 >
TableElem < 048h, reg_type, 10h, null_type, 00h, 1, 0 >
TableElem < 048h, reg_type, 20h, null_type, 00h, 1, 0 >

DEC_table Table < 5, OFFSET DEC_table_elems>

;INC instruction
INC_table_elems TableElem < 0FEh, reg_or_mem_type, 08h, null_type, 00h, 0, 0 >
TableElem < 0FFh, reg_or_mem_type, 10h, null_type, 00h, 0, 0 >
TableElem < 0FFh, reg_or_mem_type, 20h, null_type, 00h, 0, 0 >
TableElem < 040h, reg_type, 10h, null_type, 00h, 1, 0 >
TableElem < 040h, reg_type, 20h, null_type, 00h, 1, 0 >

INC_table Table < 5, OFFSET INC_table_elems>

;JMP instruction
JMP_table_elems TableElem < 0EBh, offset_type, 08h, null_type, 00h, 0, 0 >
TableElem < 0E9h, offset_type, 10h, null_type, 00h, 0, 0 >
TableElem < 0E9h, offset_type, 20h, null_type, 00h, 0, 0 >
TableElem < 0FFh, reg_or_mem_type, 10h, null_type, 00h, 0, 4 >
TableElem < 0FFh, reg_or_mem_type, 20h, null_type, 00h, 0, 4 >

JMP_table Table < 5, OFFSET JMP_table_elems>

;LEA instruction
LEA_table_elems TableElem < 08Dh, reg_type, 10h, mem_type, 0FFh, 0, 0 >
TableElem < 08Dh, reg_type, 20h, mem_type, 0FFh, 0, 0 >

LEA_table Table < 2, OFFSET LEA_table_elems>

; MOV instruction
MOV_table_elems TableElem < 088h, reg_or_mem_type, 08h, reg_type, 08h, 0, 0 >
TableElem < 089h, reg_or_mem_type, 10h, reg_type, 10h, 0, 0 >
TableElem < 089h, reg_or_mem_type, 20h, reg_type, 20h, 0, 0 >
TableElem < 08Ah, reg_type, 08h, reg_or_mem_type, 08h, 0, 0 >
TableElem < 08Bh, reg_type, 10h, reg_or_mem_type, 10h, 0, 0 >
TableElem < 08Bh, reg_type, 20h, reg_or_mem_type, 20h, 0, 0 >
TableElem < 0B0h, reg_type, 08h, imm_type, 08h, 1, 0 >
TableElem < 0B8h, reg_type, 10h, imm_type, 10h, 1, 0 >
TableElem < 0B8h, reg_type, 20h, imm_type, 20h, 1, 0 >
TableElem < 0C6h, reg_or_mem_type, 08h, imm_type, 08h, 0, 0 >
TableElem < 0C7h, reg_or_mem_type, 10h, imm_type, 10h, 0, 0 >
TableElem < 0C7h, reg_or_mem_type, 20h, imm_type, 20h, 0, 0 >

MOV_table Table < 12, OFFSET MOV_table_elems>

; ----------- Above this line is WJL's work(tables A - M)
; below this line is JYH's work(tables N - Z) -----------

; NEG instruction
NEG_table_elems TableElem < 0F6h, reg_or_mem_type, 08h, null_type, 00h, 0, 3 >
TableElem < 0F7h, reg_or_mem_type, 10h, null_type, 00h, 0, 3 >
TableElem < 0F7h, reg_or_mem_type, 20h, null_type, 00h, 0, 3 >

NEG_table Table < 3, OFFSET NEG_table_elems>

; OR instruction
OR_table_elems TableElem <80h, reg_or_mem_type, 08h, imm_type, 08h, 0, 1 >
TableElem <81h, reg_or_mem_type, 10h, imm_type, 10h, 0, 1 >
TableElem <81h, reg_or_mem_type, 20h, imm_type, 20h, 0, 1 >
TableElem <83h, reg_or_mem_type, 10h, imm_type, 08h, 0, 1 >
TableElem <83h, reg_or_mem_type, 20h, imm_type, 08h, 0, 1 >
TableElem <08h, reg_or_mem_type, 08h, reg_type, 08h, 0, 0 >
TableElem <09h, reg_or_mem_type, 10h, reg_type, 10h, 0, 0 >
TableElem <09h, reg_or_mem_type, 20h, reg_type, 20h, 0, 0 >
TableElem <0Ah, reg_type, 08h, reg_or_mem_type, 08h, 0, 0 >
TableElem <0Bh, reg_type, 10h, reg_or_mem_type, 10h, 0, 0 >
TableElem <0Bh, reg_type, 20h, reg_or_mem_type, 20h, 0, 0 >

OR_table Table < 11, OFFSET OR_table_elems>

; POP instruction
POP_table_elems TableElem <8Fh, reg_or_mem_type, 10h, null_type, 00h, 0, 0 >
TableElem <8Fh, reg_or_mem_type, 20h, null_type, 00h, 0, 0 >
TableElem <58h, reg_type, 10h, null_type, 00h, 1, 0 >
TableElem <58h, reg_type, 20h, null_type, 00h, 1, 0 >

POP_table Table < 4, OFFSET POP_table_elems>

; PUSH instruction
PUSH_table_elems TableElem <0FFh, reg_or_mem_type, 10h, null_type, 00h, 0, 6 >
TableElem <0FFh, reg_or_mem_type, 20h, null_type, 00h, 0, 6 >
TableElem <50h, reg_type, 10h, null_type, 00h, 1, 0 >
TableElem <50h, reg_type, 20h, null_type, 00h, 1, 0 >
TableElem <6Ah, imm_type, 08h, null_type, 00h, 0, 0 >
TableElem <68h, imm_type, 10h, null_type, 00h, 0, 0 >
TableElem <68h, imm_type, 20h, null_type, 00h, 0, 0 >

PUSH_table Table < 7, OFFSET PUSH_table_elems>

; RET instruction
RET_table_elems TableElem <0C3h, null_type, 00h, null_type, 00h, 0, 0 >
;TableElem <0CBh, null_type, 00h, null_type, 00h, 0, 0 >
;TableElem <0C2h, imm_type, 10h, null_type, 00h, 0, 0 >
;TableElem <0CAh, imm_type, 10h, null_type, 00h, 0, 0 >

RET_table Table < 1, OFFSET RET_table_elems>

; SAL/SAR/SHL/SHR instruction
SAL_table_elems TableElem <0C0h, reg_or_mem_type, 08h, imm_type, 08h, 0, 4 >
TableElem <0C1h, reg_or_mem_type, 10h, imm_type, 08h, 0, 4 >
TableElem <0C1h, reg_or_mem_type, 20h, imm_type, 08h, 0, 4 >

SAL_table Table < 3, OFFSET SAL_table_elems>

SAR_table_elems TableElem <0C0h, reg_or_mem_type, 08h, imm_type, 08h, 0, 7 >
TableElem <0C1h, reg_or_mem_type, 10h, imm_type, 08h, 0, 7 >
TableElem <0C1h, reg_or_mem_type, 20h, imm_type, 08h, 0, 7 >

SAR_table Table < 3, OFFSET SAR_table_elems>

SHL_table_elems TableElem <0C0h, reg_or_mem_type, 08h, imm_type, 08h, 0, 4 >
TableElem <0C1h, reg_or_mem_type, 10h, imm_type, 08h, 0, 4 >
TableElem <0C1h, reg_or_mem_type, 20h, imm_type, 08h, 0, 4 >

SHL_table Table < 3, OFFSET SHL_table_elems>

SHR_table_elems TableElem <0C0h, reg_or_mem_type, 08h, imm_type, 08h, 0, 5 >
TableElem <0C1h, reg_or_mem_type, 10h, imm_type, 08h, 0, 5 >
TableElem <0C1h, reg_or_mem_type, 20h, imm_type, 08h, 0, 5 >

SHR_table Table < 3, OFFSET SHR_table_elems>

; SUB instruction
SUB_table_elems TableElem <80h, reg_or_mem_type, 08h, imm_type, 08h, 0, 5 >
TableElem <81h, reg_or_mem_type, 10h, imm_type, 10h, 0, 5 >
TableElem <81h, reg_or_mem_type, 20h, imm_type, 20h, 0, 5 >
TableElem <83h, reg_or_mem_type, 10h, imm_type, 08h, 0, 5 >
TableElem <83h, reg_or_mem_type, 20h, imm_type, 08h, 0, 5 >
TableElem <28h, reg_or_mem_type, 08h, reg_type, 08h, 0, 0 >
TableElem <29h, reg_or_mem_type, 10h, reg_type, 10h, 0, 0 >
TableElem <29h, reg_or_mem_type, 20h, reg_type, 20h, 0, 0 >
TableElem <2Ah, reg_type, 08h, reg_or_mem_type, 08h, 0, 0 >
TableElem <2Bh, reg_type, 10h, reg_or_mem_type, 10h, 0, 0 >
TableElem <2Bh, reg_type, 20h, reg_or_mem_type, 20h, 0, 0 >

SUB_table Table < 11 , OFFSET SUB_table_elems>

; XCHG instruction
XCHG_table_elems TableElem <86h, reg_or_mem_type, 08h, reg_type, 08h, 0, 0 >
TableElem <86h, reg_type, 08h, reg_or_mem_type, 08h, 0, 0 >
TableElem <87h, reg_or_mem_type, 10h, reg_type, 10h, 0, 0 >
TableElem <87h, reg_type, 10h, reg_or_mem_type, 10h, 0, 0 >
TableElem <87h, reg_or_mem_type, 20h, reg_type, 20h, 0, 0 >
TableElem <87h, reg_type, 20h, reg_or_mem_type, 20h, 0, 0 >

XCHG_table Table < 6, OFFSET XCHG_table_elems>

; XOR instruction
XOR_table_elems TableElem <80h, reg_or_mem_type, 08h, imm_type, 08h, 0, 6 >
TableElem <81h, reg_or_mem_type, 10h, imm_type, 10h, 0, 6 >
TableElem <81h, reg_or_mem_type, 20h, imm_type, 20h, 0, 6 >
TableElem <83h, reg_or_mem_type, 10h, imm_type, 08h, 0, 6 >
TableElem <83h, reg_or_mem_type, 20h, imm_type, 08h, 0, 6 >
TableElem <30h, reg_or_mem_type, 08h, reg_type, 08h, 0, 0 >
TableElem <31h, reg_or_mem_type, 10h, reg_type, 10h, 0, 0 >
TableElem <31h, reg_or_mem_type, 20h, reg_type, 20h, 0, 0 >
TableElem <32h, reg_type, 08h, reg_or_mem_type, 08h, 0, 0 >
TableElem <33h, reg_type, 10h, reg_or_mem_type, 10h, 0, 0 >
TableElem <33h, reg_type, 20h, reg_or_mem_type, 20h, 0, 0 >

XOR_table Table < 11, OFFSET XOR_table_elems>

;------ that's the end of all instruction tables ------

;------ table mapping begins here --------

table_mapping_elems TableMappingElem <"ADD", OFFSET ADD_table>
TableMappingElem <"AND", OFFSET AND_table>
TableMappingElem <"CALL", OFFSET CALL_table>
TableMappingElem <"CMP", OFFSET CMP_table>
TableMappingElem <"DEC", OFFSET DEC_table>
TableMappingElem <"INC", OFFSET INC_table>
TableMappingElem <"JMP", OFFSET JMP_table>
TableMappingElem <"LEA", OFFSET LEA_table>
TableMappingElem <"MOV", OFFSET MOV_table>
TableMappingElem <"NEG", OFFSET NEG_table>
TableMappingElem <"OR", OFFSET OR_table>
TableMappingElem <"POP", OFFSET POP_table>
TableMappingElem <"PUSH", OFFSET PUSH_table>
TableMappingElem <"RET", OFFSET RET_table>
TableMappingElem <"SAL", OFFSET SAL_table>
TableMappingElem <"SAR", OFFSET SAR_table>
TableMappingElem <"SHL", OFFSET SHL_table>
TableMappingElem <"SHR", OFFSET SHR_table>
TableMappingElem <"SUB", OFFSET SUB_table>
TableMappingElem <"XCHG", OFFSET XCHG_table>
TableMappingElem <"XOR", OFFSET XOR_table>

table_mapping TableMapping <21, OFFSET table_mapping_elems>

end
