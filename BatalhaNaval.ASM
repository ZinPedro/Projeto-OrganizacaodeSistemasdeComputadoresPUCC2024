TITLE Batalha Naval - Projeto
.MODEL SMALL
.STACK 100H
.DATA
    VETORL DB 'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T'
    VETORN DB '1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20'
    MATRIZ DB 20 DUP (20 DUP ('*'))  ; Matriz 20x20 inicializada com '*'
    ELINHA  DB ''
    ECOLUNA DB ''
.CODE
    MAIN PROC
        MOV AX, @DATA
        MOV DS, AX

        CALL ImprimirMatriz


        MOV AH, 4Ch
        INT 21H
    MAIN ENDP

    ImprimirMatriz PROC        
        XOR BX,BX          ; BX se refere ao índice da linha da matriz
        XOR DI,DI
        MOV AH, 02h         ; Função para imprimir um caractere

        MOV CX,20
    VLETRA:
        MOV DL,VETORL[DI]
        INT 21H
        INC DI

        MOV DL,32
        INT 21H

        LOOP VLETRA

        MOV DL, 10          ; Caractere de nova linha
        INT 21H

        XOR DI,DI
    FOR:
        XOR SI, SI          ; SI se refere ao índice da coluna
        
        MOV CX, 20          ; 20 colunas

        MOV DL,VETORN[DI]
        INT 21h
        INC DI
    FOR2:
        MOV DL, MATRIZ[BX][SI]  
        INT 21h                 ; Imprime o caractere

        INC SI              ; Próxima coluna  
         
        MOV DL,32
        INT 21H
                            
        LOOP FOR2           ; Repete para as 20 colunas

        ; Imprime nova linha
        MOV DL, 10          ; Caractere de nova linha
        INT 21H

        INC BX              ; Próxima linha
        CMP BX, 20          ; Verifica se chegou na última linha
        JL FOR              ; Se SI < 20, continua

        RET                 ;Retorna ao main
    ImprimirMatriz ENDP

    Atira PROC 


    ATIRA ENDP    
END MAIN