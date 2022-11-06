## 汇编大作业：简易汇编器实现
### 背景
    对于一个标准的C程序，整个编译流程包括预处理、编译、汇编、链接。汇编是指根据ASCII码格式的汇编文件（.asm）生成二进制格式的可重定位目标文件。可重定位文件包括（TODO）；为简化实验，突出重点，本项目仅实现可重定位目标文件中的code segment，即仅实现汇编文件中.code部分的机器码生成。当然，由于.code段中可能会出现对.data段定义的全局变量的寻址，因此本项目完整处理整个汇编文件（.data & .code），仅显示打印.code段的机器码。为保证正确性，我们通过使用GDB工具，获取了由masm汇编得到的可重定位目标文件的.data段，用于对比验证。
### 程序架构
    本项目主要由三个部分构成：IO、tokenizer、translator。
#### IO
    Input模块位于main.asm中，表现为向用户获取汇编文件的路径名，然后根据路径名，读取汇编文件内容。
    Output模块位于translator中，由于汇编代码和机器码逐行对应，因此本项目采取了逐行翻译、输出的策略：每处理完一行汇编指令后，将相应的机器码打印在屏幕上。
#### tokenizer
    汇编指令中主要包含两部分：operator和operand；我们采用BYTE数组存放operator，定义了结构体Operand，由于存放读取到的operand的相应信息。tokenizer具体包括code tokenizer和data tokenizer，将全局变量的信息维护在一个数组中，同时将每一行指令operator和operand存储到上述定义好的标准的数据结构中，作为参数传给translator，完成翻译。
#### translator
    translator是本项目的核心，将机器码
### 汇编流程

### 演示

### 小组分工