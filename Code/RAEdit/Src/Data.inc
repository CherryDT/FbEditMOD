
SaveUndo				PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
Expand					PROTO :DWORD,:DWORD
TestExpand				PROTO :DWORD,:DWORD
GetCharPtr				PROTO :DWORD,:DWORD
SelChange				PROTO :DWORD,:DWORD
GetYpFromLine			PROTO :DWORD,:DWORD
TestBlockEnd			PROTO :DWORD,:DWORD
PreviousBookMark		PROTO :DWORD,:DWORD,:DWORD
NextBookMark			PROTO :DWORD,:DWORD,:DWORD
GetBlock				PROTO :DWORD,:DWORD,:DWORD
TestBlockStart			PROTO :DWORD,:DWORD

MAXLINEMEM				equ 8*1024
MAXCHARMEM				equ 24*1024
;MAXCHARMEM				equ 32*1024
MAXUNDOMEM				equ 24*1024
MAXWORDMEM				equ 8*1024
;MAXFREE					equ 32
MAXFREE					equ 256
MAXSTREAM				equ 32*1024

BTNWT					equ 14
BTNHT					equ 6
SELWT					equ 26
LNRWT					equ 28

UNDO_INSERT				equ 1
UNDO_OVERWRITE			equ 2
UNDO_DELETE				equ 3
UNDO_BACKDELETE			equ 4
UNDO_INSERTBLOCK		equ 5
UNDO_DELETEBLOCK		equ 6

TIMER struct
	hwnd		dd ?
	umsg		dd ?
	lparam		dd ?
	wparam		dd ?
TIMER ends

RABRUSH struct
	hBrBck		dd ?		;Back color brush
	hBrSelBck	dd ?		;Sel back color brush
	hBrHilite1	dd ?		;Line hilite 1
	hBrHilite2	dd ?		;Line hilite 2
	hBrHilite3	dd ?		;Line hilite 3
	hBrSelBar	dd ?		;Selection bar
	hPenSelbar	dd ?		;Selection bar pen
RABRUSH ends

WORDINFO struct
	len			dd ?		;Length
	rpprev		dd ?		;Relative pointer to previous
	color		dd ?		;Color (high byte is font 0-3)
	fend		dd ?		;End flag
WORDINFO ends

RAFONTINFO struct
	charset		dd ?		;Character set
	fDBCS		dd ?		;Use double byte characters
	fntwt		dd ?		;Font width
	fntht		dd ?		;Font height
	spcwt		dd ?		;Space width
	tabwt		dd ?		;Tab width
	italic		dd ?		;Height shift
	monospace	dd ?		;Font is monospaced
	linespace	dd ?		;Extra line spacing
RAFONTINFO ends

LINE struct
	rpChars		dd ?		;Relative pointer to CHARS
LINE ends

CHARS struct
	len			dd ?		;Actual String len
	max			dd ?		;Max String len
	state		dd ?		;Line state
	bmid		dd ?		;Bookmark ID
	errid		dd ?		;Error ID
CHARS ends

RAUNDO struct
	rpPrev		dd ?		;Relative pointer to previous
	undoid		dd ?		;Undo ID
	cp			dd ?		;Character position
	cb			dd ?		;Size in bytes
	fun			db ?		;Function
RAUNDO ends

RAEDT struct
	hwnd		dd ?		;Handle of edit a or b
	hvscroll	dd ?		;Handle of scroll bar
	cpxmax		dd ?		;Last cursor pos x
	cpy			dd ?		;Scroll position
	cp			dd ?		;Character position
	rc			RECT <?>	;Edit a or b rect
	topyp		dd ?		;First visible lines Y position
	topln		dd ?		;First visible lines linenumber
	topcp		dd ?		;First visible lines character position
RAEDT ends

EDIT struct
	hwnd		dd ?		;Handle of main window
	fstyle		dd ?		;Window style
	ID			dd ?		;Window ID
	hpar		dd ?		;Handle of parent window
	edta		RAEDT <>
	edtb		RAEDT <>
	hhscroll	dd ?		;Handle of horizontal scrollbar
	hgrip		dd ?		;Handle of sizegrip
	hnogrip		dd ?		;Handle of nosizegrip
	hsbtn		dd ?		;Handle of splitt button
	hlin		dd ?		;Handle of linenumber button
	hexp		dd ?		;Handle of expand button
	hcol		dd ?		;Handle of collapse button
	hlock		dd ?		;Handle of lock button
	hsta		dd ?		;Handle of state window
	htt			dd ?		;Handle of tooltip
	fresize		dd ?		;Resize in action flag
	fsplitt		dd ?		;Splitt factor
	nsplitt		dd ?		;Splitt height

	hHeap		dd 3 dup(?)	;Handle of heap
	hLine		dd ?		;Handle of line pointer mem
	cbLine		dd ?		;Size of line pointer mem
	rpLine		dd ?		;Relative pointer into line pointer mem
	rpLineFree	dd ?		;Pointer to free line pointer
	hChars		dd ?		;Handle of character mem
	cbChars		dd ?		;Size of character mem
	rpChars		dd ?		;Relative pointer into character mem
	rpCharsFree	dd ?		;Relative pointer to free character
	hUndo		dd ?		;Handle of undo memory
	cbUndo		dd ?		;Size of undo memory
	rpUndo		dd ?		;Relative pointer to free (last)
	line		dd ?		;Linenumber
	cpLine		dd ?		;Character position for start of line

	rc			RECT <?>	;Main rect
	selbarwt	dd ?		;Width of selection bar
	nlinenrwt	dd ?		;Initial width of linenumber bar
	linenrwt	dd ?		;Width of linenumber bar
	nScroll		dd ?		;Mouse wheel scroll lines
	nPageBreak	dd ?		;Page break
	cpMin		dd ?		;Selection min
	cpMax		dd ?		;Selection max
	fOvr		dd ?		;Insert / Overwrite
	nHidden		dd ?		;Number of hidden lines
	cpx			dd ?		;Scroll position
	focus		dd ?		;Handle of edit having focus
	fCaretHide	dd ?		;Caret is hidden
	fChanged	dd ?		;Content changed
	fHideSel	dd ?		;Hide selection
	fIndent		dd ?		;Auto indent
	clr			RACOLOR <?>
	br			RABRUSH <?>
	nTab		dd ?		;Tab size
	fnt			RAFONT <?>
	fntinfo		RAFONTINFO <?>
	lpBmCB		dd ?		;Bookmark paint callback
	nchange		dd ?		;Used by EN_SELCHANGE
	nlastchange	dd ?		;Used by EN_SELCHANGE
	nWordGroup	dd ?		;Hilite word group
	fExpandTab	dd ?		;TRUE/FALSE Expand tabs to spaces
	savesel		CHARRANGE <?>
	htlt		dd ?		;Scroll tooltip
	nMode		dd ?		;Block selection
	blrg		BLOCKRANGE <?>
	lockundoid	dd ?
	ccmntblocks	dd ?
	cpbrst		dd ?
	cpbren		dd ?
	cpselbar	dd ?
	fLock		dd ?
	nCursorWordType	dd ?
	fstyleex	dd ?
	funicode	dd ?
	fhilite		dd ?
	lastline	dd ?
EDIT ends

IDB_RAEDITBUTTON		equ 100
IDC_HSPLITTCUR			equ 101
IDB_BOOKMARK			equ 102
IDC_SELECTCUR			equ 103
IDB_LINENUMBER			equ 104
IDB_EXPAND				equ 105
IDB_COLLAPSE			equ 106
IDB_LOCK				equ 107

.const

szScrollBar				db 'ScrollBar',0
szStatic				db 'Static',0
szButton				db 'Button',0
szToolTips				db 'Tooltips_class32',0

szToolTip				db 'RAEdit control',0
szSplitterBar			db 'Splitter Bar',0
szLineNumber			db 'Show/Hide Linenumbers',0
szExpand				db 'Expand all',0
szCollapse				db 'Collapse all',0
szLock					db 'Lock/Unlock Tab',0
szChanged				db 'Changed state',0

szX						db 'X',0
szW						db 'W',0
szI						db 'I',0
szSpace					db ' ',0
szTab					db VK_TAB,0
szComment				db 'comment +',0
szInclude				db 'include',0
szIncludelib			db 'includelib',0
szMemFailLine			db 'Memory allocation failed! (Line)',0
szMemFailChar			db 'Memory allocation failed! (Char)',0
szMemFailUndo			db 'Memory allocation failed! (Undo)',0
szMemFailSyntax			db 'Memory allocation failed! (Syntax)',0
szGlobalFail			db 'GlobalAlloc failed.',0
szHeapFail				db 'HeapAlloc failed.',0

.data

CharTabInit				db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;00
						db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;10
						;    ! " # $ % & ' ( ) * + , - . /
						db 0,2,5,3,2,2,2,5,2,2,2,2,2,2,3,2		;20
						;  0 1 2 3 4 5 6 7 8 9 : ; < = > ?
						db 1,1,1,1,1,1,1,1,1,1,2,4,2,2,2,3		;30
						;  @ A B C D E F G H I J K L M N O
						db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1		;40
						;  P Q R S T U V W X Y Z [ \ ] ^ _
						db 1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,1		;50
						;  ` a b c d e f g h i j k l m n o
						db 0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1		;60
						;  p q r s t u v w x y z { | } ~
						db 1,1,1,1,1,1,1,1,1,1,1,2,2,2,0,0		;70

						db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;80
						db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;90
						db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;A0
						db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;B0
						db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;C0
						db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;D0
						db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;E0
						db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;F0

CharTab					db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;00
						db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;10
						;    ! " # $ % & ' ( ) * + , - . /
						db 0,2,5,3,2,2,2,5,2,2,2,2,2,2,3,2		;20
						;  0 1 2 3 4 5 6 7 8 9 : ; < = > ?
						db 1,1,1,1,1,1,1,1,1,1,2,4,2,2,2,3		;30
						;  @ A B C D E F G H I J K L M N O
						db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1		;40
						;  P Q R S T U V W X Y Z [ \ ] ^ _
						db 1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,1		;50
						;  ` a b c d e f g h i j k l m n o
						db 0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1		;60
						;  p q r s t u v w x y z { | } ~
						db 1,1,1,1,1,1,1,1,1,1,1,2,2,2,0,0		;70

						db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;80
						db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;90
						db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;A0
						db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;B0
						db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;C0
						db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;D0
						db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;E0
						db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;F0

CaseTab					db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;00
						db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;10
						db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;20
						db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;30
						db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;40
						db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;50
						db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;60
						db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;70
						db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;80
						db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;90
						db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;A0
						db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;B0
						db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;C0
						db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;D0
						db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;E0
						db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;F0

szLine					db 'Line: ',16 dup(0)

.data?

hInstance				dd ?
hBmpLnr					dd ?
hBmpExp					dd ?
hBmpCol					dd ?
hBmpLck					dd ?
hHSCur					dd ?
hSelCur					dd ?
hIml					dd ?
hBrTlt					dd ?
SBWT					dd ?
OldStateProc			dd ?
OldSplittBtnProc		dd ?
OldFakeToolTipProc		dd ?
hWrdMem					dd ?
cbWrdMem				dd ?
rpWrdFree				dd ?
fSelState				dd ?
iYp						dd ?
fOnBM					dd ?
fOnSel					dd ?
nBmid					dd ?
nUndoid					dd ?
fSize					dd ?
TimerID					dd ?
tmr1					TIMER <?>
tmr2					TIMER <?>
ptDrag					POINT <?>
hDragWin				dd ?
hDragSourceMem			dd ?
cpDragSource			CHARRANGE <?>
peff					dd ?
MpX						dd ?
MpY						dd ?
fTlln					dd ?
blockdefs				db 4096 dup(?)
bracketstart			db 16 dup(?)
bracketend				db 16 dup(?)
bracketcont				db 16 dup(?)
fNoSaveUndo				dd ?
