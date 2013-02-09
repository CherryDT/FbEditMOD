
;Default colors
DEFBCKCOLOR				equ 00C0F0F0h
DEFTXTCOLOR				equ 00000000h
DEFSELBCKCOLOR			equ 00800000h
DEFSELTXTCOLOR			equ 00FFFFFFh
DEFCMNTCOLOR			equ 02008000h
DEFSTRCOLOR				equ 00A00000h
DEFOPRCOLOR				equ 000000A0h
DEFHILITE1				equ 00F0C0C0h
DEFHILITE2				equ 00C0F0C0h
DEFHILITE3				equ 00C0C0F0h
DEFSELBARCOLOR			equ 00C0C0C0h
DEFSELBARPEN			equ 00808080h
DEFLNRCOLOR				equ 00800000h
DEFNUMCOLOR				equ 00808080h

;Window styles
STYLE_NOSPLITT			equ 00001h			;No splitt button
STYLE_NOLINENUMBER		equ 00002h			;No linenumber button
STYLE_NOCOLLAPSE		equ 00004h			;No expand/collapse buttons
STYLE_NOHSCROLL			equ 00008h			;No horizontal scrollbar
STYLE_NOVSCROLL			equ 00010h			;No vertical scrollbar
STYLE_NOHILITE			equ 00020h			;No color hiliting
STYLE_NOSIZEGRIP		equ 00040h			;No size grip
STYLE_NODBLCLICK		equ 00080h			;No action on double clicks
STYLE_READONLY			equ 00100h			;Text is locked
STYLE_NODIVIDERLINE		equ 00200h			;Blocks are not divided by line
STYLE_NOBACKBUFFER		equ 00400h			;Drawing directly to screen DC
STYLE_NOSTATE			equ 00800h			;No state indicator
STYLE_DRAGDROP			equ 01000h			;Drag & Drop support, app must load ole
STYLE_SCROLLTIP			equ 02000h			;Scrollbar tooltip
STYLE_HILITECOMMENT		equ 04000h			;Comments are hilited
STYLE_AUTOSIZELINENUM	equ 08000h			;Line number column autosizes
STYLE_NOLOCK			equ 10000h			;No lock button

;Edit modes
MODE_NORMAL				equ 0				;Normal
MODE_BLOCK				equ 1				;Block select
MODE_OVERWRITE			equ 2				;Overwrite

;REM_COMMAND commands
CMD_LEFT				equ 1
CMD_RIGHT				equ 2
CMD_LINE_UP				equ 3
CMD_LINE_DOWN			equ 4
CMD_PAGE_UP				equ 5
CMD_PAGE_DOWN			equ 6
CMD_HOME				equ 7
CMD_END					equ 8
CMD_INSERT				equ 9
CMD_DELETE				equ 10
CMD_BACKSPACE			equ 11
;REM_COMMAND modifyers
CMD_ALT					equ 256
CMD_CTRL				equ 512
CMD_SHIFT				equ 1024

;Private edit messages
REM_RAINIT				equ WM_USER+9999	;wParam=0, lParam=pointer to controls DIALOG struct
REM_BASE				equ WM_USER+1000
REM_SETHILITEWORDS		equ REM_BASE+0		;wParam=Color, lParam=lpszWords
REM_SETFONT				equ REM_BASE+1		;wParam=nLineSpacing, lParam=lpRAFONT
REM_GETFONT				equ REM_BASE+2		;wParam=0, lParam=lpRAFONT
REM_SETCOLOR			equ REM_BASE+3		;wParam=0, lParam=lpRACOLOR
REM_GETCOLOR			equ REM_BASE+4		;wParam=0, lParam=lpRACOLOR
REM_SETHILITELINE		equ REM_BASE+5		;wParam=Line, lParam=Color
REM_GETHILITELINE		equ REM_BASE+6		;wParam=Line, lParam=0
REM_SETBOOKMARK			equ REM_BASE+7		;wParam=Line, lParam=Type
REM_GETBOOKMARK			equ REM_BASE+8		;wParam=Line, lParam=0
REM_CLRBOOKMARKS		equ REM_BASE+9		;wParam=0, lParam=Type
REM_NXTBOOKMARK			equ REM_BASE+10		;wParam=Line, lParam=Type
REM_PRVBOOKMARK			equ REM_BASE+11		;wParam=Line, lParam=Type
REM_FINDBOOKMARK		equ REM_BASE+12		;wParam=BmID, lParam=0
REM_SETBLOCKS			equ REM_BASE+13		;wParam=[lpLINERANGE], lParam=0
REM_ISLINE				equ REM_BASE+14		;wParam=Line, lParam=lpszDef
REM_GETWORD				equ REM_BASE+15		;wParam=BuffSize, lParam=lpBuff
REM_COLLAPSE			equ REM_BASE+16		;wParam=Line, lParam=0
REM_COLLAPSEALL			equ REM_BASE+17		;wParam=0, lParam=0
REM_EXPAND				equ REM_BASE+18		;wParam=Line, lParam=0
REM_EXPANDALL			equ REM_BASE+19		;wParam=0, lParam=0
REM_LOCKLINE			equ REM_BASE+20		;wParam=Line, lParam=TRUE/FALSE
REM_ISLINELOCKED		equ REM_BASE+21		;wParam=Line, lParam=0
REM_HIDELINE			equ REM_BASE+22		;wParam=Line, lParam=TRUE/FALSE
REM_ISLINEHIDDEN		equ REM_BASE+23		;wParam=Line, lParam=0
REM_AUTOINDENT			equ REM_BASE+24		;wParam=0, lParam=TRUE/FALSE
REM_TABWIDTH			equ REM_BASE+25		;wParam=nChars, lParam=TRUE/FALSE (Expand tabs)
REM_SELBARWIDTH			equ REM_BASE+26		;wParam=nWidth, lParam=0
REM_LINENUMBERWIDTH		equ REM_BASE+27		;wParam=nWidth, lParam=0
REM_MOUSEWHEEL			equ REM_BASE+28		;wParam=nLines, lParam=0
REM_SUBCLASS			equ REM_BASE+29		;wParam=0, lParam=lpWndProc
REM_SETSPLIT			equ REM_BASE+30		;wParam=nSplit, lParam=0
REM_GETSPLIT			equ REM_BASE+31		;wParam=0, lParam=0
REM_VCENTER				equ REM_BASE+32		;wParam=0, lParam=0
REM_REPAINT				equ REM_BASE+33		;wParam=0, lParam=TRUE/FALSE (Paint Now)
REM_BMCALLBACK			equ REM_BASE+34		;wParam=0, lParam=lpBmProc
REM_READONLY			equ REM_BASE+35		;wParam=0, lParam=TRUE/FALSE
REM_INVALIDATELINE		equ REM_BASE+36		;wParam=Line, lParam=0
REM_SETPAGESIZE			equ REM_BASE+37		;wParam=nLines, lParam=0
REM_GETPAGESIZE			equ REM_BASE+38		;wParam=0, lParam=0
REM_GETCHARTAB			equ REM_BASE+39		;wParam=nChar, lParam=0
REM_SETCHARTAB			equ REM_BASE+40		;wParam=nChar, lParam=nValue
REM_SETCOMMENTBLOCKS	equ REM_BASE+41		;wParam=lpStart, lParam=lpEnd
REM_SETWORDGROUP		equ REM_BASE+42		;wParam=0, lParam=nGroup (0-15)
REM_GETWORDGROUP		equ REM_BASE+43		;wParam=0, lParam=0
REM_SETBMID				equ REM_BASE+44		;wParam=nLine, lParam=nBmID
REM_GETBMID				equ REM_BASE+45		;wParam=nLine, lParam=0
REM_ISCHARPOS			equ REM_BASE+46		;wParam=CP, lParam=0, returns 1 if comment block, 2 if comment, 3 if string
REM_HIDELINES			equ REM_BASE+47		;wParam=nLine, lParam=nLines
REM_SETDIVIDERLINE		equ REM_BASE+48		;wParam=nLine, lParam=TRUE/FALSE
REM_ISINBLOCK			equ REM_BASE+49		;wParam=nLine, lParam=lpRABLOCKDEF
REM_TRIMSPACE			equ REM_BASE+50		;wParam=nLine, lParam=fLeft
REM_SAVESEL				equ REM_BASE+51		;wParam=0, lParam=0
REM_RESTORESEL			equ REM_BASE+52		;wParam=0, lParam=0
REM_GETCURSORWORD		equ REM_BASE+53		;wParam=BuffSize, lParam=lpBuff
REM_SETSEGMENTBLOCK		equ REM_BASE+54		;wParam=nLine, lParam=TRUE/FALSE
REM_GETMODE				equ REM_BASE+55		;wParam=0, lParam=0
REM_SETMODE				equ REM_BASE+56		;wParam=nMode, lParam=0
REM_GETBLOCK			equ REM_BASE+57		;wParam=0, lParam=lpBLOCKRANGE
REM_SETBLOCK			equ REM_BASE+58		;wParam=0, lParam=lpBLOCKRANGE
REM_BLOCKINSERT			equ REM_BASE+59		;wParam=0, lParam=lpText
REM_LOCKUNDOID			equ REM_BASE+60		;wParam=TRUE/FALSE, lParam=0
REM_ADDBLOCKDEF			equ REM_BASE+61		;wParam=0, lParam=lpRABLOCKDEF
REM_CONVERT				equ REM_BASE+62		;wParam=nType, lParam=0
REM_BRACKETMATCH		equ REM_BASE+63		;wParam=0, lParam=lpDef {[(,}]),_
REM_COMMAND				equ REM_BASE+64		;wParam=nCommand, lParam=0
REM_CASEWORD			equ REM_BASE+65		;wParam=cp, lParam=lpWord
REM_GETBLOCKEND			equ REM_BASE+66		;wParam=Line, lParam=0
REM_SETLOCK				equ REM_BASE+67		;wParam=TRUE/FALSE, lParam=0
REM_GETLOCK				equ REM_BASE+68		;wParam=0, lParam=0
REM_GETWORDFROMPOS		equ REM_BASE+69		;wParam=cp, lParam=lpBuff
REM_SETNOBLOCKLINE		equ REM_BASE+70		;wParam=Line, lParam=TRUE/FALSE
REM_ISLINENOBLOCK		equ REM_BASE+71		;wParam=Line, lParam=0

;Convert types
CONVERT_TABTOSPACE		equ 0
CONVERT_SPACETOTAB		equ 1
CONVERT_UPPERCASE		equ 2
CONVERT_LOWERCASE		equ 3

;Line hiliting
STATE_HILITEOFF			equ 0
STATE_HILITE1			equ 1
STATE_HILITE2			equ 2
STATE_HILITE3			equ 3
STATE_HILITEMASK		equ 3

;Bookmarks
STATE_BMOFF				equ 00h
STATE_BM1				equ 10h
STATE_BM2				equ 20h
STATE_BM3				equ 30h
STATE_BM4				equ 40h
STATE_BM5				equ 50h
STATE_BM6				equ 60h
STATE_BM7				equ 70h
STATE_BM8				equ 80h
STATE_BMMASK			equ 0F0h

;Line states
STATE_LOCKED			equ 0100h
STATE_HIDDEN			equ 0200h
STATE_COMMENT			equ 0400h
STATE_DIVIDERLINE		equ 0800h
STATE_SEGMENTBLOCK		equ 1000h
STATE_NOBLOCK			equ 2000h
STATE_GARBAGE			equ 80000000h

;Character table types
CT_NONE					equ 0
CT_CHAR					equ 1
CT_OPER					equ 2
CT_HICHAR				equ 3
CT_CMNTCHAR				equ 4
CT_STRING				equ 5
CT_CMNTDBLCHAR			equ 6
CT_CMNTINITCHAR			equ 7

RAFONT struct
	hFont		dd ?						;Code edit normal
	hIFont		dd ?						;Code edit italics
	hLnrFont	dd ?						;Line numbers
RAFONT ends

RACOLOR struct
	bckcol		dd ?						;Back color
	txtcol		dd ?						;Text color
	selbckcol	dd ?						;Sel back color
	seltxtcol	dd ?						;Sel text color
	cmntcol		dd ?						;Comment color
	strcol		dd ?						;String color
	oprcol		dd ?						;Operator color
	hicol1		dd ?						;Line hilite 1
	hicol2		dd ?						;Line hilite 2
	hicol3		dd ?						;Line hilite 3
	selbarbck	dd ?						;Selection bar
	selbarpen	dd ?						;Selection bar pen
	lnrcol		dd ?						;Line numbers color
	numcol		dd ?						;Numbers & hex color
RACOLOR ends

RASELCHANGE struct
	nmhdr		NMHDR <?>
	chrg		CHARRANGE <?>				;Current selection
	seltyp		dw ?						;SEL_TEXT or SEL_OBJECT
	line		dd ?						;Line number
	cpLine		dd ?						;Character position of first character
	lpLine		dd ?						;Pointer to line
	nlines		dd ?						;Total number of lines
	nhidden		dd ?						;Total number of hidden lines
	fchanged	dd ?						;TRUE if changed since last
	npage		dd ?						;Page number
	nWordGroup	dd ?						;Hilite word group(0-15)
RASELCHANGE ends

BD_NONESTING			equ 01h				;Set to true for non nested blocks
BD_DIVIDERLINE			equ 02h				;Draws a divider line
BD_INCLUDELAST			equ 04h				;lpszEnd line is also collapsed
BD_LOOKAHEAD			equ 08h				;Look 500 lines ahead for the ending
BD_SEGMENTBLOCK			equ 10h				;Segment block, collapse till next segmentblock
BD_COMMENTBLOCK			equ 20h				;Comment block
BD_NOBLOCK				equ 40h				;

RABLOCKDEF struct
	lpszStart	dd ?						;Block start
	lpszEnd		dd ?						;Block end
	lpszNot1	dd ?						;Dont hide line containing this or set to NULL
	lpszNot2	dd ?						;Dont hide line containing this or set to NULL
	flag		dd ?						;High word is WordGroup(0-15)
RABLOCKDEF ends

LINERANGE struct
	lnMin		dd ?						;Starting line
	lnMax		dd ?						;Ending line
LINERANGE ends

BLOCKRANGE struct
	lnMin		dd ?						;Starting line
	clMin		dd ?						;Starting column
	lnMax		dd ?						;Ending line
	clMax		dd ?						;Ending column
BLOCKRANGE ends

.const

szRAEditClass	db 'RAEdit',0
szEditClassName	db 'RAEditChild',0
