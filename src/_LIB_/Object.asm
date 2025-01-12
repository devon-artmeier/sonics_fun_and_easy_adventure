; =========================================================================================================================================================
; Sonic's Fun And Easy Adventure
; By Ralakimus/Novedicus 2017
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Object functions
; =========================================================================================================================================================
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Run object code
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; PARAMETERS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; RETURNS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
RunObjects:
		lea	r_Objects.w,a0			; Object space
		moveq	#OBJECT_COUNT-1,d7		; Number of objects

.Loop:
		move.l	oAddr(a0),d0			; Get address
		beq.s	.Next				; If it's 0, branch
		move.l	d0,a1				; Jump to it
		jsr	(a1)				; ''

.Next:
		lea	oSize(a0),a0			; Next object
		dbf	d7,.Loop			; Loop

ObjNull:
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Find the first free object space available
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; PARAMETERS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; RETURNS:
;	a1.l	- Pointer to the SST space in the free object space
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
FindFreeObj:
		lea	(r_Dyn_Objs-oSize).w,a1		; Dynamic object space
		move.w	#DYN_OBJ_CNT-1,d0		; Number of objects to check

FindObjLoop:
		lea	oSize(a1),a1			; Get next object
		tst.l	oAddr(a1)			; Is this slot free?
		dbeq	d0,FindObjLoop			; If not, loop

.End:
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Find the first free object space available after the current one
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l	- Current object's SST space pointer
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; RETURNS:
;	a1.l	- Pointer to the SST space in the free object space
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
FindNextFreeObj:
		movea.l	a0,a1				; Get length of memory left in object RAM after us
		move.w	#r_Dyn_Objs_End,d0		; ''
		sub.w	a0,d0				; ''
		lsr.w	#6,d0				; Turn into offset
		move.b	.ObjsCnt(pc,d0.w),d0		; Get number of objects to search
		bmi.s	.End				; If there are none, branch
		bra.s	FindObjLoop			; Find an object slot

.End:
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.ObjsCnt:
I = DYN_OBJ_CNT*oSize
	while I>0
I = I-$40
		dc.b	(((DYN_OBJ_CNT*oSize)-I)/oSize-1)%256
	endw
		even
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Delete the current object
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; PARAMETERS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; RETURNS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
DeleteObject:
		movea.l	a0,a1				; Copy current object space pointer
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Delete an object
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; PARAMETERS:
;	a1.l	- Pointet to object space to clear
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; RETURNS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
DeleteOtherObj:
		moveq	#0,d1

		rept	oSize/4
			move.l	d1,(a1)+		; Clear variables
		endr

		if oSize&2
			move.w	d1,(a1)+		; Clear the rest
		endif

		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Render object sprites
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; PARAMETERS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; RETURNS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
RenderObjects:
		moveq	#($280/8)-1,d7			; Max sprite count
		moveq	#0,d6				; Render flags

		lea	r_FG_Cam.w,a3			; Foreground camera variables
		lea	r_Spr_Input.w,a5		; Sprite input table
		lea	r_Sprites.w,a6			; Sprite table buffer

		cmpi.b	#gLevel,r_Game_Mode.w		; Are we in level mode?
		bne.s	.PrioLvlLoop			; If not, branch
		jsr	Level_RenderHUD			; Render the HUD

.PrioLvlLoop:
		tst.w	(a5)				; Are there any input for the current priority level?
		beq.w	.NextPrioLvl			; If not, branch
		lea	2(a5),a4			; Prepare to read input data

.ObjectLoop:
		movea.w	(a4)+,a0			; Get object SST address
		tst.l	oAddr(a0)			; Is this object slot used?
		beq.w	.NextObject			; If not, branch
		
		andi.b	#$7F,oRender(a0)		; Clear on-screen flag
		move.b	oRender(a0),d6			; Store render flags
		move.w	oX(a0),d0			; Get X position
		move.w	oY(a0),d1			; Get Y position

		btst	#6,d6				; Is the multi sprite flag set?
		bne.w	.MultiDraw			; If so, branch
		btst	#2,d6				; Is the sprite to be drawn via screen space?
		beq.s	.Render				; If not, branch

		sub.w	cX(a3),d0			; Subtract the camera's X position from the sprite's
		sub.w	cY(a3),d1			; Subtract the camera's Y position from the sprite's
		
.Render:
		moveq	#0,d2
		move.b	oDrawW(a0),d2			; Get sprite width
		move.w	d0,d3				; Get sprite X position
		add.w	d2,d3				; Add width
		bmi.s	.NextObject			; If it's off screen on the left, branch
		move.w	d0,d3				; Get sprite X position
		sub.w	d2,d3				; Subtract width
		cmpi.w	#320,d3				; Is it off screen on the right?
		bge.s	.NextObject			; If so, branch
		addi.w	#128,d0				; Move sprite on screen

		moveq	#0,d2
		move.b	oDrawH(a0),d2			; Get sprite height
		move.w	d1,d3				; Get sprite Y position
		add.w	d2,d3				; Add height
		bmi.s	.NextObject			; If it's off screen on the top, branch
		move.w	d1,d3				; Get sprite Y position
		sub.w	d2,d3				; Subtract height
		cmpi.w	#224,d3				; Is it off screen on the bottom?
		bge.s	.NextObject			; If so, branch
		addi.w	#128,d1				; Move sprite on screen
		
		ori.b	#$80,oRender(a0)		; Set on-screen flag
		tst.w	d7				; Do we still have some sprite space left?
		bmi.s	.NextObject			; If not, branch

		move.l	oMap(a0),d4			; Get mappings pointer
		beq.s	.NextObject			; If blank, branch
		movea.l	d4,a1				; Store it
		moveq	#0,d4
		btst	#5,d6				; Is the static sprite flag set
		bne.s	.Static				; If so, branch
		move.b	oFrame(a0),d4			; Get mapping frame
		add.w	d4,d4				; Turn into offset
		adda.w	(a1,d4.w),a1			; Get mapping frame data pointer
		move.w	(a1)+,d4			; Get mapping frame sprite count
		subq.w	#1,d4				; Subtract 1 from sprite count
		bmi.s	.NextObject			; If there are no sprites to draw, branch
		
.Static:
		move.w	oVRAM(a0),d5			; Get sprite tile properties
		bsr.w	DrawSprite			; Draw the sprites

.NextObject:
		subq.w	#2,(a5)				; Decrement input count
		bne.w	.ObjectLoop			; If there are still some sprites to draw in this priority level, branch

.NextPrioLvl:
		lea	$80(a5),a5			; Get next priority level
		cmpa.w	#r_Spr_Input_End,a5		; Are we at the end of the input table?
		blo.w	.PrioLvlLoop			; If not, branch

		cmpi.b	#gLevel,r_Game_Mode.w		; Are we in level mode?
		bne.s	.NotLevel			; If not, branch
		jsr	Level_RenderRings		; Render the rings

.NotLevel:
		move.w	d7,d6				; Get remaining sprite count
		bmi.s	.SetDrawnSprites		; If we have filled the entire sprite table, branch
		moveq	#0,d0

.FillRest:
		move.w	d0,(a6)				; Move sprite off screen
		addq.w	#8,a6				; Next sprite
		dbf	d7,.FillRest			; Loop

.SetDrawnSprites:
		subi.w	#($280/8)-1,d6			; Get number of sprites drawn
		neg.w	d6				; ''
		move.b	d6,r_Spr_Count.w		; Store it

		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.MultiDraw:
		btst	#2,d6				; Is the sprite to be drawn via screen space?
		beq.s	.RenderMain			; If not, branch

		sub.w	cX(a3),d0			; Subtract the camera's X position from the sprite's
		sub.w	cY(a3),d1			; Subtract the camera's Y position from the sprite's
		
.RenderMain:
		moveq	#0,d2
		move.b	oDrawW(a0),d2			; Get main sprite width
		move.w	d0,d3				; Get main sprite X position
		add.w	d2,d3				; Add width
		bmi.s	.NextObject			; If it's off screen on the left, branch
		move.w	d0,d3				; Get main sprite X position
		sub.w	d2,d3				; Subtract width
		cmpi.w	#320,d3				; Is it off screen on the right?
		bge.s	.NextObject			; If so, branch
		addi.w	#128,d0				; Move sprite on screen

		move.b	oDrawH(a0),d2			; Get main sprite height
		move.w	d1,d3				; Get main sprite Y position
		add.w	d2,d3				; Add height
		bmi.s	.NextObject			; If it's off screen on the top, branch
		move.w	d1,d3				; Get main sprite Y position
		sub.w	d2,d3				; Subtract height
		cmpi.w	#224,d3				; Is it off screen on the bottom?
		bge.s	.NextObject			; If so, branch
		addi.w	#128,d1				; Move sprite on screen

		ori.b	#$80,oRender(a0)		; Set on-screen flag
		tst.w	d7				; Do we still have some sprite space left?
		bmi.w	.NextObject			; If not, branch

		move.w	oVRAM(a0),d5			; Get sprite tile properties
		move.l	oMap(a0),d4			; Get mappings pointer
		beq.w	.NextObject			; If blank, branch
		movea.l	d4,a2				; Store it
		moveq	#0,d4
		move.b	oFrame(a0),d4			; Get mapping frame
		add.w	d4,d4				; Turn into offset
		lea	(a2),a1				; Copy mappings data pointer
		adda.w	(a1,d4.w),a1			; Get mapping frame data pointer
		move.w	(a1)+,d4			; Get mapping frame sprite count
		subq.w	#1,d4				; Subtract 1 from sprite count
		bmi.s	.RenderSubSprites		; If there are no sprites to draw, branch
		move.w	d6,d3				; Store render flags
		bsr.w	DrawSprite_BoundChk		; Draw the sprites
		move.w	d3,d6				; Restore render flags

		tst.w	d7				; Do we still have some sprite space left?
		bmi.w	.NextObject			; If not, branch

.RenderSubSprites:
		move.w	oSubCnt(a0),d3			; Get sub sprite count
		subq.w	#1,d3				; Subtract 1
		bmi.w	.NextObject			; If there are no sprites to draw, branch
		lea	oSubStart(a0),a0		; Get sub sprite SSTs start

.RenderSubSprs_Loop:
		move.w	(a0)+,d0			; Get X position
		addi.w	#128,d0				; Move on screen
		move.w	(a0)+,d1			; Get Y position
		addi.w	#128,d1				; Move on screen
		
		btst	#2,d6				; Is the sprite to be drawn via screen space?
		beq.s	.RenderSub			; If not, branch
		
		sub.w	cX(a3),d0			; Subtract the camera's X position from the sprite's
		sub.w	cY(a3),d1			; Subtract the camera's Y position from the sprite's
		
.RenderSub:
		move.w	(a0)+,d4			; Get mapping frame
		add.w	d4,d4				; Turn into offset
		lea	(a2),a1				; Copy mappings data pointer
		adda.w	(a1,d4.w),a1			; Get mapping frame data pointer
		move.w	(a1)+,d4			; Get mapping frame sprite count
		subq.w	#1,d4				; Subtract 1 from sprite count
		bmi.s	.RenderSubSprs_ChkLoop		; If there are no sprites to draw, branch
		push.w	d6				; Store render flags
		bsr.w	DrawSprite_BoundChk		; Draw the sprites
		pop.w	d6				; Restore render flags

.RenderSubSprs_ChkLoop:
		tst.w	d7				; Do we still have some sprite space left?
		dbmi	d3,.RenderSubSprs_Loop		; If so, loop
		bra.w	.NextObject			; Continue on rendering other sprites
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Display an object's sprite
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l	- Object space pointer
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; RETURNS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
DisplayObject:
		movea.w	oPrio(a0),a1			; Get priority level object list address

DispObj_SetEntry:
		cmpi.w	#$7E,(a1)			; Are we out of space for this priority entry table?
		bhs.s	.ChkEnd				; If so, branch
		addq.w	#2,(a1)				; Increment entry count
		adda.w	(a1),a1				; Go to first empty entry
		move.w	a0,(a1)				; Store object space pointer

.End:
		rts

.ChkEnd:
		cmpa.w	#r_Spr_Input+(7*$80),a1		; Are we at the last table of the input table?
		beq.s	.End				; If so, branch
		adda.w	#$80,a1				; Next priority level
		bra.s	DispObj_SetEntry		; Continue
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Animate an object's sprite
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l	- Object space pointer
;	a1.l	- Animation script pointer
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; RETURNS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
AnimateObject:
		moveq	#0,d0
		move.b	oAni(a0),d0			; Get animation ID
		cmp.b	oPrevAni(a0),d0			; Has it changed?
		beq.s	.Run				; If not, branch
		move.b	d0,oPrevAni(a0)			; Save the new ID
		clr.b	oAniFrame(a0)			; Reset animation
		clr.b	oAniTimer(a0)			; Reset animation timer

.Run:
		subq.b	#1,oAniTimer(a0)		; Decrement animation timer
		bpl.s	.Wait				; If it hasn't run out, branch
		add.w	d0,d0				; Turn ID into offset
		adda.w	(a1,d0.w),a1			; Get pointer to current animation script
		move.b	(a1),oAniTimer(a0)		; Set new animation timer
		
		moveq	#0,d1
		move.b	oAniFrame(a0),d1		; Get current value in the script
		move.b	1(a1,d1.w),d0			; ''
		cmpi.b	#$FA,d0				; Is it a command value?
		bhs.s	.CmdReset			; If so, branch

.Next:
		move.b	d0,oFrame(a0)			; Set mapping frame ID
		move.b	oStatus(a0),d0			; Get status
		andi.b	#3,d0				; Only get flip bits
		andi.b	#$FC,oRender(a0)		; Mask out flip bits in render flags
		or.b	d0,oRender(a0)			; Set flip bits
		addq.b	#1,oAniFrame(a0)		; Advance into the animation script

.Wait:
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.CmdReset:
		addq.b	#1,d0				; Is this flag $FF (reset)?
		bne.s	.CmdJump			; If not, branch
		clr.b	oAniFrame(a0)			; Reset animation
		move.b	1(a1),d0			; Get first frame ID
		bra.s	.Next				; Continue
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.CmdJump:
		addq.b	#1,d0				; Is this flag $FE (jump)?
		bne.s	.CmdSetAnim			; If not, branch
		move.b	2(a1,d1.w),d0			; Get jump offset
		sub.b	d0,oAniFrame(a0)		; Go back
		sub.b	d0,d1				; ''
		move.b	1(a1,d1.w),d0			; Get new frame ID
		bra.s	.Next				; Continue
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.CmdSetAnim:
		addq.b	#1,d0				; Is this flag $FD (set animation ID)?
		bne.s	.CmdNextRout			; If not, branch
		move.b	2(a1,d1.w),oAni(a0)		; Set new animation ID
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.CmdNextRout:
		addq.b	#1,d0				; Is this flag $FC (next routine)?
		bne.s	.CmdReset2ndRout		; If not, branch
		addq.b	#2,oRoutine(a0)			; Next routine
		clr.b	oAniTimer(a0)			; Reset animation timer
		addq.b	#1,oAniFrame(a0)		; Next animation frame
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.CmdReset2ndRout:
		addq.b	#1,d0				; Is this flag $FB (reset secondary routine)?
		bne.s	.CmdNext2ndRout			; If not, branch
		clr.b	oAniTimer(a0)			; Reset animation timer
		clr.b	oWFZRout(a0)			; Reset routine
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
.CmdNext2ndRout:
		addq.b	#1,d0				; Is this flag $FA (next secondary routine)?
		bne.s	.CmdEnd				; If not, branch
		addq.b	#2,oWFZRout(a0)			; Next routine
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------		
.CmdEnd:
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------		
; Load object DPLCs
; ---------------------------------------------------------------------------------------------------------------------------------------------------------		
; PARAMETERS:
;	d4.w	- Target VRAM address
;	d6.l	- Pointer to uncompressed art
;	a2.l	- Pointer to DPLCs
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; RETURNS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
LoadObjDPLCs:
		moveq	#0,d0
		move.b	oFrame(a0),d0			; Get mapping frame
		cmp.b	oPrevDPLC(a0),d0		; Do we need to update the art?
		beq.s	.End				; If not, branch
		move.b	d0,oPrevDPLC(a0)		; Save the frame ID so we don't constantly load the art
		add.w	d0,d0				; Turn ID into offset
		adda.w	(a2,d0.w),a2			; Get pointer to DPLC data for the frame
		move.w	(a2)+,d5			; Get DPLC entry count
		subq.w	#1,d5				; Subtract 1
		bmi.s	.End				; If there are no more entires left, branch

.ReadEntries:
		moveq	#0,d1
		move.w	(a2)+,d1			; Get DPLC entry data
		move.w	d1,d3				; Copy that
		lsr.w	#8,d3				; Get tile count
		andi.w	#$F0,d3				; ''
		addi.w	#$10,d3				; ''
		andi.w	#$FFF,d1			; Get offset in art data
		lsl.l	#5,d1				; ''
		add.l	d6,d1				; Get pointer in art data
		move.w	d4,d2				; Copy VRAM address
		add.w	d3,d4				; Add tile count to VRAM address
		add.w	d3,d4				; ''
		jsr	QueueDMATransfer.w		; Queue the art
		dbf	d5,.ReadEntries			; Loop

.End:
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Move an object by it's velocity values
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l	- Object space pointer
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; RETURNS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjectMove:
		move.w	oXVel(a0),d0			; Get X velocity
		ext.l	d0				; ''
		lsl.l	#8,d0				; Shift
		add.l	d0,oX(a0)			; Add to the X position
		move.w	oYVel(a0),d0			; Get Y velocity
		ext.l	d0				; ''
		lsl.l	#8,d0				; Shift
		add.l	d0,oY(a0)			; Add to the Y position
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Move an object by it's velocity values (with gravity)
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l	- Object space pointer
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; RETURNS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjectMoveAndFall:
		move.w	oXVel(a0),d0			; Get X velocity
		ext.l	d0				; ''
		lsl.l	#8,d0				; Shift
		add.l	d0,oX(a0)			; Add to the X position
		move.w	oYVel(a0),d0			; Get Y velocity
		addi.w	#$38,oYVel(a0)			; Apply gravity
		ext.l	d0				; ''
		lsl.l	#8,d0				; Shift
		add.l	d0,oY(a0)			; Add to the Y position
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Check if a specific object is nearby
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l	- Current object space pointer
;	a1.l	- Range data pointer
;	a2.l	- Object to check's space pointer
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; RETURNS:
;	d0.w	- Return status (0 if not in range, other object's space pointer if in range)
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
CheckObjInRange:
		moveq	#0,d0
		move.w	oX(a2),d1			; Get other object's position
		move.w	oY(a2),d2			; ''
		move.w	oX(a0),d3			; Get current object's position
		move.w	oY(a0),d4			; ''
		add.w	(a1)+,d3			; Get left boundary
		move.w	d3,d5				; Copy
		add.w	(a1)+,d5			; Get right boundary
		add.w	(a1)+,d4			; Get top boundary
		move.w	d4,d6				; Copy
		add.w	(a1)+,d6			; Get bottom boundary
		cmp.w	d3,d1				; Is the object past the left boundary?
		blo.s	.End				; If not, branch
		cmp.w	d5,d1				; Is the object within the horizontal range?
		bhs.s	.End				; If not, branch
		cmp.w	d4,d2				; Is the object past the top boundary?
		blo.s	.End				; If not, branch
		cmp.w	d6,d2				; Is the object within the vertical range?
		bhs.s	.End				; If not, branch
		move.w	a2,d0				; Copy other object's RAM space pointer as the return status

.End:
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Object manager
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjectManager:
		moveq	#0,d0
		move.b	r_Obj_Man_Rout.w,d0
		jmp	ObjectManager_Index(pc,d0.w)
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjectManager_Index:
		bra.w	ObjectManager_Init		; Initialization
		bra.w	ObjectManager_Main		; Main routine
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjectManager_Init:
		addq.b	#4,r_Obj_Man_Rout.w		; Next routine
		
		clrRAM	r_Respawns			; Clear object respawn table

		movea.l	r_Obj_Pos_Addr.w,a0		; Get object data pointer
		move.l	a0,r_Obj_Load_R.w
		move.l	a0,r_Obj_Load_L.w		; Store address of object layout

		lea	r_Respawns.w,a3			; Object respawn table

		move.w	r_Cam_X.w,d6			; Camera's X position
		subi.w	#$80,d6				; Subtract 128
		bhs.s	.NoReset			; Branch if it doesn't go past the left boundary
		moveq	#0,d6				; Cap at left boundary

.NoReset:
		andi.w	#$FF80,d6			; Keep in chunks of 128 pixels

		movea.l	r_Obj_Load_R.w,a0		; Get address of the object loader for the right side of the screen

.ChkObjsLeft:
		cmp.w	(a0),d6				; Compare object position
		bls.s	.ChkDone			; If higher than d6, branch
		addq.w	#1,a3				; Next respawn table index
		addq.w	#6,a0				; Next object
		bra.s	.ChkObjsLeft			; Loop

.ChkDone:
		move.l	a0,r_Obj_Load_R.w		; Store new addresses
		move.w	a3,r_Obj_Resp_R.w		; ''

		lea	r_Respawns.w,a3			; Object respawn table

		movea.l	r_Obj_Load_L.w,a0
		subi.w	#$80,d6				; Subtract from camera's X position again
		blo.s	.ChkDone2			; But is done to account for the object loader later on

.ChkObjsRight:
		cmp.w	(a0),d6				; Compate object position
		bls.s	.ChkDone2			; If higher than d6, branch
		addq.w	#1,a3				; Next respawn table index
		addq.w	#6,a0				; Next object
		bra.s	.ChkObjsRight			; Loop

.ChkDone2:
		move.l	a0,r_Obj_Load_L.w		; Store new addresses
		move.w	a3,r_Obj_Resp_L.w		; ''

		move.w	#-1,r_Obj_Man_X.w		; Reset manager's camera X position
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
ObjectManager_Main:
		move.w	r_Cam_X.w,d1			; Get camera's X position
		subi.w	#$80,d1				; Subtract 128 pixels
		andi.w	#$FF80,d1			; Keep in range
		move.w	d1,r_Obj_X_Coarse.w		; Store this
		
		lea	Level_ObjIndex,a4		; Level object index

		move.w	r_Cam_X.w,d6			; Get camera's X position
		andi.w	#$FF80,d6			; Keep in range
		cmp.w	r_Obj_Man_X.w,d6		; Check against last range
		beq.w	Level_LoadObjs_SameXRange	; Branch if they are the same
		bge.s	Level_LoadObjs_Forward		; If new range is greater than the last, branch

		move.w	d6,r_Obj_Man_X.w		; Set new range

		movea.l	r_Obj_Load_L.w,a0		; Get current objects on the left side of the screen
		movea.w	r_Obj_Resp_L.w,a3		; And the appropriate respawn list

		subi.w	#$80,d6				; Subtract 128 from the X position
		blo.s	.EndLoad			; If outside of the level boundary, branch

.LoadLoop:
		cmp.w	-6(a0),d6			; Check if the last obhect is in range
		bge.s	.EndLoad			; If not, branch
		subq.w	#6,a0				; Get actual object address
		subq.w	#1,a3				; Get acutal respawn table address

		bsr.w	Level_LoadObject		; Spawn the object
		bne.s	.LoadFail			; If it failed, branch
		subq.w	#6,a0
		bra.s	.LoadLoop			; Attempt to load another object

.LoadFail:
		addq.w	#1,a3				; Undo object loading
		addq.w	#6,a0

.EndLoad:
		move.l	a0,r_Obj_Load_L.w		; Store new addresses
		move.w	a3,r_Obj_Resp_L.w

		movea.l	r_Obj_Load_R.w,a0		; Get current objects on the right side of the screen
		movea.w	r_Obj_Resp_R.w,a3		; And the appropriate respawn list

		addi.w	#$300,d6			; Load 2 chunks forward

.ChkLoop:
		cmp.w	-6(a0),d6			; Check if the last object is out of range
		bgt.s	.ChkDone			; If so, branch
		subq.w	#1,a3				; Get the respawn index before this
		subq.w	#6,a0				; Get the object before this
		bra.s	.ChkLoop			; Check next object

.ChkDone:
		move.l	a0,r_Obj_Load_R.w		; Store new addresses
		move.w	a3,r_Obj_Resp_R.w
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
Level_LoadObjs_Forward:
		move.w	d6,r_Obj_Man_X.w		; Set new range

		movea.l	r_Obj_Load_R.w,a0		; Get current objects on the right side of the screen
		movea.w	r_Obj_Resp_R.w,a3		; And the appropriate respawn list

		addi.w	#$280,d6			; Load 2 chunks forward

.LoadLoop:
		cmp.w	(a0),d6				; Check if the last obhect is in range
		bls.s	.EndLoad			; If not, branch
		bsr.w	Level_LoadObject		; Spawn the object
		addq.w	#1,a3				; Get next respawn table address
		beq.s	.LoadLoop			; If the object spawned, branch

.EndLoad:
		move.l	a0,r_Obj_Load_R.w		; Store new addresses
		move.w	a3,r_Obj_Resp_R.w

		movea.l	r_Obj_Load_L.w,a0		; Get current objects on the left side of the screen
		movea.w	r_Obj_Resp_L.w,a3		; And the appropriate respawn list

		subi.w	#$300,d6			; Check 1 chunk backwards
		blo.s	.ChkDone			; If outside of level, branch

.ChkLoop:
		cmp.w	(a0),d6				; Check if the last object is out of range
		bls.s	.ChkDone			; If so, branch
		addq.w	#1,a3				; And its respawn index
		addq.w	#6,a0				; Get the object before this
		bra.s	.ChkLoop			; Check next object

.ChkDone:
		move.l	a0,r_Obj_Load_L.w		; Store new addresses
		move.w	a3,r_Obj_Resp_L.w
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
Level_LoadObjs_SameXRange:
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Load an object from the object layout
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; PARAMETERS:
;	d5.w	- Y position limit
;	a0.l	- Index of object layout
;	a1.l	- Target object
;	a3.l	- Respawn table address
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
Level_LoadObject:
		tst.b	(a3)				; Has the object been loaded?
		bpl.s	.NotLoaded			; If not, branch
		addq.w	#6,a0				; Next object
		moveq	#0,d1				; Ensure that upstream code knows to continue loading
		rts

.NotLoaded:
		bsr.w	FindFreeObj			; Spawn object
		bne.s	.End				; If it failed, branch

		move.w	(a0)+,d7			; X position
		move.w	(a0)+,d1			; Y position
		move.w	d1,d2				; Copy
		andi.w	#$FFF,d1			; Keey Y in range

		bset	#7,(a3)				; Mark as loaded
		move.w	d7,oX(a1)			; Store X position
		move.w	d1,oY(a1)			; Store Y position

		rol.w	#3,d2				; Get X and Y flip bits
		andi.w	#3,d2				; ''
		move.b	d2,oRender(a1)			; Set render flags
		move.b	d2,oStatus(a1)			; Set status

		move.b	(a0)+,d2			; Get ID
		add.w	d2,d2				; Make it an index in the level object index list
		add.w	d2,d2
		move.l	(a4,d2.w),oAddr(a1)		; Set address

		move.b	(a0)+,oSubtype(a1)		; Set subtype
		move.w	a3,oRespawn(a1)			; Set respawn address
		
		moveq	#0,d1				; Ensure that upstream code knows to continue loading
		
.End:
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Check if the object is in range on the camera. If it isn't, delete it
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l	- Object space pointer
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; RETURNS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
CheckObjActive:
		move.w	oX(a0),d0			; Get X position
		
CheckObjActive2:
		andi.w	#$FF80,d0			; Only allow multiples of $80
		sub.w	r_Obj_X_Coarse.w,d0		; Subtract the camera's coarse X position
		cmpi.w	#$280,d0			; Has it gone offscreen?
		bhi.s	.Delete				; If so, branch
		rts

.Delete:
		move.w	oRespawn(a0),d0			; Get respawn table entry address
		beq.s	.DoDelete			; If 0, branch
		movea.w	d0,a2
		bclr	#7,(a2)				; Mark as gone

.DoDelete:
		jmp	DeleteObject.w			; Delete the object
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Check if the object is in range on the camera. If it isn't, delete it
; Also allows the object's sprite to be drawn
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l	- Object space pointer
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; RETURNS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
CheckObjActive_Draw:
		move.w	oX(a0),d0			; Get X position

CheckObjActive2_Draw:
		andi.w	#$FF80,d0			; Only allow multiples of $80
		sub.w	r_Obj_X_Coarse.w,d0		; Subtract the camera's coarse X position
		cmpi.w	#$280,d0			; Has it gone offscreen?
		bhi.s	.Delete				; If so, branch
		jmp	DisplayObject.w			; Display the sprite

.Delete:
		move.w	oRespawn(a0),d0			; Get respawn table entry address
		beq.s	.DoDelete			; If 0, branch
		movea.w	d0,a2
		bclr	#7,(a2)				; Mark as gone

.DoDelete:
		jmp	DeleteObject.w			; Delete the object
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Get orientation to player
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l	- Object space pointer
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; RETURNS:
;	a1.l	- Player object
;	d0.w	- 0 if player is left from object, 2 if right
;	d1.w	- 0 if player is above object, 2 if below
;	d2.w	- Player's horizontal distance to object
;	d3.w	- Player's vertical distance to object
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
GetOrientToPlayer:
		moveq	#0,d0
		moveq	#0,d1

		lea	r_Obj_Player.w,a1		; Get player object

		move.w	oX(a0),d2			; Get horizonal distance
		sub.w	oX(a1),d2			; ''
		bpl.s	.GetY				; Branch if the player is left from the object
		addq.w	#2,d0				; Set flag to indicate that the player is right from the object

.GetY:
		move.w	oY(a0),d3			; Get vertical distance
		sub.w	oY(a1),d3			; ''
		bhs.s	.End				; Branch if the player is above the object
		addq.w	#2,d1				; Set flag to indicate that the player is below the object

.End:
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Cap an object's speed
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l	- Object space pointer
;	d0.w	- Max X speed
;	d1.w	- Max Y speed
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; RETURNS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
CapObjSpeed:
		move.w	oXVel(a0),d2			; Get X velocity
		bpl.s	.ChkRight			; If we are going right, branch
		neg.w	d0				; Get absolute speed
		cmp.w	d0,d2				; Has it gone over the limit?
		bhs.s	.ChkUp				; If not, branch
		move.w	d0,d2				; Cap the speed
		bra.s	.ChkUp				; Continue

.ChkRight:
		cmp.w	d0,d2				; Has it gone over the limit?
		bls.s	.ChkUp				; If not, branch
		move.w	d0,d2				; Cap the speed

.ChkUp:
		move.w	oYVel(a0),d3			; Get Y velocity
		bpl.s	.ChkDown			; If we are going right, branch
		neg.w	d1				; Get absolute speed
		cmp.w	d1,d3				; Has it gone over the limit?
		bhs.s	.UpdateVel			; If not, branch
		move.w	d1,d3				; Cap the speed
		bra.s	.UpdateVel			; Continue

.ChkDown:
		cmp.w	d1,d3				; Has it gone over the limit?
		bls.s	.UpdateVel			; If not, branch
		move.w	d1,d3				; Cap the speed

.UpdateVel:
		move.w	d2,oXVel(a0)			; Set X velocity
		move.w	d2,oYVel(a0)			; Set Y velocity
		rts
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Load a child object
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; PARAMETERS:
;	a2.l	- Object data
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; RETURNS:
;	Nothing
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
LoadChildObject:
		bsr.w	FindNextFreeObj			; Find a free object slot
		bne.s	.End				; If there is non, branch
		move.w	(a2)+,d0			; Get parent object SST
		move.w	a0,(a1,d0.w)			; Store parent object
		move.w	(a2)+,d0			; Get child object SST
		move.w	a1,(a0,d0.w)			; Store child object
		move.l	(a2)+,oAddr(a1)			; Set object pointer
		move.b	(a2)+,oSubtype(a1)		; Set subtype
		move.w	oX(a0),oX(a1)			; Set X
		move.w	oY(a0),oY(a1)			; Set Y
		
.End:
		rts
; =========================================================================================================================================================