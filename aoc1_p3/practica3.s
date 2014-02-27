	 AREA datos,DATA,READWRITE 	 ; area de datos
fila EQU 5
col  EQU 7
mat	 DCB "nkongvfkobcfeqpbjufcxxfrewomnkgytvd"
k	 EQU 1

	 AREA codigo,CODE,READONLY	 ; area de codigo
	 ENTRY

	 LDR r3,=mat			 ;r3=@mat
	 mov r10,#1				 ;r10=1 número de veces que hay que hacer la ordenación por burbuja
	 mov r9,#fila		   	 ;r9 = 5
	 mov r8,#col			 ;r8=7

	 mov r1,#0				 ;r1 = i
for1 add r1,r1,#k			 ;r1=r1+1
	 cmp r9,r1			 	 ;condiciones y creación bucle
	 bls cols	 			 ; if(i<fila) then terminar la ordenación del vector

	 			 
	 mov r2,r9		 	 	 ;r2=j
for2 sub r2,r2,#k			 ;r2=j-1
	 cmp r1,r2				 ;condiciones y creación bucle
	 bhi for1				 ;if (j>=i) then  terminar este bucle y saltar al bucle anterior

	 mul r4,r2,r8
	 add r4,r4,r10
	 sub r4,r4,#1	
	 add r4,r4,r3			 ;r4=@T[j]

	 mul r7,r2,r8
	 add r7,r7,r10
	 sub r7,r7,#8	
	 add r7,r7,r3			 ;r4=@T[j-1]

	 ldrb r5,[r7]			 ;r5=T[j-1]
	 ldrb r6,[r4]			 ;r6=T[j]

	 cmp r5,r6				 ; if(T[j-1] > T[j]) then intercambio
	 bls for2				 ; else volver a evaluar la primera condición del bucle
	 strb r6,[r7]
	 strb r5,[r4]

	 b for2

cols mov r1,#0				 ;codigo destinado a ejecutar el metodo de ordenación tantas veces como col
	 cmp r10,#col
	 add r10,r10,#k
	 bne for1

fin  b fin

	 END	   