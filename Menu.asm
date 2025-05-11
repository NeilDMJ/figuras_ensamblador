.MODEL small
.STACK 100h

.DATA
    MSG1 db ":::::::::::::MENU::::::::::::$",0
    MSG2 db "1. Cuadrados$",0
    MSG3 db "2. Circulos$",0
    MSG4 db "3. Lineas$",0
    MSG5 db "4. Salir$",0
    MSG6 db "Pulse alguna tecla del 1 al 4 de su teclado$",0
    MEN DB 'Hola ........$'
.CODE 

PRINCI PROC FAR
;----------------------------------------------------------------------------------
    ;PROTOCOLO
    mov ax,@data        ;PROTOCOLO resguarda direcci?n del segmento de datos
    mov ds,ax           ;Protocolo ds = ax
;----------------------------------------------------------------------------------
    ;INCIO DEL PROGRAMA
    CALL LIMPIA 
    CALL MENU           ;LLAMADA A LA FUNCION MENU 
    
    CALL SALIDA         ;LLANADA AL SERVICIO DE SALIDA DEL SISTEMA
    
    
    RET
PRINCI ENDP 




;----------------------------------------------------------------------------------
MENU PROC 
;IMPRESION DEL MENU COMPLETO
    MOV AH,02
    MOV BH,00
    MOV DX,0H
    INT 10H
    LEA DX, MSG1           ;Imprime el MSG DE LA PALABRA MENU 
    MOV AH, 9H             ;LLAMADA AL SERVICIO DE IMPRESION 
    INT 21H                ;INTERRUPCION 21 PARA REALIZAR LA ACCI?N
    CALL NEWLINE           ;SALTO DE LINEA 
    
    LEA DX, MSG2           ;IMPRIME 1. CUADROS 
    MOV AH, 9H
    INT 21H 
    CALL NEWLINE 
    
    LEA DX, MSG3           ;IMPRIME 2. CIRCULOS
    MOV AH, 9H
    INT 21H 
    CALL NEWLINE 
    
    LEA DX, MSG4           ;IMPRIME 3. LINEAS
    MOV AH, 9H
    INT 21H 
    CALL NEWLINE
    
    LEA DX, MSG5           ;OPCION PARA SALIR DEL SISTEMA 
    MOV AH, 9H
    INT 21H 
    CALL NEWLINE 
    
    LEA DX, MSG6           ;SELECCI?N DE ALGUNA TECLA 
    MOV AH, 9H
    INT 21H 
    CALL NEWLINE
    
    CALL TECLAS
    RET 
MENU ENDP
;----------------------------------------------------------------------------------
LIMPIA PROC 
   PUSH AX              ;RESGUARDAMOS AX
   PUSH DX              ;RESGUARDAMOS DX
   MOV AX,0600h         ;SERVICIO PARA LIMPIAR PANTALLA
   MOV BH,71h           ;COLOR A OCUPAR 4 BITS PARA CADA UNO EN BH 
   MOV CX,0000h         ;COORDENADAS DEL LIMPIADO
   MOV DX,184Fh         ;CORDENADAS FINALES
   INT 10h              ;LLAMADA A LA INTERRUPCION
   POP DX               ;OBTENEMOS DX
   POP AX 
                        ;OBTENEMOS AX 
LIMPIA ENDP
;----------------------------------------------------------------------------------
TECLAS PROC
    mov ah, 00h
    int 16h  
;*********************************************************************************

RASTREA:
    CMP AL, '1'
    JE OPCION1
    CMP AL,'2'
    JE OPCION2
    CMP AL, '3'
    JE OPCION3
    CMP AL, '4'
    JE OPCION4 
    CALL MENU           ;EN DADO CASO QUE NO SEA ALGUNA DE LAS TRES TECLAS QUE LANCE DE NUEVO AL MENU  
    RET 
OPCION1: 
    MOV AH,02
    MOV BH,00
    MOV DX,0c27h
    INT 10H
    LEA DX,MEN          
    MOV AH,09
    INT 21H
    CALL LIMPIA         ;NOS AYUDA A LIMPIAR AL SALIR  
    JMP EXIT            ;SIRVE PARA ESPERAR ALGUNA TECLA Y REGRESAR UN MENU
    
;*********************************************************************************
OPCION2:
    MOV AH,02   
    MOV BH,00
    MOV DX,0c27h
    INT 10H
    LEA DX,MEN          
    MOV AH,09
    INT 21H
    CALL LIMPIA
    JMP EXIT 
;**********************************************************************************
OPCION3:
    MOV AH,02
    MOV BH,00
    MOV DX,0c27h
    INT 10H
    LEA DX,MEN          
    MOV AH,09
    INT 21H
    CALL LIMPIA 
    JMP EXIT            
;**********************************************************************************
OPCION4:
    CALL SALIDA         ;LLAMA AL SERVICIO DE SALIDA PARA DOSBOX 
    
EXIT:
    ;EN ESPERA DE ALGUNA TECLA 
    mov ah, 00h
    int 16h
    CALL MENU
    
    
    RET
TECLAS ENDP
;----------------------------------------------------------------------------------
SALIDA PROC 
    mov ax, 4C00h
    int 21h
    
    RET 
SALIDA ENDP 
;----------------------------------------------------------------------------------
NEWLINE PROC
   ;Imprime un salto de l?nea
    push ax
    push dx
    mov ah, 02h
    mov dl, 0Dh         ; Retorno de carro
    int 21h
    mov dl, 0Ah         
    int 21h
    pop dx
    pop ax
    RET
NEWLINE ENDP
;**********************************************************************************
ALEATORIO PROC

    RET 
ALEATORIO ENDP 
;**********************************************************************************
CUADRADO PROC

    RET 
CUADRADO ENDP
;**********************************************************************************
END PRINCI



