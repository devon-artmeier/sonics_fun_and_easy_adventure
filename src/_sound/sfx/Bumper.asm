Bumper_Header:
	sHeaderInit	
	sHeaderPrio	$60
	sHeaderCh	$03
	sHeaderSFX	$80, $05, Bumper_FM5, $00, $00
	sHeaderSFX	$80, $04, Bumper_FM4, $00, $00
	sHeaderSFX	$80, $02, Bumper_FM3, $00, $02

Bumper_FM5:
	sVoice		$0D
	ssJump		Bumper_Jump1

Bumper_FM4:
	sVoice		$0D
	saDetune	$07
	dc.b nRst, $01

Bumper_Jump1:
	dc.b nA4, $20
	sStop	

Bumper_FM3:
	sVoice		$0E
	dc.b nCs2, $03
	sStop	
