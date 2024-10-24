TITLE Batalha Naval - Projeto
.MODEL SMALL
.STACK 100H
.DATA
    MATRIZ DB 20 DUP (20 DUP ('*'))  ; Matriz 20x20 inicializada com '*'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    CALL ImprimirMatriz

    MOV AH, 4Ch
    INT 21H
MAIN ENDP

ImprimirMatriz PROC
    XOR SI, SI          ; SI será usado como índice da linha
    XOR BX, BX          ; BX será usado como índice da coluna

    MOV AH, 02h         ; Função para imprimir um caractere

FOR:
    ; Reset BX para a coluna 0
    XOR BX, BX

    MOV CX, 20          ; 20 colunas

FOR2:
    ; Acessa o elemento da matriz
    MOV DL, [MATRIZ + SI * 20 + BX] ; Cada caractere ocupa 1 byte
    INT 21h             ; Imprime o caractere

    INC BX              ; Próxima coluna
    LOOP FOR2           ; Repete para as 20 colunas

    ; Imprime nova linha
    MOV DL, 10          ; Caractere de nova linha
    INT 21h
    MOV DL, 13          ; Caractere de retorno de carro
    INT 21h

    INC SI              ; Próxima linha
    CMP SI, 20          ; Verifica se chegou na última linha
    JL FOR              ; Se SI < 20, continua

    RET
ImprimirMatriz ENDP
END MAIN