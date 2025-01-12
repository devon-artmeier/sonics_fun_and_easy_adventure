; =========================================================================================================================================================
; Sonic's Fun And Easy Adventure
; By Ralakimus/Novedicus 2017
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Diamond object
; =========================================================================================================================================================
		rsset	oLvlSSTs
oDiamTimer	rs.b	1
oDiamBreak	rs.b	1
oDiamColor	rs.b	1
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjDiamond:
		move.l	#ObjDiamond_Main,oAddr(a0)	; Next routine
		move.l	#Map_ObjDiamond,oMap(a0)	; Mappings
		move.w	#$3AC,oVRAM(a0)			; Tile properties
		move.b	#4,oRender(a0)			; Render flags
		move.w	#r_Spr_Input+$200,oPrio(a0)	; Priority
		move.b	#$C,oDrawW(a0)			; Sprite width
		move.b	#$C,oDrawH(a0)			; Sprite height
		move.b	#$C,oColW(a0)			; Collision width
		move.b	#$C,oColH(a0)			; Collision height
		move.b	oSubtype(a0),oAni(a0)		; Animation
		move.b	oAni(a0),oDiamColor(a0)		; Color ID
		move.b	#20,oDiamTimer(a0)		; Break timer
		clr.b	oRoutine(a0)			; Clear routine ID
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjDiamond_Main:
		moveq	#0,d1
		move.b	oColW(a0),d1			; Width
		add.w	d1,d1				; ''
		moveq	#0,d2
		move.b	oColH(a0),d2			; Height
		move.w	d2,d3				; ''
		addq.w	#1,d3				; ''
		move.w	oX(a0),d4			; X position
		jsr	SolidObject			; Make us solid

		tst.b	oDiamBreak(a0)			; Are we breaking?
		bne.s	.DoBreak			; If so, branch

		btst	#cTouchSideBit,d6		; Is Sonic pushing us?
		bne.s	.Break				; If so, branch
		btst	#cTouchBtmBit,d6		; Is Sonic touching the bottom of us?
		bne.s	.Break				; If so, branch
		btst	#3,oStatus(a0)			; Is Sonic on top of us?
		beq.s	.Display			; If not, branch
		
.Break:
		st	oDiamBreak(a0)			; Set the break flag
		playSnd	#sDiamBreak, 2			; Play the diamond break sound
		move.b	#4,oAni(a0)

.DoBreak:
		subq.b	#1,oDiamTimer(a0)		; Decrement the timer
		bpl.s	.Display			; If it hasn't run out, branch
		move.b	#20,oDiamTimer(a0)		; Reset the timer
		clr.b	oDiamBreak(a0)			; Clear the break flag
		addq.b	#1,oDiamColor(a0)		; Next phase
		move.b	oDiamColor(a0),oAni(a0)		; Set animation frame
		cmpi.b	#4,oDiamColor(a0)		; Should the diamond disappear?
		blo.s	.Display			; If not, branch
		bclr	#3,(r_Obj_Player+oStatus).w	; Reset Sonic's status
		bset	#1,(r_Obj_Player+oStatus).w	; ''
		clr.w	(r_Obj_Player+oInteract).w	; ''
		jmp	DeleteObject.w			; Delete ourselves

.Display:
		lea	Ani_ObjDiamond(pc),a1		; Animate
		jsr	AnimateObject.w			; ''
		jmp	CheckObjActive_Draw.w		; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Data
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
Map_ObjDiamond:
		include	"Level/Objects/Diamond/Mappings.asm"
		even
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
Ani_ObjDiamond:
		dc.w	.Blue-Ani_ObjDiamond
		dc.w	.Grey-Ani_ObjDiamond
		dc.w	.Yellow-Ani_ObjDiamond
		dc.w	.Teal-Ani_ObjDiamond
		dc.w	.Cycle-Ani_ObjDiamond
.Blue:		dc.b	2, 0, 1, 2, 3, $FF
.Grey:		dc.b	2, 4, 5, 6, 7, $FF
.Yellow:	dc.b	2, 8, 9, $A, $B, $FF
.Teal:		dc.b	2, $C, $D, $E, $F, $FF
.Cycle:		dc.b	2, 0, 5, $A, $F, $FF
		even
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ArtKosM_Diamond:
		incbin	"Level/Objects/Diamond/Art.kosm.bin"
		even
; =========================================================================================================================================================