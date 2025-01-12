; =========================================================================================================================================================
; Sonic's Fun And Easy Adventure
; By Ralakimus/Novedicus 2017
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Water surface object
; =========================================================================================================================================================
		rsset	oLvlSSTs

; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjRingLoss:
		moveq	#0,d0
		move.b	oRoutine(a0),d0			; Get routine ID
		move.w	.Index(pc,d0.w),d0		; Get routine pointer
		jmp	.Index(pc,d0.w)			; Jump to it
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.Index:
		dc.w	ObjRingLoss_Init-.Index
		dc.w	ObjRingLoss_Main-.Index
		dc.w	ObjRingLoss_Collect-.Index
		dc.w	ObjRingLoss_Sparkle-.Index
		dc.w	ObjRingLoss_Delete-.Index
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjRingLoss_Init:
		movea.l	a0,a1
		moveq	#0,d5
		move.w	r_Rings.w,d5
		moveq	#32,d0
		cmp.w	d0,d5
		bcs.s	.BelowMax
		move.w	d0,d5

.BelowMax:
		subq.w	#1,d5
		move.w	#$288,d4
		bra.s	.MakeRings

.Loop:
		jsr	FindFreeObj.w
		bne.w	.ResetCounter

.MakeRings:
		move.l	oAddr(a0),oAddr(a1)
		addq.b	#2,oRoutine(a1)			; Next routine
		move.w	oX(a0),oX(a1)
		move.w	oY(a0),oY(a1)
		move.l	#Map_ObjRingLoss,oMap(a1)	; Mappings
		move.w	#$26B4,oVRAM(a1)		; Tile properties
		move.b	#4,oRender(a1)			; Render flags
		move.w	#r_Spr_Input+$180,oPrio(a1)	; Priority
		move.b	#8,oDrawW(a1)			; Sprite width
		move.b	#8,oDrawH(a1)			; Sprite height
		move.b	#8,oColW(a1)			; Collision width
		move.b	#8,oColH(a1)			; Collision height
		move.b	#-1,r_RLoss_Ani_T.w
		tst.w	d4
		bmi.s	.DoLoop
		move.w	d4,d0
		jsr	CalcSine.w
		move.w	d4,d2
		lsr.w	#8,d2
		asl.w	d2,d0
		asl.w	d2,d1
		move.w	d0,d2
		move.w	d1,d3
		addi.b	#$10,d4
		bcc.s	.DoLoop
		subi.w	#$80,d4
		bcc.s	.DoLoop
		move.w	#$288,d4

.DoLoop:
		move.w	d2,oXVel(a1)
		move.w	d3,oYVel(a1)
		neg.w	d2
		neg.w	d4
		dbf	d5,.Loop

.ResetCounter:
		clr.w	r_Rings.w
		move.b	#1,r_Update_Rings.w
		playSnd	#sRingLoss, 2
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjRingLoss_Main:
		jsr	ObjectMove.w
		addi.w	#$18,oYVel(a0)
		bmi.s	.ChkCol
		move.b	(r_Frame_Cnt+3).w,d0
		add.b	d7,d0
		andi.b	#3,d0
		bne.s	.ChkCol
		jsr	ObjCheckFloorDist
		tst.w	d1
		bpl.s	.ChkCol
		add.w	d1,oY(a0)
		move.w	oYVel(a0),d0
		asr.w	#2,d0
		sub.w	d0,oYVel(a0)
		neg.w	oYVel(a0)

.ChkCol:
		lea	.RangeData(pc),a1		; Range data
		lea	r_Obj_Player.w,a2		; Player object
		jsr	CheckObjInRange.w		; Is the player in range?
		tst.w	d0				; ''
		beq.s	.ChkDel				; If not, branch
		cmpi.b	#105,(r_Obj_Player+oInvulTime).w
		bhs.s	.ChkDel
		addq.b	#2,oRoutine(a0)
		bra.s	ObjRingLoss_Collect

.ChkDel:
		tst.b	r_RLoss_Ani_T.w
		beq.s	ObjRingLoss_Delete
		move.w	r_Max_Cam_Y.w,d0		; Get max camera Y position
		addi.w	#224,d0				; Get bottom boundary position
		cmp.w	oY(a0),d0			; Have we touched the bottom boundary?
		blt.s	ObjRingLoss_Delete		; If so, branch
		jmp	DisplayObject.w			; Display the object
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.RangeData:
		dc.w	-$10, $20
		dc.w	-$10, $20
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjRingLoss_Collect:
		addq.b	#2,oRoutine(a0)
		move.w	#r_Spr_Input+$80,oPrio(a0)
		jsr	CollectRing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjRingLoss_Sparkle:
		lea	Ani_ObjRing,a1
		jsr	AnimateObject.w
		jmp	DisplayObject.w
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjRingLoss_Delete:
		jmp	DeleteObject.w
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Data
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
Map_ObjRingLoss:
		include	"Level/Objects/Ring/Mappings.asm"
		even
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
Ani_ObjRing:
		dc.w	.Ani0-Ani_ObjRing
.Ani0:		dc.b	5, 1, 2, 3, 4, $FC
		even
; =========================================================================================================================================================