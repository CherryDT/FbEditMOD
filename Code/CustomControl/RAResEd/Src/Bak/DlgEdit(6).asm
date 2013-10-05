SendToBack			PROTO	:DWORD
UpdateRAEdit		PROTO	:DWORD
CreateDlg			PROTO	:HWND
MakeDialog			PROTO	:DWORD,:DWORD
DlgEnumProc			PROTO	:DWORD,:DWORD

PGM_FIRST			equ 1400h
PGM_SETCHILD		equ PGM_FIRST+1
PGM_RECALCSIZE		equ PGM_FIRST+2
PGM_FORWARDMOUSE	equ PGM_FIRST+3
PGM_SETBKCOLOR		equ PGM_FIRST+4
PGM_GETBKCOLOR		equ PGM_FIRST+5
PGM_SETBORDER		equ PGM_FIRST+6
PGM_GETBORDER		equ PGM_FIRST+7
PGM_SETPOS			equ PGM_FIRST+8
PGM_GETPOS			equ PGM_FIRST+9
PGM_SETBUTTONSIZE	equ PGM_FIRST+10
PGM_GETBUTTONSIZE	equ PGM_FIRST+11
PGM_GETBUTTONSTATE	equ PGM_FIRST+12
PGM_GETDROPTARGET	equ CCM_GETDROPTARGET

ID_DIALOG			equ	65502

WS_ALWAYS			equ WS_CHILD or WS_VISIBLE or WS_CLIPSIBLINGS or WS_CLIPCHILDREN
MAXMULSEL			equ 256

MODE_NOTHING		equ 0
MODE_DRAWING		equ 1
MODE_MOVING			equ 2
MODE_SIZING			equ 3
MODE_MULTISEL		equ 4
MODE_MULTISELMOVE	equ 5
MODE_SELECT			equ 6
MODE_MOVINIT		equ 7
MODE_MULTISELMOVEINIT	equ 8

INIT_NPR			equ 32+32+8

.data

szPos				db 'Pos: ',32 dup(0)

DlgX				dd 10
DlgY				dd 10
szICODLG			db '#32106',0
DlgFN				db 'MS Sans Serif',0
DlgFS				dd 8

DlgID				db 'IDD_DLG',0
EdtID				db 'IDC_EDT',0
StcID				db 'IDC_STC',0
GrbID				db 'IDC_GRP',0
BtnID				db 'IDC_BTN',0
ChkID				db 'IDC_CHK',0
RbtID				db 'IDC_RBN',0
CboID				db 'IDC_CBO',0
LstID				db 'IDC_LST',0
ScbID				db 'IDC_SCB',0
TabID				db 'IDC_TAB',0
PrbID				db 'IDC_PGB',0
TrvID				db 'IDC_TRV',0
LsvID				db 'IDC_LSV',0
TrbID				db 'IDC_TRB',0
UdnID				db 'IDC_UDN',0
IcoID				db 'IDC_IMG',0
TbrID				db 'IDC_TBR',0
SbrID				db 'IDC_SBR',0
DtpID				db 'IDC_DTP',0
MviID				db 'IDC_MVI',0
RedID				db 'IDC_RED',0
UdcID				db 'IDC_UDC',0
CbeID				db 'IDC_CBE',0
ShpID				db 'IDC_SHP',0
IpaID				db 'IDC_IPA',0
AniID				db 'IDC_ANI',0
HotID				db 'IDC_HOT',0
PgrID				db 'IDC_PGR',0
RebID				db 'IDC_REB',0
HdrID				db 'IDC_HDR',0
LnkID				db 'IDC_LNK',0

LnkCAP				db '<a></a>',0

szMnu				db '  &File  ,	&Edit  ,  &Help  ',0
nPr					dd INIT_NPR
PrAll				db '(Name),(ID),Left,Top,Width,Height,Caption,Border,SysMenu,MaxButton,MinButton,Enabled,Visible,Clipping,ScrollBar,Default,Auto,Alignment,Mnemonic,WordWrap,MultiLine,Type,Locked,Child,SizeBorder,TabStop,Font,Menu,Class,Notify,AutoScroll,WantCr,'
					db 'Sort,Flat,(StartID),TabIndex,Format,SizeGrip,Group,Icon,UseTabs,StartupPos,Orientation,SetBuddy,MultiSelect,HideSel,TopMost,xExStyle,xStyle,IntegralHgt,Image,Buttons,PopUp,OwnerDraw,Transp,Timer,AutoPlay,WeekNum,AviClip,AutoSize,ToolTip,Wrap,'
					db 'Divider,DragDrop,'
					db 'Smooth,Ellipsis,Language,HasStrings,(HelpID),File,MenuEx,SaveSel'
PrCust				db 512 dup(0)

				;0-Dialog
ctltypes			dd 0
;					dd offset szDlgChildClass
					dd offset szNULL
					dd 0	;Keep size
					dd WS_VISIBLE or WS_CAPTION or WS_MAXIMIZEBOX or WS_MINIMIZEBOX or WS_SYSMENU or WS_SIZEBOX
					dd 0C00000h	;Typemask
					dd 0	;ExStyle
					dd offset DlgID
					dd offset DlgID
					dd offset szDIALOGEX
					dd 200	;xsize
					dd 300	;ysize
					dd 0	;nmethod
					dd 0	;methods
					dd 11111111111111100000000110111000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00100000010000111000100000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00101000000000000000000000000000b
					;  SELHHFMS
					dd 00000000000000000000000000000000b
					;
				;1-Edit
					dd 1
					dd offset szEditClass
					dd 0	;Keep size
					dd WS_VISIBLE or WS_CHILD or WS_TABSTOP or ES_LEFT
					dd 0	;Typemask
					dd WS_EX_CLIENTEDGE
					dd offset EdtID
					dd offset szNULL
					dd offset szCONTROL
					dd 82	;xsize
					dd 22	;ysize
					dd 0	;nmethod
					dd 0	;methods
					dd 11111111000111100100111001000011b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000001011000000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00001000000000000000000000000000b
					;  SELHHFMS
					dd 00000000000000000000000000000000b
					;
				;2-Static
					dd 2
					dd offset szStaticClass
					dd 0	;Keep size
					dd WS_VISIBLE or WS_CHILD or SS_LEFT
					dd SS_TYPEMASK	;Typemask
					dd 0	;ExStyle
					dd offset StcID
					dd offset StcID
					dd offset szCONTROL
					dd 82	;xsize
					dd 16	;ysize
					dd 0	;nmethod
					dd 0	;methods
					dd 11111111000111000111000000000100b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000000011000000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 01001000000000000000000000000000b
					;  SELHHFMS
					dd 00000000000000000000000000000000b
					;
				;3-GroupBox
					dd 3
					dd offset szButtonClass
					dd 0	;Keep size
					dd WS_VISIBLE or WS_CHILD or BS_GROUPBOX
					dd 0Fh	;Typemask
					dd 0	;ExStyle
					dd offset GrbID
					dd offset GrbID
					dd offset szCONTROL
					dd 82	;xsize
					dd 82	;ysize
					dd 0	;nmethod
					dd 0	;methods
					dd 11111111000111000000000000000000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000000011000000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00001000000000000000000000000000b
					;  SELHHFMS
					dd 00000000000000000000000000000000b
					;
				;4-Pushbutton
					dd 4
					dd offset szButtonClass
					dd 0	;Keep size
					dd WS_VISIBLE or WS_CHILD or WS_TABSTOP or BS_PUSHBUTTON
					dd 0Fh	;Typemask
					dd 0	;ExStyle
					dd offset BtnID
					dd offset BtnID
					dd offset szCONTROL
					dd 82	;xsize
					dd 22	;ysize
					dd 0	;nmethod
					dd 0	;methods
					dd 11111111000111010100110001000100b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000000011000000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00001000000000000000000000000000b
					;  SELHHFMS
					dd 00000000000000000000000000000000b
					;
				;5-CheckBox
					dd 5
					dd offset szButtonClass
					dd 0	;Keep size
					dd WS_VISIBLE or WS_CHILD or WS_TABSTOP or BS_AUTOCHECKBOX
					dd 0Fh	;Typemask
					dd 0	;ExStyle
					dd offset ChkID
					dd offset ChkID
					dd offset szCONTROL
					dd 82	;xsize
					dd 16	;ysize
					dd 0	;nmethod
					dd 0	;methods
					dd 11111110000111001100100001000100b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010010000000011000000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00001000000000000000000000000000b
					;  SELHHFMS
					dd 00000000000000000000000000000000b
					;
				;6-RadioButton
					dd 6
					dd offset szButtonClass
					dd 0	;Keep size
					dd WS_VISIBLE or WS_CHILD or WS_TABSTOP or BS_AUTORADIOBUTTON
					dd 0Fh	;Typemask
					dd 0	;ExStyle
					dd offset RbtID
					dd offset RbtID
					dd offset szCONTROL
					dd 82	;xsize
					dd 16	;ysize
					dd 0	;nmethod
					dd 0	;methods
					dd 11111110000111001100100001000100b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010010000000011000000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00001000000000000000000000000000b
					;  SELHHFMS
					dd 00000000000000000000000000000000b
					;
				;7-ComboBox
					dd 7
					dd offset szComboBoxClass
					dd 1	;Keep size
					dd WS_VISIBLE or WS_CHILD or WS_TABSTOP or CBS_DROPDOWNLIST
					dd 03h	;Typemask
					dd 0	;ExStyle
					dd offset CboID
					dd offset szNULL
					dd offset szCONTROL
					dd 82	;xsize
					dd 82	;ysize
					dd 0	;nmethod
					dd 0	;methods
					dd 11111100000111100000010001000010b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 10010000000000011100010000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00011000000000000000000000000000b
					;  SELHHFMS
					dd 00000000000000000000000000000000b
					;
				;8-ListBox
					dd 8
					dd offset szListBoxClass
					dd 1	;Keep size
					dd WS_VISIBLE or WS_CHILD or WS_TABSTOP or LBS_HASSTRINGS or LBS_NOINTEGRALHEIGHT or LBS_NOTIFY
					dd 0	;Typemask
					dd WS_EX_CLIENTEDGE
					dd offset LstID
					dd offset szNULL
					dd offset szCONTROL
					dd 82	;xsize
					dd 82	;ysize
					dd 0	;nmethod
					dd 0	;methods
					dd 11111101000111100000000001000100b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 10010000100010011100010000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00011000000000000000000000000000b
					;  SELHHFMS
					dd 00000000000000000000000000000000b
					;
				;9-HScrollBar
					dd 9
					dd offset szScrollBarClass
					dd 0	;Keep size
					dd WS_VISIBLE or WS_CHILD or SBS_HORZ
					dd 0	;Typemask
					dd 0	;ExStyle
					dd offset ScbID
					dd offset szNULL
					dd offset szCONTROL
					dd 82	;xsize
					dd 16	;ysize
					dd 0	;nmethod
					dd 0	;methods
					dd 11111100000111000000000001000000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000000011000000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00001000000000000000000000000000b
					;  SELHHFMS
					dd 00000000000000000000000000000000b
					;
				;10-VScrollBar
					dd 10
					dd offset szScrollBarClass
					dd 0	;Keep size
					dd WS_VISIBLE or WS_CHILD or SBS_VERT
					dd 0	;Typemask
					dd 0	;ExStyle
					dd offset ScbID
					dd offset szNULL
					dd offset szCONTROL
					dd 16	;xsize
					dd 82	;ysize
					dd 0	;nmethod
					dd 0	;methods
					dd 11111100000111000000000001000000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000000011000000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00001000000000000000000000000000b
					;  SELHHFMS
					dd 00000000000000000000000000000000b
					;
				;11-TabControl
					dd 11
					dd offset szTabControlClass
					dd 0	;Keep size
					dd WS_VISIBLE or WS_CHILD or WS_TABSTOP or TCS_FOCUSNEVER
					dd 0	;Typemask
					dd 0	;ExStyle
					dd offset TabID
					dd offset szNULL
					dd offset szCONTROL
					dd 150	;xsize
					dd 82	;ysize
					dd 0	;nmethod
					dd 0	;methods
					dd 11111100000111000100100001000000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000000011001000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00001000000000000000000000000000b
					;  SELHHFMS
					dd 00000000000000000000000000000000b
					;
				;12-ProgressBar
					dd 12
					dd offset szProgressBarClass
					dd 0	;Keep size
					dd WS_VISIBLE or WS_CHILD
					dd 0	;Typemask
					dd 0	;ExStyle
					dd offset PrbID
					dd offset szNULL
					dd offset szCONTROL
					dd 82	;xsize
					dd 16	;ysize
					dd 0	;nmethod
					dd 0	;methods
					dd 11111100000111000000000000000000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000001000011000000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 10001000000000000000000000000000b
					;  SELHHFMS
					dd 00000000000000000000000000000000b
					;
				;13-TreeView
					dd 13
					dd offset szTreeViewClass
					dd 0	;Keep size
					dd WS_VISIBLE or WS_CHILD or WS_TABSTOP or TVS_HASLINES or TVS_LINESATROOT or TVS_HASBUTTONS
					dd 0	;Typemask
					dd WS_EX_CLIENTEDGE
					dd offset TrvID
					dd offset szNULL
					dd offset szCONTROL
					dd 82	;xsize
					dd 82	;ysize
					dd 0	;nmethod
					dd 0	;methods
					dd 11111101000111000000010001000000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000001011001000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00001000000000000000000000000000b
					;  SELHHFMS
					dd 00000000000000000000000000000000b
					;
				;14-ListViev
					dd 14
					dd offset szListViewClass
					dd 0	;Keep size
					dd WS_VISIBLE or WS_CHILD or WS_TABSTOP or LVS_LIST
					dd LVS_TYPEMASK	;Typemask
					dd WS_EX_CLIENTEDGE
					dd offset LsvID
					dd offset szNULL
					dd offset szCONTROL
					dd 82	;xsize
					dd 82	;ysize
					dd 0	;nmethod
					dd 0	;methods
					dd 11111101000111000100010001000000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 10010000000001011000010000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00001000000000000000000000000000b
					;  SELHHFMS
					dd 00000000000000000000000000000000b
					;
				;15-TrackBar
					dd 15
					dd offset szTrackBarClass
					dd 0	;Keep size
					dd WS_VISIBLE or WS_CHILD
					dd 0	;Typemask
					dd 0	;ExStyle
					dd offset TrbID
					dd offset szNULL
					dd offset szCONTROL
					dd 82	;xsize
					dd 22	;ysize
					dd 0	;nmethod
					dd 0	;methods
					dd 11111100000111000000000001000000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000000011000000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00001000000000000000000000000000b
					;  SELHHFMS
					dd 00000000000000000000000000000000b
					;
				;16-UpDown
					dd 16
					dd offset szUpDownClass
					dd 0	;Keep size
					dd WS_VISIBLE or WS_CHILD
					dd 0	;Typemask
					dd 0	;ExStyle
					dd offset UdnID
					dd offset szNULL
					dd offset szCONTROL
					dd 16	;xsize
					dd 19	;ysize
					dd 0	;nmethod
					dd 0	;methods
					dd 11111100000111001100000001000000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000001100011000000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00001000000000000000000000000000b
					;  SELHHFMS
					dd 00000000000000000000000000000000b
					;
				;17-Image
					dd 17
					dd offset szStaticClass
					dd 0	;Keep size
					dd WS_VISIBLE or WS_CHILD or SS_ICON or SS_CENTERIMAGE
					dd SS_TYPEMASK	;Typemask
					dd 0	;ExStyle
					dd offset IcoID
					dd offset szNULL
					dd offset szCONTROL
					dd 31	;xsize
					dd 31	;ysize
					dd 0	;nmethod
					dd 0	;methods
					dd 11111101000111000100010000000100b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000000011010000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00001000000000000000000000000000b
					;  SELHHFMS
					dd 00000000000000000000000000000000b
					;
				;18-ToolBar
					dd 18
					dd offset szToolBarClass
					dd 0	;Keep size
					dd WS_VISIBLE or WS_CHILD or CCS_TOP
					dd 0	;Typemask
					dd 0	;ExStyle
					dd offset TbrID
					dd offset szNULL
					dd offset szCONTROL
					dd 82	;xsize
					dd 22	;ysize
					dd 0	;nmethod
					dd 0	;methods
					dd 11111100000111000100000000000000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 01010000000000011000000000011110b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00001000000000000000000000000000b
					;  SELHHFMS
					dd 00000000000000000000000000000000b
					;
				;19-StatusBar
					dd 19
					dd offset szStatusBarClass
					dd 0	;Keep size
					dd WS_VISIBLE or WS_CHILD or CCS_BOTTOM
					dd 0	;Typemask
					dd 0	;ExStyle
					dd offset SbrID
					dd offset SbrID
					dd offset szCONTROL
					dd 82	;xsize
					dd 22	;ysize
					dd 0	;nmethod
					dd 0	;methods
					dd 11000010000111000100000000000000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010100000000011000000000011000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00001000000000000000000000000000b
					;  SELHHFMS
					dd 00000000000000000000000000000000b
					;
				;20-DateTimePicker
					dd 20
					dd offset szDateTimeClass
					dd 0	;Keep size
					dd WS_VISIBLE or WS_CHILD or WS_TABSTOP or 4
					dd 0	;Typemask
					dd 0	;ExStyle
					dd offset DtpID
					dd offset szNULL
					dd offset szCONTROL
					dd 82	;xsize
					dd 22	;ysize
					dd 0	;nmethod
					dd 0	;methods
					dd 11111100000111000000010001000000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00011000000000011000000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00001000000000000000000000000000b
					;  SELHHFMS
					dd 00000000000000000000000000000000b
					;
				;21-MonthView
					dd 21
					dd offset szMonthViewClass
					dd 0	;Keep size
					dd WS_VISIBLE or WS_CHILD
					dd 0	;Typemask
					dd WS_EX_CLIENTEDGE	;ExStyle
					dd offset MviID
					dd offset szNULL
					dd offset szCONTROL
					dd 82	;xsize
					dd 82	;ysize
					dd 0	;nmethod
					dd 0	;methods
					dd 11111101000111000000000001000000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000010011000000001000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00001000000000000000000000000000b
					;  SELHHFMS
					dd 00000000000000000000000000000000b
					;
				;22-RichEdit
					dd 22
					dd offset szRichEditClass
					dd 0	;Keep size
					dd WS_VISIBLE or WS_CHILD or WS_TABSTOP
					dd 0	;Typemask
					dd WS_EX_CLIENTEDGE	;ExStyle
					dd offset RedID
					dd offset RedID
					dd offset szCONTROL
					dd 82	;xsize
					dd 82	;ysize
					dd 0	;nmethod
					dd 0	;methods
					dd 11111111000111100000101001000011b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000001011000000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00001001000000000000000000000000b
					;  SELHHFMS
					dd 00000000000000000000000000000000b
					;
				;23-UserDefinedControl
					dd 23
					dd offset szStaticClass
					dd 0	;Keep size
					dd WS_VISIBLE or WS_CHILD
					dd 0	;Typemask
					dd 0	;ExStyle
					dd offset UdcID
					dd offset UdcID
					dd offset szCONTROL
					dd 82	;xsize
					dd 82	;ysize
					dd 0	;nmethod
					dd 0	;methods
					dd 11111111000101100000000001001000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000000011000000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00001000000000000000000000000000b
					;  SELHHFMS
					dd 00000000000000000000000000000000b
					;
				;24-ComboBoxEx
					dd 24
					dd offset szComboBoxExClass
					dd 1	;Keep size
					dd WS_VISIBLE or WS_CHILD or WS_TABSTOP or CBS_DROPDOWNLIST
					dd 03h	;Typemask
					dd 0	;ExStyle
					dd offset CbeID
					dd offset szNULL
					dd offset szCONTROL
					dd 82	;xsize
					dd 82	;ysize
					dd 0	;nmethod
					dd 0	;methods
					dd 11111100000111000000010001000000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000000011000000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00001000000000000000000000000000b
					;  SELHHFMS
					dd 00000000000000000000000000000000b
					;
				;25-Static Rect & Line
					dd 25
					dd offset szStaticClass
					dd 0	;Keep size
					dd WS_VISIBLE or WS_CHILD or SS_BLACKRECT
					dd SS_TYPEMASK	;Typemask
					dd 0	;ExStyle
					dd offset ShpID
					dd offset szNULL
					dd offset szCONTROL
					dd 22	;xsize
					dd 22	;ysize
					dd 0	;nmethod
					dd 0	;methods
					dd 11111101000111000000010000000100b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000000011000000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00001000000000000000000000000000b
					;  SELHHFMS
					dd 00000000000000000000000000000000b
					;
				;26-IP Address
					dd 26
					dd offset szIPAddressClass
					dd 0	;Keep size
					dd WS_VISIBLE or WS_CHILD or WS_TABSTOP
					dd 0	;Typemask
					dd 0	;ExStyle
					dd offset IpaID
					dd offset szNULL
					dd offset szCONTROL
					dd 82	;xsize
					dd 22	;ysize
					dd 0	;nmethod
					dd 0	;methods
					dd 11111101000111000000000001000000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000000011000000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00001000000000000000000000000000b
					;  SELHHFMS
					dd 00000000000000000000000000000000b
					;
				;27-Animate
					dd 27
					dd offset szAnimateClass
					dd 0	;Keep size
					dd WS_VISIBLE or WS_CHILD
					dd 0	;Typemask
					dd 0	;ExStyle
					dd offset AniID
					dd offset szNULL
					dd offset szCONTROL
					dd 22	;xsize
					dd 22	;ysize
					dd 0	;nmethod
					dd 0	;methods
					dd 11111101000111000100000000000000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000000011000001110100000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00001000000000000000000000000000b
					;  SELHHFMS
					dd 00000000000000000000000000000000b
					;
				;28-HotKey
					dd 28
					dd offset szHotKeyClass
					dd 0	;Keep size
					dd WS_VISIBLE or WS_CHILD or WS_TABSTOP
					dd 0	;Typemask
					dd 0	;ExStyle
					dd offset HotID
					dd offset szNULL
					dd offset szCONTROL
					dd 82	;xsize
					dd 22	;ysize
					dd 0	;nmethod
					dd 0	;methods
					dd 11111101000111000000000001000000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000000011000000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00001000000000000000000000000000b
					;  SELHHFMS
					dd 00000000000000000000000000000000b
					;
				;29-HPager
					dd 29
					dd offset szPagerClass
					dd 0	;Keep size
					dd WS_VISIBLE or WS_CHILD or PGS_HORZ
					dd 0	;Typemask
					dd 0	;ExStyle
					dd offset PgrID
					dd offset szNULL
					dd offset szCONTROL
					dd 82	;xsize
					dd 22	;ysize
					dd 0	;nmethod
					dd 0	;methods
					dd 11111101000111000000000001000000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000000011000000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00001000000000000000000000000000b
					;  SELHHFMS
					dd 00000000000000000000000000000000b
					;
				;30-VPager
					dd 30
					dd offset szPagerClass
					dd 0	;Keep size
					dd WS_VISIBLE or WS_CHILD or PGS_VERT
					dd 0	;Typemask
					dd 0	;ExStyle
					dd offset PgrID
					dd offset szNULL
					dd offset szCONTROL
					dd 22	;xsize
					dd 82	;ysize
					dd 0	;nmethod
					dd 0	;methods
					dd 11111101000111000000000001000000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000000011000000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00001000000000000000000000000000b
					;  SELHHFMS
					dd 00000000000000000000000000000000b
					;
				;31-ReBar
					dd 31
					dd offset szReBarClass
					dd 0	;Keep size
					dd WS_VISIBLE or WS_CHILD
					dd 0	;Typemask
					dd 0	;ExStyle
					dd offset RebID
					dd offset szNULL
					dd offset szCONTROL
					dd 82	;xsize
					dd 22	;ysize
					dd 0	;nmethod
					dd 0	;methods
					dd 11111101000111000000000001000000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000000011000000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00001000000000000000000000000000b
					;  SELHHFMS
					dd 00000000000000000000000000000000b
					;
				;32-Header
					dd 32
					dd offset szHeaderClass
					dd 0	;Keep size
					dd WS_VISIBLE or WS_CHILD or HDS_BUTTONS
					dd 0	;Typemask
					dd 0	;ExStyle
					dd offset HdrID
					dd offset szNULL
					dd offset szCONTROL
					dd 82	;xsize
					dd 19	;ysize
					dd 0	;nMethod
					dd 0	;Methods
					dd 11111101000111000000000000000000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000000011001000000000001b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00001000000000000000000000000000b
					;  SELHHFMS
					dd 00000000000000000000000000000000b
					;  
				;33-SysLink
					dd 33
					dd offset szSysLinkClass
					dd 0	;Keep size
					dd WS_VISIBLE or WS_CHILD or LWS_TRANSPARENT
					dd 0	;Typemask
					dd 0	;ExStyle
					dd offset LnkID
					dd offset LnkCAP
					dd offset szCONTROL
					dd 82	;xsize
					dd 19	;ysize
					dd 0	;nMethod
					dd 0	;Methods
					dd 11111111000111000000000001000000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000000011000000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00001000000000000000000000000000b
					;  SELHHFMS
					dd 00000000000000000000000000000000b
					;  
custtypes			TYPES 32 dup(<?>)

dwNOTStyle			dd WS_VISIBLE

					align 4
dlgdata				dd WS_CAPTION or DS_SETFONT						;style
					dd 00000000h									;exstyle
					dw 0000h										;cdit
					dw 4096											;x
					dw 3072											;y
					dw 0060h										;cx
					dw 0040h										;cy
					dw 0000h										;menu
					dw 0000h										;class
					dw 0000h										;caption
dlgps				dw 0											;point size
dlgfn				dw 33 dup(0)									;face name

.data?

fGrid				dd ?
fRSnapToGrid		dd ?
fSnapToGrid			dd ?
fShowSizePos		dd ?
fStyleHex			dd ?
fSizeToFont			dd ?
fNoDefines			dd ?
fSimpleProperty		dd ?
fNoResetToolbox		dd ?
hSizeing			dd 8 dup(?)
hMultiSel			dd ?

hReSize				dd ?
OldPt				POINT <?>
MousePtDown			POINT <?>
OldSizeingProc		dd ?
dlgpaste			DIALOG MAXMULSEL dup(<?>)
SizeRect			RECT <?>
;Dialog menu
MnuInx				dd ?

hWinBmp				HBITMAP ?
dfntwt				dd ?
dfntht				dd ?
fntwt				dd ?
fntht				dd ?

mpt					POINT <?>

.code

CaptureWin proc
	LOCAL	rect:RECT
	LOCAL	hDC:HDC
	LOCAL	hMemDC:HDC

	invoke GetDC,hInvisible
	mov		hDC,eax
	invoke GetClientRect,hDEd,addr rect
	invoke GetWindowLong,hDEd,DEWM_SCROLLX
	shl		eax,3
	mov		rect.left,eax
	invoke GetWindowLong,hDEd,DEWM_SCROLLY
	shl		eax,3
	mov		rect.top,eax
	invoke CreateCompatibleDC,hDC
	mov		hMemDC,eax
	invoke CreateCompatibleBitmap,hDC,rect.right,rect.bottom
	mov		hWinBmp,eax
	invoke SelectObject,hMemDC,hWinBmp
	push	eax
	invoke BitBlt,hMemDC,0,0,rect.right,rect.bottom,hDC,rect.left,rect.top,SRCCOPY
	pop		eax
	invoke SelectObject,hMemDC,eax
	invoke DeleteDC,hMemDC
	invoke ReleaseDC,hInvisible,hDC
	ret

CaptureWin endp

RestoreWin proc
	LOCAL	rect:RECT
	LOCAL	hDC:HDC
	LOCAL	hMemDC:HDC

	invoke GetDC,hInvisible
	mov		hDC,eax
	invoke GetClientRect,hDEd,addr rect
	invoke GetWindowLong,hDEd,DEWM_SCROLLX
	shl		eax,3
	mov		rect.left,eax
	add		rect.right,eax
	invoke GetWindowLong,hDEd,DEWM_SCROLLY
	shl		eax,3
	mov		rect.top,eax
	add		rect.bottom,eax
	invoke CreateCompatibleDC,hDC
	mov		hMemDC,eax
	invoke SelectObject,hMemDC,hWinBmp
	push	eax
	invoke BitBlt,hDC,rect.left,rect.top,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY
	pop		eax
	invoke SelectObject,hMemDC,eax
	invoke DeleteDC,hMemDC
	invoke ReleaseDC,hInvisible,hDC
	ret

RestoreWin endp

GetFreeDlg proc hDlgMem:DWORD

	mov		eax,hDlgMem
	add		eax,sizeof DLGHEAD
	sub		eax,sizeof DIALOG
  @@:
	add		eax,sizeof DIALOG
	cmp		[eax].DIALOG.hwnd,0
	jne		@b
	ret

GetFreeDlg endp

GetFreeID proc uses esi edi

	invoke GetWindowLong,hDEd,DEWM_MEMORY
	.if eax
		mov		esi,eax
		mov		eax,[esi].DLGHEAD.ctlid
		add		esi,sizeof DLGHEAD
		sub		esi,sizeof DIALOG
		mov		edi,esi
	  @@:
		add		esi,sizeof DIALOG
		cmp		[esi].DIALOG.hwnd,0
		je		@f
		cmp		[esi].DIALOG.hwnd,-1
		je		@b
		cmp		eax,[esi].DIALOG.id
		jne		@b
		mov		esi,edi
		inc		eax
		jmp		@b
	  @@:
	.endif
	ret

GetFreeID endp

IsFreeID proc uses esi,nID:DWORD

	invoke GetWindowLong,hDEd,DEWM_MEMORY
	.if eax
		mov		esi,eax
		add		esi,sizeof DLGHEAD
		sub		esi,sizeof DIALOG
		mov		eax,nID
	  @@:
		add		esi,sizeof DIALOG
		cmp		[esi].DIALOG.hwnd,0
		je		@f
		cmp		[esi].DIALOG.hwnd,-1
		je		@b
		cmp		eax,[esi].DIALOG.id
		jne		@b
		mov		eax,0
	  @@:
	.endif
	.if eax
		;ID is free
		mov		eax,TRUE
	.else
		mov		eax,FALSE
	.endif
	ret

IsFreeID endp

GetFreeTab proc uses esi edi
	LOCAL	nTab:DWORD

	invoke GetWindowLong,hDEd,DEWM_MEMORY
	.if eax
		mov		esi,eax
		add		esi,sizeof DLGHEAD
		mov		edi,esi
		mov		nTab,0
	  @@:
		add		esi,sizeof DIALOG
		cmp		[esi].DIALOG.hwnd,0
		je		@f
		cmp		[esi].DIALOG.hwnd,-1
		je		@b
		mov		eax,nTab
		cmp		eax,[esi].DIALOG.tab
		jne		@b
		mov		esi,edi
		inc		nTab
		jmp		@b
	  @@:
		mov		eax,nTab
	.endif
	ret

GetFreeTab endp

;0 1 2 3 4 5 6 7
;0 1 2 5 3 4 6 7
;if new>old
;	if t>old and t<=new then t=t-1
;0 1 2 3 4 5 6 7
;0 2 3 1 4 5 6 7
;if new<old
;	if t<old and t>=new then t=t+1
SetNewTab proc uses esi edi,hCtl:HWND,nTab:DWORD
	LOCAL	nOld:DWORD

	invoke GetCtrlMem,hCtl
	.if eax
		mov		esi,eax
		invoke GetFreeTab
		.if eax<=nTab
			.if eax
				dec		eax
			.endif
			mov		nTab,eax
		.endif
		mov		eax,[esi].DIALOG.tab
		mov		nOld,eax
		mov		edi,esi
		invoke GetWindowLong,hDEd,DEWM_MEMORY
		.if eax
			mov		esi,eax
			add		esi,sizeof DLGHEAD
		  @@:
			add		esi,sizeof DIALOG
			cmp		[esi].DIALOG.hwnd,0
			je		@f
			cmp		[esi].DIALOG.hwnd,-1
			je		@b
			mov		eax,nTab
			.if eax>nOld
				mov		eax,[esi].DIALOG.tab
				.if eax>nOld && eax<=nTab
					dec		[esi].DIALOG.tab
				.endif
			.else
				mov		eax,[esi].DIALOG.tab
				.if eax<nOld && eax>=nTab
					inc		[esi].DIALOG.tab
				.endif
			.endif
			jmp		@b
		  @@:
			mov		eax,nTab
			mov		[edi].DIALOG.tab,eax
		.endif
	.endif
	ret

SetNewTab endp

InsertTab proc uses esi,nTab:DWORD

	invoke GetWindowLong,hDEd,DEWM_MEMORY
	.if eax
		mov		esi,eax
		add		esi,sizeof DLGHEAD
	  @@:
		add		esi,sizeof DIALOG
		cmp		[esi].DIALOG.hwnd,0
		je		@f
		cmp		[esi].DIALOG.hwnd,-1
		je		@b
		mov		eax,nTab
		.if eax<=[esi].DIALOG.tab
			inc		[esi].DIALOG.tab
		.endif
		jmp		@b
	  @@:
	.endif
	ret

InsertTab endp

DeleteTab proc uses esi,nTab:DWORD

	invoke GetWindowLong,hDEd,DEWM_MEMORY
	.if eax
		lea		esi,[eax+sizeof DLGHEAD]
	  @@:
		lea		esi,[esi+sizeof DIALOG]
		cmp		[esi].DIALOG.hwnd,0
		je		@f
		cmp		[esi].DIALOG.hwnd,-1
		je		@b
		mov		eax,nTab
		.if eax<[esi].DIALOG.tab
			dec		[esi].DIALOG.tab
		.endif
		jmp		@b
	  @@:
	.endif
	ret

DeleteTab endp

SetChanged proc fChanged:DWORD

	invoke GetWindowLong,hDEd,DEWM_PROJECT
	.if eax
		mov		edx,fChanged
		mov		[eax].PROJECT.changed,edx
	.endif
	invoke NotifyParent
	ret

SetChanged endp

DestroySizeingRect proc uses edi
	LOCAL	rect:RECT

	mov		edi,offset hSizeing
	mov		ecx,8
  @@:
	mov		edx,[edi]
	.if edx
		push	ecx
		push	edx
		invoke GetWindowRect,edx,addr rect
		invoke ScreenToClient,hDEd,addr rect.left
		invoke ScreenToClient,hDEd,addr rect.right
		invoke InvalidateRect,hDEd,addr rect,TRUE
		pop		edx
		invoke DestroyWindow,edx
		pop		ecx
	.endif
	xor		eax,eax
	mov		[edi],eax
	add		edi,4
	loop	@b
	invoke UpdateWindow,hDEd
	mov		hReSize,0
	invoke PropertyList,0
	ret

DestroySizeingRect endp

DialogTltSize proc uses esi,ccx:DWORD,ccy:DWORD,cdx:DWORD,cdy:DWORD     ; *** MOD add: cdx, cdy
	LOCAL	buffer[64]:BYTE
	LOCAL	pt:POINT
	LOCAL	hDC:HDC
	LOCAL	len:DWORD
	LOCAL	hOldFont:DWORD

	.if fShowSizePos
		invoke GetCursorPos,addr mpt
		add		mpt.y,15
		add		mpt.x,15

		lea		esi,buffer

		mov		[esi],dword ptr ':L '         ; *** MOD
		add		esi,3
		invoke ConvertToDux,ccx
		invoke ResEdBinToDec,eax,esi
		invoke strlen,esi
		add		esi,eax

		mov		[esi],dword ptr ':T '         ; *** MOD
		add 	esi,3
		invoke ConvertToDuy,ccy
		invoke ResEdBinToDec,eax,esi
		invoke strlen,esi
		add		esi,eax
		
		
		mov		[esi],dword ptr '    '        ; *** MOD
		add		esi,4
		mov		[esi],dword ptr ':R '         ; *** MOD
		add		esi,3
		invoke ConvertToDux,cdx
		invoke ResEdBinToDec,eax,esi
		invoke strlen,esi
		add		esi,eax

		mov		[esi],dword ptr ':B '         ; *** MOD
		add 	esi,3
		invoke ConvertToDuy,cdy
		invoke ResEdBinToDec,eax,esi
		invoke strlen,esi
		add		esi,eax

		mov		[esi],dword ptr '    '        ; *** MOD
		add		esi,4
		mov		[esi],dword ptr ':W '         ; *** MOD
		add		esi,3
		mov     eax,cdx
		sub     eax,ccx
		invoke ConvertToDux,eax
		invoke ResEdBinToDec,eax,esi
		invoke strlen,esi
		add		esi,eax

		mov		[esi],dword ptr ':H '         ; *** MOD
		add 	esi,3
		mov     eax,cdy
		sub     eax,ccy
		invoke ConvertToDuy,eax
		invoke ResEdBinToDec,eax,esi
		invoke strlen,esi
		add		esi,eax
		mov		[esi],dword ptr '  '         ; *** MOD

		invoke GetDC,hTlt
		mov		hDC,eax
		invoke SendMessage,hTlt,WM_GETFONT,0,0
		invoke SelectObject,hDC,eax
		mov		hOldFont,eax
		invoke strlen,addr buffer
		mov		len,eax
		invoke GetTextExtentPoint32,hDC,addr buffer,len,addr pt
		invoke SelectObject,hDC,hOldFont
		invoke ReleaseDC,hTlt,hDC
		invoke SetWindowText,hTlt,addr buffer
		invoke MoveWindow,hTlt,mpt.x,mpt.y,pt.x,nPropHt,TRUE
		invoke ShowWindow,hTlt,SW_SHOWNA
		invoke InvalidateRect,hTlt,NULL,TRUE
		invoke UpdateWindow,hTlt
		invoke SendMessage,hStatus,SB_SETTEXT,5, addr buffer

	.endif
	ret

DialogTltSize endp

SizeingProc proc uses edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	nInx:DWORD
	LOCAL	pt:POINT
	LOCAL	hDC:HDC
	LOCAL   rect:RECT             ; *** MOD add
    LOCAL   rect1:RECT            ; *** MOD add

	mov		eax,uMsg
	.if eax>=WM_MOUSEFIRST && eax<=WM_MOUSELAST
		invoke GetWindowLong,hWin,GWL_USERDATA
		movzx	edx,ax
		shr		eax,16
		mov		nInx,eax
		.if edx
			mov		eax,uMsg
			.if eax==WM_LBUTTONDOWN
				invoke GetFocus
				.if eax==hPrpEdtDlgCld
					invoke SetFocus,hDEd
					mov		eax,nInx
					mov		edi,offset hSizeing
					mov		eax,[edi+eax*4]
					invoke PostMessage,eax,uMsg,wParam,lParam
				.else
					mov		des.fmode,MODE_SIZING
					invoke PropertyList,0
					mov		eax,lParam
					movsx	edx,ax
					mov		MousePtDown.x,edx
					shr		eax,16
					cwde
					mov		MousePtDown.y,eax
					invoke GetWindowRect,hReSize,addr des.ctlrect
					invoke ScreenToClient,hInvisible,addr des.ctlrect.left
					invoke ScreenToClient,hInvisible,addr des.ctlrect.right
					invoke GetCtrlMem,hReSize
					mov		edi,eax
					mov		eax,[edi].DIALOG.ntype
					invoke GetTypePtr,eax
					mov		eax,[eax].TYPES.keepsize
					and		eax,1
					.if eax
						invoke ConvertDuyToPix,[edi].DIALOG.duccy
						add		eax,des.ctlrect.top
						mov		des.ctlrect.bottom,eax
					.endif
					invoke CaptureWin
					invoke SetCapture,hWin
					invoke SendMessage,hWin,WM_MOUSEMOVE,wParam,lParam
				.endif
			.elseif eax==WM_LBUTTONUP && des.fmode==MODE_SIZING
				mov		eax,hReSize
				mov		des.hselected,eax
				invoke SendMessage,hInvisible,WM_LBUTTONUP,0,0
			.elseif eax==WM_MOUSEMOVE && des.fmode==MODE_SIZING
				invoke CopyRect,addr SizeRect,addr des.ctlrect
				mov		eax,lParam
				movsx	edx,ax
				sub		edx,MousePtDown.x
				mov		pt.x,edx
				shr		eax,16
				cwde
				sub		eax,MousePtDown.y
				mov		pt.y,eax
				mov		eax,nInx
				.if eax==0
					;Left,Top
					mov		eax,pt.x
					add		SizeRect.left,eax
					mov		eax,pt.y
					add		SizeRect.top,eax
					invoke SnapPtDu,addr SizeRect.left
				.elseif eax==1
					;Center,Top
					push	SizeRect.left
					mov		eax,pt.y
					add		SizeRect.top,eax
					invoke SnapPtDu,addr SizeRect.left
					pop		SizeRect.left
				.elseif eax==2
					;Right,Top
					push	SizeRect.left
					push	SizeRect.bottom
					mov		eax,pt.y
					add		SizeRect.top,eax
					invoke SnapPtDu,addr SizeRect.left
					mov		eax,pt.x
					add		SizeRect.right,eax
					invoke SnapPtDu,addr SizeRect.right
					pop		SizeRect.bottom
					pop		SizeRect.left
				.elseif eax==3
					;Left,Middle
					push	SizeRect.top
					mov		eax,pt.x
					add		SizeRect.left,eax
					invoke SnapPtDu,addr SizeRect.left
					pop		SizeRect.top
				.elseif eax==4
					;Right,Middle
					push	SizeRect.bottom
					mov		eax,pt.x
					add		SizeRect.right,eax
					invoke SnapPtDu,addr SizeRect.right
					pop		SizeRect.bottom
				.elseif eax==5
					;Left,Bottom
					push	SizeRect.top
					push	SizeRect.right
					mov		eax,pt.y
					add		SizeRect.bottom,eax
					invoke SnapPtDu,addr SizeRect.right
					mov		eax,pt.x
					add		SizeRect.left,eax
					invoke SnapPtDu,addr SizeRect.left
					pop		SizeRect.right
					pop		SizeRect.top
				.elseif eax==6
					;Center,Bottom
					push	SizeRect.right
					mov		eax,pt.y
					add		SizeRect.bottom,eax
					invoke SnapPtDu,addr SizeRect.right
					pop		SizeRect.right
				.elseif eax==7
					;Right,Bottom
					mov		eax,pt.x
					add		SizeRect.right,eax
					mov		eax,pt.y
					add		SizeRect.bottom,eax
					invoke SnapPtDu,addr SizeRect.right
				.endif
				invoke RestoreWin
				invoke GetDC,hInvisible
				mov		hDC,eax
				invoke GetStockObject,BLACK_BRUSH
				invoke FrameRect,hDC,addr SizeRect,eax
				invoke ReleaseDC,hInvisible,hDC
				; *** MOD
				;mov		eax,SizeRect.right
				;sub		eax,SizeRect.left
				;mov		pt.x,eax
				;mov		eax,SizeRect.bottom
				;sub		eax,SizeRect.top
				;mov		pt.y,eax
				;invoke ScreenToClient,des.hdlg,addr SizeRect.left
				
				invoke GetCtrlMem,hReSize
				mov		edi,eax
				mov		eax,[edi].DIALOG.ntype
                .if eax == 0                        ; only dialogboxes
                	invoke GetClientRect,des.hdlg,addr rect
	               	invoke GetWindowRect,des.hdlg,addr rect1
					
                	mov    eax,rect.right
                	add    eax,SizeRect.right
                	sub    eax,SizeRect.left
					add    eax,rect1.left
                	sub    eax,rect1.right          ; = SizeRectWdt - non client area

					mov    ecx,rect.bottom
                	add    ecx,SizeRect.bottom
                	sub    ecx,SizeRect.top
                	add    ecx,rect1.top
                	sub    ecx,rect1.bottom         ; = SizeRectHgt - non client area

                	invoke DialogTltSize,0,0,eax,ecx                                ; *** MOD
                .else
	                invoke CopyRect,addr rect,addr SizeRect                         ; *** MOD
	                invoke MapWindowPoints,hInvisible,des.hdlg,addr rect,2          ; *** MOD
					invoke DialogTltSize,rect.left,rect.top,rect.right,rect.bottom  ; *** MOD
                .endif
	            ; ================		
			.endif
		.endif
	.elseif eax==WM_SETCURSOR
		invoke GetWindowLong,hWin,GWL_USERDATA
		movzx	eax,ax
		.if eax
			invoke LoadCursor,0,eax
		.else
			invoke LoadCursor,0,IDC_ARROW
		.endif
		invoke SetCursor,eax
	.else
		invoke CallWindowProc,OldSizeingProc,hWin,uMsg,wParam,lParam
		ret
	.endif
	xor		eax,eax
	ret

SizeingProc endp

DrawSizeingItem proc uses edi,xP:DWORD,yP:DWORD,nInx:DWORD,hCur:DWORD,hPar:DWORD,fLocked:DWORD
	LOCAL	hWin:HWND

	mov		eax,nInx
	shl		eax,2
	mov		edi,offset hSizeing
	add		edi,eax
	mov		eax,[edi]
	.if eax
		invoke DestroyWindow,eax
	.endif
	invoke GetWindowLong,hDEd,DEWM_MEMORY
	.if eax!=0 && fLocked==FALSE
		push	[eax].DLGHEAD.locked
		pop		fLocked
	.endif
	invoke GetWindowLong,hDEd,DEWM_READONLY
	.if eax
		mov		fLocked,TRUE
	.endif
	.if fLocked
		mov		hCur,NULL
	.endif
	.if hCur
		invoke CreateWindowEx,0,
		addr szStaticClass,0,
		WS_CHILD or WS_VISIBLE or SS_WHITERECT or WS_BORDER or SS_NOTIFY,
		xP,yP,6,6,
		hPar,0,hInstance,0
	.else
		invoke CreateWindowEx,0,
		addr szStaticClass,0,
		WS_CHILD or WS_VISIBLE or SS_GRAYRECT or WS_BORDER or SS_NOTIFY or WS_CLIPSIBLINGS or WS_CLIPCHILDREN,
		xP,yP,6,6,
		hPar,0,hInstance,0
	.endif
	mov		hWin,eax
	mov		[edi],eax
	mov		eax,nInx
	shl		eax,16
	or		eax,hCur
	invoke SetWindowLong,hWin,GWL_USERDATA,eax
	invoke SetWindowLong,hWin,GWL_WNDPROC,offset SizeingProc
	mov		OldSizeingProc,eax
	invoke SetWindowPos,hWin,HWND_TOP,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE
	ret

DrawSizeingItem endp

DrawMultiSelItem proc xP:DWORD,yP:DWORD,hPar:HWND,fLocked:DWORD,hPrv:HWND
	LOCAL	hWin:HWND

	.if !fLocked
		mov		edx,WS_CHILD or WS_CLIPSIBLINGS or WS_VISIBLE or SS_WHITERECT or WS_BORDER
	.else
		mov		edx,WS_CHILD or WS_CLIPSIBLINGS or WS_VISIBLE or SS_GRAYRECT or WS_BORDER
	.endif
	invoke CreateWindowEx,0,addr szStaticClass,0,edx,xP,yP,6,6,hPar,0,hInstance,0
	mov		hWin,eax
	invoke SetWindowLong,hWin,GWL_USERDATA,hPrv
	invoke SetWindowPos,hWin,HWND_TOP,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE
	mov		eax,hWin
	ret

DrawMultiSelItem endp

DestroyMultiSel proc uses ebx,hSel:HWND
	LOCAL	rect:RECT

	.if hSel
		mov		ebx,8
		.while ebx
			invoke GetWindowRect,hSel,addr rect
			invoke ScreenToClient,hDEd,addr rect.left
			invoke ScreenToClient,hDEd,addr rect.right
			invoke InvalidateRect,hDEd,addr rect,TRUE
			invoke GetWindowLong,hSel,GWL_USERDATA
			push	eax
			invoke DestroyWindow,hSel
			pop		hSel
			dec		ebx
		.endw
	.endif
	mov		eax,hSel
	ret

DestroyMultiSel endp

MultiSelRect proc uses ebx,hWin:HWND,fLocked:DWORD
	LOCAL	rect:RECT
	LOCAL	ctlrect:RECT
	LOCAL	pt:POINT
	LOCAL	hSel:HWND

	mov		hSel,0
	mov		ebx,hMultiSel
	.while ebx
		invoke GetParent,ebx
		.if eax==hWin
			invoke DestroyMultiSel,ebx
			mov		ebx,eax
			.if hSel
				invoke SetWindowLong,hSel,GWL_USERDATA,ebx
			.else
				mov		hMultiSel,ebx
			.endif
			xor		ebx,ebx
		.else
			mov		ecx,8
			.while ecx
				push	ecx
				mov		hSel,ebx
				invoke GetWindowLong,ebx,GWL_USERDATA
				mov		ebx,eax
				pop		ecx
				dec		ecx
			.endw
		.endif
	.endw
	mov		des.parpt.x,0
	mov		des.parpt.y,0
	invoke ClientToScreen,hWin,addr des.parpt
	invoke GetWindowRect,hWin,addr rect
	invoke CopyRect,addr des.ctlrect,addr rect
	mov		eax,des.parpt.x
	sub		rect.left,eax
	sub		rect.right,eax
	mov		eax,des.parpt.y
	sub		rect.top,eax
	sub		rect.bottom,eax
	invoke CopyRect,addr ctlrect,addr rect
	sub		rect.right,6
	sub		rect.bottom,6
	mov		eax,rect.right
	sub		eax,rect.left
	shr		eax,1
	add		eax,rect.left
	mov		pt.x,eax
	mov		eax,rect.bottom
	sub		eax,rect.top
	shr		eax,1
	add		eax,rect.top
	mov		pt.y,eax
	invoke DrawMultiSelItem,rect.left,rect.top,hWin,fLocked,hMultiSel
	invoke DrawMultiSelItem,pt.x,rect.top,hWin,fLocked,eax
	invoke DrawMultiSelItem,rect.right,rect.top,hWin,fLocked,eax
	invoke DrawMultiSelItem,rect.left,pt.y,hWin,fLocked,eax
	invoke DrawMultiSelItem,rect.right,pt.y,hWin,fLocked,eax
	invoke DrawMultiSelItem,rect.left,rect.bottom,hWin,fLocked,eax
	invoke DrawMultiSelItem,pt.x,rect.bottom,hWin,fLocked,eax
	invoke DrawMultiSelItem,rect.right,rect.bottom,hWin,fLocked,eax
	mov		hMultiSel,eax
	ret

MultiSelRect endp

SizeingRect proc uses esi,hWin:HWND,fLocked:DWORD
	LOCAL	fDlg:DWORD
	LOCAL	rect:RECT
	LOCAL	pt:POINT

	invoke GetCtrlMem,hWin
	mov		esi,eax
	.while hMultiSel
		invoke DestroyMultiSel,hMultiSel
		mov		hMultiSel,eax
	.endw
	mov		eax,hWin
	mov		hReSize,eax
	mov		fDlg,FALSE
	mov		eax,(DIALOG ptr [esi]).ntype
	.if !eax
		mov		fDlg,TRUE
	.elseif eax==18 || eax==19
		test	[esi].DIALOG.style,CCS_NORESIZE
		.if ZERO?
			mov		fLocked,TRUE
		.endif
	.endif
	mov		des.parpt.x,0
	mov		des.parpt.y,0
	invoke ClientToScreen,hInvisible,addr des.parpt
	invoke GetWindowRect,hWin,addr rect
	mov		eax,[esi].DIALOG.ntype
	invoke GetTypePtr,eax
	mov		eax,[eax].TYPES.keepsize
	and		eax,1
	.if eax
		invoke ConvertDuyToPix,[esi].DIALOG.duccy
		add		eax,rect.top
		mov		rect.bottom,eax
	.endif
	invoke CopyRect,addr des.ctlrect,addr rect
	mov		eax,des.parpt.x
	sub		rect.left,eax
	sub		rect.right,eax
	mov		eax,des.parpt.y
	sub		rect.top,eax
	sub		rect.bottom,eax

	sub		rect.left,6
	sub		rect.top,6
	mov		eax,rect.right
	sub		eax,rect.left
	shr		eax,1
	add		eax,rect.left
	mov		pt.x,eax
	mov		eax,rect.bottom
	sub		eax,rect.top
	shr		eax,1
	add		eax,rect.top
	mov		pt.y,eax
	.if fDlg
		invoke DrawSizeingItem,rect.left,rect.top,0,0,hInvisible,fLocked
		invoke DrawSizeingItem,pt.x,rect.top,1,0,hInvisible,fLocked
		invoke DrawSizeingItem,rect.right,rect.top,2,0,hInvisible,fLocked
		invoke DrawSizeingItem,rect.left,pt.y,3,0,hInvisible,fLocked
		invoke DrawSizeingItem,rect.left,rect.bottom,5,0,hInvisible,fLocked
	.else
		invoke DrawSizeingItem,rect.left,rect.top,0,IDC_SIZENWSE,hInvisible,fLocked
		invoke DrawSizeingItem,pt.x,rect.top,1,IDC_SIZENS,hInvisible,fLocked
		invoke DrawSizeingItem,rect.right,rect.top,2,IDC_SIZENESW,hInvisible,fLocked
		invoke DrawSizeingItem,rect.left,pt.y,3,IDC_SIZEWE,hInvisible,fLocked
		invoke DrawSizeingItem,rect.left,rect.bottom,5,IDC_SIZENESW,hInvisible,fLocked
	.endif
	invoke DrawSizeingItem,rect.right,pt.y,4,IDC_SIZEWE,hInvisible,fLocked
	invoke DrawSizeingItem,pt.x,rect.bottom,6,IDC_SIZENS,hInvisible,fLocked
	invoke DrawSizeingItem,rect.right,rect.bottom,7,IDC_SIZENWSE,hInvisible,fLocked
	invoke PropertyList,hWin
	ret

SizeingRect endp

SnapToGrid proc uses edi,hWin:HWND,lpRect:DWORD
	LOCAL	hPar:HWND

	call RSnapToGrid
	.if fRSnapToGrid
		mov		edi,lpRect
		invoke GetParent,hWin
		mov		hPar,eax
		mov		des.parpt.x,0
		mov		des.parpt.y,0
		invoke ClientToScreen,hPar,addr des.parpt
		mov		eax,[edi].RECT.left
		sub		eax,des.parpt.x
		cdq
		idiv	Gridcx
		imul	Gridcx
		add		eax,des.parpt.x
		sub		eax,[edi].RECT.left
		add		[edi].RECT.left,eax
		add		[edi].RECT.right,eax

		mov		eax,[edi].RECT.right
		sub		eax,[edi].RECT.left
		cdq
		idiv	Gridcx
		imul	Gridcx
		add		eax,[edi].RECT.left
		inc		eax
		mov		[edi].RECT.right,eax

		mov		eax,[edi].RECT.top
		sub		eax,des.parpt.y
		cdq
		idiv	Gridcy
		imul	Gridcy
		add		eax,des.parpt.y
		sub		eax,[edi].RECT.top
		add		[edi].RECT.top,eax
		add		[edi].RECT.bottom,eax

		mov		eax,[edi].RECT.bottom
		sub		eax,[edi].RECT.top
		cdq
		idiv	Gridcy
		imul	Gridcy
		add		eax,[edi].RECT.top
		inc		eax
		mov		[edi].RECT.bottom,eax
	.endif
	ret

SnapToGrid endp

CtlMultiSelect proc hWin:HWND

	.if hReSize
		invoke GetCtrlMem,hWin
		mov		eax,[eax].DIALOG.ntype
		.if eax && eax!=18 && eax!=19
			mov		eax,hReSize
			.if eax!=hWin
				push	eax
				invoke DestroySizeingRect
				pop		eax
				invoke MultiSelRect,eax,TRUE
				invoke MultiSelRect,hWin,FALSE
			.endif
		.endif
		xor		eax,eax
		ret
	.endif
	.if hMultiSel
		invoke GetParent,hMultiSel
		.if eax==hWin
			invoke DestroyMultiSel,hMultiSel
			mov		hMultiSel,eax
			invoke GetParent,eax
			push	eax
			invoke DestroyMultiSel,hMultiSel
			mov		hMultiSel,eax
			pop		eax
			.if hMultiSel
				invoke MultiSelRect,eax,FALSE
			.else
				invoke SizeingRect,eax,FALSE
			.endif
			xor		eax,eax
			ret
		.else
			push	eax
			invoke DestroyMultiSel,hMultiSel
			mov		hMultiSel,eax
			pop		eax
			invoke MultiSelRect,eax,TRUE
		.endif
	.endif
	invoke MultiSelRect,hWin,FALSE
	ret

CtlMultiSelect endp

DesignDummyProc proc uses ebx,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT
	LOCAL	hDlg:HWND
	LOCAL	buffer[16]:BYTE
	LOCAL	pt:POINT
	LOCAL	hMem:DWORD

	mov		eax,uMsg
	.if eax==WM_CREATE
		invoke GetWindowLong,hWin,GWL_ID
		.if eax==123456789
			invoke GetWindowLong,hDEd,DEWM_MEMORY
			mov		ebx,eax
			lea		ebx,[ebx+sizeof DLGHEAD+sizeof DIALOG]
			.while [ebx].DIALOG.hwnd
				.if [ebx].DIALOG.hwnd!=-1
					invoke GetCtrlID,ebx
					invoke GetDlgItem,des.hdlg,eax
					mov		edx,eax
					invoke GetWindowRect,edx,addr rect
					invoke ScreenToClient,hWin,addr rect.left
					invoke GetCtrlID,ebx
					invoke CreateWindowEx,NULL,addr szStaticClass,NULL,WS_CHILD or WS_VISIBLE or SS_CENTER or SS_NOTIFY,rect.left,rect.top,22,18,hWin,eax,hInstance,0
					push	eax
					invoke SendMessage,hTlt,WM_GETFONT,0,0
					pop		edx
					invoke SendMessage,edx,WM_SETFONT,eax,FALSE
				.endif
				lea		ebx,[ebx+sizeof DIALOG]
			.endw
			call	SetTabText
		.endif
	.elseif eax==WM_CTLCOLORSTATIC
		invoke SetBkMode,wParam,TRANSPARENT
		invoke SetTextColor,wParam,0FFFFFFh
		invoke GetStockObject,BLACK_BRUSH
		ret
	.elseif eax==WM_COMMAND
		invoke GetAsyncKeyState,VK_CONTROL
		and		eax,8000h
		.if eax
			invoke GetDlgItem,des.hdlg,wParam
			invoke GetCtrlMem,eax
			mov		eax,[eax].DIALOG.tab
			mov		nTabSet,eax
		.else
			invoke GetDlgItem,des.hdlg,wParam
			invoke SetNewTab,eax,nTabSet
			call	SetTabText
			invoke SetChanged,TRUE
		.endif
		inc		nTabSet
	.elseif eax==WM_LBUTTONDOWN
		invoke GetWindowLong,hWin,GWL_ID
		.if eax==123456789
			mov		eax,lParam
			movsx	eax,ax
			mov		pt.x,eax
			mov		eax,lParam
			shr		eax,16
			movsx	eax,ax
			mov		pt.y,eax
			invoke ClientToScreen,hWin,addr pt
			invoke GetWindowLong,hDEd,DEWM_MEMORY
			mov		ebx,eax
			add		ebx,sizeof DLGHEAD
			invoke ScreenToClient,des.hdlg,addr pt
			mov		hDlg,0
			.while [ebx].DIALOG.hwnd
				.if [ebx].DIALOG.hwnd!=-1
					invoke GetCtrlID,ebx
					.if eax
						invoke GetDlgItem,des.hdlg,eax
					.else
						mov		eax,des.hdlg
					.endif
					mov		edx,eax
					invoke GetWindowRect,edx,addr rect
					invoke ScreenToClient,des.hdlg,addr rect.left
					invoke ScreenToClient,des.hdlg,addr rect.right
					mov		eax,pt.x
					mov		edx,pt.y
					.if sdword ptr eax>=rect.left && sdword ptr eax<=rect.right && sdword ptr edx>=rect.top && sdword ptr edx<=rect.bottom
						invoke GetCtrlID,ebx
						.if eax
							invoke GetDlgItem,des.hdlg,eax
						.else
							mov		eax,des.hdlg
						.endif
						mov		hDlg,eax
						mov		hMem,ebx
					.endif
				.endif
				add		ebx,sizeof DIALOG
			.endw
			.if hDlg
				mov		ebx,hMem
				.if ![ebx].DIALOG.ntype
					invoke DestroyWindow,hTabSet
					invoke ShowWindow,hInvisible,SW_SHOWNA
					invoke SizeingRect,des.hdlg,FALSE
					xor		eax,eax
					mov		hTabSet,eax
					ret
				.endif
			.endif
		.endif
		xor		eax,eax
	.else
  ExDef:
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
	.endif
	ret

SetTabText:
	mov		ecx,1
	.while TRUE
		push	ecx
		push	ecx
		invoke GetDlgItem,hWin,ecx
		pop		ecx
		.if !eax
			pop		ecx
			.break
		.endif
		push	eax
		invoke GetDlgItem,des.hdlg,ecx
		invoke GetCtrlMem,eax
		mov		ebx,eax
		invoke ResEdBinToDec,[ebx].DIALOG.tab,addr buffer
		pop		edx
		invoke SetWindowText,edx,addr buffer
		pop		ecx
		inc		ecx
	.endw
	retn

DesignDummyProc endp

CreateNewCtl proc uses esi edi,hOwner:DWORD,nType:DWORD,x:DWORD,y:DWORD,ccx:DWORD,ccy:DWORD
	LOCAL	buffer[MaxName]:BYTE

	invoke GetWindowLong,hDEd,DEWM_MEMORY
	.if eax
		invoke GetFreeDlg,eax
		mov		edi,eax
		invoke GetTypePtr,nType
		mov		esi,eax
		;Set default ctl data
		mov		[edi].DIALOG.hwnd,1
		mov		eax,nType
		mov		[edi].DIALOG.ntype,eax
		mov		eax,(TYPES ptr [esi]).ID
		mov		[edi].DIALOG.ntypeid,eax
		mov		eax,(TYPES ptr [esi]).style
		mov		[edi].DIALOG.style,eax
		mov		eax,(TYPES ptr [esi]).exstyle
		mov		[edi].DIALOG.exstyle,eax
		mov		eax,x
		mov		[edi].DIALOG.dux,eax
		mov		eax,y
		mov		[edi].DIALOG.duy,eax
		.if ccx<3 && ccy<3
			invoke ConvertToDux,[esi].TYPES.xsize
			invoke SizeX
			mov		ccx,eax
			invoke ConvertToDuy,[esi].TYPES.ysize
			invoke SizeY
			mov		ccy,eax
		.endif
		mov		eax,ccx
		mov		[edi].DIALOG.duccx,eax
		mov		eax,ccy
		mov		[edi].DIALOG.duccy,eax
		invoke strcpyn,addr buffer,[esi].TYPES.lpidname,MaxName
		invoke GetUnikeName,addr buffer
		invoke strcpyn,addr [edi].DIALOG.idname,addr buffer,MaxName
		invoke strcpyn,addr [edi].DIALOG.caption,[esi].TYPES.lpcaption,MaxCap
		.if !nType
			invoke GetFreeProjectitemID,TPE_DIALOG
			mov		[edi].DIALOG.id,eax
			;Set default DLGHEAD info
			mov		esi,edi
			sub		esi,sizeof DLGHEAD
			inc		eax
			mov		[esi].DLGHEAD.ctlid,eax
			mov		[esi].DLGHEAD.class,0
			mov		[esi].DLGHEAD.menuid,0
			invoke strcpy,addr [esi].DLGHEAD.font,addr DlgFN
			mov		eax,DlgFS
			mov		[esi].DLGHEAD.fontsize,eax
			mov		[edi].DIALOG.tab,0
		.else
			invoke GetFreeID
			mov		[edi].DIALOG.id,eax
			mov		[edi].DIALOG.tab,-1
			invoke GetFreeTab
			mov		[edi].DIALOG.tab,eax
			.if nType==23
				invoke strcpy,addr [edi].DIALOG.class,addr szUserControlClass
			.endif
		.endif
		invoke GetWindowLong,hDEd,DEWM_MEMORY
		mov		esi,eax
		invoke GetCtrlID,edi
		push	eax
		invoke MakeDialog,esi,eax
		invoke SetChanged,TRUE
		pop		edx
		.if edx
			invoke GetDlgItem,des.hdlg,edx
		.endif
		push	eax
		invoke NotifyParent
		pop		eax
	.endif
	ret

CreateNewCtl endp

DesignInvisibleProc proc uses ebx,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	pt:POINT
	LOCAL	rect:RECT
	LOCAL	rect1:RECT
	LOCAL	hCld:HWND
	LOCAL	hDC:HDC
	LOCAL	parpt:POINT
	LOCAL	fShift:DWORD
	LOCAL	fControl:DWORD
	LOCAL	fChanged:DWORD
	LOCAL	nInx:DWORD
	LOCAL	dblclk:CTLDBLCLICK

	mov		eax,uMsg
	.if eax==WM_MOUSEMOVE
		.if des.fmode==MODE_DRAWING
			call	SnapPt
			invoke RestoreWin
			mov		eax,pt.x
			mov		des.ctlrect.right,eax
			mov		eax,pt.y
			mov		des.ctlrect.bottom,eax
			invoke CopyRect,addr rect,addr des.ctlrect
			mov		eax,rect.right
			.if sdword ptr eax<rect.left
				inc		eax
				xchg	rect.left,eax
				mov		rect.right,eax
			.endif
			mov		eax,rect.bottom
			.if sdword ptr eax<rect.top
				inc		eax
				xchg	rect.top,eax
				mov		rect.bottom,eax
			.endif
			call	DrawRect
			; *** MOD
			;mov		eax,rect.right
			;sub		eax,rect.left
			;mov		edx,rect.bottom
			;sub		edx,rect.top
			invoke MapWindowPoints,hInvisible,des.hdlg,addr rect,2
			invoke DialogTltSize,rect.left,rect.top,rect.right,rect.bottom
		    ; ===========
		.elseif des.fmode==MODE_MOVING || des.fmode==MODE_MOVINIT
			call	SnapPt
			invoke RestoreWin
			mov		eax,des.ctlrect.right
			sub		eax,des.ctlrect.left
			;Width
			push	eax
			mov		eax,des.ctlrect.bottom
			sub		eax,des.ctlrect.top
			;Height
			push	eax
			invoke SnapPtDu,addr des.ctlrect.left
			pop		eax
			add		eax,des.ctlrect.top
			mov		des.ctlrect.bottom,eax
			pop		eax
			add		eax,des.ctlrect.left
			mov		des.ctlrect.right,eax
			invoke CopyRect,addr rect,addr des.ctlrect
			mov		eax,pt.x
			sub		eax,MousePtDown.x
			add		rect.left,eax
			mov		eax,pt.y
			sub		eax,MousePtDown.y
			add		rect.top,eax
			invoke SnapPtDu,addr rect.left
			mov		eax,des.ctlrect.right
			sub		eax,des.ctlrect.left
			add		eax,rect.left
			mov		rect.right,eax
			mov		eax,des.ctlrect.bottom
			sub		eax,des.ctlrect.top
			add		eax,rect.top
			mov		rect.bottom,eax
			call	DrawRect
			mov		eax,pt.x
			sub		eax,MousePtDown.x
			mov		edx,pt.y
			sub		edx,MousePtDown.y
			.if sdword ptr eax<-1 || sdword ptr eax>1 || sdword ptr edx<-1 ||  sdword ptr edx>1 || des.fmode==MODE_MOVING
				mov		des.fmode,MODE_MOVING
				; *** MOD
				;invoke ClientToScreen,hInvisible,addr rect.left
				;invoke ScreenToClient,des.hdlg,addr rect.left
				invoke MapWindowPoints,hInvisible,des.hdlg,addr rect,2
				invoke DialogTltSize,rect.left,rect.top,rect.right,rect.bottom
			    ; ============= 
			.endif
		.elseif des.fmode==MODE_MULTISELMOVE || des.fmode==MODE_MULTISELMOVEINIT
			call	SnapPt
			mov		eax,pt.x
			mov		edx,pt.y
			.if eax!=OldPt.x || edx!=OldPt.y
				mov		des.fmode,MODE_MULTISELMOVE
				mov		OldPt.x,eax
				mov		OldPt.y,edx
				invoke RestoreWin
				call	DrawMultisel
			.endif
		.elseif des.fmode==MODE_SELECT
			call	SnapPt
			invoke RestoreWin
			mov		eax,pt.x
			mov		des.ctlrect.right,eax
			mov		eax,pt.y
			mov		des.ctlrect.bottom,eax
			invoke CopyRect,addr rect,addr des.ctlrect
			mov		eax,rect.right
			.if sdword ptr eax<rect.left
				inc		eax
				xchg	rect.left,eax
				mov		rect.right,eax
			.endif
			mov		eax,rect.bottom
			.if sdword ptr eax<rect.top
				inc		eax
				xchg	rect.top,eax
				mov		rect.bottom,eax
			.endif
			call	DrawRect
		.elseif !ToolBoxID
			mov		eax,lParam
			movsx	edx,ax
			shr		eax,16
			cwde
			mov		pt.x,edx
			mov		pt.y,eax
			invoke ClientToScreen,hWin,addr pt
			invoke GetWindowRect,des.hdlg,addr rect
			mov		eax,rect.left
			sub		pt.x,eax
			mov		eax,rect.top
			sub		pt.y,eax
			mov		eax,pt.x
			mov		edx,pt.y
			.if eax!=des.dlgpt.x || edx!=des.dlgpt.y
				mov		des.dlgpt.x,eax
				mov		des.dlgpt.y,edx
				.if (eax>=des.mnurect.left && eax<=des.mnurect.right && edx>=des.mnurect.top && edx <=des.mnurect.bottom) || des.nmnu
					shl		edx,16
					movzx	eax,ax
					or		eax,edx
					invoke SendMessage,des.hdlg,WM_NCMOUSEMOVE,wParam,eax
				.endif
			.endif
		.endif
		.if hStatus
			invoke GetCursorPos,addr pt
			invoke GetWindowLong,hDEd,DEWM_MEMORY
			.if eax
				invoke ScreenToClient,des.hdlg,addr pt
				invoke ConvertToDux,pt.x
				invoke ResEdBinToDec,eax,offset szPos+5
				invoke strlen,offset szPos
				mov		word ptr szPos[eax],' ,'
				add     eax,2
				push	eax
				invoke ConvertToDuy,pt.y
				mov		edx,eax
				pop		eax
				invoke ResEdBinToDec,edx,addr szPos[eax]
				invoke SendMessage,hStatus,SB_SETTEXT,nStatus,offset szPos
			.endif
		.endif
	.elseif eax==WM_LBUTTONDOWN
		.if des.nmnu
			dec		des.dlgpt.x
			invoke SendMessage,hWin,WM_MOUSEMOVE,wParam,lParam
		.else
			mov		eax,lParam
			movsx	edx,ax
			shr		eax,16
			cwde
			mov		pt.x,edx
			mov		pt.y,eax
			invoke SetCapture,hWin
			mov		ebx,des.hdlg
			call	IsInWindow
			.if eax
				mov		fShift,FALSE
				mov		fControl,FALSE
				mov		eax,wParam
				test	eax,MK_SHIFT
				.if !ZERO?
					mov		fShift,TRUE
				.endif
				;Control key
				test	eax,MK_CONTROL
				.if !ZERO?
					mov		fControl,TRUE
				.endif
				mov		eax,hReSize
				mov		des.hselected,eax
				.if hSizeing
					invoke DestroySizeingRect
				.endif
				.if ToolBoxID
					;Is readOnly
					invoke GetWindowLong,hDEd,DEWM_READONLY
					.if !eax
						invoke CaptureWin
						call	SnapPt
						mov		eax,pt.x
						mov		MousePtDown.x,eax
						mov		eax,pt.y
						mov		MousePtDown.y,eax
						mov		eax,pt.x
						mov		des.ctlrect.left,eax
						mov		des.ctlrect.right,eax
						mov		eax,pt.y
						mov		des.ctlrect.top,eax
						mov		des.ctlrect.bottom,eax
						mov		des.fmode,MODE_DRAWING
					.endif
				.else
					push	ebx
					call	GetCtrl
					pop		eax
					.if eax!=hCld
						; Control
						.if !fShift && !fControl
							invoke GetWindowLong,hDEd,DEWM_READONLY
							.if !eax
								mov		eax,hMultiSel
								.if eax
									call	IsMultisel
									.if eax
										mov		des.fmode,MODE_MULTISELMOVEINIT
										invoke CaptureWin
										call	SnapPt
										mov		eax,pt.x
										mov		MousePtDown.x,eax
										mov		eax,pt.y
										mov		MousePtDown.y,eax
										call	DrawMultisel
										ret
									.endif
									.while hMultiSel
										invoke DestroyMultiSel,hMultiSel
										mov		hMultiSel,eax
									.endw
									invoke UpdateWindow,hDEd
								.endif
								invoke GetWindowLong,hDEd,DEWM_MEMORY
								.if ![eax].DLGHEAD.locked
									mov		eax,hCld
									mov		des.hselected,eax
									invoke CaptureWin
									call	SnapPt
									mov		eax,pt.x
									mov		MousePtDown.x,eax
									mov		eax,pt.y
									mov		MousePtDown.y,eax
									invoke GetWindowRect,hCld,addr des.ctlrect
									invoke ScreenToClient,hInvisible,addr des.ctlrect.left
									invoke ScreenToClient,hInvisible,addr des.ctlrect.right
									mov		des.fmode,MODE_MOVINIT
								.endif
							.endif
						.elseif !fShift && fControl
							.if hMultiSel
								invoke CtlMultiSelect,hCld
							.else
								call	GetCtrl
								mov		edx,des.hdlg
								mov		eax,hCld
								.if eax!=des.hselected && edx!=des.hselected
									invoke CtlMultiSelect,des.hselected
									invoke CtlMultiSelect,hCld
								.endif
							.endif
							.if hMultiSel
								mov		des.fmode,MODE_MULTISEL
								invoke PropertyList,-1
							.endif
						.elseif fShift && !fControl
							.while hMultiSel
								invoke DestroyMultiSel,hMultiSel
								mov		hMultiSel,eax
							.endw
							invoke UpdateWindow,hDEd
							invoke CaptureWin
							call	SnapPt
							mov		eax,pt.x
							mov		MousePtDown.x,eax
							mov		eax,pt.y
							mov		MousePtDown.y,eax
							mov		eax,pt.x
							mov		des.ctlrect.left,eax
							mov		des.ctlrect.right,eax
							mov		eax,pt.y
							mov		des.ctlrect.top,eax
							mov		des.ctlrect.bottom,eax
							mov		des.fmode,MODE_SELECT
						.endif
					.else
						; Dialog
						.if hMultiSel
							.while hMultiSel
								invoke DestroyMultiSel,hMultiSel
								mov		hMultiSel,eax
							.endw
							invoke UpdateWindow,hDEd
						.endif
						mov		des.fmode,MODE_NOTHING
						mov		eax,hCld
						.if eax==des.hselected || (fShift && !fControl)
							invoke CaptureWin
							call	SnapPt
							mov		eax,pt.x
							mov		MousePtDown.x,eax
							mov		eax,pt.y
							mov		MousePtDown.y,eax
							mov		eax,pt.x
							mov		des.ctlrect.left,eax
							mov		des.ctlrect.right,eax
							mov		eax,pt.y
							mov		des.ctlrect.top,eax
							mov		des.ctlrect.bottom,eax
							mov		des.fmode,MODE_SELECT
						.endif
					.endif
				.endif
				invoke NotifyParent
			.endif
		.endif
	.elseif eax==WM_LBUTTONUP
		mov		eax,lParam
		movsx	edx,ax
		shr		eax,16
		cwde
		mov		pt.x,edx
		mov		pt.y,eax
		invoke ReleaseCapture
		.if des.fmode==MODE_DRAWING
			invoke RestoreWin
			invoke DeleteObject,hWinBmp
			invoke ShowWindow,hTlt,SW_HIDE
			mov		des.fmode,MODE_NOTHING
			invoke CopyRect,addr rect,addr des.ctlrect
			mov		eax,rect.right
			.if sdword ptr eax<rect.left
				inc		eax
				xchg	rect.left,eax
				mov		rect.right,eax
			.endif
			mov		eax,rect.bottom
			.if sdword ptr eax<rect.top
				inc		eax
				xchg	rect.top,eax
				mov		rect.bottom,eax
			.endif
			invoke ClientToScreen,hInvisible,addr rect.left
			invoke ClientToScreen,hInvisible,addr rect.right
			mov		ebx,des.hdlg
			invoke ScreenToClient,ebx,addr rect.left
			invoke ScreenToClient,ebx,addr rect.right
			mov		eax,rect.right
			sub		eax,rect.left
			mov		rect.right,eax
			mov		eax,rect.bottom
			sub		eax,rect.top
			mov		rect.bottom,eax
	 		invoke ConvertToDux,rect.left
	 		invoke SizeX
			mov		rect.left,eax
	 		invoke ConvertToDux,rect.right
	 		invoke SizeX
			mov		rect.right,eax
	 		invoke ConvertToDuy,rect.top
	 		invoke SizeY
			mov		rect.top,eax
	 		invoke ConvertToDuy,rect.bottom
	 		invoke SizeY
			mov		rect.bottom,eax
			mov		edx,ToolBoxID
			invoke CreateNewCtl,des.hdlg,edx,rect.left,rect.top,rect.right,rect.bottom
			.if !fNoResetToolbox
				invoke ToolBoxReset
			.endif
		.elseif des.fmode==MODE_MOVING || des.fmode==MODE_MOVINIT
			invoke RestoreWin
			invoke DeleteObject,hWinBmp
			invoke ShowWindow,hTlt,SW_HIDE
			call	SnapPt
			mov		eax,pt.x
			mov		edx,pt.y
			mov		fChanged,FALSE
			.if (eax!=MousePtDown.x || edx!=MousePtDown.y) && des.fmode==MODE_MOVING
				invoke CopyRect,addr rect,addr des.ctlrect
				mov		eax,pt.x
				sub		eax,MousePtDown.x
				add		rect.left,eax
				add		rect.right,eax
				mov		eax,pt.y
				sub		eax,MousePtDown.y
				add		rect.top,eax
				add		rect.bottom,eax
				invoke ClientToScreen,hInvisible,addr rect.left
				invoke ClientToScreen,hInvisible,addr rect.right
				invoke ScreenToClient,des.hdlg,addr rect.left
				invoke ScreenToClient,des.hdlg,addr rect.right
				invoke GetCtrlMem,des.hselected
				mov		ebx,eax
		 		invoke ConvertToDux,rect.left
		 		invoke SizeX
		 		.if eax!=[ebx].DIALOG.dux
					mov		[ebx].DIALOG.dux,eax
					mov		fChanged,TRUE
		 		.endif
		 		invoke ConvertToDuy,rect.top
		 		invoke SizeY
		 		.if eax!=[ebx].DIALOG.duy
					mov		[ebx].DIALOG.duy,eax
					mov		fChanged,TRUE
		 		.endif
			.endif
			.if fChanged
				invoke GetWindowLong,des.hselected,GWL_ID
				push	eax
				invoke GetWindowLong,hDEd,DEWM_MEMORY
				pop		edx
				invoke MakeDialog,eax,edx
				invoke SetChanged,TRUE
			.else
				invoke SizeingRect,des.hselected,FALSE
			.endif
			mov		des.fmode,MODE_NOTHING
		.elseif des.fmode==MODE_SIZING
			invoke RestoreWin
			invoke DeleteObject,hWinBmp
			invoke ShowWindow,hTlt,SW_HIDE
			xor		eax,eax
			mov		des.fmode,eax
			mov		fChanged,eax
			invoke CopyRect,addr rect,addr SizeRect
			invoke ClientToScreen,hInvisible,addr rect.left
			invoke ClientToScreen,hInvisible,addr rect.right
			invoke ScreenToClient,des.hdlg,addr rect.left
			invoke ScreenToClient,des.hdlg,addr rect.right
			mov		eax,des.hdlg
			.if eax==des.hselected
				;Dialog
				mov		eax,rect.left
				sub		rect.right,eax
				mov		eax,rect.top
				sub		rect.bottom,eax
				xor		eax,eax
				mov		rect.left,eax
				mov		rect.top,eax
				mov		rect1.left,eax
				mov		rect1.top,eax
				mov		rect1.right,eax
				mov		rect1.bottom,eax
				invoke GetWindowLong,hDEd,DEWM_MEMORY
				xor		edx,edx
				.if [eax].DLGHEAD.menuid
					inc		edx
				.endif
				invoke AdjustWindowRectEx,addr rect1,[eax+sizeof DLGHEAD].DIALOG.style,edx,[eax+sizeof DLGHEAD].DIALOG.exstyle
				mov		eax,rect1.right
				sub		eax,rect1.left
				sub		rect.right,eax
				mov		eax,rect1.bottom
				sub		eax,rect1.top
				sub		rect.bottom,eax
			.endif
			invoke GetWindowLong,des.hselected,GWL_ID
			push	eax
			invoke GetCtrlMem,des.hselected
			mov		ebx,eax
			mov		eax,des.hdlg
			.if eax!=des.hselected
				;Control
		 		invoke ConvertToDux,rect.left
		 		.if eax!=[ebx].DIALOG.dux
					mov		[ebx].DIALOG.dux,eax
					inc		fChanged
		 		.endif
		 		invoke ConvertToDuy,rect.top
		 		.if eax!=[ebx].DIALOG.duy
					mov		[ebx].DIALOG.duy,eax
					inc		fChanged
		 		.endif
		 		invoke ConvertToDux,rect.right
		 		invoke SizeX
		 		sub		eax,[ebx].DIALOG.dux
		 		.if eax!=[ebx].DIALOG.duccx
					mov		[ebx].DIALOG.duccx,eax
					inc		fChanged
		 		.endif
		 		invoke ConvertToDuy,rect.bottom
		 		invoke SizeY
		 		sub		eax,[ebx].DIALOG.duy
		 		.if eax!=[ebx].DIALOG.duccy
					mov		[ebx].DIALOG.duccy,eax
					inc		fChanged
		 		.endif
			.else
				;Dialog
		 		invoke ConvertToDux,rect.right
		 		invoke SizeX
		 		.if eax!=[ebx].DIALOG.duccx
					mov		[ebx].DIALOG.duccx,eax
					inc		fChanged
		 		.endif
		 		invoke ConvertToDuy,rect.bottom
		 		invoke SizeY
		 		.if eax!=[ebx].DIALOG.duccy
					mov		[ebx].DIALOG.duccy,eax
					inc		fChanged
		 		.endif
			.endif
			invoke GetWindowLong,hDEd,DEWM_MEMORY
			pop		edx
			.if fChanged
				invoke MakeDialog,eax,edx
				invoke SetChanged,TRUE
			.else
				invoke PropertyList,des.hselected
			.endif
		.elseif des.fmode==MODE_MULTISEL
			.if !hMultiSel
				mov		des.fmode,MODE_NOTHING
			.endif
		.elseif des.fmode==MODE_MULTISELMOVE || des.fmode==MODE_MULTISELMOVEINIT
			mov		OldPt.x,0FFFFh
			mov		OldPt.y,0FFFFh
			invoke RestoreWin
			invoke DeleteObject,hWinBmp
			invoke ShowWindow,hTlt,SW_HIDE
			mov		des.fmode,MODE_NOTHING
			call	SnapPt
			mov		eax,pt.x
			sub		eax,MousePtDown.x
			invoke ConvertToDux,eax
	 		invoke SizeX
			mov		pt.x,eax
			mov		eax,pt.y
			sub		eax,MousePtDown.y
			invoke ConvertToDuy,eax
	 		invoke SizeY
			mov		pt.y,eax
			.if pt.x || pt.y
				mov		eax,hMultiSel
			  @@:
				push	eax
				invoke GetParent,eax
				invoke GetCtrlMem,eax
				mov		edx,eax
				mov		eax,pt.x
				add		[edx].DIALOG.dux,eax
				mov		eax,pt.y
				add		[edx].DIALOG.duy,eax
				pop		eax
				mov		ecx,8
				.while ecx
					push	ecx
					invoke GetWindowLong,eax,GWL_USERDATA
					pop		ecx
					dec		ecx
				.endw
				or		eax,eax
				jne		@b
				invoke GetWindowLong,hDEd,DEWM_MEMORY
				invoke MakeDialog,eax,-1
				invoke PropertyList,-1
				invoke SetChanged,TRUE
			.endif
		.elseif des.fmode==MODE_SELECT
			invoke RestoreWin
			invoke DeleteObject,hWinBmp
			mov		des.fmode,MODE_NOTHING
			.while hMultiSel
				invoke DestroyMultiSel,hMultiSel
				mov		hMultiSel,eax
			.endw
			invoke UpdateWindow,hDEd
			invoke CopyRect,addr rect,addr des.ctlrect
			mov		eax,rect.right
			.if sdword ptr eax<rect.left
				inc		eax
				xchg	rect.left,eax
				mov		rect.right,eax
			.endif
			mov		eax,rect.bottom
			.if sdword ptr eax<rect.top
				inc		eax
				xchg	rect.top,eax
				mov		rect.bottom,eax
			.endif
			invoke ClientToScreen,hWin,addr rect.left
			invoke ClientToScreen,hWin,addr rect.right
			invoke GetWindowLong,hDEd,DEWM_MEMORY
			lea		ebx,[eax+sizeof DLGHEAD+sizeof DIALOG]
			mov		nInx,0
			.while [ebx].DIALOG.hwnd
				.if [ebx].DIALOG.hwnd!=-1
					invoke GetCtrlID,ebx
					invoke GetDlgItem,des.hdlg,eax
					mov		hCld,eax
					invoke GetWindowRect,hCld,addr rect1
					mov		eax,rect1.left
					mov		ecx,rect1.right
					.if (eax>=rect.left && eax<=rect.right) || (ecx>=rect.left && ecx<=rect.right) || (rect.left>=eax && rect.right<=ecx)
						mov		eax,rect1.top
						mov		ecx,rect1.bottom
						.if (eax>=rect.top && eax<=rect.bottom) || (ecx>=rect.top && ecx<=rect.bottom) || (rect.top>=eax && rect.bottom<=ecx)
							mov		eax,[ebx].DIALOG.ntype
							.if eax!=18 && eax!=19
								invoke CtlMultiSelect,hCld
								inc		nInx
							.endif
						.endif
					.endif
				.endif
				lea		ebx,[ebx+sizeof DIALOG]
			.endw
			.if nInx==1 && hMultiSel
				invoke GetParent,hMultiSel
				invoke SizeingRect,eax,FALSE
			.elseif hMultiSel
				invoke PropertyList,-1
			.else
				invoke SizeingRect,des.hdlg,FALSE
			.endif
		.else
			mov		hCld,0
			mov		eax,lParam
			movsx	edx,ax
			shr		eax,16
			cwde
			mov		pt.x,edx
			mov		pt.y,eax
			mov		ebx,des.hdlg
			call	IsInWindow
			.if eax
				call	GetCtrl
				invoke SizeingRect,hCld,FALSE
			.endif
		.endif
		invoke NotifyParent
		invoke SetFocus,hDEd
	.elseif eax==WM_LBUTTONDBLCLK
		mov		eax,lParam
		movsx	edx,ax
		shr		eax,16
		cwde
		mov		pt.x,edx
		mov		pt.y,eax
		mov		ebx,des.hdlg
		call	IsInWindow
		.if eax
			push	ebx
			push	esi
			push	edi
			invoke GetWindowLong,hDEd,DEWM_MEMORY
			mov		esi,eax
			mov		edi,eax
			lea		esi,[esi+sizeof DLGHEAD]
			.while [esi].DIALOG.hwnd
				lea		esi,[esi+sizeof DIALOG]
			.endw
			lea		esi,[esi-sizeof DIALOG]
			.while esi>edi
				invoke GetCtrlID,esi
				.if eax
					invoke GetDlgItem,des.hdlg,eax
					mov		ebx,eax
				.else
					mov		ebx,des.hdlg
				.endif
				call	IsInWindow
				.break .if eax
				lea		esi,[esi-sizeof DIALOG]
			.endw
			pop		edi
			pop		esi
			pop		eax
			invoke GetCtrlMem,hCld
			mov		ebx,eax
			mov		eax,hRes
			mov		dblclk.nmhdr.hwndFrom,eax
			invoke GetWindowLong,hRes,GWL_ID
			push	eax
			mov		dblclk.nmhdr.idFrom,eax
			mov		dblclk.nmhdr.code,NM_CLICK
			mov		eax,[ebx].DIALOG.id
			mov		dblclk.nCtlId,eax
			lea		eax,[ebx].DIALOG.idname
			mov		dblclk.lpCtlName,eax
			invoke GetCtrlMem,des.hdlg
			mov		edx,eax
			mov		dblclk.lpDlgMem,edx
			mov		eax,[edx].DIALOG.id
			mov		dblclk.nDlgId,eax
			lea		eax,[edx].DIALOG.idname
			mov		dblclk.lpDlgName,eax
			invoke GetParent,hRes
			pop		edx
			mov		ecx,eax
			invoke SendMessage,ecx,WM_NOTIFY,edx,addr dblclk
		.endif
	.elseif eax==WM_SETCURSOR
		invoke GetCursorPos,addr pt
		invoke ScreenToClient,hInvisible,addr pt
		mov		ebx,des.hdlg
		call	IsInWindow
		.if ToolBoxID && (eax || des.fmode==MODE_DRAWING)
			invoke LoadCursor,0,IDC_CROSS
		.else
			invoke LoadCursor,0,IDC_ARROW
		.endif
		invoke SetCursor,eax
	.else
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
		ret
	.endif
	xor		eax,eax
	ret

IsMultisel:
	mov		eax,hMultiSel
	.if eax
	  @@:
		push	eax
		invoke GetParent,eax
		pop		edx
		.if eax==hCld
			retn
		.endif
		mov		eax,edx
		mov		ecx,8
		.while ecx
			push	ecx
			invoke GetWindowLong,eax,GWL_USERDATA
			pop		ecx
			dec		ecx
		.endw
		or		eax,eax
		jne		@b
	.endif
	retn

SnapPt:
	mov		eax,lParam
	movsx	edx,ax
	shr		eax,16
	cwde
	mov		pt.x,edx
	mov		pt.y,eax
	invoke SnapPtDu,addr pt
	retn

IsInWindow:
	invoke GetWindowRect,ebx,addr rect
	invoke ScreenToClient,hInvisible,addr rect.left
	invoke ScreenToClient,hInvisible,addr rect.right
	mov		eax,pt.x
	mov		edx,pt.y
	.if sdword ptr eax>=rect.left && sdword ptr eax<=rect.right && sdword ptr edx>=rect.top && sdword ptr edx<=rect.bottom
		mov		hCld,ebx
		mov		eax,TRUE
	.else
		xor		eax,eax
	.endif
	retn

GetCtrl:
	push	esi
	push	edi
	invoke GetWindowLong,hDEd,DEWM_MEMORY
	mov		esi,eax
	mov		edi,eax
	lea		esi,[esi+sizeof DLGHEAD]
	.while [esi].DIALOG.hwnd
		lea		esi,[esi+sizeof DIALOG]
	.endw
	lea		esi,[esi-sizeof DIALOG]
	.while esi>edi
		invoke GetCtrlID,esi
		.if eax
			invoke GetDlgItem,des.hdlg,eax
			mov		ebx,eax
		.else
			mov		ebx,des.hdlg
		.endif
		call	IsInWindow
		.break .if eax
		lea		esi,[esi-sizeof DIALOG]
	.endw
	pop		edi
	pop		esi
	retn

DrawMultisel:
	mov		eax,hMultiSel
  @@:
	push	eax
	invoke GetParent,eax
	push	eax
	mov		edx,eax
	invoke GetWindowRect,edx,addr rect
	mov		eax,pt.x
	sub		eax,MousePtDown.x
	add		rect.left,eax
	add		rect.right,eax
	mov		eax,pt.y
	sub		eax,MousePtDown.y
	add		rect.top,eax
	add		rect.bottom,eax
	invoke ScreenToClient,hInvisible,addr rect.left
	invoke ScreenToClient,hInvisible,addr rect.right
	call	DrawRect
	invoke GetParent,hMultiSel
	pop		edx
	.if eax==edx && des.fmode==MODE_MULTISELMOVE
		; *** MOD
		;invoke ConvertToDlgPt,addr rect.left
        invoke MapWindowPoints,hInvisible,des.hdlg,addr rect,2
		invoke DialogTltSize,rect.left,rect.top,rect.right,rect.bottom
	    ; =============
	.endif
	mov		ecx,8
	pop		eax
	.while ecx
		push	ecx
		invoke GetWindowLong,eax,GWL_USERDATA
		pop		ecx
		dec		ecx
	.endw
	or		eax,eax
	jne		@b
	retn

DrawRect:
	invoke GetDC,hWin
	mov		hDC,eax
	invoke GetStockObject,BLACK_BRUSH
	invoke FrameRect,hDC,addr rect,eax
	invoke ReleaseDC,hWin,hDC
	retn

DesignInvisibleProc endp

CopyCtl proc uses esi edi ebx
	LOCAL	hCtl:HWND

	.if hReSize
		invoke GetCtrlMem,hReSize
		.if eax
			mov		esi,eax
			mov		edi,offset dlgpaste
			mov		ecx,sizeof DIALOG
			rep	movsb
			xor		eax,eax
			stosd
		.endif
	.elseif hMultiSel
		mov		edi,offset dlgpaste
		mov		ebx,hMultiSel
		.while ebx
			invoke GetParent,ebx
			mov		hCtl,eax
			mov		eax,8
			.while eax
				push	eax
				invoke GetWindowLong,ebx,GWL_USERDATA
				mov		ebx,eax
				pop		eax
				dec		eax
			.endw
			invoke GetCtrlMem,hCtl
			.if eax
				mov		esi,eax
				mov		ecx,sizeof DIALOG
				rep	movsb
			.endif
		.endw
		xor		eax,eax
		stosd
	.endif
	invoke SendMessage,hDEd,WM_LBUTTONDOWN,0,0
	ret

CopyCtl endp

PasteCtl proc uses esi edi
	LOCAL	px:DWORD
	LOCAL	py:DWORD
	LOCAL	nbr:DWORD

	mov		nbr,0
	mov		esi,offset dlgpaste
	mov		px,9999
	mov		py,9999
	push	esi
  @@:
	mov		eax,[esi].DIALOG.hwnd
	.if eax
		mov		eax,[esi].DIALOG.dux
		.if (px<80000000 && eax<80000000 && eax<px) || (px>80000000 && eax>80000000 && eax<px) || (px<80000000 && eax>80000000)
			mov		px,eax
		.endif
		mov		eax,[esi].DIALOG.duy
		.if (py<80000000 && eax<80000000 && eax<py) || (py>80000000 && eax>80000000 && eax<py) || (py<80000000 && eax>80000000)
			mov		py,eax
		.endif
		add		esi,sizeof DIALOG
		jmp		@b
	.endif
	pop		esi
  @@:
	mov		eax,[esi].DIALOG.hwnd
	.if eax
		invoke GetWindowLong,hDEd,DEWM_MEMORY
		.if eax
			push	eax
			mov		edx,eax
			mov		edx,[edx].DLGHEAD.ctlid
			add		eax,sizeof DLGHEAD
			mov		[esi].DIALOG.id,edx
			invoke IsFreeID,edx
			.if eax==FALSE
				invoke GetFreeID
				mov		[esi].DIALOG.id,eax
			.endif
			pop		eax
			invoke GetFreeDlg,eax
			mov		edi,eax
			push	esi
			push	eax
			mov		ecx,sizeof DIALOG
			rep	movsb
			pop		esi
			mov		eax,px
			sub		[esi].DIALOG.dux,eax
			mov		eax,py
			sub		[esi].DIALOG.duy,eax
			xor		eax,eax
			mov		[esi].DIALOG.himg,eax
			invoke GetTypePtr,[esi].DIALOG.ntype
			invoke strcpyn,addr [esi].DIALOG.idname,(TYPES ptr [eax]).lpidname,MaxName
			invoke GetUnikeName,addr [esi].DIALOG.idname
			mov		[esi].DIALOG.tab,-1
			invoke GetFreeTab
			mov		[esi].DIALOG.tab,eax
			pop		esi
			add		esi,sizeof DIALOG
			inc		nbr
			jmp		@b
		.endif
	.endif
	.if nbr
		invoke DestroySizeingRect
		.while hMultiSel
			invoke DestroyMultiSel,hMultiSel
			mov		hMultiSel,eax
		.endw
		invoke GetWindowLong,hDEd,DEWM_MEMORY
		invoke MakeDialog,eax,-2
		invoke SetChanged,TRUE
		.if nbr>1
			.while nbr
				sub		edi,sizeof DIALOG
				invoke GetCtrlID,edi
				invoke GetDlgItem,des.hdlg,eax
				invoke CtlMultiSelect,eax
				dec		nbr
			.endw
		.else
			sub		edi,sizeof DIALOG
			invoke GetCtrlID,edi
			invoke GetDlgItem,des.hdlg,eax
			invoke SizeingRect,eax,FALSE
		.endif
		invoke NotifyParent
	.endif
	ret

PasteCtl endp

DeleteCtl proc uses esi
	LOCAL	hCtl:HWND

	.if hReSize
		invoke GetCtrlMem,hReSize
		.if eax
			mov		esi,eax
			mov		eax,[esi].DIALOG.ntype
			;Don't delete DialogBox
			.if eax
				mov		[esi].DIALOG.hwnd,-1
				invoke DeleteTab,[esi].DIALOG.tab
				invoke DestroySizeingRect
				invoke GetWindowLong,hDEd,DEWM_MEMORY
				invoke MakeDialog,eax,0
				invoke SetChanged,TRUE
			.endif
		.endif
	.elseif hMultiSel
		.while hMultiSel
			invoke GetParent,hMultiSel
			mov		hCtl,eax
			mov		eax,8
			.while eax
				push	eax
				invoke GetWindowLong,hMultiSel,GWL_USERDATA
				push	eax
				invoke DestroyWindow,hMultiSel
				pop		eax
				mov		hMultiSel,eax
				pop		eax
				dec		eax
			.endw
			invoke GetCtrlMem,hCtl
			.if eax
				mov		esi,eax
				mov		eax,[esi].DIALOG.ntype
				;Don't delete DialogBox
				.if eax
					mov		[esi].DIALOG.hwnd,-1
					invoke DeleteTab,[esi].DIALOG.tab
				.endif
			.endif
		.endw
		invoke GetWindowLong,hDEd,DEWM_MEMORY
		invoke MakeDialog,eax,0
		invoke SetChanged,TRUE
	.endif
	invoke NotifyParent
	ret

DeleteCtl endp

AlignSizeCtl proc uses esi ebx,nFun:DWORD
	LOCAL	xp:DWORD
	LOCAL	yp:DWORD
	LOCAL	wt:DWORD
	LOCAL	ht:DWORD
	LOCAL	hCtl:HWND
	LOCAL	fChanged:DWORD
	LOCAL	xpmin:DWORD
	LOCAL	ypmin:DWORD
	LOCAL	xpmax:DWORD
	LOCAL	ypmax:DWORD
	LOCAL	rect:RECT

	mov		ebx,hMultiSel
	.if ebx
		;Multi select
		mov		eax,nFun
		.if eax==ALIGN_DLGVCENTER || eax==ALIGN_DLGHCENTER
			mov		eax,99999
			mov		xpmin,eax
			mov		ypmin,eax
			neg		eax
			mov		xpmax,eax
			mov		ypmax,eax
			.while ebx
				invoke GetParent,ebx
				invoke GetCtrlMem,eax
				mov		esi,eax
				mov		eax,[esi].DIALOG.dux
				.if sdword ptr eax<xpmin
					mov		xpmin,eax
				.endif
				add		eax,[esi].DIALOG.duccx
				.if sdword ptr eax>xpmax
					mov		xpmax,eax
				.endif
				mov		eax,[esi].DIALOG.duy
				.if sdword ptr eax<ypmin
					mov		ypmin,eax
				.endif
				add		eax,[esi].DIALOG.duccy
				.if sdword ptr eax>ypmax
					mov		ypmax,eax
				.endif
				mov		ecx,8
				.while ecx
					push	ecx
					invoke GetWindowLong,ebx,GWL_USERDATA
					mov		ebx,eax
					pop		ecx
					dec		ecx
				.endw
			.endw
			invoke GetCtrlMem,des.hdlg
			mov		edx,[eax].DIALOG.duccx
			mov		rect.right,edx
			mov		edx,[eax].DIALOG.duccy
			mov		rect.bottom,edx
			mov		rect.left,0
			mov		rect.top,0
			mov		eax,xpmax
			sub		eax,xpmin
			mov		edx,rect.right
			sub		edx,eax
			shr		edx,1
			sub		xpmin,edx
			mov		eax,ypmax
			sub		eax,ypmin
			mov		edx,rect.bottom
			sub		edx,eax
			shr		edx,1
			sub		ypmin,edx
			mov		ebx,hMultiSel
			.while ebx
				mov		fChanged,FALSE
				invoke GetParent,ebx
				mov		hCtl,eax
				invoke GetCtrlMem,hCtl
				mov		esi,eax
				mov		eax,nFun
				.if eax==ALIGN_DLGVCENTER
					mov		eax,ypmin
					.if eax
						sub		[esi].DIALOG.duy,eax
						inc		fChanged
					.endif
				.elseif eax==ALIGN_DLGHCENTER
					mov		eax,xpmin
					.if eax
						sub		[esi].DIALOG.dux,eax
						inc		fChanged
					.endif
				.endif
				call	SnapGrid
				mov		ecx,8
				.while ecx
					push	ecx
					invoke GetWindowLong,ebx,GWL_USERDATA
					mov		ebx,eax
					pop		ecx
					dec		ecx
				.endw
			.endw
		.else
			invoke GetParent,ebx
			invoke GetCtrlMem,eax
			mov		esi,eax
			mov		eax,[esi].DIALOG.dux
			mov		xp,eax
			mov		eax,[esi].DIALOG.duy
			mov		yp,eax
			mov		eax,[esi].DIALOG.duccx
			mov		wt,eax
			mov		eax,[esi].DIALOG.duccy
			mov		ht,eax
			.while ebx
				mov		fChanged,FALSE
				invoke GetParent,ebx
				mov		hCtl,eax
				invoke GetCtrlMem,hCtl
				mov		esi,eax
				mov		eax,nFun
				.if eax==ALIGN_LEFT
					mov		eax,xp
					.if eax!=[esi].DIALOG.dux
						mov		[esi].DIALOG.dux,eax
						inc		fChanged
					.endif
				.elseif eax==ALIGN_CENTER
					mov		eax,wt
					shr		eax,1
					add		eax,xp
					mov		edx,[esi].DIALOG.duccx
					shr		edx,1
					add		edx,[esi].DIALOG.dux
					sub		eax,edx
					.if eax
						add		[esi].DIALOG.dux,eax
						inc		fChanged
					.endif
				.elseif eax==ALIGN_RIGHT
					mov		eax,xp
					add		eax,wt
					sub		eax,[esi].DIALOG.duccx
					.if eax!=[esi].DIALOG.dux
						mov		[esi].DIALOG.dux,eax
						inc		fChanged
					.endif
				.elseif eax==ALIGN_TOP
					mov		eax,yp
					.if eax!=[esi].DIALOG.duy
						mov		[esi].DIALOG.duy,eax
						inc		fChanged
					.endif
				.elseif eax==ALIGN_MIDDLE
					mov		eax,ht
					shr		eax,1
					add		eax,yp
					mov		edx,[esi].DIALOG.duccy
					shr		edx,1
					add		edx,[esi].DIALOG.duy
					sub		eax,edx
					.if eax
						add		[esi].DIALOG.duy,eax
						inc		fChanged
					.endif
				.elseif eax==ALIGN_BOTTOM
					mov		eax,yp
					add		eax,ht
					sub		eax,[esi].DIALOG.duccy
					.if eax!=[esi].DIALOG.duy
						mov		[esi].DIALOG.duy,eax
						inc		fChanged
					.endif
				.elseif eax==SIZE_WIDTH
					mov		eax,wt
					.if eax!=[esi].DIALOG.duccx
						mov		[esi].DIALOG.duccx,eax
						inc		fChanged
					.endif
				.elseif eax==SIZE_HEIGHT
					mov		eax,ht
					.if eax!=[esi].DIALOG.duccy
						mov		[esi].DIALOG.duccy,eax
						inc		fChanged
					.endif
				.elseif eax==SIZE_BOTH
					mov		eax,wt
					.if eax!=[esi].DIALOG.duccx
						mov		[esi].DIALOG.duccx,eax
						inc		fChanged
					.endif
					mov		eax,ht
					.if eax!=[esi].DIALOG.duccy
						mov		[esi].DIALOG.duccy,eax
						inc		fChanged
					.endif
				.endif
				call	SnapGrid
				mov		ecx,8
				.while ecx
					push	ecx
					invoke GetWindowLong,ebx,GWL_USERDATA
					mov		ebx,eax
					pop		ecx
					dec		ecx
				.endw
			.endw
		.endif
		invoke GetWindowLong,hDEd,DEWM_MEMORY
		invoke MakeDialog,eax,-1
		invoke SetChanged,TRUE
	.else
		mov		eax,nFun
		.if (eax==ALIGN_DLGVCENTER || eax==ALIGN_DLGHCENTER) && hReSize
			;Single select
			mov		eax,hReSize
			mov		hCtl,eax
			invoke GetCtrlMem,hCtl
			mov		esi,eax
			mov		eax,[esi].DIALOG.dux
			mov		xpmin,eax
			mov		eax,[esi].DIALOG.duy
			mov		ypmin,eax
			mov		eax,[esi].DIALOG.duccx
			add		eax,[esi].DIALOG.dux
			mov		xpmax,eax
			mov		eax,[esi].DIALOG.duccy
			add		eax,[esi].DIALOG.duy
			mov		ypmax,eax
			invoke GetCtrlMem,des.hdlg
			mov		edx,[eax].DIALOG.duccx
			mov		rect.right,edx
			mov		edx,[eax].DIALOG.duccy
			mov		rect.bottom,edx
			mov		rect.left,0
			mov		rect.top,0
			mov		eax,xpmax
			sub		eax,xpmin
			mov		edx,rect.right
			sub		edx,eax
			shr		edx,1
			sub		xpmin,edx
			mov		eax,ypmax
			sub		eax,ypmin
			mov		edx,rect.bottom
			sub		edx,eax
			shr		edx,1
			sub		ypmin,edx
			mov		eax,nFun
			.if eax==ALIGN_DLGVCENTER
				mov		eax,ypmin
				.if eax
					sub		[esi].DIALOG.duy,eax
					inc		fChanged
				.endif
			.elseif eax==ALIGN_DLGHCENTER
				mov		eax,xpmin
				.if eax
					sub		[esi].DIALOG.dux,eax
					inc		fChanged
				.endif
			.endif
			call	SnapGrid
			invoke GetWindowLong,hCtl,GWL_ID
			push	eax
			invoke GetWindowLong,hDEd,DEWM_MEMORY
			pop		edx
			invoke MakeDialog,eax,edx
			invoke SetChanged,TRUE
		.endif
	.endif
	invoke NotifyParent
	ret

SnapGrid:
retn
	call RSnapToGrid
	.if fRSnapToGrid
;		mov		eax,[esi].x
;		xor		edx,edx
;		idiv	Gridcx
;		imul	Gridcx
;		.if eax!=[esi].x
;			mov		[esi].x,eax
;			inc		fChanged
;		.endif
;		mov		eax,[esi].ccx
;		add		eax,[esi].x
;		xor		edx,edx
;		idiv	Gridcx
;		imul	Gridcx
;		sub		eax,[esi].x
;		inc		eax
;		.if eax!=[esi].ccx
;			mov		[esi].ccx,eax
;			inc		fChanged
;		.endif
;		mov		eax,[esi].y
;		xor		edx,edx
;		idiv	Gridcy
;		imul	Gridcy
;		.if eax!=[esi].y
;			mov		[esi].y,eax
;			inc		fChanged
;		.endif
;		mov		eax,[esi].ccy
;		add		eax,[esi].y
;		xor		edx,edx
;		idiv	Gridcy
;		imul	Gridcy
;		sub		eax,[esi].y
;		inc		eax
;		.if eax!=[esi].ccy
;			mov		[esi].ccy,eax
;			inc		fChanged
;		.endif
	.endif
	retn

AlignSizeCtl endp

MoveMultiSel proc uses esi,x:DWORD,y:DWORD

	mov		eax,hMultiSel
	.while eax
		push	eax
		invoke GetParent,eax
		invoke GetCtrlMem,eax
		mov		esi,eax
		.if x
			mov		eax,(DIALOG ptr [esi]).dux
			add		eax,x
			xor		edx,edx
			idiv	x
			imul	x
			mov		(DIALOG ptr [esi]).dux,eax
		.endif
		.if y
			mov		eax,(DIALOG ptr [esi]).duy
			add		eax,y
			xor		edx,edx
			idiv	y
			imul	y
			mov		(DIALOG ptr [esi]).duy,eax
		.endif
		mov		ecx,8
		pop		eax
		.while ecx
			push	ecx
			invoke GetWindowLong,eax,GWL_USERDATA
			pop		ecx
			dec		ecx
		.endw
	.endw
	invoke GetWindowLong,hDEd,DEWM_MEMORY
	invoke MakeDialog,eax,-1
	invoke SetChanged,TRUE
	invoke NotifyParent
	ret

MoveMultiSel endp

SizeMultiSel proc uses esi,x:DWORD,y:DWORD

	mov		eax,hMultiSel
	.while eax
		push	eax
		invoke GetParent,eax
		invoke GetCtrlMem,eax
		mov		esi,eax
		.if x
			mov		eax,(DIALOG ptr [esi]).duccx
			add		eax,x
			.if sdword ptr eax>0
				xor		edx,edx
				idiv	x
				imul	x
				mov		(DIALOG ptr [esi]).duccx,eax
			.endif
		.endif
		.if y
			mov		eax,(DIALOG ptr [esi]).duccy
			add		eax,y
			.if sdword ptr eax>0
				xor		edx,edx
				idiv	y
				imul	y
				mov		(DIALOG ptr [esi]).duccy,eax
			.endif
		.endif
		mov		ecx,8
		pop		eax
		.while ecx
			push	ecx
			invoke GetWindowLong,eax,GWL_USERDATA
			pop		ecx
			dec		ecx
		.endw
	.endw
	invoke GetWindowLong,hDEd,DEWM_MEMORY
	invoke MakeDialog,eax,-1
	invoke SetChanged,TRUE
	invoke NotifyParent
	ret

SizeMultiSel endp

AutoIDMultiSel proc uses esi
	LOCAL	MinID:DWORD
	LOCAL	MinTab:DWORD
	LOCAL	MaxTab:DWORD
	LOCAL	TabPtr:DWORD

	mov		eax,hMultiSel
	.if eax
		mov		MinID,7FFFFFFFh
		mov		MinTab,7FFFFFFFh
		.while eax
			push	eax
			invoke GetParent,eax
			invoke GetCtrlMem,eax
			mov		esi,eax
			mov		eax,(DIALOG ptr [esi]).id
			.if sdword ptr eax>0
				.if eax<MinID
					mov		MinID,eax
				.endif
			.endif
			mov		eax,(DIALOG ptr [esi]).tab
			.if eax<MinTab
				mov		MinTab,eax
			.endif
			mov		ecx,8
			pop		eax
			.while ecx
				push	ecx
				invoke GetWindowLong,eax,GWL_USERDATA
				pop		ecx
				dec		ecx
			.endw
		.endw
		invoke GetParent,hMultiSel
		invoke GetCtrlMem,eax
		mov		eax,(DIALOG ptr [eax]).id
		.if sdword ptr eax>0
			mov		MinID,eax
		.endif
		.while TRUE
			call	GetNextTab
			mov		esi,TabPtr
			.break .if !esi
			.if sdword ptr (DIALOG ptr [esi]).id>0
				mov		eax,MinID
				mov		(DIALOG ptr [esi]).id,eax
				inc		MinID
			.endif
			inc		MinTab
		.endw
		invoke SetChanged,TRUE
	.endif
	invoke GetWindowLong,hDEd,DEWM_MEMORY
	invoke UpdateRAEdit,eax
	invoke NotifyParent
	ret

GetNextTab:
	mov		MaxTab,7FFFFFFFh
	mov		TabPtr,0
	mov		eax,hMultiSel
	.while eax
		push	eax
		invoke GetParent,eax
		invoke GetCtrlMem,eax
		mov		esi,eax
		mov		eax,(DIALOG ptr [esi]).tab
		.if eax>=MinTab
			.if eax<MaxTab
				mov		MaxTab,eax
				mov		TabPtr,esi
			.endif
		.endif
		mov		ecx,8
		pop		eax
		.while ecx
			push	ecx
			invoke GetWindowLong,eax,GWL_USERDATA
			pop		ecx
			dec		ecx
		.endw
	.endw
	retn

AutoIDMultiSel endp

SendToBack proc uses esi edi,hCtl:HWND
	LOCAL	buffer[512]:BYTE
	LOCAL	lpSt:DWORD
	LOCAL	lpFirst:DWORD
	LOCAL	nID:DWORD

	invoke GetCtrlMem,hCtl
	mov		lpSt,eax
	mov		esi,eax
	invoke GetWindowLong,hDEd,DEWM_MEMORY
	add		eax,sizeof DLGHEAD+sizeof DIALOG
	.while [eax].DIALOG.hwnd==-1
		add		eax,sizeof DIALOG
	.endw
	.if [esi].DIALOG.ntype!=11
		.while ([eax].DIALOG.ntype==3 || [eax].DIALOG.ntype==11 || [eax].DIALOG.hwnd==-1) && [eax].DIALOG.hwnd
			add		eax,sizeof DIALOG
		.endw
	.endif
	mov		lpFirst,eax
	.if eax<lpSt
		lea		edi,buffer
		mov		ecx,sizeof DIALOG
		rep movsb
		mov		esi,lpSt
	  @@:
		mov		edi,esi
		mov		ecx,sizeof DIALOG
		sub		esi,ecx
		rep movsb
		sub		esi,sizeof DIALOG
		cmp		esi,lpFirst
		jge		@b
		invoke GetCtrlID,lpFirst
		mov		nID,eax
		lea		esi,buffer
		mov		edi,lpFirst
		mov		ecx,sizeof DIALOG
		rep movsb
		invoke GetWindowLong,hDEd,DEWM_MEMORY
		mov		esi,eax
		invoke MakeDialog,esi,nID
	.endif
	ret

SendToBack endp

BringToFront proc uses esi edi,hCtl:HWND
	LOCAL	buffer[512]:BYTE
	LOCAL	lpSt:DWORD
	LOCAL	nID:DWORD

	invoke GetCtrlMem,hCtl
	mov		lpSt,eax
	mov		esi,eax
	lea		edi,buffer
	mov		ecx,sizeof DIALOG
	rep movsb
	mov		edi,esi
	sub		edi,sizeof DIALOG
  @@:
	mov		ecx,sizeof DIALOG
	rep movsb
	mov		eax,dword ptr [esi]
	or		eax,eax
	jne		@b
	invoke GetCtrlID,edi
	mov		nID,eax
	lea		esi,buffer
	mov		ecx,sizeof DIALOG
	rep movsb
	invoke GetWindowLong,hDEd,DEWM_MEMORY
	mov		esi,eax
	invoke MakeDialog,esi,nID
	ret

BringToFront endp

GetMnuString proc uses ebx esi edi,lpName:DWORD,lpBuff:DWORD

	invoke GetWindowLong,hPrj,0
	mov		esi,eax
	mov		edi,lpName
	xor		ebx,ebx
	.if byte ptr [edi]>='0' && byte ptr [edi]<='9'
		invoke ResEdDecToBin,edi
		mov		ebx,eax
	.endif
	.while [esi].PROJECT.hmem
		.if [esi].PROJECT.ntype==TPE_MENU
			mov		edx,[esi].PROJECT.hmem
			.if ebx
				cmp		ebx,[edx].MNUHEAD.menuid
				.break .if ZERO?
			.else
				invoke strcmp,lpName,addr [edx].MNUHEAD.menuname
				.break .if !eax
			.endif
		.endif
		lea		esi,[esi+sizeof PROJECT]
	.endw
	.if [esi].PROJECT.ntype==TPE_MENU
		mov		esi,[esi].PROJECT.hmem
		push	esi
		mov		edi,lpBuff
		mov		byte ptr [edi],0
		add		esi,sizeof MNUHEAD
	  @@:
		mov		eax,(MNUITEM ptr [esi]).itemflag
		.if eax
			.if eax!=-1
				mov		eax,(MNUITEM ptr [esi]).level
				.if !eax
					.if edi!=lpBuff
						mov		byte ptr [edi],','
						inc		edi
					.endif
					mov		byte ptr [edi],' '
					inc		edi
					mov		byte ptr [edi],' '
					inc		edi
					invoke strcpy,edi,addr (MNUITEM ptr [esi]).itemcaption
					invoke strlen,edi
					add		edi,eax
					mov		byte ptr [edi],' '
					inc		edi
					mov		byte ptr [edi],' '
					inc		edi
					mov		byte ptr [edi],0
				.endif
			.endif
			add		esi,sizeof MNUITEM
			jmp		@b
		.endif
		pop		eax
	.else
		invoke strcpy,lpBuff,addr szMnu
		xor		eax,eax
	.endif
	ret

GetMnuString endp

TestProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT
	LOCAL	fnt:LOGFONT

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke GetClientRect,hWin,addr rect
		push	rect.right
		pop		fntwt
		push	rect.bottom
		pop		fntht
		invoke SendMessage,hWin,WM_GETFONT,0,0
		mov		edx,eax
		invoke GetObject,edx,sizeof LOGFONT,addr fnt
		mov		eax,fnt.lfHeight
		mov		lfntht,eax
		mov		eax,FALSE
		ret
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

TestProc endp

DlgResize proc uses esi edi,hMem:DWORD,lpOldFont:DWORD,nOldSize:DWORD,lpNewFont:DWORD,nNewSize:DWORD

	mov		eax,nOldSize
	mov		dlgps,ax
	invoke ConvFontToUnicode,offset dlgfn,lpOldFont
	invoke CreateDialogIndirectParam,hInstance,offset dlgdata,hDEd,offset TestProc,0
	invoke DestroyWindow,eax
	push	fntwt
	pop		dfntwt
	push	fntht
	pop		dfntht
	mov		eax,nNewSize
	mov		dlgps,ax
	invoke ConvFontToUnicode,offset dlgfn,lpNewFont
	invoke CreateDialogIndirectParam,hInstance,offset dlgdata,hDEd,offset TestProc,0
	invoke DestroyWindow,eax
	mov		esi,hMem
	add		esi,sizeof DLGHEAD
	mov		edi,esi
	.while [esi].DIALOG.hwnd
		.if [esi].DIALOG.hwnd!=-1
			; Dont move dialog
			.if edi!=esi
				mov		eax,[esi].DIALOG.dux
				call	getx
				.if fSnapToGrid
					xor		edx,edx
					idiv	Gridcx
					imul	Gridcx
				.endif
				mov		[esi].DIALOG.dux,eax
				mov		eax,[esi].DIALOG.duy
				call	gety
				.if fSnapToGrid
					xor		edx,edx
					idiv	Gridcy
					imul	Gridcy
				.endif
				mov		[esi].DIALOG.duy,eax
			.endif
			mov		eax,[esi].DIALOG.duccx
			call	getx
			.if fSnapToGrid
				xor		edx,edx
				idiv	Gridcx
				imul	Gridcx
				;inc		eax
			.endif
			mov		[esi].DIALOG.duccx,eax
			mov		eax,[esi].DIALOG.duccy
			call	gety
			.if fSnapToGrid
				xor		edx,edx
				idiv	Gridcy
				imul	Gridcy
				;inc		eax
			.endif
			mov		[esi].DIALOG.duccy,eax
		.endif
		add		esi,sizeof DIALOG
	.endw
	ret

getx:
	.if sdword ptr eax<0
		neg		eax
		shl		eax,1
		imul	dfntwt
		xor		edx,edx
		idiv	fntwt
		shr		eax,1
;		adc		eax,0
		neg		eax
	.else
		shl		eax,1
		imul	dfntwt
		xor		edx,edx
		idiv	fntwt
		shr		eax,1
;		adc		eax,0
	.endif
	retn

gety:
	.if sdword ptr eax<0
		neg		eax
		shl		eax,1
		imul	dfntht
		xor		edx,edx
		idiv	fntht
		shr		eax,1
;		adc		eax,0
		neg		eax
	.else
		shl		eax,1
		imul	dfntht
		xor		edx,edx
		idiv	fntht
		shr		eax,1
;		adc		eax,0
	.endif
	retn

DlgResize endp

GetType proc uses ebx esi,lpDlg:DWORD

	mov		esi,lpDlg
	mov		eax,[esi].DIALOG.ntypeid
	.if eax
		mov		ebx,offset ctltypes
		xor		ecx,ecx
		.while ecx<nButtons
			.if eax==[ebx].TYPES.ID
				mov		[esi].DIALOG.ntype,ecx
				xor		eax,eax
				.break
			.endif
			add		ebx,sizeof TYPES
			inc		ecx
		.endw
		.if eax
			mov		[esi].DIALOG.ntype,2
			mov		[esi].DIALOG.ntypeid,2
		.endif
	.else
		mov		eax,[esi].DIALOG.ntype
		mov		[esi].DIALOG.ntypeid,eax
		xor		eax,eax
	.endif
	ret

GetType endp

UpdateRAEdit proc uses ebx esi edi,hMem:DWORD

	mov		ebx,hMem
	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,256*1024
	mov		edi,eax
	invoke ExportDialogNames,ebx
	mov		esi,eax
	invoke strcpy,edi,esi
	invoke GlobalUnlock,esi
	invoke GlobalFree,esi
	invoke ExportDialog,ebx
	mov		esi,eax
	invoke strcat,edi,esi
	invoke GlobalUnlock,esi
	invoke GlobalFree,esi
	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,256*1024
	mov		esi,eax
	invoke SaveToMem,[ebx].DLGHEAD.hred,esi
	invoke strcmp,esi,edi
	.if eax
		invoke SendMessage,[ebx].DLGHEAD.hred,REM_LOCKUNDOID,TRUE,0
		invoke SendMessage,[ebx].DLGHEAD.hred,EM_SETSEL,0,-1
		invoke SendMessage,[ebx].DLGHEAD.hred,EM_REPLACESEL,TRUE,edi
		invoke SendMessage,[ebx].DLGHEAD.hred,REM_LOCKUNDOID,FALSE,0
	.endif
	invoke GlobalFree,esi
	invoke GlobalFree,edi
	ret

UpdateRAEdit endp

CloseDialog proc uses esi

	invoke GetWindowLong,hDEd,DEWM_MEMORY
	.if eax
		mov		esi,eax
		.if [esi].DLGHEAD.ftextmode
			invoke ShowWindow,[esi].DLGHEAD.hred,SW_HIDE
		.else
			invoke DestroySizeingRect
			.while hMultiSel
				invoke DestroyMultiSel,hMultiSel
				mov		hMultiSel,eax
			.endw
		.endif
		invoke GetWindowLong,hDEd,DEWM_DIALOG
		invoke DestroyWindow,eax
		mov		des.hdlg,0
		invoke SetWindowLong,hDEd,DEWM_MEMORY,0
		invoke SetWindowLong,hDEd,DEWM_DIALOG,0
		invoke SetWindowLong,hDEd,DEWM_PROJECT,0
		invoke ShowWindow,hInvisible,SW_HIDE
		.if hTabSet
			invoke DestroyWindow,hTabSet
			mov		hTabSet,0
		.endif
	.elseif hDialog
		invoke SendMessage,hDialog,WM_COMMAND,BN_CLICKED shl 16 or IDOK,0
		invoke SendMessage,hDialog,WM_COMMAND,BN_CLICKED shl 16 or IDCANCEL,0
		mov		hDialog,0
	.endif
	ret

CloseDialog endp

GetMnuName proc uses ebx esi,lpDlgMem:DWORD,nid:DWORD

	mov		esi,lpDlgMem
	mov		eax,[esi].DLGHEAD.lpmnu
	.if eax
		mov		esi,eax
		add		esi,sizeof MNUHEAD
	  @@:
		mov		eax,(MNUITEM ptr [esi]).itemflag
		.if eax
			.if eax!=-1
				mov		eax,(MNUITEM ptr [esi]).itemid
				.if eax==nid
					lea		eax,(MNUITEM ptr [esi]).itemname
					jmp		Ex
				.endif
			.endif
			add		esi,sizeof MNUITEM
			jmp		@b
		.endif
	.endif
	xor		eax,eax
  Ex:
	ret

GetMnuName endp

MakeDlgProc proc uses esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT
	LOCAL	dblclk:CTLDBLCLICK

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke GetWindowRect,hWin,addr rect
		invoke GetWindowLong,hDEd,DEWM_MEMORY
		.if [eax].DLGHEAD.menuid
			invoke GetSystemMetrics,SM_CYMENU
			add		rect.bottom,eax
		.endif
		invoke GetWindowLong,hDEd,DEWM_SCROLLY
		push	eax
		invoke GetWindowLong,hDEd,DEWM_SCROLLX
		shl		eax,3
		neg		eax
		add		eax,DlgX
		pop		edx
		shl		edx,3
		neg		edx
		add		edx,DlgY
		mov		ecx,rect.bottom
		sub		ecx,rect.top
		mov		rect.bottom,ecx
		mov		ecx,rect.left
		sub		rect.right,ecx
		invoke SetWindowPos,hWin,0,eax,edx,rect.right,rect.bottom,SWP_NOZORDER
		invoke EnumChildWindows,hWin,addr DlgEnumProc,hWin
		mov		eax,FALSE
		ret
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if !edx
			push	ebx
			mov		eax,hRes
			mov		dblclk.nmhdr.hwndFrom,eax
			invoke GetWindowLong,hRes,GWL_ID
			push	eax
			mov		dblclk.nmhdr.idFrom,eax
			mov		dblclk.nmhdr.code,NM_CLICK
			mov		eax,wParam
			mov		dblclk.nCtlId,eax
			push	eax
			invoke GetWindowLong,hDEd,DEWM_MEMORY
			pop		edx
			invoke GetMnuName,eax,edx
			mov		dblclk.lpCtlName,eax
			invoke GetCtrlMem,des.hdlg
			mov		edx,eax
			mov		dblclk.lpDlgMem,edx
			mov		eax,[edx].DIALOG.id
			mov		dblclk.nDlgId,eax
			lea		eax,[edx].DIALOG.idname
			mov		dblclk.lpDlgName,eax
			invoke GetParent,hRes
			pop		edx
			mov		ecx,eax
			invoke SendMessage,ecx,WM_NOTIFY,edx,addr dblclk
			pop		ebx
		.endif
	.elseif eax==WM_DRAWITEM
		mov		esi,lParam
		invoke GetStockObject,GRAY_BRUSH
		invoke FillRect,[esi].DRAWITEMSTRUCT.hdc,addr [esi].DRAWITEMSTRUCT.rcItem,eax
		xor		eax,eax
		inc		eax
		ret
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

MakeDlgProc endp

MakeDlgClassProc proc uses ebx,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[512]:BYTE
	LOCAL	buffer1[128]:BYTE
	LOCAL	rect:RECT
	LOCAL	rect1:RECT
	LOCAL	rect2:RECT
	LOCAL	hDC:HDC
	LOCAL	mDC:HDC
	LOCAL	nInx:DWORD
	LOCAL	pt:POINT
	LOCAL	fMnu:DWORD

	mov		eax,uMsg
	.if eax==WM_NCCALCSIZE
		invoke GetWindowLong,hDEd,DEWM_MEMORY
		.if [eax].DLGHEAD.menuid
			mov		ebx,lParam
			invoke GetSystemMetrics,SM_CYMENU
			add		[ebx].NCCALCSIZE_PARAMS.rgrc.top,eax
			.if !wParam
				add		[ebx].NCCALCSIZE_PARAMS.rgrc.bottom,eax
			.endif
		.endif
	.elseif eax==WM_CREATE
		.if hGridBr
			invoke DeleteObject,hGridBr
			mov		hGridBr,0
		.endif
		invoke CreateGridBrush,hWin
	.elseif eax==WM_NCPAINT
		xor		eax,eax
		mov		des.mnurect.left,eax
		mov		des.mnurect.top,eax
		mov		des.mnurect.right,eax
		mov		des.mnurect.bottom,eax
		mov		rect1.left,eax
		mov		rect1.top,eax
		mov		rect1.right,eax
		mov		rect1.bottom,eax
		mov		nInx,eax
		mov		des.nmnu,eax
		mov		fMnu,eax
		mov		rect2.left,eax
		mov		rect2.top,eax
		invoke GetWindowLong,hDEd,DEWM_MEMORY
		mov		ebx,eax
		.if [ebx].DLGHEAD.menuid
			invoke GetMnuString,addr [ebx].DLGHEAD.menuid,addr buffer
			mov		[ebx].DLGHEAD.lpmnu,eax
			invoke GetWindowDC,hWin
			mov		hDC,eax
			invoke CreateCompatibleDC,hDC
			mov		mDC,eax
			invoke GetWindowLong,hWin,GWL_STYLE
			push	eax
			invoke GetWindowLong,hWin,GWL_EXSTYLE
			pop		edx
			invoke AdjustWindowRectEx,addr rect1,edx,FALSE,eax
			invoke GetWindowRect,hWin,addr rect
			mov		eax,rect.left
			sub		rect.right,eax
			mov		rect.left,0
			mov		eax,rect.top
			sub		rect.bottom,eax
			mov		rect.top,0
			mov		eax,rect1.left
			sub		rect.left,eax
			mov		eax,rect1.right
			sub		rect.right,eax
			mov		eax,rect1.top
			sub		rect.top,eax
			mov		eax,rect1.bottom
			sub		rect.bottom,eax
			invoke GetSystemMetrics,SM_CYMENU
			add		eax,rect.top
			.if eax<rect.bottom
				mov		rect.bottom,eax
			.endif
			invoke CopyRect,addr des.mnurect,addr rect
			mov		eax,rect.right
			sub		eax,rect.left
			mov		rect2.right,eax
			mov		edx,rect.bottom
			sub		edx,rect.top
			mov		rect2.bottom,edx
			invoke CreateCompatibleBitmap,hDC,eax,edx
			invoke SelectObject,mDC,eax
			push	eax
			invoke FillRect,mDC,addr rect2,COLOR_BTNFACE+1
			invoke SetBkMode,mDC,TRANSPARENT
			invoke SelectObject,mDC,hMnuFont
			push	eax
			mov		eax,rect2.left
			mov		rect2.right,eax
		  @@:
			invoke GetStrItem,addr buffer,addr buffer1
			.if buffer1
				inc		nInx
				xor		eax,eax
				mov		rect1.left,eax
				mov		rect1.top,eax
				mov		rect1.right,eax
				mov		rect1.bottom,eax
				invoke DrawText,mDC,addr buffer1,-1,addr rect1,DT_SINGLELINE or DT_CALCRECT
				mov		eax,rect2.right
				mov		rect2.left,eax
				mov		eax,rect1.right
				add		rect2.right,eax
				invoke DrawText,mDC,addr buffer1,-1,addr rect2,DT_SINGLELINE
				mov		eax,des.dlgpt.x
				sub		eax,des.mnurect.left
				mov		edx,des.dlgpt.y
				sub		edx,des.mnurect.top
				.if eax>=rect2.left && eax<=rect2.right && edx>=rect2.top && edx<=rect2.bottom
					mov		eax,nInx
					mov		des.nmnu,eax
					dec		rect2.bottom
					invoke GetSystemMetrics,SM_SWAPBUTTON
					.if eax
						mov		eax,VK_RBUTTON
					.else
						mov		eax,VK_LBUTTON
					.endif
					invoke GetAsyncKeyState,eax
					and		eax,8000h
					push	eax
					.if eax
						mov		eax,BDR_SUNKENOUTER
					.else
						mov		eax,BDR_RAISEDINNER
					.endif
					invoke DrawEdge,mDC,addr rect2,eax,BF_RECT
					pop		edx
					mov		eax,[ebx].DLGHEAD.lpmnu
					.if eax && edx
						mov		eax,nInx
						mov		fMnu,eax
						invoke GetWindowRect,hWin,addr rect1
						mov		eax,rect1.left
						add		eax,rect.left
						add		eax,rect2.left
						mov		pt.x,eax
						mov		eax,rect1.top
						add		eax,rect.bottom
						dec		eax
						mov		pt.y,eax
					.endif
					inc		rect2.bottom
				.endif
				jmp		@b
			.endif
			mov		eax,rect.right
			sub		eax,rect.left
			mov		edx,rect.bottom
			sub		edx,rect.top
			invoke BitBlt,hDC,rect.left,rect.top,eax,edx,mDC,0,0,SRCCOPY
			pop		eax
			invoke SelectObject,mDC,eax
			pop		eax
			invoke SelectObject,mDC,eax
			invoke DeleteObject,eax
			invoke DeleteDC,mDC
			invoke ReleaseDC,hWin,hDC
			.if fMnu
				mov		eax,[ebx].DLGHEAD.lpmnu
				add		eax,sizeof MNUHEAD
				invoke CreateSubMenu,eax,fMnu
				.if eax
					.if des.hmnu
						push	eax
						invoke DestroyMenu,des.hmnu
						mov		des.hmnu,0
						pop		eax
					.endif
					mov		des.hmnu,eax
					invoke TrackPopupMenu,des.hmnu,TPM_LEFTALIGN or TPM_LEFTBUTTON,pt.x,pt.y,0,hWin,0
				.endif
			.endif
		.endif
	.elseif eax==WM_NCMOUSEMOVE
		invoke SetWindowPos,hWin,0,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER or SWP_FRAMECHANGED
		invoke UpdateWindow,hWin
	.elseif eax==WM_EXITMENULOOP
		.if des.hmnu
			invoke DestroyMenu,des.hmnu
		.endif
		xor		eax,eax
		mov		des.hmnu,eax
		mov		des.dlgpt.x,eax
		mov		des.dlgpt.y,eax
		invoke SetWindowPos,hWin,0,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER or SWP_FRAMECHANGED
		invoke UpdateWindow,hWin
	.elseif eax==WM_ERASEBKGND
		.if fGrid
			invoke GetClientRect,hWin,addr rect
			invoke FillRect,wParam,addr rect,hGridBr
			xor		eax,eax
			ret
		.endif
	.endif
	invoke DefDlgProc,hWin,uMsg,wParam,lParam
	ret

MakeDlgClassProc endp

MakeDialog proc uses esi edi ebx,hMem:DWORD,nSelID:DWORD
	LOCAL	nInx:DWORD
	LOCAL	hDlg:HWND
	LOCAL	racol:RACOLOR
	LOCAL	buffer[MaxCap]:BYTE

	;Get convertiion
	mov		dlgps,10
	mov		dlgfn,0
	invoke CreateDialogIndirectParam,hInstance,offset dlgdata,hDEd,offset TestProc,0
	invoke DestroyWindow,eax
	mov		eax,fntwt
	mov		dfntwt,eax
	mov		eax,fntht
	mov		dfntht,eax
	mov		esi,hMem
	mov		eax,[esi].DLGHEAD.fontsize
	mov		dlgps,ax
	invoke ConvFontToUnicode,offset dlgfn,addr [esi].DLGHEAD.font
	invoke CreateDialogIndirectParam,hInstance,offset dlgdata,hDEd,offset TestProc,0
	invoke DestroyWindow,eax
	.if nSelID==-1
		push	0
		mov		ebx,hMultiSel
	  @@:
		invoke GetParent,ebx
		invoke GetWindowLong,eax,GWL_ID
		push	eax
		mov		ecx,8
		.while ecx
			push	ecx
			invoke GetWindowLong,ebx,GWL_USERDATA
			mov		ebx,eax
			pop		ecx
			dec		ecx
		.endw
		or		ebx,ebx
		jne		@b
		.while hMultiSel
			invoke DestroyMultiSel,hMultiSel
			mov		hMultiSel,eax
		.endw
	.endif
	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,128*1024
	mov		ebx,eax
	push	eax
	mov		[ebx].MyDLGTEMPLATEEX.dlgVer,1
	mov		[ebx].MyDLGTEMPLATEEX.signature,-1
	mov		[ebx].MyDLGTEMPLATEEX.helpID,0
	mov		esi,hMem
	mov		edi,esi
	add		esi,sizeof DLGHEAD
	mov		eax,[esi].DIALOG.style
	.if byte ptr [edi].DLGHEAD.font
		or		eax,DS_SETFONT
	.endif
	or		eax,WS_ALWAYS or DS_NOFAILCREATE
	and		eax,-1 xor (WS_POPUP or WS_DISABLED or WS_MINIMIZE or WS_MAXIMIZE or WS_CLIPCHILDREN or WS_CLIPSIBLINGS)
	mov		[ebx].MyDLGTEMPLATEEX.style,eax
	push	eax
	mov		eax,[esi].DIALOG.exstyle
	and		eax,0F7FFFh
	and		eax,-1 xor (WS_EX_LAYERED or WS_EX_TRANSPARENT or WS_EX_MDICHILD)
	mov		[ebx].MyDLGTEMPLATEEX.exStyle,eax
	push	esi
	mov		ecx,-1
	.while [esi].DIALOG.hwnd
		.if [esi].DIALOG.hwnd!=-1
			inc		ecx
		.endif
		add		esi,sizeof DIALOG
	.endw
	pop		esi
	mov		[ebx].MyDLGTEMPLATEEX.cDlgItems,cx
	mov		[ebx].MyDLGTEMPLATEEX.x,0
	mov		[ebx].MyDLGTEMPLATEEX.y,0
	mov		eax,[esi].DIALOG.duccx
	mov		[ebx].MyDLGTEMPLATEEX.ccx,ax
	mov		eax,[esi].DIALOG.duccy
	mov		[ebx].MyDLGTEMPLATEEX.ccy,ax
	mov		[ebx].MyDLGTEMPLATEEX.menu,0
	add		ebx,sizeof MyDLGTEMPLATEEX
	;Class
	invoke SaveWideChar,addr szDlgChildClass,ebx
	add		ebx,eax
	;Caption
	invoke ConvertCaption,addr buffer,addr [esi].DIALOG.caption
	invoke SaveWideChar,addr buffer,ebx
	add		ebx,eax
	pop		eax
	test	eax,DS_SETFONT
	.if !ZERO?
		;Fontsize
		mov		eax,[edi].DLGHEAD.fontsize
		mov		[ebx],ax
		add		ebx,2
		;Weight
		mov		word ptr [ebx],0
		add		ebx,2
		;Italics
		mov		byte ptr [ebx],0
		add		ebx,1
		;Charset
		mov		byte ptr [ebx],0
		add		ebx,1
		;Facename
		invoke SaveWideChar,addr [edi].DLGHEAD.font,ebx
		add		ebx,eax
	.endif
	add		esi,sizeof DIALOG
	mov		edi,esi
	mov		nInx,0
	.while [edi].DIALOG.hwnd
		inc		nInx
		add		edi,sizeof DIALOG
	.endw
	.if nInx
	  @@:
		sub		edi,sizeof DIALOG
		add		ebx,2
		and		ebx,0FFFFFFFCh
		.if [edi].DIALOG.hwnd
			.if [edi].DIALOG.hwnd!=-1
				mov		[ebx].MyDLGITEMTEMPLATEEX.helpID,0
				mov		eax,[edi].DIALOG.style
				or		eax,WS_ALWAYS
				and		eax,-1 xor (WS_POPUP or WS_DISABLED or WS_MINIMIZE or WS_MAXIMIZE or WS_CLIPCHILDREN or WS_CLIPSIBLINGS)
				.if [edi].DIALOG.ntype==14
					or		eax,LVS_SHAREIMAGELISTS
				.elseif [edi].DIALOG.ntype==16
					and		eax,(-1 xor UDS_AUTOBUDDY)
				.endif
				mov		[ebx].MyDLGITEMTEMPLATEEX.style,eax
				mov		eax,[edi].DIALOG.exstyle
				and		eax,0F7FFFh
				and		eax,-1 xor (WS_EX_LAYERED or WS_EX_TRANSPARENT or WS_EX_MDICHILD)
				mov		[ebx].MyDLGITEMTEMPLATEEX.exStyle,eax
				mov		eax,[edi].DIALOG.dux
				mov		[ebx].MyDLGITEMTEMPLATEEX.x,ax
				mov		eax,[edi].DIALOG.duy
				mov		[ebx].MyDLGITEMTEMPLATEEX.y,ax
				mov		eax,[edi].DIALOG.duccx
				mov		[ebx].MyDLGITEMTEMPLATEEX.ccx,ax
				mov		eax,[edi].DIALOG.duccy
				mov		[ebx].MyDLGITEMTEMPLATEEX.ccy,ax
				mov		eax,nInx
				mov		[ebx].MyDLGITEMTEMPLATEEX.id,eax
				add		ebx,sizeof MyDLGITEMTEMPLATEEX
				;Class
				mov		eax,[edi].DIALOG.ntype
				mov		edx,sizeof TYPES
				mul		edx
				add		eax,offset ctltypes
				invoke SaveWideChar,[eax].TYPES.lpclass,ebx
				add		ebx,eax
				;Caption
				invoke ConvertCaption,addr buffer,addr [edi].DIALOG.caption
				invoke SaveWideChar,addr buffer,ebx
				add		ebx,eax
				mov		word ptr [ebx],0
				add		ebx,2
			.endif
			dec		nInx
			jne		@b
		.endif
	.endif
	pop		ebx
	invoke GetWindowLong,hDEd,DEWM_DIALOG
	.if eax
		invoke DestroyWindow,eax
	.endif
	invoke SetWindowLong,hDEd,DEWM_MEMORY,hMem
	invoke CreateDialogIndirectParam,hInstance,ebx,hDEd,offset MakeDlgProc,0
	mov		hDlg,eax
	mov		des.hdlg,eax
	invoke SetWindowLong,hDEd,DEWM_DIALOG,hDlg
	invoke GlobalFree,ebx
	mov		esi,hMem
	invoke SetWindowLong,hDlg,GWL_ID,0
	invoke SendMessage,hDlg,WM_NCACTIVATE,1,0
	.if nSelID==-1
		.while TRUE
			pop		eax
			.break .if !eax
			invoke GetDlgItem,hDlg,eax
			invoke CtlMultiSelect,eax
		.endw
	.else
		.if nSelID
			invoke GetDlgItem,hDlg,nSelID
		.else
			mov		eax,hDlg
		.endif
		invoke SizeingRect,eax,FALSE
	.endif
	mov		esi,hMem
	lea		esi,[esi+sizeof DLGHEAD+sizeof DIALOG]
	xor		ebx,ebx
	.while [esi].DIALOG.hwnd
		inc		ebx
		.if [esi].DIALOG.hwnd!=-1
			invoke GetDlgItem,des.hdlg,ebx
			.if eax
				invoke SetWindowPos,eax,HWND_BOTTOM,0,0,0,0,SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE
			.endif
		.endif
		add		esi,sizeof DIALOG
	.endw
	invoke SetWindowPos,hInvisible,HWND_TOP,0,0,0,0,SWP_NOACTIVATE or SWP_SHOWWINDOW or SWP_NOMOVE or SWP_NOSIZE
	invoke InvalidateRect,hDEd,NULL,TRUE
	invoke UpdateWindow,hDEd
	mov		esi,hMem
	.if ![esi].DLGHEAD.hred
		invoke CreateWindowEx,200h,addr szRAEditClass,0,WS_CHILD or STYLE_NOSIZEGRIP or STYLE_NOCOLLAPSE,0,0,0,0,hRes,0,hInstance,0
		mov		[esi].DLGHEAD.hred,eax
		invoke SendMessage,[esi].DLGHEAD.hred,WM_SETFONT,hredfont,0
		invoke SendMessage,[esi].DLGHEAD.hred,REM_GETCOLOR,0,addr racol
		mov		eax,color.back
		mov		racol.bckcol,eax
		mov		racol.cmntback,eax
		mov		racol.strback,eax
		mov		racol.oprback,eax
		mov		racol.numback,eax
		mov		eax,color.text
		mov		racol.txtcol,eax
		mov		racol.strcol,0
		invoke SendMessage,[esi].DLGHEAD.hred,REM_SETCOLOR,0,addr racol
		invoke SendMessage,[esi].DLGHEAD.hred,REM_SETWORDGROUP,0,2
		invoke UpdateRAEdit,esi
		invoke SendMessage,[esi].DLGHEAD.hred,EM_EMPTYUNDOBUFFER,0,0
	.else
		invoke UpdateRAEdit,esi
	.endif
	mov		eax,hDlg
	mov		des.hdlg,eax
	ret

MakeDialog endp

CreateDlg proc uses esi edi,lpProItemMem:DWORD

	invoke CloseDialog
	mov		esi,lpProItemMem
	invoke SetWindowLong,hDEd,DEWM_PROJECT,esi
	mov		eax,(PROJECT ptr [esi]).hmem
	.if !eax
		;Create new dlg
		invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,MaxMem
		mov		esi,eax
		invoke GlobalLock,esi
		invoke SetWindowLong,hDEd,DEWM_MEMORY,esi
		invoke CreateNewCtl,hDEd,0,DlgX,DlgY,150,100
	.else
		;Create existing dlg
		mov		esi,eax
		push	esi
		add		esi,sizeof DLGHEAD
		.while [esi].DIALOG.hwnd
			mov		eax,[esi].DIALOG.ntype
			invoke GetTypePtr,eax
			mov		eax,[eax].TYPES.ID
			mov		[esi].DIALOG.ntypeid,eax
			add		esi,sizeof DIALOG
		.endw
		pop		esi
		invoke MakeDialog,esi,0
	.endif
	invoke ShowWindow,hDEd,SW_SHOWNA
	mov		eax,esi
	ret

CreateDlg endp

UndoRedo proc uses ebx esi edi,fRedo:DWORD

	invoke GetWindowLong,hDEd,DEWM_MEMORY
	.if eax
		mov		ebx,eax
		.if [ebx].DLGHEAD.hred
			.if fRedo!=-1
				mov		edx,EM_UNDO
				.if fRedo
					mov		edx,EM_REDO
				.endif
				invoke SendMessage,[ebx].DLGHEAD.hred,edx,0,0
				invoke SendMessage,[ebx].DLGHEAD.hred,EM_SETSEL,0,0
			.endif
			invoke GetWindowLong,hPrj,0
			mov		esi,eax
			invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,256*1024
			mov		edi,eax
			invoke SaveToMem,[ebx].DLGHEAD.hred,edi
			.while ebx!=[esi].PROJECT.hmem
				add		esi,sizeof PROJECT
			.endw
			mov		[esi].PROJECT.hmem,0
			push	[ebx].DLGHEAD.hred
			push	[ebx].DLGHEAD.ftextmode
			invoke GetWindowLong,hPrj,0
			invoke ParseRCMem,edi,eax
			.if fParseError
				.if [esi].PROJECT.hmem
					invoke GlobalUnlock,[esi].PROJECT.hmem
					invoke GlobalFree,[esi].PROJECT.hmem
				.endif
				mov		[esi].PROJECT.hmem,ebx
				pop		eax
				pop		eax
			.else
				mov		eax,[esi].PROJECT.hmem
				pop		[eax].DLGHEAD.ftextmode
				pop		[eax].DLGHEAD.hred
				invoke CreateDlg,esi
				invoke GlobalUnlock,ebx
				invoke GlobalFree,ebx
			.endif
			invoke GlobalFree,edi
			invoke SetChanged,TRUE
			mov		fClose,0
		.endif
	.endif
	invoke NotifyParent
	ret

UndoRedo endp
