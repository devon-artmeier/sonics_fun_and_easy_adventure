; =========================================================================================================================================================
; MegaDrive macros
; =========================================================================================================================================================
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Align
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; PARAMETERS:
;	bound	- Size boundary
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; RETURNS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
align		macros	bound
		cnop	0,\bound
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Pad RS to even address
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; PARAMETERS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; RETURNS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
rsEven		macros
		rs.b	__rs&1
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Push registers to stack (works on either processor)
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; PARAMETERS:
;	regs	- Registers to push
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; RETURNS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
push		macro	regs
		if z80prg=0
			if instr("\regs","/")|instr("\regs","-")
				movem.\0 \regs,-(sp)
			else
				move.\0	\regs,-(sp)
			endif
		else
			zpush	\regs
		endif
		endm
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Pop registers from stack (works on either processor)
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; PARAMETERS:
;	regs	- Registers to pop
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; RETURNS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
pop		macro	regs
		if z80prg=0
			if instr("\regs","/")|instr("\regs","-")
				movem.\0 (sp)+,\regs
			else
				move.\0	(sp)+,\regs
			endif
		else
			zpop	\regs
		endif
		endm
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Clear memory
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; PARAMETERS:
;	starta	- Address to start clearing memory at
;	enda	- Address to finish clearing memory at
;		  (not rEQUired if there exists a label that is the same as the starting label, but with "_End" at the end of it)
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; RETURNS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
clrRAM		macro	starta, enda
		local	endaddr
		if narg<2
endaddr			EQUS	"\starta\_End"
		else
endaddr			EQUS	"\enda"
		endif

		moveq	#0,d0

		if ((\starta)&$8000)=0
			lea	\starta,a1
		else
			lea	(\starta).w,a1
		endif
		if (\starta)&1
			move.b	d0,(a1)+
		endif

		move.w	#(((\endaddr)-(\starta))-((\starta)&1))>>2-1,d1
.Clear\@:	move.l	d0,(a1)+
		dbf	d1,.Clear\@

		if (((\endaddr)-(\starta))-((\starta)&1))&2
			move.w	d0,(a1)+
		endif
		if (((\endaddr)-(\starta))-((\starta)&1))&1
			move.b	d0,(a1)+
		endif
		endm
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Disable SRAM access
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; PARAMETERS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; RETURNS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
sramOff		macros
		move.b	#0,SRAM_ACCESS
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Enable SRAM access
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; PARAMETERS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; RETURNS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
sramOn		macros
		move.b	#1,SRAM_ACCESS
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Disable interrupts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; PARAMETERS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; RETURNS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
intsOff		macros
		ori	#$700,sr
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Enable interrupts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; PARAMETERS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; RETURNS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
intsOn		macros
		andi	#$F8FF,sr
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Stop the Z80
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; PARAMETERS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; RETURNS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
doZ80Stop	macros
		move.w	#$100,Z80_BUS_REQ
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Wait for the Z80 to stop
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; PARAMETERS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; RETURNS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
waitZ80Stop	macro
.Wait\@:	btst	#0,Z80_BUS_REQ
		bne.s	.Wait\@
		endm
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Stop the Z80 and wait for it to
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; PARAMETERS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; RETURNS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
stopZ80		macro
		doZ80Stop
		waitZ80Stop
		endm
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Start the Z80
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; PARAMETERS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; RETURNS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
startZ80	macros
		move.w	#0,Z80_BUS_REQ
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Wait for the Z80 to start
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; PARAMETERS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; RETURNS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
waitZ80Start	macro
.Wait\@:	btst	#0,Z80_BUS_REQ
		beq.s	.Wait\@
		endm
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Cancel Z80 reset
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; PARAMETERS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; RETURNS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
resetZ80Off	macros
		move.w	#$100,Z80_RESET
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Reset the Z80
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; PARAMETERS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; RETURNS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
resetZ80	macros
		move.w	#0,Z80_RESET
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Wait for the YM2612 to not be busy
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; PARAMETERS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; RETURNS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
waitYM		macro
		nop
		nop
		nop
@Wait\@:	tst.b	(a0)
		bmi.s	@Wait\@
		endm
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Wait for DMA finish
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; PARAMETERS:
;	port	- Something to represent the VDP control port (default is VDP_CTRL_PORT)
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; RETURNS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------	
waitDMA		macro	port
.Wait\@:
		if narg>0
			move.w	\port,d1
		else
			move.w	VDP_CTRL,d1
		endif
		btst	#1,d1
		bne.s	.Wait\@
		endm
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; VDP command instruction
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; PARAMETERS:
;	addr	- Address in VDP memory
;	type	- Type of VDP memory
;	rwd	- VDP command
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; RETURNS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
VRAM		EQU	%100001		; VRAM
CRAM		EQU	%101011		; CRAM
VSRAM		EQU	%100101		; VSRAM
READ		EQU	%001100		; VDP read
WRITE		EQU	%000111		; VDP write
DMA		EQU	%100111		; VDP DMA
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
vdpCmd		macro	ins, addr, type, rwd, end, end2
		if narg=5
			\ins	#(((((\type)&(\rwd))&3)<<30)|(((\addr)&$3FFF)<<16)|((((\type)&(\rwd))&$FC)<<2)|(((\addr)&$C000)>>14)), \end
		elseif narg>=6
			\ins	#(((((\type)&(\rwd))&3)<<30)|(((\addr)&$3FFF)<<16)|((((\type)&(\rwd))&$FC)<<2)|(((\addr)&$C000)>>14))\end, \end2
		else
			\ins	(((((\type)&(\rwd))&3)<<30)|(((\addr)&$3FFF)<<16)|((((\type)&(\rwd))&$FC)<<2)|(((\addr)&$C000)>>14))
		endif
		endm
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; VDP DMA from 68000 memory to VDP memory
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; PARAMETERS:
;	src	- Source address in 68000 memory
;	dest	- Destination address in VDP memory
;	len	- Length of data in bytes
;	type	- Type of VDP memory
;	a6.l	- VDP control port
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; RETURNS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
dma68k		macro	src, dest, len, type, port
		move.l	#$94009300|((((\len)/2)&$FF00)<<8)|(((\len)/2)&$FF),(a6)
		move.l	#$96009500|((((\src)/2)&$FF00)<<8)|(((\src)/2)&$FF),(a6)
		move.w	#$9700|(((\src)>>17)&$7F),(a6)
		vdpCmd	move.w, \dest, \type, DMA, >>16, (a6)
		vdpCmd	move.w, \dest, \type, DMA, &$FFFF, -(sp)
		move.w	(sp)+,(a6)
		endm
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Fill VRAM with byte
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; PARAMETERS:
;	byte	- Byte to fill VRAM with
;	addr	- Address in VRAM
;	len	- Length of fill in bytes
;	a6.l	- VDP control port
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; RETURNS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
dmaFill		macro	byte, addr, len
		move.w	#$8F01,(a6)
		move.l	#$94009300|((((\len)-1)&$FF00)<<8)|(((\len)-1)&$FF),(a6)
		move.w	#$9780,(a6)
		move.l	#$40000080|(((\addr)&$3FFF)<<16)|(((\addr)&$C000)>>14),(a6)
		move.w	#(\byte)<<8,-4(a6)
		waitDMA	(a6)
		move.w	#$8F02,(a6)
		endm
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Copy a region of VRAM to a location in VRAM
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; PARAMETERS:
;	src	- Source address in VRAM
;	dest	- Destination address in VRAM
;	len	- Length of copy in bytes
;	a6.l	- VDP control port
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; RETURNS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
dmaCopy		macro	src, dest, len
		move.w	#$8F01,(a6)
		move.l	#$94009300|((((\len)-1)&$FF00)<<8)|(((\len)-1)&$FF),(a6)
		move.l	#$96009500|(((\src)&$FF00)<<8)|((\src)&$FF),(a6)
		move.w	#$97C0,(a6)
		move.l	#$000000C0|(((\dest)&$3FFF)<<16)|(((\dest)&$C000)>>14),(a6)
		waitDMA	(a6)
		move.w	#$8F02,(a6)
		endm
; =========================================================================================================================================================