; =========================================================================================================================================================
; Sonic's Fun And Easy Adventure
; By Ralakimus/Novedicus 2017
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Checkpoint object
; =========================================================================================================================================================
		rsset	oLvlSSTs
oDongleX	rs.w	1				; Ball dongle X
oDongleY	rs.w	1				; Ball dongle Y
oDongleTime	rs.w	1				; Ball dongle timer
oDonglePar	rs.w	1				; Ball dongle parent
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjCheckpoint:
		moveq	#0,d0
		move.b	oRoutine(a0),d0			; Get routine ID
		move.w	.Index(pc,d0.w),d0		; Get offset to routine
		jmp	.Index(pc,d0.w)			; Jump to it
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.Index:
		dc.w	ObjChkpoint_Init-.Index
		dc.w	ObjChkpoint_Main-.Index
		dc.w	ObjChkpoint_Animate-.Index
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjChkpoint_Init:
		addq.b	#2,oRoutine(a0)			; Next routine
		
		move.l	#Map_ObjChkpoint,oMap(a0)	; Mappings
		move.w	#$57E,oVRAM(a0)			; Tile properties
		move.b	#4,oRender(a0)			; Render flags
		move.b	#8,oDrawW(a0)			; Sprite width
		move.b	#$20,oDrawH(a0)			; Sprite height
		move.w	#r_Spr_Input+$280,oPrio(a0)	; Priority
		
		move.w	oRespawn(a0),d0			; Get respawn table address
		movea.w	d0,a2				; ''
		btst	#0,(a2)				; Is it already set?
		bne.s	.AlreadySet			; If so, branch

		move.b	oSubtype(a0),d1			; Get checkpoint ID
		cmp.b	r_Last_Chkpoint.w,d1		; Has a later checkpoint already been hit?
		bgt.s	ObjChkpoint_Main		; If not, branch

.AlreadySet:
		bset	#0,(a2)				; Mark as set
		move.b	#2,oAni(a0)			; ''
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjChkpoint_Main:
		tst.b	r_Debug_Mode.w			; Are we in debug placement mode?
		bne.w	ObjChkpoint_Animate		; If so, branch
		
		lea	r_Obj_Player.w,a1		; Player object
		move.b	r_Last_Chkpoint.w,d1		; Get last checkpoint hit
		cmp.b	oSubtype(a0),d1			; Has a later checkpoint already been hit?
		bhs.w	.ChkSetAnim			; If so, branch

		move.w	oX(a1),d0			; Get player's X position
		sub.w	oX(a0),d0			; Get delta X from current position
		addq.w	#8,d0				; Add 8
		cmpi.w	#$10,d0				; Is the player within horizontal boundaries?
		bcc.w	ObjChkpoint_Animate		; If not, branch
		move.w	oY(a1),d0			; Get player's Y position
		sub.w	oY(a0),d0			; Get delta Y from current position
		addi.w	#$40,d0				; Add $40
		cmpi.w	#$68,d0				; Is the player within vertical boundaries?
		bcc.w	ObjChkpoint_Animate		; If not, branch
		
		playSnd	#sCheckpoint, 2			; Play checkpoint sound

		jsr	FindNextFreeObj.w		; Find a free object slot
		bne.s	.SetPoint			; If there is none, branch
		move.l	#ObjChkPoint_Dongle,oAddr(a1)	; Load the checkpoint ball dongle object
		move.w	oX(a0),oDongleX(a1)		; Dongle X
		move.w	oY(a0),oDongleY(a1)		; Dongle Y
		subi.w	#$14,oDongleY(a1)		; ''
		move.l	oMap(a0),oMap(a1)		; Mappings
		move.w	oVRAM(a0),oVRAM(a1)		; Tile properties
		move.b	#4,oRender(a1)			; Render flags
		move.b	#8,oDrawW(a1)			; Sprite width
		move.b	#8,oDrawH(a1)			; Sprite height
		move.w	#r_Spr_Input+$200,oPrio(a1)	; Priority
		move.b	#2,oFrame(a1)			; Map frame
		move.w	#$20,oDongleTime(a1)		; Dongle timer
		move.w	a0,oDonglePar(a1)		; Dongle parent

.SetPoint:
		move.w	oRespawn(a0),d0			; Get respawn table address
		movea.w	d0,a2				; ''
		bset	#0,(a2)				; Mark as set
		
		move.b	#1,oAni(a0)			; Use dongling animation
		move.b	oSubtype(a0),r_Last_Chkpoint.w	; Set checkpoint ID

		addq.b	#2,oRoutine(a0)
		pea	ObjChkpoint_Animate		; Animate
		jmp	Level_SaveInfo			; Save data
		
.ChkSetAnim:
		addq.b	#2,oRoutine(a0)
		tst.b	oAni(a0)			; Are we still unset?
		bne.s	ObjChkpoint_Animate		; If not, branch
		move.b	#2,oAni(a0)			; Use the set animation
; ---------------------------------------------------------------------------------------------------------------------------------------------------------		
ObjChkpoint_Animate:
		lea	Ani_ObjChkpoint,a1		; Animate
		jsr	AnimateObject.w			; ''
		jmp	CheckObjActive_Draw.w		; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------		
; Ball dongle object
; ---------------------------------------------------------------------------------------------------------------------------------------------------------		
ObjChkPoint_Dongle:
		subq.w	#1,oDongleTime(a0)		; Decrement timer
		bpl.s	.MoveDongle			; If it hasn't run out, branch
		movea.w	oDonglePar(a0),a1		; Get parent
		move.b	#2,oAni(a1)			; Set set animation for parent
		clr.b	oFrame(a1)			; Reset map frame for parent
		jmp	DeleteObject.w			; Delete ourselves

.MoveDongle:
		move.b	oAngle(a0),d0			; Get angle
		subi.b	#$10,oAngle(a0)			; Decrement angle
		subi.b	#$40,d0				; Subtract $40
		jsr	CalcSine.w			; Get sine and cosine
		muls.w	#$C00,d1			; Multiply cosine with $C00
		swap	d1				; Get high word
		add.w	oDongleX(a0),d1			; Add dongle X
		move.w	d1,oX(a0)			; Set actual X
		muls.w	#$C00,d0			; Multiply sine with $C00
		swap	d0				; Get high word
		add.w	oDongleY(a0),d0			; Add dongle X
		move.w	d0,oY(a0)			; Set actual X
		jmp	CheckObjActive_Draw.w		; Display
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Data
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ArtKosM_Chkpoint:
		incbin	"Level/Objects/Checkpoint/Art.kosm.bin"
		even
Ani_ObjChkpoint:
		dc.w	.Ani0-Ani_ObjChkpoint
		dc.w	.Ani1-Ani_ObjChkpoint
		dc.w	.Ani2-Ani_ObjChkpoint
.Ani0:		dc.b	$F, 0, $FF
		even
.Ani1:		dc.b	$F, 1, $FF
		even
.Ani2:		dc.b	3, 0, 4, $FF
		even
Map_ObjChkpoint:
		include	"Level/Objects/Checkpoint/Mappings.asm"
; =========================================================================================================================================================