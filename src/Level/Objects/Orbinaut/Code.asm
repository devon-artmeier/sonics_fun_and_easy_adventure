; =========================================================================================================================================================
; Sonic's Fun And Easy Adventure
; By Ralakimus/Novedicus 2017
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Orbinaut object
; =========================================================================================================================================================
		rsset	oLvlSSTs
oOrbPar		rs.w	1
oOrbAngleSpd	rs.b	1
oOrbProjCnt	rs.b	1
oOrbProjs	rs.w	4
oOrbProjAngle	rs.b	1
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjOrbinaut:
		move.l	#ObjOrbinaut_Main,oAddr(a0)	; Next routine
		move.l	#Map_ObjOrbinaut,oMap(a0)	; Mappings
		move.w	#$38D,oVRAM(a0)			; Tile properties
		ori.b	#4,oRender(a0)			; Render flags
		move.w	#r_Spr_Input+$200,oPrio(a0)	; Priority
		move.b	#8,oDrawW(a0)			; Sprite width
		move.b	#8,oDrawH(a0)			; Sprite height
		move.b	#8,oColW(a0)			; Collision width
		move.b	#8,oColH(a0)			; Collision height
		move.b	#2,oColType(a0)			; Enemy

		moveq	#0,d2				; Angle
		lea	oOrbProjs(a0),a2		; Projectile pointers
		moveq	#3,d1				; Number of projectiles

.MakeProjectiles:
		jsr	FindNextFreeObj.w		; Find a free object slot
		bne.s	.AngleSpd			; If there are none, branch
		addq.b	#1,oOrbProjCnt(a0)		; Increment projectile count
		move.w	a1,(a2)+			; Save pointer
		move.l	#ObjOrbinaut_Proj,oAddr(a1)	; Load a projectile
		move.l	oMap(a0),oMap(a1)		; Mappings
		move.w	oVRAM(a0),oVRAM(a1)		; Tile properties
		ori.b	#4,oRender(a1)			; Render flags
		move.w	#r_Spr_Input+$200,oPrio(a1)	; Priority
		move.b	#4,oDrawW(a1)			; Sprite width
		move.b	#4,oDrawH(a1)			; Sprite height
		move.b	#4,oColW(a1)			; Collision width
		move.b	#4,oColH(a1)			; Collision height
		move.b	#3,oFrame(a1)			; Map frame
		move.b	#4,oColType(a1)			; Indestructable
		move.b	d2,oOrbProjAngle(a1)		; Angle
		addi.b	#$40,d2				; Increment angle
		move.w	a0,oOrbPar(a1)			; Parent object
		dbf	d1,.MakeProjectiles		; Loop

.AngleSpd:
		move.w	#-$40,oXVel(a0)			; X velocity
		moveq	#1,d0				; Angle speed
		btst	#0,oStatus(a0)			; Are we facing left?
		beq.s	.SetAngleSpd			; If not, branch
		neg.w	d0				; Reverse angle speed
		neg.w	oXVel(a0)			; Go the other way

.SetAngleSpd:
		move.b	d0,oOrbAngleSpd(a0)		; Set angle speed
		jmp	AddToColResponse		; Allow collision
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjOrbinaut_Empty:
		jsr	ObjectMove.w			; Move
		jsr	AddToColResponse		; Allow collision
		bra.s	ObjOrbinaut_ChkDel		; Continue
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjOrbinaut_Main:
		move.w	(r_Obj_Player+oX).w,d0		; Get horizontal distance from player
		sub.w	oX(a0),d0			; ''
		bcc.s	.ChkXRange			; If Sonic is right of us, branch
		neg.w	d0				; Get absolute value

.ChkXRange:
		cmpi.w	#$A0,d0				; Is Sonic in horizontal range?
		bcc.s	.Display			; If not, branch
		
		move.w	(r_Obj_Player+oY).w,d0		; Get vertical distance from player
		sub.w	oY(a0),d0			; ''
		bcc.s	.ChkYRange			; If Sonic is above us, branch
		neg.w	d0				; Get absolute value

.ChkYRange:
		cmpi.w	#$50,d0				; Is Sonic in vertical range?
		bcc.s	.Display			; If not, branch
		move.b	#1,oAni(a0)			; Use angry face

.Display:
		lea	Ani_ObjOrbinaut(pc),a1		; Animate
		jsr	AnimateObject.w			; ''
		jsr	AddToColResponse		; Allow collision

ObjOrbinaut_ChkDel:
		move.w	oX(a0),d0			; Get X position
		andi.w	#$FF80,d0			; Only allow multiples of $80
		sub.w	r_Obj_X_Coarse.w,d0		; Subtract the camera's coarse X position
		cmpi.w	#$280,d0			; Has it gone offscreen?
		bhi.s	.ChkRespawn			; If so, branch
		jmp	DisplayObject.w			; Display the sprite

.ChkRespawn:
		move.w	oRespawn(a0),d0			; Get respawn table entry address
		beq.s	.DelProjectiles			; If 0, branch
		movea.w	d0,a2
		bclr	#7,(a2)				; Mark as gone

.DelProjectiles:
		lea	oOrbProjCnt(a0),a2		; Projectiles
		moveq	#0,d2
		move.b	(a2)+,d2			; Get number of projectiles
		subq.w	#1,d2				; Convert for dbf
		bcs.s	.Delete				; If there are none, branch

.DelProjsLoop:
		move.w	(a2)+,a1			; Get projectile
		jsr	DeleteOtherObj.w		; Delete it
		dbf	d2,.DelProjsLoop		; Loop

.Delete:
		jmp	DeleteObject.w			; Delete ourselves
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjOrbinaut_Proj:
		movea.w	oOrbPar(a0),a1			; Get parent
		cmpi.l	#ObjOrbinaut_Main,oAddr(a1)	; Is it an orbinaut?
		bne.s	.Delete				; If not, branch
		cmpi.b	#2,oFrame(a1)			; Is the orbinaut angry?
		bne.s	.Circle				; If not, branch
		cmpi.b	#$40,oOrbProjAngle(a0)		; Are we under the orbinaut?
		bne.s	.Circle				; If not, branch
		move.l	#ObjOrbinaut_ProjRel,oAddr(a0)	; Release ourselves
		subq.b	#1,oOrbProjCnt(a1)		; Decrement projectile count
		bne.s	.Fire				; If there are still some left, branch
		move.l	#ObjOrbinaut_Empty,oAddr(a1)	; Next routine for the orbinaut

.Fire:
		move.w	#-$200,oXVel(a0)		; Go left
		btst	#0,oStatus(a1)			; Was the orbinaut facing left?
		beq.s	.Display			; If not, branch
		neg.w	oXVel(a0)			; Go the other way

.Display:
		jsr	AddToColResponse		; Allow collision
		jmp	DisplayObject.w			; Display

.Delete:
		jmp	DeleteObject.w			; Delete ourselves

.Circle:
		move.b	oOrbProjAngle(a0),d0		; Get angle
		jsr	CalcSine.w			; Get sine and cosine
		asr.w	#4,d1				; Fix cosine
		add.w	oX(a1),d1			; Add orbinaut's X to cosine
		move.w	d1,oX(a0)			; Set X
		asr.w	#4,d0				; Fix sine
		add.w	oY(a1),d0			; Add orbinaut's Y to sine
		move.w	d0,oY(a0)			; Set Y
		move.b	oOrbAngleSpd(a1),d0		; Get angle speed
		add.b	d0,oOrbProjAngle(a0)		; Add to angle
		jsr	AddToColResponse		; Allow collision
		jmp	DisplayObject.w			; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjOrbinaut_ProjRel:
		jsr	ObjectMove.w			; Move
		tst.b	oRender(a0)			; Are we offscreen?
		bpl.s	.Delete				; If so, branch
		jsr	AddToColResponse		; Allow collision
		jmp	DisplayObject.w			; Display

.Delete:
		jmp	DeleteObject.w			; Delete ourselves
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Data
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
Map_ObjOrbinaut:
		include	"Level/Objects/Orbinaut/Mappings.asm"
		even
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
Ani_ObjOrbinaut:
		dc.w	.Ani0-Ani_ObjOrbinaut
		dc.w	.Ani1-Ani_ObjOrbinaut
.Ani0:		dc.b	$F, 0, $FF, 0
.Ani1:		dc.b	$F, 1, 2, $FE, 1
		even
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ArtKosM_Orbinaut:
		incbin	"Level/Objects/Orbinaut/Art.kosm.bin"
		even
; =========================================================================================================================================================