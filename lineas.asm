MODEL small
.STACK 100h

.DATA
    X      DW 0
    Y      DW 0
    x0     DW 0
    y0     DW 0
    x1     DW 0
    y1     DW 0
    color  DB 0Ch
    seed   DW 0
    direccion DB 0  
    len    DW 0

.CODE
start:
    MOV AX, @data
    MOV DS, AX
    MOV AX, 0013h       ; Modo grafico 320x200
    INT 10h
    
    CALL generar_semilla ; Inicializar semilla
    
    MOV CX, 50          ; Dibujar 50 lineas
bucle_lineas:
    CALL generar_linea_aleatoria
    CALL dibujar_linea
    LOOP bucle_lineas
    
    MOV AH, 00h         ; Esperar tecla
    INT 16h
    
    MOV AX, 0003h       ; Volver a modo texto
    INT 10h
    
    MOV AX, 4C00h       ; Salir
    INT 21h

;-----------------------------------------------------
; Generar semilla inicial desde el reloj del sistema
generar_semilla PROC
    PUSH AX
    PUSH CX
    PUSH DX
    MOV AH, 2Ch
    INT 21h             ; CH=hora, CL=min, DH=seg, DL=1/100s
    MOV [seed], DX      ; Usar segundos y centesimas como semilla
    POP DX
    POP CX
    POP AX
    RET
generar_semilla ENDP

; Generar numero aleatorio entre 0-65535 en AX
generar_aleatorio PROC
    MOV AX, [seed]
    MOV DX, 8405h       
    MUL DX
    INC AX
    MOV [seed], AX      ; Actualizar semilla
    RET
generar_aleatorio ENDP

; Generar color aleatorio (1-15)
generar_color_aleatorio PROC
    CALL generar_aleatorio
    AND AL, 0Fh         ; 16 colores b??sicos
    CMP AL, 0
    JNE color_valido
    MOV AL, 1           ; Evitar negro
color_valido:
    MOV [color], AL
    RET
generar_color_aleatorio ENDP

;-----------------------------------------------------
; Generar coordenadas y direccion aleatorias
generar_linea_aleatoria PROC
    ; Generar punto inicial (x0, y0)
    CALL generar_aleatorio
    XOR DX, DX
    MOV BX, 320
    DIV BX              ; DX = residuo (0-319)
    MOV [x0], DX
    
    CALL generar_aleatorio
    XOR DX, DX
    MOV BX, 200
    DIV BX              ; DX = residuo (0-199)
    MOV [y0], DX
    
    ; Generar direccion (0-3)
    CALL generar_aleatorio
    AND AL, 03h
    MOV [direccion], AL
    
    ; Generar longitud (10-100)
    CALL generar_aleatorio
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
    CALL generar_color_aleatorio
    RET
generar_linea_aleatoria ENDP

;-----------------------------------------------------
; Dibujar pixel en (X,Y)
put_pixel PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    MOV AH, 0Ch
    MOV AL, [color]
    MOV BH, 0
    MOV CX, [X]
    MOV DX, [Y]
    INT 10h
    POP DX
    POP CX
    POP BX
    POP AX
    RET
put_pixel ENDP

;-----------------------------------------------------
; Dibujar linea segun direccion
dibujar_linea PROC
    MOV AX, [x0]
    MOV [X], AX
    MOV AX, [y0]
    MOV [Y], AX
    
    MOV CX, [len]
    CMP [direccion], 0
    JE dibujar_vertical
    CMP [direccion], 1
    JE dibujar_horizontal
    CMP [direccion], 2
    JE dibujar_diagonal_sup
    JMP dibujar_diagonal_inf

dibujar_vertical:
    CALL put_pixel
    INC [Y]
    LOOP dibujar_vertical
    JMP fin_dibujo

dibujar_horizontal:
    CALL put_pixel
    INC [X]
    LOOP dibujar_horizontal
    JMP fin_dibujo

dibujar_diagonal_sup:
    CALL put_pixel
    INC [X]
    INC [Y]
    LOOP dibujar_diagonal_sup
    JMP fin_dibujo

dibujar_diagonal_inf:
    CALL put_pixel
    INC [X]
    DEC [Y]
    LOOP dibujar_diagonal_inf

fin_dibujo:
    RET
dibujar_linea ENDP

END start