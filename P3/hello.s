@
@ Sistemas Empotrados
@ El "hola mundo" en la Redwire EconoTAG
@

@
@ Variables globales
@

.data

        @ El led rojo está en el GPIO 44 (el bit 12 de los registros GPIO_X_1)
        LED_RED_MASK:   .word     (1 << (44-32))

        @ El led verde está en el GPIO 45 (el bit 13 de los registros GPIO_X_1)
        LED_GREEN_MASK: .word   (1 << (45-32))

        @ Retardo para el parpadeo
        DELAY:          .word   0x00200000

        PIN_BUTTON_1:   .word   0x08000000
        PIN_BUTTON_2:   .word   0x04000000

        PIN_BUTTONS:    .word   0x00C00000

@
@ Punto de entrada
@

        .code 32
        .text
        .global _start
        .type   _start, %function

_start:
        bl gpio_init

loop:

	bl test_buttons

        @ Pausa corta
        ldr     r0, =DELAY
	ldr	r0, [r0]
        bl pause

	str	r5, [r6]

        @ Pausa corta
        ldr     r0, =DELAY
	ldr	r0, [r0]
        bl pause

        @ Apagamos el led
	str	r5, [r7]

        @ Bucle infinito
        b loop
        
@
@ Función que produce un retardo
@ r0: iteraciones del retardo
@
        .type   pause, %function
pause:
        subs    r0, r0, #1
        bne pause
        mov     pc, lr

        .type test_buttons, %function
test_buttons:
        
        ldr     r1, =gpio_data0
	ldr     r1, [r1]        

	ldr     r9, =PIN_BUTTON_1
	ldr     r9, [r9]
        tst     r1, r9
        bne led_green_on

	ldr     r9, =PIN_BUTTON_2
	ldr     r9, [r9]
        tst     r1, r9
        bne led_red_on

	mov     pc, lr

        .type led_red, %function
led_red_on:

	ldr	r4, =LED_GREEN_MASK
	ldr	r4, [r4]
	ldr	r5, =LED_RED_MASK
	ldr	r5, [r5]
	str	r5, [r7]
        mov     pc, lr

        .type led_green, %function
led_green_on:

	ldr	r5, =LED_GREEN_MASK
	ldr	r5, [r5]
	ldr	r4, =LED_RED_MASK
	ldr	r4, [r4]
	str	r4, [r7]
        mov     pc, lr

        .type gpio_init, %function
gpio_init:

        ldr     r8, =gpio_dir_set1
	//ldr	r8, =GPIO_PAD_DIR1
	//ldr	r8, [r8]

        @ Configuramos el GPIO45 para que sea de salida
        ldr     r4, =LED_GREEN_MASK
	ldr	r4, [r4]
        str     r4, [r8]

        @ Configuramos el GPIO44 para que sea de salida
        ldr     r5, =LED_RED_MASK
	ldr	r5, [r5]
        str     r5, [r8]      

        @ Direcciones de los registros GPIO_DATA_SET1 y GPIO_DATA_RESET1
        ldr     r6, =gpio_data_set1
	//ldr	r6, [r6]
        ldr     r7, =gpio_data_reset1
	//ldr	r7, [r7]      
        
        ldr     r2, =gpio_data_set0
	//ldr	r2, [r2]
        ldr     r3, =PIN_BUTTONS
	ldr	r3, [r3]
        str     r3, [r2]

	str	r5, [r6]

        mov     pc, lr
