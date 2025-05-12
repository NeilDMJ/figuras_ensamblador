.MODEL small
.STACK 100 

.DATA
;:::::::::::::::::::::DATA PARA LA PARTE DE MENU::::::::::::::::::::::::::::::::
    MSG1 db ":::::::::::::MENU::::::::::::$",0
    MSG2 db "1. Rectangulos$",0
    MSG3 db "2. Circulos$",0
    MSG4 db "3. Lineas$",0
    MSG5 db "4. Salir$",0
    MSG6 db "Pulse alguna tecla del 1 al 4 de su teclado$",0
    MEN DB 'Hola ........$'
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;::::::::::::::::::::::DATA PARA LOS RECTANGULOS:::::::::::::::::::::::::::::::
    Y DW 0
    X DW 0
    COLOR DB 0
    BASE DW 40
    ALTURA DW 30
    VALUE DW 0
    REPETICIONES DB 0
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;:::::::::::::::::::::::DATA PARA LOS CIRCULOS:::::::::::::::::::::::::::::::::
    center_x DW 80     ; Centro X (se actualizar??)
    center_y DW 50     ; Centro Y (se actualizar??)
    radius DW 10       ; Radio del c??rculo
    color DB 0Ch       ; Color base 
    seed DW 0          ; Semilla para aleatorios
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;:::::::::::::::::::::::DATA PARA LAS LINEAS:::::::::::::::::::::::::::::::::::
    Xx      DW 0
    Yy      DW 0
    x0     DW 0
    y0     DW 0
    x1     DW 0
    y1     DW 0
    col  DB 0Ch
    sed   DW 0
    direccion DB 0  
    len    DW 0

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
;:::::::::::::::::SUBRUTINAS QUE SE OCUPARON PARA REALIZAR EL CODIGO:::::::::::::::
;----------------------------------------------------------------------------------
MENU PROC 
;IMPRESION DEL MENU COMPLETO
    CALL GRAPH
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
    MOV AH,00H
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
;*********************************************************************************
TECLAS PROC  

RASTREA:
    INT 16H
    CMP AL, '1'
    JE OPCION1
    CMP AL,'2'
    JE OPCION2
    CMP AL, '3'
    JE OPCION3
    CMP AL, '4'
    JE OPCION4            ;EN DADO CASO QUE NO SEA ALGUNA DE LAS TRES TECLAS QUE LANCE DE NUEVO AL MENU  
    CALL MENU
    RET 
OPCION1: 
    CALL RECTANGULOS_ALEATORIOS
    JMP EXIT            
;*********************************************************************************
OPCION2:
    CALL CIRCULO
    JMP EXIT 
;**********************************************************************************
OPCION3:
    CALL LINEA
    JMP EXIT            
;**********************************************************************************
OPCION4:
    CALL SALIDA         ;LLAMA AL SERVICIO DE SALIDA PARA DOSBOX 
    
EXIT:
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
;***********************************************************************************
;**Creacion de una subrutina para poner la parte que genera rectangulos aleatorios**
;***********************************************************************************
RECTANGULOS_ALEATORIOS PROC
PUSH AX CX DX
    CALL GRAPH
    CALL RECTANGULO
POP DX CX AX
RET
RECTANGULOS_ALEATORIOS ENDP
;::::::::::::::::::::::::::::::::MODO GR?FICO:::::::::::::::::::::::::::::::::::::::
GRAPH PROC                    ;Inicia modo gr?fico
    MOV AH,00H      ;Set video mode (Func 00/int 10h)
    MOV AL,12H      ;12h = 80x30 8x16 640x480 16/256k A000 VGA, ATI, VIP
    INT 10H         ;Interrupt 10h Video functions
RET
GRAPH   ENDP
;::::::::::::::::::::::::::::::::SEMILLA Y VALORES ALEATORIOS:::::::::::::::::::::::::::::::::::::::
SEMILLA PROC
    PUSH AX
    MOV AH,2CH
    INT 21H  
    POP AX
    RET
SEMILLA ENDP

ALEATORIO PROC
    MOV AX,DX 
    MOV DX,0  ;CARGANDO CERO EN LA POSICION MAS SIGNIFICATIVA DEL               MULTIPLICANDO
    MOV BX,2053 ; MULTIPLICADOR
    MUL BX
    MOV BX,13849 ;CARGA EN BX LA CONSTANTE ADITIVA
    CLC
    ADD AX,BX ; SUMA PARTES MENOS SIGNIFICATIVAS DEL RESULTADO
    ADC DX,0 ; SUMA EL ACARREO SI ES NECESARIO
    MOV BX,0FFFFH ; CARGAR LA CONSTANTE 2**16-1
    DIV BX
    MOV AX,DX ; MUEVE EL RESIDUO  AX
    RET
ALEATORIO ENDP

ESCALANDO PROC
    MOV DX,0
    MOV BX, VALUE 
    DIV BX 
    RET
ESCALANDO ENDP

BASEALTURA PROC
PUSH DX
ABASE:
    CALL SEMILLA
    CALL ALEATORIO
    MOV VALUE, 64
    CALL ESCALANDO
    ADD DX,10
    MOV BASE,DX
AALTURA:
    CALL SEMILLA
    CALL ALEATORIO
    MOV VALUE, 48
    CALL ESCALANDO
    ADD DX, 10
    MOV ALTURA,DX
POP DX
RET
BASEALTURA ENDP

ALCOLOR PROC
PUSH DX
    CALL SEMILLA
    CALL ALEATORIO
    MOV VALUE, 15
    MOV COLOR, DL
POP DX    
RET
ALCOLOR ENDP

POSICION PROC
PUSH DX
YP: 
    CALL SEMILLA
    CALL ALEATORIO
    MOV VALUE, 640
    CALL ESCALANDO
    MOV Y,DX
XP:
    CALL SEMILLA
    CALL ALEATORIO
    MOV VALUE, 480
    CALL ESCALANDO
    MOV X,DX
POP DX
RET 
POSICION ENDP
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;::::::::::::::::::PROCESO DE DIBBUJADO DE LOS RECTANGULOS:::::::::::::::::::::::::::::::::::::
PUNTO PROC  
PUSH CX         ;Dibuja un punto en la pantalla (En modo gr?fico)
    MOV AH,0CH              ;Func 0C/Int 10h
    MOV AL,COLOR    ;color 0-15
    MOV BH,0                ;pagina (0 por default en esta aplicaci?n)
    MOV CX,Y                ;Columna
    MOV DX,X                ;Fila
    INT 10H         ;Interrupt 10h Video functions
POP CX
RET
PUNTO  ENDP
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::    
RECTANGULO PROC 
IMPRESION:
;    DATOS ALEATORIOS 
    CALL POSICION
    CALL BASEALTURA
    CALL ALCOLOR
;    GENERAMOS EL RECTANGULO
    CALL RRIG
    CALL RDOWN
    CALL RLEFT
    CALL RUP
    MOV AH, 00H
    JMP TECLA
TECLA: 
   INT 16H
   CMP AL, '1'
   JNE IMPRESION  
SALIDAR:   
 RET
RECTANGULO ENDP
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
RUP PROC
PUSH CX
    MOV CX, ALTURA
UP:
    CALL PUNTO
    DEC X
    LOOP UP
POP CX
RET
RUP ENDP
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
RDOWN PROC
PUSH CX
    MOV CX, ALTURA
DOWN:
    CALL PUNTO
    INC X
    LOOP DOWN
POP CX
RET
RDOWN ENDP
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
RRIG PROC
PUSH CX
    MOV CX, BASE
RIGHT:
    CALL PUNTO
    INC Y
    LOOP RIGHT
POP CX
RET
RRIG ENDP
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
RLEFT PROC
PUSH CX
    MOV CX, BASE
LEFT:
    CALL PUNTO
    DEC Y 
    LOOP LEFT 
POP CX
RET
RLEFT ENDP
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;::::::::::::::::::::::::::::::::::PROTOCOLOS PARA CIRCULOS:::::::::::::::::::::::::::::::::::::::::
GRAPH13 PROC
PUSH AX
    MOV AX, 0013h
    INT 10h
POP AX 
RET
GRAPH13 ENDP
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;:::::::::::::::::::::::::::::::::::ALEATORIEDAD PARA EL CIRCULO::::::::::::::::::::::::::::::::::::
generar_radio_aleatorio PROC
    CALL generar_aleatorio
    AND AL, 0Fh
    ADD AL, 5
    XOR AH, AH        ; Limpiar parte alta (AH = 0)
    MOV [radius], AX  ; AX ahora tiene el valor 16-bit
    RET
generar_radio_aleatorio ENDP
;--------------------------------------------------------------------------------------------------
; Genera posici??n aleatoria dentro de m??rgenes seguros
generar_posicion_aleatoria PROC
    ; Margen = radio + 5 (15) para evitar bordes
    MOV BX, [radius]
    ADD BX, 5

    ; Generar X (entre margen y 319 - margen)
    CALL generar_aleatorio
    XOR AH, AH          ; AX = 0-255
    MOV DX, 0
    MOV CX, 319         ; L??mite m??ximo X
    SUB CX, BX          ; 319 - margen
    SUB CX, BX          ; 319 - 2*margen
    INC CX              ; Rango total
    MOV BX, CX
    CALL calcular_rango_aleatorio
    ADD AX, BX          ; AX = margen + random
    MOV [center_x], AX

    ; Generar Y (entre margen y 199 - margen)
    CALL generar_aleatorio
    XOR AH, AH
    MOV DX, 0
    MOV CX, 199         ; L??mite m??ximo Y
    SUB CX, BX          ; 199 - margen
    SUB CX, BX          ; 199 - 2*margen
    INC CX
    MOV BX, CX
    CALL calcular_rango_aleatorio
    ADD AX, BX          ; AX = margen + random
    MOV [center_y], AX
RET
calcular_rango_aleatorio: ; AX = random, BX = rango -> Devuelve AX = random % BX
    CMP BX, 0
    JE fin_calculo
    DIV BX              ; DX = AX % BX
    MOV AX, DX
fin_calculo:
    RET
generar_posicion_aleatoria ENDP

;-------------------------------------------------------------------------------------
; Genera una semilla basada en el tiempo del sistema
generar_semilla PROC
    PUSH AX
    PUSH CX
    PUSH DX
    MOV AH, 2Ch
    INT 21h       ; CH = hora, CL = min, DH = seg, DL = 1/100 seg
    MOV [seed], DX ; Usar segundos y cent??simas como semilla
    POP DX
    POP CX
    POP AX
    RET
generar_semilla ENDP

; Genera n??mero aleatorio entre 0-255 en AL
generar_aleatorio PROC
    MOV AX, [seed]
    MOV DX, 8405h ; Multiplicador para LCG
    MUL DX
    INC AX
    MOV [seed], AX ; Actualizar semilla
    MOV AL, AH     ; Usar parte alta para mayor aleatoriedad
    RET
generar_aleatorio ENDP

; Establece color aleatorio (0-15 para colores b??sicos)
generar_color_aleatorio PROC
    PUSH AX
    CALL generar_semilla
    CALL generar_aleatorio
    AND AL, 0Fh   ; M??scara para 16 colores b??sicos (0-15)
    MOV [color], AL
    POP AX
    RET
generar_color_aleatorio ENDP
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;:::::::::::::::::::::::::::::::::::DIBUJAR EL CIRCULO::::::::::::::::::::::::::::::::::::::::::::::
; Procedimiento para dibujar p??xel
put_pixel PROC
    PUSH BX
    MOV AH, 0Ch
    MOV BH, 0
    INT 10h
    POP BX
    RET
put_pixel ENDP

; Algoritmo de c??rculo de Bresenham optimizado
draw_circle PROC
    XOR SI, SI          ; x = 0
    MOV DI, [radius]    ; y = radio
    MOV BX, 3          ; d = 3 - 2*r
    SUB BX, DI
    SUB BX, DI

circle_loop:
    ; Dibujar 8 puntos sim??tricos
    CALL draw_octants

    ; Actualizar par??metro de decisi??n
    CMP BX, 0
    JGE d_positive
    
    ; Caso d < 0 (E)
    MOV AX, SI
    SHL AX, 2      ; Multiplicar por 4 (equivalente a SI*4)
    ADD AX, 6      ; Sumar 6 (total = 4*SI + 6)
    ADD BX, AX
    JMP next_step

d_positive:
    ; Caso d >= 0 (SE)
    DEC DI             ; y--
    MOV AX, SI
    SUB AX, DI         ; x - y
    SHL AX, 2          ; 4*(x - y)
    ADD AX, 10         ; 4*(x - y) + 10
    ADD BX, AX

next_step:
    INC SI             ; x++
    CMP SI, DI
    JLE circle_loop
    RET
draw_circle ENDP

; Dibujar los 8 octantes
draw_octants PROC
    ; Punto (x + cx, y + cy)
    MOV CX, [center_x]
    ADD CX, SI
    MOV DX, [center_y]
    ADD DX, DI
    MOV AL, [color]
    CALL put_pixel

    ; Punto (y + cx, x + cy)
    MOV CX, [center_x]
    ADD CX, DI
    MOV DX, [center_y]
    ADD DX, SI
    CALL put_pixel

    ; Punto (-x + cx, y + cy)
    MOV CX, [center_x]
    SUB CX, SI
    MOV DX, [center_y]
    ADD DX, DI
    CALL put_pixel

    ; Punto (-y + cx, x + cy)
    MOV CX, [center_x]
    SUB CX, DI
    MOV DX, [center_y]
    ADD DX, SI
    CALL put_pixel

    ; Punto (x + cx, -y + cy)
    MOV CX, [center_x]
    ADD CX, SI
    MOV DX, [center_y]
    SUB DX, DI
    CALL put_pixel

    ; Punto (y + cx, -x + cy)
    MOV CX, [center_x]
    ADD CX, DI
    MOV DX, [center_y]
    SUB DX, SI
    CALL put_pixel

    ; Punto (-x + cx, -y + cy)
    MOV CX, [center_x]
    SUB CX, SI
    MOV DX, [center_y]
    SUB DX, DI
    CALL put_pixel

    ; Punto (-y + cx, -x + cy)
    MOV CX, [center_x]
    SUB CX, DI
    MOV DX, [center_y]
    SUB DX, SI
    CALL put_pixel

    RET
draw_octants ENDP

CIRCULO PROC
    CALL GRAPH13
RCIRCULO:
    CALL generar_semilla
    CALL generar_radio_aleatorio
    CALL generar_posicion_aleatoria
    CALL generar_color_aleatorio
    CALL draw_circle
    MOV AH, 00H
    JMP TECLAC
TECLAC: 
   INT 16H
   CMP AL, '2'
   JNE RCIRCULO
SALIDAC:
RET
CIRCULO ENDP
;:::::::::::::::::::::::::::SUBRUTINAS PARA LA GENERACION DE LINEAS::::::::::::::::::
; ================== PROCEDIMIENTOS ALEATORIOS ==================
generar_semillaL PROC
    PUSH AX
    PUSH CX
    PUSH DX
    MOV AH, 2Ch
    INT 21h             ; CH=hora, CL=min, DH=seg, DL=1/100s
    MOV [sed], DX      ; Usar segundos y centésimas como semilla
    POP DX
    POP CX
    POP AX
    RET
generar_semillaL ENDP

; Generar número aleatorio entre 0-65535 en AX
generar_aleatorioL PROC
    MOV AX, [sed]
    MOV DX, 8405h       ; Multiplicador para LCG
    MUL DX
    INC AX
    MOV [sed], AX      ; Actualizar semilla
    RET
generar_aleatorioL ENDP

; Generar color aleatorio (1-15)
generar_color_aleatorioL PROC
    CALL generar_aleatorio
    AND AL, 0Fh         ; 16 colores básicos
    CMP AL, 0
    JNE color_valido
    MOV AL, 1           ; Evitar negro
color_valido:
    MOV [col], AL
    RET
generar_color_aleatorioL ENDP

;-----------------------------------------------------
; Generar coordenadas y dirección aleatorias
generar_linea_aleatoriaL PROC
    ; Generar punto inicial (x0, y0)
    CALL generar_aleatorioL
    XOR DX, DX
    MOV BX, 320
    DIV BX              ; DX = residuo (0-319)
    MOV [x0], DX
    
    CALL generar_aleatorioL
    XOR DX, DX
    MOV BX, 200
    DIV BX              ; DX = residuo (0-199)
    MOV [y0], DX
    
    ; Generar dirección (0-3)
    CALL generar_aleatorioL
    AND AL, 03h
    MOV [direccion], AL
    
    ; Generar longitud (10-100)
    CALL generar_aleatorioL
    AND AX, 007Fh
    ADD AX, 10
    MOV [len], AX
    
    ; Calcular punto final (x1, y1)
    MOV AX, [x0]
    MOV BX, [y0]
    MOV CX, [len]
    
    CMP [direccion], 0
    JE vertical
    CMP [direccion], 1
    JE horizontal
    CMP [direccion], 2
    JE diagonal_sup
    JMP diagonal_inf

vertical:
    ADD BX, CX
    CMP BX, 199
    JLE fin_calc
    MOV BX, 199
    JMP fin_calc

horizontal:
    ADD AX, CX
    CMP AX, 319
    JLE fin_calc
    MOV AX, 319
    JMP fin_calc

diagonal_sup:
    ADD AX, CX
    ADD BX, CX
    CMP AX, 319
    JLE check_y1
    MOV AX, 319
check_y1:
    CMP BX, 199
    JLE fin_calc
    MOV BX, 199
    JMP fin_calc

diagonal_inf:
    ADD AX, CX
    SUB BX, CX
    CMP AX, 319
    JLE check_y2
    MOV AX, 319
check_y2:
    CMP BX, 0
    JGE fin_calc
    MOV BX, 0

fin_calc:
    MOV [x1], AX
    MOV [y1], BX
    CALL generar_color_aleatorioL
    RET
generar_linea_aleatoriaL ENDP
;:::::::::::::::::::::::::::::::::::DIBUJADO DE LINEAS::::::::::::::::::::::::::::::::::::::::
put_pixelL PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    MOV AH, 0Ch
    MOV AL, [col]
    MOV BH, 0
    MOV CX, [Xx]
    MOV DX, [Yy]
    INT 10h
    POP DX
    POP CX
    POP BX
    POP AX
    RET
    put_pixelL ENDP

;-----------------------------------------------------
; Dibujar línea según dirección
dibujar_linea PROC
    MOV AX, [x0]
    MOV [Xx], AX
    MOV AX, [y0]
    MOV [Yy], AX
    
    MOV CX, [len]
    CMP [direccion], 0
    JE dibujar_vertical
    CMP [direccion], 1
    JE dibujar_horizontal
    CMP [direccion], 2
    JE dibujar_diagonal_sup
    JMP dibujar_diagonal_inf

dibujar_vertical:
    CALL put_pixelL
    INC [Yy]
    LOOP dibujar_vertical
    JMP fin_dibujo

dibujar_horizontal:
    CALL put_pixelL
    INC [Xx]
    LOOP dibujar_horizontal
    JMP fin_dibujo

dibujar_diagonal_sup:
    CALL put_pixelL
    INC [Xx]
    INC [Yy]
    LOOP dibujar_diagonal_sup
    JMP fin_dibujo

dibujar_diagonal_inf:
    CALL put_pixelL
    INC [Xx]
    DEC [Yy]
    LOOP dibujar_diagonal_inf

fin_dibujo:
    RET
dibujar_linea ENDP

LINEA PROC
    CALL GRAPH13
    CALL generar_semillaL 
LINEASRE:
    CALL generar_linea_aleatoriaL
    CALL dibujar_linea
    MOV AH, 00H
    JMP TECLAL
TECLAL: 
   INT 16H
   CMP AL, '3'
   JNE LINEASRE
SALIDAL:
RET

LINEA ENDP 
END PRINCI
