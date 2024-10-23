TITLE Batalaha Naval - Projeto
.MODEL SMALL
.STACK 100H
.DATA
    MATRIZ DW 20 DUP ( 20 DUP (*))

.CODE
    MAIN PROC
        MOV AX,@DATA
        MOV DS,AX

        CALL ImprimirMatriz

        MOV AH,4Ch
        INT 21H
    MAIN ENDP

    ImprimirMatriz PROC
        LEA BX, MATRIZ

        XOR SI,SI
        XOR DI,DI

        MOV AH,02

        FOR:
            INC SI
            MOV CX,20

            

            FOR2:
                MOV DL,MATRIZ[SI,DI]
                INT 21H

                INC DI

                LOOP FOR2

                MOV DL,10
                INT 21H

                TEST SI,19
                JZ EXIT
                JMP FOR
        ;
        EXIT:
            RET
    ImprimirMatriz ENDP
END MAIN

