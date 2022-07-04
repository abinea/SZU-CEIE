; 计时器

MODEL SMALL
.486
DATA SEGMENT
   I8254_CS EQU 210H
DATA ENDS

CODE SEGMENT
    ASSUME CS:CODE,DS:DATA
START:
	MOV AX,DATA
	MOV DS,AX

	MOV DX,I8254_CS+3
	MOV AL,10H ;设置计数器0为工作方式0,二进制计数
	OUT DX,AL

L0:
	MOV DX,I8254_CS
	MOV AL,0FH ;给计数器0赋初值0FH
	OUT DX,AL
L1:
	IN AL,DX ;读计数器的值
	CALL PRINT ;调用显示子程序
	CMP AL,1 ;判断到1了吗
	JNZ L1
	JMP L0

PRINT PROC
	PUSH DX
	AND AL,OFH ;取低四位
	MOV DL,AL
	CMP DL,9 ;判断是否<=9
	JLE L2
	ADD DL,07H
L2:
	ADD DL,30H ;转换成字符
	MOV AH,02H ;显示到屏幕
	INT 21H
	POP DX

	RET
PRINT ENDP

CODE ENDS
	END START