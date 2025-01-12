; =========================================================================================================================================================
; Sonic's Fun And Easy Adventure
; By Ralakimus/Novedicus 2017
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; SEGA FMV
; =========================================================================================================================================================
SEGA_FMV:
		clr.b	r_FMV_Flag.w
		clr.l	r_FMV_Y.w
		clr.w	r_FMV_Y_Vel.w
		clr.b	r_FMV_Frame.w			; Reset FMV frame
		move.w	#$8200|($A000/$400),VDP_CTRL	; Use plane 1
		bra.w	.StartLoad			; Start load

.Loop:
		move.b	#vFMV,r_VINT_Rout.w		; FMV V-INT routine
		jsr	VSync_Routine.w			; V-SYNC

		tst.b	r_FMV_Flag.w
		bne.s	.NoSEGA
		cmpi.b	#15*4,r_FMV_Frame.w
		bne.s	.NoSEGA
		lea	SampleList+$D0,a3
		jsr	PlayDAC1
		move.b	#80,r_FMV_Time.w

.WaitSEGA:
		move.b	#vTitle,r_VINT_Rout.w		; V-INT routine
		jsr	VSync_Routine.w			; V-SYNC
		tst.b	r_P1_Press.w
		bmi.w	.End
		subq.b	#1,r_FMV_Time.w
		bne.s	.WaitSEGA
		st	r_FMV_Flag.w

.NoSEGA:
		cmpi.b	#24*4,r_FMV_Frame.w
		bne.s	.DoDrop
		move.w	#-$480,r_FMV_Y_Vel.w

.DoDrop:
		cmpi.b	#24*4,r_FMV_Frame.w
		bcs.s	.NoJump
		move.w	r_FMV_Y.w,r_VScroll_FG.w
		neg.w	r_VScroll_FG.w
		bsr.w	SEGA_Jump

.NoJump:
		tst.b	r_FMV_Load.w			; Are we set to load new data?
		beq.s	.ChkFrame			; If not, branch
		clr.b	r_FMV_Load.w			; Reset the flag

		tst.b	r_FMV_Plane.w			; Are we on plane 1?
		beq.s	.Plane0				; If not, branch
		move.w	#$8200|($A000/$400),VDP_CTRL	; Use plane 1
		bra.s	.ChkFrame

.Plane0:
		move.w	#$8200|($C000/$400),VDP_CTRL	; Use plane 0

.ChkFrame:
		move.b	r_FMV_Frame.w,d0		; Get frame ID
		andi.b	#3,d0				; Is it a multiple of 4?
		bne.w	.LoadPal			; If not, branch

.StartLoad:
		not.b	r_FMV_Plane.w			; Switch planes
		st	r_FMV_Load.w			; Set load data flag

		moveq	#0,d0
		move.b	r_FMV_Frame.w,d0		; Get frame ID
		andi.b	#$FC,d0				; ''
		lsl.w	#2,d0				; Turn into offset

		lea	SEGA_FMV_Data,a0		; FMV data
		lea	(a0,d0.w),a0			; ''

		move.l	(a0)+,d1			; Load art
		move.w	#$20,d2				; ''
		tst.b	r_FMV_Plane.w			; Are we on plane 0?
		beq.s	.LoadArt			; If so, branch
		move.w	#$4000,d2			; ''
		
.LoadArt:
		move.l	(a0)+,d3			; ''
		jsr	QueueDMATransfer		; ''

		move.l	(a0)+,a1			; Load mappings
		lea	r_Buffer,a0			; Load into buffer
		moveq	#$27,d1				; ''
		moveq	#$1B,d2				; ''
		move.w	#$4001,d3			; ''
		tst.b	r_FMV_Plane.w			; Are we on plane 0?
		beq.s	.LoadMap			; If so, branch
		move.w	#$6200,d3			; ''
		
.LoadMap:
		bsr.w	LoadPlaneMap_RAM		; ''

.LoadPal:
		moveq	#0,d0
		move.b	r_FMV_Frame.w,d0		; Get FMV frame
		andi.b	#3,d0				; Only get 0-3
		lsl.w	#5,d0				; Turn into offset
		lea	SEGA_FMV_Pal(pc,d0.w),a0	; Get pointer to palette
		moveq	#$20>>2-1,d0			; Size
		lea	(r_Palette+$40).w,a1		; Palette pointer
		tst.b	r_FMV_Plane.w			; Are we on plane 0?
		beq.s	.LoadPalLoop			; If so, branch
		lea	(r_Palette+$60).w,a1		; Palette pointer
		
.LoadPalLoop:
		move.l	(a0)+,(a1)+			; Copy data
		dbf	d0,.LoadPalLoop			; Loop

		tst.b	r_P1_Press.w
		bmi.s	.End

		addq.b	#1,r_FMV_Frame.w		; Next frame
		cmpi.b	#(43*4)+2,r_FMV_Frame.w		; Is this the end of the FMV?
		bne.w	.Loop				; If not, loop

.End:
		lea	SampleList,a3
		jmp	PlayDAC1
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
SEGA_Jump:
		move.w	r_FMV_Y_Vel.w,d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,r_FMV_Y.w
		addi.w	#$38,r_FMV_Y_Vel.w
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; FMV palette
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
SEGA_FMV_Pal:
		dc.w	$EEE, $E40, $EEE, $E40, $EEE, $E40, $EEE, $E40
		dc.w	$EEE, $E40, $EEE, $E40, $EEE, $E40, $EEE, $E40

		dc.w	$EEE, $EEE, $E40, $E40, $EEE, $EEE, $E40, $E40
		dc.w	$EEE, $EEE, $E40, $E40, $EEE, $EEE, $E40, $E40
		
		dc.w	$EEE, $EEE, $EEE, $EEE, $E40, $E40, $E40, $E40
		dc.w	$EEE, $EEE, $EEE, $EEE, $E40, $E40, $E40, $E40

		dc.w	$EEE, $EEE, $EEE, $EEE, $EEE, $EEE, $EEE, $EEE
		dc.w	$E40, $E40, $E40, $E40, $E40, $E40, $E40, $E40
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; FMV data
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
SEGA_FMV_Data:
		dc.l	FMV00_Art, (FMV00_Art_End-FMV00_Art)/2, FMV00_Map, 0
		dc.l	FMV01_Art, (FMV01_Art_End-FMV01_Art)/2, FMV01_Map, 0
		dc.l	FMV02_Art, (FMV02_Art_End-FMV02_Art)/2, FMV02_Map, 0
		dc.l	FMV03_Art, (FMV03_Art_End-FMV03_Art)/2, FMV03_Map, 0
		dc.l	FMV04_Art, (FMV04_Art_End-FMV04_Art)/2, FMV04_Map, 0
		dc.l	FMV05_Art, (FMV05_Art_End-FMV05_Art)/2, FMV05_Map, 0
		dc.l	FMV06_Art, (FMV06_Art_End-FMV06_Art)/2, FMV06_Map, 0
		dc.l	FMV07_Art, (FMV07_Art_End-FMV07_Art)/2, FMV07_Map, 0
		dc.l	FMV08_Art, (FMV08_Art_End-FMV08_Art)/2, FMV08_Map, 0
		dc.l	FMV09_Art, (FMV09_Art_End-FMV09_Art)/2, FMV09_Map, 0
		dc.l	FMV10_Art, (FMV10_Art_End-FMV10_Art)/2, FMV10_Map, 0
		dc.l	FMV11_Art, (FMV11_Art_End-FMV11_Art)/2, FMV11_Map, 0
		dc.l	FMV12_Art, (FMV12_Art_End-FMV12_Art)/2, FMV12_Map, 0
		dc.l	FMV13_Art, (FMV13_Art_End-FMV13_Art)/2, FMV13_Map, 0
		dc.l	FMV14_Art, (FMV14_Art_End-FMV14_Art)/2, FMV14_Map, 0
		dc.l	FMV15_Art, (FMV15_Art_End-FMV15_Art)/2, FMV15_Map, 0
		dc.l	FMV16_Art, (FMV16_Art_End-FMV16_Art)/2, FMV16_Map, 0
		dc.l	FMV17_Art, (FMV17_Art_End-FMV17_Art)/2, FMV17_Map, 0
		dc.l	FMV18_Art, (FMV18_Art_End-FMV18_Art)/2, FMV18_Map, 0
		dc.l	FMV19_Art, (FMV19_Art_End-FMV19_Art)/2, FMV19_Map, 0
		dc.l	FMV20_Art, (FMV20_Art_End-FMV20_Art)/2, FMV20_Map, 0
		dc.l	FMV21_Art, (FMV21_Art_End-FMV21_Art)/2, FMV21_Map, 0
		dc.l	FMV22_Art, (FMV22_Art_End-FMV22_Art)/2, FMV22_Map, 0
		dc.l	FMV23_Art, (FMV23_Art_End-FMV23_Art)/2, FMV23_Map, 0
		dc.l	FMV24_Art, (FMV24_Art_End-FMV24_Art)/2, FMV24_Map, 0
		dc.l	FMV25_Art, (FMV25_Art_End-FMV25_Art)/2, FMV25_Map, 0
		dc.l	FMV26_Art, (FMV26_Art_End-FMV26_Art)/2, FMV26_Map, 0
		dc.l	FMV27_Art, (FMV27_Art_End-FMV27_Art)/2, FMV27_Map, 0
		dc.l	FMV28_Art, (FMV28_Art_End-FMV28_Art)/2, FMV28_Map, 0
		dc.l	FMV29_Art, (FMV29_Art_End-FMV29_Art)/2, FMV29_Map, 0
		dc.l	FMV30_Art, (FMV30_Art_End-FMV30_Art)/2, FMV30_Map, 0
		dc.l	FMV31_Art, (FMV31_Art_End-FMV31_Art)/2, FMV31_Map, 0
		dc.l	FMV32_Art, (FMV32_Art_End-FMV32_Art)/2, FMV32_Map, 0
		dc.l	FMV33_Art, (FMV33_Art_End-FMV33_Art)/2, FMV33_Map, 0
		dc.l	FMV34_Art, (FMV34_Art_End-FMV34_Art)/2, FMV34_Map, 0
		dc.l	FMV35_Art, (FMV35_Art_End-FMV35_Art)/2, FMV35_Map, 0
		dc.l	FMV36_Art, (FMV36_Art_End-FMV36_Art)/2, FMV36_Map, 0
		dc.l	FMV37_Art, (FMV37_Art_End-FMV37_Art)/2, FMV37_Map, 0
		dc.l	FMV38_Art, (FMV38_Art_End-FMV38_Art)/2, FMV38_Map, 0
		dc.l	FMV39_Art, (FMV39_Art_End-FMV39_Art)/2, FMV39_Map, 0
		dc.l	FMV40_Art, (FMV40_Art_End-FMV40_Art)/2, FMV40_Map, 0
		dc.l	FMV41_Art, (FMV41_Art_End-FMV41_Art)/2, FMV41_Map, 0
		dc.l	FMV42_Art, (FMV42_Art_End-FMV42_Art)/2, FMV42_Map, 0
		dc.l	FMV43_Art, (FMV43_Art_End-FMV43_Art)/2, FMV43_Map, 0
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
FMV00_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV00.Art.bin"
FMV00_Art_End:	even
FMV00_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV00.Map.bin"
		even
FMV01_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV01.Art.bin"
FMV01_Art_End:	even
FMV01_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV01.Map.bin"
		even
FMV02_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV02.Art.bin"
FMV02_Art_End:	even
FMV02_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV02.Map.bin"
		even
FMV03_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV03.Art.bin"
FMV03_Art_End:	even
FMV03_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV03.Map.bin"
		even
FMV04_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV04.Art.bin"
FMV04_Art_End:	even
FMV04_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV04.Map.bin"
		even
FMV05_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV05.Art.bin"
FMV05_Art_End:	even
FMV05_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV05.Map.bin"
		even
FMV06_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV06.Art.bin"
FMV06_Art_End:	even
FMV06_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV06.Map.bin"
		even
FMV07_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV07.Art.bin"
FMV07_Art_End:	even
FMV07_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV07.Map.bin"
		even
FMV08_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV08.Art.bin"
FMV08_Art_End:	even
FMV08_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV08.Map.bin"
		even
FMV09_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV09.Art.bin"
FMV09_Art_End:	even
FMV09_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV09.Map.bin"
		even
FMV10_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV10.Art.bin"
FMV10_Art_End:	even
FMV10_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV10.Map.bin"
		even
FMV11_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV11.Art.bin"
FMV11_Art_End:	even
FMV11_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV11.Map.bin"
		even
FMV12_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV12.Art.bin"
FMV12_Art_End:	even
FMV12_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV12.Map.bin"
		even
FMV13_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV13.Art.bin"
FMV13_Art_End:	even
FMV13_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV13.Map.bin"
		even
FMV14_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV14.Art.bin"
FMV14_Art_End:	even
FMV14_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV14.Map.bin"
		even
FMV15_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV15.Art.bin"
FMV15_Art_End:	even
FMV15_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV15.Map.bin"
		even
FMV16_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV16.Art.bin"
FMV16_Art_End:	even
FMV16_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV16.Map.bin"
		even
FMV17_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV17.Art.bin"
FMV17_Art_End:	even
FMV17_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV17.Map.bin"
		even
FMV18_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV18.Art.bin"
FMV18_Art_End:	even
FMV18_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV18.Map.bin"
		even
FMV19_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV19.Art.bin"
FMV19_Art_End:	even
FMV19_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV19.Map.bin"
		even
FMV20_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV20.Art.bin"
FMV20_Art_End:	even
FMV20_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV20.Map.bin"
		even
FMV21_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV21.Art.bin"
FMV21_Art_End:	even
FMV21_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV21.Map.bin"
		even
FMV22_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV22.Art.bin"
FMV22_Art_End:	even
FMV22_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV22.Map.bin"
		even
FMV23_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV23.Art.bin"
FMV23_Art_End:	even
FMV23_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV23.Map.bin"
		even
FMV24_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV24.Art.bin"
FMV24_Art_End:	even
FMV24_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV24.Map.bin"
		even
FMV25_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV25.Art.bin"
FMV25_Art_End:	even
FMV25_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV25.Map.bin"
		even
FMV26_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV26.Art.bin"
FMV26_Art_End:	even
FMV26_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV26.Map.bin"
		even
FMV27_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV27.Art.bin"
FMV27_Art_End:	even
FMV27_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV27.Map.bin"
		even
FMV28_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV28.Art.bin"
FMV28_Art_End:	even
FMV28_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV28.Map.bin"
		even
FMV29_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV29.Art.bin"
FMV29_Art_End:	even
FMV29_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV29.Map.bin"
		even
FMV30_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV30.Art.bin"
FMV30_Art_End:	even
FMV30_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV30.Map.bin"
		even
FMV31_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV31.Art.bin"
FMV31_Art_End:	even
FMV31_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV31.Map.bin"
		even
FMV32_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV32.Art.bin"
FMV32_Art_End:	even
FMV32_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV32.Map.bin"
		even
FMV33_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV33.Art.bin"
FMV33_Art_End:	even
FMV33_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV33.Map.bin"
		even
FMV34_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV34.Art.bin"
FMV34_Art_End:	even
FMV34_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV34.Map.bin"
		even
FMV35_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV35.Art.bin"
FMV35_Art_End:	even
FMV35_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV35.Map.bin"
		even
FMV36_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV36.Art.bin"
FMV36_Art_End:	even
FMV36_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV36.Map.bin"
		even
FMV37_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV37.Art.bin"
FMV37_Art_End:	even
FMV37_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV37.Map.bin"
		even
FMV38_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV38.Art.bin"
FMV38_Art_End:	even
FMV38_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV38.Map.bin"
		even
FMV39_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV39.Art.bin"
FMV39_Art_End:	even
FMV39_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV39.Map.bin"
		even
FMV40_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV40.Art.bin"
FMV40_Art_End:	even
FMV40_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV40.Map.bin"
		even
FMV41_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV41.Art.bin"
FMV41_Art_End:	even
FMV41_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV41.Map.bin"
		even
FMV42_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV42.Art.bin"
FMV42_Art_End:	even
FMV42_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV42.Map.bin"
		even
FMV43_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV43.Art.bin"
FMV43_Art_End:	even
FMV43_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV43.Map.bin"
		even
; =========================================================================================================================================================