; =========================================================================================================================================================
; Sonic's Fun And Easy Adventure
; By Ralakimus/Novedicus 2017
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Title screen bird object
; =========================================================================================================================================================
		rsset	oDynSSTs
oBirdTimer	rs.b	1				; Timer
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjTtlBird:
		move.l	#ObjTtlBird_Main,oAddr(a0)	; Next routine
		move.b	#4,oRender(a0)			; Render flags
		move.w	#$2420,oVRAM(a0)		; Tile properties
		move.l	#Map_ObjTtlBird,oMap(a0)	; Mappings
		move.w	#r_Spr_Input+$80,oPrio(a0)	; Priority
		move.b	#$40,oDrawW(a0)			; Sprite width
		move.b	#$40,oDrawH(a0)			; Sprite height
		clr.b	oAni(a0)			; Reset animation ID
		move.w	#$140,oXVel(a0)			; X velocity

ObjTtlBird_Main:
		jsr	ObjectMove.w			; Move

		cmpi.w	#320+64,oX(a0)			; Has the bird moved too far to the right?
		blt.s	.Display			; If not, branch
		move.w	#-64,oX(a0)			; Reset X

.Display:
		lea	Ani_ObjTtlBird,a1		; Animate
		jsr	AnimateObject.w			; ''
		jmp	DisplayObject.w			; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Data
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ArtKosM_TtlBird:
		incbin	"Title Screen/Objects/Bird/Art.kosm.bin"
		even
Ani_ObjTtlBird:
		dc.w	.Ani0-Ani_ObjTtlBird
.Ani0:		dc.b	4, 0, 1, $FF
		even
Map_ObjTtlBird:
		include	"Title Screen/Objects/Bird/Mappings.asm"
		even
; =========================================================================================================================================================