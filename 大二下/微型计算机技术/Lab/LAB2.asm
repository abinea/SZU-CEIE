DATA SEGMENT
    BUFFER DB 100 DUP('$') ;存储输入

    DECIMAL DB 3 DUP('$'),'$' ;存储十进制输出，最多三位数
    ODD_NUM DW 1 DUP(0),'$$'  ;奇数个数
    EVEN_NUM DW 1 DUP(0),'$$' ;奇数之和
    ODD_SUM DW 1 DUP(0),'$$'  ;偶数个数
    EVEN_SUM DW 1 DUP(0),'$$' ;偶数之和

    ;一些字符串
    ILLEGAL_WARN DB "Illegal input (only space and digits are allowed), try again!",'$'
    ODD_INFO DB "The number of odd digits is ",'$'
    EVEN_INFO DB "The number of even digits is ",'$'
    SUM_INFO  DB "The sum of these digits is ",'$'
DATA ENDS

STACK SEGMENT
    DATA_SS_W DB 5 DUP(0)
STACK ENDS

CODE SEGMENT
    ASSUME CS:CODE,DS:DATA,SS:STACK
START:
    ;初始化
    MOV AX, DATA
    MOV DS, AX
    MOV AX, STACK
    MOV SS, AX

    ;存储输入
    MOV BUFFER,40H
    LEA DX,BUFFER
    MOV AH,0AH
    INT 21H

    ;循环变量
    XOR CX,CX
    MOV CL,BUFFER+1
    MOV SI,02H
    MOV BL,02H
;判断是否有效
VAILD:
    XOR AX,AX
    MOV AL,BUFFER[SI]

    CMP AL,' '
    JZ NEXT

    CMP AL,'0'
    JB ILLEGAL
    CMP AL,'9'
    JA ILLEGAL

    CMP BUFFER[SI+1],'0'
    JB JUDGE_ODD_OR_EVEN
    CMP BUFFER[SI+1],'9'
    JA JUDGE_ODD_OR_EVEN

    JMP ILLEGAL
;通过最后一位为0或1判断奇偶
JUDGE_ODD_OR_EVEN:
    SUB AL,'0'
    MOV BL,01H
    AND BL,AL

    CMP BL,00H
    JZ IS_EVEN
;得到奇数
IS_ODD:
    INC ODD_NUM
    ADD ODD_SUM,AX
    JMP NEXT
;得到偶数
IS_EVEN:
    INC EVEN_NUM 
    ADD EVEN_SUM,AX
;遍历输入
NEXT:
    INC SI
    LOOP VAILD

    CALL END_LINE
;打印奇数
PRINT_ODD:
    LEA DX,ODD_INFO
    MOV AH,09H
    INT 21H

    MOV AX,ODD_NUM
    MOV DX,AX
    CALL CONVERT

    LEA DX,SUM_INFO
    MOV AH,09H
    INT 21H

    MOV DX,ODD_SUM
    MOV AX,ODD_SUM
    CALL CONVERT
;打印偶数
PRINT_EVEN:
    LEA DX,EVEN_INFO
    MOV AH,09H
    INT 21H

    MOV AX,EVEN_NUM
    MOV DX,EVEN_NUM
    CALL CONVERT

    LEA DX,SUM_INFO
    MOV AH,09H
    INT 21H

    MOV AX,EVEN_SUM
    MOV DX,EVEN_SUM
    CALL CONVERT
;结束程序
END_PROGRAM:
    MOV AX,4C00H
    INT 21H

;非法输入处理
ILLEGAL:
    CALL END_LINE
    
    LEA DX,ILLEGAL_WARN
    MOV AH,09H
    INT 21H
    
    MOV AH,4CH
    INT 21H  

;打印回车
END_LINE PROC NEAR
    MOV DX,0AH
    MOV AH,02H
    INT 21H

    MOV DX,0DH
    MOV AH,02H
    INT 21H

    RET
END_LINE ENDP

;十六进制转十进制并输出
CONVERT PROC NEAR
    XOR SI,SI
    XOR DI,DI
    MOV BL,0AH

    ;判断十进制的位数
    CMP DL,64H
    JAE GTE_HUNDRED
    CMP DL,0AH
    JAE GTE_TEN
    CMP DL,00H
    JAE GTE_ZERO
    
    JMP ILLEGAL
    
    ;百位
    GTE_HUNDRED:
    DIV BL
    XOR CH,CH
    MOV CL,AH
    PUSH CX
    
    INC DI
    XOR AH,AH
    ;十位
    GTE_TEN:
    DIV BL
    XOR CH,CH
    MOV CL,AH
    PUSH CX
    
    INC DI
    XOR AH,AH
    ;个位
    GTE_ZERO:
    DIV BL 
    XOR CH,CH
    MOV CL,AH
    PUSH CX

    INC DI
    
    ;依次弹出栈顶，得到十进制数
    POP_STACK_TOP:
    POP AX
    MOV [DECIMAL+SI],AL
    ADD [DECIMAL+SI],30H
    
    INC SI
    CMP DI,SI
    JA POP_STACK_TOP
    
    LEA DX,DECIMAL
    MOV AH,09H
    INT 21H
    
    CALL END_LINE
    
    ;输出后清空
    MOV [DECIMAL],'$'
    MOV [DECIMAL+1],'$'
    MOV [DECIMAL+2],'$'
    
    RET
CONVERT ENDP

CODE ENDS
END  START