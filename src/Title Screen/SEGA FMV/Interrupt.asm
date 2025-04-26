; =========================================================================================================================================================
; Sonic's Fun And Easy Adventure
; By Ralakimus/Novedicus 2017
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; SEGA FMV V-BLANK interrupt
; =========================================================================================================================================================
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Load packet art
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; PARAMETERS:
;	vram	- VRAM offset
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
segaIntLoadArt macro vram
		move.w	(4*9)+2(sp),d0			; Get DMA length
		andi.w	#~1,d0				; ''
		sub.w	r_FMV_DMA_Size,d0		; ''
		beq.s	.End\@				; If it's 0, branch
		
		cmpi.w	#$2000,d0			; Is it too large?
		bcs.s	.GetDMAInfo\@			; If not, branch
		move.w	#$2000,d0			; If so, cap it
		
.GetDMAInfo\@:
		move.l	#r_Buffer&$FFFFFF,d1		; Get DMA source
		add.w	r_FMV_DMA_Size,d1		; ''
		
		moveq	#0,d2				; Get DMA command
		move.w	#\vram,d2			; ''
		add.w	r_FMV_DMA_Size,d2		; ''
		rol.l	#2,d2				; ''
		lsr.w	#2,d2				; ''
		swap	d2				; ''
		ori.l	#$40000080,d2			; ''
		
		add.w	d0,r_FMV_DMA_Size		; Increment DMA size
		
		move.l	#$96009500,-(sp)		; Setup DMA registers
		move.w	#$9700,-(sp)			; ''
		move.l	#$94009300,-(sp)		; ''
		lsr.l	#1,d1				; ''
		movep.l	d1,3(sp)			; ''
		lsr.w	#1,d0				; ''
		movep.w	d0,1(sp)			; ''
		
		move.l	(sp)+,(a6)			; Start DMA
		move.l	(sp)+,(a6)			; ''
		move.w	(sp)+,(a6)			; ''
		move.l	d2,(a6)				; ''
		
.End\@:
		endm
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; V-BLANK interrupt
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
VInt_SEGA:
		intsOff					; Turn interrupts off
		push.l	d0-a6				; Save registers
		
		clr.b	r_VINT_Flag.w			; Clear V-INT flag
		
		lea	VDP_CTRL,a6			; VDP control port
		lea	-4(a6),a5			; VDP data port
; ---------------------------------------------------------------------------------------------------------------------------------------------------------		
		cmpi.w	#25,r_FMV_Packet.w		; Should the logo fall?
		bcs.s	.NoFall				; If not, branch
				
		move.w	r_FMV_Y.w,r_VScroll_FG.w	; Set vertical scroll
		neg.w	r_VScroll_FG.w			; ''
		
		move.w	r_FMV_Y_Vel.w,d0		; Make logo fall
		ext.l	d0				; ''
		asl.l	#8,d0				; ''
		add.l	d0,r_FMV_Y.w			; ''
		addi.w	#$38,r_FMV_Y_Vel.w		; ''
		
		cmpi.w	#224,r_FMV_Y.w			; Has the logo fallen too far?
		blt.s	.NoFall				; If not, branch
		move.w	#224,r_FMV_Y.w			; Stop the logo
		
.NoFall:
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
		lea	.Palette(pc),a0			; Get palette data
		moveq	#0,d0				; ''
		move.b	r_FMV_Frame.w,d0		; ''
		lsl.w	#5,d0				; ''
		adda.w	d0,a0				; ''
		moveq	#$20>>2-1,d0			; Palette size
		
		lea	r_Palette+$60.w,a1		; Palette buffer 1
		tst.b	r_FMV_Plane.w			; Are displaying plane 1?
		beq.s	.LoadPalLoop			; If so, branch
		lea	r_Palette+$40.w,a1		; Palette buffer 0
		
.LoadPalLoop:
		move.l	(a0)+,(a1)+			; Copy data
		dbf	d0,.LoadPalLoop			; Loop
; ---------------------------------------------------------------------------------------------------------------------------------------------------------		
		stopZ80					; Stop the Z80
		bsr.w	ReadJoypads			; Read joypads
		
		tst.b	r_FMV_Frame.w			; Are we on the first frame?
		bne.s	.NoMapLoad			; If not, branch

		tst.b	r_FMV_Plane.w			; Are we loading into plane 0?
		beq.s	.LoadMap0			; If so, branch
		move.w	#$8200|($C000/$400),(a6)	; Display plane 0
		dma68k	r_Buffer+$4000,$A000,$E00,VRAM	; Load packet mappings into plane 1
		bra.s	.NoMapLoad			; ''
		
.LoadMap0:
		move.w	#$8200|($A000/$400),(a6)	; Display plane 1
		dma68k	r_Buffer+$4000,$C000,$E00,VRAM	; Load packet mappings into plane 0

.NoMapLoad:
		dma68k	r_Palette,0,$80,CRAM		; Load palette into CRAM
		dma68k	r_VScroll,0,$50,VSRAM		; Load VScroll buffer into VSRAM
		
		tst.b	r_FMV_Plane.w			; Are we loading into plane 0?
		beq.s	.LoadArt0			; If so, branch
		segaIntLoadArt	$4000			; Load packet art into VRAM
		bra.s	.ArtDone			; ''
		
.LoadArt0:
		segaIntLoadArt	$20			; Load packet art into VRAM
		
.ArtDone:
		startZ80				; Start the Z80
; ---------------------------------------------------------------------------------------------------------------------------------------------------------	
		tst.b	r_FMV_Frame.w			; Are we on the first frame?
		bne.s	.CheckFrameInc			; If not, branch

		cmpi.w	#16,r_FMV_Packet.w		; Is it time to play the chant?
		bne.s	.NoChant			; If not, branch

		moveq	#5-1,d0				; Wait a little
		bsr.w	SEGA_Wait			; ''
		
		lea	SampleList+$D0,a3		; Play chant
		jsr	PlayDAC1			; ''
		
		moveq	#110-1,d0			; Wait some more
		bsr.w	SEGA_Wait			; ''
	
.NoChant:
		cmpi.w	#25,r_FMV_Packet.w		; Should the logo jump?
		bne.s	.CheckFrameInc			; If not, branch
		
		move.w	#-$480,r_FMV_Y_Vel.w		; Make the logo jump
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.CheckFrameInc:
		cmpi.b	#3,r_FMV_Frame.w		; Are we at the last frame for the packet?
		bcc.s	.NoFrameInc			; If so, branch
		addq.b	#1,r_FMV_Frame.w		; Next frame
		
.NoFrameInc:	
		tst.b	r_FMV_Ready.w			; Is the packet ready for display?
		beq.s	.End				; If not, branch
		clr.b	r_FMV_Ready.w			; Reset ready flag
	
		not.b	r_FMV_Plane.w			; Swap plane IDs
		addq.w	#1,r_FMV_Packet.w		; Next packet
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.End:
		pop.l	d0-a6				; Restore registers
		lagOn					; Turn on the lag-o-meter

		tst.b	r_P1_Press.w			; Has the start button been pressed?
		bpl.s	.NoFMVEnd			; If not, branch
		
		move.w	#43,r_FMV_Packet.w		; End the FMV
		move.l	#SEGA_End,2(sp)			; ''

.NoFMVEnd:
		rte
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.Palette:
		dc.w	$EEE, $E40, $EEE, $E40, $EEE, $E40, $EEE, $E40
		dc.w	$EEE, $E40, $EEE, $E40, $EEE, $E40, $EEE, $E40

		dc.w	$EEE, $EEE, $E40, $E40, $EEE, $EEE, $E40, $E40
		dc.w	$EEE, $EEE, $E40, $E40, $EEE, $EEE, $E40, $E40
		
		dc.w	$EEE, $EEE, $EEE, $EEE, $E40, $E40, $E40, $E40
		dc.w	$EEE, $EEE, $EEE, $EEE, $E40, $E40, $E40, $E40

		dc.w	$EEE, $EEE, $EEE, $EEE, $EEE, $EEE, $EEE, $EEE
		dc.w	$E40, $E40, $E40, $E40, $E40, $E40, $E40, $E40
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Wait a certain amount of time
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; PARAMETERS:
;	d0.w	- Wait time
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; RETURNS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
SEGA_Wait:
		intsOff					; Temporarily switch V-BLANK interrupt
		move.l	#VInt_Standard,r_VInt_Addr.w	; ''

.WaitSEGA:
		move.b	#vTitle,r_VINT_Rout.w		; V-INT routine
		jsr	VSync_Routine			; V-SYNC
		
		tst.b	r_P1_Press.w			; Has the start button been pressed?
		bmi.s	.End				; If so, branch

		dbf	d0,.WaitSEGA			; Loop until finished

.End:
		intsOff					; Switch V-BLANK interrupt back
		move.l	#VInt_SEGA,r_VInt_Addr.w	; ''
		rts
; =========================================================================================================================================================