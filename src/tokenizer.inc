start_status = 0
proc_name_status = 1
after_proc_name_status = 2
proc_label_status = 3

operator_status = 4
after_operator_status = 5
operand_one_status = 6
after_operand_one_status = 7
operand_two_status = 8

register_string_to_standard STRUCT
    string_name BYTE    4 DUP(0)
    binary_name BYTE    0 
register_string_to_standard ENDS

