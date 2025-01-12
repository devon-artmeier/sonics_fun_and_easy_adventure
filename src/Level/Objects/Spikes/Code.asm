; ===========================================================================
; Sonic's Fun And Easy Adventure
; By Ralakimus/Novedicus 2017
; ---------------------------------------------------------------------------
; Spike object
; ===========================================================================
		rsset	oLvlSSTs
oSpikeX		rs.w	1
oSpikeY		rs.w	1
oSpkMvOff	rs.w	1
oSpkMvState	rs.w	1
oSpkMvTime	rs.w	1
; ===========================================================================
ObjSpike:
		moveq	#0,d0
		move.b	oRoutine(a0),d0
		move.w	ObjSpike_Index(pc,d0.w),d1
		jmp	ObjSpike_Index(pc,d1.w)
; ===========================================================================
ObjSpike_Index:
		dc.w ObjSpike_Init-ObjSpike_Index
		dc.w ObjSpike_Upright-ObjSpike_Index
		dc.w ObjSpike_Sideways-ObjSpike_Index
		dc.w ObjSpike_UpsideDown-ObjSpike_Index
; ===========================================================================
ObjSpike_InitData:
		dc.b $10,$10	; 0	- Upright or ceiling spikes
		dc.b $10,$10	; 2	- Sideways spikes
; ===========================================================================
ObjSpike_Init:
		addq.b	#2,oRoutine(a0)
		move.l	#Map_ObjSpike,oMap(a0)
		move.w	#$6A8,oVRAM(a0)
		ori.b	#4,oRender(a0)
		move.w	#r_Spr_Input+$200,oPrio(a0)
		move.b	oSubtype(a0),d0
		andi.b	#$F,oSubtype(a0)
		andi.w	#$F0,d0
		lea	(ObjSpike_InitData).l,a1
		lsr.w	#3,d0
		adda.w	d0,a1
		move.b	(a1),oDrawW(a0)
		move.b	(a1)+,oColW(a0)
		move.b	(a1),oDrawH(a0)
		move.b	(a1)+,oColH(a0)
		lsr.w	#1,d0
		move.b	d0,oFrame(a0)
		cmpi.b	#1,d0
		bne.s	.ChkUpsideDown
		addq.b	#2,oRoutine(a0)
		move.w	#$6AC,oVRAM(a0)

.ChkUpsideDown:
		btst	#1,oStatus(a0)
		beq.s	.SavePos
		move.b	#6,oRoutine(a0)

.SavePos:
		move.w	oX(a0),oSpikeX(a0)
		move.w	oY(a0),oSpikeY(a0)

		bsr.w	MoveSpikes		; make the object move
		cmpi.b	#1,oFrame(a0)		; is object type $1x ?
		beq.s	ObjSpike_SideWays	; if yes, branch
; ===========================================================================
; Upright spikes
; ===========================================================================
ObjSpike_Upright:
		bsr.w	MoveSpikes
		moveq	#0,d1
		move.b	oDrawW(a0),d1
		addi.w	#$B,d1
		moveq	#0,d2
		move.b	oDrawH(a0),d2
		move.w	d2,d3
		addq.w	#1,d3
		move.w	oX(a0),d4
		jsr	SolidObject
		btst	#cStandBit,oStatus(a0)
		beq.s	ObjSpike_UprightEnd
		lea	(r_Obj_Player).w,a1
		bsr.w	Touch_ChkHurt2

ObjSpike_UprightEnd:
		move.w	oSpikeX(a0),d0
		jmp	CheckObjActive_Draw.w
; ===========================================================================
; Sideways spikes
; ===========================================================================
ObjSpike_Sideways:
		move.w	oX(a0),-(sp)	
		bsr.w	MoveSpikes
		moveq	#0,d1
		move.b	oDrawW(a0),d1
		addi.w	#$B,d1
		moveq	#0,d2
		move.b	oDrawH(a0),d2
		move.w	d2,d3
		addq.w	#1,d3
		move.w	(sp)+,d4
		jsr	SolidObject
		btst	#cTouchSideBit,d6
		beq.s	ObjSpike_SidewaysEnd
		lea	(r_Obj_Player).w,a1
		bsr.w	Touch_ChkHurt2

ObjSpike_SidewaysEnd:
		move.w	oSpikeX(a0),d0
		jmp	CheckObjActive_Draw.w
; ===========================================================================
; Upside down spikes
; ===========================================================================
ObjSpike_UpsideDown:
		bsr.w	MoveSpikes
		moveq	#0,d1
		move.b	oDrawW(a0),d1
		addi.w	#$B,d1
		moveq	#0,d2
		move.b	oDrawH(a0),d2
		move.w	d2,d3
		addq.w	#1,d3
		move.w	oX(a0),d4
		jsr	SolidObject
		btst	#cTouchBtmBit,d6
		beq.s	ObjSpike_UpsideDownEnd
		lea	(r_Obj_Player).w,a1
		bsr.w	Touch_ChkHurt2

ObjSpike_UpsideDownEnd:
		move.w	oSpikeX(a0),d0
		jmp	CheckObjActive_Draw.w
; ===========================================================================
Touch_ChkHurt2:
		tst.b	(r_Obj_Player+oInvulTime).w	; is Sonic invincible?
		bne.s	.End				; if yes, branch
		cmpi.b	#4,oRoutine(a1)
		beq.s	.End
		move.l	oY(a1),d3
		move.w	oYVel(a1),d0
		ext.l	d0
		asl.l	#8,d0
		sub.l	d0,d3
		move.l	d3,oY(a1)
		movea.l	a0,a2
		movea.l	a1,a0
		jsr	ObjSonic_GetHurt
		movea.l	a2,a0

.End:
		rts
; ===========================================================================
MoveSpikes:	
		moveq	#0,d0
		move.b	oSubtype(a0),d0
		add.w	d0,d0
		move.w	MoveSpikes_Behaviors(pc,d0.w),d1
		jmp	MoveSpikes_Behaviors(pc,d1.w)
; ===========================================================================
MoveSpikes_Behaviors:
		dc.w MoveSpikes_Still-MoveSpikes_Behaviors
		dc.w MoveSpikes_Vertical-MoveSpikes_Behaviors
		dc.w MoveSpikes_Horizontal-MoveSpikes_Behaviors
; ===========================================================================
MoveSpikes_Still:
		rts			; don't move the object
; ===========================================================================
MoveSpikes_Vertical:
		bsr.w	MoveSpikes_Delay
		moveq	#0,d0
		move.b	oSpkMvOff(a0),d0
		add.w	oSpikeY(a0),d0
		move.w	d0,oY(a0)	; move the object vertically
		rts
; ===========================================================================
MoveSpikes_Horizontal:
		bsr.w	MoveSpikes_Delay
		moveq	#0,d0
		move.b	oSpkMvOff(a0),d0
		add.w	oSpikeX(a0),d0
		move.w	d0,oX(a0)	; move the object horizontally
		rts
; ===========================================================================
MoveSpikes_Delay:
		tst.w	oSpkMvTime(a0)		; is time delay	= zero?
		beq.s	MoveSpikes_ChkDir		; if yes, branch
		subq.w	#1,oSpkMvTime(a0)	; subtract 1 from time delay
		bne.s	locret_CFE6
		tst.b	oRender(a0)
		bpl.s	locret_CFE6
		playSnd	#sSpikeMove, 2		; Play spike move sound
		bra.s	locret_CFE6
; ===========================================================================
MoveSpikes_ChkDir:
		tst.w	oSpkMvState(a0)
		beq.s	MoveSpikes_Retract
		subi.w	#$800,oSpkMvOff(a0)
		bcc.s	locret_CFE6
		move.w	#0,oSpkMvOff(a0)
		move.w	#0,oSpkMvState(a0)
		move.w	#60,oSpkMvTime(a0)	; set time delay to 1 second
		bra.s	locret_CFE6
; ===========================================================================
MoveSpikes_Retract:
		addi.w	#$800,oSpkMvOff(a0)
		cmpi.w	#$2000,oSpkMvOff(a0)
		bcs.s	locret_CFE6
		move.w	#$2000,oSpkMvOff(a0)
		move.w	#1,oSpkMvState(a0)
		move.w	#60,oSpkMvTime(a0)	; set time delay to 1 second

locret_CFE6:
		rts
; ===========================================================================
; Spike object mappings
; ===========================================================================
Map_ObjSpike:
	include "Level/Objects/Spikes/Mappings.asm"
; ===========================================================================
ArtKosM_SpikesN:
		incbin	"Level/Objects/Spikes/Art - Normal.kosm.bin"
		even
; ===========================================================================
ArtKosM_SpikesS:
		incbin	"Level/Objects/Spikes/Art - Sideways.kosm.bin"
		even
; ===========================================================================