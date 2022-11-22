;---------------------------------------
; Macro printch
;-------------------------------------------
printch macro mch
  push ax        ; salva AX na pilha
  push dx        ; salva DX na pilha
  mov dl,mch     ; imprime digito
  mov ah,02      ; syscall function 02
  int 21h        ; dos interrupt
  pop dx         ; resstaura DX
  pop ax         ; restarqa AX
endm


;-------------------------------------------
; Macro sai para dos
;-------------------------------------------
sai_dos macro
   push ax  ; jogo para a pilha o conteudo do reg ax
   mov ax,0
   mov ah,4Ch
   int 21h
   pop ax   ; recupero da pilha o conteudo da pilha
endm
;-------------------------------------------
; Macro Posiciona cursor linha, coluna 
;-------------------------------------------
pos_rc macro mL,mC
    push ax    ; salvando o contexto na pilha: ax,
    push bx    ;    bx
    push dx    ;     dx
    mov bh,0   ; determina pagina de video
    mov dh,mL  ; determino a linha para posicionar o cursor
    mov dl,mC  ; determino a coluna para posicionar o cursor
    mov ah,2   ; funcao 02 - da bios
    int 10h    ; chama interrucao
    pop dx     ; recupero o contexto da pilha   dx
    pop bx     ;  bx
    pop dx     ;  dx
endm
;-------------------------------------------
;  Macro pausa
;-------------------------------------------
pausa macro
    push ax
    mov ax,0
    mov ah,7
    int 21h
    pop ax
endm
;-------------------------------------------
; Macro limpa tela
;-------------------------------------------
cls macro
    push ax
    mov ax,0
    mov ah,0fh
    int 10h
    mov ah,0
    int 10h
    pop ax

endm
;-------------------------------------------
;  Macro imprime texto
;-------------------------------------------
print macro t
    push ax
    push ds
    push dx
    mov ax,@data ;segmento de dados definido no programa principal
    mov ds,ax
    lea dx,t    ; Carrega o end efetivo da variavel de texto t em DX
    mov ah,09   ; carrega a funcao 09 do DOS
    int 21h     ; promive a interrupcao 21h  imprime a string t
    pop dx
    pop ds
    pop ax
endm
;-------------------------------------------
;  Macro imprime numero na variavel N
;-------------------------------------------
printn macro mN,mB,mS
    push ax
    push bx
    mov ax, 0
    mov al, mN
    div mB[2]    ; divide por 100
    mov mS[0],al
    add mS[0],48 ; codigo ascii do zero '0' em S
    mov bx,0
    mov bl,ah    ; resto em ah
    mov ax,0
    mov al,bl    ; coloca o resto em al
    div mB[1]    ; divide por 10
    mov mS[1],al ; coloca o resultado em S
    add mS[1], 48  ; transforma em codigo ascii
    mov mS[2],ah   ; resultado em ah para S
    add ms[2],48   ; transforma em codigo ascii
    print mS       ; imprime o numero
    pop bx
    pop ax
endm
;-------------------------------------------
; Macro Pega numero de 3 digitos de 0 - 255
;-------------------------------------------
 pega3dig macro mN,mE,mB,mS, mTE,mTN
     local e_pedn1, e_cap, e_conv, e_limpar, e_impr, e_sair
     cls           ; limpa a tela
     pos_rc 10,6
     print mTN     ; imprime mensagem de texto em mTn
     mov di,0      ; inicializa contador de digitos em di
 e_cap:
     mov ax,0
     mov ah,07     ; captura tecla pressionada
     int 21h       ; promove a interrupcao do DOS
     cmp al,48     ; verifica se codigo ascii eh menor que 48 {0}
     jb  e_cap     ; se for menor, volta a capturar nova tecla
     cmp al,57     ; verifica se eh maior que 57 {9}
     ja e_cap      ; se maior, volta a capturar nova tecla
     mov mE[di],al ; se tudo o, armazena codigo ascii em mE
     sub mE[di],'0'; converte para numero
     mov dl,al     ; imprime digito
     mov ah,02
     int 21h
     inc di        ; incrementa contador   di = di+1
     cmp di,3      ; verifica se pegou os 3 digitos
     jb e_cap      ; se nao , continua a capturar
     mov si,2      ; inicializa outro contador em si
     mov di,0      ; zera contador em di
     jmp e_conv    ; converte os  digitos capturados
e_conv:
     mov ax,0        ;zera ax
     mov al,mE[di]   ; pega o primeiro digito
     mul mB[si]      ; multiplica pela base B = [1,10,100]
     jo e_limpar     ; verifica se esta entre 0 e 255
     jc e_limpar
     add mN,al       ; armazena em mN
     jc e_limpar
     dec si
     inc di
     cmp di,3        ; repete para os  3 digitos em mE
     jb  e_conv
     jmp e_impr      ; imprime o valor em mN
e_limpar:
     cls             ; limpa a tela
     pos_rc 10,6
     print mTE       ; imprime msg de numero invalido
     pausa           ; aguarda qualquer tecla
     cls             ; limpa a tela
     pos_rc 10,6
     print mTN       ; imprime texto novamente
     mov mN,0
     mov mE[0],0
     mov mE[1],0     ; limpa variaveis
     mov mE[2],0
     mov di,0
     jmp e_cap       ; pega os digitos novamente
e_impr:
     cls
     pos_rc 10,6
     print mTN
     printn mN,mB,mS ; limpa tela e imprime o numero armazenado em mN
     
e_sair:
                     ;  retorna

endm
;-------------------------------------------
; Macro cria arquivo texto
;-------------------------------------------

cria_txt macro mNome,mTC,mTE ; nome do arquivo, texto se tudo ok, texto de erro
       local erro, sair
       mov ax,@data    ; registrados DS com o segmento de dados atual
       mov ds,ax       ; coloca em DS
       mov ah,3ch      ; tenta criar arquivo
       mov cx,0
       mov dx, offset mNome ; determina o nome do arquivo a ser criado
       int 21h              ; chama interrupcao do DOS
       jc erro              ; se houver erro, trata o erro
       mov bx,ax
       mov ah,03eh          ; funcao que fecha arquivo
       int 21h              ; interrucao do dos
       print mTC            ; msg que arquivo foi criado com sucesso!
       jmp sair
 erro:
       print mTE            ; se houve erros na criacao, imprime msg de erro 
 sair:
 endm

;-------------------------------------------
; Macro pega uma cadeia de caracteres
;-------------------------------------------
 pegac macro mTXT
    local pega
    mov si,0         ; zero contador SI
 pega:
    mov ah,01h       ; pega um tecla digitada - codigo ascII
    int 21h          ; chama o DOS
    mov mTXT[si],al  ; armazena o conteudo retornado em al na variavel 
    inc si           ; pega a proxima
    cmp al,0dh       ; verifica se tecla = enter
    ja pega          ; senao for enter, continua
    jb pega          ; continua...
endm

;-------------------------------------------
; Macro escreve em um arquivo texto
;-------------------------------------------
escrevetxt macro mNome,mTXT,mTE
local erro, sair
      pegac mTXT           ; pega cadeia de caracteres do teclado
      mov ah,03dh          ; funcao de abrir arquivo
      mov al,01            ; 0 - Leitura 1-escrita 2 - R/W
      mov dx, offset mNome ; pega o nome do arquivo
      int 21h              ; chama o DOS
      jc erro              ; trata se houver erro
      mov bx,ax            ; guarda o conteudo de AX
      mov cx, si           ; cx contem o numero de caracteres a ser escrito no arq
      mov dx, offset mTXT  ; DX pega o endereco da variavel que contem o texto
      mov ah, 40h          ; escreve no arquivo
      int 21h              ; chama o DOS
      cmp cx,ax            ; se houver erro, trata
      jne erro
      mov ah, 3eh          ; fechar o arquivo
      int 21h
      jmp sair
  erro:
      print mTE            ; msg de erro de arquivo
  sair:
endm

;---------------------------------------------------------
; imprime moldura simples
;---------------------------------------------------------

mold_s macro LIh,LFh,CIh,CFh
   local carac_horiz,linha,carac_spc,carac_spcf,carac_spch 

   ; cls           ; limpa a tela
   ; posiciona em LI,CI na tela
  mov ax,@data  ; determina onde fica o segmento de dados em AX
  mov ds,ax     ; coloca o endereco do segmento de dados em DS 
 
 ;---------------------------------------------------------
 ; calculo do nro de linhas e colunas
 ;---------------------------------------------------------
  mov bx,LIh
  mov ax, LFh
  sub ax,bx
  mov linhas, al  ; armazena na variavel LINHAS
  mov bx, CIh
  mov ax, CFh
  sub ax,bx
  inc al     ; soma 1 em al
  mov colunas, al ; armazena na variavel Colunas
  pos_rc LIh,CIh+1
  printch sup_esq_s ; imprime caracter sup esquerdo simples
  
  mov al, colunas
  inc al
  mov ah,0
  mov cx,ax      ;  caracteres horizontais em cx

carac_horiz:

  printch  hori_s     ; impprime todos os carac horizontais
  loop carac_horiz    ; repete ate cx=00

  printch sup_dir_s   ; imprime caracter superior direito simples
  
  printch cr     ; carriage return : volta o cursor
  printch lf     ; line feed : vai para proxima linha

  mov bh,0  
  mov bl, linhas
  mov si,bx ; contador de linhas em si

linha:  
  printch espaco 
  printch vert_s    ; imprime caratere vertical simples
  mov al, colunas
  mov ah,0
  mov cx,ax      ;  caracteres espaco
carac_spc:
  printch espaco
  dec cx        ; decrementa o cx
  cmp cx,ax      ; imprime enquanto nao terminar
  jb  carac_spc
  printch vert_s  ; imprime caratere vertical simples
  printch cr
  printch lf
  dec si          ; decrementa o contador de linhas
  cmp si,bx
  jb  linha
  printch espaco
  printch inf_esq_s ; imprrime caractere inferior esquerdo simples
  
  mov cx,ax      ; Colunas -> caracteres espaco
carac_spcf:
  printch hori_s   ;imrime o caractere simples horiontal 
  dec cx           ; decrementa o cx
  cmp cx,ax        ; imprime enquanto nao terminar
  jb  carac_spcf
  printch inf_dir_s ; imprime caractere inferior direito
  ;---------------------------------------------------------
  ;  imprime sub moldura
  ;---------------------------------------------------------
  printch cr
  printch lf
  
  printch espaco
  pos_rc LIh+2,CIh+1
  mov ah,0
  mov al,colunas
  mov cx,ax
  printch esq_s
carac_spch:
  printch hori_s
  dec cx              ; decrementa o cx
  cmp cx,ax      ; imprime enquanto nao terminar
  jb  carac_spch
  printch dir_s

endm
  ;---------------------------------------------------------
  ; imprime moldura Dupla
  ;---------------------------------------------------------

mold_d macro LIn,LFn,CIn,CFn
  local carac_horiz_d,linha_d,carac_spc_d,carac_spcf_d,carac_spchd
  
  ;cls           ; limpa a tela
  
  mov ax,@data  ; determina onde fica o segmento de dados em AX
  mov ds,ax     ; coloca o endereco do segmento de dados em DS 
 
 ;---------------------------------------------------------
 ; calculo do nro de linhas e colunas           carac_horiz
 ;---------------------------------------------------------
  mov bx,LIn
  mov ax, LFn
  sub ax,bx
  mov linhas, al  ; armazena na variavel LINHAS
  mov bx, CIn
  mov ax, CFn
  sub ax,bx
  mov colunas, al ; armazena na variavel Colunas

  pos_rc LIn,CIn+1   ; posiciona em LI,CI na tela
  printch sup_esq_d ; imprime caracter sup esquerdo simples
  mov al, colunas
  inc al
  mov ah,0
  mov cx,ax      ;  caracteres horizontais

carac_horiz_d:

  printch  hori_d     ; impprime todos os carac horizontais
  loop carac_horiz_d

  printch sup_dir_d 
  
  printch cr     ; carriage return : volta o cursor
  printch lf     ; line feed : vai para proxima linha

mov bh,0  
mov bl, linhas
mov si,bx ; contador de linhas

linha_d:  
  printch espaco 
  printch vert_d
  mov al, colunas
  mov ah,0
  mov cx,ax      ;  caracteres espaco
carac_spc_d:
  printch espaco
  dec cx        ; decrementa o cx
  cmp cx,ax      ; imprime enquanto nao terminar
  jb  carac_spc_d
  printch vert_d
  printch cr
  printch lf
  dec si
  cmp si,bx
  jb  linha_d
  printch espaco
  printch inf_esq_d
  
  mov cx,ax      ; 40 caracteres espaco
carac_spcf_d:
  printch hori_d
  dec cx              ; decrementa o cx
  cmp cx,ax      ; imprime enquanto nao terminar
  jb  carac_spcf_d
  printch inf_dir_d
  

  printch cr
  printch lf
  
  printch espaco
  pos_rc LIn+2,CIn+1
  mov ah,0
  mov al,colunas
  mov cx,ax
  printch esq_d
 carac_spchd:
  printch hori_d
  dec cx              ; decrementa o cx
  cmp cx,ax      ; imprime enquanto nao terminar
  jb  carac_spchd
  printch dir_d


endm
;---------------------------------------------------------
; imprime moldura Dupla/simles
;---------------------------------------------------------
moldura macro mLIn,mLFn,mCIn,mCFn,mS
    local dupla,simples, saida

    push ax      ; salva contexto na pilha
    mov al,mS    ; veifico qual funcao ativar
    cmp al,1
    je  dupla    ; se for  1 moldura dupla
    jmp simples  ; se for 0 moldura simples
  dupla:
    mold_d mLIn,mLFn,mCIn,mCFn
    jmp saida
  simples:
     mold_s mLIn,mLFn,mCIn,mCFn
    saida:
     pop ax

endm


