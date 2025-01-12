; =========================================================================================================================================================
; Sonic's Fun And Easy Adventure
; By Ralakimus/Novedicus 2017
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Harpoon object
; =========================================================================================================================================================
		rsset	oLvlSSTs
oHarpTime	rs.b	1				; Timer
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjHarpoon:
		moveq	#0,d0
		move.b	oRoutine(a0),d0			; Get routine ID
		move.w	.Index(pc,d0.w),d0		; Get routine offset
		jsr	.Index(pc,d0.w)			; Jump to it
		jmp	AddToColResponse		; Allow collision
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.Index:
		dc.w	ObjHarpoon_Init-.Index		; Initialization
		dc.w	ObjHarpoon_Main-.Index		; Main
		dc.w	ObjHarpoon_Wait-.Index		; Wait
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjHarpoon_Init:
		addq.b	#2,oRoutine(a0)			; Next routine
		move.l	#Map_ObjHarpoon,oMap(a0)	; Mappings
		move.w	#$453,oVRAM(a0)			; Tile properties
		move.b	#4,oRender(a0)			; Render flags
		move.w	#r_Spr_Input+$200,oPrio(a0)	; Priority
		move.b	oSubtype(a0),oAni(a0)		; Animation
		move.b	#$14,oDrawW(a0)			; Sprite width
		move.b	#$14,oDrawH(a0)			; Sprite height
		move.b	#4,oColType(a0)			; Indestructable
		move.b	#60,oHarpTime(a0)		; Timer
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjHarpoon_Main:
		lea	Ani_ObjHarpoon,a1		; Animate
		jsr	AnimateObject.w			; ''

		moveq	#0,d0
		move.b	oFrame(a0),d0			; Get map frame
		add.b	d0,d0				; Turn into offset
		move.b	.ColData(pc,d0.w),oColW(a0)	; Collision width
		move.b	.ColData+1(pc,d0.w),oColH(a0)	; Collision height

		jmp	CheckObjActive_Draw.w		; Display the object
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.ColData:
		dc.b	16, 4
		dc.b	32, 4
		dc.b	48, 4
		dc.b	4, 16
		dc.b	4, 32
		dc.b	4, 48
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjHarpoon_Wait:
		subq.b	#1,oHarpTime(a0)		; Decrement timer
		bpl.s	.Display			; If it hasn't run out, branch
		move.b	#60,oHarpTime(a0)		; Reset timer
		subq.b	#2,oRoutine(a0)			; Reset routine
		bchg	#0,oAni(a0)			; Reverse animation

.Display:
		jmp	CheckObjActive_Draw.w		; Display the object
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Data
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
Map_ObjHarpoon:
		include	"Level/Objects/Harpoon/Mappings.asm"
		even
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
Ani_ObjHarpoon:
		dc.w	.Ani0-Ani_ObjHarpoon
		dc.w	.Ani1-Ani_ObjHarpoon
		dc.w	.Ani2-Ani_ObjHarpoon
		dc.w	.Ani3-Ani_ObjHarpoon
.Ani0:		dc.b	3, 1, 2, $FC
.Ani1:		dc.b	3, 1, 0, $FC
.Ani2:		dc.b	3, 4, 5, $FC
.Ani3:		dc.b	3, 4, 3, $FC
		even
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ArtKosM_Harpoon:
		incbin	"Level/Objects/Harpoon/Art.kosm.bin"
		even
; =========================================================================================================================================================