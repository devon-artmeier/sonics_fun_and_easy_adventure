; =========================================================================================================================================================
; Sonic's Fun And Easy Adventure
; By Ralakimus/Novedicus 2017
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Asteron object
; =========================================================================================================================================================
		rsset	oLvlSSTs
oStarTime	rs.b	1				; Timer
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjAsteron:
		moveq	#0,d0
		move.b	oRoutine(a0),d0			; Get routine ID
		move.w	.Index(pc,d0.w),d0		; Get routine offset
		jsr	.Index(pc,d0.w)			; Jump to it
		jmp	AddToColResponse		; Allow collision
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.Index:
		dc.w	ObjAsteron_Init-.Index		; Initialization
		dc.w	ObjAsteron_Main-.Index		; Main
		dc.w	ObjAsteron_Speed-.Index		; Get speed
		dc.w	ObjAsteron_Explode-.Index	; Explode
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjAsteron_Init:
		addq.b	#2,oRoutine(a0)			; Next routine
		move.l	#Map_ObjAsteron,oMap(a0)	; Mappings
		move.w	#$8444,oVRAM(a0)		; Tile properties
		move.b	#4,oRender(a0)			; Render flags
		move.w	#r_Spr_Input+$200,oPrio(a0)	; Priority
		move.b	#$10,oDrawW(a0)			; Sprite width
		move.b	#$10,oDrawH(a0)			; Sprite height
		move.b	#2,oColType(a0)			; Enemy
		move.b	#$C,oColW(a0)			; Collision width
		move.b	#$C,oColH(a0)			; Collision height
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjAsteron_Main:
		jsr	GetOrientToPlayer.w		; Get orientation to the player
		addi.w	#$60,d2				; Center horizontal distance
		cmpi.w	#$C0,d2				; Is the player in range horizontally?
		bhs.s	.Display			; If not, branch
		addi.w	#$40,d3				; Center vertical distance
		cmpi.w	#$80,d3				; Is the player in range vertically?
		blo.s	.DoMove				; If so, branch

.Display:
		jmp	CheckObjActive_Draw.w		; Display

.DoMove:
		addq.b	#2,oRoutine(a0)			; Next routine
		jmp	CheckObjActive_Draw.w		; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjAsteron_Speed:
		jsr	GetOrientToPlayer.w		; Get orientation to the player
		tst.w	d2				; Get absolute value of horizontal distance
		bpl.s	.ChkXRange			; ''
		neg.w	d2				; ''

.ChkXRange:
		cmpi.w	#$10,d2				; Is Sonic in range?
		blo.s	.ChkY				; If not, branch
		cmpi.w	#$60,d2				; Is Sonic in range?
		bhs.s	.ChkY				; If not, branch
		move.w	.Speeds(pc,d0.w),oXVel(a0)	; Set X velocity
		bsr.s	.DoExplode			; Set to explode

.ChkY:
		tst.w	d3				; Get absolute value of vertical distance
		bpl.s	.ChkYRange			; ''
		neg.w	d3				; ''

.ChkYRange:
		cmpi.w	#$10,d3				; Is Sonic in range?
		blo.s	.Display			; If not, branch
		cmpi.w	#$60,d3				; Is Sonic in range?
		bhs.s	.Display			; If not, branch
		move.w	.Speeds(pc,d1.w),oYVel(a0)	; Set Y velocity
		bsr.s	.DoExplode			; Set to explode

.Display:
		jmp	CheckObjActive_Draw.w		; Display

.DoExplode:
		move.b	#6,oRoutine(a0)			; Next routine
		move.b	#$40,oStarTime(a0)		; Set timer
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.Speeds:
		dc.w	-$40, $40
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjAsteron_Explode:
		subq.b	#1,oStarTime(a0)		; Decrement timer
		bmi.s	.Explode			; If it has run out, branch
		jsr	ObjectMove.w			; Move
		lea	Ani_ObjAsteron,a1		; Animate
		jsr	AnimateObject.w			; ''
		jmp	CheckObjActive_Draw.w		; Display

.Explode:
		move.l	#ObjExplosion,oAddr(a0)		; Explode

		moveq	#4,d6				; Number of projetiles
		lea	.ProjStats(pc),a2		; Projectile stats
		bsr.s	.CreateProjectiles		; Create projectiles

		jmp	CheckObjActive_Draw.w		; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.ProjStats:
		dc.b	$00, $F8, $00, $FC, $02, $00
		dc.b	$08, $FC, $03, $FF, $03, $01
		dc.b	$08, $08, $03, $03, $04, $01
		dc.b	$F8, $08, $FD, $03, $04, $00
		dc.b	$F8, $FC, $FD, $FF, $03, $00
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.CreateProjectiles:
		moveq	#0,d1				; Object index

.Loop:
		jsr	FindNextFreeObj.w		; Find a free object slot
		bne.s	.End				; If there is none, branch
		move.l	#ObjAsteronProj,oAddr(a1)	; Load projectile
		move.w	oX(a0),oX(a1)			; X position
		move.w	oY(a0),oY(a1)			; Y position
		lea	(a2,d1.w),a3			; Get address in list
		move.b	(a3)+,d0			; Get X offset
		ext.w	d0				; ''
		add.w	d0,oX(a1)			; Add X offset
		move.b	(a3)+,d0			; Get Y offset
		ext.w	d0				; ''
		add.w	d0,oY(a1)			; Add Y offset
		move.b	(a3)+,oXVel(a1)			; X velocity
		move.b	(a3)+,oYVel(a1)			; Y velocity
		move.b	(a3)+,oFrame(a1)		; Map frame
		move.b	(a3)+,oRender(a1)		; Render flags

		addq.w	#6,d1				; Next object
		dbf	d6,.Loop			; Loop

.End:
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Asteron projectile
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjAsteronProj:
		moveq	#0,d0
		move.b	oRoutine(a0),d0			; Get routine ID
		move.w	.Index(pc,d0.w),d0		; Get routine offset
		jsr	.Index(pc,d0.w)			; Jump to it
		jmp	AddToColResponse		; Allow collision
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.Index:
		dc.w	ObjAsteronProj_Init-.Index	; Initialization
		dc.w	ObjAsteronProj_Main-.Index	; Main
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjAsteronProj_Init:
		addq.b	#2,oRoutine(a0)			; Next routine
		move.l	#Map_ObjAsteron,oMap(a0)	; Mappings
		move.w	#$8444,oVRAM(a0)		; Tile properties
		ori.b	#$84,oRender(a0)		; Render flags
		move.w	#r_Spr_Input+$200,oPrio(a0)	; Priority
		move.b	#4,oDrawW(a0)			; Sprite width
		move.b	#4,oDrawH(a0)			; Sprite height
		move.b	#4,oColType(a0)			; Indestructable
		move.b	#4,oColW(a0)			; Collision width
		move.b	#4,oColH(a0)			; Collision height
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjAsteronProj_Main:
		tst.b	oRender(a0)			; Are we on screen?
		bpl.s	.Delete				; If not, branch
		jsr	ObjectMove.w			; Move
		jmp	CheckObjActive_Draw.w		; Display

.Delete:
		jmp	DeleteObject.w			; Delete ourselves
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Data
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
Map_ObjAsteron:
		include	"Level/Objects/Asteron/Mappings.asm"
		even
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
Ani_ObjAsteron:
		dc.w	.Ani0-Ani_ObjAsteron
.Ani0:		dc.b	1, 0, 1, $FF
		even
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ArtKosM_Asteron:
		incbin	"Level/Objects/Asteron/Art.kosm.bin"
		even
; =========================================================================================================================================================