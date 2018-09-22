.org FreeSpace

lui $at, %hi(Start_GS_List)
ori $at, $at, %lo(Start_GS_List)

Main_Loop:
lbu t0, 0x0000($at) ; t0 = code-type
lbu t1, 0x0001($at) ; t1 = (memory address & 0x00FF0000) >> 16
lhu t2, 0x0002($at) ; t2 = (memory address & 0x0000FFFF)
sll t1, t1, 0x0010 ; t1 <<= 16
addu t1, t1, t2 ; t1 = (memory address & 0x00FFFFFF)
lui t2, 0x8000
addu t1, t1, t2 ; t1 now holds a memory address whose upper-bits ((t1 & 0xFF000000) >> 28) == 0x80

addiu t2, $zero, 0x80
lbu t3, 0x0005($at) ; t3 = code-value-u8
beql t0, t2, Loop_Update  ; if (code-type == 0x81) goto Loop_Update...
sb t3, 0x0000(t1) ; { ...memory-value-u8 = code-value-u8 }
addiu t2, $zero, 0xA0
beql t0, t2, Loop_Update ; if (code-type == 0xA1) goto Loop_Update...
sb t3, 0x0000(t1) ; { ...memory-value-u8 = code-value-u8 }

addiu t2, $zero, 0x81
lhu t3, 0x0004($at) ; t3 = code-value-u16
beql t0, t2, Loop_Update  ; if (code-type == 0x81) goto Loop_Update...
sh t3, 0x0000(t1) ; { ...memory-value-u16 = code-value-u16 }
addiu t2, $zero, 0xA1
beql t0, t2, Loop_Update ; if (code-type == 0xA1) goto Loop_Update...
sh t3, 0x0000(t1) ; { ...memory-value-u16 = code-value-u16 }

addiu t2, $zero, 0xD0
lbu t3, 0x0005($at) ; t3 = code-value-u8
bne t0, t2, D1_Check ; if (code-type != 0xD0) goto D1_Check
lbu t2, 0x0000(t1) ; t2 = memory-value-u8
beq t2, t3, Loop_Update ; if (memory-value-u8 == code-value-u8) goto Loop_Update
nop
beq $zero, $zero, More_D_Check ; goto More_D_Check
addiu $at, $at, 0x0006 ; else increment GS code line

D1_Check:
addiu t2, $zero, 0xD1
lhu t3, 0x0004($at) ; t3 = code-value-u16
bne t0, t2, D2_Check ; if (code-type != 0xD1) goto D2_Check
lhu t2, 0x0000(t1) ; t2 = memory-value-u16
beq t2, t3, Loop_Update ; if (memory-value-u16 == code-value-u16) goto Loop_Update
nop
beq $zero, $zero, More_D_Check ; goto More_D_Check
addiu $at, $at, 0x0006 ; else increment GS code line

D2_Check:
addiu t2, $zero, 0xD2
lbu t3, 0x0005($at) ; t3 = code-value-u8
bne t0, t2, D3_Check ; if (code-type != 0xD2) goto D3_Check
lbu t2, 0x0000(t1) ; t2 = memory-value-u8
bne t2, t3, Loop_Update ; if (memory-value-u8 != code-value-u8) goto Loop_Update
nop
beq $zero, $zero, More_D_Check ; goto More_D_Check
addiu $at, $at, 0x0006 ; else increment GS code line

D3_Check:
addiu t2, $zero, 0xD3
lhu t3, 0x0004($at) ; t3 = code-value-u16
bne t0, t2, Exit ; if (code-type != 0xD3) goto Exit
lhu t2, 0x0000(t1) ; t2 = memory-value-u16
bne t2, t3, Loop_Update ; if (memory-value-u16 != code-value-u16) goto Loop_Update
nop
addiu $at, $at, 0x0006 ; else increment GS code line

More_D_Check:
addiu t2, $zero, 0xD0
lbu t0, 0x0000($at) ; t0 = code-type
andi t0, t0, 0x00F0 ; t0 = code-type & 0x00F0
beql t2, t0, More_D_Check ; if ((code-type & 0x00F0) == 0xD0) goto More_D_Check
addiu $at, $at, 0x0006 ; { increment GS code line }

Loop_Update:
beq $zero, $zero, Main_Loop ; goto Main_Loop
addiu $at, $at, 0x0006 ; increment GS code line

Exit:
jr $ra ; return
nop

Start_GS_List: