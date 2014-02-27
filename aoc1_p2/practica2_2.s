	 AREA datos,DATA,READWRITE 	 ; area de datos
trad DCB "CDE+ =", 0xFF, 0xFF, "6789AB", 0xFF, 0xFF, "012345"
finm DCB 0xFF
msj  DCB 0x11, 0x12, 0x04, 0x03, 0x04, 0x0C, 0x10, 0x04, 0x05, 0x04, 0x0D, 0x12, 0xFF
msjf


	 AREA codigo,CODE,READONLY	 ; area de codigo
	 ENTRY

	 LDR r0,=trad		; r0=@trad
	 LDR r1,=msj		; r1=@msj
	 LDR r5,=msjf		; r5=@msjf
	 LDR r6,=finm
	 strb r7,[r6]

buc	 ldrb r2,[r1],#1	; r2= Memb[r1]	, r1=r1+1
	 add r3,r0,r2		; r3= r0+r2
   	 ldrb r4,[r3]		; r4= Memb[r3]
	 strb r4,[r5],#1	; Memb[r5]= r4, r5=r5+1
	 cmp  r4,r7
	 bne buc

fin b fin
