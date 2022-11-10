operator_mapping_list STRUCT
    len				DWORD ?
    start_of_list   DWORD ?
operator_mapping_list ENDS

operator_mapping_element STRUCT
    operator_name           BYTE 8 DUP(?)
    len                    DWORD ?
    start_of_related_list  DWORD ?
operator_mapping_element ENDS

operand_mapping_element STRUCT
    opcode              BYTE 0
	target_operand_type BYTE 0
	target_operand_size BYTE 0
	source_operand_type BYTE 0
	source_operand_size BYTE 0
	encoded             BYTE 0
	digit               BYTE 0
operand_mapping_element ENDS
