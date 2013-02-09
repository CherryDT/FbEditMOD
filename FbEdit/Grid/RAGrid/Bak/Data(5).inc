include windows.inc
include kernel32.inc
include user32.inc
include gdi32.inc
include Comctl32.inc

includelib kernel32.lib
includelib user32.lib
includelib gdi32.lib
includelib Comctl32.lib

;Debug
include masm32.inc
include \Programme\Radasm\masm\inc\Debug.Inc
includelib masm32.lib
includelib \Programme\Radasm\masm\lib\Debug.lib


IDB_RAGRIDBUTTON	equ 100
IDC_VSIZE			equ 102

;DLGC_CODE			equ DLGC_WANTARROWS or DLGC_WANTCHARS or DLGC_WANTALLKEYS
DLGC_CODE			equ DLGC_WANTCHARS or DLGC_WANTALLKEYS

;Grid structure
GRID struct
	col				dd ?			;Current column.
	row				dd ?			;Current row.
	cols			dd ?			;Number of columns.
	rows			dd ?			;Number of rows.
	hdrht			dd ?			;Header height.
	rowht			dd ?			;Row height.
	ccx				dd ?			;Sum of column widths.
	sbx				dd ?			;Horizontal scroll position.
	hpar			dd ?			;Handle of parent.
	hgrd			dd ?			;Handle of grid.
	nid				dd ?			;ID of grid.
	hhdr			dd ?			;Handle of header.
	hlst			dd ?			;Handle of grid listbox.
	hsize			dd ?			;Handle of sizeing bar.
	hfont			dd ?			;Handle of font
	style			dd ?			;Grid style.
	hcur			dd ?			;Handle of resize cursor
	colback			dd ?			;Back color
	colgrid			dd ?			;Grid color
	coltext			dd ?			;Text color
	hbrback			dd ?			;Back brush
	hpengrd			dd ?			;Grid pen
	hedt			dd ?			;Handle of current edit control
	edtrowcol		dd ?			;Row & Column of edit
	hmem			dd ?			;Handle of data memory.
	rpmemfree		dd ?			;Relative pointer to next free.
	memsize			dd ?			;Memory size.
	hstr			dd ?			;Handle of string memory.
	rpstrfree		dd ?			;Relative pointer to next free.
	strsize			dd ?			;Memory size.
	lpdata			dd ?			;Button cell data
	toprow			dd ?
	itemmemsize		dd ?
	rpitemdata		dd ?
GRID ends

STYLE				equ WS_CHILD or WS_VISIBLE or WS_TABSTOP or STYLE_HGRIDLINES or STYLE_VGRIDLINES or STYLE_NOSEL
EXSTYLE				equ WS_EX_CLIENTEDGE

;Used by RadASM 1.2.0.5
CCDEF struct
	ID				dd ?		;Controls uniqe ID
	lptooltip		dd ?		;Pointer to tooltip text
	hbmp			dd ?		;Handle of bitmap
	lpcaption		dd ?		;Pointer to default caption text
	lpname			dd ?		;Pointer to default id-name text
	lpclass			dd ?		;Pointer to class text
	style			dd ?		;Default style
	exstyle			dd ?		;Default ex-style
	flist1			dd ?		;Property listbox 1
	flist2			dd ?		;Property listbox 2
	disable			dd ?		;Disable controls child windows. 0=No, 1=Use method 1, 2=Use method 2
CCDEF ends

;Used by RadASM 2.1.0.4
CCDEFEX struct
	ID				dd ?		;Controls uniqe ID
	lptooltip		dd ?		;Pointer to tooltip text
	hbmp			dd ?		;Handle of bitmap
	lpcaption		dd ?		;Pointer to default caption text
	lpname			dd ?		;Pointer to default id-name text
	lpclass			dd ?		;Pointer to class text
	style			dd ?		;Default style
	exstyle			dd ?		;Default ex-style
	flist1			dd ?		;Property listbox 1
	flist2			dd ?		;Property listbox 2
	flist3			dd ?		;Property listbox 3
	flist4			dd ?		;Property listbox 4
	lpproperty		dd ?		;Pointer to properties text to add
	lpmethod		dd ?		;Pointer to property methods
CCDEFEX ends

PROP_STYLETRUEFALSE		equ 1
PROP_EXSTYLETRUEFALSE	equ 2
PROP_STYLEMULTI			equ 3

.const

szStaticClass		db 'Static',0
szListBoxClass		db 'ListBox',0
szRAListClass		db 'RAList',0
szRAComboClass		db 'RACombo',0
szEditClass			db 'Edit',0
szHotKeyClass		db 'msctls_hotkey32',0
szButtonClass		db 'Button',0
szDateTimeClass		db 'SysDateTimePick32',0

szToolTip			db 'RAGrid control',0
szCap				db 0
szName				db 'IDC_GRD',0

;Hotkey text
szCtrl				db 'Ctrl + ',0
szShift				db 'Shift + ',0
szAlt				db 'Alt + ',0

.data

szProperty			db 'GridLines,GridFrame,CellFocus,ShowSel,ColSize',0
PropertyGridLines	db 'None,Horizontal,Vertical,Both',0
					dd -1 xor (STYLE_HGRIDLINES or STYLE_VGRIDLINES),0
					dd -1,0
					dd -1 xor (STYLE_HGRIDLINES or STYLE_VGRIDLINES),STYLE_HGRIDLINES
					dd -1,0
					dd -1 xor (STYLE_HGRIDLINES or STYLE_VGRIDLINES),STYLE_VGRIDLINES
					dd -1,0
					dd -1 xor (STYLE_HGRIDLINES or STYLE_VGRIDLINES),STYLE_HGRIDLINES or STYLE_VGRIDLINES
					dd -1,0
PropertyGridFrame	dd -1 xor STYLE_GRIDFRAME,0
					dd -1 xor STYLE_GRIDFRAME,STYLE_GRIDFRAME
PropertyCellFocus	dd -1 xor STYLE_NOFOCUS,STYLE_NOFOCUS
					dd -1 xor STYLE_NOFOCUS,0
PropertyShowSel		dd -1 xor STYLE_NOSEL,STYLE_NOSEL
					dd -1 xor STYLE_NOSEL,0
PropertyColSize		dd -1 xor STYLE_NOCOLSIZE,STYLE_NOCOLSIZE
					dd -1 xor STYLE_NOCOLSIZE,0

Methods				dd PROP_STYLEMULTI,offset PropertyGridLines
					dd PROP_STYLETRUEFALSE,offset PropertyGridFrame
					dd PROP_STYLETRUEFALSE,offset PropertyCellFocus
					dd PROP_STYLETRUEFALSE,offset PropertyShowSel
					dd PROP_STYLETRUEFALSE,offset PropertyColSize

;Create an inited struct
ccdef				CCDEF <280,offset szToolTip,0,offset szCap,offset szName,offset szRAGridClass,WS_CHILD or WS_VISIBLE or WS_TABSTOP or STYLE_HGRIDLINES or STYLE_VGRIDLINES or STYLE_NOSEL,WS_EX_CLIENTEDGE,11111101000111100000000001000000b,00010000000000011000000000000000b,1>
ccdefex				CCDEFEX <280,offset szToolTip,0,offset szCap,offset szName,offset szRAGridClass,STYLE,EXSTYLE,11111101000111100000000001000000b,00010000000000011000000000000000b,00000000000000000000000000000000b,00000000000000000000000000000000b,offset szProperty,offset Methods>

.data?

hInstance			dd ?
iccex				INITCOMMONCONTROLSEX <?>
;Cancel edit update
fCancelEdit			dd ?
;Data used while resizing a column
fSize				dd ?
nSizeCol			dd ?
nSizeMin			dd ?
nSizeOfs			dd ?
lplstproc			dd ?
lpcboproc			dd ?
ncol				dd ?
nrow				dd ?
fsame				dd ?
fonbtn				dd ?
hfocus				dd ?
