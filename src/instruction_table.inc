TableMappingElem struct
	mnemonic byte 8 DUP(0)
	address dword ?
TableMappingElem ends

TableMapping struct
	len dword ?
	address dword ?
TableMapping ends

TableElem struct
	opcode byte ?
	target_type byte ?
	target_size byte ?
	source_type byte ?
	source_size byte ?
	encoded byte ?
	digit byte ?
TableElem ends

Table struct
	len dword ?
	address dword ?
Table ends

EXTERNDEF table_mapping: TableMapping
