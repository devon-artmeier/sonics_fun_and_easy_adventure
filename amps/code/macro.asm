; ===========================================================================
; ---------------------------------------------------------------------------
; Various assembly flags
; ---------------------------------------------------------------------------
	opt ae+

; if safe mode is enabled (1), then the driver will attempt to find any issues.
; if Vladik's error debugger is installed, then the error will be displayed.
; else, the CPU is trapped.

safe =	0

; Select the tempo algorith.
; 0 = Overflow method.
; 1 = Counter method.

tempo =	0
; ===========================================================================
; ---------------------------------------------------------------------------
; Channel configuration
; ---------------------------------------------------------------------------

	rsset 0
cFlags		rs.b 1		; various channel flags, see below
cType		rs.b 1		; hardware type for the channel
cData		rs.l 1		; 68k tracker address for the channel
cPanning	rs.b 0		; channel panning and LFO. FM and DAC only
cEnvPos		rs.b 1		; volume envelope position. PSG only
cDetune		rs.b 1		; frequency detune (offset)
cPitch		rs.b 1		; pitch (transposition) offset
cVolume		rs.b 1		; channel volume
cTick		rs.b 1		; channel tick multiplier
cSample		rs.b 0		; channel sample ID, DAC only
cVolEnv		rs.b 0		; volume envelope ID. PSG only
cVoice		rs.b 1		; YM2612 voice ID. FM only
cDuration	rs.b 1		; current note duration
cLastDur	rs.b 1		; last note duration
cFreq		rs.w 1		; channel base frequency
cModDelay	rs.b 0		; delay before modulation starts
cMod		rs.l 1		; modulation data address
cModFreq	rs.w 1		; modulation frequency offset
cModSpeed	rs.b 1		; number of frames til next modulation step
cModStep	rs.b 1		; modulation frequency offset per step
cModCount	rs.b 1		; number of modulation steps until reversal
cLoop		rs.b 3		; loop counter values
cStatPSG4 =	__rs-1		; PSG4 type value. PSG3 only
cPrio =		__rs-2		; sound effect channel priority. SFX only
cSizeSFX	rs.w 0		; size of each SFX track

cNoteTimeCur	rs.b 1		; frame counter to note off. Music only
cNoteTimeMain	rs.b 1		; copy of frame counter to note off. Music only
cStack		rs.b 1		; channel stack pointer. Music only
		rs.b 1		; unused. Music only
		rs.l 3		; channel stack data. Music only
cSize		rs.w 0		; size of each music track
; ===========================================================================
; ---------------------------------------------------------------------------
; Bits for cFlags
; ---------------------------------------------------------------------------

	rsset 0
cfbMode		rs.b 0		; set if in pitch mode, clear if in sample mode. DAC only
cfbRest		rs.b 1		; set if channel is resting. FM and PSG only
cfbInt		rs.b 1		; set if interrupted by SFX. Music only
cfbHold		rs.b 1		; set if playing notes does not trigger note-on's
cfbMod		rs.b 1		; set if modulation is enabled
cfbCond		rs.b 1		; set if ignoring many tracker commands
cfbVol		rs.b 1		; set if channel should update volume
cfbRun =	$07		; set if channel is running a tracker
; ===========================================================================
; ---------------------------------------------------------------------------
; Misc variables for channel modes
; ---------------------------------------------------------------------------

ctbPt2 =	$02		; bit part 2 - FM 4-6
ctFM1 =		$00		; FM 1
ctFM2 =		$01		; FM 2
ctFM3 =		$02		; FM 3	- Valid for SFX
ctFM4 =		$04		; FM 4	- Valid for SFX
ctFM5 =		$05		; FM 5	- Valid for SFX

ctbDAC =	$03		; DAC bit
ctDAC1 =	(1<<ctbDAC)|$03	; DAC 1	- Valid for SFX
ctDAC2 =	(1<<ctbDAC)|$06	; DAC 2

ctPSG1 =	$80		; PSG 1	- Valid for SFX
ctPSG2 =	$A0		; PSG 2	- Valid for SFX
ctPSG3 =	$C0		; PSG 3	- Valid for SFX
ctPSG4 =	$E0		; PSG 4
; ===========================================================================
; ---------------------------------------------------------------------------
; Misc flags
; ---------------------------------------------------------------------------

Mus_DAC =	2		; number of DAC channels
Mus_FM =	5		; number of FM channels
Mus_PSG =	3		; number of PSG channels
Mus_Ch =	Mus_DAC+Mus_FM+Mus_PSG; total number of music channels
SFX_DAC =	1		; number of DAC SFX channels
SFX_FM =	3		; number of FM SFX channels
SFX_PSG =	3		; number of PSG SFX channels
SFX_Ch =	SFX_DAC+SFX_FM+SFX_PSG; total number of SFX channels

VoiceRegs =	29		; total number of registers inside of a voice
VoiceTL =	VoiceRegs-4	; location of voice TL levels

MaxPitch =	$1000		; this is the maximum pitch Dual PCM is capable of processing
Z80E_Read =	$00018		; this is used by Dual PCM internally but we need this for macros

; NOTE: There is no magic trick to making Dual PCM play samples at higher rates.
; These values are only here to allow you to give lower pitch samples higher
; quality, and playing samples at higher rates than Dual PCM can process them
; may decrease the perceived quality by the end user. Use these equates only
; if you know what you are doing.

sr17 =		$0140		; 5 Quarter sample rate	17500 Hz
sr15 =		$0120		; 9 Eights sample rate	15750 Hz
sr14 =		$0100		; Default sample rate	14000 Hz
sr12 =		$00E0		; 7 Eights sample rate	12250 Hz
sr10 =		$00C0		; 3 Quarter sample rate	10500 Hz
sr8 =		$00A0		; 5 Eights sample rate	8750 Hz
sr7 =		$0080		; Half sample rate	7000 HZ
sr5 =		$0060		; 3 Eights sample rate	5250 Hz
sr3 =		$0040		; 1 Quarter sample rate	3500 Hz
; ===========================================================================
; ---------------------------------------------------------------------------
; Sound driver RAM configuration
; ---------------------------------------------------------------------------

dZ80 =		$A00000		; quick reference to Z80 RAM
dPSG =		$C00011		; quick reference to PSG port

; ===========================================================================
; ---------------------------------------------------------------------------
; Bits for mFlags
; ---------------------------------------------------------------------------

	rsset 0
mfbRing		rs.b 1		; if set, change speaker (play different sfx)
mfbSpeed	rs.b 1		; if set, speed shoes are active
mfbWater	rs.b 1		; if set, underwater mode is active
mfbNoPAL	rs.b 1		; if set, play songs slowly in PAL region
mfbPaused =	$07		; if set, sound driver is paused
; ===========================================================================
; ---------------------------------------------------------------------------
; Sound ID equates
; ---------------------------------------------------------------------------

	rsset 1
Mus_Reset	rs.b 1		; reset underwater and speed shoes flags, update volume
Mus_FadeOut	rs.b 1		; initialize a music fade out
Mus_Stop	rs.b 1		; stop all music
Mus_ShoesOn	rs.b 1		; enable speed shoes mode
Mus_ShoesOff	rs.b 1		; disable speed shoes mode
Mus_ToWater	rs.b 1		; enable underwater mode
Mus_OutWater	rs.b 1		; disable underwater mode
Mus_Pause	rs.b 1		; pause the music
Mus_Unpause	rs.b 1		; unpause the music
MusOff		rs.b 0		; first music ID

MusCount =	$78		; number of installed music tracks
SFXoff =	MusCount+MusOff	; first SFX ID
SFXcount =	$78		; number of intalled sound effects
; ===========================================================================
; ---------------------------------------------------------------------------
; Condition modes
; ---------------------------------------------------------------------------

	rsset 0
dcoT		rs.b 1		; condition T	; True
dcoF		rs.b 1		; condition F	; False
dcoHI		rs.b 1		; condition HI	; HIgher (unsigned)
dcoLS		rs.b 1		; condition LS	; Less or Same (unsigned)
dcoHS		rs.b 0		; condition HS	; Higher or Sane (unsigned)
dcoCC		rs.b 1		; condition CC	; Carry Clear (unsigned)
dcoLO		rs.b 0		; condition LO	; LOwer (unsigned)
dcoCS		rs.b 1		; condition CS	; Carry Set (unsigned)
dcoNE		rs.b 1		; condition NE	; Not Equal
dcoEQ		rs.b 1		; condition EQ	; EQual
dcoVC		rs.b 1		; condition VC	; oVerflow Clear (signed)
dcoVS		rs.b 1		; condition VS	; oVerflow Set (signed)
dcoPL		rs.b 1		; condition PL	; Positive (PLus)
dcoMI		rs.b 1		; condition MI	; Negamite (MInus)
dcoGE		rs.b 1		; condition GE	; Greater or Equal (signed)
dcoLT		rs.b 1		; condition LT	; Less Than (signed)
dcoGT		rs.b 1		; condition GT	; GreaTer (signed)
dcoLE		rs.b 1		; condition LE	; Less or Equal (signed)
; ===========================================================================
; ---------------------------------------------------------------------------
; Emvelope commands equates
; ---------------------------------------------------------------------------

	rsset $80
eReset		rs.w 1		; 80 - Restart from position 0
eHold		rs.w 1		; 82 - Hold volume at current level
eLoop		rs.w 1		; 84 - Jump back/forwards according to next byte
eStop		rs.w 1		; 86 - Stop current note and envelope
eLast		rs.w 0		; safe mode equate
; ===========================================================================
; ---------------------------------------------------------------------------
; Fade out end commands
; ---------------------------------------------------------------------------

	rsset $80
fEnd		rs.l 1		; 80 - Do nothing
fStop		rs.l 1		; 84 - Stop all music
fResVol		rs.l 1		; 88 - Reset volume and update
fReset		rs.l 1		; 8C - Stop music playing and reset volume
fLast		rs.l 0		; safe mode equate
; ===========================================================================
; ---------------------------------------------------------------------------
; Quickly read a word from odd address. 28 cycles
; ---------------------------------------------------------------------------

dREAD_WORD	macro areg, dreg
	move.b	(\areg)+,(sp)		; read the next byte into stack
	move.w	(sp),\dreg		; get word back from stack (shift byte by 8 bits)
	move.b	(\areg),\dreg		; get the next byte into register
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; used to calculate the address of the right FM voice
; ---------------------------------------------------------------------------

dCALC_VOICE	macro off
	lsl.w	#5,d0			; multiply voice ID by $20
	if narg>0
		add.w	#\off,d0	; if have had extra argument, add it to offset
	endif

	add.w	d0,a1			; add offset to voice table address
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Tells the Z80 to stop, and waits for it to finish stopping (acquire bus)
; ---------------------------------------------------------------------------

;stopZ80 	macro
;	move.w	#$100,$A11100		; stop the Z80
;.loop\@
;	btst	#0,$A11100
;	bne.s	.loop\@			; loop until it says it's stopped
;    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Tells the Z80 to start again
; ---------------------------------------------------------------------------

;startZ80 	macro
;	move.w	#0,$A11100		; start the Z80
;    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Macro for pausing music
; ---------------------------------------------------------------------------

AMPS_MUSPAUSE	macro	; enable request pause and paused flags
	move.b	#Mus_Pause,mQueue+2.w
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Macro for unpausing music
; ---------------------------------------------------------------------------

AMPS_MUSUNPAUSE	macro	; enable request unpause flag
	move.b	#Mus_Unpause,mQueue+2.w
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Macro for queueing sound
; ---------------------------------------------------------------------------

playSnd	macro id, queue	; queue sound
	move.b	\id,(mQueue+((\queue\)-1)).w
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Create volume envelope table, and SMPS2ASM equates
; ---------------------------------------------------------------------------

volenv		macro name
	rept narg			; repeate for all arguments
v\name =	__venv			; create SMPS2ASM equate
		dc.l vd\name		; create pointer
__venv =	__venv+1		; increase ID
	shift				; shift next argument into view
	endr
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Creates SFX pointers table, and creates necessary equates
; ---------------------------------------------------------------------------

ptrSFX		macro type, name
.type =		\type<<24		; create equate for the type mask

	rept narg-1			; repeat for all arguments
		dc.l \name\|.type	; create pointer with specified type
__sfx =		__sfx+1			; increase SFX ID
	shift				; shift next argument into view
	endr
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Creates music pointers table, and creates necessary equates
; ---------------------------------------------------------------------------

ptrMusic	macro name, sptempo
	rept narg/2			; repeat for half of the arguments
		dc.l ((\sptempo)<<24)|\name\; create pointer with tempo
__mus =		__mus+1			; increase music ID
	shift				; shift next argument into view
	shift				; ''
	endr
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Include PCM data
; ---------------------------------------------------------------------------

incSWF		macro name, file
SWF_\name\	incbin	\file		; include PCM data
SWFR_\name\ 	dcb.b Z80E_Read*(MaxPitch/$100),$00; add end markers (for Dual PCM)
    endm
; ===========================================================================
; ---------------------------------------------------------------------------
; Create data for a sample
; ---------------------------------------------------------------------------

sample		macro freq, start, loop, name
	if narg=4		; if we have 4 arguments, we'd like a custom name
d\name =	__samp		; use the extra argument to create SMPS2ASM equate
	else
d\start =	__samp		; else, use the first one!
	endif

__samp =	__samp+1	; increase sample ID
; create offsets for the sample normal, reverse, loop normal, loop reverse.
	dc.b SWF_\start&$FF,((SWF_\start>>$08)&$7F)|$80,(SWF_\start>>$0F)&$FF
	dc.b (SWFR_\start-1)&$FF,(((SWFR_\start-1)>>$08)&$7F)|$80,((SWFR_\start-1)>>$0F)&$FF
	dc.b SWF_\loop&$FF,((SWF_\loop>>$08)&$7F)|$80, (SWF_\loop>>$0F)&$FF
	dc.b (SWFR_\loop-1)&$FF,(((SWFR_\loop-1)>>$08)&$7F)|$80,((SWFR_\loop-1)>>$0F)&$FF
	dc.w \freq-$100		; sample frequency (actually offset, so we remove $100)
	dc.w 0			; unused!
    endm
; ===========================================================================
	opt ae-
