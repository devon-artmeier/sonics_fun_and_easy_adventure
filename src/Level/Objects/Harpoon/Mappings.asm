; --------------------------------------------------------------------------------
; Sprite mappings - output from SonMapEd - Sonic 3 & Knuckles format
; --------------------------------------------------------------------------------

SME_5RxVB:	
		dc.w SME_5RxVB_C-SME_5RxVB, SME_5RxVB_14-SME_5RxVB	
		dc.w SME_5RxVB_1C-SME_5RxVB, SME_5RxVB_2A-SME_5RxVB	
		dc.w SME_5RxVB_32-SME_5RxVB, SME_5RxVB_3A-SME_5RxVB	
SME_5RxVB_C:	dc.b 0, 1	
		dc.b $FC, 4, 0, 0, $FF, $F8	
SME_5RxVB_14:	dc.b 0, 1	
		dc.b $FC, $C, 0, 2, $FF, $F8	
SME_5RxVB_1C:	dc.b 0, 2	
		dc.b $FC, 8, 0, 6, $FF, $F8	
		dc.b $FC, 8, 0, 3, 0, $10	
SME_5RxVB_2A:	dc.b 0, 1	
		dc.b $F8, 1, 0, 9, $FF, $FC	
SME_5RxVB_32:	dc.b 0, 1	
		dc.b $E8, 3, 0, $B, $FF, $FC	
SME_5RxVB_3A:	dc.b 0, 2	
		dc.b $D8, 2, 0, $B, $FF, $FC	
		dc.b $F0, 2, 0, $F, $FF, $FC	
		even