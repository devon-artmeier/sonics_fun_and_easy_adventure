; =========================================================================================================================================================
; Sonic's Fun And Easy Adventure
; By Ralakimus/Novedicus 2017
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Ball mode enable/disable object
; =========================================================================================================================================================
		rsset	oLvlSSTs
oBModeTouch	rs.b	1				; Touched flag
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjBallMode:
		move.l	#ObjBallMode_Main,oAddr(a0)	; Next routine
		move.l	#Map_ObjMonitor,oMap(a0)	; Mappings
		clr.w	oVRAM(a0)			; Tile properties
		ori.b	#4,oRender(a0)			; Render flags
		move.w	#r_Spr_Input+$280,oPrio(a0)	; Priority
		move.b	#$10,oDrawW(a0)			; Sprite width
		move.b	#$10,oDrawH(a0)			; Sprite height
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjBallMode_Main:
		lea	.RangeData(pc),a1		; Range data
		lea	r_Obj_Player.w,a2		; Player object
		jsr	CheckObjInRange.w		; Is the player in range?
		tst.w	d0				; ''
		beq.s	.NotTouched			; If not, branch

		bclr	#2,(r_Obj_Player+oFlags).w
		
		tst.b	oSubtype(a0)			; Should we force Sonic out of ball mode?
		bmi.s	.NoBallMode			; If so, branch
		bne.s	.BallMode			; Branch if we should force Sonic in to ball mode

		tst.b	oBModeTouch(a0)			; Have we already been touched?
		bne.s	.End				; If so, branch
		st	oBModeTouch(a0)			; Touched

		not.b	oBallMode(a2)			; Switch ball mode for Sonic
		beq.s	.End				; If it's not set, branch

.MakeSonicRoll:
		movea.l	a0,a1				; Save a0
		movea.l	a2,a0				; Make Sonic roll
		jsr	ObjSonic_DoRoll			; ''
		movea.l	a1,a0				; Restore a0
		rts

.NotTouched:
		clr.b	oBModeTouch(a0)			; Not touched
		rts

.BallMode:
		st	oBallMode(a2)			; Get in to ball mode
		bra.s	.MakeSonicRoll			; ''

.NoBallMode:
		clr.b	oBallMode(a2)			; Get out of ball mode

.End:
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.RangeData:
		dc.w	-$10, $20
		dc.w	-$10, $20
; =========================================================================================================================================================