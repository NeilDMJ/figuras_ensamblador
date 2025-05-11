.MODEL small
.STACK 100h

.DATA
    x0      DW 20
    y0      DW 20
    x1      DW 120
    y1      DW 120
    color   DB 0Ch       ; Color inicial
    seed    DW 0         ; Semilla para números aleatorios
    dx_abs DW 0     ; Delta X absoluto
    dy_abs DW 0

.CODE
start:
    MOV AX, @data
    MOV DS, AX

    ; Establecer modo gráfico 13h
    MOV AX, 0013h
    INT 10h

    ; Inicializar generador aleatorio
    CALL inicializar_semilla

    ; Generar y dibujar 50 líneas aleatorias
    MOV CX, 12
bucle_lineas:
    PUSH CX
    CALL generar_linea_aleatoria
    CALL draw_line
    POP CX
    LOOP bucle_lineas

    ; Esperar una tecla
    MOV AH, 00h
    INT 16h

    ; Volver al modo de texto
    MOV AX, 0003h
    INT 10h

    ; Terminar el programa
    MOV AX, 4C00h
    INT 21h

; ================== PROCEDIMIENTOS ALEATORIOS ==================
inicializar_semilla PROC
    PUSH AX CX DX
    MOV AH, 2Ch       ; Obtener tiempo del sistema
    INT 21h           ; DH = segundos, DL = centésimas
    MOV [seed], DX    ; Usar como semilla inicial
    POP DX CX AX
    RET
inicializar_semilla ENDP

generar_aleatorio PROC
    MOV AX, [seed]
    MOV DX, 8405h     ; Multiplicador
    MUL DX
    ADD AX, 1         ; Incremento
    MOV [seed], AX     ; Actualizar semilla
    RET
generar_aleatorio ENDP

generar_coordenada PROC   ; Devuelve en AX (0-319)
    CALL generar_aleatorio
    XOR DX, DX
    MOV BX, 320       ; Rango máximo X
    DIV BX
    MOV AX, DX        ; Usar residuo
    RET
generar_coordenada ENDP

generar_color PROC
    CALL generar_aleatorio
    AND AL, 0Fh       ; Limitar a 16 colores básicos
    CMP AL, 0
    JNE color_ok
    MOV AL, 1         ; Evitar color negro (0)
color_ok:
    RET
generar_color ENDP

generar_linea_aleatoria PROC
    ; Generar coordenadas
    CALL generar_coordenada
    MOV [x0], AX
    CALL generar_coordenada
    MOV [y0], AX
    CALL generar_coordenada
    MOV [x1], AX
    CALL generar_coordenada
    MOV [y1], AX
    
    ; Generar color
    CALL generar_color
    MOV [color], AL
    RET
generar_linea_aleatoria ENDP

; ================== PROCEDIMIENTOS GRÁFICOS ==================
put_pixel PROC
    MOV AH, 0Ch
    MOV BH, 0
    INT 10h
    RET
put_pixel ENDP

draw_line PROC
    ; Calcular delta X y delta Y absolutos
    MOV AX, x1
    SUB AX, x0
    JNS dx_pos
    NEG AX
dx_pos:
    MOV dx_abs, AX   ; Guardar |x1 - x0|

    MOV AX, y1
    SUB AX, y0
    JNS dy_pos
    NEG AX
dy_pos:
    MOV dy_abs, AX   ; Guardar |y1 - y0|

    ; Determinar dirección de incremento para X (CORREGIDO)
    MOV BX, 1
    MOV AX, x1       ; Cargar x1 en registro
    CMP AX, x0       ; Ahora es registro vs memoria
    JG set_sy
    MOV BX, -1

set_sy:
    ; Determinar dirección de incremento para Y (CORREGIDO)
    MOV BP, 1
    MOV AX, y1       ; Cargar y1 en registro
    CMP AX, y0       ; Ahora es registro vs memoria
    JG check_slope
    MOV BP, -1

check_slope:
    ; Comparar dx y dy para determinar pendiente
    MOV AX, dx_abs
    CMP AX, dy_abs
    JGE x_major

y_major:
    ; Línea con pendiente pronunciada (dy > dx)
    MOV AX, dx_abs
    SHL AX, 1        ; 2*dx_abs
    SUB AX, dy_abs    ; error = 2*dx - dy
    MOV SI, AX        ; SI = error

    MOV CX, x0
    MOV DX, y0

y_loop:
    MOV AL, color
    CALL put_pixel

    CMP DX, y1       ; Verificar si llegó al final
    JE end_draw

    CMP SI, 0        ; Chequear error
    JL y_skip_x

    ADD CX, BX       ; Ajustar X
    SUB SI, dy_abs   ; error -= dy
    SUB SI, dy_abs

y_skip_x:
    ADD SI, dx_abs   ; error += dx
    ADD SI, dx_abs
    ADD DX, BP       ; Incrementar Y
    JMP y_loop

x_major:
    ; Línea con pendiente suave (dx >= dy)
    MOV AX, dy_abs
    SHL AX, 1        ; 2*dy_abs
    SUB AX, dx_abs    ; error = 2*dy - dx
    MOV SI, AX        ; SI = error

    MOV CX, x0
    MOV DX, y0

x_loop:
    MOV AL, color
    CALL put_pixel

    CMP CX, x1       ; Verificar si llegó al final
    JE end_draw

    CMP SI, 0        ; Chequear error
    JL x_skip_y

    ADD DX, BP       ; Ajustar Y
    SUB SI, dx_abs   ; error -= dx
    SUB SI, dx_abs

x_skip_y:
    ADD SI, dy_abs   ; error += dy
    ADD SI, dy_abs
    ADD CX, BX       ; Incrementar X
    JMP x_loop

end_draw:
    RET
draw_line ENDP

END start