SaveUndo			PROTO	:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ScrollCaret			PROTO	:HWND
FindBookmark		PROTO	:DWORD,:DWORD

MAXCHARMEM			equ 128*1024
MAXSTREAM			equ 128*1024
MAXUNDOMEM			equ 32*1024

UNDO_CHARINSERT		equ 1
UNDO_CHAROVERWRITE	equ 2
UNDO_INSERTBLOCK	equ 3
UNDO_DELETEBLOCK	equ 4

SBWT				equ 16
BTNWT				equ 14
BTNHT				equ 6
SELWT				equ 14
LNRWT				equ 28
SPCWT				equ 3

HEUNDO struct
	rpPrev			dd ?		;Relative pointer to previous
	cp				dd ?		;Character position
	cb				dd ?		;Size in bytes
	fun				db ?		;Function
HEUNDO ends

TIMER struct
	hwnd			dd ?
	umsg			dd ?
	lparam			dd ?
	wparam			dd ?
TIMER ends

HEBRUSH struct
	hBrBck			dd ?		;Back color brush
	hBrSelBck		dd ?		;Selected focus back color brush
	hBrLfSelBck		dd ?		;Selected lost focus back color brush
	hBrAscSelBck	dd ?		;Selected lost focus back color brush
	hBrSelBar		dd ?		;Selection bar
	hPenSelbar		dd ?		;Selection bar pen
HEBRUSH ends

HEFONTINFO struct
	fntwt			dd ?		;Font width
	fntht			dd ?		;Font height
	linespace		dd ?		;Extra line spacing
HEFONTINFO ends

HEEDT struct
	hwnd			dd ?		;Handle of edit a or b
	hvscroll		dd ?		;Handle of scroll bar
	nline			dd ?		;Scroll position
	rc				RECT <?>	;Edit a or b rect
HEEDT ends

EDIT struct
	hwnd			dd ?		;Handle of main window
	fstyle			dd ?		;Window style
	ID				dd ?		;Window ID
	hpar			dd ?		;Handle of parent window
	edta			HEEDT <>
	edtb			HEEDT <>
	hhscroll		dd ?		;Handle of horizontal scrollbar
	hgrip			dd ?		;Handle of sizegrip
	hnogrip			dd ?		;Handle of nosizegrip
	hsbtn			dd ?		;Handle of splitt button
	hlin			dd ?		;Handle of linenumber button
	hsta			dd ?		;Handle of state window
	htt				dd ?		;Handle of tooltip
	fresize			dd ?		;Resize in action flag
	fsplitt			dd ?		;Splitt factor
	nsplitt			dd ?		;Splitt height

	hmem			dd ?
	nbytes			dd ?
	nsize			dd ?

	hundo			dd ?
	rpundo			dd ?
	cbundo			dd ?

	rc				RECT <?>	;Main rect
	selbarwt		dd ?		;Width of selection bar
	nlinenrwt		dd ?		;Initial width of linenumber bar
	linenrwt		dd ?		;Width of linenumber bar
	cpMin			dd ?		;Selection min
	cpMax			dd ?		;Selection max
	fOvr			dd ?		;Insert / Overwrite
	cpx				dd ?		;Scroll position
	focus			dd ?		;Handle of edit having focus
	fCaretHide		dd ?		;Caret is hidden
	fChanged		dd ?		;Content changed
	fHideSel		dd ?		;Hide selection
	clr				HECOLOR <?>
	br				HEBRUSH <?>
	fnt				HEFONT <?>
	fntinfo			HEFONTINFO <?>
	lpBmCB			dd ?		;Bookmark paint callback
	nchange			dd ?		;Used by EN_SELCHANGE
	nlastchange		dd ?		;Used by EN_SELCHANGE
	addrxp			dd ?
	addrwt			dd ?
	dataxp			dd ?
	datawt			dd ?
	asciixp			dd ?
	asciiwt			dd ?
	ofs				dd ?		;Offset
EDIT ends

IDB_RAHEXEDBUTTON	equ 100
IDC_HSPLITTCUR		equ 101
IDB_BOOKMARK		equ 102
IDC_SELECTCUR		equ 103
IDB_LINENUMBER		equ 104

.data

szScrollBar			db 'ScrollBar',0
szStatic			db 'Static',0
szButton			db 'Button',0
szToolTips			db 'Tooltips_class32',0

szToolTip			db 'RAHexEd control',0
szSplitterBar		db 'Splitter Bar',0
szLineNumber		db 'Show/Hide Linenumbers',0
szChanged			db 'Changed indicator',0
szX					db '0123456789ABCDEF',0

szMemFailChar		db 'Memory allocation failed! (Char)',0
szMemFailUndo		db 'Memory allocation failed! (Undo)',0
hex					dd 'A'-10

.data?

hInstance			dd ?
hBmpLnr				dd ?
hHSCur				dd ?
hSelCur				dd ?
hIml				dd ?
OldStateProc		dd ?
OldSplittBtnProc	dd ?
TimerID				dd ?
tmr1				TIMER <?>
tmr2				TIMER <?>
fSize				dd ?
fSelState			dd ?
icp					dd ?
charbuff			db 16384 dup(?)
