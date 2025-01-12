; =========================================================================================================================================================
; Sonic's Fun And Easy Adventure
; By Ralakimus/Novedicus 2017
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Title screen glove object
; =========================================================================================================================================================
		rsset	oDynSSTs
oGloveFlag	rs.b	1				; Punch flag
oGloveTime	rs.b	1				; Timer
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjTtlGlove:
		move.l	#ObjTtlGlove_Main,oAddr(a0)	; Next routine
		move.b	#4,oRender(a0)			; Render flags
		move.w	#$430,oVRAM(a0)			; Tile properties
		move.l	#Map_ObjTtlGlove,oMap(a0)	; Mappings
		move.w	#r_Spr_Input+$80,oPrio(a0)	; Priority
		move.b	#$80,oDrawW(a0)			; Sprite width
		move.b	#$80,oDrawH(a0)			; Sprite height
		clr.b	oAni(a0)			; Reset animation ID
		move.w	#-$1800,oYVel(a0)		; Y velocity
		move.b	#90,oGloveTime(a0)		; Set timer

ObjTtlGlove_Main:
		tst.b	oGloveFlag(a0)			; Are we allowed to punch?
		beq.s	.Display			; If not, branch

		subq.b	#1,oGloveTime(a0)		; Decrement timer

		jsr	ObjectMove.w			; Move

		cmpi.w	#256,oY(a0)			; Should the glove punch Sonic up?
		bgt.s	.Display			; If not, branch
		move.w	#-$1800,(r_Obj_0+oYVel).w	; Punch Sonic up in the air

		cmpi.w	#176,oY(a0)			; Has the Glove moved too far to the right?
		bgt.s	.Display			; If not, branch
		clr.w	oYVel(a0)			; Stop moving

.Display:
		jmp	DisplayObject.w			; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Data
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ArtKosM_TtlGlove:
		incbin	"Title Screen/Objects/Glove/Art.kosm.bin"
		even
Map_ObjTtlGlove:
		include	"Title Screen/Objects/Glove/Mappings.asm"
		even
; =========================================================================================================================================================