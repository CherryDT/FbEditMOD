RAHexEdInstall			PROTO C :DWORD,:DWORD
RAHexEdUnInstall		PROTO

DEFBCKCOLOR				equ 00C0F0F0h
DEFADRTXTCOLOR			equ 00800000h
DEFDTATXTCOLOR			equ 00000000h
DEFASCTXTCOLOR			equ 00008000h
DEFSELBCKCOLOR			equ 00800000h
DEFLFSELBCKCOLOR		equ 00C0C0C0h
DEFSELTXTCOLOR			equ 00FFFFFFh
DEFSELASCCOLOR			equ 00C0C0C0h
DEFSELBARCOLOR			equ 00C0C0C0h
DEFSELBARPEN			equ 00808080h
DEFLNRCOLOR				equ 00800000h

HEM_RAINIT				equ WM_USER+9999	;wParam=0, lParam=pointer to controls DIALOG struct
HEM_BASE				equ WM_USER+1000

;Private messages
HEM_SETFONT				equ HEM_BASE+1		;wParam=nLineSpacing, lParam=lpRAFONT
HEM_GETFONT				equ HEM_BASE+2		;wParam=0, lParam=lpRAFONT
HEM_SETCOLOR			equ HEM_BASE+3		;wParam=0, lParam=lpRACOLOR
HEM_GETCOLOR			equ HEM_BASE+4		;wParam=0, lParam=lpRACOLOR
HEM_VCENTER				equ HEM_BASE+5		;wParam=0, lParam=0
HEM_REPAINT				equ HEM_BASE+6		;wParam=0, lParam=0
HEM_ANYBOOKMARKS		equ HEM_BASE+7		;wParam=0, lParam=0
HEM_TOGGLEBOOKMARK		equ HEM_BASE+8		;wParam=nLine, lParam=0
HEM_CLEARBOOKMARKS		equ HEM_BASE+9		;wParam=0, lParam=0
HEM_NEXTBOOKMARK		equ HEM_BASE+10		;wParam=0, lParam=0
HEM_PREVIOUSBOOKMARK	equ HEM_BASE+11		;wParam=0, lParam=0
HEM_SELBARWIDTH			equ HEM_BASE+12		;wParam=nWidth, lParam=0
HEM_LINENUMBERWIDTH		equ HEM_BASE+13		;wParam=nWidth, lParam=0
HEM_SETSPLIT			equ HEM_BASE+14		;wParam=nSplitt, lParam=0
HEM_GETSPLIT			equ HEM_BASE+15		;wParam=0, lParam=0
HEM_GETBYTE				equ HEM_BASE+16		;wParam=cp, lParam=0
HEM_SETBYTE				equ HEM_BASE+17		;wParam=cp, lParam=ByteVal
HEM_GETOFFSET			equ HEM_BASE+18		;wParam=0, lParam=0
HEM_SETOFFSET			equ HEM_BASE+19		;wParam=ofs, lParam=0
HEM_SETMEM				equ HEM_BASE+20		;wParam=nBytes, lParam=lpBytes
HEM_GETMEM				equ HEM_BASE+21		;wParam=nBytes, lParam=lpBytes

FR_HEX					equ 2

HEX_STYLE_NOSPLITT		equ 0001h			;No splitt button
HEX_STYLE_NOLINENUMBER	equ 0002h			;No linenumber button
HEX_STYLE_NOHSCROLL		equ 0004h			;No horizontal scrollbar
HEX_STYLE_NOVSCROLL		equ 0008h			;No vertical scrollbar
HEX_STYLE_NOSIZEGRIP	equ 0010h			;No size grip
HEX_STYLE_NOSTATE		equ 0020h			;No state indicator
HEX_STYLE_NOADDRESS		equ 0040h			;No adress field
HEX_STYLE_NOASCII		equ 0080h			;No ascii field
HEX_STYLE_NOUPPERCASE	equ 0100h			;Hex numbers is lowercase letters
HEX_STYLE_READONLY		equ 0200h			;Text is locked
HEX_STYLE_ADDRESSBITS8	equ 0400h			;8 bit address
HEX_STYLE_ADDRESSBITS16	equ 0800h			;16 bit address
HEX_STYLE_ADDRESSBITS32	equ 0000h			;32 bit address
HEX_STYLE_NOINSDEL		equ 1000h			;Bytes can not be inserted or deleted

HEFONT struct
	hFont			dd ?		;Code edit normal
	hLnrFont		dd ?		;Line numbers
HEFONT ends

HECOLOR struct
	bckcol			dd ?		;Back color
	adrtxtcol		dd ?		;Text color
	dtatxtcol		dd ?		;Text color
	asctxtcol		dd ?		;Text color
	selbckcol		dd ?		;Sel back color
	sellfbckcol		dd ?		;Sel lost focus back color
	seltxtcol		dd ?		;Sel text color
	selascbckcol	dd ?		;Sel back color
	selbarbck		dd ?		;Selection bar
	selbarpen		dd ?		;Selection bar pen
	lnrcol			dd ?		;Line numbers color
HECOLOR ends

HESELCHANGE struct
	nmhdr			NMHDR <?>
	chrg			CHARRANGE <?>
	seltyp			dw ?		;SEL_TEXT or SEL_OBJECT
					dw ?
	line			dd ?		;Line number
	nlines			dd ?		;Total number of lines
	fchanged		dd ?		;TRUE if changed since last
HESELCHANGE ends

HEBMK struct
	hWin			dd ?		;Handle of window having the bookmark
	nLine			dd ?		;Bokkmarked line
HEBMK ends

.const

szRAHexEdClassName	db 'RAHEXEDIT',0
szHexChildClassName	db 'RAHEXEDITCHILD',0
