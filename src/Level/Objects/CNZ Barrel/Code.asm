; =========================================================================================================================================================
; Sonic's Fun And Easy Adventure
; By Ralakimus/Novedicus 2017
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; CNZ barrel object
; =========================================================================================================================================================
		rsset	oLvlSSTs
oBarMaxSpd	rs.w	1
oBarMovType	rs.w	1
oBarX		rs.w	1
oBarY		rs.w	1
oBarStat	rs.w	1
oBarFlags	rs.l	1
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjCNZBarrel_MaxSpds:
		dc.w	$4E0
		dc.w	$6F0
		dc.w	$870
		dc.w	$9C0
		dc.w	$AE0
		dc.w	$C00
		dc.w	$CF0
		dc.w	$DE0
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjCNZBarrel:
		move.b	oSubtype(a0),d0			; Get subtype
		move.b	d0,d1				; Copy it
		lsr.b	#3,d1				; Turn high nibble into offset
		andi.w	#$E,d1				; ''
		move.w	ObjCNZBarrel_MaxSpds(pc,d1.w),d1; Get max Y speed for the barrel
		move.w	d1,oBarMaxSpd(a0)		; Set it

		add.w	d0,d0				; Turn low nibble into offset
		andi.w	#$1E,d0				; ''
		move.w	d0,oBarMovType(a0)		; Set movement type

		move.l	#Map_ObjCNZBarrel,oMap(a0)	; Mappings
		move.w	#$3D0,oVRAM(a0)			; Tile properties
		move.b	#4,oRender(a0)			; Render flags
		move.w	#r_Spr_Input+$280,oPrio(a0)	; Priority
		move.b	#$20,oDrawW(a0)			; Sprite width
		move.b	#$20,oDrawH(a0)			; Sprite height
		move.b	#$2B,oColW(a0)			; Collision width
		move.b	#$20,oColH(a0)			; Collision height

		move.w	oX(a0),oBarX(a0)		; Save position
		move.w	oY(a0),oBarY(a0)		; ''

		move.l	#ObjCNZBarrel_Main,oAddr(a0)	; Next routine
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjCNZBarrel_Main:
		lea	oBarFlags(a0),a2
		lea	r_Obj_Player.w,a1

		move.b	(a2),d0
		bne.s	.HandleSonic
		btst	#3,oStatus(a0)
		beq.w	.HandleMovement
		clr.b	1(a2)
		move.w	oX(a1),d0
		sub.w	oX(a0),d0
		bpl.s	.LockSonic
		neg.w	d0
		move.b	#-$80,1(a2)

.LockSonic:
		move.b	d0,2(a2)
		clr.l	oXVel(a1)			; Reset velocities
		clr.w	oGVel(a1)			; ''
		move.b	#3,oFlags(a1)			; Disable movement
		move.b	oInitColH(a1),oColH(a1)		; Reset collision height
		move.b	oInitColW(a1),oColW(a1)		; Reset collision width
		andi.b	#$C9,oStatus(a1)		; Reset mode and pushing flag
		clr.b	oJumping(a1)			; Clear jumping flag
		clr.b	oAni(a1)			; Reset animation
		move.b	#1,(a2)
		bsr.w	ObjCNZBarrel_AniSonic		; Animate Sonic
		bra.w	.HandleMovement			; Continue

.HandleSonic:
		cmpi.b	#4,oRoutine(a1)			; Is Sonic hurt or dead?
		bhs.w	.ForceSonicOut			; If so, branch
		btst	#3,oStatus(a0)			; Are we being stood on?
		beq.w	.ForceSonicOut			; If not, branch

		moveq	#0,d0
		move.b	1(a2),d0
		jsr	CalcSine.w
		addi.w	#$100,d0
		asr.w	#2,d0
		move.b	d0,3(a2)

		moveq	#0,d2
		move.w	2(a2),d2
		muls.w	d2,d1
		swap	d1
		add.w	oX(a0),d1
		move.w	d1,oX(a1)
		addq.b	#4,1(a2)
		clr.w	oGVel(a1)
		move.w	oYVel(a0),d0
		bpl.s	.ChkInAir
		neg.w	d0

.ChkInAir:
		btst	#1,oStatus(a1)
		bne.s	.ChkJump
		cmpi.w	#$480,d0
		blo.s	.ChkJump
		move.w	#$800,oGVel(a1)

.ChkJump:
		move.b	r_Ctrl_Press.w,d0
		andi.b	#$70,d0
		beq.s	.AnimateSonic
		st	oJumping(a1)			; Set the jumping flag
		move.b	#$E,oColH(a1)			; Reduce Sonic's hitbox
		move.b	#7,oColW(a1)			; ''
		move.b	#2,oAni(a1)			; Set jumping animation
		bset	#2,oStatus(a1)			; Set roll flag
		move.w	oYVel(a0),oYVel(a1)
		addi.w	#-JUMP_HEIGHT,oYVel(a1)
		clr.w	oXVel(a1)
		clr.w	oGVel(a1)

.ForceSonicOut:
		bset	#1,oStatus(a1)			; Set "in air" flag
		clr.b	oFlags(a1)			; Reset flags
		clr.b	(a2)
		bra.s	.HandleMovement

.AnimateSonic:
		bsr.w	ObjCNZBarrel_AniSonic		; Animate Sonic
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.HandleMovement:
		move.w	oBarStat(a0),d1			; Get last saved status
		move.b	oStatus(a0),d0			; Get current status
		andi.w	#8,d0				; Get only stood on bit
		cmp.w	d1,d0				; Has the status changed? (If Sonic landed or jumped off the barrel)
		beq.s	.DoMovement			; If not, branch
		move.w	d0,oBarStat(a0)			; Save new status
		sub.w	d1,d0
		bcs.s	.DoMovement
		move.w	oYVel(a0),d0			; Get Y velocity
		bpl.s	.ChkYVel			; Get absolute value
		neg.w	d0				; ''

.ChkYVel:
		cmpi.w	#$200,d0			; Is the barrel at least 2 pixels/frame?
		bhs.s	.DoMovement			; If so, branch
		move.w	oY(a0),d0			; Get current vertical distance from center
		sub.w	oBarY(a0),d0			; ''
		addi.w	#$40,d0				; Center it
		cmpi.w	#$80,d0
		bhs.s	.DoMovement
		addi.w	#$400,oYVel(a0)			; Push the barrel down
		move.w	oBarMaxSpd(a0),d0		; Get max Y speed
		cmp.w	oYVel(a0),d0			; Are we going too fast?
		bgt.s	.DoMovement			; If not, branch
		move.w	d0,oYVel(a0)			; Cap the speed

.DoMovement:
		jsr	ObjectMove.w			; Move
		moveq	#0,d5
		btst	#3,oStatus(a0)			; Are we being stood on?
		beq.s	.Bounce				; If not, branch
		move.b	r_Ctrl_Hold.w,d5		; Get Sonic's control bits

.Bounce:
		move.w	oY(a0),d0			; Get vertical distance from center
		sub.w	oBarY(a0),d0			; ''
		beq.s	.AtCenter			; Branch if at the center
		bcc.s	.Below				; Branch if below the center
		move.w	oBarMaxSpd(a0),d0		; Get max Y speed
		cmp.w	oYVel(a0),d0			; Have we reached the max Y speed?
		ble.s	.Solid				; If not, branch
		addi.w	#$20,oYVel(a0)			; Go down
		bmi.s	.MovingUpAbove			; If we are moving up, branch
		btst	#1,d5				; Are we holding down?
		beq.s	.Solid				; If not, branch
		addi.w	#$20,oYVel(a0)			; Go down further
		bra.s	.Solid				; Continue

.MovingUpAbove:
		addi.w	#$10,oYVel(a0)			; Go down further
		bra.s	.Solid				; Continue

.Below:
		move.w	oBarMaxSpd(a0),d0		; Get max Y speed
		neg.w	d0				; ''
		cmp.w	oYVel(a0),d0			; Have we reached the max Y speed?
		bge.s	.Solid				; If not, branch
		subi.w	#$20,oYVel(a0)			; Go up
		bpl.s	.MovingDownBelow		; If we are moving up, branch
		btst	#0,d5				; Are we holding up?
		beq.s	.Solid				; If not, branch
		subi.w	#$20,oYVel(a0)			; Go up further
		bra.s	.Solid				; Continue

.MovingDownBelow:
		subi.w	#$10,oYVel(a0)			; Go up further
		bra.s	.Solid				; Continue

.AtCenter:
		move.w	oYVel(a0),d0			; Get Y velocity
		bpl.s	.ChkYVelCenter			; Get absolute value
		neg.w	d0				; ''

.ChkYVelCenter:
		cmpi.w	#$80,d0
		bhs.s	.Solid
		clr.w	oYVel(a0)
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.Solid:
		moveq	#0,d1
		move.b	oColW(a0),d1			; Width
		moveq	#0,d2
		move.b	oColH(a0),d2			; Height
		move.w	d2,d3				; ''
		addq.w	#1,d3				; ''
		move.w	oX(a0),d4			; X position
		jsr	SolidObject			; Make us solid

		subq.b	#1,oAniTimer(a0)		; Decrement animation timer
		bpl.s	.Display			; If it hasn't run out, branch
		move.b	#1,oAniTimer(a0)		; Reset timer
		addq.b	#1,oFrame(a0)			; Next frame
		andi.b	#3,oFrame(a0)			; Keep frame within range

.Display:
		move.w	oBarX(a0),d0			; X position
		jmp	CheckObjActive2_Draw.w		; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Animate Sonic while he's on the barrel
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjCNZBarrel_AniSonic:
		moveq	#0,d0
		move.b	1(a2),d0
		addi.b	#$B,d0
		divu.w	#$16,d0
		move.b	.TwistFrames(pc,d0.w),oFrame(a1)
		andi.b	#$FC,oRender(a1)
		move.b	.TwistFlip(pc,d0.w),d0
		or.b	d0,oRender(a1)

		push.l	a0-a2
		movea.l	a1,a0
		lea	DPLC_ObjSonic,a2		; DPLCs
		move.w	#$F000,d4			; VRAM location
		move.l	#ArtUnc_Sonic,d6		; Art
		jsr	LoadObjDPLCs.w			; Load DPLCs
		pop.l	a0-a2

		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.TwistFrames:	dc.b	$74, $74, $76, $76, $74, $74, $01, $01, $75, $75, $01, $01
.TwistFlip:	dc.b	$00, $00, $00, $00, $01, $01, $01, $01, $00, $00, $00, $00
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Data
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
Map_ObjCNZBarrel:
		include	"Level/Objects/CNZ Barrel/Mappings.asm"
		even
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ArtKosM_CNZBarrel:
		incbin	"Level/Objects/CNZ Barrel/Art.kosm.bin"
		even
; =========================================================================================================================================================