TITLE Batalha Naval - Projeto
.MODEL SMALL              ; Define o modelo de memória como SMALL
.STACK 100H               ; Define um espaço de stack de 256 bytes

; Macro para empilhar todos os registradores usados
PUSH_ALL MACRO
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
ENDM

; Macro para desempilhar todos os registradores
POP_ALL MACRO
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
ENDM

; Macro para imprimir um espaço (caractere ASCII 32)
ESPAÇO MACRO             
    PUSH_ALL   
    MOV AH,02           ; Função para imprimir um caractere
    MOV DL,32           ; Caractere de espaço
    INT 21H             ; Chama interrupção para imprimir
    POP_ALL             
ENDM                     

; Macro para pular uma linha (caractere ASCII 10)
PulaLinha MACRO         
    PUSH_ALL             
    MOV AH,02           ; Função para imprimir um caractere
    MOV DL,10           ; Caractere de nova linha
    INT 21H             ; Chama interrupção para imprimir
    POP_ALL             
ENDM                     

; Macro para imprimir uma mensagem
MENSAGEM MACRO MSG      
    PUSH_ALL             
    MOV AH,09H          ; Função para imprimir uma string
    LEA DX,MSG          ; Carrega o endereço da mensagem
    INT 21H             ; Chama interrupção para imprimir
    POP_ALL             
ENDM                     

; Macro para posicionar um encouraçado (tamanho 4) no tabuleiro
ENCOURACADO MACRO  X, Y, DIRECAO 
    LOCAL ENCOURACADO_HORIZONTAL
    LOCAL ENCOURACADO_VERTICAL   
    LOCAL FIM  
    PUSH_ALL

    MOV SI,Y
    DEC SI              ; Ajusta índice da linha

    MOV DX,DIRECAO      ; Verifica direção do barco (1 = VERTICAL , 0 = HORIZONTAL)

    MOV BX,X
    DEC BX              ; Ajusta índice da coluna
    MOV AX,20
    MUL BL              ; Calcula deslocamento da linha
    MOV BX,AX

    MOV CX,4            ; Tamanho do encouraçado

    CMP DX,1
    JE ENCOURACADO_VERTICAL

    ENCOURACADO_HORIZONTAL:
        MOV GABARITO[BX][SI],'#' ; Posiciona parte do navio
        INC SI                   ; Move para a próxima coluna
        LOOP ENCOURACADO_HORIZONTAL
        JMP FIM

    ENCOURACADO_VERTICAL:
        MOV GABARITO[BX][SI],'#' ; Posiciona parte do navio
        ADD BX,20                ; Move para a próxima linha
        LOOP ENCOURACADO_VERTICAL
    FIM:
    POP_ALL
ENDM

; Macro para posicionar uma fragata (tamanho 3) no tabuleiro
FRAGATA MACRO  X, Y, DIRECAO     
    LOCAL FRAGATA_HORIZONTAL
    LOCAL FRAGATA_VERTICAL  
    LOCAL FIM    
    PUSH_ALL

    MOV SI,Y
    DEC SI              ; Ajusta índice da linha

    MOV DX,DIRECAO      ; Verifica direção do barco (1 = VERTICAL , 0 = HORIZONTAL) 

    MOV BX,X
    DEC BX              ; Ajusta índice da coluna
    MOV AX,20
    MUL BL              ; Calcula deslocamento da linha
    MOV BX,AX

    MOV CX,3            ; Tamanho da fragata

    CMP DX,1
    JE FRAGATA_VERTICAL

    FRAGATA_HORIZONTAL:
        MOV GABARITO[BX][SI],'#'
        INC SI
        LOOP FRAGATA_HORIZONTAL
        JMP FIM

    FRAGATA_VERTICAL:
        MOV GABARITO[BX][SI],'#'
        ADD BX,20
        LOOP FRAGATA_VERTICAL
    FIM:
    POP_ALL
ENDM

; Macro para posicionar um submarino (tamanho 2) no tabuleiro
SUBMARINO MACRO  X, Y, DIRECAO   
    LOCAL SUBMARINO_HORIZONTAL
    LOCAL SUBMARINO_VERTICAL   
    LOCAL FIM 
    PUSH_ALL

    MOV SI,Y
    DEC SI              ; Ajusta índice da linha

    MOV DX,DIRECAO      ; Verifica direção do barco (1 = VERTICAL , 0 = HORIZONTAL)

    MOV BX,X
    DEC BX              ; Ajusta índice da coluna
    MOV AX,20
    MUL BL              ; Calcula deslocamento da linha
    MOV BX,AX

    MOV CX,2            ; Tamanho do submarino

    CMP DX,1
    JE SUBMARINO_VERTICAL

    SUBMARINO_HORIZONTAL:
        MOV GABARITO[BX][SI],'#'
        INC SI
        LOOP SUBMARINO_HORIZONTAL
        JMP FIM

    SUBMARINO_VERTICAL:
        MOV GABARITO[BX][SI],'#'
        ADD BX,20
        LOOP SUBMARINO_VERTICAL
    FIM:
    POP_ALL
ENDM

; Macro para posicionar um hidroavião (tamanho 4 (1 na primeira linha, 2 na segunda 1 na terceira)) no tabuleiro
HIDROAV MACRO X,Y       
    LOCAL HIDROAV_      
    PUSH_ALL

    MOV SI,Y
    DEC SI              ; Ajusta índice da linha

    MOV BX,X
    DEC BX              ; Ajusta índice da coluna
    MOV AX,20
    MUL BL              ; Calcula deslocamento da linha
    MOV BX,AX

    MOV CX,2            ; Tamanho do hidroavião

    MOV GABARITO[BX][SI],'#' ; Primeira posição
    ADD BX,20            ; Move para a linha abaixo

    HIDROAV_:
        MOV GABARITO[BX][SI],'#' ; Segunda posição
        INC SI
        LOOP HIDROAV_
    ADD BX,20           ; Move para linha abaixo
    SUB SI,2            ; Volta duas colunas para a posição final
    MOV GABARITO[BX][SI],'#' ; Terceira posição
    POP_ALL
ENDM

.DATA                   ; Seção de dados
    VETORL DB 'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T' ; Letras para colunas
    VETORN DB '1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20' ; Números para linhas
    MATRIZ DB 20 DUP (20 DUP ('*'))  ; Cria uma matriz 20x20 inicializada com '*'
    GABARITO DB 20 DUP (20 DUP ('X')) ; Cria a matriz gabarito

    ; Mensagens usadas no jogo
    TIROMSG DB 10,13,'Qual a cordenada em que voce quer atirar?(ex: 1a, 17Q, 6T)',10,13,'$' 
    TENRESMSG1 DB '(Tentativas Restantes: $' 
    TENRESMSG2 DB ')',10,13,'$'  
 
    MSG2 DB 10,13,'Escolha o jogo que voce quer jogar?',10,13,'1)Jogo A',10,13,'2)Jogo B',10,13,'3)Jogo C',10,13,'4)Jogo D',10,13,'5)Jogo E',10,13,'$'
    MSG3 DB 10,13,'JOGO INVALIDO, DIGITE UM NUMERO DE 1 A 5!',10,13,'$'

    NPERMITIDO DB 10,13,'ALERTA! Esta nao e uma escolha possivel! Precione qualquer tecla para continuar. $'
    TIROREPETIDO DB 10,13,'ALERTA! Voce ja atirou nessa posicao! Nao eh possivel dar dois tiros no mesmo lugar! Precione qualquer tecla para continuar.$'
    VITORIA DB 'Parabens!! Voce acertou todos o barcos e venceu o jogo!$'
    SAIDAMSG DB 'Voce escolheu sair do jogo! GAME OVER!!$'
    DERROTA DB 'Seus tiros acabaram e voce nao derrubou todos os barcos! GAME OVER!!$'

.CODE                    ; Seção de código
    MAIN PROC            
        MOV AX, @DATA    ; Configura o segmento de dados
        MOV DS, AX 

        XOR DX,DX        ; Inicializa a condição de vitória

        CALL PerguntaJogo ; Pergunta ao jogador qual jogo carregar
        PulaLinha

        MOV CX,150       ; Inicializa o contador de rodadas com 100 tentativas

        ; Loop principal da batalha
        BATALHA:         
            CALL ImprimirMatriz ; Imprime o tabuleiro atual

            CMP DX,19
            JE VITORIA_    ; Se DX = 19, o jogador venceu
            CMP DX,20
            JE SAIDA_ANCORA      ; Se DX = 20, o jogador escolheu sair

            MENSAGEM TIROMSG  ; Mensagem para perguntar onde atirar
            MENSAGEM TENRESMSG1 ;Mensagem para numeros de tentativas restantes
            CALL TentativasRestantes    ; Procedimento que imprime o numero de tentativas restantes.
            MENSAGEM TENRESMSG2 ; Complemento da mensagem (estético)             
            CALL Atira     ; Chama a função para processar o tiro
            PulaLinha      

            LOOP BATALHA   ; Decrementa CX e volta ao início do loop se CX não for zero

        ; Caso o jogador perca (CX chegou a 0)
        CALL ImprimirMatriz 
        MENSAGEM DERROTA
        JMP FIM

            SAIDA_ANCORA:  ; Ancora para saída por causa do alcance do salto condicional
            JMP SAIDA_ 

        ; Caso o jogador vença
        VITORIA_:
        MENSAGEM VITORIA 
        JMP FIM 

        ; Caso o jogador escolha sair
        SAIDA_:
        MENSAGEM SAIDAMSG

        ; Fim do jogo
        FIM:
        MOV AH, 4Ch      ; Termina o programa
        INT 21H          
    MAIN ENDP     
          ; Fim do procedimento principal

    PerguntaJogo PROC
        PUSH_ALL                ; Salva todos os registradores para preservar o contexto
        MOV AH,01H              ; Prepara para receber um caractere do teclado
        JOGO:
            MENSAGEM MSG2           ; Exibe a mensagem perguntando qual jogo o jogador deseja escolher
            INT 21H             ; Lê a entrada do teclado (caractere do usuário)
            CMP AL, 1BH         ; Verifica novamente se a tecla ESC foi pressionada
            JE SAIDA_           ; Sai se for ESC e encerra o jogo
            CMP AL,31H          ; Verifica se o caractere é '1'
            JE BOT1             ; Se for '1', salta para o bloco de jogo BOT1
            JB INVALIDO         ; Se o caractere for menor que '1', é inválido
            CMP AL,32H          ; Verifica se o caractere é '2'
            JE BOT2             ; Se for '2', salta para o bloco de jogo BOT2
            CMP AL,33H          ; Verifica se o caractere é '3'
            JE BOT3             ; Se for '3', salta para o bloco de jogo BOT3
            CMP AL,34H          ; Verifica se o caractere é '4'
            JE BOT4             ; Se for '4', salta para o bloco de jogo BOT4
            CMP AL,35H          ; Verifica se o caractere é '5'
            JE BOT5             ; Se for '5', salta para o bloco de jogo BOT5
 
        INVALIDO:               ; Rótulo para entrada inválida
            MENSAGEM MSG3       ; Exibe mensagem informando que o jogo é inválido
            JMP JOGO            ; Volta para o início para receber uma nova entrada 

        ; Blocos de salto para os diferentes cenários de jogo

            BOT2:               ; Rótulo para o jogo 2
            JMP BOT2_           ; Salta para o posicionamento de embarcações do jogo 2
            BOT3:               ; Rótulo para o jogo 3
            JMP BOT3_           ; Salta para o posicionamento de embarcações do jogo 3
            BOT4:               ; Rótulo para o jogo 4
            JMP BOT4_           ; Salta para o posicionamento de embarcações do jogo 4
            BOT5:               ; Rótulo para o jogo 5
            JMP BOT5_           ; Salta para o posicionamento de embarcações do jogo 5

        BOT1: ;Posiciona as embarcações de acordo com as cordenadas dadas no bot 1
            ENCOURACADO 7,13,1    ; Posiciona um encouraçado em (7,13)
            FRAGATA 20,3,0        ; Posiciona uma fragata em (20,3)
            SUBMARINO 11,16,1     ; Posiciona uma submarino em (11,16)
            SUBMARINO 17,5,1      ; Posiciona um submarino em (17,5)
            HIDROAV 12,6        ; Posiciona um hidroavião em (12,6)
            HIDROAV 1,1         ; Posiciona um hidroavião em (1,1)
            JMP SAIDA           ; Salta para a saída após posicionar os navios

        BOT2_:
            ENCOURACADO 13,5,1    ; Posiciona um encouraçado em (13,5)
            FRAGATA 10,17,1       ; Posiciona uma fragata em (10,17)
            SUBMARINO 4,10,1      ; Posiciona uma submarino em (4,10)
            SUBMARINO 18,13,1     ; Posiciona um submarino em (18,13)
            HIDROAV 13,13       ; Posiciona um hidroavião em (13,13)
            HIDROAV 8,6         ; Posiciona um hidroavião em (8,6)
            JMP SAIDA           ; Salta para a saída após posicionar os navios

        BOT3_:
            ENCOURACADO 16,13,0   ; Posiciona um encouraçado em (16,13)
            FRAGATA 14,5,0        ; Posiciona uma fragata em (14,5)
            SUBMARINO 9,14,1      ; Posiciona uma submarino em (9,14)
            SUBMARINO 1,5,1       ; Posiciona um submarino em (1,5)
            HIDROAV 3,6         ; Posiciona um hidroavião em (3,6)
            HIDROAV 10,3        ; Posiciona um hidroavião em (10,3)
            JMP SAIDA           ; Salta para a saída após posicionar os navios

        BOT4_:
            ENCOURACADO 12,11,0   ; Posiciona um encouraçado em (12,11)
            FRAGATA 14,2,1        ; Posiciona uma fragata em (14,2)
            SUBMARINO 7,7,0       ; Posiciona uma submarino em (7,7)
            SUBMARINO 2,3,0       ; Posiciona um submarino em (2,3)
            HIDROAV 4,15        ; Posiciona um hidroavião em (4,15)
            HIDROAV 15,12       ; Posiciona um hidroavião em (15,12)
            JMP SAIDA           ; Salta para a saída após posicionar os navios

        BOT5_:
            ENCOURACADO 14,16,1   ; Posiciona um encouraçado em (14,16)
            FRAGATA 20,16,0       ; Posiciona uma fragata em (20,16)
            SUBMARINO 1,2,0       ; Posiciona uma submarino em (1,2)
            SUBMARINO 6,8,0       ; Posiciona um submarino em (6,8)
            HIDROAV 3,14        ; Posiciona um hidroavião em (3,14)
            HIDROAV 11,7        ; Posiciona um hidroavião em (11,7)
            JMP SAIDA           ; Salta para a saída após posicionar os navios

        SAIDA:
        POP_ALL                 ; Restaura todos os registradores salvos
        RET                     ; Retorna do procedimento
    PerguntaJogo ENDP

    ImprimirMatriz PROC          ; Início do procedimento para imprimir a matriz 
            PUSH_ALL             ; Salva todos os registradores para preservar o contexto           

            XOR BX,BX            ; Zera o registrador BX (índice da linha da matriz)
            XOR DI,DI            ; Zera o registrador DI (índice dos vetores auxiliares)
            MOV AH, 02h          ; Função para imprimir um caractere

            MOV CX,20            ; Inicializa CX com 20 (número de colunas)

            ESPAÇO               ; Chama a macro para imprimir três espaços antes do vetor de letras
            ESPAÇO
            ESPAÇO

        VLETRA:                 ; Início do loop para imprimir o vetor de letras referente às colunas
            MOV DL,VETORL[DI]   ; Carrega a letra correspondente da coluna em DL
            INT 21H             ; Executa função para imprimir o caractere em DL
            INC DI              ; Incrementa DI para a próxima letra

            ESPAÇO              ; Imprime um espaço entre as letras

            LOOP VLETRA         ; Repete até que todas as letras tenham sido impressas

            PulaLinha           ; Chama a macro para pular uma linha

            XOR DI,DI           ; Reseta DI para o índice das linhas
        FOR:                    ; Início do loop para imprimir números e linhas
            XOR SI, SI          ; Zera o registrador SI (índice da coluna)
            
            MOV CX, 20          ; Inicializa CX com 20 (número de colunas)

            CMP DI,8            ; Verifica se DI é maior que 8 (8 representa a 9° linha da matriz)
            JA SKIP             ; Se DI > 8, não gera espaço antes do número referente à linha
            ESPAÇO              ; Imprime um espaço antes dos números se DI <= 8
        SKIP:
            
            MOV DL,VETORN[DI]   ; Carrega o número correspondente da linha em DL
            INT 21h             ; Executa função para imprimir o caractere em DL
            INC DI              ; Incrementa DI para o próximo número

            CMP DI,9            ; Verifica se DI é menor ou igual a 9
            JBE FOR2            ; Pula para a impressão da matriz se DI <= 9

        VNUMERO:                ; Caso DI > 9, imprime os dois dígitos do número da linha
            MOV DL,VETORN[DI]   ; Carrega o número correspondente em DL
            INT 21H             ; Executa função para imprimir o caractere em DL
            INC DI              ; Incrementa DI

        FOR2:                   ; Início do loop para imprimir a matriz
            ESPAÇO              ; Imprime um espaço entre os valores da matriz

            MOV DL, MATRIZ[BX][SI] ; Carrega o valor da matriz em DL
            INT 21h             ; Executa função para imprimir o caractere em DL
            INC SI              ; Incrementa SI para a próxima coluna  
                    
            LOOP FOR2           ; Repete para as 20 colunas

            PulaLinha           ; Chama a macro para pular uma linha

            ADD BX,20           ; Incrementa BX para a próxima linha
            CMP BX,400          ; Verifica se BX atingiu 400 (20x20)
            JL FOR              ; Se BX < 400, continua o loop para imprimir mais linhas

            POP_ALL             ; Restaura todos os registradores salvos
            RET                 ; Retorna ao chamador
    ImprimirMatriz ENDP         ; Fim da função ImprimirMatriz
 
    Atira PROC                  ; Início da função para processar um tiro 
        XOR BH,BH               ; Zera o registrador BH para uso posterior

        MOV AH,1                ; Configura para ler um caractere da entrada
        VOLTA_NPERMITIDO:
            INT 21H             ; Lê o primeiro caractere (número da linha)

            CMP AL, 1BH         ; Verifica se a tecla ESC foi pressionada
            JE SAIDA2           ; Se for ESC, sai do procedimento e encerra o jogo

            CMP AL,39H          ; Verifica se o número está fora do intervalo permitido
            JA NPERMITIDO_ATIRA_ANCORA
            CMP AL,31H          ; Verifica se o número está abaixo do permitido
            JB NPERMITIDO_ATIRA_ANCORA  ; Ancora para NPERMITIDO_ATIRA por causa do alcance do salto condicional
            JMP CONTINUA_ATIRA

            NPERMITIDO_ATIRA_ANCORA:    ; Ancora para NPERMITIDO_ATIRA por causa do alcance do salto condicional
             JMP NPERMITIDO_ATIRA       ; Salto incondicional para NPERMITIDO_ATIRA

            CONTINUA_ATIRA:
            AND AL,0FH          ; Converte o número ASCII para o correspondente valor numérico
            MOV BL,AL           ; Armazena o número da linha em BL

            BACKSPACE_CHECKPOINT:   ; Checkpoint para backspace caso o usuário de beckspace no segundo numero digitado
            INT 21H             ; Lê o próximo caractere (número ou letra)

            CMP AL, 1BH         ; Verifica novamente se a tecla ESC foi pressionada
            JE SAIDA2           ; Sai do procedimento se for ESC, e encerra o jogo

            CMP AL,08H          ; Verifica se a tecla BACKSPACE foi pressionada
            JE BACKSPACE1       ; Se backspace foi precionada, pula para BACKSPACE1 

            CMP AL,39H          ; Verifica se o caractere é uma letra ou está fora do intervalo de números
            JA LETRA            ; Se for uma letra, salta para o processamento de letras
            
            CMP BL, 01          ; Se o segundo número digitado é um número, verifica se o primeiro digitado é 1
            JE DEZENA           ; Pula para DEZENA para validar o número

            CMP BL,02           ; Verifica se o primeiro numero digitado é 2, se for, então só é possível digitar 0 posteriormente, já que a maior linha possível é 20  
            JE VINTE            ; Se o segundo caracter dor um número e o primeiro não for o 1 e nem 2, pula para NPERMITIDO_ATIRA

            JMP NPERMITIDO_ATIRA_ANCORA     ; Ancora para NPERMITIDO_ATIRA por causa do alcance do salto condicional

            DEZENA:             ; Caso o primeiro numero seja 1, verifica se o segundo é entre 0 e 9 
            CMP AL,30H          ; Verifica se o caractere é válido
            JB NPERMITIDO_ATIRA_ANCORA  ; Ancora para NPERMITIDO_ATIRA por causa do alcance do salto condicional
            JMP TIRO_VALIDO     ; Se passar de todas as verificações é um tiro valido
 
            VINTE:
            CMP AL,30H          ; Se for o 2, verifica se o número é '0'
            JNE NPERMITIDO_ATIRA ; Se não for 0, avisa que não é permitido
 
            TIRO_VALIDO:
            AND AL,0FH       ; Converte o número ASCII para o correspondente valor numérico
            PUSH AX          ; Salva o valor atual de AX na pilha
            MOV AL,10        ; Carrega o valor 10 para multiplicação
            MUL BL           ; Multiplica 10 pelo número da linha armazenado em BL
            MOV BX,AX        ; Armazena o resultado em BX
            POP AX           ; Restaura o valor original de AX da pilha

            ADD BL,AL        ; Soma o resultado da multiplicação com o segundo número 

            INT 21H          ; Lê o próximo caractere para validação final

            CMP AL, 1BH      ; Verifica novamente se a tecla ESC foi pressionada
            JE SAIDA2        ; Sai se for ESC e encerra o jogo

            CMP AL,08H       ; Verifica se a tecla BACKSPACE foi pressionada
            JE BACKSPACE2    ; Se backspace foi precionada, pula para BACKSPACE2 

            JMP LETRA        ; Salta para o processamento da letra
            
            SAIDA2:          ; Transformação do jump condicional para o incondicional             
            JMP SAIDAincondicional ; Salta para a saída, trecho de código motivado por limitações dos jumps condicionais

            BACKSPACE1:      ; Backspace1 caso o usuário de backspace no primeiro número digitado 
            CALL BACKSPACE      ; Chama o procedimento que exclui o caractere digitado na tela
            JMP VOLTA_NPERMITIDO    ; Volta para entrada do primeiro numero novamente

            BACKSPACE2:      ; Backspace2 caso o usuário de backspace no segundo número digitado 
            PUSH AX
                MOV AX,BX    ; Retorna o valor de BX que havia sido alterado pelo sdegundo numero
                MOV BX,10   
                DIV BL  
                XOR AH,AH
                MOV BX,AX 
            POP AX    
            CALL BACKSPACE   ; Chama o procedimento que exclui o caractere digitado na tela
            JMP BACKSPACE_CHECKPOINT    ; Volta para entrada do segundo numero novamente

        LETRA:
            CMP AL,41H       ; Compara com o valor ASCII da letra 'A'
            JB NPERMITIDO_ATIRA ; Se for menor, é inválido

            CMP AL,61H       ; Verifica se é uma letra minúscula comparando com o valor ASCII da letra 'a'
            JAE MINUSCULA    ; Se for, salta para o processamento de minúsculas

            CMP AL,54H       ; Verifica se é maior que 'T' (ultima coluna do tabuleiro)
            JA NPERMITIDO_ATIRA ; Se for, é inválido

            PUSH AX          ; Salva o valor atual de AX na pilha
            DEC BL           ; Decrementa BL para ajustar o índice da linha

            MOV AL,20        ; Carrega o valor 20 para multiplicação (tamanho da linha)
            MUL BL           ; Multiplica 20 pelo número da linha
            MOV BX,AX        ; Armazena o resultado em BX
            POP AX           ; Restaura o valor original de AX da pilha
    
            SUB AL,41H       ; Converte a letra maiúscula para o índice da coluna
            JMP EXITLETRA    ; Salta para a saída

        MINUSCULA:
            CMP AL,74H       ; Compara com o valor ASCII da letra 't'
            JA NPERMITIDO_ATIRA ; Se for maior que 't', é inválido

            PUSH AX          ; Salva o valor atual de AX na pilha
            DEC BL           ; Decrementa BL para ajustar o índice da linha

            MOV AL,20        ; Carrega o valor 20 para multiplicação (tamanho da linha)
            MUL BL           ; Multiplica 20 pelo número da linha
            MOV BX,AX        ; Armazena o resultado em BX
            POP AX           ; Restaura o valor original de AX da pilha

            SUB AL,61H       ; Converte a letra minúscula para o índice da coluna

        EXITLETRA:
            XOR AH,AH        ; Zera AH para usar AX como endereço de coluna
            MOV SI,AX        ; Move o índice da coluna para SI

            CMP MATRIZ[BX][SI],'*' ; Verifica se o alvo já foi atingido 
            JNE TIROREPETIDO_

            MOV AH,GABARITO[BX][SI] ; Carrega o valor correspondente da matriz gabarito para AH
            MOV MATRIZ[BX][SI],AH   ; Atualiza a matriz com o valor da posição atingida do gabarito

            CMP AH, '#'            ; Verifica se o tiro foi um acerto ('#' representa um acerto)
            JE ACERTO              ; Se sim, salta para a rotina de acerto

            RETORNO: 
            RET                    ; Retorna ao chamador após processar o tiro

        NPERMITIDO_ATIRA:
            PUSH AX                ; Salva o valor atual de AX na pilha 

            MENSAGEM NPERMITIDO    ; Exibe a mensagem de entrada não permitida
            MOV AH,01              ; Prepara para ler um caractere para continuar
            INT 21H                ; Espera por um entrada do usuário 

            POP AX                 ; Restaura o valor original de AX 
            INC CX                 ; Incrementa CX para que o usuário não perca uma tentativa em vão 
            JMP RETORNO            ; Retorna ao ponto de entrada para nova tentativa

        ACERTO: 
            INC CX                 ; Incrementa o contador de acertos gerais
            INC DX                 ; Incrementa o contador específico para verificação da condição de vitória
            JMP RETORNO            ; Retorna após registrar o acerto

        TIROREPETIDO_:
            PUSH AX                ; Salva o valor atual de AX na pilha
            MENSAGEM TIROREPETIDO  ; Exibe a mensagem de tiro repetido
            MOV AH,01              ; Prepara para ler um caractere para continuar
            INT 21H                ; Espera por um entrada do usuário
            POP AX                 ; Restaura o valor original de AX 
            INC CX                 ; Incrementa CX para que o usuário não perca uma tentativa em vão
            JMP RETORNO            ; Retorna ao chamador após tratar o tiro repetido

        SAIDAincondicional:
            MOV DX,20              ; Carrega o valor 20 em DX para uso posterior
            INC CX                 ; Incrementa o contador CX
            JMP RETORNO            ; Retorna ao chamador após sair de forma condicional

    ATIRA ENDP                ; Fim do procedimento Atira
 
    TentativasRestantes PROC          ; Início do procedimento para exibir o número de tentativas restantes
        PUSH_ALL                 ; Salva todos os registradores para preservar o contexto

        MOV BX,10               ; Define BX como 10 (para divisão por 10, usada na conversão de números)
        MOV AX,CX               ; Move o valor de CX (número de tentativas restantes) para AX
        XOR CX,CX               ; Zera o registrador CX (usado como contador de dígitos)

        REPEAT_TENTRES:             ; Loop para converter o número de tentativas para dígitos individuais
            XOR DX,DX               ; Zera DX antes da divisão

            DIV BL                  ; Divide AX por 10, resultado em AL, resto em AH
            MOV DL,AH               ; Armazena o valor do resto (dígito) em DL
            PUSH DX                 ; Salva o dígito convertido na pilha
            XOR AH,AH               ; Zera o registrador AH
            INC CX                  ; Incrementa CX (conta o número de dígitos)
            TEST AX,AX              ; Testa se o valor em AX é zero
            JNZ REPEAT_TENTRES      ; Se AX não for zero, repete o loop

            MOV AH,02H              ; Configura para imprimir um caractere na tela

        LOOP_TENTRES:               ; Loop para imprimir os dígitos em ordem correta
            POP DX                  ; Recupera o próximo dígito da pilha
            OR DL,30H               ; Converte o dígito para o código ASCII ('0' - '9')
            INT 21H                 ; Imprime o dígito na tela
            LOOP LOOP_TENTRES       ; Repete o loop até que todos os dígitos sejam impressos

        POP_ALL                 ; Restaura todos os registradores
        RET                     ; Retorna do procedimento
    TentativasRestantes ENDP    ; Fim do procedimento
     
    
    BACKSPACE PROC          ; Procedimento para representar a movimentação do backspace na tela
        PUSH_ALL            ; Salva todos os registradores para preservar o contexto
            MOV AH,02 
 
            MOV DL,20H      ; Imprime espaço (para tirar o ultimo caractere digitado)
            INT 21H

            MOV DL,08       ; Imprime backspace (para voltar o ponteiro de digitação um digito)  
            INT 21H 
        POP_ALL             ; Restaura todos os registradores salvos
        RET                 ; Retorna ao chamador após processar o backspace
    BACKSPACE ENDP    
END MAIN  