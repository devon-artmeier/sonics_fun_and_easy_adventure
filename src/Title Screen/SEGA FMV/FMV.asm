; =========================================================================================================================================================
; Sonic's Fun And Easy Adventure
; By Ralakimus/Novedicus 2017
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; SEGA FMV
; =========================================================================================================================================================
SEGA_FMV:
		intsOff					; Set V-BLANK interrupt
		move.l	#VInt_SEGA,r_VInt_Addr.w	; ''
		
		clrRAM	r_Buffer			; Clear buffer
		
		clr.l	r_FMV_Y.w			; Reset Y position
		clr.w	r_FMV_Y_Vel.w			; Reset Y velocity
		clr.b	r_FMV_Ready.w			; Reset ready flag
		clr.w	r_FMV_Packet.w			; Reset packet ID
		clr.b	r_FMV_Plane.w			; Reset plane ID
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
SEGA_Loop:
		intsOff					; Disable interrupts

		move.w	r_FMV_Packet.w,d0		; Get packet data
		lsl.w	#3,d0				; ''
		lea	SEGA_FMV_Data,a3		; ''
		lea	(a3,d0.w),a3			; ''
		
		movea.l	(a3)+,a1			; Get mappings data
		lea	r_Buffer+$4000,a0		; Get mappings load buffer
		moveq	#$28-1,d1			; Mappings width
		moveq	#$1C-1,d2			; Mappings height
		
		move.w	#$4001,d3			; Base tile properties for plane 0
		tst.b	r_FMV_Plane.w			; Are we loading into plane 0?
		beq.s	.LoadMap			; If so, branch
		move.w	#$6200,d3			; Base tile properties for plane 1
		
.LoadMap:
		bsr.w	LoadPlaneMap_RAM		; Load mappings
		
		movea.l	(a3)+,a0			; Get art data
		lea	r_Buffer,a1			; Get art load buffer
		
		clr.w	r_FMV_DMA_Size.w		; Reset DMA size
		clr.b	r_FMV_Frame.w			; Reset frame ID
		
		intsOn					; Enable interrupts
		bsr.w	KosDec				; Load art
		st	r_FMV_Ready.w			; Set ready flag
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.WaitNextPacket:
		tst.b	r_P1_Press.w			; Has the start button been pressed?
		bmi.s	SEGA_End			; If so, branch
		
		tst.b	r_FMV_Ready.w			; Should we load the next packet?
		bne.s	.WaitNextPacket			; If not, wait

		cmpi.w	#44,r_FMV_Packet.w		; Is this the end of the FMV?
		bcs.w	SEGA_Loop			; If not, loop
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
SEGA_End:
		intsOff					; Switch V-BLANK interrupt back to the regular one
		move.l	#VInt_Standard,r_VInt_Addr.w	; ''
		
		lea	SampleList,a3			; Stop the chant if it's still playing
		jmp	PlayDAC1			; ''
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
		include	"Title Screen/SEGA FMV/Interrupt.asm"
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; FMV data
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
SEGA_FMV_Data:
		dc.l	FMV00_Map, FMV00_Art
		dc.l	FMV01_Map, FMV01_Art
		dc.l	FMV02_Map, FMV02_Art
		dc.l	FMV03_Map, FMV03_Art
		dc.l	FMV04_Map, FMV04_Art
		dc.l	FMV05_Map, FMV05_Art
		dc.l	FMV06_Map, FMV06_Art
		dc.l	FMV07_Map, FMV07_Art
		dc.l	FMV08_Map, FMV08_Art
		dc.l	FMV09_Map, FMV09_Art
		dc.l	FMV10_Map, FMV10_Art
		dc.l	FMV11_Map, FMV11_Art
		dc.l	FMV12_Map, FMV12_Art
		dc.l	FMV13_Map, FMV13_Art
		dc.l	FMV14_Map, FMV14_Art
		dc.l	FMV15_Map, FMV15_Art
		dc.l	FMV16_Map, FMV16_Art
		dc.l	FMV17_Map, FMV17_Art
		dc.l	FMV18_Map, FMV18_Art
		dc.l	FMV19_Map, FMV19_Art
		dc.l	FMV20_Map, FMV20_Art
		dc.l	FMV21_Map, FMV21_Art
		dc.l	FMV22_Map, FMV22_Art
		dc.l	FMV23_Map, FMV23_Art
		dc.l	FMV24_Map, FMV24_Art
		dc.l	FMV25_Map, FMV25_Art
		dc.l	FMV26_Map, FMV26_Art
		dc.l	FMV27_Map, FMV27_Art
		dc.l	FMV28_Map, FMV28_Art
		dc.l	FMV29_Map, FMV29_Art
		dc.l	FMV30_Map, FMV30_Art
		dc.l	FMV31_Map, FMV31_Art
		dc.l	FMV32_Map, FMV32_Art
		dc.l	FMV33_Map, FMV33_Art
		dc.l	FMV34_Map, FMV34_Art
		dc.l	FMV35_Map, FMV35_Art
		dc.l	FMV36_Map, FMV36_Art
		dc.l	FMV37_Map, FMV37_Art
		dc.l	FMV38_Map, FMV38_Art
		dc.l	FMV39_Map, FMV39_Art
		dc.l	FMV40_Map, FMV40_Art
		dc.l	FMV41_Map, FMV41_Art
		dc.l	FMV42_Map, FMV42_Art
		dc.l	FMV43_Map, FMV43_Art
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
FMV00_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV00.Art.kos"
		even
FMV00_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV00.Map.bin"
		even
FMV01_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV01.Art.kos"
		even
FMV01_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV01.Map.bin"
		even
FMV02_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV02.Art.kos"
		even
FMV02_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV02.Map.bin"
		even
FMV03_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV03.Art.kos"
		even
FMV03_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV03.Map.bin"
		even
FMV04_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV04.Art.kos"
		even
FMV04_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV04.Map.bin"
		even
FMV05_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV05.Art.kos"
		even
FMV05_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV05.Map.bin"
		even
FMV06_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV06.Art.kos"
		even
FMV06_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV06.Map.bin"
		even
FMV07_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV07.Art.kos"
		even
FMV07_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV07.Map.bin"
		even
FMV08_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV08.Art.kos"
		even
FMV08_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV08.Map.bin"
		even
FMV09_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV09.Art.kos"
		even
FMV09_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV09.Map.bin"
		even
FMV10_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV10.Art.kos"
		even
FMV10_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV10.Map.bin"
		even
FMV11_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV11.Art.kos"
		even
FMV11_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV11.Map.bin"
		even
FMV12_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV12.Art.kos"
		even
FMV12_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV12.Map.bin"
		even
FMV13_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV13.Art.kos"
		even
FMV13_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV13.Map.bin"
		even
FMV14_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV14.Art.kos"
		even
FMV14_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV14.Map.bin"
		even
FMV15_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV15.Art.kos"
		even
FMV15_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV15.Map.bin"
		even
FMV16_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV16.Art.kos"
		even
FMV16_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV16.Map.bin"
		even
FMV17_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV17.Art.kos"
		even
FMV17_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV17.Map.bin"
		even
FMV18_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV18.Art.kos"
		even
FMV18_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV18.Map.bin"
		even
FMV19_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV19.Art.kos"
		even
FMV19_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV19.Map.bin"
		even
FMV20_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV20.Art.kos"
		even
FMV20_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV20.Map.bin"
		even
FMV21_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV21.Art.kos"
		even
FMV21_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV21.Map.bin"
		even
FMV22_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV22.Art.kos"
		even
FMV22_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV22.Map.bin"
		even
FMV23_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV23.Art.kos"
		even
FMV23_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV23.Map.bin"
		even
FMV24_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV24.Art.kos"
		even
FMV24_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV24.Map.bin"
		even
FMV25_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV25.Art.kos"
		even
FMV25_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV25.Map.bin"
		even
FMV26_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV26.Art.kos"
		even
FMV26_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV26.Map.bin"
		even
FMV27_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV27.Art.kos"
		even
FMV27_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV27.Map.bin"
		even
FMV28_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV28.Art.kos"
		even
FMV28_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV28.Map.bin"
		even
FMV29_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV29.Art.kos"
		even
FMV29_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV29.Map.bin"
		even
FMV30_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV30.Art.kos"
		even
FMV30_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV30.Map.bin"
		even
FMV31_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV31.Art.kos"
		even
FMV31_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV31.Map.bin"
		even
FMV32_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV32.Art.kos"
		even
FMV32_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV32.Map.bin"
		even
FMV33_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV33.Art.kos"
		even
FMV33_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV33.Map.bin"
		even
FMV34_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV34.Art.kos"
		even
FMV34_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV34.Map.bin"
		even
FMV35_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV35.Art.kos"
		even
FMV35_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV35.Map.bin"
		even
FMV36_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV36.Art.kos"
		even
FMV36_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV36.Map.bin"
		even
FMV37_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV37.Art.kos"
		even
FMV37_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV37.Map.bin"
		even
FMV38_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV38.Art.kos"
		even
FMV38_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV38.Map.bin"
		even
FMV39_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV39.Art.kos"
		even
FMV39_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV39.Map.bin"
		even
FMV40_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV40.Art.kos"
		even
FMV40_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV40.Map.bin"
		even
FMV41_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV41.Art.kos"
		even
FMV41_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV41.Map.bin"
		even
FMV42_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV42.Art.kos"
		even
FMV42_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV42.Map.bin"
		even
FMV43_Art:	incbin	"Title Screen/SEGA FMV/Data/FMV43.Art.kos"
		even
FMV43_Map:	incbin	"Title Screen/SEGA FMV/Data/FMV43.Map.bin"
		even
; =========================================================================================================================================================