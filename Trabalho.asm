include MACROS.asm

.model small

.stack 0100h

.data
espaco     db  " " ; caractere 32 espaco
resposta db ""
string db "ola mundo$"
string2 db "Bem vindo a utfpr, deseja entrar  $"
contador db 0

sup_esq_s  db  218 ; caractere  canto superior esquerdo
vert_s     db  179 ; caractere  vertical
hori_s     db  196 ; caractere  Horiontal
sup_dir_s  db  191 ; caractere  canto superior direito
inf_esq_s  db  192 ; caractere inferior esquerdo
inf_dir_s  db  217 ; caractere inferior direito
esq_s      db  195
dir_s      db  180

pos_rc  contador,2  ; posiciona o cursor na linha10,col 2
print string  ; imprime a string na tela

sup_esq_d  db  201 ; caractere  canto superior esquerdo
vert_d     db  186 ; caractere  vertical
hori_d     db  205 ; caractere  Horiontal
sup_dir_d  db  187 ; caractere  canto superior direito
inf_esq_d  db  200 ; caractere inferior esquerdo
inf_dir_d  db  188 ; caractere inferior direito

esq_d      db  204
dir_d      db  185

cr       db  13  ; caractere ENTER
lf       db  10  ; caractere LINE FEED

texto    db  "RPG UTFPR $"

linhas   db  0
colunas  db  0
.code       
;
cls ; limpa tela
  moldura 02,22,0,20,1 
  
pos_rc 5,4 ; posiciona linha 5 col 4

print string2 ; print primeiro texto
pos_rc 7,4 ; posiciona linha 7 col 4
pegac resposta

  pausa         ; espera pressionar uma tecla
  sai_dos       ; sai para o DOS
   
end
