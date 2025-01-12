; =========================================================================================================================================================
; Sonic's Fun And Easy Adventure
; By Ralakimus/Novedicus 2017
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Level
; =========================================================================================================================================================
r_Obj_Player		equ	r_Obj_0
r_Obj_Surface1		equ	r_Obj_1
r_Obj_Surface2		equ	r_Obj_2
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
Level:
		playSnd	#Mus_FadeOut, 1			; Fade out sound

		jsr	FadeToBlack			; Fade to black

Level_NoFade:
		; --- Set up the VDP ---

		intsOff					; Disable interrupts
		displayOff				; Disable display

		lea	VDP_CTRL,a5			; VDP control port
		move.w	#$8004,(a5)			; Disable H-INT
		move.w	#$8230,(a5)			; Plane A at $C000
		move.w	#$8407,(a5)			; Plane B at $E000
		move.w	#$8720,VDP_CTRL			; Set background color to palette line 2, entry 0
		move.w	#$8B03,(a5)			; V-Scroll by screen, H-Scroll by scanline
		move.w	#$9001,(a5)			; 64x32 cell plane area
		move.w	#$9200,d0			; Make the window invisible
		move.w	d0,r_Window_Y.w			; ''
		move.w	d0,(a5)				; ''
		clr.w	r_DMA_Queue.w			; Set stop token at the beginning of the DMA queue
		move.w	#r_DMA_Queue,r_DMA_Slot.w	; Reset the DMA queue slot

		jsr	ClearScreen.w			; Clear the screen

		; --- Clear some RAM ---

		clrRAM	r_Kos_Vars			; Clear Kosinski queue variables
		clrRAM	r_Game_Vars			; Clear variables
		clrRAM	r_Objects			; Clear object RAM
		clrRAM	r_Osc_Nums			; Clear oscillation data

		; --- Do some final initializing and play the level music ---

		move.b	#3,r_Ring_Ani_Time.w		; Set ring animation timer
		move.w	#30,r_Floor_Timer.w		; Set floor timer
		clr.w	r_PalCyc_Timer.w		; Reset palette cycle

		lea	Level_MusicIDs(pc),a0		; Music ID list
		move.w	r_Level.w,d0			; Get level ID
		ror.b	#1,d0				; Turn into offset
		lsr.w	#7,d0				; ''
		move.b	(a0,d0.w),d0			; Get music ID
		move.b	d0,r_Level_Music.w		; Store it
		playSnd	d0, 1				; Play it

		intsOn					; Enable interrupts

		; --- Load level data ---

		lea	PLC_LevelMain,a3		; Load main level PLCs
		jsr	LoadKosMQueue.w			; ''

		bsr.w	Level_LoadData			; Load level data

.WaitPLCs:
		move.b	#vGeneral,r_VINT_Rout.w		; Level load V-INT routine
		jsr	ProcessKos.w			; Process Kosinski queue
		jsr	VSync_Routine.w			; V-SYNC
		jsr	ProcessKosM.w			; Process Kosinski Moduled queue
		tst.b	r_KosM_Mods.w			; Are there still modules left?
		bne.s	.WaitPLCs			; If so, branch

		clr.b	r_Water_Flag.w			; Clear the water flag

		lea	Level_WaterLevels(pc),a0	; Water heights
		move.w	r_Level.w,d0			; Get level ID
		ror.b	#1,d0				; Turn into offset
		lsr.w	#6,d0				; ''
		move.w	(a0,d0.w),d0			; Get water height
		bmi.s	.NoWater			; If it's negative, branch
		move.w	d0,r_Water_Lvl.w		; Set the water height
		move.w	d0,r_Dest_Wat_Lvl.w
		
		st	r_Water_Flag.w			; Set the water flag
		move.w	#$8014,VDP_CTRL			; Enable H-INT
		bsr.w	Level_WaterHeight		; Update water height
		move.w	r_HInt_Reg.w,VDP_CTRL		; Set H-INT counter

.NoWater:
		move.w	#320/2,r_Cam_X_Center.w		; Set camera X center

		jsr	InitOscillation.w		; Initialize oscillation

		bsr.w	Level_HandleCamera		; Initialize the camera
		bsr.w	Level_InitHUD			; Initialize the HUD
		bsr.w	Level_WaterHeight		; Initialize water height

		bsr.w	Level_AnimateArt		; Animate level art

		; --- Load the planes ---

		intsOff					; Disable interrupts
		move.l	#VInt_RunSMPS,r_VInt_Addr.w	; Swap V-INT
		intsOn					; Enable interrupts
		bsr.w	Level_InitPlanes		; Initialize the planes
		intsOff					; Disable interrupts
		move.l	#VInt_Standard,r_VInt_Addr.w	; Swap V-INT
		intsOn					; Enable interrupts
		move.b	#vLvlLoad,r_VINT_Rout.w		; Level load V-INT routine
		jsr	VSync_Routine.w			; V-SYNC

		; --- Load the level objects and rings ---

		clr.b	r_Obj_Man_Rout.w		; Reset object manager routine
		bsr.w	Level_RingsManager		; Initialize the ring manager
		jsr	ObjectManager.w			; Run the object manager
		
		move.l	#ObjSonic,r_Obj_Player.w	; Load Sonic object

		tst.b	r_Water_Flag.w			; Does the level have water?
		beq.s	.NoSurface			; If not, branch

							; Load water surfaces
		move.l	#ObjWaterSurface,r_Obj_Surface1.w
		move.w	#$60,(r_Obj_Surface1+oX).w
		move.l	#ObjWaterSurface,r_Obj_Surface2
		move.w	#$120,(r_Obj_Surface2+oX).w
		
.NoSurface:
		jsr	RunObjects.w			; Run objects
		jsr	RenderObjects.w			; Render objects

		tst.b	r_Start_Fall.w			; Should we start the level by falling?
		beq.s	.Finalize			; If not, branch
		move.b	#$1B,(r_Obj_Player+oAni).w	; Set to falling animation
		clr.b	r_Start_Fall.w			; Clear the flag
		
		lea	SampleList+$110,a3
		jsr	PlayDAC1

.Finalize:
		; --- Finalize initialzation ---
		
		clr.b	r_Lvl_Reload.w			; Clear the level reload flag
		
		displayOn				; Enable display
		jsr	FadeFromBlack.w			; Fade from black
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Main loop
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.Loop:
		move.b	#vLevel,r_VINT_Rout.w		; Level V-INT routine
		jsr	ProcessKos.w			; Process Kosinski queue
		jsr	VSync_Routine.w			; V-SYNC

		jsr	CheckPause.w			; Check for pausing
		addq.w	#1,r_Lvl_Frames.w		; Increment frame counter

		jsr	UpdateOscillation.w		; Update oscillation

		bsr.w	Level_RingsManager		; Run the ring manager
		jsr	ObjectManager.w			; Run the object manager
		
		jsr	RunObjects.w			; Run objects
		
		tst.b	r_Lvl_Reload.w			; Does the level need to be reloaded?
		bne.w	Level				; If so, branch

		bsr.w	Level_HandleCamera		; Handle the camera
		bsr.w	Level_UpdatePlanes		; Update the planes (draw new tiles and scroll)
		bsr.w	Level_UpdateWaterSurface	; Update the water surface

		jsr	RenderObjects.w			; Render objects
		
		bsr.w	Level_WaterHeight		; Update water height
		bsr.w	Level_AnimateArt		; Animate level art
		bsr.w	Level_PalCycle			; Do palette cycling
		bsr.w	Level_DynEvents			; Run dynamic events

		subq.b	#1,r_Ring_Ani_Time.w		; Decrement ring animation timer
		bpl.s	.NoRingAni			; If it hasn't run out, branch
		move.b	#3,r_Ring_Ani_Time.w		; Reset animation timer
		addq.b	#1,r_Ring_Frame.w		; Next ring frame
		andi.b	#7,r_Ring_Frame.w		; Limit it

		moveq	#0,d0
		move.b	r_Ring_Frame.w,d0		; Get ring frame
		lsl.w	#7,d0				; Convert to offset
		move.l	#ArtUnc_Ring,d1			; Source address
		add.l	d0,d1				; ''
		move.w	#$D780,d2			; VRAM address
		move.w	#$80/2,d3			; Size
		jsr	QueueDMATransfer.w		; Queue a transfer

.NoRingAni:
		tst.b	r_RLoss_Ani_T.w
		beq.s	.NoRingLossAni
		moveq	#0,d0
		move.b	r_RLoss_Ani_T.w,d0
		add.w	r_RLoss_Ani_A.w,d0
		move.w	d0,r_RLoss_Ani_A.w
		rol.w	#8,d0
		andi.w	#7,d0
		move.b	d0,r_RLoss_Ani_F.w
		subq.b	#1,r_RLoss_Ani_T.w

		moveq	#0,d0
		move.b	r_RLoss_Ani_F.w,d0		; Get ring frame
		lsl.w	#7,d0				; Convert to offset
		move.l	#ArtUnc_Ring,d1			; Source address
		add.l	d0,d1				; ''
		move.w	#$D680,d2			; VRAM address
		move.w	#$80/2,d3			; Size
		jsr	QueueDMATransfer.w		; Queue a transfer

.NoRingLossAni:
		jsr	ProcessKosM.w			; Process Kosinski Moduled queue

		cmpi.b	#gLevel,r_Game_Mode.w		; Is the game mode level?
		beq.w	.Loop				; If so, branch
		jmp	GotoGameMode.w			; Go to the correct game mode
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Level functions
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
		include	"Level/Level Drawing.asm"
		include	"Level/Level Collision.asm"
		include	"Level/Level Functions.asm"
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Music IDs
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
Level_MusicIDs:
		dc.b	mWWZ, mWWZ
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Level water heights (-1 for no water)
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
Level_WaterLevels:
		;dc.w	$490, -1			; Wacky Workbench
		dc.w	-1, -1
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Level data pointers
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; FORMAT:
;	dc.l	CHUNKS, BLOCKS, TILES, PALETTE
;	dc.l	LAYOUT, OBJECTS, RINGS, COLLISION
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
Level_DataPointers:
		dc.l	WWZ_Chunks, WWZ_Blocks,  WWZ_Tiles, WWZ_Pal
		dc.l	WWZ_Layout, WWZ_Objects, WWZ_Rings, WWZ_Collision
		dc.l	WWZ_Chunks, WWZ_Blocks,  WWZ_Tiles, WWZ_Pal
		dc.l	WWZ_Layout, WWZ_Objects, WWZ_Rings, WWZ_Collision
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Size and start position data
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
Level_SizeStartPos:
		dc.w	$3000, $580
		incbin	"Level/Level Data/Wacky Workbench/Start Position.bin"
		dc.w	$3000, $580
		incbin	"Level/Level Data/Wacky Workbench/Start Position.bin"
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Dynamic events routines
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
Level_DynEvenRouts:
		dc.l	DynEv_WWZ			; Wacky Workbench
		dc.l	DynEv_WWZ
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Wacky Workbench dynamic events routine
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
DynEv_WWZ:
		moveq	#0,d0
		move.b	r_Dyn_Ev_Rout.w,d0
		move.w	.Index(pc,d0.w),d0
		jmp	.Index(pc,d0.w)
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.Index:
		dc.w	.WaitBoss-.Index
		dc.w	.Done-.Index
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.WaitBoss:
		cmpi.w	#$2EE0,r_Cam_X.w
		blt.s	.Done
		move.w	#$340,r_Min_Cam_Y.w
		move.w	#$340,r_Dest_Max_Y.w
		move.w	#$2EE0,r_Min_Cam_X.w
		move.w	#$2EE0,r_Max_Cam_X.w
		addq.b	#2,r_Dyn_Ev_Rout.w

.Done:
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Palette cycle routines
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
Level_PalCycRouts:
		dc.l	PalCycle_WWZ			; Wacky Workbench
		dc.l	PalCycle_WWZ
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Wacky Workbench palette cycle routine
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
PalCycle_WWZ:
		tst.b	r_Floor_Active.w		; Is the floor active?
		bne.s	.Flash				; If so, branch

		subq.w	#1,r_Floor_Timer.w		; Decrement the floor timer
		bpl.s	.ResetPal			; If it hasn't run out, branch
		st	r_Floor_Active.w		; Set the floor active flag
		move.w	#180,r_Floor_Timer.w		; Set the floor timer

.ResetPal:
		clr.w	r_PalCyc_Timer.w		; Reset the palette cycle
		move.w	#$C28,(r_Palette+$62).w		; Set the floor color to be deactivated
		move.w	#$E48,(r_Water_Pal+$62).w	; ''
		rts

.Flash:
		subq.w	#1,r_Floor_Timer.w		; Decrement the floor timer
		bpl.s	.UpdatePal			; If it hasn't run out, branch
		clr.b	r_Floor_Active.w		; Clear the floor active flag
		move.w	#30,r_Floor_Timer.w		; Set the floor timer

.UpdatePal:
		subq.b	#1,r_PalCyc_Timer.w		; Decrement the palette cycle timer
		bpl.s	.End				; If it hasn't run out, branch
		move.b	#1,r_PalCyc_Timer.w		; Reset the palette cycle timer

		moveq	#0,d0
		move.b	r_PalCyc_Index.w,d0		; Get the palette cycle index
		add.w	d0,d0				; Turn into offset
							; Set the floor color
		move.w	PalCyc_WWZFloor(pc,d0.w),(r_Palette+$62).w
		move.w	PalCyc_WWZFloorUW(pc,d0.w),(r_Water_Pal+$62).w
		
		addq.b	#1,r_PalCyc_Index.w		; Increment the palette cycle index
		cmpi.b	#5,r_PalCyc_Index.w		; Has it reached the end of the cycle?
		bcs.s	.End				; If not, branch
		clr.b	r_PalCyc_Index.w		; Reset the palette cycle index

.End:
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
PalCyc_WWZFloor:
		dc.w	$C28, $000, $0EE, $000, $EEE
PalCyc_WWZFloorUW:
		dc.w	$E48, $220, $2EE, $220, $EEE
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Animated art routines
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
Level_AniArtRouts:
		dc.l	AniArt_WWZ			; Wacky Workbench
		dc.l	AniArt_WWZ
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Wacky Workbench animated art routine
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
AniArt_WWZ:
		lea	.AniData(pc),a2			; Tutorial animated art data
		bra.w	AniArt_DoAnimate		; Handle animations
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.AniData:
		dc.w	2

		lvlAniDat 3, ArtUnc_Electricity, $162, 4, 8
		dc.b	0, 8, $10, $18

		lvlAniDat 1, ArtUnc_ElectricOrbs, $15E, $E, 4
		dc.b	0, 4, 4, 0, 4, 4, 8, 4, 4, 8, $C, 4, 4, $C

		lvlAniDat 4, ArtUnc_Sirens, $A8, 8, 4
		dc.b	0, 4, 4, 8, $C, $C, $C, $C
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Level drawing initialization and update routines
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; PARAMETERS:
;	a1.l	- Camera RAM
;	a3.l	- Row plane buffer
;	a4.l	- Column plane buffer
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; RETURNS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
Level_RenderRouts:
		dc.l	General_InitFG			; Wacky Workbench
		dc.l	WWZ_InitBG
		dc.l	General_UpdateFG
		dc.l	WWZ_UpdateBG
		dc.l	General_InitFG
		dc.l	WWZ_InitBG
		dc.l	General_UpdateFG
		dc.l	WWZ_UpdateBG
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Wacky Workbench background initialization
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
WWZ_InitBG:
		lea	r_FG_Cam.w,a2			; Get foreground camera RAM
		move.w	cY(a2),d0			; Get foreground Y position
		asr.w	#2,d0				; Divide by $20
		move.w	d0,cY(a1)			; Set as background Y position

		bsr.w	Level_RefreshPlane		; Refresh the plane

		lea	WWZ_Scroll(pc),a3		; Get background scroll data
		bra.w	ScrollSections			; Scroll the planes
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Wacky Workbench background update
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
WWZ_UpdateBG:
		lea	r_FG_Cam.w,a2			; Get foreground camera RAM
		move.w	cY(a2),d0			; Get foreground Y position
		asr.w	#2,d0				; Divide by $20
		move.w	d0,cY(a1)			; Set as background Y position

		bsr.w	Level_ChkRedrawPlane		; Check if the plane needs to be redrawn
		moveq	#(512/16)-1,d4			; Number of blocks per column
		bsr.w	Level_UpdatePlaney		; Update the plane

		lea	WWZ_Scroll(pc),a3		; Get background scroll data
		bra.w	ScrollSections			; Scroll the planes
; --------------------------------------------------------------------------------------------------------------------------------------
		scrollInit WWZ_Scroll

		; CEILING LIGHTS
		scrollSection	 48, $80
		scrollSection	 32, $60
		scrollSection	 32, $50
		scrollSection	 24, $40
		scrollSection	 24, $38
		scrollSection	 16, $30
		scrollSection	 16, $2C
		scrollSection	 16, $28
		scrollSection	 16, $24
		scrollSection	 16, $20

		; BACK WALL
		scrollSection	160, $40

		; FRONT WALL
		scrollSection	368, $80

		scrollEnd
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Wacky Workbench level data
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
WWZ_Layout:
		incbin	"Level/Level Data/Wacky Workbench/Layout.bin"
		even
WWZ_Chunks:
		incbin	"Level/Level Data/Wacky Workbench/Chunks.bin"
		even
WWZ_Blocks:
		incbin	"Level/Level Data/Wacky Workbench/Blocks.bin"
		even
WWZ_Tiles:
		incbin	"Level/Level Data/Wacky Workbench/Tiles.kosm.bin"
		even
		dc.w	$FFFF, 0, 0
WWZ_Objects:
		incbin	"Level/Level Data/Wacky Workbench/Objects.bin"
		even
WWZ_Rings:
		incbin	"Level/Level Data/Wacky Workbench/Rings.bin"
		even
WWZ_Pal:
		dc.w	$100>>1-1
		incbin	"Level/Level Data/Wacky Workbench/Palette.pal.bin"
		incbin	"Level/Level Data/Wacky Workbench/Palette (Water).pal.bin"
		even
WWZ_Collision:
		dc.l	.ColData, .Angles, .Heights, .HeightsR
.ColData:
		incbin	"Level/Level Data/Wacky Workbench/Collision.bin"
		even
.Angles:
		incbin	"Level/Level Data/Wacky Workbench/Angle Values.bin"
		even
.Heights:
		incbin	"Level/Level Data/Wacky Workbench/Height Values.bin"
		even
.HeightsR:
		incbin	"Level/Level Data/Wacky Workbench/Height Values (Rotated).bin"
		even
ArtUnc_Electricity:
		incbin	"Level/Level Data/Wacky Workbench/Electricity.bin"
		even
ArtUnc_ElectricOrbs:
		incbin	"Level/Level Data/Wacky Workbench/Electric Orbs.bin"
		even
ArtUnc_Sirens:
		incbin	"Level/Level Data/Wacky Workbench/Sirens.bin"
		even
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Main level PLCs
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
PLC_LevelMain:
		dc.w	$A
		dc.l	ArtKosM_Chkpoint
		dc.w	$AFC0
		dc.l	ArtKosM_Monitor
		dc.w	$B100
		dc.l	ArtKosM_SpringH
		dc.w	$B740
		dc.l	ArtKosM_SpringV
		dc.w	$B940
		dc.l	ArtKosM_SpringD
		dc.w	$BB20
		dc.l	ArtKosM_HUD
		dc.w	$D000
		dc.l	ArtKosM_WaterSurface
		dc.w	$D200
		dc.l	ArtKosM_SpikesN
		dc.w	$D500
		dc.l	ArtKosM_SpikesS
		dc.w	$D580
		dc.l	ArtKosM_RingSparkle
		dc.w	$D700
		dc.l	ArtKosM_Explosion
		dc.w	$D800
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Level PLCs
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
Level_PLCs:
		dc.l	PLC_WWZ
		dc.l	PLC_WWZ
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Wacky Workbench PLCs
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
PLC_WWZ:
		dc.w	8
		dc.l	ArtKosM_Bumper
		dc.w	$6B60
		dc.l	ArtKosM_Orbinaut
		dc.w	$71A0
		dc.l	ArtKosM_Diamond
		dc.w	$7580
		dc.l	ArtKosM_CNZBarrel
		dc.w	$7A00
		dc.l	ArtKosM_Slicer
		dc.w	$8000
		dc.l	ArtKosM_ShlCrker
		dc.w	$8400
		dc.l	ArtKosM_Asteron
		dc.w	$8880
		dc.l	ArtKosM_Harpoon
		dc.w	$8A60
		dc.l	ArtKosM_WFZBoss
		dc.w	$9000
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Art
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ArtKosM_HUD:
		incbin	"Level/Objects/HUD/Art - HUD Base.kosm.bin"
		even
ArtKosM_RingSparkle:
		incbin	"Level/Objects/Ring/Art - Sparkle.kosm.bin"
		even
ArtUnc_Ring:
		incbin	"Level/Objects/Ring/Art - Ring.unc.bin"
		even
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Object index
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
Level_ObjIndex:
		dc.l	ObjMonitor
		dc.l	ObjSpike
		dc.l	ObjSpring
		dc.l	ObjCheckpoint
		dc.l	ObjSlicer
		dc.l	ObjShlCrker
		dc.l	ObjAsteron
		dc.l	ObjWFZBoss
		dc.l	ObjWallSpring
		dc.l	ObjHarpoon
		dc.l	ObjBallMode
		dc.l	ObjBumper
		dc.l	ObjCNZBarrel
		dc.l	ObjDiamond
		dc.l	ObjOrbinaut
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Objects
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
		include	"Level/Objects/Sonic/Code.asm"		; Sonic object
		include	"Level/Objects/Ring/Code.asm"		; Ring loss object
		include	"Level/Objects/Explosion/Code.asm"	; Explosion object
		include	"Level/Objects/Monitor/Code.asm"	; Monitor object
		include	"Level/Objects/Spikes/Code.asm"		; Spike object
		include	"Level/Objects/Checkpoint/Code.asm"	; Checkpoint object
		include	"Level/Objects/Spring/Code.asm"		; Spring object
		include	"Level/Objects/Water Surface/Code.asm"	; Water surface object
		include	"Level/Objects/Slicer/Code.asm"		; Slicer object
		include	"Level/Objects/Shellcracker/Code.asm"	; Shellcracker object
		include	"Level/Objects/Asteron/Code.asm"	; Asteron object
		include	"Level/Objects/Harpoon/Code.asm"	; Harpoon object
		include	"Level/Objects/Wall Spring/Code.asm"	; Wall spring object
		include	"Level/Objects/Ball Mode/Code.asm"	; Ball mode switch object
		include	"Level/Objects/Bumper/Code.asm"		; Bumper object
		include	"Level/Objects/CNZ Barrel/Code.asm"	; CNZ barrel object
		include	"Level/Objects/Diamond/Code.asm"	; Diamond object
		include	"Level/Objects/Orbinaut/Code.asm"	; Orbinaut object
		include	"Level/Objects/Boss - WFZ/Code.asm"	; WFZ boss object
; =========================================================================================================================================================