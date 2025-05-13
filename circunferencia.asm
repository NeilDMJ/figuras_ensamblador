.MODEL small
.STACK 100h

.DATA
    center_x DW 80     ; Centro X 
    center_y DW 50     ; Centro Y 
    radius DW 10       ; Radio del círculo
    color DB 0Ch       ; Color base 
    seed DW 0          ; Semilla para aleatorios

.CODE
start:
    MOV AX, @data
    MOV DS, AX

    ; Establecer modo gráfico 13h
    MOV AX, 0013h
    INT 10h
    MOV CX,10
REPETIR:
    ; Generar posición y color aleatorios
    CALL generar_semilla
    CALL generar_radio_aleatorio
    CALL generar_posicion_aleatoria
    CALL generar_color_aleatorio

    ; Dibujar círculo
    
    CALL draw_circle
    LOOP REPETIR

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
generar_radio_aleatorio PROC
    CALL generar_aleatorio
    AND AL, 0Fh
    ADD AL, 5
    XOR AH, AH        ; Limpiar parte alta (AH = 0)
    MOV [radius], AX  ; AX ahora tiene el valor 16-bit
    RET
generar_radio_aleatorio ENDP
;--------------------------------------------------------------------
; Genera posición aleatoria dentro de márgenes seguros
generar_posicion_aleatoria PROC
    ; Margen = radio + 5 (15) para evitar bordes
    MOV BX, [radius]
    ADD BX, 5

    ; Generar X (entre margen y 319 - margen)
    CALL generar_aleatorio
    XOR AH, AH          ; AX = 0-255
    MOV DX, 0
    MOV CX, 319         ; Límite máximo X
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
    MOV CX, 199         ; Límite máximo Y
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

; Algoritmo de círculo
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
    SHL AX, 2      ; Multiplicar
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