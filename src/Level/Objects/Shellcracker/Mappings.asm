; --------------------------------------------------------------------------------
; Sprite mappings - output from SonMapEd - Sonic 3 & Knuckles format
; --------------------------------------------------------------------------------

SME_Sh1iP:	
		dc.w SME_Sh1iP_C-SME_Sh1iP, SME_Sh1iP_26-SME_Sh1iP	
		dc.w SME_Sh1iP_40-SME_Sh1iP, SME_Sh1iP_5A-SME_Sh1iP	
		dc.w SME_Sh1iP_6E-SME_Sh1iP, SME_Sh1iP_76-SME_Sh1iP	
SME_Sh1iP_C:	dc.b 0, 4	
		dc.b $EC, $A, 0, $18, $FF, $E0	
		dc.b $F8, 4, 0, $21, 0, 8	
		dc.b $F4, $A, 0, 0, $FF, $E8	
		dc.b $F4, $A, 8, 0, 0, 0	
SME_Sh1iP_26:	dc.b 0, 4	
		dc.b $EC, $A, 0, $18, $FF, $E0	
		dc.b $F8, 4, 0, $21, 0, 8	
		dc.b $F4, 6, 8, $12, $FF, $F0	
		dc.b $F4, $A, 8, 9, 0, 0	
SME_Sh1iP_40:	dc.b 0, 4	
		dc.b $EC, $A, 0, $18, $FF, $E0	
		dc.b $F8, 4, 0, $21, 0, 8	
		dc.b $F4, $A, 0, 9, $FF, $E8	
		dc.b $F4, 6, 0, $12, 0, 0	
SME_Sh1iP_5A:	dc.b 0, 3	
		dc.b $F8, 4, 0, $21, 0, 8	
		dc.b $F4, $A, 0, 0, $FF, $E8	
		dc.b $F4, $A, 8, 0, 0, 0	
SME_Sh1iP_6E:	dc.b 0, 1	
		dc.b $FC, 0, 0, $23, $FF, $FC	
SME_Sh1iP_76:	dc.b 0, 1	
		dc.b $F4, $A, 0, $18, $FF, $F4	
		even