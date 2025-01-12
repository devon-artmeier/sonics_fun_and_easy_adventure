; --------------------------------------------------------------------------------
; Sprite mappings - output from SonMapEd - Sonic 3 & Knuckles format
; --------------------------------------------------------------------------------

SME_BDRFf:	
		dc.w SME_BDRFf_8-SME_BDRFf, SME_BDRFf_10-SME_BDRFf	
		dc.w SME_BDRFf_18-SME_BDRFf, SME_BDRFf_20-SME_BDRFf	
SME_BDRFf_8:	dc.b 0, 1	
		dc.b $F4, $A, 0, 0, $FF, $F4	
SME_BDRFf_10:	dc.b 0, 1	
		dc.b $F4, $A, 0, 9, $FF, $F4	
SME_BDRFf_18:	dc.b 0, 1	
		dc.b $F4, $A, 0, $12, $FF, $F4	
SME_BDRFf_20:	dc.b 0, 1	
		dc.b $F8, 5, 0, $1B, $FF, $F8	
		even