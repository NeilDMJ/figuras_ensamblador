.MODEL small
.STACK 100h

.DATA
    center_x DW 160   ; Centro X
    center_y DW 100   ; Centro Y
    radius DW 2      ; Radio del círculo
    color DB 0Ch      ; Color rojo

.CODE
start:
    MOV AX, @data
    MOV DS, AX

    ; Establecer modo gráfico 13h
    MOV AX, 0013h
    INT 10h

    ; Dibujar círculo
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
    SHL AX, 2      
    ADD AX, 6      
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