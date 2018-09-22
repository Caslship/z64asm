	.org	0x801064B0
	.set 	noreorder
	.set	noat
#include <mips.h>

	j	Gameshark_Interpret

	.org	0x80600000
	.set	noreorder
	.set	noat
#include <mips.h>

	.global	Gameshark_Interpret
Gameshark_Interpret:

	lui	$at,%hi(Start_GS_List)
	ori	$at,$at,%lo(Start_GS_List)

Main_Loop:
	lbu	t0,0x0000($at)
	lbu	t1,0x0001($at)
	lhu	t2,0x0002($at)
	sll	t1,t1,0x10
	addu	t1,t1,t2
	lui	t2,0x8000
	addu	t1,t1,t2

	li	t2,0x80
	lbu	t3,0x0005($at)
	beql	t0,t2,Loop_Update
	sb	t3,0x0000(t1)
	li	t2,0xA0
	beql	t0,t2,Loop_Update
	sb	t3,0x0000(t1)

	li	t2,0x81
	lhu	t3,0x0004($at)
	beql	t0,t2,Loop_Update
	sh	t3,0x0000(t1)
	li	t2,0xA1
	beql	t0,t2,Loop_Update
	sh	t3,0x0000(t1)

	li	t2,0xD0
	lbu	t3,0x0005($at)
	bne	t0,t2,D1_Check
	lbu	t2,0x0000(t1)
	beq	t2,t3,Loop_Update
	nop
	b	More_D_Check
	addiu	$at,$at,0x0006

D1_Check:
	li	t2,0xD1
	lhu	t3,0x0004($at)
	bne	t0,t2,D2_Check
	lhu	t2,0x0000(t1)
	beq	t2,t3,Loop_Update
	nop
	b	More_D_Check
	addiu	$at,$at,0x0006

D2_Check:
	li	t2,0xD2
	lbu	t3,0x0005($at)
	bne	t0,t2,D3_Check
	lbu	t2,0x0000(t1)
	bne	t2,t3,Loop_Update
	nop
	b	More_D_Check
	addiu	$at,$at,0x0006

D3_Check:
	li	t2,0xD3
	lhu	t3,0x0004($at)
	bne	t0,t2,Exit
	lhu	t2,0x0000(t1)
	bne	t2,t3,Loop_Update
	nop
	addiu	$at,$at,0x0006

More_D_Check:
	li	t2,0xD0
	lbu	t0,0x0000($at)
	andi	t0,t0,0x00F0
	beql	t2,t0,More_D_Check
	addiu	$at,$at,0x0006

Loop_Update:
	b	Main_Loop
	addiu	$at,$at,0x0006

Exit:
	jr	$ra
	nop

Start_GS_List: