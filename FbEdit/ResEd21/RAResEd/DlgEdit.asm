SendToBack			PROTO	:DWORD
UpdateRAEdit		PROTO	:DWORD
CreateDlg			PROTO	:HWND,:DWORD,:DWORD

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

.data

szPos				db 'Pos: ',32 dup(0)
Gridcx				dd 3
Gridcy				dd 3
Gridc				dd 0

DlgX				dd 10
DlgY				dd 10
szICODLG			db '#32106',0
DlgFN				db 'MS Sans Serif',0
DlgFS				dd 8
DlgFH				dd -11

DlgIDN				dd 1000
CtrlIDN				dd 1001

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

szMnu				db '  &File  ,	&Edit  ,  &Help  ',0
nPr					dd 32+32+7
PrAll				db '(Name),(ID),Left,Top,Width,Height,Caption,Border,SysMenu,MaxButton,MinButton,Enabled,Visible,Clipping,ScrollBar,Default,Auto,Alignment,Mnemonic,WordWrap,MultiLine,Type,Locked,Child,SizeBorder,TabStop,Font,Menu,Class,Notify,AutoScroll,WantCr,'
					db 'Sort,Flat,(StartID),TabIndex,Format,SizeGrip,Group,Icon,UseTabs,StartupPos,Orientation,SetBuddy,MultiSelect,HideSel,TopMost,xExStyle,xStyle,IntegralHgt,Image,Buttons,PopUp,OwnerDraw,Transp,Timer,AutoPlay,WeekNum,AviClip,AutoSize,ToolTip,Wrap,'
					db 'Divider,DragDrop,'
					db 'Smooth,Ellipsis,Language,HasStrings,(HelpID),File,MenuEx,SaveSel'
					db 512 dup(0)

				;0-Dialog
ctltypes			dd 0
					dd offset szDlgChildClass
					dd 1	;Parent
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
					dd 0	;Parent
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
					dd 0	;Parent
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
					dd 0;2	;Parent
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
					dd 0	;Parent
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
					dd 0	;Parent
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
					dd 0	;Parent
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
					dd 0	;Parent
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
					dd 0	;Parent
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
					dd 0	;Parent
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
					dd 0	;Parent
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
					dd 0	;Parent
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
					dd 0	;Parent
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
					dd 0	;Parent
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
					dd 0	;Parent
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
					dd 0	;Parent
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
					dd 0	;Parent
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
					dd 0	;Parent
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
					dd 0	;Parent
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
					dd 0	;Parent
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
					dd 0	;Parent
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
					dd 0	;Parent
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
					dd 0	;Parent
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
					dd 11111101000111100000101001000011b
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
					dd 0	;Parent
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
					dd 0	;Parent
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
					dd 0	;Parent
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
					dd 0	;Parent
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
					dd 0	;Parent
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
					dd 0	;Parent
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
					dd 0	;Parent
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
					dd 0	;Parent
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
					dd 0	;Parent
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
					dd 0	;Not used
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
custtypes			TYPES 32 dup(<?>)

szNOTStyle			db 'NOT WS_VISIBLE|',0
szNOTStyleHex		db 'NOT 0x10000000|',0
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

szDupTab			db 0Dh,0Ah,'Duplicate TabIndex',0
szMissTab			db 0Dh,0Ah,'Missing TabIndex',0

.data?

fGrid				dd ?
;//Edit
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
fNoMouseUp			dd ?
CtlRect				RECT <?>
fSizeing			dd ?
fMoveing			dd ?
fDrawing			dd ?
fMultiSel			dd ?
ParPt				POINT <?>
hReSize				dd ?
MousePtDown			POINT <?>
OldSizeingProc		dd ?
hDlgIml				dd ?
dlgpaste			DIALOG MAXMULSEL dup(<?>)
SizeRect			RECT MAXMULSEL dup(<?>)
;Dialog menu
MnuRight			dd ?
MnuHigh				dd ?
MnuTrack			dd ?
MnuInx				dd ?

hScrDC				dd ?
hWinDC				dd ?
hWinHwnd			dd ?
hWinRgn				dd ?
hComDC				dd ?
hWinBmp				dd ?
hOldRgn				dd ?
fNoParent			dd ?
dfntwt				dd ?
dfntht				dd ?

mpt					POINT <?>
fntwt				dd ?
fntht				dd ?
hRect				dd MAXMULSEL*4 dup(?)
mousedown			dd ?

.code

;//Edit
RSnapToGrid proc 
	push	eax
	push	ecx
	push	edx
	invoke	GetAsyncKeyState, VK_MENU
	cmp		eax, 0
	mov		eax, 0
	setne 	al
	xor		eax, fSnapToGrid
	mov		fRSnapToGrid, eax
	pop		edx
	pop		ecx
	pop		eax
	ret
RSnapToGrid endp

CaptureWin proc hWin:HWND
	LOCAL	rect:RECT
	LOCAL	rect1:RECT
	LOCAL	Ht:DWORD
	LOCAL	Wt:DWORD
	LOCAL	hCld:HWND

	.if !hComDC
		mov		eax,hWin
		mov		hCld,eax
		invoke GetParent,hWin
		mov		hWin,eax
		invoke GetWindowRect,hWin,addr rect
		mov		eax,rect.right
		sub		eax,rect.left
		mov		Wt,eax
		mov		eax,rect.bottom
		sub		eax,rect.top
		mov		Ht,eax
		invoke GetWindowDC,hWin
		mov    hWinDC,eax
		mov		eax,hWin
		mov		hWinHwnd,eax
		invoke CreateCompatibleDC,hWinDC
		mov    hComDC,eax
		invoke CreateCompatibleBitmap,hWinDC,Wt,Ht
		mov		hWinBmp,eax
		invoke GdiFlush
		invoke SelectObject,hComDC,hWinBmp
		invoke BitBlt,hComDC,0,0,Wt,Ht,hWinDC,0,0,SRCCOPY
		invoke GetDC,0
		mov		hScrDC,eax
		.if fNoParent
			invoke GetWindowRect,hCld,addr rect
		.endif
		invoke GetClientRect,hDEd,addr rect1
		invoke ClientToScreen,hDEd,addr rect1.left
		invoke ClientToScreen,hDEd,addr rect1.right
		mov		eax,rect1.left
		.if eax>rect.left
			mov		rect.left,eax
		.endif
		mov		eax,rect1.top
		.if eax>rect.top
			mov		rect.top,eax
		.endif
		mov		eax,rect1.right
		.if eax<rect.right
			mov		rect.right,eax
		.endif
		mov		eax,rect1.bottom
		.if eax<rect.bottom
			mov		rect.bottom,eax
		.endif
		invoke CreateRectRgn,rect.left,rect.top,rect.right,rect.bottom
		mov		hWinRgn,eax
		invoke SelectObject,hScrDC,hWinRgn
		mov		hOldRgn,eax
	.endif
	ret

CaptureWin endp

PaintWin proc hWin:HWND
	LOCAL	hDC:HDC
	LOCAL	rect:RECT

	.if hComDC
		invoke GetParent,hWin
		mov		hWin,eax
		invoke GetWindowDC,hWin
		mov		hDC,eax
		invoke GetWindowRect,hWin,addr rect
		mov		eax,rect.right
		sub		eax,rect.left
		mov		rect.right,eax
		mov		eax,rect.bottom
		sub		eax,rect.top
		mov		rect.bottom,eax
		invoke BitBlt,hDC,0,0,rect.right,rect.bottom,hComDC,0,0,SRCCOPY
		invoke ReleaseDC,hWin,hDC
	.endif
	ret

PaintWin endp

DestroyWin proc

	.if hComDC
		invoke ReleaseDC,hWinHwnd,hWinDC
		invoke DeleteDC,hComDC
		invoke DeleteObject,hWinBmp
		invoke SelectObject,hScrDC,hOldRgn
		invoke DeleteObject,hWinRgn
		invoke ReleaseDC,0,hScrDC
		mov		hComDC,0
	.endif
	ret

DestroyWin endp

DlgDrawRect proc uses esi edi,hWin:HWND,lpRect:DWORD,nFun:DWORD,nInx:DWORD
	LOCAL	ht:DWORD
	LOCAL	wt:DWORD
	LOCAL	rect:RECT

	invoke CopyRect,addr rect,lpRect
	lea		esi,rect
	assume esi:ptr RECT
	add		[esi].right,1
	mov		eax,[esi].right
	sub		eax,[esi].left
	jns		@f
	mov		eax,[esi].right
	xchg	eax,[esi].left
	mov		[esi].right,eax
	sub		eax,[esi].left
	dec		[esi].left
	inc		[esi].right
	inc		eax
  @@:
	mov		wt,eax
	add		[esi].bottom,1
	mov		eax,[esi].bottom
	sub		eax,[esi].top
	jns		@f
	mov		eax,[esi].bottom
	xchg	eax,[esi].top
	mov		[esi].bottom,eax
	sub		eax,[esi].top
	dec		[esi].top
	inc		[esi].bottom
	inc		eax
  @@:
	mov		ht,eax
	dec		[esi].right
	dec		[esi].bottom
	mov		edi,nInx
	shl		edi,4
	add		edi,offset hRect
	.if nFun==0
		.if nInx==0
			invoke CaptureWin,hWin
		.endif
		invoke GetStockObject,BLACK_BRUSH
		mov edx,eax
		invoke FrameRect,hScrDC,addr rect,edx
	.elseif nFun==1
		.if nInx==0
			invoke PaintWin,hWin
		.endif
		invoke GetStockObject,BLACK_BRUSH
		mov edx,eax
		invoke FrameRect,hScrDC,addr rect,edx
	.elseif nFun==2
		.if nInx==0
			invoke PaintWin,hWin
			invoke DestroyWin
		.endif
	.endif
	assume esi:nothing
	ret

DlgDrawRect endp

GetFreeDlg proc hDlgMem:DWORD

	mov		eax,hDlgMem
	add		eax,sizeof DLGHEAD
	sub		eax,sizeof DIALOG
  @@:
	add		eax,sizeof DIALOG
	cmp		(DIALOG ptr [eax]).hwnd,0
	jne		@b
	ret

GetFreeDlg endp

GetFreeID proc uses esi edi

	invoke GetWindowLong,hDEd,DEWM_MEMORY
	.if eax
		mov		esi,eax
		assume esi:ptr DLGHEAD
		mov		eax,[esi].ctlid
		add		esi,sizeof DLGHEAD
		assume esi:ptr DIALOG
		sub		esi,sizeof DIALOG
		mov		edi,esi
	  @@:
		add		esi,sizeof DIALOG
		cmp		[esi].hwnd,0
		je		@f
		cmp		[esi].hwnd,-1
		je		@b
		cmp		eax,[esi].id
		jne		@b
		mov		esi,edi
		inc		eax
		jmp		@b
	  @@:
		assume esi:nothing
	.endif
	ret

GetFreeID endp

IsFreeID proc uses esi,nID:DWORD

	invoke GetWindowLong,hDEd,DEWM_MEMORY
	.if eax
		mov		esi,eax
		add		esi,sizeof DLGHEAD
		assume esi:ptr DIALOG
		sub		esi,sizeof DIALOG
		mov		eax,nID
	  @@:
		add		esi,sizeof DIALOG
		cmp		[esi].hwnd,0
		je		@f
		cmp		[esi].hwnd,-1
		je		@b
		cmp		eax,[esi].id
		jne		@b
		mov		eax,0
	  @@:
		assume esi:nothing
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
		assume esi:ptr DIALOG
		mov		edi,esi
		mov		nTab,0
	  @@:
		add		esi,sizeof DIALOG
		cmp		[esi].hwnd,0
		je		@f
		cmp		[esi].hwnd,-1
		je		@b
		mov		eax,nTab
		cmp		eax,[esi].tab
		jne		@b
		mov		esi,edi
		inc		nTab
		jmp		@b
	  @@:
		mov		eax,nTab
	.endif
	assume esi:nothing
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

	invoke GetWindowLong,hCtl,GWL_USERDATA
	.if eax
		mov		esi,eax
		invoke GetFreeTab
		.if eax<=nTab
			.if eax
				dec		eax
			.endif
			mov		nTab,eax
		.endif
		mov		eax,(DIALOG ptr [esi]).tab
		mov		nOld,eax
		mov		edi,esi
		invoke GetWindowLong,hDEd,DEWM_MEMORY
		.if eax
			mov		esi,eax
			add		esi,sizeof DLGHEAD
			assume esi:ptr DIALOG
		  @@:
			add		esi,sizeof DIALOG
			cmp		[esi].hwnd,0
			je		@f
			cmp		[esi].hwnd,-1
			je		@b
			mov		eax,nTab
			.if eax>nOld
				mov		eax,[esi].tab
				.if eax>nOld && eax<=nTab
					dec		[esi].tab
				.endif
			.else
				mov		eax,[esi].tab
				.if eax<nOld && eax>=nTab
					inc		[esi].tab
				.endif
			.endif
			jmp		@b
		  @@:
			mov		eax,nTab
			mov		(DIALOG ptr [edi]).tab,eax
			assume esi:nothing
		.endif
	.endif
	ret

SetNewTab endp

InsertTab proc uses esi,nTab:DWORD

	invoke GetWindowLong,hDEd,DEWM_MEMORY
	.if eax
		mov		esi,eax
		add		esi,sizeof DLGHEAD
		assume esi:ptr DIALOG
	  @@:
		add		esi,sizeof DIALOG
		cmp		[esi].hwnd,0
		je		@f
		cmp		[esi].hwnd,-1
		je		@b
		mov		eax,nTab
		.if eax<=[esi].tab
			inc		[esi].tab
		.endif
		jmp		@b
	  @@:
	.endif
	assume esi:nothing
	ret

InsertTab endp

DeleteTab proc uses esi,nTab:DWORD

	invoke GetWindowLong,hDEd,DEWM_MEMORY
	.if eax
		mov		esi,eax
		add		esi,sizeof DLGHEAD
		assume esi:ptr DIALOG
	  @@:
		add		esi,sizeof DIALOG
		cmp		[esi].hwnd,0
		je		@f
		cmp		[esi].hwnd,-1
		je		@b
		mov		eax,nTab
		.if eax<[esi].tab
			dec		[esi].tab
		.endif
		jmp		@b
	  @@:
	.endif
	assume esi:nothing
	ret

DeleteTab endp

FindTab proc uses esi,nTab:DWORD,hMem:HWND
	LOCAL	hCtl:HWND

	xor		edx,edx
	mov		hCtl,edx
	mov		eax,hMem
	.if eax
		mov		esi,eax
		add		esi,sizeof DLGHEAD
		assume esi:ptr DIALOG
	  @@:
		add		esi,sizeof DIALOG
		cmp		[esi].hwnd,0
		je		@f
		cmp		[esi].hwnd,-1
		je		@b
		mov		eax,nTab
		cmp		eax,[esi].tab
		jne		@b
		mov		eax,[esi].hwnd
		mov		hCtl,eax
		mov		edx,esi
	  @@:
	.endif
	mov		eax,hCtl
	assume esi:nothing
	ret

FindTab endp

UpdateDialog proc uses esi,hDlg:HWND
	LOCAL	hCtl:HWND

	invoke GetWindowLong,hDlg,GWL_USERDATA
	mov		esi,eax
	push	esi
  @@:
	mov		eax,(DIALOG ptr [esi]).hwnd
	.if eax
		.if eax!=-1
			mov		hCtl,eax
			invoke SetWindowLong,hCtl,GWL_USERDATA,esi
		.endif
		add		esi,sizeof DIALOG
		jmp		@b
	.endif
	pop		esi
  @@:
	mov		eax,(DIALOG ptr [esi]).hwnd
	.if eax
		.if eax!=-1
			mov		hCtl,eax
			invoke SetWindowPos,hCtl,HWND_TOP,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE
		.endif
		add		esi,sizeof DIALOG
		jmp		@b
	.endif
	mov		esi,offset hSizeing
	.while esi<offset hSizeing+8*4
		.if dword ptr [esi]
			invoke SetWindowPos,dword ptr [esi],HWND_TOP,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE
		.endif
		add		esi,4
	.endw
	ret

UpdateDialog endp

FindParent proc hWin:HWND

  @@:
	invoke GetWindowLong,hWin,GWL_USERDATA
	mov		eax,(DIALOG ptr [eax]).ntype
	.if !eax
		mov		eax,hWin
		ret
	.endif
	invoke GetParent,hWin
	mov		hWin,eax
	jmp		@b

FindParent endp

FetchParent proc hWin:HWND

	invoke GetWindowLong,hWin,GWL_USERDATA
	mov		eax,(DIALOG ptr [eax]).hpar
	ret

FetchParent endp

GetTypePtr proc nType:DWORD

	push	edx
	mov		eax,size TYPES
	mov		edx,nType
	mul		edx
	add		eax,offset ctltypes
	pop		edx
	ret

GetTypePtr endp

SetChanged proc fChanged:DWORD,hWin:HWND
	LOCAL	hDC:HDC
	LOCAL	hBr:DWORD
	LOCAL	rect:RECT

	.if !hWin
		mov		eax,hDEd
		mov		hWin,eax
	.endif
	invoke GetWindowLong,hWin,DEWM_MEMORY
	.if eax
		.if fChanged==2
			push	(DLGHEAD ptr [eax]).changed
			pop		fChanged
		.else
			push	fChanged
			pop		(DLGHEAD ptr [eax]).changed
		.endif
		invoke GetDC,hWin
		mov		hDC,eax
		.if fChanged
			mov		eax,40A040h
		.else
			invoke GetWindowLong,hWin,DEWM_READONLY
			.if eax
				mov		eax,0FFh
			.else
				mov		eax,color.back
			.endif
		.endif
		invoke CreateSolidBrush,eax
		mov		hBr,eax
		mov		rect.left,1
		mov		rect.top,1
		mov		rect.right,6
		mov		rect.bottom,6
		invoke FillRect,hDC,addr rect,hBr
		invoke ReleaseDC,hWin,hDC
		invoke DeleteObject,hBr
	.endif
	invoke NotifyParent
	ret

SetChanged endp

UpdateSize proc uses esi,hWin:HWND,x:DWORD,y:DWORD,ccx:DWORD,ccy:DWORD
	LOCAL	fChanged:DWORD

	mov		fChanged,FALSE
	invoke GetWindowLong,hWin,GWL_USERDATA
	mov		esi,eax
	assume esi:ptr DIALOG
	;Posotion & Size
	mov		eax,[esi].x
	.if eax!=x
		mov		fChanged,TRUE
	.endif
	mov		eax,[esi].y
	.if eax!=y
		mov		fChanged,TRUE
	.endif
	mov		eax,[esi].ccx
	.if eax!=ccx
		mov		fChanged,TRUE
	.endif
	mov		eax,[esi].ccy
	.if eax!=ccy
		mov		fChanged,TRUE
	.endif
	push	x
	pop		[esi].x
	push	y
	pop		[esi].y
	push	ccx
	pop		[esi].ccx
	push	ccy
	pop		[esi].ccy
	.if fChanged
		xor		eax,eax
		mov		[esi].dux,eax
		mov		[esi].duy,eax
		mov		[esi].duccx,eax
		mov		[esi].duccy,eax
		invoke SetChanged,TRUE,0
		invoke GetWindowLong,hDEd,DEWM_MEMORY
		invoke UpdateRAEdit,eax
	.endif
	assume esi:nothing
	ret

UpdateSize endp

DestroySizeingRect proc uses edi

	mov		edi,offset hSizeing
	invoke GetParent,[edi]
	push	eax
	mov		ecx,8
  @@:
	mov		eax,[edi]
	.if eax
		push	ecx
		invoke DestroyWindow,eax
		pop		ecx
	.endif
	xor		eax,eax
	mov		[edi],eax
	add		edi,4
	loop	@b
	mov		hReSize,0
	invoke PropertyList,0
	pop		eax
	invoke UpdateWindow,eax
	invoke SendMessage,hDEd,WM_LBUTTONDOWN,0,0
	ret

DestroySizeingRect endp

DialogTltSize proc uses esi,ccx:DWORD,ccy:DWORD
	LOCAL	buffer[32]:BYTE
	LOCAL	pt:POINT
	LOCAL	hDC:HDC
	LOCAL	len:DWORD
	LOCAL	hOldFont:DWORD

	.if fShowSizePos
		invoke GetCursorPos,addr mpt
		add		mpt.y,15
		add		mpt.x,15
		lea		esi,buffer
		mov		al,' '
		mov		[esi],al
		inc		esi
		invoke ResEdBinToDec,ccx,esi
		invoke strlen,esi
		add		esi,eax
		mov		al,','
		mov		[esi],al
		inc		esi
		mov		al,' '
		mov		[esi],al
		inc		esi
		invoke ResEdBinToDec,ccy,esi
		invoke strlen,esi
		add		esi,eax
		mov		eax,'  '
		mov		[esi],eax
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
	.endif
	ret

DialogTltSize endp

SizeX proc nInc:DWORD

;//Edit
	call RSnapToGrid
	.if fRSnapToGrid
		xor		edx,edx
		idiv	Gridcx
		imul	Gridcx
		add		eax,nInc
	.endif
	ret

SizeX endp

SizeY proc nInc:DWORD

;//Edit
	call RSnapToGrid
	.if fRSnapToGrid
		xor		edx,edx
		idiv	Gridcy
		imul	Gridcy
		add		eax,nInc
	.endif
	ret

SizeY endp

SizeingProc proc uses edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	nInx:DWORD
	LOCAL	pt:POINT
	LOCAL	parpt:POINT
	LOCAL	fChanged:DWORD

	mov		eax,uMsg
	.if eax>=WM_MOUSEFIRST && eax<=WM_MOUSELAST
		invoke GetWindowLong,hWin,GWL_USERDATA
		movzx	edx,ax
		shr		eax,16
		mov		nInx,eax
		.if edx
			mov		eax,uMsg
			.if eax==WM_LBUTTONDOWN && !fSizeing
				mov		fSizeing,TRUE
				invoke PropertyList,0
				mov		eax,lParam
				and		eax,0FFFFh
				cwde
				mov		MousePtDown.x,eax
				mov		eax,lParam
				shr		eax,16
				cwde
				mov		MousePtDown.y,eax
				mov		ParPt.x,0
				mov		ParPt.y,0
				invoke GetWindowLong,hDEd,DEWM_DIALOG
				mov		edx,eax
				invoke ClientToScreen,edx,addr ParPt
				invoke GetWindowRect,hReSize,addr CtlRect
				invoke GetWindowLong,hReSize,GWL_USERDATA
				mov		edi,eax
				assume edi:ptr DIALOG
				mov		eax,[edi].ntype
				.if eax==7 || eax==24
					mov		eax,[edi].ccy
					add		eax,CtlRect.top
					mov		CtlRect.bottom,eax
				.endif
				invoke CopyRect,addr SizeRect,addr CtlRect
				invoke DlgDrawRect,hReSize,addr SizeRect,0,0
				invoke SetCapture,hWin
				invoke SendMessage,hWin,WM_MOUSEMOVE,wParam,lParam
			.elseif eax==WM_LBUTTONUP && fSizeing
				mov		fSizeing,FALSE
				invoke ReleaseCapture
				invoke DlgDrawRect,hReSize,addr SizeRect,2,0
				mov		eax,SizeRect.left
				sub		SizeRect.right,eax
				mov		eax,SizeRect.top
				sub		SizeRect.bottom,eax
				mov		eax,ParPt.x
				sub		SizeRect.left,eax
				mov		eax,ParPt.y
				sub		SizeRect.top,eax
				invoke GetWindowLong,hReSize,GWL_USERDATA
				mov		edi,eax
				assume edi:ptr DIALOG
				mov		fChanged,FALSE
				mov		eax,[edi].ntype
				.if eax
					mov		eax,SizeRect.left
					.if eax!=[edi].x
						mov		[edi].x,eax
						mov		fChanged,TRUE
					.endif
					mov		eax,SizeRect.top
					.if eax!=[edi].y
						mov		[edi].y,eax
						mov		fChanged,TRUE
					.endif
				.else
					mov		edx,edi
					sub		edx,sizeof DLGHEAD
					.if [edx].DLGHEAD.menuid
						sub		SizeRect.bottom,19
					.endif
				.endif
				mov		eax,SizeRect.right
				.if eax!=[edi].ccx
					mov		[edi].ccx,eax
					mov		fChanged,TRUE
				.endif
				mov		eax,SizeRect.bottom
				.if eax!=[edi].ccy
					mov		[edi].ccy,eax
					mov		fChanged,TRUE
				.endif
				.if fChanged
					xor		eax,eax
					mov		[edi].dux,eax
					mov		[edi].duy,eax
					mov		[edi].duccx,eax
					mov		[edi].duccy,eax
					invoke UpdateCtl,hReSize
					mov		hReSize,eax
				.else
					invoke PropertyList,hReSize
				.endif
				invoke ShowWindow,hTlt,SW_HIDE
				assume edi:nothing
			.elseif eax==WM_MOUSEMOVE && fSizeing
				mov		parpt.x,0
				mov		parpt.y,0
				invoke GetWindowLong,hDEd,DEWM_DIALOG
				mov		edx,eax
				invoke ClientToScreen,edx,addr parpt
				invoke CopyRect,addr SizeRect,addr CtlRect
				mov		eax,lParam
				and		eax,0FFFFh
				cwde
				sub		eax,MousePtDown.x
				mov		pt.x,eax
				mov		eax,lParam
				shr		eax,16
				cwde
				sub		eax,MousePtDown.y
				mov		pt.y,eax
				mov		eax,nInx
				.if eax==0
					mov		eax,pt.x
					add		SizeRect.left,eax
					mov		eax,SizeRect.left
					sub		eax,parpt.x
					invoke SizeX,0
					add		eax,parpt.x
					mov		SizeRect.left,eax
					mov		eax,pt.y
					add		SizeRect.top,eax
					mov		eax,SizeRect.top
					sub		eax,parpt.y
					invoke SizeY,0
					add		eax,parpt.y
					mov		SizeRect.top,eax
				.elseif eax==1
					mov		eax,pt.y
					add		SizeRect.top,eax
					mov		eax,SizeRect.top
					sub		eax,parpt.y
					invoke SizeY,0
					add		eax,parpt.y
					mov		SizeRect.top,eax
				.elseif eax==2
					mov		eax,pt.x
					add		SizeRect.right,eax
					mov		eax,SizeRect.right
					sub		eax,SizeRect.left
					invoke SizeX,1
					add		eax,SizeRect.left
					mov		SizeRect.right,eax
					mov		eax,pt.y
					add		SizeRect.top,eax
					mov		eax,SizeRect.top
					sub		eax,parpt.y
					invoke SizeY,0
					add		eax,parpt.y
					mov		SizeRect.top,eax
				.elseif eax==3
					mov		eax,pt.x
					add		SizeRect.left,eax
					mov		eax,SizeRect.left
					sub		eax,parpt.x
					invoke SizeX,0
					add		eax,parpt.x
					mov		SizeRect.left,eax
				.elseif eax==4
					mov		eax,pt.x
					add		SizeRect.right,eax
					mov		eax,SizeRect.right
					sub		eax,SizeRect.left
					invoke SizeX,1
					add		eax,SizeRect.left
					mov		SizeRect.right,eax
				.elseif eax==5
					mov		eax,pt.x
					add		SizeRect.left,eax
					mov		eax,SizeRect.left
					sub		eax,parpt.x
					invoke SizeX,0
					add		eax,parpt.x
					mov		SizeRect.left,eax
					mov		eax,pt.y
					add		SizeRect.bottom,eax
					mov		eax,SizeRect.bottom
					sub		eax,SizeRect.top
					invoke SizeY,1
					add		eax,SizeRect.top
					mov		SizeRect.bottom,eax
				.elseif eax==6
					mov		eax,pt.y
					add		SizeRect.bottom,eax
					mov		eax,SizeRect.bottom
					sub		eax,SizeRect.top
					invoke SizeY,1
					add		eax,SizeRect.top
					mov		SizeRect.bottom,eax
				.elseif eax==7
					mov		eax,pt.x
					add		SizeRect.right,eax
					mov		eax,SizeRect.right
					sub		eax,SizeRect.left
					invoke SizeX,1
					add		eax,SizeRect.left
					mov		SizeRect.right,eax
					mov		eax,pt.y
					add		SizeRect.bottom,eax
					mov		eax,SizeRect.bottom
					sub		eax,SizeRect.top
					invoke SizeY,1
					add		eax,SizeRect.top
					mov		SizeRect.bottom,eax
				.endif
				invoke DlgDrawRect,hReSize,addr SizeRect,1,0
				mov		eax,SizeRect.right
				sub		eax,SizeRect.left
				mov		pt.x,eax
				mov		eax,SizeRect.bottom
				sub		eax,SizeRect.top
				mov		pt.y,eax
				invoke DialogTltSize,pt.x,pt.y
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
		push	(DLGHEAD ptr [eax]).locked
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

DestroyMultiSel proc hSel:HWND

	.if hSel
		invoke GetParent,hSel
		push	eax
		mov		eax,8
		.while eax
			push	eax
			invoke GetWindowLong,hSel,GWL_USERDATA
			push	eax
			invoke DestroyWindow,hSel
			pop		hSel
			pop		eax
			dec		eax
		.endw
		pop		eax
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
	mov		ParPt.x,0
	mov		ParPt.y,0
	invoke ClientToScreen,hWin,addr ParPt
	invoke GetWindowRect,hWin,addr rect
	invoke CopyRect,addr CtlRect,addr rect
	mov		eax,ParPt.x
	sub		rect.left,eax
	sub		rect.right,eax
	mov		eax,ParPt.y
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
	invoke SendMessage,hDEd,WM_LBUTTONDOWN,0,0
	ret

MultiSelRect endp

SizeingRect proc uses esi,hWin:HWND,fLocked:DWORD
	LOCAL	fDlg:DWORD
	LOCAL	rect:RECT
	LOCAL	ctlrect:RECT
	LOCAL	pt:POINT
	LOCAL	hPar:HWND

	invoke GetWindowLong,hWin,GWL_USERDATA
	mov		esi,eax
	.if fLocked!=99
		.while hMultiSel
			invoke DestroyMultiSel,hMultiSel
			mov		hMultiSel,eax
		.endw
		mov		eax,hWin
		mov		hReSize,eax
	.endif
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
	invoke FetchParent,hWin
	mov		hPar,eax
	mov		ParPt.x,0
	mov		ParPt.y,0
	invoke ClientToScreen,hPar,addr ParPt
	invoke GetWindowRect,hWin,addr rect
	mov		eax,(DIALOG ptr [esi]).ntype
	.if eax==7 || eax==8 || eax==24
		mov		eax,(DIALOG ptr [esi]).ccy
		add		eax,rect.top
		mov		rect.bottom,eax
	.endif
	invoke CopyRect,addr CtlRect,addr rect
	mov		eax,ParPt.x
	sub		rect.left,eax
	sub		rect.right,eax
	mov		eax,ParPt.y
	sub		rect.top,eax
	sub		rect.bottom,eax
	invoke CopyRect,addr ctlrect,addr rect
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
	.if fLocked!=99
		.if fDlg
			invoke DrawSizeingItem,rect.left,rect.top,0,0,hPar,fLocked
			invoke DrawSizeingItem,pt.x,rect.top,1,0,hPar,fLocked
			invoke DrawSizeingItem,rect.right,rect.top,2,0,hPar,fLocked
			invoke DrawSizeingItem,rect.left,pt.y,3,0,hPar,fLocked
			invoke DrawSizeingItem,rect.left,rect.bottom,5,0,hPar,fLocked
		.else
			invoke DrawSizeingItem,rect.left,rect.top,0,IDC_SIZENWSE,hPar,fLocked
			invoke DrawSizeingItem,pt.x,rect.top,1,IDC_SIZENS,hPar,fLocked
			invoke DrawSizeingItem,rect.right,rect.top,2,IDC_SIZENESW,hPar,fLocked
			invoke DrawSizeingItem,rect.left,pt.y,3,IDC_SIZEWE,hPar,fLocked
			invoke DrawSizeingItem,rect.left,rect.bottom,5,IDC_SIZENESW,hPar,fLocked
		.endif
		invoke DrawSizeingItem,rect.right,pt.y,4,IDC_SIZEWE,hPar,fLocked
		invoke DrawSizeingItem,pt.x,rect.bottom,6,IDC_SIZENS,hPar,fLocked
		invoke DrawSizeingItem,rect.right,rect.bottom,7,IDC_SIZENWSE,hPar,fLocked
	.endif
	mov		eax,ctlrect.left
	sub		ctlrect.right,eax
	mov		eax,ctlrect.top
	sub		ctlrect.bottom,eax
	.if !fDlg
		invoke UpdateSize,hWin,ctlrect.left,ctlrect.top,ctlrect.right,ctlrect.bottom
	.endif
	.if fLocked!=99
		invoke PropertyList,hWin
		invoke SendMessage,hDEd,WM_LBUTTONDOWN,0,0
	.endif
	ret

SizeingRect endp

SnapToGrid proc uses edi,hWin:HWND,lpRect:DWORD
	LOCAL	hPar:HWND

;//Edit
	call RSnapToGrid
	.if fRSnapToGrid
		mov		edi,lpRect
		invoke FetchParent,hWin
		mov		hPar,eax
		mov		ParPt.x,0
		mov		ParPt.y,0
		invoke ClientToScreen,hPar,addr ParPt
		mov		eax,(RECT ptr [edi]).left
		sub		eax,ParPt.x
		cdq
		idiv	Gridcx
		imul	Gridcx
		add		eax,ParPt.x
		sub		eax,(RECT ptr [edi]).left
		add		(RECT ptr [edi]).left,eax
		add		(RECT ptr [edi]).right,eax

		mov		eax,(RECT ptr [edi]).right
		sub		eax,(RECT ptr [edi]).left
		cdq
		idiv	Gridcx
		imul	Gridcx
		add		eax,(RECT ptr [edi]).left
		inc		eax
		mov		(RECT ptr [edi]).right,eax

		mov		eax,(RECT ptr [edi]).top
		sub		eax,ParPt.y
		cdq
		idiv	Gridcy
		imul	Gridcy
		add		eax,ParPt.y
		sub		eax,(RECT ptr [edi]).top
		add		(RECT ptr [edi]).top,eax
		add		(RECT ptr [edi]).bottom,eax

		mov		eax,(RECT ptr [edi]).bottom
		sub		eax,(RECT ptr [edi]).top
		cdq
		idiv	Gridcy
		imul	Gridcy
		add		eax,(RECT ptr [edi]).top
		inc		eax
		mov		(RECT ptr [edi]).bottom,eax
	.endif
	ret

SnapToGrid endp

MoveingRect proc uses esi edi,hWin:HWND,lParam:LPARAM,nFun:DWORD,nInx:DWORD
	LOCAL	pt:POINT
	LOCAL	ptold:POINT
	LOCAL	hPar:HWND

	invoke GetWindowRect,hWin,addr CtlRect
	invoke GetWindowLong,hWin,GWL_USERDATA
	.if eax
		mov		esi,eax
		mov		eax,(DIALOG ptr [esi]).ntype
		.if eax==7 || eax==24
			mov		eax,(DIALOG ptr [esi]).ccy
			add		eax,CtlRect.top
			mov		CtlRect.bottom,eax
		.endif
		mov		eax,lParam
		and		eax,0FFFFh
		cwde
		mov		pt.x,eax
		mov		eax,lParam
		shr		eax,16
		cwde
		mov		pt.y,eax
		mov		edi,nInx
		shl		edi,4
		add		edi,offset SizeRect
		.if nFun==0
			mov		eax,(DIALOG ptr [esi]).ntype
			.if eax
				mov		fMoveing,TRUE
				mov		eax,pt.x
				mov		MousePtDown.x,eax
				mov		eax,pt.y
				mov		MousePtDown.y,eax
				invoke DlgDrawRect,hWin,addr CtlRect,0,nInx
				invoke CopyRect,edi,addr CtlRect
			.endif
		.elseif nFun==1
			mov		eax,pt.x
			sub		eax,MousePtDown.x
			mov		pt.x,eax
			mov		eax,pt.y
			sub		eax,MousePtDown.y
			mov		pt.y,eax
			push	(RECT ptr [edi]).left
			pop		ptold.x
			push	(RECT ptr [edi]).top
			pop		ptold.y
			invoke CopyRect,edi,addr CtlRect
			mov		eax,pt.x
			add		(RECT ptr [edi]).left,eax
			add		(RECT ptr [edi]).right,eax
			mov		eax,pt.y
			add		(RECT ptr [edi]).top,eax
			add		(RECT ptr [edi]).bottom,eax
			invoke SnapToGrid,hWin,edi
			mov		eax,(RECT ptr [edi]).left
			mov		edx,(RECT ptr [edi]).top
			.if eax!=ptold.x || edx!=ptold.y
				invoke DlgDrawRect,hWin,edi,1,nInx
			.endif
			invoke FetchParent,hWin
			mov		hPar,eax
			mov		ParPt.x,0
			mov		ParPt.y,0
			invoke ClientToScreen,hPar,addr ParPt
			mov		eax,(RECT ptr [edi]).left
			sub		eax,ParPt.x
			mov		ParPt.x,eax
			mov		eax,(RECT ptr [edi]).top
			sub		eax,ParPt.y
			mov		ParPt.y,eax
		.elseif nFun==2
			invoke DlgDrawRect,hWin,edi,2,nInx
			invoke ShowWindow,hTlt,SW_HIDE
			invoke FetchParent,hWin
			mov		hPar,eax
			mov		ParPt.x,0
			mov		ParPt.y,0
			invoke ClientToScreen,hPar,addr ParPt
			mov		eax,(RECT ptr [edi]).left
			sub		eax,ParPt.x
			mov		pt.x,eax
			mov		eax,(RECT ptr [edi]).top
			sub		eax,ParPt.y
			mov		pt.y,eax
			mov		fMoveing,FALSE
			invoke ReleaseCapture
			invoke SetWindowPos,hWin,0,pt.x,pt.y,0,0,SWP_NOZORDER or SWP_NOSIZE
		.endif
	.endif
	ret

MoveingRect endp

CtlMultiSelect proc hWin:HWND,lParam:LPARAM

	.if hReSize
		invoke GetWindowLong,hReSize,GWL_USERDATA
		mov		eax,(DIALOG ptr [eax]).ntype
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
				mov		fNoMouseUp,TRUE
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

GetMnuPopup proc uses ebx esi,lpDlgMem:DWORD

	mov		eax,lpDlgMem
	mov		eax,[eax].DLGHEAD.lpmnu
	.if eax
		add		eax,sizeof MNUHEAD
		mov		edx,MnuInx
		inc		edx
		invoke CreateSubMenu,eax,edx
	.endif
	ret

GetMnuPopup endp

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

CtlProc proc uses esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	lpOldProc:DWORD
	LOCAL	pt:POINT
	LOCAL	rect:RECT
	LOCAL	rect1:RECT
	LOCAL	ws:DWORD
	LOCAL	wsex:DWORD
	LOCAL	nInx:DWORD
	LOCAL	fShift:DWORD
	LOCAL	fControl:DWORD
	LOCAL	hCtl:HWND
	LOCAL	dblclk:CTLDBLCLICK

	mov		nInx,0
	invoke GetWindowLong,hWin,GWL_USERDATA
	.if eax
		mov		esi,eax
		push	(DIALOG ptr [esi]).oldproc
		pop		lpOldProc
		mov		eax,uMsg
		.if eax==WM_NCLBUTTONDOWN || eax==WM_NCLBUTTONDBLCLK || eax==WM_NCMOUSEMOVE || eax==WM_NCLBUTTONUP
			mov		eax,lParam
			and		eax,0FFFFh
			cwde
			mov		rect1.left,eax
			add		eax,100
			mov		rect1.right,eax
			mov		eax,lParam
			shr		eax,16
			cwde
			mov		rect1.top,eax
			add		eax,100
			mov		rect1.bottom,eax
			invoke GetWindowLong,hWin,GWL_STYLE
			mov		ws,eax
			invoke GetWindowLong,hWin,GWL_EXSTYLE
			mov		wsex,eax
			invoke AdjustWindowRectEx,addr rect1,ws,0,wsex
			mov		eax,rect1.left
			mov		pt.x,eax
			mov		eax,rect1.top
			mov		pt.y,eax
			invoke GetWindowRect,hWin,addr rect
			mov		eax,(DIALOG ptr [esi]).ntype
			.if eax==7 || eax==24
				mov		eax,(DIALOG ptr [esi]).ccy
				add		eax,rect.top
				mov		rect.bottom,eax
			.endif
			mov		eax,rect.left
			sub		pt.x,eax
			mov		eax,rect.top
			sub		pt.y,eax
			mov		eax,pt.y
			shl		eax,16
			and		pt.x,0FFFFh
			add		eax,pt.x
			mov		lParam,eax
		.endif
		mov		eax,(DIALOG ptr [esi]).ntype
		.if !eax
			mov		eax,uMsg
			.if eax==WM_LBUTTONDOWN || eax==WM_NCLBUTTONDOWN
				.if !MnuTrack
					invoke SendMessage,hWin,WM_NCPAINT,0,0
					.if MnuHigh
						mov		eax,MnuHigh
						and		eax,0FFFFh
						mov		pt.x,eax
						mov		eax,MnuHigh
						shr		eax,16
						mov		pt.y,eax
						invoke GetWindowRect,hWin,addr rect
						mov		eax,rect.left
						dec		eax
						add		pt.x,eax
						mov		eax,rect.top
						add		pt.y,eax
						sub		esi,sizeof DLGHEAD
						invoke GetMnuPopup,esi
						mov		MnuTrack,eax
						.if eax
							invoke TrackPopupMenu,eax,TPM_LEFTALIGN or TPM_LEFTBUTTON,pt.x,pt.y,0,hWin,0
							invoke SendMessage,hWin,WM_NCPAINT,0,0
							invoke DestroyMenu,MnuTrack
						.endif
						xor		eax,eax
						mov		MnuTrack,eax
						jmp		Ex
					.endif
				.endif
			.elseif eax==WM_NCMOUSEMOVE
				mov		edx,lParam
				movzx	eax,dx
				add		eax,5
				shr		edx,16
				.if edx>1 && edx<18 && eax<MnuRight
					invoke SendMessage,hWin,WM_NCPAINT,0,0
				.endif
			.elseif eax==WM_COMMAND && !lParam
				push	ebx
				lea		ebx,dblclk
				mov		eax,hRes
				mov		[ebx].CTLDBLCLICK.nmhdr.hwndFrom,eax
				invoke GetWindowLong,hRes,GWL_ID
				push	eax
				mov		[ebx].CTLDBLCLICK.nmhdr.idFrom,eax
				mov		[ebx].CTLDBLCLICK.nmhdr.code,NM_CLICK
				mov		eax,wParam
				mov		[ebx].CTLDBLCLICK.nCtlId,eax
				lea		edx,[esi-sizeof DLGHEAD]
				invoke GetMnuName,edx,eax
				mov		[ebx].CTLDBLCLICK.lpCtlName,eax
				mov		eax,(DIALOG ptr [esi]).ntype
				.if !eax
					mov		eax,esi
				.else
					mov		eax,(DIALOG ptr [esi]).hpar
					invoke GetWindowLong,eax,GWL_USERDATA
				.endif
				mov		edx,eax
				mov		[ebx].CTLDBLCLICK.lpDlgMem,eax
				mov		eax,(DIALOG ptr [edx]).id
				mov		[ebx].CTLDBLCLICK.nDlgId,eax
				lea		eax,(DIALOG ptr [edx]).idname
				mov		[ebx].CTLDBLCLICK.lpDlgName,eax
				invoke GetParent,hRes
				pop		edx
				invoke SendMessage,eax,WM_NOTIFY,edx,ebx
				pop		ebx
				jmp		Ex
			.endif
		.endif
		mov		eax,uMsg
		.if eax==WM_MOUSEMOVE || eax==WM_NCMOUSEMOVE
			.if MnuHigh
				mov		eax,(DIALOG ptr [esi]).ntype
				.if !eax
					mov		eax,hWin
				.else
					invoke GetParent,hWin
				.endif
				invoke SendMessage,eax,WM_NCPAINT,0,0
			.endif
			.if hStatus
				invoke GetCursorPos,addr pt
				invoke GetWindowLong,hDEd,DEWM_MEMORY
				.if eax
					add		eax,sizeof DLGHEAD
					mov		edx,(DIALOG ptr [eax]).hwnd
					invoke ScreenToClient,edx,addr pt
					invoke ResEdBinToDec,pt.x,offset szPos+5
					invoke strlen,offset szPos
					mov		byte ptr szPos[eax],','
					inc		eax
					invoke ResEdBinToDec,pt.y,addr szPos[eax]
					invoke SendMessage,hStatus,SB_SETTEXT,nStatus,offset szPos
				.endif
			.endif
		.endif
		mov		eax,uMsg
		.if eax==WM_RBUTTONDOWN
			mov		eax,lParam
			mov		edx,eax
			movzx	eax,ax
			shr		edx,16
			mov		pt.x,eax
			mov		pt.y,edx
			invoke ClientToScreen,hWin,addr pt
			mov		eax,pt.y
			shl		eax,16
			mov		ax,word ptr pt.x
			invoke SendMessage,hDEd,WM_CONTEXTMENU,hWin,eax
			jmp		Ex
		.elseif eax==WM_NCRBUTTONDOWN
			invoke SendMessage,hDEd,WM_CONTEXTMENU,hWin,lParam
			jmp		Ex
		.elseif eax==WM_LBUTTONDBLCLK || eax==WM_NCLBUTTONDBLCLK
			push	ebx
			lea		ebx,dblclk
			mov		eax,hRes
			mov		[ebx].CTLDBLCLICK.nmhdr.hwndFrom,eax
			invoke GetWindowLong,hRes,GWL_ID
			push	eax
			mov		[ebx].CTLDBLCLICK.nmhdr.idFrom,eax
			mov		[ebx].CTLDBLCLICK.nmhdr.code,NM_DBLCLK
			mov		eax,(DIALOG ptr [esi]).id
			mov		[ebx].CTLDBLCLICK.nCtlId,eax
			lea		eax,(DIALOG ptr [esi]).idname
			mov		[ebx].CTLDBLCLICK.lpCtlName,eax
			mov		eax,(DIALOG ptr [esi]).ntype
			.if !eax
				mov		eax,esi
			.else
				mov		eax,(DIALOG ptr [esi]).hpar
				invoke GetWindowLong,eax,GWL_USERDATA
			.endif
			mov		edx,eax
			mov		[ebx].CTLDBLCLICK.lpDlgMem,eax
			mov		eax,(DIALOG ptr [edx]).id
			mov		[ebx].CTLDBLCLICK.nDlgId,eax
			lea		eax,(DIALOG ptr [edx]).idname
			mov		[ebx].CTLDBLCLICK.lpDlgName,eax
			invoke GetParent,hRes
			pop		edx
			invoke SendMessage,eax,WM_NOTIFY,edx,ebx
			pop		ebx
			jmp		Ex
		.elseif eax==WM_LBUTTONDOWN || eax==WM_NCLBUTTONDOWN
			invoke SetFocus,hDEd
			invoke GetWindowLong,hWin,GWL_USERDATA
			.if eax
				mov		esi,eax
				mov		eax,(DIALOG ptr [esi]).ntype
				.if !eax
					mov		eax,hWin
				.else
					invoke GetParent,hWin
				.endif
				invoke SendMessage,eax,WM_NCPAINT,0,0
				.if ToolBoxID
					;Is readOnly
					invoke GetWindowLong,hDEd,DEWM_READONLY
					.if !eax
						;Draw outline of new control
						invoke DrawingRect,hWin,lParam,0
					.endif
				.elseif !fMoveing
					;Select control
					;Shift key
					mov		eax,wParam
					and		eax,MK_SHIFT
					mov		fShift,eax
					;Control key
					mov		eax,wParam
					and		eax,MK_CONTROL
					mov		fControl,eax
					.if !fControl && !fShift && !fMultiSel
						mov		eax,hMultiSel
						.if eax
						  @@:
							push	eax
							invoke GetParent,eax
							.if eax==hWin
								pop		eax
								jmp		@f
							.endif
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
						.endif
						.while hMultiSel
							invoke GetParent,hMultiSel
							invoke PostMessage,eax,WM_PAINT,0,0
							invoke DestroyMultiSel,hMultiSel
							mov		hMultiSel,eax
							.if !eax
								invoke PostMessage,hWin,uMsg,wParam,lParam
								jmp		Ex
							.endif
						.endw
					  @@:
						.if hMultiSel
							invoke SetCapture,hWin
							mov		eax,hMultiSel
						  @@:
							push	eax
							invoke GetParent,eax
							invoke MoveingRect,eax,lParam,0,nInx
							inc		nInx
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
						.else
							invoke GetWindowLong,hDEd,DEWM_READONLY	;ReadOnly
							push	eax
							invoke GetWindowLong,hDEd,DEWM_MEMORY
							pop		edx
							.if eax
								mov		eax,(DLGHEAD ptr [eax]).locked
								.if !eax && !edx
									invoke DestroySizeingRect
									mov		eax,(DIALOG ptr [esi]).ntype
									.if eax
										mov		edx,(DIALOG ptr [esi]).style
										and		edx,CCS_NORESIZE
										.if (eax==18 && !edx) || (eax==19 && !edx)
										.else
											invoke SetCapture,hWin
											invoke MoveingRect,hWin,lParam,0,0
											invoke MoveingRect,hWin,lParam,1,0
											invoke DialogTltSize,ParPt.x,ParPt.y
										.endif
									.else
										mov		fMultiSel,TRUE
										mov		eax,lParam
										mov		mousedown,eax
									.endif
								.endif
							.endif
						.endif
					.else
						invoke GetWindowLong,hWin,GWL_USERDATA
						mov		edx,(DIALOG ptr [eax]).style
						and		edx,CCS_NORESIZE
						mov		eax,(DIALOG ptr [eax]).ntype
						.if fShift && !fControl
							.if !eax || eax==3 || eax==11
								;Draw multisel rect
								mov		fMultiSel,TRUE
								mov		eax,lParam
								mov		mousedown,eax
							.endif
						.elseif !fShift && fControl
							.if eax
								.if (eax==18 && !edx) || (eax==19 && !edx)
								.else
									invoke CtlMultiSelect,hWin,lParam
									.if hMultiSel
										invoke PropertyList,-1
									.endif
								.endif
							.endif
						.endif
					.endif
				.endif
			.endif
			jmp		Ex
		.elseif eax==WM_MOUSEMOVE || eax==WM_NCMOUSEMOVE
			.if ToolBoxID
				invoke DrawingRect,hWin,lParam,1
			.elseif fMoveing
				.if hMultiSel
					mov		eax,hMultiSel
				  @@:
					push	eax
					invoke GetParent,eax
					push	eax
					invoke MoveingRect,eax,lParam,1,nInx
					pop		eax
					.if eax==hWin
						invoke DialogTltSize,ParPt.x,ParPt.y
					.endif
					inc		nInx
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
				.else
					invoke MoveingRect,hWin,lParam,1,0
					invoke DialogTltSize,ParPt.x,ParPt.y
				.endif
			.else
				.if fDrawing
					invoke DrawingRect,hWin,lParam,1
				.elseif fMultiSel
					mov		eax,mousedown
					mov		edx,lParam
					movsx	eax,ax
					movsx	edx,dx
					sub		eax,edx
					.if sdword ptr eax<0
						neg		eax
					.endif
					mov		ecx,eax
					mov		eax,mousedown
					mov		edx,lParam
					shr		eax,16
					shr		edx,16
					movsx	eax,ax
					movsx	edx,dx
					sub		eax,edx
					.if sdword ptr eax<0
						neg		eax
					.endif
					add		ecx,eax
					.if ecx>=2
						invoke DrawingRect,hWin,mousedown,0
						invoke DrawingRect,hWin,lParam,1
						mov		fMultiSel,FALSE
					.endif
				.endif
			.endif
			jmp		Ex
		.elseif eax==WM_LBUTTONUP || eax==WM_NCLBUTTONUP
			.if !fNoMouseUp
				.if fMoveing
					.if hMultiSel
						mov		eax,hMultiSel
						.while eax
							push	eax
							invoke GetParent,eax
							push	eax
							invoke MoveingRect,eax,lParam,2,nInx
							pop		eax
							invoke SizeingRect,eax,99
							inc		nInx
							mov		ecx,8
							pop		eax
							.while ecx
								push	ecx
								invoke GetWindowLong,eax,GWL_USERDATA
								pop		ecx
								dec		ecx
							.endw
						.endw
					.else
						invoke SetFocus,hPrp
						invoke MoveingRect,hWin,lParam,2,0
						invoke SizeingRect,hWin,FALSE
					.endif
					invoke ReleaseCapture
					mov		fMoveing,0
					invoke NotifyParent
				.elseif fDrawing
					push	ToolBoxID
					invoke DrawingRect,hWin,lParam,2
					pop		eax
					.if !eax
						.if hReSize
							invoke DestroySizeingRect
						.endif
						.while hMultiSel
							invoke DestroyMultiSel,hMultiSel
							mov		hMultiSel,eax
						.endw
						.if sdword ptr SizeRect.right<0
							mov		eax,SizeRect.left
							mov		SizeRect.right,eax
							mov		SizeRect.left,0
						.endif
						mov		eax,SizeRect.left
						add		SizeRect.right,eax
						.if  sdword ptr SizeRect.bottom<0
							mov		eax,SizeRect.top
							mov		SizeRect.bottom,eax
							mov		SizeRect.top,0
						.endif
						mov		eax,SizeRect.top
						add		SizeRect.bottom,eax
						mov		eax,TRUE
						.while eax
							add		esi,sizeof DIALOG
							mov		eax,(DIALOG ptr [esi]).hwnd
							.if eax && eax!=-1
								mov		eax,(DIALOG ptr [esi]).x
								mov		ecx,eax
								add		ecx,(DIALOG ptr [esi]).ccx
								.if (eax>=SizeRect.left && eax<=SizeRect.right) || (ecx>=SizeRect.left && ecx<=SizeRect.right) || (SizeRect.left>=eax && SizeRect.right<=ecx)
									mov		eax,(DIALOG ptr [esi]).y
									mov		ecx,eax
									add		ecx,(DIALOG ptr [esi]).ccy
									.if (eax>=SizeRect.top && eax<=SizeRect.bottom) || (ecx>=SizeRect.top && ecx<=SizeRect.bottom) || (SizeRect.top>=eax && SizeRect.bottom<=ecx)
										mov		eax,(DIALOG ptr [esi]).ntype
										.if eax!=18 && eax!=19
											mov		eax,(DIALOG ptr [esi]).hwnd
											invoke CtlMultiSelect,eax,lParam
											inc		nInx
										.endif
									.endif
								.endif
								mov		eax,TRUE
							.endif
						.endw
						.if nInx==1 && hMultiSel
							invoke GetParent,hMultiSel
							invoke SizeingRect,eax,FALSE
						.elseif hMultiSel
							invoke PropertyList,-1
						.endif
						invoke NotifyParent
					.endif
				.else
					.if !hMultiSel
						invoke SizeingRect,hWin,FALSE
					.endif
					invoke NotifyParent
				.endif
			.else
				mov		fNoMouseUp,FALSE
			.endif
			mov		fMultiSel,FALSE
			jmp		Ex
		.elseif eax==WM_SYSCOMMAND
			jmp		Ex
		.elseif eax==WM_SIZE
			mov		eax,(DIALOG ptr [esi]).ntype
			.if !eax
				invoke GetClientRect,hWin,addr rect
				sub		esi,sizeof DLGHEAD
				mov		eax,[esi].DLGHEAD.htlb 
				.if eax
					mov		hCtl,eax
					invoke GetWindowLong,eax,GWL_STYLE
					test	eax,CCS_NORESIZE
					.if ZERO?
						invoke MoveWindow,hCtl,0,0,rect.right,rect.bottom,TRUE
					.endif
				.endif
				mov		eax,[esi].DLGHEAD.hstb 
				.if eax
					mov		hCtl,eax
					invoke GetWindowLong,eax,GWL_STYLE
					test	eax,CCS_NORESIZE
					.if ZERO?
						invoke MoveWindow,hCtl,0,0,rect.right,rect.bottom,TRUE
					.endif
				.endif
			.endif
		.elseif eax==WM_NOTIFY
			mov		edx,lParam
			mov		eax,(NMHDR ptr [edx]).code
			.if eax==PGN_CALCSIZE
				mov		eax,[edx].NMPGCALCSIZE.dwFlag
				.if eax==PGF_CALCHEIGHT
					mov		[edx].NMPGCALCSIZE.iHeight,2048
				.else
					mov		[edx].NMPGCALCSIZE.iWidth,2048
				.endif
			.endif
			jmp		Ex
		.elseif eax==WM_SETCURSOR
			.if ToolBoxID
				invoke LoadCursor,0,IDC_CROSS
			.else
				invoke LoadCursor,0,IDC_ARROW
			.endif
			invoke SetCursor,eax
			jmp		Ex
		.elseif eax==WM_PAINT
			.if hTabSet
				invoke InvalidateRect,hTabSet,NULL,TRUE
			.endif
		.endif
	.endif
	invoke CallWindowProc,lpOldProc,hWin,uMsg,wParam,lParam
	ret
  Ex:
	xor		eax,eax
	ret

CtlProc endp

CtlDummyProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	pt:POINT
	LOCAL	ptp:POINT
	LOCAL	hPar:HWND

	mov		eax,uMsg
	.if eax>=WM_MOUSEFIRST && eax<=WM_MOUSELAST
		mov		eax,lParam
		and		eax,0FFFFh
		mov		pt.x,eax
		mov		eax,lParam
		shr		eax,16
		mov		pt.y,eax
		invoke ClientToScreen,hWin,addr pt
		invoke GetParent,hWin
		mov		hPar,eax
		mov		ptp.x,0
		mov		ptp.y,0
		invoke ClientToScreen,hPar,addr ptp
		mov		eax,pt.x
		sub		eax,ptp.x
		mov		edx,pt.y
		sub		edx,ptp.y
		shl		edx,16
		or		edx,eax
		invoke PostMessage,hPar,uMsg,wParam,edx
		xor		eax,eax
		ret
	.endif
	invoke GetWindowLong,hWin,GWL_USERDATA
	invoke CallWindowProc,eax,hWin,uMsg,wParam,lParam
	ret

CtlDummyProc endp

CtlEnumProc proc hWin:HWND,lParam:LPARAM

	.if lParam
		invoke SetWindowLong,hWin,GWL_WNDPROC,offset CtlDummyProc
		invoke SetWindowLong,hWin,GWL_USERDATA,eax
	.else
		invoke GetWindowLong,hWin,GWL_STYLE
		or		eax,WS_DISABLED
		invoke SetWindowLong,hWin,GWL_STYLE,eax
	.endif
	mov		eax,TRUE
	ret

CtlEnumProc endp

MakeDlgFont proc uses esi,lpMem:DWORD
	LOCAL	lf:LOGFONT

	mov		esi,lpMem
	.if [esi].DLGHEAD.hfont
		invoke DeleteObject,[esi].DLGHEAD.hfont
	.endif
	invoke RtlZeroMemory,addr lf,size lf
	mov		eax,[esi].DLGHEAD.fontht
	mov		lf.lfHeight,eax
	movzx	eax,[esi].DLGHEAD.weight
	mov		lf.lfWeight,eax
	movzx	eax,[esi].DLGHEAD.italic
	mov		lf.lfItalic,al
	movzx	eax,[esi].DLGHEAD.charset
	mov		lf.lfCharSet,al
	invoke strcpy,addr lf.lfFaceName,addr [esi].DLGHEAD.font
	invoke CreateFontIndirect,addr lf
	mov		[esi].DLGHEAD.hfont,eax
	ret

MakeDlgFont endp

DesignDummyProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	ps:PAINTSTRUCT
	LOCAL	rect:RECT
	LOCAL	hDlg:HWND
	LOCAL	buffer[16]:BYTE
	LOCAL	pt:POINT
	LOCAL	hMem:DWORD

	mov		eax,uMsg
	.if eax>=WM_MOUSEFIRST && eax<=WM_MOUSELAST
		invoke GetWindowLong,hWin,GWL_ID
		.if eax==123456789
			.if  uMsg==WM_LBUTTONDOWN
				mov		eax,lParam
				movsx	eax,ax
				mov		pt.x,eax
				mov		eax,lParam
				shr		eax,16
				movsx	eax,ax
				mov		pt.y,eax
				invoke ClientToScreen,hWin,addr pt
				invoke GetParent,hWin
				invoke GetWindowLong,eax,DEWM_MEMORY
				push	ebx
				mov		ebx,eax
				add		ebx,sizeof DLGHEAD
				invoke ScreenToClient,[ebx].DIALOG.hwnd,addr pt
				mov		hDlg,0
				mov		ecx,pt.x
				mov		edx,pt.y
				.while [ebx].DIALOG.hwnd
					.if [ebx].DIALOG.hwnd!=-1
						mov		eax,[ebx].DIALOG.x
						add		eax,[ebx].DIALOG.ccx
						.if ecx>=[ebx].DIALOG.x && ecx<eax
							mov		eax,[ebx].DIALOG.y
							add		eax,[ebx].DIALOG.ccy
							.if edx>=[ebx].DIALOG.y && edx<eax
								mov		eax,[ebx].DIALOG.hwnd
								mov		hDlg,eax
								mov		hMem,ebx
							.endif
						.endif
					.endif
					add		ebx,sizeof DIALOG
				.endw
				.if hDlg
					.while hMultiSel
						invoke GetParent,hMultiSel
						invoke DestroyMultiSel,hMultiSel
						mov		hMultiSel,eax
					.endw
					mov		fMultiSel,FALSE
					invoke DestroySizeingRect
					invoke SizeingRect,hDlg,FALSE
					mov		ebx,hMem
					.if ![ebx].DIALOG.ntype
						invoke DestroyWindow,hTabSet
						pop		ebx
						xor		eax,eax
						mov		hTabSet,eax
						ret
					.else
						test	wParam,MK_CONTROL
						.if ZERO?
							invoke SetNewTab,hDlg,nTabSet
							invoke UpdateCtl,hDlg
						.else
							mov		eax,[ebx].DIALOG.tab
							mov		nTabSet,eax
						.endif
						inc		nTabSet
					.endif
				.endif
				pop		ebx
			.endif
		.else
			invoke GetParent,hWin
			invoke SendMessage,eax,uMsg,wParam,lParam
		.endif
		xor		eax,eax
	.elseif eax==WM_PAINT
		invoke GetWindowLong,hWin,GWL_ID
		.if eax==123456789
			invoke BeginPaint,hWin,addr ps
			push	ebx
			invoke GetParent,hWin
			invoke GetWindowLong,eax,DEWM_MEMORY
			mov		ebx,eax
			add		ebx,sizeof DLGHEAD
			mov		eax,[ebx].DIALOG.hwnd
			mov		hDlg,eax
			add		ebx,sizeof DIALOG
			.while [ebx].DIALOG.hwnd
				.if [ebx].DIALOG.hwnd!=-1
					.if [ebx].DIALOG.hcld
						invoke UpdateWindow,[ebx].DIALOG.hcld
					.endif
					mov		eax,[ebx].DIALOG.x
					mov		rect.left,eax
					add		eax,22
					mov		rect.right,eax
					mov		eax,[ebx].DIALOG.y
					mov		rect.top,eax
					add		eax,18
					mov		rect.bottom,eax
					invoke ClientToScreen,hDlg,addr rect.left
					invoke ClientToScreen,hDlg,addr rect.right
					invoke ScreenToClient,hWin,addr rect.left
					invoke ScreenToClient,hWin,addr rect.right
					invoke GetStockObject,BLACK_BRUSH
					invoke FillRect,ps.hdc,addr rect,eax
					invoke ResEdBinToDec,[ebx].DIALOG.tab,addr buffer
					invoke SetTextColor,ps.hdc,0FFFFFFh
					invoke SetBkMode,ps.hdc,TRANSPARENT
					invoke SendMessage,hTlt,WM_GETFONT,0,0
					invoke SelectObject,ps.hdc,eax
					push	eax
					invoke DrawText,ps.hdc,addr buffer,-1,addr rect,DT_CENTER or DT_VCENTER or DT_SINGLELINE
					pop		eax
					invoke SelectObject,ps.hdc,eax
				.endif
				add		ebx,sizeof DIALOG
			.endw
			invoke EndPaint,hWin,addr ps
			pop		ebx
			xor		eax,eax
		.else
			jmp		ExDef
		.endif
	.else
  ExDef:
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
	.endif
	ret

DesignDummyProc endp

CreateCtl proc uses esi edi,lpDlgCtl:DWORD
	LOCAL	hCtl:HWND
	LOCAL	hCld:HWND
	LOCAL	hTmp:DWORD
	LOCAL	ws:DWORD
	LOCAL	wsex:DWORD
	LOCAL	tci:TCITEM
	LOCAL	lvi:LVITEM
	LOCAL	tpe:DWORD
	LOCAL	lpclass:DWORD
	LOCAL	tbb:TBBUTTON
	LOCAL	tbab:TBADDBITMAP
	LOCAL	hMdi:HWND
	LOCAL	buffer[512]:BYTE
	LOCAL	rect:RECT
	LOCAL	val:DWORD
	LOCAL	cbei:COMBOBOXEXITEM
	LOCAL	hFnt:DWORD
	LOCAL	rbbi:REBARBANDINFO
	LOCAL	nimg:DWORD
	LOCAL	hdi:HD_ITEM

	mov		edi,lpDlgCtl
	assume edi:ptr DIALOG
	push	[edi].ntype
	pop		tpe
	invoke GetTypePtr,tpe
	mov		esi,eax
	push	(TYPES ptr [esi]).lpclass
	pop		lpclass
	push	[edi].style
	pop		ws
	or		ws,WS_ALWAYS
	push	[edi].exstyle
	pop		wsex
	and		wsex,0F7FFFh
	and		wsex,-1 xor (WS_EX_LAYERED or WS_EX_TRANSPARENT or WS_EX_MDICHILD)
	.if !tpe
		and		ws,-1 xor (WS_POPUP or WS_DISABLED or WS_MINIMIZE or WS_MAXIMIZE or WS_VISIBLE)
		mov		eax,[edi].hpar
		mov		hMdi,eax
		mov		edx,edi
		sub		edx,sizeof DLGHEAD
		invoke MakeDlgFont,edx
		mov		hFnt,eax
	.else
		and		ws,-1 xor (WS_POPUP or WS_DISABLED or WS_MINIMIZE or WS_MAXIMIZE)
		mov		eax,[edi].hpar
		invoke GetWindowLong,eax,GWL_USERDATA
		mov		edx,eax
		mov		eax,(DIALOG ptr [edx]).hpar
		mov		hMdi,eax
		sub		edx,sizeof DLGHEAD
		mov		eax,[edx].DLGHEAD.hfont
		mov		hFnt,eax
		.if tpe==2
			or		ws,SS_NOTIFY
		.elseif tpe==14
			or		ws,LVS_SHAREIMAGELISTS
		.elseif tpe==16
			and		ws,-1 xor UDS_AUTOBUDDY
		.endif
	.endif
	invoke ConvertCaption,addr buffer,addr [edi].caption
	.if tpe==0
		invoke CreateWindowEx,wsex,lpclass,addr buffer,
		ws,0,0,0,0,
		[edi].hpar,NULL,hInstance,0
		mov		hCtl,eax
	.elseif tpe==1
		invoke CreateWindowEx,wsex,lpclass,addr buffer,
		ws,[edi].x,[edi].y,[edi].ccx,[edi].ccy,
		[edi].hpar,0,hInstance,0
		mov		hCtl,eax
		invoke SetWindowPos,hCtl,HWND_TOP,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE
	.elseif tpe==3
		invoke CreateWindowEx,0,addr szStaticClass,NULL,
		WS_CHILD or WS_VISIBLE or SS_LEFT or SS_NOTIFY or WS_CLIPSIBLINGS,
		[edi].x,[edi].y,[edi].ccx,[edi].ccy,
		[edi].hpar,0,hInstance,0
		mov		hCtl,eax
		invoke SetWindowPos,hCtl,HWND_TOP,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE
		invoke CreateWindowEx,wsex,lpclass,addr buffer,
		ws,0,0,[edi].ccx,[edi].ccy,
		hCtl,0,hInstance,0
		mov		hCld,eax
		mov		[edi].hcld,eax
	.elseif tpe==11
		invoke CreateWindowEx,0,addr szStaticClass,NULL,
		WS_CHILD or WS_VISIBLE or SS_LEFT or SS_NOTIFY or WS_CLIPSIBLINGS,
		[edi].x,[edi].y,[edi].ccx,[edi].ccy,
		[edi].hpar,0,hInstance,0
		mov		hCtl,eax
		invoke SetWindowPos,hCtl,HWND_TOP,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE
		or		ws,WS_DISABLED
		invoke CreateWindowEx,wsex,lpclass,addr buffer,
		ws,0,0,[edi].ccx,[edi].ccy,
		hCtl,0,hInstance,0
		mov		hCld,eax
		mov		[edi].hcld,eax
		mov		eax,[edi].style
		and		eax,TCS_VERTICAL
	.elseif tpe==17
		mov		edx,ws
		and		edx,WS_BORDER or SS_SUNKEN
		or		edx,WS_CHILD or WS_VISIBLE or SS_LEFT or SS_NOTIFY or WS_CLIPSIBLINGS
		invoke CreateWindowEx,wsex,addr szStaticClass,NULL,edx,
		[edi].x,[edi].y,[edi].ccx,[edi].ccy,
		[edi].hpar,0,hInstance,0
		mov		hCtl,eax
		invoke GetWindowRect,hCtl,addr rect
		mov		eax,rect.right
		sub		eax,rect.left
		push	eax
		invoke GetClientRect,hCtl,addr rect
		pop		eax
		sub		eax,rect.right
		mov		val,eax
		.if [edi].caption
			push	ebx
			push	esi
			invoke GetWindowLong,hPrj,0
			mov		esi,eax
			.while [esi].PROJECT.hmem
				.if [esi].PROJECT.ntype==TPE_RESOURCE
					mov		ebx,[esi].PROJECT.hmem
					.while [ebx].RESOURCEMEM.szname || [ebx].RESOURCEMEM.value
						mov		eax,[edi].style
						and		eax,SS_TYPEMASK
						.if ([ebx].RESOURCEMEM.ntype==0 && eax==SS_BITMAP) || ([ebx].RESOURCEMEM.ntype==2 && eax==SS_ICON)
							invoke strcmp,addr [edi].caption,addr [ebx].RESOURCEMEM.szname
							.if eax
								mov		buffer,'#'
								invoke ResEdBinToDec,[ebx].RESOURCEMEM.value,addr buffer[1]
								invoke strcmp,addr [edi].caption,addr buffer
							.endif
							.if !eax
								mov		ax,word ptr [ebx].RESOURCEMEM.szfile
								.if ah!=':'
									invoke strcpy,addr buffer,addr szProjectPath
									invoke strcat,addr buffer,addr szBS
									invoke strcat,addr buffer,addr [ebx].RESOURCEMEM.szfile
								.else
									invoke strcpy,addr buffer,addr [ebx].RESOURCEMEM.szfile
								.endif
								.if [ebx].RESOURCEMEM.ntype==0
									mov		edx,IMAGE_BITMAP
								.else
									mov		edx,IMAGE_ICON
								.endif
								mov		eax,TRUE
								jmp		ImgFound
							.endif
						.endif
						lea		ebx,[ebx+sizeof RESOURCEMEM]
					.endw
				.endif
				lea		esi,[esi+sizeof PROJECT]
				xor		eax,eax
			.endw
		  ImgFound:
			pop		esi
			pop		ebx
			.if eax
				mov		nimg,edx
				.if edx==IMAGE_BITMAP
					invoke LoadImage,NULL,addr buffer,edx,NULL,NULL,LR_LOADFROMFILE
				.else
					invoke LoadImage,NULL,addr buffer,edx,NULL,NULL,LR_LOADFROMFILE or LR_DEFAULTSIZE
				.endif
				mov		[edi].himg,eax
				xor		edx,edx
			.else
				mov		edx,offset szICODLG
			.endif
		.else
			mov		edx,offset szICODLG
		.endif
		mov		ecx,ws
		and		ecx,-1 xor (WS_BORDER or SS_SUNKEN or SS_NOTIFY)
		or		ecx,WS_CLIPSIBLINGS or WS_CLIPCHILDREN
		invoke CreateWindowEx,0,lpclass,edx,ecx,0,0,[edi].ccx,[edi].ccy,hCtl,0,hInstance,0
		mov		hCld,eax
		mov		[edi].hcld,eax
		.if [edi].himg
			invoke SendMessage,hCld,STM_SETIMAGE,nimg,[edi].himg
		.endif
		mov		eax,[edi].style
		and		eax,SS_CENTERIMAGE
		.if !eax
			invoke GetWindowRect,hCld,addr rect
			mov		eax,rect.right
			sub		eax,rect.left
			mov		edx,rect.bottom
			sub		edx,rect.top
			.if eax && edx
				add		eax,val
				add		edx,val
				mov		[edi].ccx,eax
				mov		[edi].ccy,edx
				invoke MoveWindow,hCtl,[edi].x,[edi].y,[edi].ccx,[edi].ccy,TRUE
			.endif
		.else
			invoke InvalidateRect,hCtl,NULL,TRUE
		.endif
		invoke SetWindowPos,hCtl,HWND_TOP,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE
	.elseif tpe==23
		and		ws,0FFFF0000h
		or		ws,SS_LEFT or SS_NOTIFY
		invoke CreateWindowEx,wsex,addr szStaticClass,addr buffer,
		ws,[edi].x,[edi].y,[edi].ccx,[edi].ccy,
		[edi].hpar,0,hInstance,0
		mov		hCtl,eax
		invoke SetWindowPos,hCtl,HWND_TOP,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE
	.elseif tpe==25
		and		ws,-1 xor SS_NOTIFY
		invoke CreateWindowEx,0,addr szStaticClass,NULL,
		WS_CHILD or WS_VISIBLE or SS_LEFT or SS_NOTIFY or WS_CLIPSIBLINGS,
		[edi].x,[edi].y,[edi].ccx,[edi].ccy,
		[edi].hpar,0,hInstance,0
		mov		hCtl,eax
		invoke SetWindowPos,hCtl,HWND_TOP,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE
		invoke CreateWindowEx,wsex,lpclass,NULL,
		ws,0,0,[edi].ccx,[edi].ccy,
		hCtl,0,hInstance,0
		mov		hCld,eax
		mov		[edi].hcld,eax
	.elseif tpe==26
		or		ws,WS_DISABLED
		invoke CreateWindowEx,0,addr szStaticClass,NULL,
		WS_CHILD or WS_VISIBLE or SS_LEFT or SS_NOTIFY or WS_CLIPSIBLINGS,
		[edi].x,[edi].y,[edi].ccx,[edi].ccy,
		[edi].hpar,0,hInstance,0
		mov		hCtl,eax
		invoke SetWindowPos,hCtl,HWND_TOP,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE
		invoke CreateWindowEx,wsex,lpclass,NULL,
		ws,0,0,[edi].ccx,[edi].ccy,
		hCtl,0,hInstance,0
		mov		hCld,eax
		mov		[edi].hcld,eax
	.elseif tpe==27
		invoke CreateWindowEx,0,addr szStaticClass,NULL,
		WS_CHILD or WS_VISIBLE or SS_LEFT or SS_NOTIFY or WS_CLIPSIBLINGS,
		[edi].x,[edi].y,[edi].ccx,[edi].ccy,
		[edi].hpar,0,hInstance,0
		mov		hCtl,eax
		invoke SetWindowPos,hCtl,HWND_TOP,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE
		invoke CreateWindowEx,wsex,lpclass,NULL,
		ws,0,0,[edi].ccx,[edi].ccy,
		hCtl,0,hInstance,0
		mov		hCld,eax
		mov		[edi].hcld,eax
	.elseif tpe==29 || tpe==30
		invoke CreateWindowEx,0,addr szStaticClass,NULL,
		WS_CHILD or WS_VISIBLE or SS_LEFT or SS_NOTIFY or WS_CLIPSIBLINGS,
		[edi].x,[edi].y,[edi].ccx,[edi].ccy,
		[edi].hpar,0,hInstance,0
		mov		hCtl,eax
		invoke CreateWindowEx,wsex,lpclass,addr buffer,
		ws,0,0,[edi].ccx,[edi].ccy,
		hCtl,0,hInstance,0
		mov		hCld,eax
	.elseif tpe==31
		or		ws,4
		invoke CreateWindowEx,wsex,lpclass,addr buffer,
		ws,[edi].x,[edi].y,[edi].ccx,[edi].ccy,
		[edi].hpar,0,hInstance,0
		mov		hCtl,eax
		mov		rbbi.cbSize,sizeof REBARBANDINFO
		mov		rbbi.fMask,RBBIM_STYLE or RBBIM_CHILD or RBBIM_SIZE or RBBIM_CHILDSIZE
		mov		rbbi.fStyle,RBBS_GRIPPERALWAYS or RBBS_CHILDEDGE
		invoke CreateWindowEx,0,addr szStaticClass,addr [edi].idname,
		WS_CHILD or WS_VISIBLE or SS_LEFT or WS_CLIPSIBLINGS,
		0,0,[edi].ccx,[edi].ccy,
		hCtl,0,hInstance,0
		mov		rbbi.hwndChild,eax
		invoke SendMessage,eax,WM_SETFONT,hFnt,0
		mov		eax,[edi].ccx
		mov		rbbi.lx,eax
		mov		eax,[edi].ccx
		mov		rbbi.cxMinChild,eax
		mov		eax,[edi].ccy
		mov		rbbi.cyMinChild,eax
		invoke SendMessage,hCtl,RB_INSERTBAND,0,addr rbbi
		invoke SetWindowPos,hCtl,HWND_TOP,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE
	.else
		invoke CreateWindowEx,wsex,lpclass,addr buffer,
		ws,[edi].x,[edi].y,[edi].ccx,[edi].ccy,
		[edi].hpar,0,hInstance,0
		mov		hCtl,eax
		invoke SetWindowPos,hCtl,HWND_TOP,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE
	.endif
	push	hCtl
	pop		[edi].hwnd
	invoke SetWindowLong,hCtl,GWL_USERDATA,edi
	invoke SetWindowLong,hCtl,GWL_WNDPROC,offset CtlProc
	mov		[edi].oldproc,eax
	mov		eax,tpe
	.if !eax
		mov		edx,edi
		sub		edx,sizeof DLGHEAD
		mov		eax,[edi].ccy
		.if [edx].DLGHEAD.menuid
			;Adjust for menu
			add		eax,19
		.endif
		invoke SetWindowPos,hCtl,HWND_TOP,DlgX,DlgY,[edi].ccx,eax,SWP_SHOWWINDOW
	.elseif eax==7
		invoke SendMessage,hCtl,CB_ADDSTRING,0,addr [edi].idname
		invoke SendMessage,hCtl,CB_SETCURSEL,0,0
		invoke EnumChildWindows,hCtl,addr CtlEnumProc,0
	.elseif eax==8
		invoke SendMessage,hCtl,LB_ADDSTRING,0,addr [edi].idname
		invoke SendMessage,hCtl,LB_ADDSTRING,0,addr [edi].idname
	.elseif eax==11
		mov		tci.imask,TCIF_TEXT
		lea		eax,[edi].idname
		mov		tci.pszText,eax
		mov		tci.cchTextMax,6
		invoke SendMessage,hCld,TCM_INSERTITEM,0,addr tci
		invoke SendMessage,hCld,TCM_INSERTITEM,1,addr tci
	.elseif eax==12
		invoke SendMessage,hCtl,PBM_STEPIT,0,0
		invoke SendMessage,hCtl,PBM_STEPIT,0,0
		invoke SendMessage,hCtl,PBM_STEPIT,0,0
	.elseif eax==13
		invoke SendMessage,hCtl,TVM_SETIMAGELIST,0,hPrjIml
		invoke Do_TreeViewAddNode,hCtl,TVI_ROOT,NULL,addr [edi].idname,0,0,0
		mov		hTmp,eax
		invoke Do_TreeViewAddNode,hCtl,hTmp,NULL,addr [edi].idname,1,1,1
		mov		edx,eax
		push	eax
		invoke Do_TreeViewAddNode,hCtl,edx,NULL,addr [edi].idname,2,2,2
		pop		eax
		invoke SendMessage,hCtl,TVM_EXPAND,TVE_EXPAND,eax
		invoke SendMessage,hCtl,TVM_EXPAND,TVE_EXPAND,hTmp
	.elseif eax==14
		invoke SendMessage,hCtl,LVM_SETCOLUMNWIDTH,-1,LVSCW_AUTOSIZE
		invoke SendMessage,hCtl,LVM_SETIMAGELIST,LVSIL_SMALL,hDlgIml
		mov		lvi.imask,LVIF_TEXT or LVIF_IMAGE
		mov		lvi.iItem,0
		mov		lvi.iSubItem,0
		lea		eax,[edi].idname
		mov		lvi.pszText,eax
		mov		lvi.cchTextMax,13
		mov		lvi.iImage,0
		invoke SendMessage,hCtl,LVM_INSERTITEM,0,addr lvi
		mov		lvi.iItem,1
		mov		lvi.iImage,1
		invoke SendMessage,hCtl,LVM_INSERTITEM,0,addr lvi
		mov		lvi.iItem,2
		mov		lvi.iImage,2
		invoke SendMessage,hCtl,LVM_INSERTITEM,0,addr lvi
	.elseif eax==18
		invoke SendMessage,hCtl,TB_BUTTONSTRUCTSIZE,sizeof TBBUTTON,0
		invoke SendMessage,hCtl,TB_SETBUTTONSIZE,0,00100010h
		invoke SendMessage,hCtl,TB_SETBITMAPSIZE,0,00100010h
		mov		tbab.hInst,HINST_COMMCTRL
		mov		tbab.nID,IDB_STD_SMALL_COLOR
		invoke SendMessage,hCtl,TB_ADDBITMAP,12,addr tbab
		mov		tbb.fsState,TBSTATE_ENABLED
		mov		tbb.dwData,0
		mov		tbb.iString,0
		mov		tbb.iBitmap,0
		mov		tbb.idCommand,0
		mov		tbb.fsStyle,TBSTYLE_SEP
		invoke SendMessage,hCtl,TB_ADDBUTTONS,1,addr tbb
		mov		tbb.iBitmap,0
		mov		tbb.idCommand,1
		mov		tbb.fsStyle,TBSTYLE_BUTTON
		invoke SendMessage,hCtl,TB_ADDBUTTONS,1,addr tbb
		mov		tbb.iBitmap,1
		mov		tbb.idCommand,2
		mov		tbb.fsStyle,TBSTYLE_BUTTON
		invoke SendMessage,hCtl,TB_ADDBUTTONS,1,addr tbb
		mov		tbb.iBitmap,2
		mov		tbb.idCommand,3
		mov		tbb.fsStyle,TBSTYLE_BUTTON
		invoke SendMessage,hCtl,TB_ADDBUTTONS,1,addr tbb
		mov		tbb.iBitmap,0
		mov		tbb.idCommand,0
		mov		tbb.fsStyle,TBSTYLE_SEP
		invoke SendMessage,hCtl,TB_ADDBUTTONS,1,addr tbb
		mov		tbb.iBitmap,3
		mov		tbb.idCommand,4
		mov		tbb.fsStyle,TBSTYLE_BUTTON
		invoke SendMessage,hCtl,TB_ADDBUTTONS,1,addr tbb
		mov		tbb.iBitmap,4
		mov		tbb.idCommand,5
		mov		tbb.fsStyle,TBSTYLE_BUTTON
		invoke SendMessage,hCtl,TB_ADDBUTTONS,1,addr tbb
		mov		tbb.iBitmap,0
		mov		tbb.idCommand,0
		mov		tbb.fsStyle,TBSTYLE_SEP
		invoke SendMessage,hCtl,TB_ADDBUTTONS,1,addr tbb
		invoke GetWindowLong,hMdi,DEWM_MEMORY
		.if eax
			push	hCtl
			pop		(DLGHEAD ptr [eax]).htlb
		.endif
	.elseif eax==19
		invoke GetWindowLong,hMdi,DEWM_MEMORY
		.if eax
			push	hCtl
			pop		(DLGHEAD ptr [eax]).hstb
		.endif
	.elseif eax==20
		invoke EnumChildWindows,hCtl,addr CtlEnumProc,0
	.elseif eax==24
		invoke SendMessage,hCtl,CBEM_SETIMAGELIST,0,hDlgIml
		mov		cbei._mask,CBEIF_IMAGE or CBEIF_TEXT or CBEIF_SELECTEDIMAGE
		mov		cbei.iItem,0
		lea		eax,[edi].idname
		mov		cbei.pszText,eax
		mov		cbei.cchTextMax,32
		mov		cbei.iImage,0
		mov		cbei.iSelectedImage,0
		invoke SendMessage,hCtl,CBEM_INSERTITEM,0,addr cbei
		mov		cbei.iItem,1
		mov		cbei.iImage,1
		mov		cbei.iSelectedImage,1
		invoke SendMessage,hCtl,CBEM_INSERTITEM,0,addr cbei
		invoke SendMessage,hCtl,CB_SETCURSEL,0,0
		invoke EnumChildWindows,hCtl,addr CtlEnumProc,TRUE
	.elseif eax==26
		invoke SendMessage,[edi].hcld,IPM_SETADDRESS,0,080818283h
	.elseif eax==27
		.if [edi].caption
			push	ebx
			push	esi
			invoke GetWindowLong,hPrj,0
			mov		esi,eax
			.while [esi].PROJECT.hmem
				.if [esi].PROJECT.ntype==TPE_RESOURCE
					mov		ebx,[esi].PROJECT.hmem
					.while [ebx].RESOURCEMEM.szname || [ebx].RESOURCEMEM.value
						.if [ebx].RESOURCEMEM.ntype==3
							invoke strcmp,addr [edi].caption,addr [ebx].RESOURCEMEM.szname
							.if eax
								mov		buffer,'#'
								invoke ResEdBinToDec,[ebx].RESOURCEMEM.value,addr buffer[1]
								invoke strcmp,addr [edi].caption,addr buffer
							.endif
							.if !eax
								mov		ax,word ptr [ebx].RESOURCEMEM.szfile
								.if ah!=':'
									invoke strcpy,addr buffer,addr szProjectPath
									invoke strcat,addr buffer,addr szBS
									invoke strcat,addr buffer,addr [ebx].RESOURCEMEM.szfile
								.else
									invoke strcpy,addr buffer,addr [ebx].RESOURCEMEM.szfile
								.endif
								invoke SendMessage,[edi].hcld,ACM_OPEN,0,addr buffer
								jmp		AviFound
							.endif
						.endif
						lea		ebx,[ebx+sizeof RESOURCEMEM]
					.endw
				.endif
				lea		esi,[esi+sizeof PROJECT]
				xor		eax,eax
			.endw
		  AviFound:
			pop		esi
			pop		ebx
		.endif
	.elseif eax==28
		invoke SendMessage,hCtl,HKM_SETHOTKEY,(HOTKEYF_CONTROL shl 8) or VK_A,0
	.elseif eax==29 || eax==30
		invoke CreateWindowEx,0,addr szStaticClass,addr [edi].idname,
		WS_CHILD or WS_VISIBLE or SS_LEFT or WS_CLIPSIBLINGS,
		0,0,[edi].ccx,[edi].ccy,
		hCld,0,hInstance,0
		push	eax
		invoke SendMessage,eax,WM_SETFONT,hFnt,0
		pop		eax
		invoke SendMessage,hCld,PGM_SETCHILD,0,eax
		invoke SendMessage,hCld,PGM_SETBUTTONSIZE,0,10
		invoke SendMessage,hCld,PGM_SETPOS,0,1
		invoke EnumChildWindows,hCtl,addr CtlEnumProc,TRUE
	.elseif tpe==32
		mov		hdi.imask,HDI_TEXT or HDI_WIDTH or HDI_FORMAT
		mov		hdi.lxy,100
		lea		eax,[edi].idname
		mov		hdi.pszText,eax
		mov		hdi.fmt,HDF_STRING
		invoke SendMessage,hCtl,HDM_INSERTITEM,0,addr hdi
	.elseif eax>=NoOfButtons
		invoke CreateWindowEx,WS_EX_TRANSPARENT,addr szDlgEditDummyClass,NULL,WS_CHILD or WS_VISIBLE,0,0,0,0,hCtl,NULL,hInstance,0
		mov		[edi].hdmy,eax
		invoke SetWindowPos,eax,HWND_TOP,0,0,[edi].ccx,[edi].ccy,0
		invoke SendMessage,hCtl,WM_USER+9999,0,edi
	.endif
	mov		eax,[edi].hcld
	.if !eax
		mov		eax,[edi].hwnd
	.endif
	invoke SendMessage,eax,WM_SETFONT,hFnt,0
	invoke SetChanged,TRUE,hMdi
	.if [edi].ntype==3 || [edi].ntype==11
		;Groupbox and TabControl
		invoke SendToBack,hCtl
	.endif
	mov		eax,hCtl
	assume edi:nothing
	ret

CreateCtl endp

CreateNewCtl proc uses esi edi,hOwner:DWORD,nType:DWORD,x:DWORD,y:DWORD,ccx:DWORD,ccy:DWORD
	LOCAL	buffer[MaxName]:BYTE

	invoke GetWindowLong,hDEd,DEWM_MEMORY
	.if eax
		invoke GetFreeDlg,eax
		mov		edi,eax
		invoke GetTypePtr,nType
		mov		esi,eax
		;Set default ctl data
		mov		(DIALOG ptr [edi]).hdmy,0
		mov		eax,hOwner
		mov		(DIALOG ptr [edi]).hpar,eax
		mov		eax,nType
		mov		(DIALOG ptr [edi]).ntype,eax
		mov		eax,(TYPES ptr [esi]).ID
		mov		(DIALOG ptr [edi]).ntypeid,eax
		mov		eax,(TYPES ptr [esi]).style
		mov		(DIALOG ptr [edi]).style,eax
		mov		eax,(TYPES ptr [esi]).exstyle
		mov		(DIALOG ptr [edi]).exstyle,eax
		mov		eax,x
		mov		(DIALOG ptr [edi]).x,eax
		mov		eax,y
		mov		(DIALOG ptr [edi]).y,eax
		mov		eax,ccx
		mov		(DIALOG ptr [edi]).ccx,eax
		mov		eax,ccy
		mov		(DIALOG ptr [edi]).ccy,eax
		xor		eax,eax
		mov		(DIALOG ptr [edi]).dux,eax
		mov		(DIALOG ptr [edi]).duy,eax
		mov		(DIALOG ptr [edi]).duccx,eax
		mov		(DIALOG ptr [edi]).duccy,eax
		invoke strcpyn,addr buffer,(TYPES ptr [esi]).lpidname,MaxName
		invoke GetUnikeName,addr buffer
		invoke strcpyn,addr (DIALOG ptr [edi]).idname,addr buffer,MaxName
		invoke strcpyn,addr (DIALOG ptr [edi]).caption,(TYPES ptr [esi]).lpcaption,MaxCap
		.if !nType
			invoke GetFreeProjectitemID,TPE_DIALOG
			mov		(DIALOG ptr [edi]).id,eax
			;Set default DLGHEAD info
			mov		esi,edi
			sub		esi,sizeof DLGHEAD
			assume esi:ptr DLGHEAD
			inc		eax
			mov		[esi].ctlid,eax
			mov		[esi].class,0
			mov		[esi].menuid,0
			invoke strcpy,addr [esi].font,addr DlgFN
			mov		eax,DlgFS
			mov		[esi].fontsize,eax
			mov		eax,DlgFH
			mov		[esi].fontht,eax
		.else
			invoke GetFreeID
			mov		(DIALOG ptr [edi]).id,eax
			invoke GetFreeTab
			mov		(DIALOG ptr [edi]).tab,eax
			.if nType==23
				invoke strcpy,addr [edi].DIALOG.class,addr szUserControlClass
			.endif
		.endif
		assume esi:nothing
		invoke CreateCtl,edi
		push	eax
		invoke GetWindowLong,hDEd,DEWM_MEMORY
		invoke UpdateRAEdit,eax
		invoke NotifyParent
		pop		eax
	.endif
	ret

CreateNewCtl endp

CopyCtl proc uses esi edi ebx
	LOCAL	hCtl:HWND

	.if hReSize
		invoke GetWindowLong,hReSize,GWL_USERDATA
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
			invoke GetWindowLong,hCtl,GWL_USERDATA
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
	LOCAL	hCtl:HWND
	LOCAL	hPar:HWND
	LOCAL	px:DWORD
	LOCAL	py:DWORD
	LOCAL	nbr:DWORD

	mov		nbr,0
	mov		esi,offset dlgpaste
	assume esi:ptr DIALOG
	mov		px,9999
	mov		py,9999
	push	esi
  @@:
	mov		eax,[esi].hwnd
	.if eax
		mov		eax,[esi].x
		.if (px<80000000 && eax<80000000 && eax<px) || (px>80000000 && eax>80000000 && eax<px) || (px<80000000 && eax>80000000)
			mov		px,eax
		.endif
		mov		eax,[esi].y
		.if (py<80000000 && eax<80000000 && eax<py) || (py>80000000 && eax>80000000 && eax<py) || (py<80000000 && eax>80000000)
			mov		py,eax
		.endif
		add		esi,sizeof DIALOG
		jmp		@b
	.endif
	pop		esi
  @@:
	mov		eax,[esi].hwnd
	.if eax
		invoke GetWindowLong,hDEd,DEWM_MEMORY
		.if eax
			push	eax
			mov		edx,eax
			mov		edx,[edx].DLGHEAD.ctlid
			add		eax,sizeof DLGHEAD
			push	(DIALOG ptr [eax]).hwnd
			pop		hPar
			push	hPar
			pop		[esi].hpar
			mov		[esi].id,edx
			invoke IsFreeID,edx
			.if eax==FALSE
				invoke GetFreeID
				mov		[esi].id,eax
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
			sub		[esi].x,eax
			mov		eax,py
			sub		[esi].y,eax
			xor		eax,eax
			mov		[esi].himg,eax
			mov		[esi].dux,eax
			mov		[esi].duy,eax
			mov		[esi].duccx,eax
			mov		[esi].duccy,eax
			invoke GetTypePtr,[esi].ntype
			invoke strcpyn,addr [esi].idname,(TYPES ptr [eax]).lpidname,MaxName
			invoke GetUnikeName,addr [esi].idname
			invoke CreateCtl,esi
			mov		hCtl,eax
			invoke GetWindowLong,hCtl,GWL_USERDATA
			mov		esi,eax
			mov		[esi].tab,-1
			invoke GetFreeTab
			mov		[esi].tab,eax
			invoke SizeingRect,hCtl,FALSE
			invoke SetChanged,TRUE,0
			pop		esi
			push	hCtl
			pop		[esi].hwnd
			add		esi,sizeof DIALOG
			inc		nbr
			jmp		@b
		.endif
	.endif
	.if nbr>1
		invoke DestroySizeingRect
		mov		esi,offset dlgpaste
		.while nbr
			.if hMultiSel
				invoke GetParent,hMultiSel
				push	eax
				invoke DestroyMultiSel,hMultiSel
				mov		hMultiSel,eax
				pop		eax
				invoke MultiSelRect,eax,TRUE
			.endif
			mov		eax,[esi].hwnd
			invoke MultiSelRect,eax,FALSE
			add		esi,sizeof DIALOG
			dec		nbr
		.endw
	.endif
	invoke GetWindowLong,hDEd,DEWM_MEMORY
	invoke UpdateRAEdit,eax
	invoke NotifyParent
	assume esi:nothing
	ret

PasteCtl endp

DeleteCtl proc uses esi
	LOCAL	hCtl:HWND

	.if hReSize
		invoke GetWindowLong,hReSize,GWL_USERDATA
		.if eax
			mov		esi,eax
			assume esi:ptr DIALOG
			mov		eax,[esi].ntype
			;Don't delete DialogBox
			.if eax
				invoke GetWindowLong,hDEd,DEWM_MEMORY
				mov		edx,eax
				mov		eax,(DLGHEAD ptr [edx]).undo
				mov		[esi].undo,eax
				mov		(DLGHEAD ptr [edx]).undo,esi
				mov		[esi].hwnd,-1
				invoke DeleteTab,[esi].tab
				mov		eax,[esi].himg
				.if eax
					invoke DeleteObject,eax
					mov		[esi].himg,0
				.endif
				.if [esi].hcld
					invoke GetStockObject,SYSTEM_FONT
					invoke SendMessage,[esi].hcld,WM_SETFONT,eax,0
					invoke DestroyWindow,[esi].hcld
				.endif
				invoke GetStockObject,SYSTEM_FONT
				invoke SendMessage,hReSize,WM_SETFONT,eax,0
				invoke DestroyWindow,hReSize
				invoke DestroySizeingRect
				invoke SetChanged,TRUE,0
				invoke GetWindowLong,hDEd,DEWM_DIALOG
				invoke SizeingRect,eax,FALSE
			.endif
			assume esi:nothing
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
			invoke GetWindowLong,hCtl,GWL_USERDATA
			.if eax
				mov		esi,eax
				assume esi:ptr DIALOG
				mov		eax,[esi].ntype
				;Don't delete DialogBox
				.if eax
					invoke GetWindowLong,hDEd,DEWM_MEMORY
					push	(DLGHEAD ptr [eax]).undo
					mov		(DLGHEAD ptr [eax]).undo,esi
					mov		[esi].hwnd,-1
					pop		[esi].undo
					invoke DeleteTab,[esi].tab
					mov		eax,[esi].himg
					.if eax
						invoke DeleteObject,eax
						mov		[esi].himg,0
					.endif
					.if [esi].hcld
						invoke GetStockObject,SYSTEM_FONT
						invoke SendMessage,[esi].hcld,WM_SETFONT,eax,0
						invoke DestroyWindow,[esi].hcld
					.endif
					invoke GetStockObject,SYSTEM_FONT
					invoke SendMessage,hCtl,WM_SETFONT,eax,0
					invoke DestroyWindow,hCtl
				.endif
				assume esi:nothing
			.endif
		.endw
		invoke SetChanged,TRUE,0
		invoke GetWindowLong,hDEd,DEWM_DIALOG
		invoke SizeingRect,eax,FALSE
	.endif
	invoke SendMessage,hDEd,WM_LBUTTONDOWN,0,0
	invoke GetWindowLong,hDEd,DEWM_MEMORY
	invoke UpdateRAEdit,eax
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
				invoke GetWindowLong,eax,GWL_USERDATA
				mov		esi,eax
				assume esi:ptr DIALOG
				mov		eax,[esi].x
				.if sdword ptr eax<xpmin
					mov		xpmin,eax
				.endif
				add		eax,[esi].ccx
				.if sdword ptr eax>xpmax
					mov		xpmax,eax
				.endif
				mov		eax,[esi].y
				.if sdword ptr eax<ypmin
					mov		ypmin,eax
				.endif
				add		eax,[esi].ccy
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
			mov		ebx,hMultiSel
			invoke GetParent,ebx
			invoke GetParent,eax
			mov		edx,eax
			invoke GetClientRect,edx,addr rect
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
			.while ebx
				mov		fChanged,FALSE
				invoke GetParent,ebx
				mov		hCtl,eax
				invoke GetWindowLong,hCtl,GWL_USERDATA
				mov		esi,eax
				mov		eax,nFun
				.if eax==ALIGN_DLGVCENTER
					mov		eax,ypmin
					.if eax
						sub		[esi].y,eax
						inc		fChanged
					.endif
				.elseif eax==ALIGN_DLGHCENTER
					mov		eax,xpmin
					.if eax
						sub		[esi].x,eax
						inc		fChanged
					.endif
				.endif
				call	SnapGrid
				call	MoveIt
				call	MoveMarkers
			.endw
		.else
			invoke GetParent,ebx
			invoke GetWindowLong,eax,GWL_USERDATA
			mov		esi,eax
			assume esi:ptr DIALOG
			mov		eax,[esi].x
			mov		xp,eax
			mov		eax,[esi].y
			mov		yp,eax
			mov		eax,[esi].ccx
			mov		wt,eax
			mov		eax,[esi].ccy
			mov		ht,eax
			.while ebx
				mov		fChanged,FALSE
				invoke GetParent,ebx
				mov		hCtl,eax
				invoke GetWindowLong,hCtl,GWL_USERDATA
				mov		esi,eax
				mov		eax,nFun
				.if eax==ALIGN_LEFT
					mov		eax,xp
					.if eax!=[esi].x
						mov		[esi].x,eax
						inc		fChanged
					.endif
				.elseif eax==ALIGN_CENTER
					mov		eax,wt
					shr		eax,1
					add		eax,xp
					mov		edx,[esi].ccx
					shr		edx,1
					add		edx,[esi].x
					sub		eax,edx
					.if eax
						add		[esi].x,eax
						inc		fChanged
					.endif
				.elseif eax==ALIGN_RIGHT
					mov		eax,xp
					add		eax,wt
					sub		eax,[esi].ccx
					.if eax!=[esi].x
						mov		[esi].x,eax
						inc		fChanged
					.endif
				.elseif eax==ALIGN_TOP
					mov		eax,yp
					.if eax!=[esi].y
						mov		[esi].y,eax
						inc		fChanged
					.endif
				.elseif eax==ALIGN_MIDDLE
					mov		eax,ht
					shr		eax,1
					add		eax,yp
					mov		edx,[esi].ccy
					shr		edx,1
					add		edx,[esi].y
					sub		eax,edx
					.if eax
						add		[esi].y,eax
						inc		fChanged
					.endif
				.elseif eax==ALIGN_BOTTOM
					mov		eax,yp
					add		eax,ht
					sub		eax,[esi].ccy
					.if eax!=[esi].y
						mov		[esi].y,eax
						inc		fChanged
					.endif
				.elseif eax==SIZE_WIDTH
					mov		eax,wt
					.if eax!=[esi].ccx
						mov		[esi].ccx,eax
						inc		fChanged
					.endif
				.elseif eax==SIZE_HEIGHT
					mov		eax,ht
					.if eax!=[esi].ccy
						mov		[esi].ccy,eax
						inc		fChanged
					.endif
				.elseif eax==SIZE_BOTH
					mov		eax,wt
					.if eax!=[esi].ccx
						mov		[esi].ccx,eax
						inc		fChanged
					.endif
					mov		eax,ht
					.if eax!=[esi].ccy
						mov		[esi].ccy,eax
						inc		fChanged
					.endif
				.endif
				call	SnapGrid
				call	MoveIt
				call	MoveMarkers
			.endw
		.endif
	.else
		mov		eax,nFun
		.if (eax==ALIGN_DLGVCENTER || eax==ALIGN_DLGHCENTER) && hReSize
			;Single select
			mov		eax,hReSize
			mov		hCtl,eax
			invoke GetWindowLong,hCtl,GWL_USERDATA
			mov		esi,eax
			assume esi:ptr DIALOG
			mov		eax,[esi].x
			mov		xpmin,eax
			mov		eax,[esi].y
			mov		ypmin,eax
			mov		eax,[esi].ccx
			add		eax,[esi].x
			mov		xpmax,eax
			mov		eax,[esi].ccy
			add		eax,[esi].y
			mov		ypmax,eax
			invoke GetParent,hCtl
			mov		edx,eax
			invoke GetClientRect,edx,addr rect
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
					sub		[esi].y,eax
					inc		fChanged
				.endif
			.elseif eax==ALIGN_DLGHCENTER
				mov		eax,xpmin
				.if eax
					sub		[esi].x,eax
					inc		fChanged
				.endif
			.endif
			call	SnapGrid
			call	MoveIt
			invoke GetWindowLong,hDEd,DEWM_MEMORY
			mov		eax,[eax].DLGHEAD.locked
			invoke SizeingRect,hCtl,FALSE
		.endif
	.endif
	invoke GetWindowLong,hDEd,DEWM_MEMORY
	invoke UpdateRAEdit,eax
	invoke NotifyParent
	ret

MoveIt:
	.if fChanged
		xor		eax,eax
		mov		[esi].dux,eax
		mov		[esi].duy,eax
		mov		[esi].duccx,eax
		mov		[esi].duccy,eax
		invoke MoveWindow,hCtl,[esi].x,[esi].y,[esi].ccx,[esi].ccy,TRUE
		mov		eax,[esi].hcld
		.if eax
			invoke MoveWindow,eax,0,0,[esi].ccx,[esi].ccy,TRUE
		.endif
		invoke SetChanged,TRUE,hDEd
	.endif
	retn

SnapGrid:
;//Edit
	call RSnapToGrid
	.if fRSnapToGrid
		mov		eax,[esi].x
		xor		edx,edx
		idiv	Gridcx
		imul	Gridcx
		.if eax!=[esi].x
			mov		[esi].x,eax
			inc		fChanged
		.endif
		mov		eax,[esi].ccx
		add		eax,[esi].x
		xor		edx,edx
		idiv	Gridcx
		imul	Gridcx
		sub		eax,[esi].x
		inc		eax
		.if eax!=[esi].ccx
			mov		[esi].ccx,eax
			inc		fChanged
		.endif
		mov		eax,[esi].y
		xor		edx,edx
		idiv	Gridcy
		imul	Gridcy
		.if eax!=[esi].y
			mov		[esi].y,eax
			inc		fChanged
		.endif
		mov		eax,[esi].ccy
		add		eax,[esi].y
		xor		edx,edx
		idiv	Gridcy
		imul	Gridcy
		sub		eax,[esi].y
		inc		eax
		.if eax!=[esi].ccy
			mov		[esi].ccy,eax
			inc		fChanged
		.endif
	.endif
	retn

MoveMarkers:
	mov		ecx,8
	.while ecx
		push	ecx
		.if ecx==8
			mov		eax,[esi].ccx
			sub		eax,6
			mov		edx,[esi].ccy
			sub		edx,6
		.elseif ecx==7
			mov		eax,[esi].ccx
			shr		eax,1
			sub		eax,3
			mov		edx,[esi].ccy
			sub		edx,6
		.elseif ecx==6
			xor		eax,eax
			mov		edx,[esi].ccy
			sub		edx,6
		.elseif ecx==5
			mov		eax,[esi].ccx
			sub		eax,6
			mov		edx,[esi].ccy
			shr		edx,1
			sub		edx,3
		.elseif ecx==4
			xor		eax,eax
			mov		edx,[esi].ccy
			shr		edx,1
			sub		edx,3
		.elseif ecx==3
			mov		eax,[esi].ccx
			sub		eax,6
			xor		edx,edx
		.elseif ecx==2
			mov		eax,[esi].ccx
			shr		eax,1
			sub		eax,3
			xor		edx,edx
		.elseif ecx==1
			xor		eax,eax
			xor		edx,edx
		.endif
		invoke MoveWindow,ebx,eax,edx,6,6,TRUE
		invoke GetWindowLong,ebx,GWL_USERDATA
		mov		ebx,eax
		pop		ecx
		dec		ecx
	.endw
	retn

AlignSizeCtl endp

UpdateCtl proc uses esi,hCtl:DWORD
	LOCAL	ws:DWORD
	LOCAL	wsex:DWORD

	invoke GetWindowLong,hCtl,GWL_USERDATA
	mov		esi,eax
	assume esi:ptr DIALOG
	.if [esi].ntype
		mov		eax,[esi].himg
		.if eax
			invoke DeleteObject,eax
			mov		[esi].himg,0
		.endif
		.if [esi].hcld
			invoke GetStockObject,SYSTEM_FONT
			invoke SendMessage,[esi].hcld,WM_SETFONT,eax,0
			invoke DestroyWindow,[esi].hcld
		.endif
		invoke GetStockObject,SYSTEM_FONT
		invoke SendMessage,hCtl,WM_SETFONT,eax,0
		invoke DestroyWindow,hCtl
		invoke CreateCtl,esi
		mov		hCtl,eax
	  @@:
		add		esi,sizeof DIALOG
		mov		eax,[esi].hwnd
		cmp		eax,-1
		je		@b
		.if eax
			invoke SetWindowPos,hCtl,eax,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE
		.endif
	.else
		push	[esi].style
		pop		ws
		or		ws,WS_ALWAYS
		and		ws,-1 xor (WS_POPUP or WS_DISABLED or WS_MINIMIZE or WS_MAXIMIZE)
		push	[esi].exstyle
		pop		wsex
		and		wsex,-1 xor (WS_EX_LAYERED or WS_EX_TRANSPARENT)
		invoke SetWindowLong,hCtl,GWL_STYLE,ws
		invoke SetWindowLong,hCtl,GWL_EXSTYLE,wsex
		invoke SetWindowText,hCtl,addr [esi].caption
		mov		edx,esi
		sub		edx,sizeof DLGHEAD
		mov		eax,[esi].ccy
		.if [edx].DLGHEAD.menuid
			;Adjust for menu
			add		eax,19
		.endif
		invoke SetWindowPos,hCtl,0,0,0,[esi].ccx,eax,SWP_NOMOVE or SWP_NOZORDER or SWP_FRAMECHANGED
	.endif
	invoke UpdateWindow,hCtl
	.if !fSizeing
		.if !hMultiSel
			invoke SizeingRect,hCtl,FALSE
		.endif
	.else
		m2m		hReSize,hCtl
	.endif
	invoke SetChanged,TRUE,0
	assume esi:nothing
	invoke GetWindowLong,hDEd,DEWM_MEMORY
	invoke UpdateRAEdit,eax
	invoke NotifyParent
	mov		eax,hCtl
	ret

UpdateCtl endp

MoveMultiSel proc uses esi,x:DWORD,y:DWORD

	mov		eax,hMultiSel
	.while eax
		push	eax
		invoke GetParent,eax
		push	eax
		invoke GetWindowLong,eax,GWL_USERDATA
		mov		esi,eax
		.if x
			mov		eax,(DIALOG ptr [esi]).x
			add		eax,x
			xor		edx,edx
			idiv	x
			imul	x
			mov		(DIALOG ptr [esi]).x,eax
		.endif
		.if y
			mov		eax,(DIALOG ptr [esi]).y
			add		eax,y
			xor		edx,edx
			idiv	y
			imul	y
			mov		(DIALOG ptr [esi]).y,eax
		.endif
		xor		eax,eax
		mov		[esi].DIALOG.dux,eax
		mov		[esi].DIALOG.duy,eax
		mov		[esi].DIALOG.duccx,eax
		mov		[esi].DIALOG.duccy,eax
		pop		eax
		invoke MoveWindow,eax,(DIALOG ptr [esi]).x,(DIALOG ptr [esi]).y,(DIALOG ptr [esi]).ccx,(DIALOG ptr [esi]).ccy,TRUE
		mov		ecx,8
		pop		eax
		.while ecx
			push	ecx
			invoke GetWindowLong,eax,GWL_USERDATA
			pop		ecx
			dec		ecx
		.endw
	.endw
	invoke SetChanged,TRUE,0
	invoke GetWindowLong,hDEd,DEWM_MEMORY
	invoke UpdateRAEdit,eax
	invoke NotifyParent
	ret

MoveMultiSel endp

SizeMultiSel proc uses esi,x:DWORD,y:DWORD

	mov		eax,hMultiSel
	.while eax
		push	eax
		invoke GetParent,eax
		push	eax
		invoke GetWindowLong,eax,GWL_USERDATA
		mov		esi,eax
		.if x
			mov		eax,(DIALOG ptr [esi]).ccx
			add		eax,x
			.if sdword ptr eax>0
				xor		edx,edx
				idiv	x
				imul	x
				mov		(DIALOG ptr [esi]).ccx,eax
			.endif
		.endif
		.if y
			mov		eax,(DIALOG ptr [esi]).ccy
			add		eax,y
			.if sdword ptr eax>0
				xor		edx,edx
				idiv	y
				imul	y
				mov		(DIALOG ptr [esi]).ccy,eax
			.endif
		.endif
		xor		eax,eax
		mov		[esi].DIALOG.dux,eax
		mov		[esi].DIALOG.duy,eax
		mov		[esi].DIALOG.duccx,eax
		mov		[esi].DIALOG.duccy,eax
		pop		eax
		invoke MoveWindow,eax,(DIALOG ptr [esi]).x,(DIALOG ptr [esi]).y,(DIALOG ptr [esi]).ccx,(DIALOG ptr [esi]).ccy,TRUE
		mov		ecx,8
		pop		eax
		.while ecx
			push	ecx
			push	eax
			.if ecx==8
				mov		ecx,(DIALOG ptr [esi]).ccx
				sub		ecx,6
				mov		edx,(DIALOG ptr [esi]).ccy
				sub		edx,6
			.elseif ecx==7
				mov		ecx,(DIALOG ptr [esi]).ccx
				sub		ecx,6
				shr		ecx,1
				mov		edx,(DIALOG ptr [esi]).ccy
				sub		edx,6
			.elseif ecx==6
				xor		ecx,ecx
				mov		edx,(DIALOG ptr [esi]).ccy
				sub		edx,6
			.elseif ecx==5
				mov		ecx,(DIALOG ptr [esi]).ccx
				sub		ecx,6
				mov		edx,(DIALOG ptr [esi]).ccy
				sub		edx,6
				shr		edx,1
			.elseif ecx==4
				xor		ecx,ecx
				mov		edx,(DIALOG ptr [esi]).ccy
				sub		edx,6
				shr		edx,1
			.elseif ecx==3
				mov		ecx,(DIALOG ptr [esi]).ccx
				sub		ecx,6
				xor		edx,edx
			.elseif ecx==2
				mov		ecx,(DIALOG ptr [esi]).ccx
				sub		ecx,6
				shr		ecx,1
				xor		edx,edx
			.elseif ecx==1
				xor		ecx,ecx
				xor		edx,edx
			.endif
			push	eax
			invoke MoveWindow,eax,ecx,edx,6,6,TRUE
			pop		eax
			invoke UpdateWindow,eax
			pop		eax
			invoke GetWindowLong,eax,GWL_USERDATA
			pop		ecx
			dec		ecx
		.endw
	.endw
	invoke SetChanged,TRUE,0
	invoke GetWindowLong,hDEd,DEWM_MEMORY
	invoke UpdateRAEdit,eax
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
			invoke GetWindowLong,eax,GWL_USERDATA
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
		invoke GetWindowLong,eax,GWL_USERDATA
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
		invoke SetChanged,TRUE,0
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
		invoke GetWindowLong,eax,GWL_USERDATA
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

	invoke GetWindowLong,hCtl,GWL_USERDATA
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
		mov		eax,(DIALOG ptr [esi]).undo
		.if eax<=lpSt && eax
			add		(DIALOG ptr [esi]).undo,sizeof DIALOG
		.endif
		rep movsb
		sub		esi,sizeof DIALOG
		cmp		esi,lpFirst
		jge		@b
		lea		esi,buffer
		mov		edi,lpFirst
		mov		ecx,sizeof DIALOG
		rep movsb
		invoke GetWindowLong,hDEd,DEWM_DIALOG
		invoke UpdateDialog,eax
		invoke GetWindowLong,hDEd,DEWM_MEMORY
		mov		esi,eax
		mov		eax,[esi].DLGHEAD.undo
		.if eax<=lpSt && eax
			add		[esi].DLGHEAD.undo,sizeof DIALOG
		.endif
		invoke SetChanged,TRUE,0
		invoke NotifyParent
	.endif
	ret

SendToBack endp

BringToFront proc uses esi edi,hCtl:HWND
	LOCAL	buffer[512]:BYTE
	LOCAL	lpSt:DWORD

	invoke GetWindowLong,hCtl,GWL_USERDATA
	mov		lpSt,eax
	mov		esi,eax
	lea		edi,buffer
	mov		ecx,sizeof DIALOG
	rep movsb
	mov		edi,esi
	sub		edi,sizeof DIALOG
  @@:
	mov		eax,(DIALOG ptr [esi]).undo
	.if eax>lpSt
		sub		(DIALOG ptr [esi]).undo,sizeof DIALOG
	.endif
	mov		ecx,sizeof DIALOG
	rep movsb
	mov		eax,dword ptr [esi]
	or		eax,eax
	jne		@b
	lea		esi,buffer
	mov		ecx,sizeof DIALOG
	rep movsb
	invoke GetWindowLong,hDEd,DEWM_DIALOG
	invoke UpdateDialog,eax
	invoke GetWindowLong,hDEd,DEWM_MEMORY
	mov		esi,eax
	mov		eax,[esi].DLGHEAD.undo
	.if eax>lpSt
		sub		[esi].DLGHEAD.undo,sizeof DIALOG
	.endif
	invoke SetChanged,TRUE,0
	invoke NotifyParent
	ret

BringToFront endp

ResetSize proc uses edi,lpMem:DWORD

	mov		edi,lpMem
	add		edi,sizeof DLGHEAD
	xor		eax,eax
	.while [edi].DIALOG.hwnd
		mov		[edi].DIALOG.dux,eax
		mov		[edi].DIALOG.duy,eax
		mov		[edi].DIALOG.duccx,eax
		mov		[edi].DIALOG.duccy,eax
		add		edi,sizeof DIALOG
	.endw
	ret

ResetSize endp

DrawingRect proc hWin:HWND,lParam:LPARAM,nFun:DWORD
	LOCAL	pt:POINT
	LOCAL	hPar:DWORD

	mov		eax,lParam
	and		eax,0FFFFh
	cwde
	mov		pt.x,eax
	mov		eax,lParam
	shr		eax,16
	cwde
	mov		pt.y,eax
;//Edit
	call RSnapToGrid
	.if fRSnapToGrid
		mov		eax,pt.x
		xor		edx,edx
		idiv	Gridcx
		imul	Gridcx
		mov		pt.x,eax
		mov		eax,pt.y
		xor		edx,edx
		idiv	Gridcy
		imul	Gridcy
		mov		pt.y,eax
	.endif
	invoke FindParent,hWin
	mov		hPar,eax
	.if nFun==0
		mov		fDrawing,TRUE
		invoke SetCapture,hWin
		invoke ClientToScreen,hWin,addr pt
		mov		eax,pt.x
		mov		MousePtDown.x,eax
		mov		CtlRect.left,eax
		mov		CtlRect.right,eax
		mov		eax,pt.y
		mov		MousePtDown.y,eax
		mov		CtlRect.top,eax
		mov		CtlRect.bottom,eax
		mov		fNoParent,TRUE
		invoke DlgDrawRect,hPar,addr CtlRect,0,0
		mov		fNoParent,FALSE
		invoke CopyRect,addr SizeRect,addr CtlRect
	.elseif nFun==1
		.if fDrawing
;//Edit
			call RSnapToGrid
			.if fRSnapToGrid
				inc		pt.x
				inc		pt.y
			.endif
			invoke ClientToScreen,hWin,addr pt
			mov		eax,pt.x
			sub		eax,MousePtDown.x
			mov		pt.x,eax
			mov		eax,pt.y
			sub		eax,MousePtDown.y
			mov		pt.y,eax
			invoke CopyRect,addr SizeRect,addr CtlRect
			mov		eax,pt.x
			add		SizeRect.right,eax
			mov		eax,pt.y
			add		SizeRect.bottom,eax
			invoke DlgDrawRect,hPar,addr SizeRect,1,0
			invoke DialogTltSize,pt.x,pt.y
		.endif
	.elseif nFun==2
		mov		fDrawing,FALSE
		invoke DlgDrawRect,hPar,addr SizeRect,2,0
		mov		ParPt.x,0
		mov		ParPt.y,0
		invoke ClientToScreen,hPar,addr ParPt
		mov		eax,ParPt.x
		sub		SizeRect.left,eax
		sub		SizeRect.right,eax
		mov		eax,ParPt.y
		sub		SizeRect.top,eax
		sub		SizeRect.bottom,eax
		mov		eax,SizeRect.left
		.if sdword ptr eax>SizeRect.right
			xchg	eax,SizeRect.right
			mov		SizeRect.left,eax
		.endif
		sub		SizeRect.right,eax
		mov		eax,SizeRect.top
		.if sdword ptr eax>SizeRect.bottom
			xchg	eax,SizeRect.bottom
			mov		SizeRect.top,eax
		.endif
		sub		SizeRect.bottom,eax
		invoke ReleaseCapture
		mov		eax,ToolBoxID
		.if eax>=1 && eax<nButtons
			push	eax
			mov		ecx,sizeof TYPES
			mul		ecx
			mov		ecx,offset ctltypes
			lea		ecx,[ecx+eax]
			.if SizeRect.right<=1
				mov		SizeRect.right,20
;//Edit			
				call RSnapToGrid
				.if fRSnapToGrid
					mov		eax,SizeRect.left
					add		eax,[ecx].TYPES.xsize
					xor		edx,edx
					idiv	Gridcx
					imul	Gridcx
					sub		eax,SizeRect.left
					inc		eax
					mov		SizeRect.right,eax
				.endif
			.endif
			.if SizeRect.bottom<=1
				mov		SizeRect.bottom,20
;//Edit				
				call RSnapToGrid
				.if fRSnapToGrid
					mov		eax,SizeRect.top
					add		eax,[ecx].TYPES.ysize
					xor		edx,edx
					idiv	Gridcy
					imul	Gridcy
					sub		eax,SizeRect.top
					inc		eax
					mov		SizeRect.bottom,eax
				.endif
			.endif
			pop		eax
			invoke CreateNewCtl,hPar,eax,SizeRect.left,SizeRect.top,SizeRect.right,SizeRect.bottom
			.if eax
				invoke SizeingRect,eax,FALSE
			.endif
			.if !fNoResetToolbox
				invoke ToolBoxReset
			.endif
			invoke NotifyParent
		.endif
		invoke ShowWindow,hTlt,SW_HIDE
	.endif
  Ex:
	ret

DrawingRect endp

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

EditDlgProc proc uses ebx esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	hDC:HDC
	LOCAL	mDC:HDC
	LOCAL	rect:RECT
	LOCAL	rect1:RECT
	LOCAL	ws:DWORD
	LOCAL	wsex:DWORD
	LOCAL	ps:PAINTSTRUCT
	LOCAL	ptW:POINT
	LOCAL	ptM:POINT
	LOCAL	ptA:POINT
	LOCAL	buffer[512]:BYTE
	LOCAL	buffer1[64]:BYTE
	LOCAL	buffer2[64]:BYTE
	LOCAL	nInx:DWORD

	mov		eax,uMsg
	.if eax==WM_NCCALCSIZE
		.if wParam==TRUE
			invoke GetWindowLong,hWin,GWL_USERDATA
			sub		eax,sizeof DLGHEAD
			mov		esi,eax
			mov		al,[esi].DLGHEAD.menuid
			.if al
				mov		esi,lParam
				add		(RECT ptr [esi]).top,19
			.endif
		.endif
	.elseif eax==WM_DESTROY
		invoke GetWindowLong,hWin,GWL_USERDATA
		.if eax
			sub		eax,sizeof DLGHEAD
			mov		esi,eax
			.while hMultiSel
				invoke DestroyMultiSel,hMultiSel
				mov		hMultiSel,eax
			.endw
			.if [esi].DLGHEAD.hfont
				invoke DeleteObject,[esi].DLGHEAD.hfont
				mov		[esi].DLGHEAD.hfont,0
			.endif
			add		esi,sizeof DLGHEAD+sizeof DIALOG
			.while [esi].DIALOG.hwnd
				.if [esi].DIALOG.hwnd!=-1
					.if [esi].DIALOG.hcld
						invoke DestroyWindow,[esi].DIALOG.hcld
					.endif
					.if [esi].DIALOG.hdmy
						invoke DestroyWindow,[esi].DIALOG.hdmy
					.endif
					invoke DestroyWindow,[esi].DIALOG.hwnd
				.endif
				add		esi,sizeof DIALOG
			.endw
		.endif
	.elseif eax==WM_NCPAINT
		mov		MnuHigh,FALSE
		invoke GetWindowLong,hWin,GWL_USERDATA
		sub		eax,sizeof DLGHEAD
		mov		esi,eax
		mov		al,[esi].DLGHEAD.menuid
		.if al
			mov		nInx,0
			invoke GetMnuString,addr [esi].DLGHEAD.menuid,addr buffer
			mov		[esi].DLGHEAD.lpmnu,eax
			invoke GetWindowDC,hWin
			mov		hDC,eax
			invoke CreateCompatibleDC,hDC
			mov		mDC,eax
			invoke GetWindowRect,hWin,addr rect

			invoke GetCursorPos,addr ptM
			mov		eax,rect.left
			sub		ptM.x,eax
			mov		eax,rect.top
			sub		ptM.y,eax

			invoke CopyRect,addr rect1,addr rect
			invoke GetWindowLong,hWin,GWL_STYLE
			mov		ws,eax
			invoke GetWindowLong,hWin,GWL_EXSTYLE
			mov		wsex,eax
			invoke AdjustWindowRectEx,addr rect1,ws,FALSE,wsex
			mov		eax,rect.left
			sub		eax,rect1.left
			mov		ptA.x,eax
			mov		eax,rect.top
			sub		eax,rect1.top
			mov		ptA.y,eax
			mov		edx,rect.top
			sub		edx,rect1.top
			mov		rect.top,edx
			add		edx,19
			mov		rect.bottom,edx
			sub		edx,rect.top
			mov		eax,rect.left
			sub		rect.right,eax
			sub		eax,rect1.left
			mov		rect.left,eax
			sub		rect.right,eax
			mov		eax,rect.right
			sub		eax,rect.left
			mov		rect1.left,0
			mov		rect1.top,0
			mov		rect1.right,eax
			mov		rect1.bottom,edx
			invoke CreateCompatibleBitmap,hDC,eax,edx
			invoke SelectObject,mDC,eax
			push	eax

			mov		eax,rect.left
			sub		ptM.x,eax
			mov		eax,rect.top
			sub		ptM.y,eax
			invoke FillRect,mDC,addr rect1,COLOR_BTNFACE+1
			invoke SetBkMode,mDC,TRANSPARENT
			invoke SetTextColor,mDC,0h
			invoke SendMessage,hTlt,WM_GETFONT,0,0
			invoke SelectObject,mDC,eax
			push	eax
			dec		rect1.bottom
		  @@:
			invoke GetStrItem,addr buffer,addr buffer1
			mov		al,buffer1
			.if al
				lea		esi,buffer1
				call	DrawMnu
				inc		nInx
				jmp		@b
			.endif
			inc		rect1.bottom
			invoke BitBlt,hDC,rect.left,rect.top,rect1.right,rect1.bottom,mDC,0,0,SRCCOPY
			pop		eax
			invoke SelectObject,mDC,eax
			pop		eax
			invoke SelectObject,mDC,eax
			invoke DeleteObject,eax
			invoke DeleteDC,mDC
			invoke ReleaseDC,hWin,hDC
			.if !fDrawing && !fSizeing && !fMoveing
				.if MnuHigh
					invoke GetCapture
					.if eax!=hPreview
						invoke SetCapture,hWin
					.endif
				.else
					invoke GetCapture
					.if eax==hWin
						invoke ReleaseCapture
					.endif
				.endif
			.endif
		.endif
	.elseif eax==WM_PAINT
		invoke GetClientRect,hWin,addr rect
		invoke BeginPaint,hWin,addr ps
		.if fGrid
			mov		eax,hGridBr
		.else
			mov		eax,COLOR_BTNFACE+1
		.endif
		invoke FillRect,ps.hdc,addr rect,eax
		invoke EndPaint,hWin,addr ps
		xor		eax,eax
		ret
	.endif
	invoke	DefWindowProc,hWin,uMsg,wParam,lParam
	ret

  DrawMnu:

	push	esi
	push	edi
	lea		edi,buffer2
	dec		esi
  @@:
	inc		esi
	mov		al,[esi]
	cmp		al,'&'
	je		@b
	mov		[edi],al
	inc		edi
	or		al,al
	jne		@b
	pop		edi
	lea		esi,buffer2
	invoke strlen,esi
	mov		ebx,eax
	invoke GetTextExtentPoint32,mDC,esi,ebx,addr ptW
	pop		esi
	mov		eax,rect1.left
	.if eax<ptM.x
		add		eax,ptW.x
		.if eax>ptM.x
			.if ptM.y>1 && ptM.y<19
				mov		eax,rect1.bottom
				add		eax,ptA.y
				shl		eax,16
				add		eax,rect1.left
				add		eax,ptA.x
				mov		MnuHigh,eax
				push	nInx
				pop		MnuInx
				push	rect1.right
				mov		eax,rect1.left
				add		eax,ptW.x
				mov		rect1.right,eax
				invoke GetSystemMetrics,SM_SWAPBUTTON
				.if eax
					mov		eax,VK_RBUTTON
				.else
					mov		eax,VK_LBUTTON
				.endif
				invoke GetAsyncKeyState,eax
				and		eax,8000h
				.if eax
					mov		eax,BDR_SUNKENOUTER
				.else
					mov		eax,BDR_RAISEDINNER
				.endif
				invoke DrawEdge,mDC,addr rect1,eax,BF_RECT
				pop		rect1.right
			.endif
		.endif
	.endif
	invoke strlen,esi
	mov		ebx,eax
	invoke DrawText,mDC,esi,ebx,addr rect1,DT_SINGLELINE or DT_VCENTER
	mov		eax,ptW.x
	add		rect1.left,eax
	push	rect1.left
	pop		MnuRight
	retn

EditDlgProc endp

SaveCtlSize proc uses ebx edx esi
	LOCAL	rect:RECT
	LOCAL	bux:DWORD
	LOCAL	buy:DWORD
	LOCAL	fNoChange:DWORD

	assume esi:ptr DIALOG
	mov		eax,[esi].dux
	or		eax,[esi].duy
	or		eax,[esi].duccx
	or		eax,[esi].duccy
	mov		fNoChange,eax
	mov		eax,[esi].ntype
	.if !eax
		mov		rect.left,eax
		mov		rect.top,eax
		mov		rect.right,eax
		mov		rect.bottom,eax
		.if ![esi].DIALOG.ntype
			invoke AdjustWindowRectEx,addr rect,[esi].style,FALSE,[esi].exstyle
		.endif
		mov		eax,[esi].ccx
		sub		eax,rect.right
		add		eax,rect.left
		mov		rect.right,eax
		mov		rect.left,0		
		mov		eax,[esi].ccy
		sub		eax,rect.bottom
		add		eax,rect.top
		mov		rect.bottom,eax
		mov		rect.top,0		
	.else
		push	[esi].ccx
		pop		rect.right
		push	[esi].ccy
		pop		rect.bottom
	.endif
	invoke GetDialogBaseUnits
	mov		edx,eax
	and		eax,0FFFFh
	mov		bux,eax
	shr		edx,16
	mov		buy,edx

	mov		eax,[esi].x
	shl		eax,2
	mov		ebx,dfntwt
	imul	ebx
	cdq
	mov		ebx,bux
	idiv	ebx
	cdq
	mov		ebx,fntwt
	idiv	ebx
	.if fNoChange
		mov		eax,[esi].dux
	.endif
	invoke SaveVal,eax,TRUE

	mov		eax,[esi].y
	shl		eax,3
	mov		ebx,dfntht
	mul		ebx
	cdq
	mov		ebx,buy
	idiv	ebx

	cdq
	mov		ebx,fntht
	idiv	ebx
	.if fNoChange
		mov		eax,[esi].duy
	.endif
	invoke SaveVal,eax,TRUE

	mov		eax,rect.right
	shl		eax,2+9
	mov		ebx,dfntwt
	mul		ebx
	xor		edx,edx
	mov		ebx,bux
	idiv	ebx

	xor		edx,edx
	mov		ebx,fntwt
	idiv	ebx
	shr		eax,9
	.if fNoChange
		mov		eax,[esi].duccx
	.endif
	invoke SaveVal,eax,TRUE

	mov		eax,rect.bottom
	shl		eax,3+9
	mov		ebx,dfntht
	mul		ebx
	xor		edx,edx
	mov		ebx,buy
	idiv	ebx
	xor		edx,edx
	mov		ebx,fntht
	idiv	ebx
	shr		eax,9
	.if fNoChange
		mov		eax,[esi].duccy
	.endif
	invoke SaveVal,eax,FALSE
	assume esi:nothing
	ret

SaveCtlSize endp

SaveType proc uses edx esi edi

	invoke GetTypePtr,[esi].DIALOG.ntype
	mov		edx,eax
	invoke SaveStr,edi,[edx].TYPES.lprc
	ret

SaveType endp

SaveName proc uses esi edi
	LOCAL	buffer[16]:BYTE

	assume esi:ptr DIALOG
	mov		al,[esi].idname
	.if al
		invoke SaveStr,edi,addr [esi].idname
	.else
		invoke ResEdBinToDec,[esi].id,addr buffer
		invoke SaveStr,edi,addr buffer
	.endif
	assume esi:nothing
	ret

SaveName endp

SaveDefine proc
	LOCAL	buffer[16]:BYTE

	assume esi:ptr DIALOG
	;Is ctl deleted
	mov		eax,[esi].hwnd
	.if eax!=-1
		mov		al,[esi].idname
		.if al && [esi].id
			invoke strcmpi,addr [esi].idname,addr szIDOK
			.if eax
				invoke strcmpi,addr [esi].idname,addr szIDCANCEL
				.if eax
					invoke strcmpi,addr [esi].idname,addr szIDC_STATIC
					.if !eax
						invoke GetWindowLong,hRes,GWL_STYLE
						test	eax,DES_DEFIDC_STATIC
						.if !ZERO?
							invoke GetWindowLong,hPrj,0
							mov		edx,eax
							push	eax
							invoke FindName,edx,addr szIDC_STATIC
							pop		edx
							.if !eax
								invoke AddName,edx,addr szIDC_STATIC,addr szIDC_STATICValue
							.endif
						.endif
						xor		eax,eax
					.endif
				.endif
			.endif
			.if eax
				invoke SaveStr,edi,addr szDEFINE
				add		edi,eax
				mov		al,' '
				stosb
				invoke SaveStr,edi,addr [esi].idname
				add		edi,eax
				mov		al,' '
				stosb
				invoke ResEdBinToDec,[esi].id,addr buffer
				invoke SaveStr,edi,addr buffer
				add		edi,eax
				mov		ax,0A0Dh
				stosw
			.endif
		.endif
	.endif
	assume esi:nothing
	ret

SaveDefine endp

SaveCaption proc

	assume esi:ptr DIALOG
	mov		al,22h
	stosb
	lea		edx,[esi].caption
  @@:
	mov		al,[edx]
	.if al=='"'
		mov		[edi],al
		inc		edi
	.endif
	mov		[edi],al
	inc		edx
	inc		edi
	or		al,al
	jne		@b
	dec		edi
	mov		al,22h
	stosb
	assume esi:nothing
	ret

SaveCaption endp

SaveClass proc
	LOCAL	lpclass:DWORD

	assume esi:ptr DIALOG
	invoke GetTypePtr,[esi].ntype
	push	(TYPES ptr [eax]).lpclass
	pop		lpclass

	mov		al,22h
	stosb
	invoke SaveStr,edi,lpclass
	add		edi,eax
	mov		al,22h
	stosb
	assume esi:nothing
	ret

SaveClass endp

SaveUDCClass proc

	assume esi:ptr DIALOG

	mov		al,22h
	stosb
	invoke SaveStr,edi,addr [esi].class
	add		edi,eax
	mov		al,22h
	stosb
	assume esi:nothing
	ret

SaveUDCClass endp

SaveDlgClass proc

	mov		al,[esi].DLGHEAD.class
	.if al
		invoke SaveStr,edi,addr szCLASS
		add		edi,eax
		mov		al,' '
		stosb
		mov		al,22h
		stosb
		invoke SaveStr,edi,addr [esi].DLGHEAD.class
		add		edi,eax
		mov		al,22h
		stosb
		mov		ax,0A0Dh
		stosw
	.endif
	ret

SaveDlgClass endp

SaveDlgFont proc
	LOCAL	buffer[512]:BYTE
	LOCAL	val:DWORD

	mov		al,[esi].DLGHEAD.font
	.if al
		invoke SaveStr,edi,addr szFONT
		add		edi,eax
		mov		al,' '
		stosb
		push	[esi].DLGHEAD.fontsize
		pop		val
		invoke ResEdBinToDec,val,addr buffer
		invoke SaveStr,edi,addr buffer
		add		edi,eax
		mov		al,','
		stosb
		mov		al,22h
		stosb
		invoke SaveStr,edi,addr [esi].DLGHEAD.font
		add		edi,eax
		mov		ax,',"'
		stosw
		movzx	eax,[esi].DLGHEAD.weight
		mov		val,eax
		invoke ResEdBinToDec,val,addr buffer
		invoke SaveStr,edi,addr buffer
		add		edi,eax
		mov		al,','
		stosb
		movzx	eax,[esi].DLGHEAD.italic
		mov		val,eax
		invoke ResEdBinToDec,val,addr buffer
		invoke SaveStr,edi,addr buffer
		add		edi,eax
		invoke GetWindowLong,hRes,GWL_STYLE
		test	eax,DES_BORLAND
		.if ZERO?
			movzx	eax,[esi].DLGHEAD.charset
			mov		val,eax
			mov		al,','
			stosb
			invoke ResEdBinToDec,val,addr buffer
			invoke SaveStr,edi,addr buffer
			add		edi,eax
		.endif
		mov		ax,0A0Dh
		stosw
	.endif
	ret

SaveDlgFont endp

SaveDlgMenu proc

	mov		al,[esi].DLGHEAD.menuid
	.if al
		invoke SaveStr,edi,addr szMENU
		add		edi,eax
		mov		al,' '
		stosb
		invoke SaveStr,edi,addr [esi].DLGHEAD.menuid
		add		edi,eax
		mov		ax,0A0Dh
		stosw
	.endif
	ret

SaveDlgMenu endp

SaveStyle proc uses ebx esi,nStyle:DWORD,nType:DWORD,fComma:DWORD
	LOCAL	nst:DWORD
	LOCAL	ncount:DWORD
	LOCAL	npos:DWORD

	.if fStyleHex
		invoke SaveHexVal,nStyle,fComma
	.else
		mov		nst,0
		mov		ncount,0
		mov		[npos],edi
		push	edi
		mov		dword ptr namebuff,0
		mov		ebx,offset types
		mov		eax,nType
		.while eax!=[ebx].RSTYPES.ctlid && [ebx].RSTYPES.ctlid!=-1
			lea		ebx,[ebx+sizeof RSTYPES]
		.endw
		.if byte ptr [ebx].RSTYPES.style1
			lea		esi,[ebx].RSTYPES.style1
			call	AddStyles
		.endif
		.if byte ptr [ebx].RSTYPES.style2
			lea		esi,[ebx].RSTYPES.style2
			call	AddStyles
		.endif
		.if byte ptr [ebx].RSTYPES.style3
			lea		esi,[ebx].RSTYPES.style3
			call	AddStyles
		.endif
		pop		edi
		invoke strcpy,edi,offset namebuff+1
		invoke strlen,edi
		lea		edi,[edi+eax]
		mov		eax,nst
		.if eax!=nStyle
			.if ncount
				mov		byte ptr [edi],'|'
				inc		edi
			.endif
			xor		eax,nStyle
			invoke SaveHexVal,eax,fComma
		.elseif fComma
			mov		al,','
			stosb
		.endif
	.endif
	ret

Compare:
	xor		eax,eax
	xor		ecx,ecx
	.while byte ptr [esi+ecx]
		mov		al,[esi+ecx]
		sub		al,[edi+ecx+8]
		.break .if eax
		inc		ecx
	.endw
	retn

AddStyles:
	.if [ebx].RSTYPES.ctlid
		mov		edi,offset srtstyledef
	.else
		mov		edi,offset srtstyledefdlg
	.endif
	mov		edx,nStyle
	.while dword ptr [edi]
		push	edi
		mov		edi,[edi]
		push	edx
		call	Compare
		pop		edx
		.if !eax
			mov		eax,edx
			and		eax,[edi+4]
			.if eax==[edi] && eax
				xor		ecx,ecx
				.if nType==1
					push	eax
					push	edx
					invoke IsNotStyle,addr [edi+8],offset editnot
					mov		ecx,eax
					pop		edx
					pop		eax
				.elseif nType==22
					push	eax
					push	edx
					invoke IsNotStyle,addr [edi+8],offset richednot
					mov		ecx,eax
					pop		edx
					pop		eax
				.endif
				.if !ecx
					or		nst,eax
					inc		ncount
					xor		edx,eax
					push	edx
					invoke strcat,offset namebuff,offset szOR
					invoke strcat,offset namebuff,addr [edi+8]
					pop		edx
				.endif
			.endif
		.endif
		pop		edi
		lea		edi,[edi+4]
	.endw
	retn

SaveStyle endp

SaveExStyle proc uses ebx esi,nExStyle:DWORD
	LOCAL	buffer1[8]:BYTE
	LOCAL	nst:DWORD
	LOCAL	ncount:DWORD
	LOCAL	npos:DWORD

	.if fStyleHex
		invoke SaveHexVal,nExStyle,FALSE
	.else
		mov		nst,0
		mov		ncount,0
		mov		[npos],edi
		mov		dword ptr buffer1,'E_SW'
		mov		dword ptr buffer1[4],'_X'
		push	edi
		mov		dword ptr namebuff,0
		lea		esi,buffer1
		call	AddStyles
		pop		edi
		invoke strcpy,edi,offset namebuff+1
		invoke strlen,edi
		lea		edi,[edi+eax]
		mov		eax,nst
		.if eax!=nExStyle
			.if ncount
				mov		byte ptr [edi],'|'
				inc		edi
			.endif
			xor		eax,nExStyle
			invoke SaveHexVal,eax,FALSE
		.endif
	.endif
	ret

Compare:
	xor		eax,eax
	xor		ecx,ecx
	.while byte ptr [esi+ecx]
		mov		al,[esi+ecx]
		sub		al,[edi+ecx+8]
		.break .if eax
		inc		ecx
	.endw
	retn

AddStyles:
	mov		edi,offset srtexstyledef
	mov		edx,nExStyle
	.while dword ptr [edi]
		push	edi
		mov		edi,[edi]
		push	edx
		call	Compare
		pop		edx
		.if !eax
			mov		eax,edx
			and		eax,[edi+4]
			.if eax==[edi] && eax
				or		nst,eax
				inc		ncount
				xor		edx,eax
				push	edx
				invoke strcat,offset namebuff,offset szOR
				invoke strcat,offset namebuff,addr [edi+8]
				pop		edx
			.endif
		.endif
		pop		edi
		lea		edi,[edi+4]
	.endw
	retn

SaveExStyle endp

SaveCtl proc uses ebx esi edi
	LOCAL	buffer[512]:BYTE

	assume esi:ptr DIALOG
	;Is ctl deleted
	mov		eax,[esi].hwnd
	.if eax!=-1
		mov		eax,[esi].ntype
		.if eax==0
			;Dialog
			invoke SaveName
			add		edi,eax
			mov		al,' '
			stosb
			invoke SaveType
			add		edi,eax
			mov		al,' '
			stosb
			invoke SaveCtlSize
			mov		edx,[esi].helpid
			.if edx
				mov		al,','
				stosb
				invoke ResEdBinToDec,edx,addr buffer
				invoke SaveStr,edi,addr buffer
				add		edi,eax
			.endif
			mov		eax,0A0Dh
			stosw
			mov		al,[esi].caption
			.if al
				invoke SaveStr,edi,addr szCAPTION
				add		edi,eax
				mov		al,20h
				stosb
				invoke SaveCaption
				mov		ax,0A0Dh
				stosw
			.endif
			;These are stored in DLGHEAD
			sub		esi,sizeof DLGHEAD
			invoke SaveDlgFont
			invoke SaveDlgClass
			mov		eax,esi
			.if byte ptr [eax].DLGHEAD.menuid
				invoke SaveDlgMenu
			.endif
			add		esi,sizeof DLGHEAD
			;This is stored in DLGHEAD
			sub		esi,sizeof DLGHEAD
			mov		eax,esi
			.if [eax].DLGHEAD.lang || [eax].DLGHEAD.sublang
				invoke SaveLanguage,addr [eax].DLGHEAD.lang,edi
				add		edi,eax
			.endif
			add		esi,sizeof DLGHEAD
			invoke SaveStr,edi,addr szSTYLE
			add		edi,eax
			mov		al,' '
			stosb
			mov		eax,[esi].style
			and		eax,dwNOTStyle
			xor		eax,dwNOTStyle
			.if eax
				.if fStyleHex
					invoke SaveStr,edi,addr szNOTStyleHex
				.else
					invoke SaveStr,edi,addr szNOTStyle
				.endif
				add		edi,eax
			.endif
			invoke SaveStyle,[esi].style,[esi].ntype,FALSE
			mov		ax,0A0Dh
			stosw
			.if [esi].exstyle
				invoke SaveStr,edi,addr szEXSTYLE
				add		edi,eax
				mov		al,' '
				stosb
				invoke SaveExStyle,[esi].exstyle
				mov		ax,0A0Dh
				stosw
			.endif
			invoke SaveStr,edi,addr szBEGIN
			add		edi,eax
			mov		ax,0A0Dh
			stosw
		.elseif eax==23
			;UserDefinedControl
			mov		ax,'  '
			stosw
			invoke SaveType
			add		edi,eax
			mov		al,' '
			stosb
			;Caption
			invoke SaveCaption
			mov		al,','
			stosb
			invoke SaveName
			add		edi,eax
			mov		al,','
			stosb
			;Class
			invoke SaveUDCClass
			mov		al,','
			stosb
			mov		eax,[esi].style
			and		eax,dwNOTStyle
			xor		eax,dwNOTStyle
			.if eax
				invoke SaveStr,edi,addr szNOTStyle
				add		edi,eax
			.endif
			invoke SaveStyle,[esi].style,[esi].ntype,TRUE
			invoke SaveCtlSize
			.if [esi].exstyle || [esi].helpid
				mov		al,','
				stosb
				.if [esi].exstyle
					invoke SaveExStyle,[esi].exstyle
				.endif
				.if [esi].helpid
					mov		al,','
					stosb
					invoke ResEdBinToDec,[esi].helpid,addr buffer
					invoke SaveStr,edi,addr buffer
					add		edi,eax
				.endif
			.endif
			mov		ax,0A0Dh
			stosw
		.else
			;Control
			push	eax
			mov		ax,'  '
			stosw
			invoke SaveType
			add		edi,eax
			mov		al,' '
			stosb
			pop		eax
			.if eax==17 || eax==27
				.if byte ptr [esi].caption=='#'
					; "#100"
					invoke SaveCaption
				.elseif  byte ptr [esi].caption>='0' && byte ptr [esi].caption<='9'
					; 100
					invoke SaveStr,edi,addr [esi].caption
					add		edi,eax
				.else
					xor		ebx,ebx
					.if byte ptr [esi].caption
						invoke GetWindowLong,hPrj,0
						invoke GetTypeMem,eax,TPE_RESOURCE
						.if [eax].PROJECT.hmem
							push	edi
							mov		edi,[eax].PROJECT.hmem
							.while byte ptr [edi].RESOURCEMEM.szname || [edi].RESOURCEMEM.value
								invoke strcmp,addr [edi].RESOURCEMEM.szname,addr [esi].caption
								.if !eax
									.if [edi].RESOURCEMEM.value
										; IDI_ICON
										pop		edi
										invoke SaveStr,edi,addr [esi].caption
										add		edi,eax
										push	edi
									.else
										; "IDI_ICON"
										pop		edi
										invoke SaveCaption
										push	edi
									.endif
									inc		ebx
									.break
								.endif
								add		edi,sizeof RESOURCEMEM
							.endw
							pop		edi
						.endif
					.endif
					.if !ebx
						invoke SaveCaption
					.endif
				.endif
			.else
				invoke SaveCaption
			.endif
			mov		al,','
			stosb
			invoke SaveName
			add		edi,eax
			mov		al,','
			stosb
			invoke SaveClass
			mov		al,','
			stosb
			mov		eax,[esi].style
			and		eax,dwNOTStyle
			xor		eax,dwNOTStyle
			.if eax
				.if fStyleHex
					invoke SaveStr,edi,addr szNOTStyleHex
				.else
					invoke SaveStr,edi,addr szNOTStyle
				.endif
				add		edi,eax
			.endif
			invoke SaveStyle,[esi].style,[esi].ntype,TRUE
			invoke SaveCtlSize
			.if [esi].exstyle || [esi].helpid
				mov		al,','
				stosb
				.if [esi].exstyle
					invoke SaveExStyle,[esi].exstyle
				.endif
				.if [esi].helpid
					mov		al,','
					stosb
					invoke ResEdBinToDec,[esi].helpid,addr buffer
					invoke SaveStr,edi,addr buffer
					add		edi,eax
				.endif
			.endif
			mov		ax,0A0Dh
			stosw
		.endif
	.endif
	mov		eax,edi
	assume esi:nothing
	ret

SaveCtl endp

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

ExportDialogNames proc uses ebx esi edi,hMem:DWORD

	mov		esi,hMem
	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,256*1024
	mov		edi,eax
	invoke GlobalLock,edi
	push	edi
	.if [esi].DLGHEAD.ftextmode
		invoke SendMessage,[esi].DLGHEAD.hred,EM_GETMODIFY,0,0
		.if eax
			invoke GetWindowLong,hPrj,0
			mov		ebx,eax
			.while esi!=[ebx].PROJECT.hmem
				add		ebx,sizeof PROJECT
			.endw
			mov		[ebx].PROJECT.hmem,0
			push	[esi].DLGHEAD.hred
			push	[esi].DLGHEAD.ftextmode
			invoke SaveToMem,[esi].DLGHEAD.hred,edi
			invoke GetWindowLong,hPrj,0
			invoke ParseRCMem,edi,eax
			.if fParseError
				.if [ebx].PROJECT.hmem
					invoke GlobalUnlock,[ebx].PROJECT.hmem
					invoke GlobalFree,[ebx].PROJECT.hmem
				.endif
				mov		[ebx].PROJECT.hmem,esi
				pop		eax
				pop		eax
			.else
				invoke GetWindowLong,hDEd,DEWM_MEMORY
				.if eax==esi
					invoke DestroySizeingRect
					invoke DestroyWindow,[esi+sizeof DLGHEAD].DIALOG.hwnd
					.if [esi].DLGHEAD.hfont
						invoke DeleteObject,[esi].DLGHEAD.hfont
						mov		[esi].DLGHEAD.hfont,0
					.endif
					invoke SetWindowLong,hDEd,DEWM_MEMORY,0
					invoke SetWindowLong,hDEd,DEWM_DIALOG,0
					invoke SetWindowLong,hDEd,DEWM_PROJECT,0
					invoke GlobalUnlock,esi
					invoke GlobalFree,esi
					invoke CreateDlg,hDEd,ebx,TRUE
				.endif
				mov		esi,[ebx].PROJECT.hmem
				mov		hMem,esi
				pop		[esi].DLGHEAD.ftextmode
				pop		[esi].DLGHEAD.hred
				invoke SendMessage,[esi].DLGHEAD.hred,EM_SETMODIFY,FALSE,0
			.endif
		.endif
	.endif
	mov		esi,hMem
	add		esi,sizeof DLGHEAD
  @@:
	invoke SaveDefine
	add		esi,size DIALOG
	mov		eax,[esi]
	or		eax,eax
	jne		@b
	mov		byte ptr [edi],0
	pop		eax
	ret

ExportDialogNames endp

VerifyTebIndex proc uses esi,hMem:DWORD
	LOCAL	tab[1024]:BYTE
	LOCAL	maxtab:DWORD
	LOCAL	szerr[256]:BYTE

	mov		maxtab,-1
	invoke RtlZeroMemory,addr tab,sizeof tab
	mov		esi,hMem
	add		esi,sizeof DLGHEAD
	invoke strcpy,addr szerr,addr [esi].DIALOG.idname
	add		esi,sizeof DIALOG
	.while [esi].DIALOG.hwnd
		.if [esi].DIALOG.hwnd!=-1
			mov		eax,[esi].DIALOG.tab
			.if sdword ptr eax>maxtab
				mov		maxtab,eax
			.endif
			inc		byte ptr tab[eax]
		.endif
		add		esi,sizeof DIALOG
	.endw
	.if maxtab!=-1
		xor		ecx,ecx
		.while ecx<=maxtab
			push	ecx
			.if byte ptr tab[ecx]>1
				invoke strcat,addr szerr,addr szDupTab
				invoke MessageBox,hDEd,addr szerr,addr szToolTip,MB_ICONERROR or MB_OK
				pop		ecx
				.break
			.elseif byte ptr tab[ecx]==0
				invoke strcat,addr szerr,addr szMissTab
				invoke MessageBox,hDEd,addr szerr,addr szToolTip,MB_ICONERROR or MB_OK
				pop		ecx
				.break
			.endif
			pop		ecx
			inc		ecx
		.endw
	.endif
	ret

VerifyTebIndex endp

DlgResize proc uses esi edi,hMem:DWORD,lpOldFont:DWORD,nOldSize:DWORD,lpNewFont:DWORD,nNewSize:DWORD
	LOCAL	hDlg:HWND

	mov		eax,nOldSize
	mov		dlgps,ax
	mov		esi,lpOldFont
	mov		edi,offset dlgfn
	xor		eax,eax
	mov		ecx,32
  @@:
	lodsb
	stosw
	loop	@b
	invoke CreateDialogIndirectParam,hInstance,offset dlgdata,hDEd,offset TestProc,0
	invoke DestroyWindow,eax
	push	fntwt
	pop		dfntwt
	push	fntht
	pop		dfntht
	mov		eax,nNewSize
	mov		dlgps,ax
	mov		esi,lpNewFont
	mov		edi,offset dlgfn
	xor		eax,eax
	mov		ecx,32
  @@:
	lodsb
	stosw
	loop	@b
	invoke CreateDialogIndirectParam,hInstance,offset dlgdata,hDEd,offset TestProc,0
	invoke DestroyWindow,eax
	mov		esi,hMem
	add		esi,sizeof DLGHEAD
	mov		edi,[esi].DIALOG.hwnd
	.while [esi].DIALOG.hwnd
		.if [esi].DIALOG.hwnd!=-1
			; Dont move dialog
			.if edi!=[esi].DIALOG.hwnd
				mov		eax,[esi].DIALOG.x
				imul	fntwt
				xor		edx,edx
				idiv	dfntwt
				.if fSnapToGrid
					xor		edx,edx
					idiv	Gridcx
					imul	Gridcx
				.endif
				mov		[esi].DIALOG.x,eax
				mov		eax,[esi].DIALOG.y
				imul	fntht
				xor		edx,edx
				idiv	dfntht
				.if fSnapToGrid
					xor		edx,edx
					idiv	Gridcy
					imul	Gridcy
				.endif
				mov		[esi].DIALOG.y,eax
			.endif
			mov		eax,[esi].DIALOG.ccx
			imul	fntwt
			xor		edx,edx
			idiv	dfntwt
			.if fSnapToGrid
				xor		edx,edx
				idiv	Gridcx
				imul	Gridcx
				inc		eax
			.endif
			mov		[esi].DIALOG.ccx,eax
			mov		eax,[esi].DIALOG.ccy
			imul	fntht
			xor		edx,edx
			idiv	dfntht
			.if fSnapToGrid
				xor		edx,edx
				idiv	Gridcy
				imul	Gridcy
				inc		eax
			.endif
			mov		[esi].DIALOG.ccy,eax
			.if edi!=[esi].DIALOG.hwnd
				invoke MoveWindow,[esi].DIALOG.hwnd,[esi].DIALOG.x,[esi].DIALOG.y,[esi].DIALOG.ccx,[esi].DIALOG.ccy,TRUE
			.else
				invoke MoveWindow,[esi].DIALOG.hwnd,10,10,[esi].DIALOG.ccx,[esi].DIALOG.ccy,TRUE
			.endif
		.endif
		add		esi,sizeof DIALOG
	.endw
	invoke UpdateRAEdit,hMem
	ret

DlgResize endp

ExportDialog proc uses esi edi,hRdMem:DWORD
	LOCAL	hWrMem:DWORD
	LOCAL	nTab:DWORD
	LOCAL	nMiss:DWORD

	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,256*1024
	mov		hWrMem,eax
	invoke GlobalLock,hWrMem
	mov		esi,hRdMem
	invoke VerifyTebIndex,esi
	mov		dlgps,10
	mov		dlgfn,0
	invoke CreateDialogIndirectParam,hInstance,offset dlgdata,hDEd,offset TestProc,0
	invoke DestroyWindow,eax
	push	fntwt
	pop		dfntwt
	push	fntht
	pop		dfntht
	mov		eax,[esi].DLGHEAD.fontsize
	mov		dlgps,ax
	pushad
	lea		esi,[esi].DLGHEAD.font
	mov		edi,offset dlgfn
	xor		eax,eax
	mov		ecx,32
  @@:
	lodsb
	stosw
	loop	@b
	popad
	invoke CreateDialogIndirectParam,hInstance,offset dlgdata,hDEd,offset TestProc,0
	invoke DestroyWindow,eax
	mov		edi,hWrMem
	mov		esi,hRdMem
	add		esi,sizeof DLGHEAD
	invoke SaveCtl
	mov		edi,eax
	add		esi,sizeof DIALOG
	mov		nTab,0
	mov		nMiss,0
  @@:
	invoke FindTab,nTab,hRdMem
	.if eax
		mov		esi,edx
		invoke SaveCtl
		mov		edi,eax
		inc		nTab
		mov		nMiss,0
		jmp		@b
	.else
		.if nMiss<10
			inc		nMiss
			inc		nTab
			jmp		@b
		.endif
	.endif
	invoke SaveStr,edi,addr szEND
	add		edi,eax
	mov		eax,0A0Dh
	stosw
	stosd
	mov		eax,hWrMem
	ret

ExportDialog endp

CompactDlgFile proc uses ecx esi edi,lpData:DWORD

	mov		esi,lpData
	mov		edi,esi
	add		esi,sizeof DIALOG
  @@:
	mov		dword ptr [edi],0
	mov		eax,[esi]
	.if eax
		mov		ecx,sizeof DIALOG
		rep movsb
		jmp		@b
	.endif
	ret

CompactDlgFile endp

CompactDialog proc uses esi,hWin:HWND

	invoke GetWindowLong,hWin,DEWM_MEMORY
	mov		esi,eax
	mov		[esi].DLGHEAD.undo,0
	add		esi,sizeof DLGHEAD
  @@:
	mov		eax,(DIALOG ptr [esi]).hwnd
	.if eax==-1
		invoke CompactDlgFile,esi
	.else
		add		esi,sizeof DIALOG
	.endif
	mov		eax,(DIALOG ptr [esi]).hwnd
	or		eax,eax
	jne		@b
	invoke GetWindowLong,hWin,DEWM_MEMORY
	sub		esi,eax
	invoke GetWindowLong,hWin,DEWM_DIALOG
	invoke UpdateDialog,eax
	mov		eax,esi
	ret

CompactDialog endp

GetType proc uses ebx esi,lpDlg:DWORD

	mov		esi,lpDlg
	mov		eax,[esi].DIALOG.ntypeid
	.if eax
		mov		ebx,offset ctltypes
		mov		ecx,nButtons
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
		.endif
		invoke DestroyWindow,[esi+sizeof DLGHEAD].DIALOG.hwnd
		.if [esi].DLGHEAD.hfont
			invoke DeleteObject,[esi].DLGHEAD.hfont
			mov		[esi].DLGHEAD.hfont,0
		.endif
		invoke SetWindowLong,hDEd,DEWM_MEMORY,0
		invoke SetWindowLong,hDEd,DEWM_DIALOG,0
		invoke SetWindowLong,hDEd,DEWM_PROJECT,0
	.elseif hDialog
		invoke SendMessage,hDialog,WM_COMMAND,BN_CLICKED shl 16 or IDOK,0
		invoke SendMessage,hDialog,WM_COMMAND,BN_CLICKED shl 16 or IDCANCEL,0
		mov		hDialog,0
	.endif
	ret

CloseDialog endp

CreateDlg proc uses esi edi,hWin:HWND,lpProItemMem:DWORD,fNoSelect:DWORD
	LOCAL	hDlg:HWND
	LOCAL	racol:RACOLOR

	invoke CloseDialog
	mov		esi,lpProItemMem
	invoke SetWindowLong,hWin,DEWM_PROJECT,esi
	mov		eax,(PROJECT ptr [esi]).hmem
	.if !eax
		;Create new dlg
		invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,MaxMem
		mov		esi,eax
		invoke GlobalLock,esi
		invoke SetWindowLong,hWin,DEWM_MEMORY,esi
		invoke CreateNewCtl,hWin,0,DlgX,DlgY,300,200
		mov		hDlg,eax
		invoke SetWindowLong,hWin,DEWM_DIALOG,hDlg
		invoke SetWindowLong,hDlg,GWL_ID,ID_DIALOG
	.else
		;Create existing dlg
		mov		esi,eax
		push	esi
		push	[esi].DLGHEAD.changed
		invoke SetWindowLong,hWin,DEWM_MEMORY,esi
		xor		eax,eax
		mov		[esi].DLGHEAD.hmnu,eax
		mov		[esi].DLGHEAD.htlb,eax
		mov		[esi].DLGHEAD.hstb,eax
		mov		[esi].DLGHEAD.hfont,eax
		mov		[esi].DLGHEAD.undo,eax
		add		esi,sizeof DLGHEAD
		push	hWin
		pop		[esi].DIALOG.hpar
		mov		[esi].DIALOG.hcld,0
		mov		[esi].DIALOG.himg,0
		invoke CreateCtl,esi
		mov		hDlg,eax
		invoke SetWindowLong,hWin,DEWM_DIALOG,hDlg
		invoke SetWindowLong,hDlg,GWL_ID,ID_DIALOG
		;Create ctl's
		add		esi,sizeof DIALOG
		.while [esi].DIALOG.hwnd
			.if [esi].DIALOG.hwnd!=-1
				push	hDlg
				pop		[esi].DIALOG.hpar
				mov		[esi].DIALOG.hcld,0
				mov		[esi].DIALOG.himg,0
				invoke GetType,esi
				invoke CreateCtl,esi
			.endif
			add		esi,sizeof DIALOG
		.endw
		pop		eax
		invoke SetChanged,eax,hWin
		pop		esi
	.endif
	invoke SetWindowLong,hWin,DEWM_READONLY,0
	invoke SendMessage,hDlg,WM_NCACTIVATE,1,0
	.if fEditMode
		invoke EnableWindow,hDlg,FALSE
	.elseif !fNoSelect
		invoke SizeingRect,hDlg,FALSE
	.endif
	.if hTabSet
		invoke SetWindowPos,hTabSet,HWND_TOP,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE
		mov		nTabSet,0
	.endif
	.if ![esi].DLGHEAD.hred
		invoke CreateWindowEx,200h,addr szRAEditClass,0,WS_CHILD or STYLE_NOSIZEGRIP or STYLE_NOLOCK or STYLE_NOCOLLAPSE,0,0,0,0,hRes,0,hInstance,0
		mov		[esi].DLGHEAD.hred,eax
		invoke SendMessage,[esi].DLGHEAD.hred,WM_SETFONT,hredfont,0
		invoke SendMessage,[esi].DLGHEAD.hred,REM_GETCOLOR,0,addr racol
		mov		eax,color.back
		mov		racol.bckcol,eax
		mov		eax,color.text
		mov		racol.txtcol,eax
		mov		racol.strcol,0
		invoke SendMessage,[esi].DLGHEAD.hred,REM_SETCOLOR,0,addr racol
		invoke SendMessage,[esi].DLGHEAD.hred,REM_SETWORDGROUP,0,2
		invoke UpdateRAEdit,esi
		invoke SendMessage,hRes,WM_SIZE,0,0
		invoke SendMessage,[esi].DLGHEAD.hred,EM_EMPTYUNDOBUFFER,0,0
	.endif
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
				invoke CreateDlg,hDEd,esi,TRUE
				invoke GlobalUnlock,ebx
				invoke GlobalFree,ebx
			.endif
			invoke GlobalFree,edi
			invoke SetChanged,TRUE,hDEd
			mov		fClose,0
		.endif
	.endif
	invoke NotifyParent
	ret

UndoRedo endp
