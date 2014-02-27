				AREA datos,DATA
VICIntEnable	EQU 0xFFFFF010		;Máscara - Activar IRQ's
VICIntEnClr		EQU 0xFFFFF014		;Máscara - Descativar IRQ's
VICSoftInt		EQU 0xFFFFF018		;Generar IRQ's Mediante Software
VICSoftIntClr	EQU 0xFFFFF01C		;Bajar peticiones IRQ's Software
VICVectAddr0	EQU 0xFFFFF100		;Vector interrupciones
VICVectAddr		EQU 0xFFFFF030		;Reg. E.O.I.
T0_IR			EQU 0xE0004000		;Reg. Control Timer 0, escribiendo 1 se baja la petición
DATA_boton		EQU 0xE001C008		;Direccion en la que se almacena el código de boton pulsado (del 1 al 7)
TEC_CTR			EQU	0xE001C018		;Bajar peticiones en el registro de control del teclado
cuerpo			SPACE 512			;reserva 512 bytes de memoria, (tamaño maximo que podria llegar a tener el gusano)
T_Saltos		DCD Boton1, Boton2, Boton3, Boton4, Boton5, Boton6, Boton7	
Posicion_INI	DCD 0x40007EEF		;posición inicial del caracter '@'
k				DCD 1				;tamaño actual del gusano (inicialmente 1)
Pantalla		DCD 0x40007E00		;Direccion de inicio de la pantalla (16 filas y 32 columnas)
reloj_so		DCD 0				;Almacena @RSI_reloj del S.O.
reloj			DCD 0				;contador de centesimas de segundo
boton_so		DCD 0				;Almacena @RSI_boton del S.O.
max				DCD 8				;velocidad de mov. caracter '@' (en centesimas s.) (inicialmente 0.08s)
dirx			DCB 0				;direccion mov. caracter  '@' (-1 izda., 0 stop, 1 der.)
diry			DCB 0				;direccion mov. caracter  '@' (-1 arriba, 0 stop, 1 abajo)
fila_actual		DCB 7				;numero de fila en la que se encuentra el caracter '@' (inicialmente 7)
columna_actual	DCB 15				;numero de columna en la que se encuentra el caracter '@' (inicialmente 15)
fin				DCB 0				;indicador fin de programa	(si vale 1)	
k_counter		DCB 0				;Cuenta el numero de movimientos hasta el proximo aumento del cuerpo (5 movimientos)
flag_start		DCB 0				;Se pone a uno al presionar el primer botón, cuando se vuelve a empezar se vuelve a poner a 0


				AREA codigo,CODE
				EXPORT inicio			; forma de enlazar con el startup.s
inicio	
				;programar @IRQ1 -> RSI_boton
				;programar @IRQ4 -> RSI_reloj
				;activar IRQ1, IRQ4

				;Guardar VI[1] en boton_so
				LDR r0,=VICVectAddr0	;r0=@VICVectAddr0
				LDR r1,=boton_so		;r1=@boton_so
				mov r2,#1				;r2 = nºIRQ de SW Interrupt = 1
				ldr r3,[r0,r2,LSL#2]	;r3=@RSI1 del S.O.
				str r3,[r1]				;boton_so = @RSI1 del S.O.

				;VI[1]=@RSI_boton (creada por mi)
				LDR r1,=RSI_boton		;Coloco en el vector de Interrupciones la RSI creada por mi
				str r1,[r0,r2,LSL#2]

				;Guardar VI[4] en reloj_so
				LDR r1,=reloj_so		;r1=@reloj_so
				mov r2,#4				;r2 = nºIRQ del timer = 4
				ldr r3,[r0,r2,LSL#2]	;r3=@RSI4 del S.O.
				str r3,[r1]				;reloj_so = @RSI4 del S.O.

				;VI[4]=@RSI_reloj (creada por mi)
				LDR r1,=RSI_reloj		;Coloco en el vector de Interrupciones la RSI creada por mi
				str r1,[r0,r2,LSL#2]

				;Habilitar máscara para IRQ1 e IRQ4
				LDR r0,=VICIntEnable
				mov r1,#2_10010
				str r1,[r0]				;Mascara[4]=1 y Mascara[1]=1, el resto se queda igual


				;Borrado de pantalla --> Clrear Screen (Clrscr)
				mov r1,#32
				LDR r2,=Pantalla
				ldr r0,[r2]
				mov r2,#16*32
				add r2,r0,r2

Clrscr			strb r1,[r0]
				add r0,r0,#1
				cmp r0,r2
				bne Clrscr
				



comienzo		;Ponemos el timer a 0 al comienzo	
				LDR r1,=reloj
				mov r0,#0
				str r0,[r1]

				;Dibujamos el caracter al comienzo
				mov r0,#64			 ;r0 = caracter '@'	
				LDR r1,=Posicion_INI 
				ldr r1,[r1]	 		 ;r1=Posicion inicial
				strb r0,[r1]
				LDR r0,=cuerpo
				str r1,[r0]

				LDR r1,=flag_start  ;Comienza si se ha presionado algún botón
				ldrb r1,[r1]
				cmp r1,#1
				bne comienzo


				;---------------------------------------------------------------------
				;----Inicio del bucle que se encarga de la ejecución del programa-----
				;---------------------------------------------------------------------
				
				;si fin=1 salto a fin_bucle
bucle			LDR r1,=fin
				ldrb r1,[r1]
				cmp r1,#1
				beq	fin_bucle

				;Compara el reloj para saber si toca mover caracter
				LDR r1,=reloj	;Carga el número de centésimas contadas
				ldr r1,[r1]
				LDR r0,=max		;Busca el número de centésimas necesarias para dar el siguiente movimiento
				ldr r0,[r0]
				cmp r1,r0		;Las compara, si no se llega al numero de centesimas necesarias se vuelve al principio del bucle
				bls	bucle
				
				;-------------------------------
				;--- Se inicia el movimiento ---
				;-------------------------------

				;Volvemos a poner el contador a 0
				LDR r1,=reloj
				mov r0,#0
				str r0,[r1]
		
				;Actualizamos k_counter para el tamaño del gusano
				LDR r0,=k_counter
				ldrb r1,[r0]
				add r1,r1,#1
				cmp r1,#5
				bne no_aumenta	;Si el tamaño no tiene que aumentar saltamos a dicha etiqueta
				mov r1,#0
				
				LDR r2,=k ;Si k_counter igual a 5 aumentamos el tamaño en uno
				ldr r3,[r2]
				add r3,r3,#1
				str r3,[r2]

no_aumenta		strb r1,[r0]  ;k_counter actualizado en memoria

				;Si k_counter distinto de 0 debemos borrar la última posición del cuerpo para que no aumente
				LDR	r3,=k_counter
				ldrb r3,[r3]
				cmp r3,#0
				beq no_borrar

				;Borramos la posicion del último caracter 
				mov r1,#32 ; 32 = espacio en blanco en ASCII
				LDR r0,=cuerpo
				LDR r2,=k
				ldr r2,[r2]
				sub r2,r2,#1
				ldr r4,[r0,r2,LSL#2]
				strb r1,[r4] ;Borramos únicamente la última posición del cuerpo
				
no_borrar		;Actualizamos las posiciones de todo el cuerpo	menos de la cabeza

				LDR r2,=k
				ldr r2,[r2]	;r2=k
				sub r2,r2,#1 ;Arreglo para que si r2=0 T[0]=cabeza

				LDR r0,=cuerpo  ;r0=@cuerpo
				cmp r2,#0	   
				bls fin_while

				;-------------------------------------------------------------------------
while			;--- Actualizamos la Tabla con las posiciones de cada parte del cuerpo ---
				;-------------------------------------------------------------------------

				;while(r2>0)
	
				sub r2,r2,#1			;r2=r2-1
				ldr r5,[r0,r2,LSL#2]	;r5=T[r2-1]
				add r2,r2,#1			;r2=r2+1
				str r5,[r0,r2,LSL#2]	;T[r2]=r5
				sub r2,r2,#1			;r2=r2-1
				
				cmp r2,#0	   
				bhi while

				;--------------------------------------------------------------
				;--- Calculamos la nueva posicion del caracter de la cabeza ---
				;--------------------------------------------------------------				

				;Calculamos la nueva fila:
fin_while		LDR r2,=fila_actual
				ldrb r0,[r2]
				LDR r1,=diry
				ldrsb r1,[r1]
				add r1,r1,r0  ;r1=diry+fila_actual
				cmp r1,#-1	  ;Si sobrepasa por arriba de la pantalla lo colocamos abajo
				moveq r1,#15
				cmp r1,#16
				moveq r1,#0   ;Si sobrepasa por abajo de la pantalla lo colocamos arriba
				strb r1,[r2]
				
				;Calculamos la nueva columna:		
				LDR r2,=columna_actual
				ldrb r0,[r2]
				LDR r3,=dirx
				ldrsb r3,[r3]
				add r3,r3,r0  ;r3=dirx+columna_actual
				cmp r3,#-1	  ;Si sobrepasa por la izquierda de la pantalla lo colocamos a la derecha
				moveq r3,#31
				cmp r3,#32
				moveq r3,#0   ;Si sobrepasa por la derecha de la pantalla lo colocamos a la izquierda
				strb r3,[r2]

				;Calculamos la posicion final: (r1=numero de fila, r3= numero de columna)
				LDR r2,=Pantalla	 ;r2 = @Pantalla			
				add r3,r3,r1,LSL#5	 ;r3 = r3 + r1*32
				ldr r1,[r2]			 ;r1 = Comienzo pantalla
				add r1,r1,r3		 ;r1 = Posicion del caracter
				LDR r3,=cuerpo
				str	r1,[r3]			 ;actualizamos posicion de la cabeza

				;-----------------------------------
				;---------Dibujo del cuerpo---------
				;-----------------------------------
				mov r3,#64			 ;r3 = caracter '@'	
				LDR r0,=cuerpo
				ldr r0,[r0]
				strb r3,[r0]		 ;dibujamos la cabeza

				;-------------------------------------
				;--------COMPROBAMOS SI CHOCA---------
				;-------------------------------------

				;Comparamos si la cabeza (T[0]=r1(Posicion)) choca con alguna parte de su cuerpo (resto de T)
			    LDR r0,=cuerpo  ;r0=@cuerpo
				ldr r1,[r0]		;r1=T[0]
				mov	r2,#0	;r2=i=0
				LDR r3,=k
				ldr r3,[r3]	;r3=k
for				;for(i=1,i<k,i++)
				add r2,r2,#1  ;i++
				cmp r3,r2
				bls fin_for

				ldr r4,[r0,r2,LSL#2]  ;r4=T[i]		
				cmp r4,r1			  ;¿T[i]=T[0]?
				beq si_choca
				bne	for

fin_for			b bucle	;Si no choca vuelve a empezar el bucle
				
				;-------------------
si_choca		;--- Si se choca ---
				;-------------------				

				;parpadea 4 veces la cabeza durante 0.64 segundos
				mov r3,#0		;contador de parpadeos
				mov r0,#16		;numero de centesimas hasta un parpadeo	
				LDR r1,=reloj	;@número de centésimas contadas	
			
				mov r5,#64			 ;r5 = caracter '@'	
				mov r6,#32			 ;r6 = caracter ' '

				LDR r4,=cuerpo
				ldr r4,[r4] 	;Posición de la cabeza

				;Ponemos el timer a 0 al comienzo
parpadeo		mov r0,#0			 ;contador de parpadeos, hasta 4.
				str r0,[r1]


b_parpadeo1		;Compara el reloj para saber si toca parpadear FASE 1: dejarlo en blanco
				ldr r2,[r1]
				cmp r2,#4		;Las compara, si no se llega al numero de centesimas necesarias se vuelve al principio del bucle
				bls	b_parpadeo1

				strb r6,[r4]	;Dibujamos el espacio en blanco

b_parpadeo2		;Compara el reloj para saber si toca parpadear FASE 1: dejarlo en blanco
				ldr r2,[r1]
				cmp r2,#8		;Las compara, si no se llega al numero de centesimas necesarias se vuelve al principio del bucle
				bls	b_parpadeo2

				strb r5,[r4]	;Dibujamos el caracter '@'
				add r3,r3,#1	;Sumamos un parpadeo
				cmp r3,#4
				bne parpadeo	;Si no hay cuatro parpadeos se vuelve a empezar			
				
				;--------------------------
				;--- Se borra el gusano ---
				;--------------------------
				mov r1,#32 ; 32 = espacio en blanco en ASCII
				LDR r0,=cuerpo  ;r0=@cuerpo
				mov	r2,#-1		;r2=i=-1
				LDR r3,=k
				ldr r3,[r3]		;r3=k
for2			;for(i=0,i<k,i++)
				add r2,r2,#1  	;i++
				cmp r3,r2
				bls fin_for2

				ldr r4,[r0,r2,LSL#2]  ;r4=@T[i]
				strb r1,[r4]		  ;T[i]=' '
				bne	for2

fin_for2		;Restauramos los valores iniciales de dirx, diry, k, k_counter, fila actual y columna actual
				mov r2,#0
				LDR r1,=dirx
				strb r2,[r1]
				LDR r1,=diry
				strb r2,[r1]
				LDR r1,=k_counter
				strb r2,[r1]
				mov r2,#1
				LDR r1,=k
				str r2,[r1]
				mov r2,#7
				LDR r1,=fila_actual
				strb r2,[r1]
				mov r2,#15
				LDR r1,=columna_actual
				strb r2,[r1]

				;Colocamos flag_start a 0
				LDR r1,=flag_start  
				mov r2,#0
				strb r2,[r1]

				;vuelvo al principio
				b comienzo

				;-----------------------
fin_bucle		;--- Fin del pograma ---
				;-----------------------

				;desactivar IRQ1,IRQ4
				;desactivar RSI_reloj
				;desactivar RSI_boton

				;Deshabilitar máscara IRQ1 y IRQ4
				LDR r0,=VICIntEnClr
				mov r1,#2_10010
				str r1,[r0]

				;Restaurar VI[1] y VI[4]
				LDR r0,=VICVectAddr0
				LDR r1,=boton_so
				ldr r1,[r1]
				mov r2,#1
				str r1,[r0,r2,LSL#2]

				LDR r1,=reloj_so
				ldr r1,[r1]
				mov r2,#4
				str r1,[r0,r2,LSL#2]


bfin			b bfin 

				;-----------------------------------------
RSI_reloj		;--- RSI reloj, para controlar tiempos ---
				;-----------------------------------------

				;Rutina de servicio a la interrupcion IRQ4 (timer 0)
				;Cada 0,01s. llega una peticion de interrupcion

				sub lr,lr,#4	;correccion @retorno
				PUSH {lr}		;apilar @retorno
				mrs r14,spsr	
				PUSH {r14}		;apilar cpsr PP
				msr cpsr_c,#2_01010010
		   	
				PUSH {r0,r1}

				LDR r0,=T0_IR
				mov r1,#1
				str r1,[r0]		;Bajamos la peticion de  IRQ4

				LDR r0,=reloj	;Sumamos una centisima a la variable
				ldr r1,[r0]
				add r1,r1,#1
				str r1,[r0]		;Actualizamos la variable reloj

				POP {r0,r1}

				;retorno
				msr cpsr_c, #2_11010010; modo irq I=1
				POP {r14}
				msr spsr_fsxc,r14	; spsr = cpsr(PP)
				LDR r14,=VICVectAddr
				str r14,[r14]
				POP {pc}^ 			; pc=@ret, ^--> cpsr = spsr modo supervisor

				;-----------------------------------------------------------------------------------------
RSI_boton		;--- RSI boton, para controlar las entradas del usuario a través de un teclado virtual ---
				;-----------------------------------------------------------------------------------------

				;Rutina de servicio a la interrupcion IRQ1 (SW interrupt)
				;al pulsar cada boton llega la peticion de interrupcion IRQ1

				sub lr,lr,#4		;correccion @retorno
				PUSH {lr}			;apilar @retorno
				mrs r14,spsr	
				PUSH {r14}			;apilar cpsr PP
				msr cpsr_c,#2_01010010
		   	
				PUSH {r0-r2}
				
				LDR r0,=DATA_boton	;Leemos el boton que se ha pulsado
				ldr r2,[r0]			; r2 = boton pulsado
				
				LDR r1,=TEC_CTR		;liberar K_teclado
				mov r0,#2_100
				strb r0,[r1]		;TEC_CTR[2]=1

				LDR r0,=VICSoftIntClr
				mov r1,#2_10
				str r1,[r0]			;Bajamos la peticion de  IRQ1

				LDR r1,=flag_start  ;Colocamos el flag a 1
				mov r0,#1
				strb r0,[r1]

				sub r1,r2,#1		; r1 = boton pulsado-1, para indexarlo correctamente en la talba de saltos
				LDR r0,=T_Saltos
				add r0,r0,r1,LSL#2
				ldr pc,[r0] 
				
				
Boton1			;Si es el boton 1 ponemos la variable fin a 1
				LDR r0,=fin
				mov r1,#1
				strb r1,[r0]
				b fin_RSI
				
Boton2			;Si es el 2 ponemos dirx a -1  para que se mueva hacia la izquierda
				LDR r0,=dirx
				mov r1,#-1
				strb r1,[r0]
				LDR r0,=diry ;Colocamos diry a 0 porque no esta permitido el movimiento en diagonal
				mov r1,#0
				strb r1,[r0]
				b fin_RSI

Boton3			;Si es el 3 ponemos dirx a 1  para que se mueva hacia la derecha
				LDR r0,=dirx
				mov r1,#1
				strb r1,[r0]
				LDR r0,=diry ;Colocamos diry a 0 porque no esta permitido el movimiento en diagonal
				mov r1,#0
				strb r1,[r0]
				b	fin_RSI

Boton4			;Si es el 4 ponemos diry a -1  para que se mueva hacia arriba
				LDR r0,=diry
				mov r1,#-1
				strb r1,[r0]
				LDR r0,=dirx ;Colocamos dirx a 0 porque no esta permitido el movimiento en diagonal
				mov r1,#0
				strb r1,[r0]
				b fin_RSI

Boton5			;Si es el 5 ponemos diry a 1  para que se mueva hacia abajo
				LDR r0,=diry
				mov r1,#1
				strb r1,[r0]
				LDR r0,=dirx ;Colocamos dirx a 0 porque no esta permitido el movimiento en diagonal
				mov r1,#0
				strb r1,[r0]
				b fin_RSI

Boton6		   ;Si es el 6 dividimos el valor de la variable max por 2 para que se mueva más rápido
				LDR r0,=max
				ldr r1,[r0]		  ;r1=max
				mov r1,r1,LSR#1	  ;r1=max/2
				cmp r1,#0		  ;Si r1=0 --> r1 = 1
				moveq r1,#1
				stral r1,[r0]
				b fin_RSI

Boton7		   ;Si es el 7 multiplicamos el valor de la variable max por 2 para que se mueva más lento
				LDR r0,=max
				ldr r1,[r0]		  ;r1=max
				mov r1,r1,LSL#1	  ;r1=max*2
				cmp r1,#256		  ;Si r1>256 --> r1 = 256
				movhi r1,#256
				stral r1,[r0]
								
fin_RSI
				POP {r0-r2}

				;retorno
				msr cpsr_c, #2_11010010; modo irq I=1
				POP {r14}
				msr spsr_fsxc,r14	; spsr = cpsr(PP)
				LDR r14,=VICVectAddr
				str r14,[r14]
				POP {pc}^ 			; pc=@ret, ^--> cpsr = spsr modo supervisor

				END	  
