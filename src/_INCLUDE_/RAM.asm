; =========================================================================================================================================================
; Sonic's Fun And Easy Adventure
; By Ralakimus/Novedicus 2017
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; User defined RAM addresses
; =========================================================================================================================================================
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Standard variables
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
		rsset	RAM_START

		; --- BUFFERS ---

r_Buffer	rs.b	0				; General buffer
r_Chunks	rs.b	$8000				; Chunk table (uses same space as general buffer)
r_Buffer_End	rs.b	0

		rsset	$FF000000|(RAM_START+$8000)

r_Kos_Buf	rs.b	$1000				; Kosinski decompression buffer

r_DMA_Queue	rs.b	$FC				; DMA queue buffer
r_DMA_Slot	rs.w	1				; DMA queue buffer slot

r_HScroll	rs.b	$380				; HScroll table
r_HScroll_End	rs.b	0				; ''

r_VScroll	rs.b	$50				; VScroll table
r_VScroll_End	rs.b	0				; ''
r_VScroll_FG	EQU	r_VScroll			; VScroll foreground value
r_VScroll_BG	EQU	r_VScroll+2			; VScroll background value

r_Sprites	rs.b	$280				; Sprite table
r_Sprites_End	rs.b	0				; ''

r_Dest_Pal	rs.b	$80				; Target palette buffer
r_Dest_UW_Pal	rs.b	$80				; Target water palette buffer
r_Palette	rs.b	$80				; Palette buffer
r_Water_Pal	rs.b	$80				; Water palette buffer

r_Kos_Vars	rs.b	0				; Kosinski decompression queue variables
r_Kos_Cnt	rs.w	1				; Kosinski decompression queue count
r_Kos_Regs	rs.b	$1A				; Kosinski decompression stored registers
r_Kos_SR	rs.w	1				; Kosinski decompression stored SR
r_Kos_Bookmark	rs.l	1				; Kosinski decompression bookmark
r_Kos_List	rs.b	$20				; Kosinski decompression queue
r_Kos_Src	equ	r_Kos_List			; ''
r_Kos_Dest	equ	r_Kos_List+4			; ''
r_Kos_List_End	rs.b	0				; ''
r_KosM_Mods	rs.w	1				; Kosinski moduled decompression modules left
r_KosM_Last_Sz	rs.w	1				; Kosinski moduled decompression last module size
r_KosM_List	rs.b	$20*6				; Kosinski moduled decompression queue
r_KosM_Src	equ	r_KosM_List			; ''
r_KosM_Dest	equ	r_KosM_List+4			; ''
r_KosM_List_End	rs.b	0				; ''
r_Kos_Vars_End	rs.b	0				; End of Kosinski decompression queue variables

r_Spr_Input	rs.b	$80*8				; Sprite input buffer (8 priority levels)
r_Spr_Input_End	rs.b	0				; ''

r_Objects	rs.b	0				; Object SSTs
r_Res_Objs	rs.b	0				; Reserved object SSTs
		maxObjRAM $200				; ''
r_Res_Objs_End	rs.b	0				; ''
r_Dyn_Objs	rs.b	0				; Dynamic object SSTs
		maxObjRAM $1E00				; ''
r_Dyn_Objs_End	rs.b	0				; ''
r_Objects_End	rs.b	0

OBJECT_COUNT	equ	(r_Objects_End-r_Objects)/oSize
RES_OBJ_CNT	equ	(r_Res_Objs_End-r_Res_Objs)/oSize
DYN_OBJ_CNT	equ	(r_Dyn_Objs_End-r_Dyn_Objs)/oSize

r_Respawns	rs.b	$300				; Object respawn table
r_Respawns_End	rs.b	0				; ''

r_FG_Row_Buf	rs.b	$102				; Foreground horizontal plane buffer
r_FG_Col_Buf	rs.b	$82				; Foreground vertical plane buffer
r_BG_Row_Buf	rs.b	$102				; Background horizontal plane buffer
r_BG_Col_Buf	rs.b	$82				; Background vertical plane buffer

r_AMPS		rs.b	0			; AMPS variables
		include	"../amps/code/ram.asm"

		; --- ENGINE VARIABLES ---

r_P1_Data	rs.b	0				; Controller 1 data
r_P1_Hold	rs.b	1				; Controller 1 held button data
r_P1_Press	rs.b	1				; Controller 1 pressed button data
r_P2_Data	rs.b	0				; Controller 2 data
r_P2_Hold	rs.b	1				; Controller 2 held button data
r_P2_Press	rs.b	1				; Controller 2 pressed button data

r_HW_Version	rs.b	1				; Hardware version
r_VINT_Flag	rs.b	0				; V-INT flag
r_VINT_Rout	rs.b	1				; V-INT routine

r_Pal_Fade	rs.b	0				; Palette fade properties
r_Fade_Start	rs.b	1				; Palette fade start index
r_Fade_Len	rs.b	1				; Palette fade size

r_Lag_Count	rs.b	1				; Lag frame counter

r_HInt_Flag	rs.b	1				; H-INT run flag

r_VInt_Jmp	rs.w	1				; Header will point here for V-INT
r_VInt_Addr	rs.l	1				; V-INT address
r_HInt_Jmp	rs.w	1				; Header will point here for H-INT
r_HInt_Addr	rs.l	1				; H-INT address

r_Frame_Cnt	rs.l	1				; Frame counter

r_Game_Mode	rs.b	1				; Game mode ID
r_Spr_Count	rs.b	1				; Sprite count
r_Pause_Flag	rs.b	1				; Pause flag
r_HInt_Updates	rs.b	1				; Level updates in H-INT flag

r_HInt_Reg	rs.b	1				; H-INT counter register
r_HInt_Cnt	rs.b	1				; H-INT counter value

r_RNG_Seed	rs.l	1				; RNG seed

r_VDP_Reg_1	rs.w	1				; VDP register 1 register ID and value
r_Window_Y	rs.w	1				; Window Y position (VDP register)

r_Move_Cheat	rs.b	1
r_Art_Cheat	rs.b	1

r_Osc_Nums	rs.b	0				; Oscillation numbers
r_Osc_Ctrl	rs.w	1				; Oscillation control
r_Osc_Data	rs.w	$20				; Oscialltion data
r_Osc_Nums_End	rs.b	0				; ''

		; --- GLOBAL VARIABLES ---

r_Level		rs.b	0				; Level ID
r_Zone		rs.b	1				; Zone ID
r_Act		rs.b	1				; Act ID

r_Chkpoint	rs.b	0				; Checkpoint RAM
r_Last_Chkpoint	rs.b	1				; Last checkpoint hit
		rs.b	1
r_Saved_X_Pos	rs.w	1				; Saved player X position
r_Saved_Y_Pos	rs.w	1				; Saved player Y position
r_Chkpoint_End	rs.b	0				; End of checkpoint RAM

r_Obj_Pos_Addr	rs.l	1				; Object position data pointer
r_Obj_Man_Rout	rs.b	1				; Object manager routine

r_Start_Fall	rs.b	1				; Start level by falling flag

r_Obj_Load_R	rs.l	1				; Object data address (for going right)
r_Obj_Load_L	rs.l	1				; Object data address (for going left)
r_Obj_Resp_L	rs.w	1				; Object respawn address (for going right)
r_Obj_Resp_R	rs.w	1				; Object respawn address (for going left)
r_Obj_X_Coarse	rs.w	1				; Object manager's coarse X position
r_Obj_Man_X	rs.w	1				; Object manager's camera X position

r_PalCyc_Timer	rs.b	1				; Palette cycle timer
r_PalCyc_Index	rs.b	1				; Palette cycle index

		; --- LOCAL VARIABLES ---

r_Game_Vars	rs.b	0				; Start of local game variables
		rs.b	((-__rs)&$FFFF)-$80		; You have the rest of RAM here for local variables
r_Game_Vars_End	rs.b	0				; End of local game variables

		; --- STACK SPACE ---

r_Stack_Space	rs.b	$80				; Stack space
r_Stack_Base	rs.b	0				; ''
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Title screen variables
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
		rsset	r_Game_Vars
r_FMV_DMA_Size	rs.w	1				; FMV packet DMA size
r_FMV_Y		rs.l	1				; FMV Y position
r_FMV_Y_Vel	rs.w	1				; FMV Y velocity
r_FMV_Ready	rs.b	1				; FMV ready flag
r_FMV_Frame	rs.b	1				; FMV frame ID
r_FMV_Packet	rs.w	1				; FMV packet ID
r_FMV_Plane	rs.b	1				; FMV plane ID

r_Logo_Angle	rs.b	1				; Base logo hover angle

r_Cheat_Entry	rs.w	1
r_Cheat_Entry2	rs.w	1

	if __rs>=r_Game_Vars_End
		inform	3,"Title screen variables take too much space!"
	endif
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Level variables
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
		rsset	r_Game_Vars
r_Blocks	rs.b	$1A00				; Block table

r_Layout	rs.b	$1000				; Level layout

r_Scrl_Secs	rs.b	$384				; Scroll sections
r_Scrl_Secs_End	rs.b	0				; ''

r_Col_List	rs.b	$80				; Collision response list
r_Col_List_End	rs.b	0				; ''

r_Rings		rs.w	1				; Ring count

r_Ring_Man_Rout	rs.b	1				; Ring manager routine
r_Ring_Frame	rs.b	1				; Ring animation frame

r_Ring_Ani_Time	rs.b	1				; Ring animation timer
r_RLoss_Ani_T	rs.b	1
r_RLoss_Ani_A	rs.w	1
r_RLoss_Ani_F	rs.b	1

r_Boss_Defeat	rs.b	1

r_Ring_Stat	rs.b	$400				; Ring status table
r_Ring_Stat_End	rs.b	0				; ''

r_Ring_Col	rs.b	0				; Ring collection table
r_Ring_Col_Cnt	rs.w	1				; Ring collection count
r_Ring_Col_List	rs.b	$7E				; Ring collection list
r_Ring_Col_End	rs.b	0				; ''

r_Ring_Pos_Addr	rs.l	1				; Ring position data pointer
r_Ring_Load_L	rs.l	1				; Ring data address for the left side of the screen
r_Ring_Load_R	rs.l	1				; Ring data address for the right side of the screen
r_Ring_Stat_Ptr	rs.w	1				; Ring status address

r_Camera	rs.b	0				; Camera RAM

r_FG_Cam	rs.b	cSize2				; Foreground variables
r_BG_Cam	rs.b	cSize2				; Background variables

r_Dest_Max_Cam	rs.b	0				; Target maximum camera positions
r_Dest_Max_X	rs.w	1				; Target maximum camera X position
r_Dest_Max_Y	rs.w	1				; Target maximum camera Y position
r_Max_Cam	rs.b	0				; Maximum camera positions
r_Max_Cam_X	rs.w	1				; Maximum camera X position
r_Max_Cam_Y	rs.w	1				; Maximum camera Y position
r_Dest_Min_Cam	rs.b	0				; Target minimum camera positions
r_Dest_Min_X	rs.w	1				; Target minimum camera X position
r_Dest_Min_Y	rs.w	1				; Target minimum camera Y position
r_Min_Cam	rs.b	0				; Minimum camera positions
r_Min_Cam_X	rs.w	1				; Minimum camera X position
r_Min_Cam_Y	rs.w	1				; Minimum camera Y position
r_Cam_Y_Dist	rs.w	1				; Distance from the player's Y position and the camera's
r_Cam_Locked	rs.b	0				; Camera locked flags
r_Cam_Lock_X	rs.b	1				; Camera locked horizontally flag
r_Cam_Lock_Y	rs.b	1				; Camera locked vertically flag
r_Cam_Max_Chg	rs.b	1				; Camera max Y position changing flag

r_Camera_End	rs.b	0				; End of camera RAM

r_Debug_Mode	rs.b	1				; Debug placement mode

r_Cam_X_Center	rs.w	1				; Camera X center

r_Ctrl		rs.b	0				; Player control data
r_Ctrl_Hold	rs.b	1				; Player control held button data
r_Ctrl_Press	rs.b	1				; Player control pressed button data

r_Level_Music	rs.b	1				; Level music ID
		rs.b	1				; Boss music ID

r_1st_Col	rs.l	1				; Primary level collision data pointer
r_2nd_Col	rs.l	1				; Secondary level collision data pointer

r_Col_Addr	rs.l	1				; Current collsion address

r_Layer_Pos	rs.w	1				; Fake layer position

r_Angle_Vals	rs.l	1				; Angle value array pointer
r_Col_Array_N	rs.l	1				; Normal height map array pointer
r_Col_Array_R	rs.l	1				; Rotated height map array pointer

r_Next_Level	rs.b	1				; Flag to go to the next level

r_Update_Rings	rs.b	1				; Update Ring counter in the HUD flag

r_Water_Flag	rs.b	1				; Water in level flag
r_Water_Fullscr	rs.b	1				; Water fullscreen flag
r_Water_Lvl	rs.w	1				; Water height
r_Dest_Wat_Lvl	rs.w	1				; Target water height

r_Lvl_Frames	rs.w	1				; Level frame counter
r_Lvl_Reload	rs.b	1				; Level reload flag
r_Time_Over	rs.b	1				; Time over flag

r_Dyn_Ev_Rout	rs.b	1				; Dynamic event routine ID

r_Floor_Active	rs.b	1				; Floor active flag
r_Floor_Timer	rs.w	1				; Floor timer

r_Anim_Cnts	rs.b	$10				; Level art animation counters

	if __rs>=r_Game_Vars_End
		inform	3,"Level variables take too much space!"
	endif
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Camera variables
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
r_Cam_X		equ	r_FG_Cam+cX			; Camera X position
r_Cam_Y		equ	r_FG_Cam+cY			; Camera Y position
r_Cam_BG_X	equ	r_BG_Cam+cX			; Background camera X position
r_Cam_BG_Y	equ	r_BG_Cam+cY			; Background camera Y position
r_FG_Redraw	equ	r_FG_Cam+cRedraw		; Foreground redraw flag
r_BG_Redraw	equ	r_BG_Cam+cRedraw		; Background redraw flag
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
; Variables for the vector table
; ---------------------------------------------------------------------------------------------------------------------------------------------------------
V_Interrupt	equ	r_VInt_Jmp			; V-INT
H_Interrupt	equ	r_HInt_Jmp			; H-INT
; =========================================================================================================================================================