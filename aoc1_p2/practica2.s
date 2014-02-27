		AREA datos,DATA,READWRITE 	 ; area de datos
tabla1	SPACE 512					 ; 512 Bytes reservados
tabla2	SPACE 512					 ; 512 Bytes reservados
tabla3	SPACE 512					 ; 512 Bytes reservados
tabla4	SPACE 512					 ; 512 Bytes reservados
t4fin

		AREA codigo,CODE,READONLY	 ; area de codigo
		ENTRY

		LDR r0,=tabla1				 ; r0 = @tabla1
		LDR r2,=t4fin
		mov r1,#0					 ; r1 = 0
buc		strh r1,[r0],#2				 ; M[r0] = r1, r0 = r0+2
		add r1,r1,#1				 ; r1 = r1 + 1
		cmp r0, r2					 ; compara r0 y @tfin
		bne buc						 ; salta si no son iguales
	
		LDR r0,=tabla1				 ; r0 = @tabla1
		LDR r1,=tabla2				 ; r1 = @tabla2
		LDR r2,=tabla3				 ; r2 = @tabla3
		LDR r3,=tabla4				 ; r3 = @tabla4
		
		LDR r8,=t4fin				 ; r8 = @ final de tabla4
		
rot		ldrh r4,[r0]				 ; r4 = Memh[r0]
		ldrh r5,[r1]			 	 ; r5 = Memh[r1] 
		ldrh r6,[r2]				 ; r6 = Memh[r2] 
		ldrh r7,[r3]				 ; r7 = Memh[r3]  
		
		strh r4,[r3],#1				 ; Memh[r3] = r4, r3 = r3 + 1
		strh r5,[r0],#1				 ; Memh[r0] = r5, r0 = r0 + 1
		strh r6,[r1],#1				 ; Memh[r1] = r6, r1 = r1 + 1
		strh r7,[r2],#1				 ; Memh[r2] = r7, r2 = r2 + 1

		cmp r3,	r8
		bne rot

fin		b fin						 ; fin del programa

		END
