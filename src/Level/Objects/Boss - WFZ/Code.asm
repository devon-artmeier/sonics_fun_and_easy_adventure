; =========================================================================================================================================================
; Sonic's Fun And Easy Adventure
; By Ralakimus/Novedicus 2017
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; WFZ boss object
; =========================================================================================================================================================
		rsset	oLvlSSTs
oWFZRout	rs.b	1				; Secondary routine
oWFZDisp	rs.b	1				; Display flag
oWFZPtfmID	rs.b	0				; Platform ID
oWFZPtfmCnt	rs.b	0				; Platform count
oWFZLaser	rs.b	0				; Laser frame
oWFZTime	rs.w	1				; Flash timer
oWFZTime2	rs.w	1				; Boss music delay timer
oWFZMinX	rs.w	1				; Minimum X position
oWFZMaxX	rs.w	1				; Maximum X position
oWFZPar		rs.w	0				; Parent object
oWFZChild1	rs.w	1				; Child object #1
oWFZChild2	rs.w	1				; Child object #2
oWFZChild3	rs.w	1				; Child object #3
oWFZChild4	rs.w	1				; Child object #4
oWFZPtfmY	rs.w	1				; Initial platform Y position
oWFZPtfmFlags	rs.b	3				; Platform load flags
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjWFZBoss:
		moveq	#0,d0
		move.b	oRoutine(a0),d0			; Get routine ID
		move.w	.Index(pc,d0.w),d0		; Get routine offset
		jsr	.Index(pc,d0.w)			; Jump to it
		jmp	AddToColResponse		; Allow collision
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.Index:
		dc.w	ObjWFZBoss_Init-.Index		; Initialization
		dc.w	ObjWFZBoss_LaserCase-.Index	; Laser case
		dc.w	ObjWFZBoss_LaserWall-.Index	; Laser wall
		dc.w	ObjWFZBoss_PtfmReleaser-.Index	; Platform releaser
		dc.w	ObjWFZBoss_Platform-.Index	; Platform
		dc.w	ObjWFZBoss_PlatformHurt-.Index	; Platform hurt
		dc.w	ObjWFZBoss_LaserShooter-.Index	; Laser shooter
		dc.w	ObjWFZBoss_Laser-.Index		; Laser
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjWFZBoss_Init:
		lea	ObjWFZBoss_VarsList,a1		; Get variable list
		moveq	#0,d0
		move.b	oSubtype(a0),d0			; Get subtype
		move.w	(a1,d0.w),d0			; Get variables offset
		lea	(a1,d0.w),a1			; ''
		bsr.w	ObjWFZBoss_InitVars		; Initialize variables

		move.b	oSubtype(a0),oRoutine(a0)	; Set routine ID
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjWFZBoss_LaserCase:
		moveq	#0,d0
		move.b	oWFZRout(a0),d0			; Get routine ID
		move.w	.Index(pc,d0.w),d0		; Get routine offset
		jsr	.Index(pc,d0.w)			; Jump to it
		bra.w	ObjWFZBoss_HandleHits		; Handle hit
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.Index:
		dc.w	.CaseBoundary-.Index		; Set boundaries for movement and misc. things
		dc.w	.WaitStart-.Index		; Waits for Sonic to start
		dc.w	.WaitDown-.Index		; Wait for the laser to go down
		dc.w	.CaseDown-.Index		; Move the case down
		dc.w	.CaseXSpeed-.Index		; Set an X speed for the case
		dc.w	.CaseBoundaryChk-.Index		; Checks to make sure the case doesn't go beyond boundaries
		dc.w	.CaseAnimate-.Index		; Animate the case (open and close)
		dc.w	.CaseLSLoad-.Index		; Laser shooting loading
		dc.w	.CaseLSDown-.Index		; Move the laser shooter down
		dc.w	.CaseWaitLoadLaser-.Index	; Wait to load the laser
		dc.w	.CaseWaitMove-.Index		; Wait to move (check if laser is completely loaded (as big as it gets))
		dc.w	.CaseBoundaryLaserChk-.Index	; Check boundaries when moving with the laser
		dc.w	.CaseLSUp-.Index		; Wait for the laser shooter to go back up
		dc.w	.CaseAnimate-.Index		; Animate the case (open and close)
		dc.w	.CaseStartOver-.Index		; Set the routine back to 8
		dc.w	.CaseDefeated-.Index		; Defeated (explosions and stuff)
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.CaseBoundary:
		addq.b	#2,oWFZRout(a0)			; Next routine
		clr.b	oColType(a0)			; No collision
		move.b	#8,oHitCnt(a0)			; Set hit count

		move.b	#$10,oColW(a0)			; Set collision boundaries
		move.b	#8,oColH(a0)			; ''
		
		move.w	oX(a0),d0			; Get X
		subi.w	#$60,d0				; Max left position
		move.w	d0,oWFZMinX(a0)			; ''
		addi.w	#$60*2,d0			; Max right position
		move.w	d0,oWFZMaxX(a0)			; ''
		
		jmp	DisplayObject.w			; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.WaitStart:
		jsr	GetOrientToPlayer.w		; Get orientation to Sonic
		addq.w	#8,d2				; Check X range
		cmpi.w	#$10,d2				; ''
		blo.s	.CaseStart			; If Sonic is within range, branch
		jmp	DisplayObject.w			; Display

.CaseStart:
		addq.b	#2,oWFZRout(a0)			; Next routine
		move.w	#$40,oYVel(a0)			; Move down

		lea	ObjWFZBoss_LaserWallData,a2	; Laser wall #1
		jsr	LoadChildObject.w		; Load it
		subi.w	#$88,oX(a1)			; Reposition
		addi.w	#$60,oY(a1)			; ''

		lea	ObjWFZBoss_LaserWallData,a2	; Laser wall #2
		jsr	LoadChildObject.w		; Load it
		addi.w	#$88,oX(a1)			; Reposition
		addi.w	#$60,oY(a1)			; ''

		lea	ObjWFZBoss_LaserShootData,a2	; Laser shooter
		jsr	LoadChildObject.w		; Load it

		lea	ObjWFZBoss_PtfmReleaserData,a2	; Platform releaser
		jsr	LoadChildObject.w		; Load it

		move.w	#$5A,oWFZTime2(a0)		; Amount of frames to wait before playing the boss music
		playSnd	#Mus_FadeOut, 2			; Fade out music
		
		jmp	DisplayObject.w			; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.WaitDown:
		subq.w	#1,oWFZTime2(a0)		; Decrement timer
		bmi.s	.SpeedDown			; If it has run out, branch
		jmp	DisplayObject.w			; Display

.SpeedDown:
		addq.b	#2,oWFZRout(a0)			; Next routine
		move.w	#$60,oWFZTime2(a0)		; How long the laser carrier goes down
		playSnd	#mBoss, 1			; Play boss music
		jmp	DisplayObject.w			; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.CaseDown:
		subq.w	#1,oWFZTime2(a0)		; Decrement timer
		beq.s	.CaseStopDown			; If it has run out, branch
		jsr	ObjectMove.w			; Move
		jmp	DisplayObject.w			; Display

.CaseStopDown:
		addq.b	#2,oWFZRout(a0)			; Next routine
		clr.w	oYVel(a0)			; Stop moving
		jmp	DisplayObject.w			; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.CaseXSpeed:
		addq.b	#2,oWFZRout(a0)			; Next routine
		jsr	GetOrientToPlayer.w		; Get orientation to Sonic
		move.w	#$100,d1			; Speed to carrier
		tst.w	d0				; Is Sonic left of the carrier?
		bne.s	.CasePMLoader			; If not, branch
		neg.w	d1				; Go the other way

.CasePMLoader:
		move.w	d1,oXVel(a0)			; Set X velocity
		bset	#2,oStatus(a0)			; Make the platform maker load
		move.w	#$70,oWFZTime2(a0)		; How long to go back and forth before sending out the laser
		jmp	DisplayObject.w			; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.CaseBoundaryChk:
		subq.w	#1,oWFZTime2(a0)		; Decrement timer
		bmi.s	.CaseOpenAnim			; If it has run out, branch
		move.w	oX(a0),d0			; Get X
		tst.w	oXVel(a0)			; Is the carrier moving left?
		bmi.s	.CaseBoundaryChk2		; If so, branch
		cmp.w	oWFZMaxX(a0),d0			; Has it reached the right boundary?
		bhs.s	.CaseNegSpeed			; If so, branch
		bra.s	.CaseMoveDisplay		; Display

.CaseBoundaryChk2:
		cmp.w	oWFZMinX(a0),d0			; Has it reached the left boundary?
		bhs.s	.CaseMoveDisplay		; If not, branch

.CaseNegSpeed:
		neg.w	oXVel(a0)			; Go the other way

.CaseMoveDisplay:
		jsr	ObjectMove.w			; Move
		jmp	DisplayObject.w			; Display

.CaseOpenAnim:
		addq.b	#2,oWFZRout(a0)			; Next routine
		clr.b	oAni(a0)			; Reset animation
		jmp	DisplayObject.w			; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.CaseAnimate:
		lea	Ani_ObjWFZBoss,a1		; Animate
		jsr	AnimateObject.w			; ''
		jmp	DisplayObject.w			; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.CaseLSLoad:
		addq.b	#2,oWFZRout(a0)			; Next routine
		move.w	#$E,oWFZTime2(a0)		; Timer the laser shooter moves down
		movea.w	oWFZChild3(a0),a1		; Get laser shooter object
		move.b	#4,oWFZRout(a1)			; Set its routine
		jmp	DisplayObject.w			; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.CaseLSDown:
		subq.w	#1,oWFZTime2(a0)		; Decrement timer
		beq.s	.CaseAddCollision		; If it has run out, branch
		movea.w	oWFZChild3(a0),a1		; Get laser shooter object
		addq.w	#1,oY(a1)			; Make it move down
		jmp	DisplayObject.w			; Display

.CaseAddCollision:
		addq.b	#2,oWFZRout(a0)			; Next routine
		move.w	#$E,oWFZTime2(a0)		; Length before shooting laser
		bset	#4,oStatus(a0)			; Makes the hit sound and flashes
		bset	#6,oStatus(a0)			; Makes sure collision gets restored
		move.b	#2,oColType(a0)			; Restore collision
		jmp	DisplayObject.w			; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.CaseWaitLoadLaser:
		subq.w	#1,oWFZTime2(a0)		; Decrement timer
		bmi.s	.CaseLoadLaser			; If it has run out, branch
		jmp	DisplayObject.w			; Display

.CaseLoadLaser:
		addq.b	#2,oWFZRout(a0)			; Next routine
		lea	ObjWFZBoss_LaserData,a2		; Laser
		jsr	LoadChildObject.w		; Load it
		jmp	DisplayObject.w			; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.CaseWaitMove:
		movea.w	oWFZPar(a0),a1			; Get parent object
		btst	#2,oStatus(a1)			; Has the laser fired?
		bne.s	.CaseLaserSpeed			; If so, branch
		jmp	DisplayObject.w			; Display

.CaseLaserSpeed:
		addq.b	#2,oWFZRout(a0)			; Next routine
		move.w	#$80,oWFZTime2(a0)		; How long to move the laser
		jsr	GetOrientToPlayer.w		; Get orientation to Sonic
		move.w	#$80,d1				; Speed when moving with laser
		tst.w	d0				; Is Sonic left of the carrier?
		bne.s	.CaseLaserSpeedSet		; If not, branch
		neg.w	d1				; Go the other way
		
.CaseLaserSpeedSet:
		move.w	d1,oXVel(a0)			; Set X velocity
		jmp	DisplayObject.w			; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.CaseBoundaryLaserChk:
		subq.w	#1,oWFZTime2(a0)		; Decrement timer
		bmi.s	.CaseStopLaserDelete		; If it has run out, branch
		move.w	oX(a0),d0			; Get X
		tst.w	oXVel(a0)			; Are we moving left?
		bmi.s	.CaseBoundaryLaserChk2		; If so, branch
		cmp.w	oWFZMaxX(a0),d0			; Has it reached the right boundary?
		bhs.s	.CaseLaserStopMove		; If so, branch
		bra.s	.CaseLaserMoveDisplay		; Display

.CaseBoundaryLaserChk2:
		cmp.w	oWFZMinX(a0),d0			; Has it reached the left boundary?
		bhs.s	.CaseLaserMoveDisplay		; If not, branch

.CaseLaserStopMove:
		clr.w	oXVel(a0)			; Stop moving

.CaseLaserMoveDisplay:
		jsr	ObjectMove.w			; Move
		jmp	DisplayObject.w			; Display

.CaseStopLaserDelete:
		addq.b	#2,oWFZRout(a0)			; Next routine
		move.w	#$E,oWFZTime2(a0)		; Timer the laser shooter to move back up
		bclr	#4,oStatus(a0)			; Do not allow collision restore
		bclr	#6,oStatus(a0)			; Do not allow flashing
		clr.b	oColType(a0)			; Disable collision
		movea.w	oWFZPar(a0),a1			; Delete laser
		jsr	DeleteOtherObj.w		; ''
		jmp	DisplayObject.w			; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.CaseLSUp:
		subq.w	#1,oWFZTime2(a0)		; Decrement timer
		beq.s	.CaseClosingAnim		; If it has run out, branch
		movea.w	oWFZChild3(a0),a1		; Get laser shooter object
		subq.w	#1,oY(a1)			; Make it move up
		jmp	DisplayObject.w			; Display

.CaseClosingAnim:
		addq.b	#2,oWFZRout(a0)			; Next routine
		move.b	#1,oAni(a0)			; Set animation
		jmp	DisplayObject.w			; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.CaseStartOver:
		move.b	#8,oWFZRout(a0)			; Reset routine
		bsr.w	.CaseXSpeed			; Go to that routine
		jmp	DisplayObject.w			; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.CaseDefeated:
		clr.b	oColType(a0)			; Disable collision
		st	oHitCnt(a0)			; Set hit count to -1
		bclr	#6,oStatus(a0)			; Do not allow flashing
		subq.w	#1,oWFZTime(a0)			; Decrement timer
		bmi.s	.CaseEnd			; If it has run out, branch
		bsr.w	ObjWFZBoss_Explode		; Explode
		jmp	DisplayObject.w			; Display

.CaseEnd:
		playSnd	#Mus_Stop, 1
		st	r_Boss_Defeat.w
		move.b	#45,(r_Obj_Player+oDeathTimer).w
		jsr	DeleteObject.w			; Delete ourselves
		addq.w	#4,sp				; Don't return to caller
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjWFZBoss_LaserWall:
		moveq	#0,d0
		move.b	oWFZRout(a0),d0			; Get routine ID
		move.w	.Index(pc,d0.w),d0		; Get routine offset
		jsr	.Index(pc,d0.w)			; Jump to it
		moveq	#$13,d1				; Width
		moveq	#$40,d2				; Height
		move.w	#$80,d3				; ''
		move.w	oX(a0),d4			; X position
		jmp	SolidObject			; Make ourselves solid

.End:
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.Index:
		dc.w	.LaserWallMappings-.Index	; Set the map frame
		dc.w	.LaserWallWaitDelete-.Index	; Wait for deletion
		dc.w	.LaserWallDelete-.Index		; Get deleted
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.LaserWallMappings:
		addq.b	#2,oWFZRout(a0)			; Next routine
		move.b	#$C,oFrame(a0)			; Set map frame
		jmp	DisplayObject.w			; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.LaserWallWaitDelete:
		movea.w	oWFZPar(a0),a1			; Get parent object
		btst	#5,oStatus(a1)			; Are we to be destroyed yet?
		bne.s	.LaserWallTImerSet		; If so, branch
		not.b	oWFZDisp(a0)			; Make us flash
		bne.s	.End				; If it's not time to display, branch
		jmp	DisplayObject.w			; Display

.LaserWallTimerSet:
		addq.b	#2,oWFZRout(a0)			; Next routine
		move.b	#4,oWFZTime(a0)			; Set timer
		jmp	DisplayObject.w			; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.LaserWallDelete:
		subq.b	#1,oAniTimer(a0)		; Decrement animation timer
		bpl.s	.End				; If it hasn't run out, branch
		move.b	oAniTimer(a0),d0		; Get animation timer
		move.b	oAniFrame(a0),d1		; Get animation frame
		addq.b	#2,d0				; Increment timer
		bpl.s	.LaserWallDisplay		; If it's positive, branch
		move.b	d1,oAniTimer(a0)		; Set timer
		subq.b	#1,oWFZTime(a0)			; Decrement timer
		bpl.s	.LaserWallDisplay		; If it hasn't run out, branch
		move.b	#$10,oWFZTime(a0)		; Reset timer
		addq.b	#1,d1				; Increment animation frame and timer
		cmpi.b	#5,d1				; Are we to delete ourselves?
		blo.s	.LaserWallSetAniTimer		; If not, branch
		jsr	DeleteObject.w			; Delete ourselves
		addq.w	#4,sp				; Don't return to caller
		rts

.LaserWallSetAniTimer:
		move.b	d1,oAniFrame(a0)		; Set animation frame
		move.b	d1,oAniTimer(a0)		; Set animation timer

.LaserWallDisplay:
		clr.b	oWFZDisp(a0)			; Reset display flag
		jmp	DisplayObject.w			; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjWFZBoss_PtfmReleaser:
		moveq	#0,d0
		move.b	oWFZRout(a0),d0			; Get routine ID
		move.w	.Index(pc,d0.w),d0		; Get routine offset
		jmp	.Index(pc,d0.w)			; Jump to it
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.Index:
		dc.w	.PtfmReleaserInit-.Index	; Initialize
		dc.w	.PtfmReleaserWaitDown-.Index	; Wait for the laser case to mvoe down
		dc.w	.PtfmReleaserDown-.Index	; Wait until time limit is up
		dc.w	.PtfmReleaserLoadWait-.Index	; Wait to load the platforms
		dc.w	.PtfmReleaserDelete-.Index	; Explode
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.PtfmReleaserInit:
		addq.b	#2,oWFZRout(a0)			; Next routine
		move.b	#5,oFrame(a0)			; Set map frame
		addq.w	#8,oY(a0)			; Shift down
		jmp	DisplayObject.w			; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.PtfmReleaserWaitDown:
		movea.w	oWFZPar(a0),a1			; Get parent object
		btst	#2,oStatus(a1)			; Has the laser case moved down all the way?
		bne.s	.PtfmReleaserSetDown		; If so, branch
		jmp	DisplayObject.w			; Display

.PtfmReleaserSetDown:
		addq.b	#2,oWFZRout(a0)			; Next routine
		move.w	#$40,oWFZTime2(a0)		; Time to go down
		move.w	#$40,oYVel(a0)			; Y velocity
		jmp	DisplayObject.w			; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.PtfmReleaserDown:
		subq.w	#1,oWFZTime2(a0)		; Decrement timer
		beq.s	.PtfmReleaserStop		; If it has run out, branch
		jsr	ObjectMove.w			; Move
		jmp	DisplayObject.w			; Display

.PtfmReleaserStop:
		addq.b	#2,oWFZRout(a0)			; Next routine
		clr.w	oYVel(a0)			; Stop moving
		move.w	#$40,oWFZTime2(a0)		; Time to wait until platforms are released
		jmp	DisplayObject.w			; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.PtfmReleaserLoadWait:
		movea.w	oWFZPar(a0),a1			; Get parent object
		btst	#5,oStatus(a1)			; Should we be destroyed?
		bne.s	.PtfmReleaserDestroyP		; If so, branch
		subq.w	#1,oWFZTime2(a0)		; Decrement timer
		bne.s	.PtfmReleaserDisplay		; If it hasn't run out, branch
		move.w	#$80,oWFZTime2(a0)		; Reset timer
		moveq	#0,d0
		move.b	oWFZPtfmCnt(a0),d0		; Get platform count
		addq.b	#1,d0				; Increment it
		cmpi.b	#3,d0				; Have 3 been loaded?
		blo.s	.PtfmReleaserLoadP		; If not, branch
		moveq	#0,d0

.PtfmReleaserLoadP:
		move.b	d0,oWFZPtfmCnt(a0)		; Set platform count
		tst.b	oWFZPtfmFlags(a0,d0.w)		; Has this object already been loaded?
		bne.s	.PtfmReleaserDisplay		; If so, branch
		st	oWFZPtfmFlags(a0,d0.w)		; Set the loaded flag
		lea	ObjWFZBoss_PlatformData,a2	; Load platform
		jsr	LoadChildObject.w		; ''
		move.b	oWFZPtfmCnt(a0),oWFZPtfmID(a1)	; Set platform ID

.PtfmReleaserDisplay:
		jmp	DisplayObject.w			; Display

.PtfmReleaserDestroyP:
		addq.b	#2,oWFZRout(a0)			; Next routine
		bset	#5,oStatus(a0)			; Destroy platforms
		jmp	DisplayObject.w			; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.PtfmReleaserDelete:
		movea.w	oWFZPar(a0),a1			; Get parent object
		cmpi.l	#ObjWFZBoss,oAddr(a1)		; Is it the WFZ boss object?
		bne.s	.Delete				; If not, branch
		bsr.w	ObjWFZBoss_Explode		; Explode
		jmp	DisplayObject.w			; Display

.Delete:
		jmp	DeleteObject.w			; Delete ourselves
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjWFZBoss_Platform:
		moveq	#0,d0
		move.b	oWFZRout(a0),d0			; Get routine ID
		move.w	.Index(pc,d0.w),d0		; Get routine offset
		jsr	.Index(pc,d0.w)			; Jump to it
		lea	Ani_ObjWFZBoss,a1		; Animate
		jsr	AnimateObject.w			; ''
		jmp	DisplayObject.w			; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.Index:
		dc.w	.PlatformInit-.Index		; Initialize
		dc.w	.PlatformWaitDown-.Index	; Wait til platform to mvoe down
		dc.w	.PlatformTurn-.Index		; Wait until time limit is up and if it is, change direction
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.PlatformInit:
		addq.b	#2,oWFZRout(a0)			; Next routine
		move.b	#3,oAni(a0)			; Animation
		move.b	#7,oFrame(a0)			; Map frame
		move.w	#$100,oYVel(a0)			; Y velocity
		move.w	#$60,oWFZTime2(a0)		; Time before the platform can move horizontally
		move.b	#8,oColW(a0)
		move.b	#8,oColH(a0)
		lea	ObjWFZBoss_PtfmHurtData,a2	; Load the hurtful part of the platform
		jmp	LoadChildObject.w		; ''
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.PlatformWaitDown:
		bsr.w	.PlatformChkExplode		; Check if we should destroy ourselves
		subq.w	#1,oWFZTime2(a0)		; Decrement timer
		beq.s	.PlatformLeft			; If it has run out, branch
		bra.s	.PlatformSolid			; Make us solid

.PlatformLeft:
		addq.b	#2,oWFZRout(a0)			; Next routine
		move.w	#$60,oWFZTime2(a0)		; Turn timer
		move.w	#-$100,oXVel(a0)		; Go left
		move.w	oY(a0),oWFZPtfmY(a0)		; Save Y position
		bra.s	.PlatformSolid			; Make us solid
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.PlatformTurn:
		bsr.w	.PlatformChkExplode		; Check if we should destroy ourselves
		subq.w	#1,oWFZTime2(a0)		; Decrement timer
		bne.s	.PlatformChkDir			; If it hasn't run out, branch
		move.w	#$C0,oWFZTime2(a0)		; Reset timer
		neg.w	oXVel(a0)			; Go the other way

.PlatformChkDir:
		moveq	#4,d0				; Y acceleration
		move.w	oY(a0),d1			; Get Y
		cmp.w	oWFZPtfmY(a0),d1		; Has it gone beyond the initial Y position?
		blo.s	.PlatformChgY			; If so, branch
		neg.w	d0				; Negate the acceleration

.PlatformChgY:
		add.w	d0,oYVel(a0)			; Apply acceleration

.PlatformSolid:
		move.w	oX(a0),-(sp)			; Save X
		jsr	ObjectMove.w			; Move
		moveq	#$10,d1				; Width
		moveq	#8,d2				; Height
		moveq	#8,d3				; ''
		move.w	(sp)+,d4			; X position
		jmp	PlatformObject			; Make us a platform
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.PlatformChkExplode:
		movea.w	oWFZPar(a0),a1			; Get parent object
		btst	#5,oStatus(a1)			; Should we explode?
		bne.s	.PlatformExplode		; If so, branch
		rts

.PlatformExplode:
		move.b	oStatus(a0),d0			; Get status
		andi.b	#cStand,d0			; Are we being stood on?
		beq.s	.PtfmMakeExplode		; If not, branch
		bclr	#cStandBit,oStatus(a0)		; Clear the stood on bit
		beq.s	.PtfmMakeExplode		; If Sonic wasn't standing on us, branch
		bclr	#3,(r_Obj_Player+oStatus).w	; Make Sonic not stand on us
		bset	#1,(r_Obj_Player+oStatus).w	; Make him fall

.PtfmMakeExplode:
		move.l	#ObjBossExplode,oAddr(a0)	; Explode
		clr.b	oRoutine(a0)			; Reset routine
		movea.w	oWFZChild3(a0),a1		; Get hurt object
		jsr	DeleteOtherObj.w		; Delete it
		addq.w	#4,sp				; Don't return to caller
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjWFZBoss_PlatformHurt:
		moveq	#0,d0
		move.b	oWFZRout(a0),d0			; Get routine ID
		move.w	.Index(pc,d0.w),d0		; Get routine offset
		jmp	.Index(pc,d0.w)			; Jump to it
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.Index:
		dc.w	.PtfmHurtCol-.Index		; Initialize
		dc.w	.PtfmHurtFollow-.Index		; Follow the platform
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.PtfmHurtCol:
		addq.b	#2,oWFZRout(a0)			; Next routine
		move.b	#4,oColType(a0)			; Indestructable
		move.b	#8,oColW(a0)			; Set collision boundaries
		move.b	#4,oColH(a0)			; ''
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.PtfmHurtFollow:
		movea.w	oWFZPar(a0),a1			; Get parent object
		btst	#5,oStatus(a1)			; Should we destroy ourselves?
		bne.s	.PtfmHurtDelete			; If so, branch
		move.w	oX(a1),oX(a0)			; Follow the platform
		move.w	oY(a1),d0			; ''
		addi.w	#$C,d0				; ''
		move.w	d0,oY(a0)			; ''
		rts

.PtfmHurtDelete:
		jmp	DeleteObject.w			; Delete ourselves
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjWFZBoss_LaserShooter:
		movea.w	oWFZPar(a0),a1			; Get parent object
		btst	#5,oStatus(a1)			; Are we to be destroyed?
		beq.s	.RunRoutines			; If not, branch
		jmp	DeleteObject.w			; Delete ourselves

.RunRoutines:
		moveq	#0,d0
		move.b	oWFZRout(a0),d0			; Get routine ID
		move.w	.Index(pc,d0.w),d0		; Get routine offset
		jmp	.Index(pc,d0.w)			; Jump to it
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.Index:
		dc.w	.LaserShooterInit-.Index
		dc.w	.LaserShooterFollow-.Index
		dc.w	.LaserShooterDown-.Index
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.LaserShooterInit:
		addq.b	#2,oWFZRout(a0)			; Next routine
		move.b	#4,oFrame(a0)			; Set map frame
		jmp	DisplayObject.w			; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.LaserShooterFollow:
		move.w	oX(a1),oX(a0)			; Follow the parent object
		move.w	oY(a1),oY(a0)			; ''
		jmp	DisplayObject.w			; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.LaserShooterDown:
		move.w	oX(a1),oX(a0)			; Follow the parent object horizontally
		jmp	DisplayObject.w			; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjWFZBoss_Laser:
		movea.w	oWFZPar(a0),a1			; Get parent object
		btst	#5,oStatus(a1)			; Are we to be destroyed?
		beq.s	.RunRoutines			; If not, branch
		jmp	DeleteObject.w			; Delete ourselves

.RunRoutines:
		moveq	#0,d0
		move.b	oWFZRout(a0),d0			; Get routine ID
		move.w	.Index(pc,d0.w),d0		; Get routine offset
		jsr	.Index(pc,d0.w)			; Jump to it
		not.b	oWFZDisp(a0)			; Make us flash
		bne.s	.End				; If it's not time to display, branch
		jmp	DisplayObject.w			; Display

.End:
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.Index:
		dc.w	.LaserInit-.Index
		dc.w	.LaserFlash-.Index
		dc.w	.LaserWaitShoot-.Index
		dc.w	.LaserShoot-.Index
		dc.w	.LaserMove-.Index
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.LaserInit:
		addq.b	#2,oWFZRout(a0)			; Next routine
		move.b	#$D,oFrame(a0)			; Set map frame
		move.w	#r_Spr_Input+$200,oPrio(a0)	; Priority
		clr.b	oColType(a0)			; Disable collision
		addi.w	#$D,oY(a0)			; Shift down
		move.b	#$C,oAniFrame(a0)		; Set animation frame
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.LaserFlash:
		st	oWFZDisp(a0)			; Set "no display" flag
		subq.b	#1,oAniTimer(a0)		; Decrement timer
		bpl.s	.LaserNoLaser			; If it hasn't run out, branch
		move.b	oAniTimer(a0),d0		; Get animation timer
		addq.b	#2,d0				; Increment it
		bpl.s	.LaserFlicker			; If it's positive, branch
		move.b	oAniFrame(a0),d0		; Get animation frame
		subq.b	#1,d0				; Decrement it
		beq.s	.LaserNext			; If it's 0, branch
		move.b	d0,oAniFrame(a0)		; Set animation frame
		move.b	d0,oAniTimer(a0)		; Set animation timer

.LaserFlicker:
		clr.b	oWFZDisp(a0)			; Reset display flag

.LaserNoLaser:
		rts

.LaserNext:
		addq.b	#2,oWFZRout(a0)			; Next routine
		move.w	#$40,oWFZTime2(a0)		; How much to wait until we shoot
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.LaserWaitShoot:
		subq.w	#1,oWFZTime2(a0)		; Decrement timer
		bmi.s	.LaserStartShooting		; If it has run out, branch
		rts

.LaserStartShooting:
		addq.b	#2,oWFZRout(a0)			; Next routine
		addi.w	#$10,oY(a0)			; Shift down
		move.b	#$10,oColW(a0)			; Set collision width
		move.b	#4,oColType(a0)			; Indestructable
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.LaserShoot:
		moveq	#0,d0
		move.b	oWFZLaser(a0),d0		; Get laser frame
		addq.b	#1,d0				; Increment it
		cmpi.b	#5,d0				; Have we reached the max?
		bhs.s	.LaserShotOut			; If so, branch
		addi.w	#$10,oY(a0)			; Shift down
		move.b	d0,oWFZLaser(a0)		; Set new laser frame
		move.b	.LaserMapData(pc,d0.w),oFrame(a0)
		move.b	.LaserColHData(pc,d0.w),oColH(a0)
		rts

.LaserShotOut:
		addq.b	#2,oWFZRout(a0)			; Next routine
		bset	#2,oStatus(a0)			; Set shot out flag
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.LaserMapData:	dc.b	$E, $F, $10, $11, $12, 0
.LaserColHData:	dc.b	4, 20, 36, 52, 68, 84
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.LaserMove:
		movea.w	oWFZPar(a0),a1			; Get parent object
		move.w	oX(a1),oX(a0)			; Follow it
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Handle hits
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjWFZBoss_HandleHits:
		tst.b	oHitCnt(a0)			; Are there any hits left?
		beq.s	.Defeated			; If not, branch
		tst.b	oColType(a0)			; Should we flash?
		bne.s	.End				; If not, branch

		tst.b	oWFZTime(a0)			; Have we set the flash timer yet?
		bne.s	.Flash				; If so, branch
		btst	#6,oStatus(a0)			; Should we flash at all?
		beq.s	.End				; If not, branch
		move.b	#$20,oWFZTime(a0)		; Set flash timer
		playSnd	#sBossHit, 2			; Play boss hit sound

.Flash:
		lea	(r_Palette+$22).w,a1		; Color to flash
		moveq	#0,d0				; Set to black
		tst.w	(a1)				; Is it black?
		bne.s	.ChkRestoreCol			; If not, branch
		move.w	#$EEE,d0			; Set to white

.ChkRestoreCol:
		move.w	d0,(a1)				; Set color
		subq.b	#1,oWFZTime(a0)			; Decrement timer
		bne.s	.End				; If it hasn't run out, branch
		btst	#4,oStatus(a0)			; Should we restore collision?
		beq.s	.End				; If not, branch
		move.b	#2,oColType(a0)			; Restore collision

.End:
		rts

.Defeated:
		clr.b	oColType(a0)			; Stop collision
		move.w	#$EF,oWFZTime(a0)		; Set timer
		move.b	#$1E,oWFZRout(a0)		; Set routine
		bset	#5,oStatus(a0)			; Set destroy flag
		bclr	#6,oStatus(a0)			; Disable collision
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Create an explosion
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjWFZBoss_Explode:
		move.b	(r_Frame_Cnt+3).w,d0		; Get frame count
		andi.b	#7,d0				; Is the current frame a multiple of 8?
		bne.s	.End				; If not, branch
		jsr	FindFreeObj.w			; Find a free object slot
		bne.s	.End				; If there is none, branch
		move.l	#ObjBossExplode,oAddr(a1)	; Load explosion
		move.w	oX(a0),oX(a1)			; X position
		move.w	oY(a0),oY(a1)			; Y position
		jsr	RandomNumber.w			; Get random number
		moveq	#0,d1
		move.b	d0,d1				; Copy for use with X position
		lsr.b	#2,d1				; Manipulate the seed
		subi.w	#$20,d1				; ''
		add.w	d1,oX(a1)			; Apply to X
		lsr.w	#8,d0				; Manipulate the ssed
		lsr.b	#2,d0				; ''
		subi.w	#$20,d0				; ''
		add.w	d0,oY(a1)			; Apply to Y

.End:
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Initialize WFZ boss variables
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjWFZBoss_InitVars:
		move.l	(a1)+,oMap(a0)			; Mappings
		move.w	(a1)+,oVRAM(a0)			; Tile properties
		move.w	(a1)+,oPrio(a0)			; Priority
		move.b	(a1)+,d0			; Render flags
		or.b	d0,oRender(a0)			; ''
		move.b	(a1)+,oDrawW(a0)		; Draw width
		move.b	(a1)+,oDrawH(a0)		; Draw height
		move.b	(a1)+,oColType(a0)		; Collision type
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; WFZ boss initial variables
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjWFZBoss_VarsList:
		dc.w	0
		dc.w	.LaserCaseVars-ObjWFZBoss_VarsList
		dc.w	.LaserWallVars-ObjWFZBoss_VarsList
		dc.w	.GeneralVars-ObjWFZBoss_VarsList
		dc.w	.GeneralVars-ObjWFZBoss_VarsList
		dc.w	.GeneralVars-ObjWFZBoss_VarsList
		dc.w	.GeneralVars-ObjWFZBoss_VarsList
		dc.w	.GeneralVars-ObjWFZBoss_VarsList
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.LaserCaseVars:
		dc.l	Map_ObjWFZBoss
		dc.w	$480
		dc.w	r_Spr_Input+$200
		dc.b	4, $20, $10, 0
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.LaserWallVars:
		dc.l	Map_ObjWFZBoss
		dc.w	$480
		dc.w	r_Spr_Input+$80
		dc.b	4, 8, $80, 0
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.GeneralVars:
		dc.l	Map_ObjWFZBoss
		dc.w	$480
		dc.w	r_Spr_Input+$280
		dc.b	4, $10, $10, 0
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; WFZ boss child object data
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjWFZBoss_LaserWallData:
		dc.w	oWFZPar, oWFZChild1
		dc.l	ObjWFZBoss
		dc.b	$04
		even
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjWFZBoss_PlatformData:
		dc.w	oWFZPar, oWFZChild4
		dc.l	ObjWFZBoss
		dc.b	$08
		even
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjWFZBoss_PtfmHurtData:
		dc.w	oWFZPar, oWFZChild3
		dc.l	ObjWFZBoss
		dc.b	$0A
		even
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjWFZBoss_LaserShootData:
		dc.w	oWFZPar, oWFZChild3
		dc.l	ObjWFZBoss
		dc.b	$0C
		even
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjWFZBoss_PtfmReleaserData:
		dc.w	oWFZPar, oWFZChild2
		dc.l	ObjWFZBoss
		dc.b	$06
		even
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjWFZBoss_LaserData:
		dc.w	oWFZPar, oWFZPar
		dc.l	ObjWFZBoss
		dc.b	$0E
		even
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Data
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ArtKosM_WFZBoss:
		incbin	"Level/Objects/Boss - WFZ/Art.kosm.bin"
		even
Ani_ObjWFZBoss:
		dc.w	.Ani0-Ani_ObjWFZBoss
		dc.w	.Ani1-Ani_ObjWFZBoss
		dc.w	.Ani2-Ani_ObjWFZBoss
		dc.w	.Ani3-Ani_ObjWFZBoss
.Ani0:		dc.b	5, 0, 1, 2, 3, 3, 3, 3, $FA, 0
.Ani1:		dc.b	3, 3, 2, 1, 0, 0, $FA, 0
.Ani2:		dc.b	3, 5, 6, $FF
.Ani3:		dc.b	3, 7, 8, 9, $A, $B, $FF
		even
Map_ObjWFZBoss:
		include	"Level/Objects/Boss - WFZ/Mappings.asm"
		even
; =========================================================================================================================================================