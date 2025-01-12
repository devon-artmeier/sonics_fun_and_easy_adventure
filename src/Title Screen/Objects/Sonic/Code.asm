; =========================================================================================================================================================
; Sonic's Fun And Easy Adventure
; By Ralakimus/Novedicus 2017
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Title screen Sonic object
; =========================================================================================================================================================
ObjTtlSonic:
		move.l	#ObjTtlSonic_Main,oAddr(a0)	; Next routine
		move.b	#4,oRender(a0)			; Render flags
		move.w	#$2200,oVRAM(a0)		; Tile properties
		move.l	#Map_ObjTtlSonic,oMap(a0)	; Mappings
		move.w	#r_Spr_Input+$80,oPrio(a0)	; Priority
		move.b	#$40,oDrawW(a0)			; Sprite width
		move.b	#$40,oDrawH(a0)			; Sprite height
		clr.b	oAni(a0)			; Reset animation ID
		move.w	#-$600,oXVel(a0)		; X velocity

ObjTtlSonic_Main:
		jsr	ObjectMove.w			; Move
		
		cmpi.w	#224,oX(a0)			; Has Sonic moved far enough?
		bgt.s	.Display			; If not, branch
		move.w	#-$80,oXVel(a0)			; Stop moving
		move.b	#1,oAni(a0)			; Set next animation ID
		move.l	#ObjTtlSonic_Jump,oAddr(a0)	; Next routine

.Display:
		lea	Ani_ObjTtlSonic,a1		; Animate
		jsr	AnimateObject.w			; ''
		jmp	DisplayObject.w			; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjTtlSonic_Jump:
		jsr	ObjectMoveAndFall.w		; Move and fall

		cmpi.w	#128,oY(a0)			; Is Sonic on the ground?
		blt.s	.Display			; If not, branch
		move.w	#-$400,oYVel(a0)		; Reset Y velocity
		move.w	#128,oY(a0)			; Align with ground
		neg.w	oXVel(a0)			; Move the other way

.Display:
		lea	Ani_ObjTtlSonic,a1		; Animate
		jsr	AnimateObject.w			; ''
		jmp	DisplayObject.w			; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Data
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ArtKosM_TtlSonic:
		incbin	"Title Screen/Objects/Sonic/Art.kosm.bin"
		even
Ani_ObjTtlSonic:
		dc.w	.Ani0-Ani_ObjTtlSonic
		dc.w	.Ani1-Ani_ObjTtlSonic
.Ani0:		dc.b	6, 0, 1, $FF
.Ani1:		dc.b	$25, 1, 0, $FF
		even
Map_ObjTtlSonic:
		include	"Title Screen/Objects/Sonic/Mappings.asm"
		even
; =========================================================================================================================================================