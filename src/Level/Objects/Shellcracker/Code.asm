; =========================================================================================================================================================
; Sonic's Fun And Easy Adventure
; By Ralakimus/Novedicus 2017
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Shellcracker object
; =========================================================================================================================================================
		rsset	oLvlSSTs
oShellTime	rs.w	1				; Timer
oClawRout	rs.b	1				; Claw throw routine
oClawFlag	rs.b	1				; Claw finish flag
oClawPar	rs.w	1				; Claw parent object
oClawType	rs.w	1				; Claw type
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjShlCrker:
		moveq	#0,d0
		move.b	oRoutine(a0),d0			; Get routine ID
		move.w	.Index(pc,d0.w),d0		; Get routine offset
		jsr	.Index(pc,d0.w)			; Jump to it
		jmp	AddToColResponse		; Allow collision
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.Index:
		dc.w	ObjShlCrker_Init-.Index		; Initialization
		dc.w	ObjShlCrker_Main-.Index		; Main
		dc.w	ObjShlCrker_Wait-.Index		; Wait
		dc.w	ObjShlCrker_Throw-.Index	; Throw claw
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjShlCrker_Init:
		addq.b	#2,oRoutine(a0)			; Next routine
		move.l	#Map_ObjShlCrker,oMap(a0)	; Mappings
		move.w	#$420,oVRAM(a0)			; Tile properties
		move.b	#4,oRender(a0)			; Render flags
		move.w	#r_Spr_Input+$280,oPrio(a0)	; Priority
		move.b	#$18,oDrawW(a0)			; Sprite width
		move.b	#$C,oDrawH(a0)			; Sprite height
		move.b	#2,oColType(a0)			; Enemy

		btst	#0,oRender(a0)			; Are we faced to the left?
		beq.s	.SetXVel			; If so, branch
		bset	#0,oStatus(a0)			; Face the other way

.SetXVel:
		move.w	#-$40,oXVel(a0)			; X velocity
		move.b	#$18,oColW(a0)			; Collision width
		move.b	#$C,oColH(a0)			; Collision height
		move.w	#$140,oShellTime(a0)		; Set timer
		jmp	CheckObjActive_Draw.w		; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjShlCrker_Main:
		jsr	GetOrientToPlayer.w		; Get orientation to the player
		tst.w	d0				; Are we facing the player?
		beq.s	.ChkRange			; If so, branch
		btst	#0,oRender(a0)			; Are we faced to the left?
		beq.s	.DoFloorCol			; If so, branch

.ChkRange:
		addi.w	#$60,d2				; Center horizontal distance
		cmpi.w	#$C0,d2				; Is Sonic within range?
		blo.s	ObjShlCrker_DoThrow		; If so, branch

.DoFloorCol:
		jsr	ObjectMove.w			; Move
		jsr	ObjCheckFloorDist		; Get distance to floor
		cmpi.w	#-8,d1				; Are we at a ledge?
		blt.s	.GoOtherWay			; If so, branch
		cmpi.w	#$C,d1				; Are we at a ledge?
		bge.s	.GoOtherWay			; If so, branch
		add.w	d1,oY(a0)			; Align to floor

		subq.w	#1,oShellTime(a0)		; Decrement timer
		bmi.s	.DoWait				; If it has run out, branch

		lea	Ani_ObjShlCrker,a1		; Animate
		jsr	AnimateObject.w			; ''
		jmp	CheckObjActive_Draw.w		; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.GoOtherWay:
		neg.w	oXVel(a0)			; Go the other way

.DoWait:
		addq.b	#2,oRoutine(a0)			; Next routine
		clr.b	oFrame(a0)			; Reset mapping frame
		move.w	#$3B,oShellTime(a0)		; Set timer
		jmp	CheckObjActive_Draw.w		; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjShlCrker_DoThrow:
		move.b	#6,oRoutine(a0)			; Next routine
		clr.b	oFrame(a0)			; Reset mapping frame
		move.w	#8,oShellTime(a0)		; Set timer
		jmp	CheckObjActive_Draw.w		; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjShlCrker_Wait:
		tst.b	oRender(a0)			; Are we on screen?
		bpl.s	.ChkTimer			; If not, branch
		jsr	GetOrientToPlayer.w		; Get orientation to the player
		tst.w	d0				; Are we facing the player?
		beq.s	.ChkRange			; If so, branch
		btst	#0,oRender(a0)			; Are we faced to the left?
		beq.s	.ChkTimer			; If so, branch

.ChkRange:
		addi.w	#$60,d2				; Center horizontal distance
		cmpi.w	#$C0,d2				; Is Sonic within range?
		blo.s	ObjShlCrker_DoThrow		; If so, branch

.ChkTimer:
		subq.w	#1,oShellTime(a0)		; Decrement the timer
		bmi.s	.FinishWait			; If it has run out, branch
		jmp	CheckObjActive_Draw.w		; Display

.FinishWait:
		subq.b	#2,oRoutine(a0)			; Previous routine
		move.w	#$140,oShellTime(a0)		; Reset timer
		jmp	CheckObjActive_Draw.w		; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjShlCrker_Throw:
		moveq	#0,d0
		move.b	oClawRout(a0),d0		; Get routine ID
		move.w	.Index(pc,d0.w),d0		; Get routine offset
		jsr	.Index(pc,d0.w)			; Jump to it
		jmp	CheckObjActive_Draw.w		; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.Index:
		dc.w	.Wait-.Index			; Wait and throw claw
		dc.w	.WaitClaw-.Index		; Wait for claw
		dc.w	.Finish-.Index			;FInish up
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.Wait:
		subq.w	#1,oShellTime(a0)		; Decrement the timer
		bmi.s	.Throw				; If it has run out, branch
		rts

.Throw:
		addq.b	#2,oClawRout(a0)		; Next routine
		move.b	#3,oFrame(a0)			; Set map frame
		bra.s	.MakeClaw			; Make the claw
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.WaitClaw:
		tst.b	oClawFlag(a0)			; Is the claw done?
		bne.s	.ClawDone			; If so, branch
		rts

.ClawDone:
		addq.b	#2,oClawRout(a0)		; Next routine
		move.w	#$20,oShellTime(a0)		; Reset timer
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.Finish:
		subq.w	#1,oShellTime(a0)		; Decrement the timer
		bmi.s	.Done				; If it has run out, branch
		rts

.Done:
		clr.b	oClawRout(a0)			; Reset routine
		clr.b	oClawFlag(a0)			; Reset claw finished flag
		move.b	#2,oRoutine(a0)			; Go back to main routine
		move.w	#$140,oShellTime(a0)		; Reset timer
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.MakeClaw:
		moveq	#0,d1				; Claw type
		moveq	#7,d6				; Number of pieces
		
.ClawLoop:
		jsr	FindNextFreeObj.w		; Find a free object slot
		bne.s	.ClawEnd			; If there is none, branch
		move.l	#ObjClaw,oAddr(a1)		; Load a claw piece
		move.b	#5,oFrame(a1)			; Map frame
		move.w	#r_Spr_Input+$200,oPrio(a1)	; Priority
		move.w	a0,oClawPar(a1)			; Set parent
		move.w	d1,oClawType(a1)		; Set claw type
		move.w	oX(a0),oX(a1)			; X position
		move.w	#-$14,d2			; X offset
		btst	#0,oRender(a0)			; Are we facing left?
		beq.s	.SetXOff			; If so, branch
		neg.w	d2				; Negate the X offset
		tst.w	d1				; Is this the claw?
		beq.s	.SetXOff			; If so, branch
		subi.w	#$C,d2				; Move the piece to the left

.SetXOff:
		add.w	d2,oX(a1)			; Add X offset
		move.w	oY(a0),oY(a1)			; Y position
		subq.w	#8,oY(a1)			; ''
		addq.w	#2,d1				; Next piece
		dbf	d6,.ClawLoop			; Loop
		
.ClawEnd:
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Shellcracker claw object
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjClaw:
		moveq	#0,d0
		move.b	oRoutine(a0),d0			; Get routine ID
		move.w	.Index(pc,d0.w),d0		; Get routine offset
		jmp	.Index(pc,d0.w)			; Jump to it
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.Index:
		dc.w	ObjClaw_Init-.Index		; Initialization
		dc.w	ObjClaw_Main-.Index		; Main
		dc.w	ObjClaw_Fall-.Index		; Fall
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjClaw_Init:
		addq.b	#2,oRoutine(a0)			; Next routine
		move.l	#Map_ObjShlCrker,oMap(a0)		; Mappings
		move.w	#$420,oVRAM(a0)			; Tile properties
		move.b	#4,oRender(a0)			; Render flags
		move.w	#r_Spr_Input+$200,oPrio(a0)	; Priority
		move.b	#$C,oDrawW(a0)			; Sprite width
		move.b	#$C,oDrawH(a0)			; Sprite height
		move.b	#4,oColType(a0)			; Indestructable
		move.b	#$C,oColW(a0)			; Collision width
		move.b	#$C,oColH(a0)			; Collision height

		movea.w	oClawPar(a0),a1			; Get parent object
		move.b	oRender(a1),d0			; Get render flags
		andi.b	#1,d0				; Get horizontal flip bit
		or.b	d0,oRender(a0)			; Set it for us

		move.w	oClawType(a0),d0		; Get type
		beq.s	.NotLink			; If it's the actual claw, branch
		move.b	#4,oFrame(a0)			; Set map frame to link sprite
		addq.w	#6,oX(a0)			; Shift position
		addq.w	#6,oY(a0)			; ''

.NotLink:
		lsr.w	#1,d0				; Divide type by 2
		move.b	.Delays(pc,d0.w),oShellTime(a0)	; Set delay timer
		jmp	CheckObjActive_Draw.w		; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.Delays:
		dc.b	0, 3, 5, 7, 9, $B, $D, $F
		even
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjClaw_Main:
		movea.w	oClawPar(a0),a1			; Get parent object
		cmpi.l	#ObjShlCrker,oAddr(a1)		; Is it a shellcracker?
		bne.s	.SetFall			; If not, branch
		
		moveq	#0,d0
		move.b	oClawRout(a0),d0		; Get routine ID
		move.w	.Index(pc,d0.w),d0		; Get routine offset
		jsr	.Index(pc,d0.w)			; Jump to it

		jsr	AddToColResponse		; Allow collision
		jmp	CheckObjActive_Draw.w		; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.Index:
		dc.w	.Wait-.Index			; Wait
		dc.w	.Move-.Index			; Move
		dc.w	.Wait2-.Index			; Wait
		dc.w	.MoveBack-.Index		; Move back
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.SetFall:
		move.b	#4,oRoutine(a0)			; Next routine
		move.w	#$40,oShellTime(a0)		; Reset timer
		jmp	CheckObjActive_Draw.w		; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.Wait:
		subq.b	#1,oShellTime(a0)		; Decrement delay timer
		beq.s	.DoMove				; If it has run out, branch
		bmi.s	.DoMove				; ''
		rts

.DoMove:
		addq.b	#2,oClawRout(a0)		; Next routine
		move.w	oClawType(a0),d0		; Get type
		cmpi.w	#$E,d0				; Is this the last link?
		bhs.s	.SetLastMoveTimers		; If so, branch
		move.w	#-$400,d2			; X velocity
		btst	#0,oRender(a0)			; Are we faced left?
		beq.s	.SetXVel			; If so, branch
		neg.w	d2				; Go the other wat

.SetXVel:
		move.w	d2,oXVel(a0)			; Set X velocity
		lsr.w	#1,d0				; Divide type by 2
		move.b	.MoveTimers(pc,d0.w),d1		; Get move timer
		move.b	d1,oShellTime(a0)		; Set timers
		move.b	d1,oShellTime+1(a0)		; ''
		rts

.SetLastMoveTimers:
		move.w	#$000B,oShellTime(a0)		; Set move timers
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.MoveTimers:
		dc.b	$D, $C, $A, 8, 6, 4, 2, 0
		even
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.Move:
		jsr	ObjectMove.w			; Move
		subq.b	#1,oShellTime(a0)		; Decrement timer
		beq.s	.DoGoBackWait			; If it has run out, branch
		bmi.s	.DoGoBackWait			; ''
		rts

.DoGoBackWait:
		addq.b	#2,oClawRout(a0)		; Next routine
		move.b	#8,oShellTime(a0)		; Reset timer
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.Wait2:
		subq.b	#1,oShellTime(a0)		; Decrement timer
		beq.s	.DoGoBack			; If it has run out, branch
		bmi.s	.DoGoBack			; ''
		rts

.DoGoBack:
		addq.b	#2,oClawRout(a0)		; Next routine
		neg.w	oXVel(a0)			; Go the other way
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.MoveBack:
		jsr	ObjectMove.w			; Move
		subq.b	#1,oShellTime+1(a0)		; Decrement timer
		beq.s	.DoFinish			; If it has run out, branch
		bmi.s	.DoFinish			; ''
		rts

.DoFinish:
		tst.w	oClawType(a0)			; Are we the actual claw?
		bne.s	.Delete				; If not, branch
		movea.w	oClawPar(a0),a1			; Get parent object
		clr.b	oFrame(a1)			; Reset map frame
		st	oClawFlag(a1)			; Set claw finished flag
		
.Delete:
		addq.w	#4,sp				; Don't return to caller
		jmp	DeleteObject.w			; Delete ourselves
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjClaw_Fall:
		jsr	ObjectMoveAndFall.w		; Move and fall
		subq.w	#1,oShellTime(a0)		; Decrement timer
		bmi.s	.Delete				; If it has run out, branch
		jmp	CheckObjActive_Draw.w		; Display

.Delete:
		jmp	DeleteObject.w			; Delete ourselves
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Data
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
Map_ObjShlCrker:
		include	"Level/Objects/Shellcracker/Mappings.asm"
		even
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
Ani_ObjShlCrker:
		dc.w	.Ani0-Ani_ObjShlCrker
		dc.w	.Ani1-Ani_ObjShlCrker
.Ani0:		dc.b	$E, 0, 1, 2, $FF
		even
.Ani1:		dc.b	$E, 0, 2, 1, $FF
		even
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ArtKosM_ShlCrker:
		incbin	"Level/Objects/Shellcracker/Art.kosm.bin"
		even
; =========================================================================================================================================================