.MODEL small
.STACK 100h

.DATA
    center_x DW 80     ; Centro X
    center_y DW 50     ; Centro Y
    radius DW 10       ; Radio del círculo
    color DB 0Ch       ; Color base (será sobrescrito)
    seed DW 0          ; Semilla para números aleatorios

.CODE
start:
    MOV AX, @data
    MOV DS, AX

    ; Establecer modo gráfico 13h
    MOV AX, 0013h
    INT 10h

    ; Generar color aleatorio y dibujar círculo
    CALL generar_color_aleatorio
    CALL draw_circle

    ; Esperar tecla
    MOV AH, 00h
    INT 16h

    ; Volver a modo texto
    MOV AX, 0003h
    INT 10h

    ; Salir
    MOV AX, 4C00h
    INT 21h

;--------------------------------------------------------------------
; Genera una semilla basada en el tiempo del sistema
generar_semilla PROC
    PUSH AX
    PUSH CX
    PUSH DX
    MOV AH, 2Ch
    INT 21h       ; CH = hora, CL = min, DH = seg, DL = 1/100 seg
    MOV [seed], DX ; Usar segundos y centésimas como semilla
    POP DX
    POP CX
    POP AX
    RET
generar_semilla ENDP

; Genera número aleatorio entre 0-255 en AL
generar_aleatorio PROC
    MOV AX, [seed]
    MOV DX, 8405h ; Multiplicador para LCG
    MUL DX
    INC AX
    MOV [seed], AX ; Actualizar semilla
    MOV AL, AH     ; Usar parte alta para mayor aleatoriedad
    RET
generar_aleatorio ENDP

; Establece color aleatorio (0-15 para colores básicos)
generar_color_aleatorio PROC
    PUSH AX
    CALL generar_semilla
    CALL generar_aleatorio
    AND AL, 0Fh   ; Máscara para 16 colores básicos (0-15)
    MOV [color], AL
    POP AX
    RET
generar_color_aleatorio ENDP

;--------------------------------------------------------------------
; Procedimiento para dibujar píxel
put_pixel PROC
    PUSH BX
    MOV AH, 0Ch
    MOV BH, 0
    INT 10h
    POP BX
    RET
put_pixel ENDP

; Algoritmo de círculo de Bresenham optimizado
draw_circle PROC
    XOR SI, SI          ; x = 0
    MOV DI, [radius]    ; y = radio
    MOV BX, 3          ; d = 3 - 2*r
    SUB BX, DI
    SUB BX, DI

circle_loop:
    ; Dibujar 8 puntos simétricos
    CALL draw_octants

    ; Actualizar parámetro de decisión
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


END start