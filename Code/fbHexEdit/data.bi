Declare Sub SaveUndo(a As DWORD, b As DWORD, c As DWORD, d As DWORD, e As DWORD)
Declare Sub ScrollCaret(a As HWND)
Declare Sub FindBookmark(a As DWORD, b As DWORD)


#Define MAXCHARMEM			128*1024
#Define MAXSTREAM				128*1024
#Define MAXUNDOMEM			32*1024

#Define UNDO_CHARINSERT				1
#Define UNDO_CHAROVERWRITE			2
#Define UNDO_INSERTBLOCK			3
#Define UNDO_DELETEBLOCK			4

#Define SBWT	16
#Define BTNWT	14
#Define BTNHT	6
#Define SELWT	14
#Define LNRWT	28
#Define SPCWT	3

Type HEUNDO
	rpPrev As Integer		' Relative pointer to previous
	cp As Integer			' position
	cb As Integer			' Size in bytes
	fun As Byte				' Function
End Type

Type Timer
	hwnd As Integer
	umsg As Integer
	lparam As Integer
	wparam As Integer
End Type

Type HEBRUSH
	hBrBck As Integer			' Back color brush
	hBrSelBck As Integer		' Selected focus back color brush
	hBrLfSelBck As Integer	' Selected lost focus back color brush
	hBrAscSelBck As Integer ' Selected lost focus back color brush
	hBrSelBar As Integer		' Selection bar
	hPenSelBar As Integer	' Selection bar Pen
End Type

Type HEFONTINFO
	fontwt As Integer			' Font width
	fontht As Integer			' Font height
	linespace As Integer		' Extra line spacing
End Type

Type HEEDT
	hwnd As Integer		' Handle of edit a or b
	hvscroll As Integer	' Handle of scroll bar
	nline As Integer		' Scroll position
	rc As RECT				' Edit a or b rect
End Type

Type EDIT
	hwnd As Integer		' Handle of main window
	fstyle As Integer		' Window style
	
End Type




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


#Define IDB_RAHEXEDBUTTON		100
#Define IDC_HSPLITTCUR			101
#Define IDB_BOOKMARK				102
#Define IDC_SELECTCUR			103
#Define IDB_LINENUMBER			104








