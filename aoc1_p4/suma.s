	 	AREA datos,DATA,READWRITE 	 ; area de datos
N	 	EQU 11
T	 	DCD 1,4,8,6,9,-7,3,5,2,0,6
stotal  DCD 0
	 	
		AREA codigo,CODE,READONLY	 ; area de codigo
	 	ENTRY

		LDR r0,=T		; r0 = @T
		mov r1,#N		; r1 = N		

		sub sp,sp,#4	; espacio resultados
		PUSH {r0,r1}	; Apilo los parámetros para la subrutina

		bl suma			; llamo a la subrutina

		add sp,sp,#8	; libero los parámetros
		POP{r1}			; recupero el resultado de la subrutina suma en r1
		
		LDR r0,=stotal	; r0=@stotal
		str r1,[r0]		; Mem[@stotal] = r1 = resultado

fin  	b fin


suma 	;Inicio de la subrutina que suma los elementos de una tabla T de N numeros enteros de 32 bits
	 	;Guarda en la pila dos parámetros y un resultado:
	 	;Parámetros--> 1. Dirección de comienzo de la tabla (por referencia)
	 	;    		   2. Número de elementos de la tabla (por valor)
	 	;La subrutina devuelve como resultado la suma de los elementos de la tabla.

		PUSH {lr}		;apilo @retorno
		PUSH {r11}		;apilo r11
		mov fp,sp		;creo fp

		PUSH {r0-r3}	;apilo registros utilizados	durante la SBR
		mov r0,#0		;r0=0
		ldr r2,[fp,#8]	;r2=N
		ldr r1,[fp,#12] ;r1=@T
		
buc		ldr r3,[r2],#4	; r3=Mem[r2], r2=r2+4
		add r0,r0,r3
		sub r1,r1,#1
		cmp r1,#0
		bne buc

		str r0,[fp,#16]	;guardo el resultado en su hueco reservado en la pila
		POP {r0-r3}		;recupero los datos originales de los registros del PP
		POP {r11}		;destruyo fp
		POP {pc}		;retorno
