; =========================================================================================================================================================
; Sonic's Fun And Easy Adventure
; By Ralakimus/Novedicus 2017
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Water surface object
; =========================================================================================================================================================
		rsset	oLvlSSTs

; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjBumper:
		moveq	#0,d0
		move.b	oRoutine(a0),d0			; Get routine ID
		move.w	.Index(pc,d0.w),d0		; Get routine pointer
		jsr	.Index(pc,d0.w)			; Jump to it
		jmp	AddToColResponse		; Allow collision
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.Index:
		dc.w	ObjBumper_Init-.Index
		dc.w	ObjBumper_Main-.Index
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjBumper_Init:
		addq.b	#2,oRoutine(a0)			; Next routine
		move.l	#Map_ObjBumper,oMap(a0)		; Mappings
		move.w	#$35B,oVRAM(a0)			; Tile properties
		move.b	#4,oRender(a0)			; Render flags
		move.w	#r_Spr_Input+$80,oPrio(a0)	; Priority
		move.b	#$10,oDrawW(a0)			; Sprite width
		move.b	#$10,oDrawH(a0)			; Sprite height
		move.b	#$10,oColW(a0)			; Collision width
		move.b	#$10,oColH(a0)			; Collision height
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjBumper_Main:
		tst.b	r_Debug_Mode.w
		bne.w	.Display

		lea	.RangeData(pc),a1		; Range data
		lea	r_Obj_Player.w,a2		; Player object
		cmpi.b	#6,oRoutine(a2)
		bcc.w	.Display
		jsr	CheckObjInRange.w		; Is the player in range?
		tst.w	d0				; ''
		beq.s	.Display			; If not, branch

		move.w	oX(a0),d1
		move.w	oY(a0),d2
		sub.w	oX(a2),d1
		sub.w	oY(a2),d2
		jsr	CalcArcTan.w
		move.b	(r_Frame_Cnt+3).w,d1
		andi.w	#3,d1
		add.w	d1,d0
		jsr	CalcSine.w
		muls.w	#-$700,d1
		asr.l	#8,d1
		move.w	d1,oXVel(a2)
		muls.w	#-$700,d0
		asr.l	#8,d0
		move.w	d0,oYVel(a2)
		cmpi.b	#4,oRoutine(a2)
		bne.s	.NotHurt
		move.b	#2,oAni(a2)
		addq.w	#5,oY(a2)
		move.b	#$E,oColH(a2)
		move.b	#7,oColW(a2)
		bset	#2,oStatus(a2)

.NotHurt:
		move.b	#2,oRoutine(a2)
		bset	#1,oStatus(a2)
		bclr	#5,oStatus(a2)
		clr.b	oJumping(a2)
		move.b	#1,oAni(a0)
		playSnd	#sBumper, 2

.Display:
		lea	Ani_ObjBumper(pc),a1
		jsr	AnimateObject.w
		jmp	CheckObjActive_Draw.w		; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.RangeData:
		dc.w	-$18, $30
		dc.w	-$18, $30
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Data
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
Map_ObjBumper:
		include	"Level/Objects/Bumper/Mappings.asm"
		even
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
Ani_ObjBumper:
		dc.w	.Ani0-Ani_ObjBumper
		dc.w	.Ani1-Ani_ObjBumper
.Ani0:		dc.b	5, 0, $FF, 0
.Ani1:		dc.b	5, 1, 2, 1, 2, $FD, 0
		even
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ArtKosM_Bumper:
		incbin	"Level/Objects/Bumper/Art.kosm.bin"
		even
; =========================================================================================================================================================