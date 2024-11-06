TITLE Batalha Naval - Projeto
.MODEL SMALL              ; Define o modelo de memória como SMALL
.STACK 100H              ; Define um espaço de stack de 256 bytes

PUSH_ALL MACRO
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
ENDM

POP_ALL MACRO
    POP DI 
    POP SI 
    POP DX 
    POP CX 
    POP BX 
    POP AX 
ENDM

ESPAÇO MACRO             ; Início da macro para imprimir um espaço 
    PUSH_ALL             
    MOV AH,02           ; Função para imprimir um caractere
    MOV DL,32           ; Caractere de espaço (ASCII 32)
    INT 21H             ; Executa função
    POP_ALL             
ENDM                     ; Fim da macro

PulaLinha MACRO         ; Início da macro para pular a linha
    PUSH_ALL             ; Salva o valor do registrador DX na pilha
    MOV AH,02           ; Função para imprimir um caractere
    MOV DL,10           ; Caractere de nova linha (ASCII 10)
    INT 21H             ; Executa função
    POP_ALL             ; Restaura o valor original de AX
ENDM                     ; Fim da macro

MENSAGEM MACRO MSG         ; Início da macro para imprimir uma mensagem
    PUSH_ALL             ; Salva o valor de DX na pilha
    MOV AH,09H          ; Função para imprimir uma string
    LEA DX,MSG         ; Carrega o endereço da mensagem em DX
    INT 21H             ; Executa função
    POP_ALL             ; Restaura o valor original de AX
ENDM                     ; Fim da macro

ENCOURACADO MACRO  X, Y
    PUSH_ALL
    
    MOV SI,Y
    DEC SI

    MOV BX,X
    DEC BX
    MOV AX,20
    MUL BL 
    MOV BX,AX

    MOV CX,4

    ENCOURACADO_:
        MOV GABARITO[BX][SI],'#'
        INC SI
        LOOP ENCOURACADO_

    POP_ALL
ENDM

FRAGATA MACRO  X, Y
    PUSH_ALL
    
    MOV SI,Y
    DEC SI

    MOV BX,X
    DEC BX
    MOV AX,20
    MUL BL 
    MOV BX,AX

    MOV CX,3

    FRAGATA_:
        MOV GABARITO[BX][SI],'#'
        INC SI
        LOOP FRAGATA_

    POP_ALL
ENDM

SUBMARINO MACRO  X, Y
    PUSH_ALL
    
    MOV SI,Y
    DEC SI

    MOV BX,X
    DEC BX
    MOV AX,20
    MUL BL 
    MOV BX,AX

    MOV CX,2

    SUBMARINO_:
        MOV GABARITO[BX][SI],'#'
        INC SI
        LOOP SUBMARINO_

    POP_ALL
ENDM

HIDROAV MACRO X,Y
    PUSH_ALL
    
    MOV SI,Y
    DEC SI

    MOV BX,X
    DEC BX
    MOV AX,20
    MUL BL 
    MOV BX,AX

    MOV CX,2

    MOV GABARITO[BX][SI],'#'
    ADD BX,20

    HIDROAV_:
        MOV GABARITO[BX][SI],'#'
        INC SI
        LOOP HIDROAV_
    ADD BX,20 
    SUB SI,2  
    MOV GABARITO[BX][SI],'#'
    POP_ALL
ENDM

.DATA                    ; Seção de dados
    VETORL DB 'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T' ; Letras para colunas
    VETORN DB '1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20' ; Números para linhas
    MATRIZ DB 20 DUP (20 DUP ('*'))  ; Cria uma matriz 20x20 inicializada com '*'
    GABARITO DB 20 DUP (20 DUP ('X')) ; Cria a matriz gabarito
    MSG1 DB 10,13,'Qual a cordenada em que voce quer atirar? (escreva o numero da linha e a letra da coluna, respectivamente, Exps: 1a, 17Q, 6T)',10,13,'$' ; Mensagem para o jogador
.CODE                    ; Seção de código
    MAIN PROC            
        MOV AX, @DATA    
        MOV DS, AX  

        CMP AL,31H
        JE BOT1
        ;BOT3
            ENCOURACADO 1,16
            FRAGATA 4,7 
            SUBMARINO 19,1
            HIDROAV 14,7
        BOT1:
            ENCOURACADO 1,16
            FRAGATA 4,7 
            SUBMARINO 19,1
            HIDROAV 14,7
        JMP CODIGO
        BOT2:





        MOV CX,100        ; Inicializa o contador CX com 10 (número de rodadas)

        BATALHA:         ; Início do loop de batalha
            CALL ImprimirMatriz ; Chama a função para imprimir a matriz
            MENSAGEM  MSG1    ; Chama a macro para imprimir a mensagem
            CALL Atira     ; Chama a função para processar o tiro
            PulaLinha      ; Chama a macro para pular uma linha
            LOOP BATALHA   ; Decrementa CX e volta ao início do loop se CX não for zero
        ;

        MOV AH, 4Ch      ; Função para terminar o programa
        INT 21H          ; Executa função
    MAIN ENDP            ; Fim do procedimento principal

    ImprimirMatriz PROC  ; Início do procedimento para imprimir a matriz
            PUSH CX           ; Salva o valor de CX na pilha

            XOR BX,BX        ; Zera o registrador BX (índice da linha da matriz)
            XOR DI,DI        ; Zera o registrador DI (índice dos vetores auxiliares)
            MOV AH, 02h      ; Função para imprimir um caractere

            MOV CX,20        ; Inicializa CX com 20 (número de colunas)

            ESPAÇO           ; Chama a macro para imprimir três espaços antes do vetor de letras
            ESPAÇO
            ESPAÇO

        VLETRA:               ; Início do loop para imprimir o vetor de letras referente as colunas
            MOV DL,VETORL[DI] ; Carrega a letra correspondente da coluna em DL
            INT 21H          ; Executa função
            INC DI           ; Incrementa DI para a próxima letra

            ESPAÇO           ; Imprime um espaço entre as letras

            LOOP VLETRA      ; Repete até que todas as letras tenham sido impressas

            PulaLinha        ; Chama a macro para pular uma linha

            XOR DI,DI        ; Reseta DI para o índice das linhas
        FOR:                  ; Início do loop para imprimir números e linhas
            XOR SI, SI       ; Zera o registrador SI (índice da coluna)
            
            MOV CX, 20       ; Inicializa CX com 20 (número de colunas)

            CMP DI,8         ; Verifica se DI é maior que 8
            JA SKIP          ; Se DI > 8, não gera espaço antes do número referente a linha
            ESPAÇO           ; Imprime um espaço antes dos números se DI <= 8
        SKIP:
            
            MOV DL,VETORN[DI] ; Carrega o número correspondente da linha em DL
            INT 21h          ; Executa função
            INC DI           ; Incrementa DI para o próximo número

            CMP DI,9        ; Verifica se DI é menor ou igual a 9
            JBE FOR2         ; Pula para a impressão da matriz
        VNUMERO:             ; Executa VNUMERO se DI for maior que nove (para imprimir os dois números refferente a linha)
            MOV DL,VETORN[DI] ; Carrega o número correspondente em DL
            INT 21H          ; Executa função
            INC DI           ; Incrementa DI

        FOR2:                 ; Início do loop para imprimir a matriz
            ESPAÇO           ; Imprime um espaço entre os valores da matriz

            MOV DL, MATRIZ[BX][SI] ; Carrega o valor da matriz em DL
            INT 21h          ; Executa função
            INC SI           ; Incrementa SI para a próxima coluna  
                    
            LOOP FOR2        ; Repete para as 20 colunas

            PulaLinha        ; Chama a macro para pular uma linha

            ADD BX,20        ; Incrementa BX para a próxima linha
            CMP BX,400       ; Verifica se BX atingiu 400 (20x20)
            JL FOR           ; Se BX < 400, continua o loop para imprimir mais linhas

            POP CX           ; Restaura o valor de CX da pilha
            RET               ; Retorna ao chamador
    ImprimirMatriz ENDP   ; Fim da função ImprimirMatriz

    Atira PROC            ; Início da função para processar um tiro
        XOR BH,BH        ; Zera o registrador BH

        MOV AH,1         ; Função para ler um caractere da entrada
        INT 21H          ; Executa função
        AND AL,0FH      ; Máscara para obter o número da linha

        MOV BL,AL        ; Armazena o número da linha em BL

        INT 21H          ; Executa função
        CMP AL,3AH       ; Compara seo valor do caractere está acima de 3Ah, e etiver é uma letra, e não é outro número
        JA LETRA         ; Se estiver, vai para processar letra

        AND AL,0FH      ; Máscara para obter o segundo número da linha
        PUSH AX          ; Salva AX na pilha
        MOV AL,10       ; Carrega 10 para multiplicação
        MUL BL           ; Multiplica 10 pelo número da linha
        MOV BX,AX        ; Armazena o resultado em BX
        POP AX           ; Restaura AX para o segundo número digitado

        ADD BL,AL        ; Soma o primeiro número multiplicado por 10 com o segundo (Entrada de Decimal)

        INT 21H          ; Executa função
    LETRA:
        PUSH AX          ; Salva AX na pilha
        DEC BL           ; Decrementa BL para indexar corretamente

        MOV AL,20        ; Carrega 20 para multiplicação
        MUL BL           ; Multiplica 20 pelo número da linha (para correponder corretamente com a linha da matriz)
        MOV BX,AX        ; Armazena o resultado em BX
        POP AX           ; Restaura AX

        CMP AL,05BH      ; Compara se o valor de AL está acima do valor da ascii de 'Z'
        JA MINUSCULA     ; Se sim, vai para tratar como letra minúscula

        SUB AL,41H       ; Se não, converte letra maiúscula para índice
        JMP EXITLETRA     ; Pula para a saída

    MINUSCULA:
        SUB AL,61H       ; Converte letra minúscula para índice

    EXITLETRA:
        XOR AH,AH        ; Zera AH para usar AX como endereço
        MOV SI,AX        ; Move o índice da coluna para SI



        MOV AH,GABARITO[BX][SI]
        MOV MATRIZ[BX][SI],AH  ; Marca a posição atingida na matriz com 'x'
        RET               ; Retorna ao chamador
    ATIRA ENDP            ; Fim da função Atira 


END MAIN  