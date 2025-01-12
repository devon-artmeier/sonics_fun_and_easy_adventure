; =========================================================================================================================================================
; Sonic's Fun And Easy Adventure
; By Ralakimus/Novedicus 2017
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Slicer object
; =========================================================================================================================================================
		rsset	oLvlSSTs
oSlicTime	rs.w	1				; Timer
oSlicPar	rs.w	1				; Parent object
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjSlicer:
		moveq	#0,d0
		move.b	oRoutine(a0),d0			; Get routine ID
		move.w	.Index(pc,d0.w),d0		; Get routine offset
		jsr	.Index(pc,d0.w)			; Jump to it
		jmp	AddToColResponse		; Allow collision
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.Index:
		dc.w	ObjSlicer_Init-.Index		; Initialization
		dc.w	ObjSlicer_Main-.Index		; Main
		dc.w	ObjSlicer_Turn-.Index		; Turn around
		dc.w	ObjSlicer_Throw-.Index		; Throw
		dc.w	ObjSlicer_Done-.Index		; Done
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjSlicer_Init:
		addq.b	#2,oRoutine(a0)			; Next routine
		move.l	#Map_ObjSlicer,oMap(a0)		; Mappings
		move.w	#$8400,oVRAM(a0)		; Tile properties
		move.b	#4,oRender(a0)			; Render flags
		move.w	#r_Spr_Input+$280,oPrio(a0)	; Priority
		move.b	#$10,oDrawW(a0)			; Sprite width
		move.b	#$10,oDrawH(a0)			; Sprite height
		move.b	#2,oColType(a0)			; Enemy

		move.w	#-$40,d0			; X velocity
		btst	#0,oRender(a0)			; Are we faced to the left?
		beq.s	.SetXVel			; If so, branch
		neg.w	d0				; Negate the X velocity

.SetXVel:
		move.w	d0,oXVel(a0)			; Set the X velocity
		move.b	#$10,oColW(a0)			; Collision width
		move.b	#$10,oColH(a0)			; Collision height
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjSlicer_Main:
		tst.b	oRender(a0)			; Are we on screen?
		bpl.s	.DoFloorCol			; If not, branch
		jsr	GetOrientToPlayer.w		; Get orientation to the player
		btst	#0,oRender(a0)			; Are we faced left?
		beq.s	.ChkRange			; If so, branch
		subq.w	#2,d0				; Fix horizontal orientation flag

.ChkRange:
		tst.w	d0				; Are we facing the player?
		bne.s	.DoFloorCol			; If not, branch
		addi.w	#$80,d2				; Center horizontal distance
		cmpi.w	#$100,d2			; Is the player in range horizontally?
		bhs.s	.DoFloorCol			; If not, branch
		addi.w	#$40,d3				; Center vertical distance
		cmpi.w	#$80,d3				; Is the player in range vertically?
		blo.s	.DoThrow			; If so, branch

.DoFloorCol:
		jsr	ObjectMove.w			; Move
		jsr	ObjCheckFloorDist		; Get distance to floor
		cmpi.w	#-8,d1				; Are we at a ledge?
		blt.s	.DoWait				; If so, branch
		cmpi.w	#$C,d1				; Are we at a ledge?
		bge.s	.DoWait				; If so, branch
		add.w	d1,oY(a0)			; Align to floor

		lea	Ani_ObjSlicer,a1		; Animate
		jsr	AnimateObject.w			; ''
		jmp	CheckObjActive_Draw.w		; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.DoWait:
		addq.b	#2,oRoutine(a0)			; Next routine
		move.b	#$3B,oSlicTime(a0)		; Set timer
		jmp	CheckObjActive_Draw.w		; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.DoThrow:
		addq.b	#4,oRoutine(a0)			; Next routine
		move.b	#3,oFrame(a0)			; Set map frame
		move.b	#8,oSlicTime(a0)		; Set timer
		jmp	CheckObjActive_Draw.w		; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjSlicer_Turn:
		subq.b	#1,oSlicTime(a0)		; Decrement the timer
		bmi.s	.Turn				; If it has run out, branch
		jmp	CheckObjActive_Draw.w		; Display

.Turn:
		subq.b	#2,oRoutine(a0)			; Previous routine
		neg.w	oXVel(a0)			; Turn around
		bchg	#0,oStatus(a0)			; Face the other way
		jmp	CheckObjActive_Draw.w		; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjSlicer_Throw:
		subq.b	#1,oSlicTime(a0)		; Decrement the timer
		bmi.s	.Throw				; If it has run out, branch
		jmp	CheckObjActive_Draw.w		; Display

.Throw:
		addq.b	#2,oRoutine(a0)			; Next routine
		move.b	#4,oFrame(a0)			; Set map frame
		bsr.s	ObjSlicer_LoadPincers		; Load the pincers
		jmp	CheckObjActive_Draw.w		; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjSlicer_Done:
		jmp	CheckObjActive_Draw.w		; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Load the pincers
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjSlicer_LoadPincers:
		moveq	#0,d1				; Offset index
		moveq	#1,d6				; Number of pincers to load

.LoadLoop:
		jsr	FindNextFreeObj.w		; Find a free object slot
		bne.s	.End				; If there are none, branch
		move.l	#ObjPincers,oAddr(a1)		; Load the pincers
		move.b	oRender(a0),oRender(a1)		; Render flags
		move.b	#5,oFrame(a1)			; Map frame
		move.w	#r_Spr_Input+$200,oPrio(a1)	; Priority
		move.w	a0,oSlicPar(a1)			; Set parent object
		move.w	#$78,oSlicTime(a1)		; Timer
		move.w	#-$200,d0			; X velocity
		btst	#0,oRender(a1)			; Are they facing left?
		beq.s	.SetXVel			; If so, branch
		neg.w	d0				; Go to the right
		bset	#0,oStatus(a1)			; Face to the right

.SetXVel:
		move.w	d0,oXVel(a1)			; Set the X velocity

		lea	.Offsets(pc,d1.w),a3		; Get offsets
		move.b	(a3)+,d0			; Get X offset
		ext.w	d0				; ''
		btst	#0,oRender(a1)			; Are they facing left?
		beq.s	.SetXOff			; If so, branch
		neg.w	d0				; Go the other way

.SetXOff:
		add.w	oX(a0),d0			; Add X position
		move.w	d0,oX(a1)			; Set X position

		move.b	(a3)+,d0			; Get Y offset
		ext.w	d0				; ''
		add.w	oY(a0),d0			; Add Y position
		move.w	d0,oY(a1)			; Set Y position

		addq.w	#2,d1				; Next offset
		dbf	d6,.LoadLoop			; Loop

.End:
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.OFfsets:
		dc.b	 $06, $00
		dc.b	-$10, $00
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Slicer pincer object
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjPincers:
		moveq	#0,d0
		move.b	oRoutine(a0),d0			; Get routine ID
		move.w	.Index(pc,d0.w),d0		; Get routine offset
		jmp	.Index(pc,d0.w)			; Jump to it
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.Index:
		dc.w	ObjPincers_Init-.Index		; Initialization
		dc.w	ObjPincers_Main-.Index		; Main
		dc.w	ObjPincers_Fall-.Index		; Fall
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjPincers_Init:
		addq.b	#2,oRoutine(a0)			; Next routine
		move.l	#Map_ObjSlicer,oMap(a0)		; Mappings
		move.w	#$8400,oVRAM(a0)		; Tile properties
		move.b	#4,oRender(a0)			; Render flags
		move.w	#r_Spr_Input+$280,oPrio(a0)	; Priority
		move.b	#$10,oDrawW(a0)			; Sprite width
		move.b	#$10,oDrawH(a0)			; Sprite height
		move.b	#4,oColType(a0)			; Indestructable
		move.b	#$10,oColW(a0)			; Collision width
		move.b	#$10,oColH(a0)			; Collision height
		jmp	CheckObjActive_Draw.w		; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjPincers_Main:
		tst.b	oRender(a0)			; Have we gone offscreen?
		bpl.s	ObjPincers_Delete		; If so, branch

		subq.w	#1,oSlicTime(a0)		; Decrement timer
		bmi.s	.SetFall			; If it has run out, branch

		movea.w	oSlicPar(a0),a1			; Get parent object
		cmpi.l	#ObjSlicer,oAddr(a1)		; Is it a slicer?
		bne.s	.SetFall			; If not, branch

		jsr	GetOrientToPlayer.w		; Get orientation to the player
		move.w	.Accelerations(pc,d0.w),d2	; Get X acceleration
		add.w	d2,oXVel(a0)			; Apply it
		move.w	.Accelerations(pc,d1.w),d2	; Get Y acceleration
		add.w	d2,oYVel(a0)			; Apply it
		move.w	#$200,d0			; Max speed
		move.w	d0,d1				; ''
		jsr	CapObjSpeed.w			; Cap the speed
		jsr	ObjectMove.w			; Move

		jsr	AddToColResponse		; Allow collision

		lea	Ani_ObjPincers,a1		; Animate
		jsr	AnimateObject.w			; ''
		jmp	CheckObjActive_Draw.w		; Display

.SetFall:
		addq.b	#2,oRoutine(a0)			; Next routine
		move.w	#$60,oSlicTime(a0)		; Reset timer
		bra.s	ObjPincers_Fall			; Continue
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.Accelerations:
		dc.w	-$10, $10
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjPincers_Delete:
		jmp	DeleteObject.w			; Delete ourselves
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjPincers_Fall:
		subq.w	#1,oSlicTime(a0)		; Decrement timer
		bmi.s	ObjPincers_Delete		; If it has run out, branch

		jsr	ObjectMoveAndFall.w		; Move and fall

		lea	Ani_ObjPincers,a1		; Animate
		jsr	AnimateObject.w			; ''
		jmp	CheckObjActive_Draw.w		; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Data
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
Map_ObjSlicer:
		include	"Level/Objects/Slicer/Mappings.asm"
		even
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
Ani_ObjSlicer:
		dc.w	.Ani0-Ani_ObjSlicer
.Ani0:		dc.b	$13, 0, 2, $FF
		even
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
Ani_ObjPincers:
		dc.w	.Ani0-Ani_ObjPincers
.Ani0:		dc.b	3, 5, 6, 7, 8, $FF
		even
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ArtKosM_Slicer:
		incbin	"Level/Objects/Slicer/Art.kosm.bin"
		even
; =========================================================================================================================================================