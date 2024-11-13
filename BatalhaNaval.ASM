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

.DATA                   ; Seção de dados
    VETORL DB 'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T' ; Letras para colunas
    VETORN DB '1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20' ; Números para linhas
    MATRIZ DB 20 DUP (20 DUP ('*'))  ; Cria uma matriz 20x20 inicializada com '*'
    GABARITO DB 20 DUP (20 DUP ('X')) ; Cria a matriz gabarito

    ; Mensagens usadas no jogo
    TIROMSG DB 10,13,'Qual a cordenada em que voce quer atirar?(ex: 1a, 17Q, 6T)',10,13,'$' 
    TENRESMSG1 DB '(Tentativas Restantes: $' 
    TENRESMSG2 DB ')',10,13,'$'  
 
    MSG2 DB 10,13,'Digite uma sequência de 7 digitos, usando números de 1 a 5',10,13,'$'
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
        MOV CX,6
        MENSAGEM MSG2 
        JOGO:          
            INT 21H             ; Lê a entrada do teclado (caractere do usuário)
            CMP AL, 1BH         ; Verifica novamente se a tecla ESC foi pressionada
            JE SAIDA_           ; Sai se for ESC e encerra o jogo

            CMP CX,6
            JE ENCOURACADOBOT
            CMP CX,5
            JE FRAGATABOT
            CMP CX,4
            JE SUBMARINOBOT
            CMP CX,3
            JE SUBMARINO_2BOT
            CMP CX,2
            JE HIDROAVBOT
            CMP CX,1
            JE HIDROAV_2BOT

            FRAGATABOT:
                JMP FRAGATABOT_

            SUBMARINOBOT:
                JMP SUBMARINOBOT_

            SUBMARINO_2BOT:
                JMP SUBMARINO_2BOT_

            HIDROAVBOT:
                JMP HIDROAVBOT_

            HIDROAV_2BOT:
                JMP HIDROAV_2BOT_

            ENCOURACADOBOT:
                CMP AL,31H          ; Verifica se o caractere é '1'
                JE ENCOURACADO1             ; Se for '1', salta para o bloco de jogo BOT1
                JB INVALIDO_ANCORA1         ; Se o caractere for menor que '1', é inválido
                CMP AL,32H          ; Verifica se o caractere é '2'
                JE ENCOURACADO2             ; Se for '2', salta para o bloco de jogo BOT2
                CMP AL,33H          ; Verifica se o caractere é '3'
                JE ENCOURACADO3             ; Se for '3', salta para o bloco de jogo BOT3
                CMP AL,34H          ; Verifica se o caractere é '4'
                JE ENCOURACADO4             ; Se for '4', salta para o bloco de jogo BOT4
                CMP AL,35H          ; Verifica se o caractere é '5'
                JE ENCOURACADO5 
                JA INVALIDO_ANCORA1

                ENCOURACADO1: ;Posiciona as embarcações de acordo com as cordenadas dadas no bot 1
                    PUSH_ALL
                    MOV BX,6
                    MOV SI,20
                    MOV DX,1      ; Verifica direção do barco (1 = VERTICAL , 0 = HORIZONTAL)
                    CALL ENCOURACADO
                    
                    LOOP JOGO           ; Salta para a saída após posicionar os navios

                ENCOURACADO2: ;Posiciona as embarcações de acordo com as cordenadas dadas no bot 1
                    PUSH_ALL
                    MOV BX,11
                    MOV SI,14
                    MOV DX,0      ; Verifica direção do barco (1 = VERTICAL , 0 = HORIZONTAL)
                    CALL ENCOURACADO

                    LOOP JOGO           ; Salta para a saída após posicionar os navios
    
                ENCOURACADO3: ;Posiciona as embarcações de acordo com as cordenadas dadas no bot 1
                    PUSH_ALL
                    MOV BX,14
                    MOV SI,1
                    MOV DX,0      ; Verifica direção do barco (1 = VERTICAL , 0 = HORIZONTAL)
                    CALL ENCOURACADO
                    LOOP JOGO_ANCORA1           ; Salta para a saída após posicionar os navios

                ENCOURACADO4: ;Posiciona as embarcações de acordo com as cordenadas dadas no bot 1
                    PUSH_ALL
                    MOV BX,12
                    MOV SI,6
                    MOV DX,1      ; Verifica direção do barco (1 = VERTICAL , 0 = HORIZONTAL)
                    CALL ENCOURACADO

                    LOOP JOGO_ANCORA1           ; Salta para a saída após posicionar os navios

                ENCOURACADO5: ;Posiciona as embarcações de acordo com as cordenadas dadas no bot 1
                    PUSH_ALL
                    MOV BX,9
                    MOV SI,10
                    MOV DX,1      ; Verifica direção do barco (1 = VERTICAL , 0 = HORIZONTAL)
                    CALL ENCOURACADO

                    LOOP JOGO_ANCORA1           ; Salta para a saída após posicionar os navios
            ;

            JOGO_ANCORA1:
                JMP JOGO

            INVALIDO_ANCORA1:
                JMP INVALIDO

            FRAGATABOT_:
                CMP AL,31H          ; Verifica se o caractere é '1'
                JE FRAGATA1             ; Se for '1', salta para o bloco de jogo BOT1
                JB INVALIDO_ANCORA1         ; Se o caractere for menor que '1', é inválido
                CMP AL,32H          ; Verifica se o caractere é '2'
                JE FRAGATA2             ; Se for '2', salta para o bloco de jogo BOT2
                CMP AL,33H          ; Verifica se o caractere é '3'
                JE FRAGATA3             ; Se for '3', salta para o bloco de jogo BOT3
                CMP AL,34H          ; Verifica se o caractere é '4'
                JE FRAGATA4             ; Se for '4', salta para o bloco de jogo BOT4
                CMP AL,35H          ; Verifica se o caractere é '5'
                JE FRAGATA5 
                JA INVALIDO_ANCORA1

                FRAGATA1: ;Posiciona as embarcações de acordo com as cordenadas dadas no bot 1
                    PUSH_ALL
                    MOV BX,1
                    MOV SI,15
                    MOV DX,0      ; Verifica direção do barco (1 = VERTICAL , 0 = HORIZONTAL)
                    CALL FRAGATA

                    LOOP JOGO_ANCORA1           ; Salta para a saída após posicionar os navios

                FRAGATA2: ;Posiciona as embarcações de acordo com as cordenadas dadas no bot 1
                    MOV BX,1
                    MOV SI,20
                    MOV DX,1      ; Verifica direção do barco (1 = VERTICAL , 0 = HORIZONTAL)
                    CALL FRAGATA

                    LOOP JOGO_ANCORA1           ; Salta para a saída após posicionar os navios
    
                FRAGATA3: ;Posiciona as embarcações de acordo com as cordenadas dadas no bot 1
                    MOV BX,3
                    MOV SI,9
                    MOV DX,1      ; Verifica direção do barco (1 = VERTICAL , 0 = HORIZONTAL)
                    CALL FRAGATA

                    LOOP JOGO_ANCORA1           ; Salta para a saída após posicionar os navios

                FRAGATA4: ;Posiciona as embarcações de acordo com as cordenadas dadas no bot 1
                    MOV BX,5
                    MOV SI,2
                    MOV DX,0      ; Verifica direção do barco (1 = VERTICAL , 0 = HORIZONTAL)
                    CALL FRAGATA
                    
                    LOOP JOGO_ANCORA1           ; Salta para a saída após posicionar os navios

                FRAGATA5: ;Posiciona as embarcações de acordo com as cordenadas dadas no bot 1
                    MOV BX,8
                    MOV SI,4
                    MOV DX,0      ; Verifica direção do barco (1 = VERTICAL , 0 = HORIZONTAL)
                    CALL FRAGATA

                    LOOP JOGO_ANCORA1           ; Salta para a saída após posicionar os navios
            ;



            SUBMARINOBOT_:
                CMP AL,31H          ; Verifica se o caractere é '1'
                JE SUBMARINO1             ; Se for '1', salta para o bloco de jogo BOT1
                JB INVALIDO_ANCORA1         ; Se o caractere for menor que '1', é inválido
                CMP AL,32H          ; Verifica se o caractere é '2'
                JE SUBMARINO2             ; Se for '2', salta para o bloco de jogo BOT2
                CMP AL,33H          ; Verifica se o caractere é '3'
                JE SUBMARINO3             ; Se for '3', salta para o bloco de jogo BOT3
                CMP AL,34H          ; Verifica se o caractere é '4'
                JE SUBMARINO4             ; Se for '4', salta para o bloco de jogo BOT4
                CMP AL,35H          ; Verifica se o caractere é '5'
                JE SUBMARINO5 
                JA INVALIDO_ANCORA1

                SUBMARINO1: ;Posiciona as embarcações de acordo com as cordenadas dadas no bot 1
                    PUSH_ALL
                    MOV BX,6
                    MOV SI,1
                    MOV DX,1      ; Verifica direção do barco (1 = VERTICAL , 0 = HORIZONTAL)
                    CALL SUBMARINO

                    LOOP JOGO_ANCORA1           ; Salta para a saída após posicionar os navios

                SUBMARINO2: ;Posiciona as embarcações de acordo com as cordenadas dadas no bot 1
                    PUSH_ALL
                    MOV BX,7
                    MOV SI,9
                    MOV DX,1      ; Verifica direção do barco (1 = VERTICAL , 0 = HORIZONTAL)
                    CALL SUBMARINO

                    LOOP JOGO_ANCORA1           ; Salta para a saída após posicionar os navios
    
                SUBMARINO3: ;Posiciona as embarcações de acordo com as cordenadas dadas no bot 1
                    PUSH_ALL
                    MOV BX,8
                    MOV SI,17
                    MOV DX,1      ; Verifica direção do barco (1 = VERTICAL , 0 = HORIZONTAL)
                    CALL SUBMARINO

                    LOOP JOGO_ANCORA1           ; Salta para a saída após posicionar os navios

                SUBMARINO4: ;Posiciona as embarcações de acordo com as cordenadas dadas no bot 1
                    PUSH_ALL
                    MOV BX,16
                    MOV SI,1
                    MOV DX,0      ; Verifica direção do barco (1 = VERTICAL , 0 = HORIZONTAL)
                    CALL SUBMARINO

                    LOOP JOGO_ANCORA1           ; Salta para a saída após posicionar os navios

                SUBMARINO5: ;Posiciona as embarcações de acordo com as cordenadas dadas no bot 1
                    PUSH_ALL
                    MOV BX,14
                    MOV SI,11
                    MOV DX,0     ; Verifica direção do barco (1 = VERTICAL , 0 = HORIZONTAL)
                    CALL SUBMARINO

                    LOOP JOGO_ANCORA1           ; Salta para a saída após posicionar os navios
            ;

            JOGO_ANCORA2:
                

            SUBMARINO_2BOT_:
                CMP AL,31H          ; Verifica se o caractere é '1'
                JE SUBMARINO_21             ; Se for '1', salta para o bloco de jogo BOT1
                JB INVALIDO_ANCORA2         ; Se o caractere for menor que '1', é inválido
                CMP AL,32H          ; Verifica se o caractere é '2'
                JE SUBMARINO_22             ; Se for '2', salta para o bloco de jogo BOT2
                CMP AL,33H          ; Verifica se o caractere é '3'
                JE SUBMARINO_23             ; Se for '3', salta para o bloco de jogo BOT3
                CMP AL,34H          ; Verifica se o caractere é '4'
                JE SUBMARINO_24             ; Se for '4', salta para o bloco de jogo BOT4
                CMP AL,35H          ; Verifica se o caractere é '5'
                JE SUBMARINO_25 
                JA INVALIDO_ANCORA2

                SUBMARINO_21: ;Posiciona as embarcações de acordo com as cordenadas dadas no bot 1
                    PUSH_ALL
                    MOV BX,13
                    MOV SI,15
                    MOV DX,0     ; Verifica direção do barco (1 = VERTICAL , 0 = HORIZONTAL)
                    CALL SUBMARINO

                    LOOP JOGO_ANCORA1           ; Salta para a saída após posicionar os navios

                SUBMARINO_22: ;Posiciona as embarcações de acordo com as cordenadas dadas no bot 1
                    PUSH_ALL
                    MOV BX,19
                    MOV SI,1
                    MOV DX,0     ; Verifica direção do barco (1 = VERTICAL , 0 = HORIZONTAL)
                    CALL SUBMARINO

                    LOOP JOGO_ANCORA1           ; Salta para a saída após posicionar os navios
    
                SUBMARINO_23: ;Posiciona as embarcações de acordo com as cordenadas dadas no bot 1
                    PUSH_ALL
                    MOV BX,19
                    MOV SI,10
                    MOV DX,0     ; Verifica direção do barco (1 = VERTICAL , 0 = HORIZONTAL)
                    CALL SUBMARINO

                    LOOP JOGO_ANCORA1           ; Salta para a saída após posicionar os navios

                SUBMARINO_24: ;Posiciona as embarcações de acordo com as cordenadas dadas no bot 1
                    PUSH_ALL
                    MOV BX,20
                    MOV SI,15
                    MOV DX,0     ; Verifica direção do barco (1 = VERTICAL , 0 = HORIZONTAL)
                    CALL SUBMARINO

                    LOOP JOGO_ANCORA1           ; Salta para a saída após posicionar os navios

                SUBMARINO_25: ;Posiciona as embarcações de acordo com as cordenadas dadas no bot 1
                    PUSH_ALL
                    MOV BX,20
                    MOV SI,19
                    MOV DX,0     ; Verifica direção do barco (1 = VERTICAL , 0 = HORIZONTAL)
                    CALL SUBMARINO

                    LOOP JOGO_ANCORA1           ; Salta para a saída após posicionar os navios
            ;

            INVALIDO_ANCORA2:
                JMP INVALIDO

            HIDROAVBOT_:
                CMP AL,31H          ; Verifica se o caractere é '1'
                JE HIDROAV1             ; Se for '1', salta para o bloco de jogo BOT1
                JB INVALIDO_ANCORA2         ; Se o caractere for menor que '1', é inválido
                CMP AL,32H          ; Verifica se o caractere é '2'
                JE HIDROAV2             ; Se for '2', salta para o bloco de jogo BOT2
                CMP AL,33H          ; Verifica se o caractere é '3'
                JE HIDROAV3             ; Se for '3', salta para o bloco de jogo BOT3
                CMP AL,34H          ; Verifica se o caractere é '4'
                JE HIDROAV4             ; Se for '4', salta para o bloco de jogo BOT4
                CMP AL,35H          ; Verifica se o caractere é '5'
                JE HIDROAV5 
                JA INVALIDO_ANCORA2

                HIDROAV1: ;Posiciona as embarcações de acordo com as cordenadas dadas no bot 1
                    PUSH_ALL
                    MOV BX,1
                    MOV SI,1
                    CALL HIDROAV

                    LOOP JOGO_ANCORA1           ; Salta para a saída após posicionar os navios

                HIDROAV2: ;Posiciona as embarcações de acordo com as cordenadas dadas no bot 1
                    PUSH_ALL
                    MOV BX,5
                    MOV SI,6
                    CALL HIDROAV

                    LOOP JOGO_ANCORA1           ; Salta para a saída após posicionar os navios
    
                HIDROAV3: ;Posiciona as embarcações de acordo com as cordenadas dadas no bot 1
                    PUSH_ALL
                    MOV BX,4
                    MOV SI,11
                    CALL HIDROAV

                    LOOP JOGO_ANCORA1           ; Salta para a saída após posicionar os navios

                HIDROAV4: ;Posiciona as embarcações de acordo com as cordenadas dadas no bot 1
                    PUSH_ALL
                    MOV BX,5
                    MOV SI,15
                    CALL HIDROAV

                    LOOP JOGO_ANCORA1           ; Salta para a saída após posicionar os navios

                HIDROAV5: ;Posiciona as embarcações de acordo com as cordenadas dadas no bot 1
                    PUSH_ALL
                    MOV BX,11
                    MOV SI,4
                    CALL HIDROAV

                    LOOP JOGO_ANCORA1           ; Salta para a saída após posicionar os navios
            ;

            HIDROAV_2BOT_:
                CMP AL,31H          ; Verifica se o caractere é '1'
                JE HIDROAV_21             ; Se for '1', salta para o bloco de jogo BOT1
                JB INVALIDO_ANCORA2         ; Se o caractere for menor que '1', é inválido
                CMP AL,32H          ; Verifica se o caractere é '2'
                JE HIDROAV_22             ; Se for '2', salta para o bloco de jogo BOT2
                CMP AL,33H          ; Verifica se o caractere é '3'
                JE HIDROAV_23             ; Se for '3', salta para o bloco de jogo BOT3
                CMP AL,34H          ; Verifica se o caractere é '4'
                JE HIDROAV_24             ; Se for '4', salta para o bloco de jogo BOT4
                CMP AL,35H          ; Verifica se o caractere é '5'
                JE HIDROAV_25 
                JA INVALIDO

                HIDROAV_21: ;Posiciona as embarcações de acordo com as cordenadas dadas no bot 1
                    PUSH_ALL
                    MOV BX,11
                    MOV SI,10
                    CALL HIDROAV

                    LOOP JOGO_ANCORA1           ; Salta para a saída após posicionar os navios
                    JMP SAIDA
                HIDROAV_22: ;Posiciona as embarcações de acordo com as cordenadas dadas no bot 1
                    PUSH_ALL
                    MOV BX,13
                    MOV SI,19
                    CALL HIDROAV
                    
                    LOOP JOGO_ANCORA1           ; Salta para a saída após posicionar os navios
                    JMP SAIDA
                HIDROAV_23: ;Posiciona as embarcações de acordo com as cordenadas dadas no bot 1
                    PUSH_ALL
                    MOV BX,15
                    MOV SI,13
                    CALL HIDROAV

                    LOOP JOGO_ANCORA1           ; Salta para a saída após posicionar os navios
                    JMP SAIDA
                HIDROAV_24: ;Posiciona as embarcações de acordo com as cordenadas dadas no bot 1
                    PUSH_ALL
                    MOV BX,16
                    MOV SI,6
                    CALL HIDROAV

                    LOOP JOGO_ANCORA1           ; Salta para a saída após posicionar os navios
                    JMP SAIDA
                HIDROAV_25: ;Posiciona as embarcações de acordo com as cordenadas dadas no bot 1
                    PUSH_ALL
                    MOV BX,16
                    MOV SI,17
                    CALL HIDROAV

                    LOOP JOGO_ANCORA1           ; Salta para a saída após posicionar os navios
            ;   
        SAIDA:
        POP_ALL                 ; Restaura todos os registradores salvos
        RET                     ; Retorna do procedimento

        INVALIDO:               ; Rótulo para entrada inválida
            CALL BACKSPACE
            JMP JOGO            ; Volta para o início para receber uma nova entrada 
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
    
    ENCOURACADO PROC   
        DEC SI              ; Ajusta índice da linha
        
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
            JMP FIMENCOURACADO

        ENCOURACADO_VERTICAL:
            MOV GABARITO[BX][SI],'#' ; Posiciona parte do navio
            ADD BX,20                ; Move para a próxima linha
            LOOP ENCOURACADO_VERTICAL
        FIMENCOURACADO:
        POP_ALL
        RET
    ENCOURACADO ENDP

    FRAGATA PROC     
        DEC SI              ; Ajusta índice da linha

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
            JMP FIMFRAGATA

        FRAGATA_VERTICAL:
            MOV GABARITO[BX][SI],'#'
            ADD BX,20
            LOOP FRAGATA_VERTICAL
        FIMFRAGATA:
        POP_ALL
        RET
    FRAGATA ENDP

    SUBMARINO PROC   
        DEC SI              ; Ajusta índice da linha

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
            JMP FIMSUBMARINO

        SUBMARINO_VERTICAL:
            MOV GABARITO[BX][SI],'#'
            ADD BX,20
            LOOP SUBMARINO_VERTICAL
        FIMSUBMARINO:
        POP_ALL
        RET
    SUBMARINO ENDP

    HIDROAV PROC
        DEC SI              ; Ajusta índice da linha

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
    HIDROAV ENDP
END MAIN  
