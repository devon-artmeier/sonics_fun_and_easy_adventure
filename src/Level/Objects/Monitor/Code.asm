; =========================================================================================================================================================
; Sonic's Fun And Easy Adventure
; By Ralakimus/Novedicus 2017
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Monitor object
; =========================================================================================================================================================
		rsset	oLvlSSTs
oMonFall	rs.b	1				; Fall flag
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjMonitor:
		move.l	#ObjMonitor_Main,oAddr(a0)
		move.b	#$E,oColH(a0)
		move.b	#$E,oColW(a0)
		move.l	#Map_ObjMonitor,oMap(a0)
		move.w	#$588,oVRAM(a0)
		move.b	#4,oRender(a0)
		move.w	#r_Spr_Input+$180,oPrio(a0)
		move.b	#$F,oDrawW(a0)
		move.b	#$F,oDrawH(a0)
		move.w	oRespawn(a0),d0
		beq.s	ObjMonitor_NotBroken
		movea.w	d0,a2
		btst	#0,(a2)				; has monitor been broken?
		beq.s	ObjMonitor_NotBroken		; if not, branch
		move.b	#7,oFrame(a0)		; use broken monitor frame
		move.l	#CheckObjActive_Draw,oAddr(a0)
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjMonitor_NotBroken:
		move.b	#6,oColType(a0)
		move.b	oSubtype(a0),oAni(a0)

ObjMonitor_Main:
		bsr.s	ObjMonitor_Fall
		move.w	#$19,d1
		move.w	#$10,d2
		move.w	d2,d3
		move.w	oX(a0),d4
		lea	r_Obj_Player.w,a1
		bsr.w	SolidObject_Monitor

		move.w	r_Max_Cam_Y.w,d0
		addi.w	#$E0,d0
		cmp.w	oY(a0),d0
		blt.s	ObjMonitor_Delete

		jsr	AddToColResponse
		lea	Ani_ObjMonitor(pc),a1
		jsr	AnimateObject.w
		jmp	CheckObjActive_Draw.w

ObjMonitor_Delete:
		jmp	DeleteObject.w
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjMonitor_Animate:
		cmpi.b	#7,oFrame(a0)
		bcs.s	.NotBroken
		move.l	#CheckObjActive_Draw,oAddr(a0)

.NotBroken:
		lea	Ani_ObjMonitor(pc),a1
		jsr	AnimateObject.w
		jmp	CheckObjActive_Draw.w
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjMonitor_Fall:
		move.b	oMonFall(a0),d0
		beq.s	.End
		jsr	ObjectMoveAndFall.w
		tst.w	oYVel(a0)
		bmi.s	.End
		jsr	ObjCheckFloorDist
		tst.w	d1
		beq.s	.InGround
		bpl.s	.End

.InGround:
		add.w	d1,oY(a0)
		clr.w	oYVel(a0)
		clr.b	oMonFall(a0)

.End:
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
SolidObject_Monitor:
		btst	#cStandBit,oStatus(a0)
		bne.s	ObjMonitor_ChkOverEdge
		cmpi.b	#2,oAni(a1)
		beq.s	.End
		cmpi.b	#$17,oAni(a1)		; check if in drowning animation
		bne.s	.SetSolid

.End:
		rts

.SetSolid:
		jmp	SolidObject_ChkCollision

ObjMonitor_ChkOverEdge:
		move.w	d1,d2
		add.w	d2,d2
		btst	#1,oStatus(a1)
		bne.s	.NotOnMonitor
		move.w	oX(a1),d0
		sub.w	oX(a0),d0
		add.w	d1,d0
		bmi.s	.NotOnMonitor
		cmp.w	d2,d0
		blo.s	ObjMonitor_CharStandOn

.NotOnMonitor:
		bclr	#cStandBit,oStatus(a1)
		bset	#1,oStatus(a1)
		bclr	#cStandBit,oStatus(a0)
		moveq	#0,d4
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjMonitor_CharStandOn:
		move.w	d4,d2
		jsr	Player_MoveOnPtfm
		moveq	#0,d4
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjMonitor_BreakOpen:
		playSnd	#sBreakItem, 2			; Play destroy sound
		
		move.b	oStatus(a0),d0
		andi.b	#cStand|cPush,d0
		beq.s	ObjMonitor_SpawnIcon
		andi.b	#$D7,(r_Obj_Player+oStatus).w
		ori.b	#2,(r_Obj_Player+oStatus).w

ObjMonitor_SpawnIcon:
		clr.b	oStatus(a0)
		move.b	#0,oColType(a0)
		jsr	FindFreeObj.w
		bne.s	.SkipIconCreation
		move.l	#ObjMonitorContents,oAddr(a1)		; load monitor contents	object
		move.w	oX(a0),oX(a1)
		move.w	oY(a0),oY(a1)
		move.b	oAni(a0),oAni(a1)
		move.b	oRender(a0),oRender(a1)
		move.b	oStatus(a0),oStatus(a1)

.SkipIconCreation:
		jsr	FindFreeObj.w
		bne.s	.SkipExplosionCreation
		move.l	#ObjExplosion,oAddr(a1)			; load explosion object
		move.w	oX(a0),oX(a1)
		move.w	oY(a0),oY(a1)
		addq.b	#2,oRoutine(a1)

.SkipExplosionCreation:
		move.w	oRespawn(a0),d0
		beq.s	.NotRemembered
		movea.w	d0,a2
		bset	#0,(a2)

.NotRemembered:
		move.b	#6,oAni(a0)
		move.l	#ObjMonitor_Animate,oAddr(a0)
		jmp	DisplayObject.w
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Contents of monitor object
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjMonitorContents:
		moveq	#0,d0
		move.b	oRoutine(a0),d0
		move.w	ObjMonitorContents_Index(pc,d0.w),d1
		jmp	ObjMonitorContents_Index(pc,d1.w)
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjMonitorContents_Index:
		dc.w	ObjMonitorContents_Main-ObjMonitorContents_Index
		dc.w	ObjMonitorContents_Move-ObjMonitorContents_Index
		dc.w	ObjMonitorContents_Delete-ObjMonitorContents_Index
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjMonitorContents_Main:
		addq.b	#2,oRoutine(a0)
		move.w	#$8588,oVRAM(a0)
		move.b	#$24,oRender(a0)
		move.w	#r_Spr_Input+$180,oPrio(a0)
		move.b	#8,oDrawW(a0)
		move.b	#8,oDrawH(a0)
		move.w	#-$300,oYVel(a0)
		moveq	#0,d0
		move.b	oAni(a0),d0
		addq.b	#1,d0
		move.b	d0,oFrame(a0)
		movea.l	#Map_ObjMonitor,a1
		add.b	d0,d0
		adda.w	(a1,d0.w),a1
		addq.w	#2,a1
		move.l	a1,oMap(a0)

ObjMonitorContents_Move:
		tst.w	oYVel(a0)			; is object moving?
		bpl.w	ObjMonitorContents_GetType	; if not, branch
		jsr	ObjectMove.w
		addi.w	#$18,oYVel(a0)			; reduce object	speed
		jmp	DisplayObject.w
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjMonitorContents_GetType:
		addq.b	#2,oRoutine(a0)
		move.w	#29,oAniTimer(a0)
		move.b	oAni(a0),d0
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
		cmpi.b	#1,d0
		bne.s	.ChkRings
		push.l	a0
		movea.l	a0,a2
		lea	r_Obj_Player.w,a0
		jsr	ObjSonic_GetHurt
		pop.l	a0
		jmp	DisplayObject.w
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.ChkRings:
		cmpi.b	#2,d0
		bne.s	.Display
		addi.w	#10,r_Rings.w 				; add 10 rings to the number of rings you have
		ori.b	#1,r_Update_Rings.w 			; update the ring counter
		playSnd	#sRing, 2				; Play ring sound
		jmp	DisplayObject.w
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.Display:
		jmp	DisplayObject.w
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjMonitorContents_Delete:
		subq.w	#1,oAniTimer(a0)
		bpl.s	.NoDelete
		jmp	DeleteObject.w

.NoDelete:
		jmp	DisplayObject.w
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Data
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ArtKosM_Monitor:
		incbin	"Level/Objects/Monitor/Art.kosm.bin"
		even
Map_ObjMonitor:
		include	"Level/Objects/Monitor/Mappings.asm"
Ani_ObjMonitor:
		include	"Level/Objects/Monitor/Animations.asm"
; =========================================================================================================================================================