TITLE Batalha Naval - Projeto
.MODEL SMALL
.STACK 100H

ESPAÇO MACRO 
    PUSH AX
    MOV AH,02 
    MOV DL,32
    INT 21H 
    POP AX
ENDM   

PulaLinha MACRO 
    PUSH AX
    MOV AH,02 
    MOV DL,10
    INT 21H
    POP AX
ENDM

.DATA
    VETORL DB 'A','B','C','D','E','F'
    VETORN DB '1','2','3','4','5','6'
    MATRIZ DB '*','*','*','*','*','*'
           DB '*','*','*','*','*','*'
           DB '*','*','*','*','*','*'
           DB '*','*','*','*','*','*'
           DB '*','*','*','*','*','*'
           DB '*','*','*','*','*','*'
    ELINHA  DB ''
    ECOLUNA DB ''
.CODE
    MAIN PROC
        MOV AX, @DATA
        MOV DS, AX

        CALL ImprimirMatriz
        PulaLinha
        CALL Atira
        PulaLinha
        CALL ImprimirMatriz



        MOV AH, 4Ch
        INT 21H
    MAIN ENDP

    ImprimirMatriz PROC        
        XOR BX,BX           ; BX se refere ao índice da linha da matriz
        XOR DI,DI           ; DI se refere ao índice dos vetores auxiliares
        MOV AH, 02h         ; Função para imprimir um caractere

        MOV CX,6 

        ESPAÇO              ; três espaços antes do A (apenas estético)
        ESPAÇO
        ESPAÇO

    VLETRA:                 ;imprime o vetor das letras, para nomear as colunas da matriz
        MOV DL,VETORL[DI]
        INT 21H                  
        INC DI

        ESPAÇO

        LOOP VLETRA

        PulaLinha

        XOR DI,DI
    FOR:                    ; impreção dos números que nomeiam as linhas e das linhas da matriz
        XOR SI, SI          ; SI se refere ao índice da coluna
        
        MOV CX, 6      

        CMP DI,8            ; Cria um espaço antes dos 9 primeiros números que nomeiam as linha (apenas estético)
        JA SKIP
        ESPAÇO
        SKIP:
        
        MOV DL,VETORN[DI]   ; imprime o número antes de imprimir a linha
        INT 21h
        INC DI 

        CMP DI,9            ; se di > 9, é preciso imprimir dois números para fazer a representação
        JA VNUMERO
        ESPAÇO
        JMP FOR2
        VNUMERO:
            MOV DL,VETORN[DI]
            INT 21H
            INC DI
            ESPAÇO
        ;
    FOR2:
        MOV DL, MATRIZ[BX][SI]      ;imprime a matriz  
        INT 21h                  

        INC SI                      ; Próxima coluna  
         
        ESPAÇO
                            
        LOOP FOR2                   ; Repete para as 20 colunas
 
        PulaLinha

        ADD BX, 6               
        CMP BX, 36          ; Verifica se chegou na última linha
        JL FOR              ; Se SI < 20, continua

        RET                 ;Retorna ao main
    ImprimirMatriz ENDP

    Atira PROC 
        XOR BH,BH

        MOV AH,1
        INT 21H
        AND AL,0FH
        MOV BL,AL

        INT 21H
        CMP AL,3AH
        JA LETRA

        AND AL,0FH
        PUSH AX
        MOV AL,10
        MUL BL
        POP AX
        ADD BL,AL

        INT 21H
        LETRA:
            PUSH AX
            SUB BL,1
            MOV AL,6
            MUL BL
            POP AX

            CMP AL,05BH
            JA MINUSCULA

            SUB AL,41H

            MINUSCULA:
                SUB AL,61H
        ; 
        XOR AH,AH
        MOV SI,AX

        MOV MATRIZ[BX][SI], 'x'
        RET
    ATIRA ENDP      
END MAIN