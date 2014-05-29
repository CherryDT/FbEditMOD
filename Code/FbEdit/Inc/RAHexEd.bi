

#Include Once "win\richedit.bi"


#Define DEFBCKCOLOR				&H00C0F0F0
#Define DEFADRTXTCOLOR			&H00800000
#Define DEFDTATXTCOLOR			&H00000000
#Define DEFASCTXTCOLOR			&H00008000
#Define DEFSELBCKCOLOR			&H00800000
#Define DEFLFSELBCKCOLOR		&H00C0C0C0
#Define DEFSELTXTCOLOR			&H00FFFFFF
#Define DEFSELASCCOLOR			&H00C0C0C0
#Define DEFSELBARCOLOR			&H00C0C0C0
#Define DEFSELBARPEN			&H00808080
#Define DEFLNRCOLOR				&H00800000

#Define HEM_RAINIT				WM_USER+9999	' wParam=0, lParam=pointer to controls DIALOG struct
#Define HEM_BASE				WM_USER+1000

' Private messages
#Define HEM_SETFONT				HEM_BASE+1		' nLineSpacing, lpHEFONT:HEFONT Ptr
#Define HEM_GETFONT				HEM_BASE+2		' 0,lpHEFONT:HEFONT Ptr, returns nLineSpacing
#Define HEM_SETCOLOR			HEM_BASE+3		' 0,lpHECOLOR:HECOLOR Ptr
#Define HEM_GETCOLOR			HEM_BASE+4		' 0,lpHECOLOR:HECOLOR Ptr
#Define HEM_VCENTER				HEM_BASE+5		' 0,0
#Define HEM_REPAINT				HEM_BASE+6		' 0,0
#Define HEM_ANYBOOKMARKS		HEM_BASE+7		' 0,0
#Define HEM_TOGGLEBOOKMARK		HEM_BASE+8		' nLine:Integer,0
#Define HEM_CLEARBOOKMARKS		HEM_BASE+9		' 0,0
#Define HEM_NEXTBOOKMARK		HEM_BASE+10		' 0,0
#Define HEM_PREVIOUSBOOKMARK	HEM_BASE+11		' 0,0
#Define HEM_SELBARWIDTH			HEM_BASE+12		' nWidth:Integer,0
#Define HEM_LINENUMBERWIDTH	    HEM_BASE+13		' nWidth:Integer,0
#Define HEM_SETSPLIT			HEM_BASE+14		' nSplit:Integer,0
#Define HEM_GETSPLIT			HEM_BASE+15		' 0,0|Integer
#Define HEM_GETBYTE				HEM_BASE+16		' cp:Integer,0
#Define HEM_SETBYTE				HEM_BASE+17		' cp:Integer,nByteVal:Integer
#Define HEM_GETOFFSET			HEM_BASE+18		' wParam=0, lParam=0
#Define HEM_SETOFFSET			HEM_BASE+19		' wParam=ofs, lParam=0
#Define HEM_SETMEM				HEM_BASE+20		' wParam=nBytes, lParam=lpBytes
#Define HEM_GETMEM				HEM_BASE+21		' wParam=nBytes, lParam=lpBytes
#Define HEM_SETMODE				HEM_BASE+22		' wParam=nMode,  lParam=0
#Define HEM_GETMODE				HEM_BASE+23		' wParam=0, lParam=0, returns nMode
#Define HEM_SUBCLASS			HEM_BASE+24		' wParam=0, lParam=lpWndProc

' Modes
#Define MODE_NORMAL				0				' Normal (insert)
#Define MODE_OVERWRITE			2				' Overwrite mode

#Define FR_HEX					2

#Define HEX_STYLE_NOSPLITT		&H0001			' No splitt button
#Define HEX_STYLE_NOLINENUMBER	&H0002			' No linenumber button
#Define HEX_STYLE_NOHSCROLL		&H0004			' No horizontal scrollbar
#Define HEX_STYLE_NOVSCROLL		&H0008			' No vertical scrollbar
#Define HEX_STYLE_NOSIZEGRIP	&H0010			' No size grip
#Define HEX_STYLE_NOSTATE		&H0020			' No state indicator
#Define HEX_STYLE_NOADDRESS		&H0040			' No adress field
#Define HEX_STYLE_NOASCII		&H0080			' No ascii field
#Define HEX_STYLE_NOUPPERCASE	&H0100			' Hex numbers is lowercase letters
#Define HEX_STYLE_READONLY		&H0200			' Text is locked
#Define HEX_STYLE_ADDRESSBITS8	&H0400			' 8 bit address
#Define HEX_STYLE_ADDRESSBITS16	&H0800			' 16 bit address
#Define HEX_STYLE_ADDRESSBITS32	&H0000			' 32 bit address
#Define HEX_STYLE_NOINSDEL		&H1000			' Bytes can not be inserted or deleted

Type HEFONT
	hFont			As HFONT			        ' Hex edit normal
	hLnrFont	    As HFONT		        	' Line numbers
End Type

Type HECOLOR
	bckcol			As Integer	            	' Back color
	adrtxtcol		As Integer	            	' Address text color
	dtatxtcol		As Integer	            	' Data text color
	asctxtcol		As Integer	            	' ASCII text color
	selbckcol		As Integer	            	' Sel back color
	sellfbckcol		As Integer	            	' Sel lost focus back color
	seltxtcol		As Integer	            	' Sel text color
	selascbckcol	As Integer	            	' Sel back color
	selbarbck		As Integer	            	' Selection bar
	selbarpen		As Integer	            	' Selection bar pen
	lnrcol			As Integer	            	' Line numbers color
End Type

Type HESELCHANGE
	nmhdr			As NMHDR
	chrg			As CHARRANGE
	seltyp		    As Integer	            	' SEL_TEXT or SEL_OBJECT
	nline			As Integer	            	' Line number
	nlines		    As Integer	            	' Total number of lines
	fchanged		As Integer	            	' TRUE if changed since last
End Type

Type HEBMK
	hWin			As HWND		                ' Handle of window having the bookmark
	nLine			As Integer	                ' Bookmarked line
End Type

'IFDEF DLL
'	szRAHexEdClassName	db 'RAHEXEDIT',0
'	szHexChildClassName	db 'RAHEXEDITCHILD',0
'ELSE
'	szRAHexEdClassName	db 'MYRAHEXEDIT',0
'	szHexChildClassName	db 'MYRAHEXEDITCHILD',0
'ENDIF
