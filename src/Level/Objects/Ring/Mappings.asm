; --------------------------------------------------------------------------------
; Sprite mappings - output from SonMapEd - Sonic 3 & Knuckles format
; --------------------------------------------------------------------------------

SME_k4ulR:	
		dc.w SME_k4ulR_A-SME_k4ulR, SME_k4ulR_C-SME_k4ulR	
		dc.w SME_k4ulR_14-SME_k4ulR, SME_k4ulR_1C-SME_k4ulR	
		dc.w SME_k4ulR_24-SME_k4ulR	
SME_k4ulR_A:	dc.b 0, 1	
		dc.b $F8, 5, 0, 0, $FF, $F8
SME_k4ulR_C:	dc.b 0, 1	
		dc.b $F8, 5, $18, 4, $FF, $F8	
SME_k4ulR_14:	dc.b 0, 1	
		dc.b $F8, 5, $18, 4, $FF, $F8	
SME_k4ulR_1C:	dc.b 0, 1	
		dc.b $F8, 5, 8, 4, $FF, $F8	
SME_k4ulR_24:	dc.b 0, 1	
		dc.b $F8, 5, $10, 4, $FF, $F8	
		even