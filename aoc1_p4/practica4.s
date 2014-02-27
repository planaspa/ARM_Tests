	 	AREA datos,DATA,READWRITE 	 ; area de datos
N	 	EQU 11
T	 	DCD 1,4,8,6,9,-7,3,5,2,0,6
stotal  DCD 0
	 	
		AREA codigo,CODE,READONLY	 ; area de codigo
	 	ENTRY

		LDR r0,=T		; r0 = @T
		mov r1,#N		; r1 = N		

	;	sub sp,sp,#4	; espacio resultados
	;	PUSH {r0,r1}	; Apilo los parámetros para la subrutina

	;	bl suma			; llamo a la subrutina

	;	add sp,sp,#8	; libero los parámetros
	;	POP{r1}			; recupero el resultado de la subrutina suma en r1
		
	;	LDR r0,=stotal	; r0=@stotal
	;	str r1,[r0]		; Mem[@stotal] = r1 = resultado

	;;  PUSH {r0,r1}	; Apilo los parámetros para la subrutina
	;;	bl ordena
	;;	add sp,sp,#8	; libero los parámetros


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


ordena ; SBR que ordena una tabla de enteros de 32 bits. Parametros:
	   ; r0 = @ de comienzo de la tabla a ordenar (tabla por referencia)
	   ; r1 = Numero de elementos de la tabla (N por valor)	 

	   PUSH {lr} 		; apilo @retorno
	   PUSH {r11}		; apilo r11
	   mov fp,sp

	   PUSH	{r0,r1}

	   ldr r0,[fp,#8]   ; r0=@T
	   ldr r1,[fp,#12]	; r2 = N 
	   sub r1,r1,#1 	; N-1
	   add r1,r0,r1,LSL#2 ;r1=@T[N-1]

	   PUSH {r0,r1}
	   bl qsort
	   add sp,sp,#8
	   
	   POP {r0,r1}

	   POP {r11}
	   POP {pc}


qsort  ; SBR que ordena una tabla de enteros de 32 bits a través del método quicksort. Parametros:
	   ; iz = limite inferior de @ de comienzo de la tabla a ordenar (tabla por referencia)
	   ; de = limite supeiror de @ de comienzo de la tabla a ordenar (tabla por referencia) 
	   
	   PUSH {lr} 		; apilo @retorno
	   PUSH {r11}		; apilo r11
	   mov fp,sp		; creo fp

	   PUSH {r0-r7}		; apilo registros utilizados durante la SBR
	   
	   ldr r0,[fp,#8]   ; r0= @T[iz]
	   ldr r2,[fp,#12]	; r2 = @T[N-1] = @T[de]
	   mov r1,r0		; r1= @T[i]
	   mov r3,r2		; r2 = @T[de] = r3 = @T[j]
	   
	   mov r7,#0
	   add r4,r2,r0			; r3 = iz+de
	   add r4,r7,r3,LSR#1	; r3 = (iz+de)/2
	   ldr r4,[r3] 			; r4 = T[(iz+de)/2] = x

buc_do
while1 ldr r5,[r1]		; r5 = T[i]
	   cmp r4,r5		; T[i]<x	
	   ble while2
	   add r1,r1,#4		; i=i+1
	   b while1

while2 ldr r5,[r3]		; r5 = T[j]
	   cmp r5,r4		; x<T[j]
	   ble if1
	   sub r3,r3,#4		; j=j-1
	   b while2

if1	   cmp r1,r3
	   bhi do_whi

	   ldr r5,[r1]		; r5 = T[i] = w
	   ldr r6,[r3]		; r6 = T[j]
	   str r6,[r1]		; T[i] = T[j]
	   str r5,[r3]  	; T[j] = w

	   add r1,r1,#4		; i=i+1
	   sub r3,r3,#4		; j=j-1

do_whi cmp r1,r3		; i<=j
	   bls buc_do

if2	   cmp r3,r0		; iz<j
	   bls if3
	   PUSH {r0,r3}		; almaceno los parámetros para la recursividad --> qsort(iz,j)
	   bl qsort
	   POP {r0,r3}

if3    cmp r2,r1		; i<de
	   bls fin_sb
	   PUSH {r1,r2}		; almaceno los parámetros para la recursividad --> qsort(i,de)
	   bl qsort
	   POP {r1,r2}

fin_sb POP {r0-r7}		;recupero los datos originales de los registros del PP
	   POP {r11}		;destruyo fp
	   POP {pc}		    ;retorno
	   
	   END	   