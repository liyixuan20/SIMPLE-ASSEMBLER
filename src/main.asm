.386
.MODEL flat, stdcall

include functions.inc
include parser_data.inc
include Irvine32.inc
includelib Irvine32.lib

.data
cmd_tail BYTE 129 DUP(0)

.code
main proc
	mov edx, OFFSET cmd_tail
	call GetCommandTail
	mov ecx, 129
loop_cmd_tail:
	mov bl, [edx]
	.IF bl == 0
		ret
	.ENDIF
	.IF bl != 32
		jmp start_cmd_tail
	.ENDIF
	inc edx
	loop loop_cmd_tail
	ret
start_cmd_tail:
	INVOKE process_file, edx
	INVOKE ExitProcess,0
	
main endp
end main