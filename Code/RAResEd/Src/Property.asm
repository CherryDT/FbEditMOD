
.const

PRP_NUM_ID				equ 1
PRP_NUM_POSL			equ 2
PRP_NUM_POST			equ 3
PRP_NUM_SIZEW			equ 4
PRP_NUM_SIZEH			equ 5
PRP_NUM_STARTID			equ 6
PRP_NUM_TAB				equ 7
PRP_NUM_HELPID			equ 8

PRP_STR_NAME			equ 100
PRP_STR_NAMEBTN			equ 101
PRP_STR_NAMESTC			equ 102
PRP_STR_CAPTION			equ 103
PRP_STR_CAPMULTI		equ 104

PRP_STR_FONT			equ 1000
PRP_STR_CLASS			equ 1001
PRP_STR_MENU			equ 1002
PRP_STR_IMAGE			equ 1005
PRP_STR_AVI				equ 1006
PRP_STR_FILE			equ 1008

PRP_FUN_STYLE			equ 1003
PRP_FUN_EXSTYLE			equ 1004
PRP_FUN_LANG			equ 1007

PRP_BOOL_SYSMENU		equ 200
PRP_BOOL_MAXBUTTON		equ 201
PRP_BOOL_MINBUTTON		equ 202
PRP_BOOL_ENABLED		equ 203
PRP_BOOL_VISIBLE		equ 204
PRP_BOOL_DEFAULT		equ 205
PRP_BOOL_AUTO			equ 206
PRP_BOOL_MNEMONIC		equ 207
PRP_BOOL_WORDWRAP		equ 208
PRP_BOOL_MULTI			equ 209
PRP_BOOL_LOCK			equ 210
PRP_BOOL_CHILD			equ 211
PRP_BOOL_SIZE			equ 212
PRP_BOOL_TABSTOP		equ 213
PRP_BOOL_NOTIFY			equ 214
PRP_BOOL_WANTCR			equ 215
PRP_BOOL_SORT			equ 216
PRP_BOOL_FLAT			equ 217
PRP_BOOL_GROUP			equ 218
PRP_BOOL_ICON			equ 219
PRP_BOOL_USETAB			equ 220
PRP_BOOL_SETBUDDY		equ 221
PRP_BOOL_HIDE			equ 222
PRP_BOOL_TOPMOST		equ 223
PRP_BOOL_INTEGRAL		equ 224
PRP_BOOL_BUTTON			equ 225
PRP_BOOL_POPUP			equ 226
PRP_BOOL_OWNERDRAW		equ 227
PRP_BOOL_TRANSP			equ 228
PRP_BOOL_TIME			equ 229
PRP_BOOL_WEEK			equ 230
PRP_BOOL_TOOLTIP		equ 231
PRP_BOOL_WRAP			equ 232
PRP_BOOL_DIVIDER		equ 233
PRP_BOOL_DRAGDROP		equ 234
PRP_BOOL_SMOOTH			equ 235
PRP_BOOL_AUTOSCROLL		equ 236
PRP_BOOL_AUTOPLAY		equ 237
PRP_BOOL_AUTOSIZE		equ 238
PRP_BOOL_HASSTRINGS		equ 239
PRP_BOOL_MENUEX			equ 240
PRP_BOOL_SAVESEL		equ 241

PRP_MULTI_CLIP			equ 300
PRP_MULTI_SCROLL		equ 301
PRP_MULTI_ALIGN			equ 302
PRP_MULTI_AUTOSCROLL	equ 303
PRP_MULTI_FORMAT		equ 304
PRP_MULTI_STARTPOS		equ 305
PRP_MULTI_ORIENT		equ 306
PRP_MULTI_SORT			equ 307
PRP_MULTI_OWNERDRAW		equ 308
PRP_MULTI_ELLIPSIS		equ 309

PRP_MULTI_BORDER		equ 400
PRP_MULTI_TYPE			equ 401

IDD_PROPERTY			equ 1600
IDC_EDTSTYLE			equ 3301
IDC_BTNLEFT				equ 3302
IDC_BTNRIGHT			equ 3303
IDC_BTNSET				equ 3304
IDC_STCWARN				equ 3305
IDC_STCTXT				equ 3306

.data

szNameExist			db 'Name already exist.',0Dh,0Ah,0Dh,0Ah,0

szFalse				db 'False',0
szTrue				db 'True',0
;False/True Styles
SysMDlg				dd -1 xor WS_SYSMENU,0
					dd -1 xor WS_SYSMENU,WS_SYSMENU
MaxBDlg				dd -1 xor WS_MAXIMIZEBOX,0
					dd -1 xor WS_MAXIMIZEBOX,WS_MAXIMIZEBOX
MinBDlg				dd -1 xor WS_MINIMIZEBOX,0
					dd -1 xor WS_MINIMIZEBOX,WS_MINIMIZEBOX
EnabAll				dd -1 xor WS_DISABLED,WS_DISABLED
					dd -1 xor WS_DISABLED,0
VisiAll				dd -1 xor WS_VISIBLE,0
					dd -1 xor WS_VISIBLE,WS_VISIBLE
DefaBtn				dd -1 xor BS_DEFPUSHBUTTON,0
					dd -1 xor BS_DEFPUSHBUTTON,BS_DEFPUSHBUTTON
AutoChk				dd -1 xor (BS_AUTOCHECKBOX or BS_CHECKBOX),BS_CHECKBOX
					dd -1 xor (BS_AUTOCHECKBOX or BS_CHECKBOX),BS_AUTOCHECKBOX
AutoRbt				dd -1 xor (BS_AUTORADIOBUTTON or BS_RADIOBUTTON),BS_RADIOBUTTON
					dd -1 xor (BS_AUTORADIOBUTTON or BS_RADIOBUTTON),BS_AUTORADIOBUTTON
AutoCbo				dd -1 xor CBS_AUTOHSCROLL,0
					dd -1 xor CBS_AUTOHSCROLL,CBS_AUTOHSCROLL
AutoSpn				dd -1 xor UDS_AUTOBUDDY,0
					dd -1 xor UDS_AUTOBUDDY,UDS_AUTOBUDDY
AutoTbr				dd -1 xor CCS_NORESIZE,CCS_NORESIZE 
					dd -1 xor CCS_NORESIZE,0
AutoAni				dd -1 xor ACS_AUTOPLAY,0
					dd -1 xor ACS_AUTOPLAY,ACS_AUTOPLAY
MnemStc				dd -1 xor SS_NOPREFIX,SS_NOPREFIX
					dd -1 xor SS_NOPREFIX,0
WordStc				dd -1 xor (SS_LEFTNOWORDWRAP or SS_CENTER or SS_RIGHT),SS_LEFTNOWORDWRAP
					dd -1 xor (SS_LEFTNOWORDWRAP or SS_CENTER or SS_RIGHT),0
MultEdt				dd -1 xor ES_MULTILINE,0
					dd -1 xor ES_MULTILINE,ES_MULTILINE
MultBtn				dd -1 xor BS_MULTILINE,0
					dd -1 xor BS_MULTILINE,BS_MULTILINE
MultTab				dd -1 xor TCS_MULTILINE,0
					dd -1 xor TCS_MULTILINE,TCS_MULTILINE
MultLst				dd -1 xor (LBS_MULTIPLESEL or LBS_EXTENDEDSEL),0
					dd -1 xor (LBS_MULTIPLESEL or LBS_EXTENDEDSEL),LBS_MULTIPLESEL or LBS_EXTENDEDSEL
MultMvi				dd -1 xor MCS_MULTISELECT,0
					dd -1 xor MCS_MULTISELECT,MCS_MULTISELECT
LockEdt				dd -1 xor ES_READONLY,0
					dd -1 xor ES_READONLY,ES_READONLY
ChilAll				dd -1 xor WS_CHILD,0
					dd -1 xor WS_CHILD,WS_CHILD
SizeDlg				dd -1 xor WS_SIZEBOX,0
					dd -1 xor WS_SIZEBOX,WS_SIZEBOX
SizeSbr				dd -1 xor SBARS_SIZEGRIP,0
					dd -1 xor SBARS_SIZEGRIP,SBARS_SIZEGRIP
TabSAll				dd -1 xor WS_TABSTOP,0
					dd -1 xor WS_TABSTOP,WS_TABSTOP
NotiStc				dd -1 xor SS_NOTIFY,0
					dd -1 xor SS_NOTIFY,SS_NOTIFY
NotiBtn				dd -1 xor BS_NOTIFY,0
					dd -1 xor BS_NOTIFY,BS_NOTIFY
NotiLst				dd -1 xor LBS_NOTIFY,0
					dd -1 xor LBS_NOTIFY,LBS_NOTIFY
WantEdt				dd -1 xor ES_WANTRETURN,0
					dd -1 xor ES_WANTRETURN,ES_WANTRETURN
SortCbo				dd -1 xor CBS_SORT,0
					dd -1 xor CBS_SORT,CBS_SORT
SortLst				dd -1 xor LBS_SORT,0
					dd -1 xor LBS_SORT,LBS_SORT
FlatTbr				dd -1 xor TBSTYLE_FLAT,0
					dd -1 xor TBSTYLE_FLAT,TBSTYLE_FLAT
GrouAll				dd -1 xor WS_GROUP,0
					dd -1 xor WS_GROUP,WS_GROUP
UseTLst				dd -1 xor LBS_USETABSTOPS,0
					dd -1 xor LBS_USETABSTOPS,LBS_USETABSTOPS
SetBUdn				dd -1 xor UDS_SETBUDDYINT,0
					dd -1 xor UDS_SETBUDDYINT,UDS_SETBUDDYINT
HideEdt				dd -1 xor ES_NOHIDESEL,ES_NOHIDESEL
					dd -1 xor ES_NOHIDESEL,0
HideTrv				dd -1 xor TVS_SHOWSELALWAYS,TVS_SHOWSELALWAYS
					dd -1 xor TVS_SHOWSELALWAYS,0
HideLsv				dd -1 xor LVS_SHOWSELALWAYS,LVS_SHOWSELALWAYS
					dd -1 xor LVS_SHOWSELALWAYS,0
IntHtCbo			dd -1 xor CBS_NOINTEGRALHEIGHT,CBS_NOINTEGRALHEIGHT
					dd -1 xor CBS_NOINTEGRALHEIGHT,0
IntHtLst			dd -1 xor LBS_NOINTEGRALHEIGHT,LBS_NOINTEGRALHEIGHT
					dd -1 xor LBS_NOINTEGRALHEIGHT,0
ButtTab				dd -1 xor TCS_BUTTONS,0
					dd -1 xor TCS_BUTTONS,TCS_BUTTONS
ButtTrv				dd -1 xor TVS_HASBUTTONS,0
					dd -1 xor TVS_HASBUTTONS,TVS_HASBUTTONS
ButtHdr				dd -1 xor HDS_BUTTONS,0
					dd -1 xor HDS_BUTTONS,HDS_BUTTONS
PopUAll				dd -1 xor WS_POPUP,0
					dd -1 xor WS_POPUP,WS_POPUP
OwneLsv				dd -1 xor LVS_OWNERDRAWFIXED,0
					dd -1 xor LVS_OWNERDRAWFIXED,LVS_OWNERDRAWFIXED
TranAni				dd -1 xor ACS_TRANSPARENT,0
					dd -1 xor ACS_TRANSPARENT,ACS_TRANSPARENT
TimeAni				dd -1 xor ACS_TIMER,0
					dd -1 xor ACS_TIMER,ACS_TIMER
WeekMvi				dd -1 xor MCS_WEEKNUMBERS,0
					dd -1 xor MCS_WEEKNUMBERS,MCS_WEEKNUMBERS
ToolTbr				dd -1 xor TBSTYLE_TOOLTIPS,0
					dd -1 xor TBSTYLE_TOOLTIPS,TBSTYLE_TOOLTIPS
ToolSbr				dd -1 xor SBARS_TOOLTIPS,0
					dd -1 xor SBARS_TOOLTIPS,SBARS_TOOLTIPS
ToolTab				dd -1 xor TCS_TOOLTIPS,0
					dd -1 xor TCS_TOOLTIPS,TCS_TOOLTIPS
WrapTbr				dd -1 xor TBSTYLE_WRAPABLE,0
					dd -1 xor TBSTYLE_WRAPABLE,TBSTYLE_WRAPABLE
DiviTbr				dd -1 xor CCS_NODIVIDER,CCS_NODIVIDER
					dd -1 xor CCS_NODIVIDER,0
DragHdr				dd -1 xor HDS_DRAGDROP,0
					dd -1 xor HDS_DRAGDROP,HDS_DRAGDROP
SmooPgb				dd -1 xor PBS_SMOOTH,0
					dd -1 xor PBS_SMOOTH,PBS_SMOOTH
HasStcb				dd -1 xor CBS_HASSTRINGS,0
					dd -1 xor CBS_HASSTRINGS,CBS_HASSTRINGS
HasStlb				dd -1 xor LBS_HASSTRINGS,0
					dd -1 xor LBS_HASSTRINGS,LBS_HASSTRINGS
MenuEx				dd -1 xor TRUE,0
					dd -1 xor TRUE,TRUE
SaveRich			dd -1 xor ES_SAVESEL,0
					dd -1 xor ES_SAVESEL,ES_SAVESEL

;False/True ExStyles
TopMost				dd -1 xor WS_EX_TOPMOST,0
					dd -1 xor WS_EX_TOPMOST,WS_EX_TOPMOST

;Multi styles
ClipAll				db 'None,Children,Siblings,Both',0
					dd -1 xor (WS_CLIPCHILDREN or WS_CLIPSIBLINGS),0
					dd -1,0
					dd -1 xor (WS_CLIPCHILDREN or WS_CLIPSIBLINGS),WS_CLIPCHILDREN
					dd -1,0
					dd -1 xor (WS_CLIPCHILDREN or WS_CLIPSIBLINGS),WS_CLIPSIBLINGS
					dd -1,0
					dd -1 xor (WS_CLIPCHILDREN or WS_CLIPSIBLINGS),WS_CLIPCHILDREN or WS_CLIPSIBLINGS
					dd -1,0
ScroAll				db 'None,Horizontal,Vertical,Both',0
					dd -1 xor (WS_HSCROLL or WS_VSCROLL),0
					dd -1,0
					dd -1 xor (WS_HSCROLL or WS_VSCROLL),WS_HSCROLL
					dd -1,0
					dd -1 xor (WS_HSCROLL or WS_VSCROLL),WS_VSCROLL
					dd -1,0
					dd -1 xor (WS_HSCROLL or WS_VSCROLL),WS_HSCROLL or WS_VSCROLL
					dd -1,0
AligStc				db 'TopLeft,TopCenter,TopRight,CenterLeft,CenterCenter,CenterRight',0
					dd -1 xor (SS_CENTER or SS_RIGHT or SS_CENTERIMAGE),0
					dd -1,0
					dd -1 xor (SS_LEFTNOWORDWRAP or SS_CENTER or SS_RIGHT or SS_CENTERIMAGE),SS_CENTER
					dd -1,0
					dd -1 xor (SS_LEFTNOWORDWRAP or SS_CENTER or SS_RIGHT or SS_CENTERIMAGE),SS_RIGHT
					dd -1,0
					dd -1 xor (SS_CENTER or SS_RIGHT or SS_CENTERIMAGE),SS_CENTERIMAGE
					dd -1,0
					dd -1 xor (SS_LEFTNOWORDWRAP or SS_CENTER or SS_RIGHT or SS_CENTERIMAGE),SS_CENTER or SS_CENTERIMAGE
					dd -1,0
					dd -1 xor (SS_LEFTNOWORDWRAP or SS_CENTER or SS_RIGHT or SS_CENTERIMAGE),SS_RIGHT or SS_CENTERIMAGE
					dd -1,0
AligEdt				db 'Left,Center,Right',0
					dd -1 xor (ES_CENTER or ES_RIGHT),0
					dd -1,0
					dd -1 xor (ES_CENTER or ES_RIGHT),ES_CENTER
					dd -1,0
					dd -1 xor (ES_CENTER or ES_RIGHT),ES_RIGHT
					dd -1,0
AligBtn				db 'Default,TopLeft,TopCenter,TopRight,CenterLeft,CenterCenter,CenterRight,BottomLeft,BottomCenter,BottomRight',0
					dd -1 xor (BS_CENTER or BS_VCENTER),0
					dd -1,0
					dd -1 xor (BS_CENTER or BS_VCENTER),BS_TOP or BS_LEFT
					dd -1,0
					dd -1 xor (BS_CENTER or BS_VCENTER),BS_CENTER or BS_TOP
					dd -1,0
					dd -1 xor (BS_CENTER or BS_VCENTER),BS_TOP or BS_RIGHT
					dd -1,0
					dd -1 xor (BS_CENTER or BS_VCENTER),BS_LEFT or BS_VCENTER
					dd -1,0
					dd -1 xor (BS_CENTER or BS_VCENTER),BS_CENTER or BS_VCENTER
					dd -1,0
					dd -1 xor (BS_CENTER or BS_VCENTER),BS_RIGHT or BS_VCENTER
					dd -1,0
					dd -1 xor (BS_CENTER or BS_VCENTER),BS_BOTTOM or BS_LEFT
					dd -1,0
					dd -1 xor (BS_CENTER or BS_VCENTER),BS_CENTER or BS_BOTTOM
					dd -1,0
					dd -1 xor (BS_CENTER or BS_VCENTER),BS_BOTTOM or BS_RIGHT
					dd -1,0
AligChk				db 'Left,Right',0
					dd -1 xor (BS_LEFTTEXT),0
					dd -1,0
					dd -1 xor (BS_LEFTTEXT),BS_LEFTTEXT
					dd -1,0
AligTab				db 'Left,Top,Right,Bottom',0
					dd -1 xor (TCS_BOTTOM or TCS_VERTICAL),TCS_VERTICAL
					dd -1,0
					dd -1 xor (TCS_BOTTOM or TCS_VERTICAL),0
					dd -1,0
					dd -1 xor (TCS_BOTTOM or TCS_VERTICAL),TCS_BOTTOM or TCS_VERTICAL
					dd -1,0
					dd -1 xor (TCS_BOTTOM or TCS_VERTICAL),TCS_BOTTOM
					dd -1,0
AligLsv				db 'Left,Top',0
					dd -1 xor LVS_ALIGNLEFT,LVS_ALIGNLEFT
					dd -1,0
					dd -1 xor LVS_ALIGNLEFT,0
					dd -1,0
AligSpn				db 'None,Left,Right',0
					dd -1 xor (UDS_ALIGNLEFT or UDS_ALIGNRIGHT),0
					dd -1,0
					dd -1 xor (UDS_ALIGNLEFT or UDS_ALIGNRIGHT),UDS_ALIGNLEFT
					dd -1,0
					dd -1 xor (UDS_ALIGNLEFT or UDS_ALIGNRIGHT),UDS_ALIGNRIGHT
					dd -1,0
AligIco				db 'AutoSize,Center',0
					dd -1 xor SS_CENTERIMAGE,0
					dd -1,0
					dd -1 xor SS_CENTERIMAGE,SS_CENTERIMAGE
					dd -1,0
AligTbr				db 'Left,Top,Right,Bottom',0
					dd -1 xor (CCS_VERT or CCS_BOTTOM or CCS_TOP),CCS_TOP or CCS_VERT
					dd -1,0
					dd -1 xor (CCS_VERT or CCS_BOTTOM or CCS_TOP),CCS_TOP
					dd -1,0
					dd -1 xor (CCS_VERT or CCS_BOTTOM or CCS_TOP),CCS_BOTTOM or CCS_VERT
					dd -1,0
					dd -1 xor (CCS_VERT or CCS_BOTTOM or CCS_TOP),CCS_BOTTOM
					dd -1,0
AligAni				db 'AutoSize,Center',0
					dd -1 xor ACS_CENTER,0
					dd -1,0
					dd -1 xor ACS_CENTER,ACS_CENTER
					dd -1,0
BordDlg				db 'Flat,Boarder,Dialog,Tool,ModalFrame',0
					dd -1 xor (WS_DLGFRAME or WS_BORDER or DS_MODALFRAME or WS_POPUP),WS_POPUP
					dd -1 xor (WS_EX_TOOLWINDOW or WS_EX_DLGMODALFRAME),0
					dd -1 xor (WS_DLGFRAME or WS_BORDER or DS_MODALFRAME or WS_POPUP),WS_BORDER or WS_POPUP
					dd -1 xor (WS_EX_TOOLWINDOW or WS_EX_DLGMODALFRAME),0
					dd -1 xor (WS_DLGFRAME or WS_BORDER or DS_MODALFRAME or WS_POPUP),WS_BORDER or WS_DLGFRAME
					dd -1 xor (WS_EX_TOOLWINDOW or WS_EX_DLGMODALFRAME),0
					dd -1 xor (WS_DLGFRAME or WS_BORDER or DS_MODALFRAME or WS_POPUP),WS_BORDER or WS_DLGFRAME
					dd -1 xor (WS_EX_TOOLWINDOW or WS_EX_DLGMODALFRAME),WS_EX_TOOLWINDOW
					dd -1 xor (WS_DLGFRAME or WS_BORDER or DS_MODALFRAME or WS_POPUP),WS_BORDER or WS_DLGFRAME or DS_MODALFRAME
					dd -1 xor (WS_EX_TOOLWINDOW or WS_EX_DLGMODALFRAME),WS_EX_DLGMODALFRAME
BordAll				db 'Flat,Boarder,Raised,Sunken,3D-Look,Edge',0
					dd -1 xor WS_BORDER,0
					dd -1 xor (WS_EX_DLGMODALFRAME or WS_EX_CLIENTEDGE or WS_EX_STATICEDGE),0
					dd -1 xor WS_BORDER,WS_BORDER
					dd -1 xor (WS_EX_DLGMODALFRAME or WS_EX_CLIENTEDGE or WS_EX_STATICEDGE),0
					dd -1 xor WS_BORDER,0
					dd -1 xor (WS_EX_DLGMODALFRAME or WS_EX_CLIENTEDGE or WS_EX_STATICEDGE),WS_EX_DLGMODALFRAME
					dd -1 xor WS_BORDER,0
					dd -1 xor (WS_EX_DLGMODALFRAME or WS_EX_CLIENTEDGE or WS_EX_STATICEDGE),WS_EX_STATICEDGE
					dd -1 xor WS_BORDER,0
					dd -1 xor (WS_EX_DLGMODALFRAME or WS_EX_CLIENTEDGE or WS_EX_STATICEDGE),WS_EX_CLIENTEDGE
					dd -1 xor WS_BORDER,0
					dd -1 xor (WS_EX_DLGMODALFRAME or WS_EX_CLIENTEDGE or WS_EX_STATICEDGE),WS_EX_CLIENTEDGE or WS_EX_DLGMODALFRAME
BordStc				db 'Flat,Boarder,Raised,Sunken,3D-Look,Edge',0
					dd -1 xor (WS_BORDER or SS_SUNKEN),0
					dd -1 xor (WS_EX_DLGMODALFRAME or WS_EX_CLIENTEDGE),0
					dd -1 xor (WS_BORDER or SS_SUNKEN),WS_BORDER
					dd -1 xor (WS_EX_DLGMODALFRAME or WS_EX_CLIENTEDGE),0
					dd -1 xor (WS_BORDER or SS_SUNKEN),0
					dd -1 xor (WS_EX_DLGMODALFRAME or WS_EX_CLIENTEDGE),WS_EX_DLGMODALFRAME
					dd -1 xor (WS_BORDER or SS_SUNKEN),SS_SUNKEN
					dd -1 xor (WS_EX_DLGMODALFRAME or WS_EX_CLIENTEDGE),0
					dd -1 xor (WS_BORDER or SS_SUNKEN),0
					dd -1 xor (WS_EX_DLGMODALFRAME or WS_EX_CLIENTEDGE),WS_EX_CLIENTEDGE
					dd -1 xor WS_BORDER,0
					dd -1 xor (WS_EX_DLGMODALFRAME or WS_EX_CLIENTEDGE),WS_EX_CLIENTEDGE or WS_EX_DLGMODALFRAME
BordBtn				db 'Flat,Boarder,Raised,Sunken,3D-Look,Edge',0
					dd -1 xor (WS_BORDER or BS_FLAT),BS_FLAT
					dd -1 xor (WS_EX_DLGMODALFRAME or WS_EX_CLIENTEDGE or WS_EX_STATICEDGE),0
					dd -1 xor (WS_BORDER or BS_FLAT),WS_BORDER or BS_FLAT
					dd -1 xor (WS_EX_DLGMODALFRAME or WS_EX_CLIENTEDGE or WS_EX_STATICEDGE),0
					dd -1 xor (WS_BORDER or BS_FLAT),0
					dd -1 xor (WS_EX_DLGMODALFRAME or WS_EX_CLIENTEDGE or WS_EX_STATICEDGE),WS_EX_DLGMODALFRAME
					dd -1 xor (WS_BORDER or BS_FLAT),0
					dd -1 xor (WS_EX_DLGMODALFRAME or WS_EX_CLIENTEDGE or WS_EX_STATICEDGE),WS_EX_STATICEDGE
					dd -1 xor (WS_BORDER or BS_FLAT),0
					dd -1 xor (WS_EX_DLGMODALFRAME or WS_EX_CLIENTEDGE or WS_EX_STATICEDGE),0
					dd -1 xor (WS_BORDER or BS_FLAT),0
					dd -1 xor (WS_EX_DLGMODALFRAME or WS_EX_CLIENTEDGE or WS_EX_STATICEDGE),WS_EX_DLGMODALFRAME or WS_EX_CLIENTEDGE
TypeEdt				db 'Normal,Upper,Lower,Number,Password',0
					dd -1 xor (ES_UPPERCASE or ES_LOWERCASE or ES_PASSWORD or ES_NUMBER),0
					dd -1,0
					dd -1 xor (ES_UPPERCASE or ES_LOWERCASE or ES_PASSWORD or ES_NUMBER),ES_UPPERCASE
					dd -1,0
					dd -1 xor (ES_UPPERCASE or ES_LOWERCASE or ES_PASSWORD or ES_NUMBER),ES_LOWERCASE
					dd -1,0
					dd -1 xor (ES_UPPERCASE or ES_LOWERCASE or ES_PASSWORD or ES_NUMBER),ES_NUMBER
					dd -1,0
					dd -1 xor (ES_UPPERCASE or ES_LOWERCASE or ES_PASSWORD or ES_NUMBER),ES_PASSWORD
					dd -1,0
TypeCbo				db 'DropDownCombo,DropDownList,SimpleCombo',0
					dd -1 xor (CBS_DROPDOWN or CBS_DROPDOWNLIST or CBS_SIMPLE),CBS_DROPDOWN
					dd -1,0
					dd -1 xor (CBS_DROPDOWN or CBS_DROPDOWNLIST or CBS_SIMPLE),CBS_DROPDOWNLIST
					dd -1,0
					dd -1 xor (CBS_DROPDOWN or CBS_DROPDOWNLIST or CBS_SIMPLE),CBS_SIMPLE
					dd -1,0
TypeBtn				db 'Text,Bitmap,Icon',0
					dd -1 xor (BS_BITMAP or BS_ICON),0
					dd -1,0
					dd -1 xor (BS_BITMAP or BS_ICON),BS_BITMAP
					dd -1,0
					dd -1 xor (BS_BITMAP or BS_ICON),BS_ICON
					dd -1,0
TypeTrv				db 'NoLines,Lines,LinesAtRoot',0
					dd -1 xor (TVS_HASLINES or TVS_LINESATROOT),0
					dd -1,0
					dd -1 xor (TVS_HASLINES or TVS_LINESATROOT),TVS_HASLINES
					dd -1,0
					dd -1 xor (TVS_HASLINES or TVS_LINESATROOT),TVS_HASLINES or TVS_LINESATROOT
					dd -1,0
TypeLsv				db 'Icon,List,Report,SmallIcon',0
					dd -1 xor LVS_TYPEMASK,LVS_ICON
					dd -1,0
					dd -1 xor LVS_TYPEMASK,LVS_LIST
					dd -1,0
					dd -1 xor LVS_TYPEMASK,LVS_REPORT
					dd -1,0
					dd -1 xor LVS_TYPEMASK,LVS_SMALLICON
					dd -1,0
TypeImg				db 'Bitmap,Icon',0
					dd -1 xor (SS_BITMAP or SS_ICON),SS_BITMAP
					dd -1,0
					dd -1 xor (SS_BITMAP or SS_ICON),SS_ICON
					dd -1,0
TypeDtp				db 'Normal,UpDown,CheckBox,Both',0
					dd -1 xor 03h,00h
					dd -1,0
					dd -1 xor 03h,01h
					dd -1,0
					dd -1 xor 03h,02h
					dd -1,0
					dd -1 xor 03h,03h
					dd -1,0
TypeStc				db 'BlackRect,GrayRect,WhiteRect,HollowRect,BlackFrame,GrayFrame,WhiteFrame,EtchedFrame,H-Line,V-Line',0
					dd -1 xor 1Fh,SS_BLACKRECT
					dd -1,0
					dd -1 xor 1Fh,SS_GRAYRECT
					dd -1,0
					dd -1 xor 1Fh,SS_WHITERECT
					dd -1,0
					dd -1 xor 1Fh,SS_OWNERDRAW
					dd -1,0
					dd -1 xor 1Fh,SS_BLACKFRAME
					dd -1,0
					dd -1 xor 1Fh,SS_GRAYFRAME
					dd -1,0
					dd -1 xor 1Fh,SS_WHITEFRAME
					dd -1,0
					dd -1 xor 1Fh,SS_ETCHEDFRAME
					dd -1,0
					dd -1 xor 1Fh,SS_ETCHEDHORZ
					dd -1,0
					dd -1 xor 1Fh,SS_ETCHEDVERT
					dd -1,0
AutoEdt				db 'None,Horizontal,Vertical,Both',0
					dd -1 xor (ES_AUTOHSCROLL or ES_AUTOVSCROLL),0
					dd -1,0
					dd -1 xor (ES_AUTOHSCROLL or ES_AUTOVSCROLL),ES_AUTOHSCROLL
					dd -1,0
					dd -1 xor (ES_AUTOHSCROLL or ES_AUTOVSCROLL),ES_AUTOVSCROLL
					dd -1,0
					dd -1 xor (ES_AUTOHSCROLL or ES_AUTOVSCROLL),ES_AUTOHSCROLL or ES_AUTOVSCROLL
					dd -1,0
FormDtp				db 'Short,Medium,Long,Time',0
					dd -1 xor 0Ch,00h
					dd -1,0
					dd -1 xor 0Ch,0Ch
					dd -1,0
					dd -1 xor 0Ch,04h
					dd -1,0
					dd -1 xor 0Ch,08h
					dd -1,0
StarDlg				db 'Normal,CenterScreen,CenterMouse',0
					dd -1 xor (DS_CENTER or DS_CENTERMOUSE),0
					dd -1,0
					dd -1 xor (DS_CENTER or DS_CENTERMOUSE),DS_CENTER
					dd -1,0
					dd -1 xor (DS_CENTER or DS_CENTERMOUSE),DS_CENTERMOUSE
					dd -1,0
OriePgb				db 'Horizontal,Vertical',0
					dd -1 xor PBS_VERTICAL,0
					dd -1,0
					dd -1 xor PBS_VERTICAL,PBS_VERTICAL
					dd -1,0
OrieUdn				db 'Vertical,Horizontal',0
					dd -1 xor UDS_HORZ,0
					dd -1,0
					dd -1 xor UDS_HORZ,UDS_HORZ
					dd -1,0
SortLsv				db 'None,Ascending,Descending',0
					dd -1 xor (LVS_SORTASCENDING or LVS_SORTDESCENDING),0
					dd -1,0
					dd -1 xor (LVS_SORTASCENDING or LVS_SORTDESCENDING),LVS_SORTASCENDING
					dd -1,0
					dd -1 xor (LVS_SORTASCENDING or LVS_SORTDESCENDING),LVS_SORTDESCENDING
					dd -1,0
OwneCbo				db 'None,Fixed,Variable',0
					dd -1 xor (CBS_OWNERDRAWFIXED or CBS_OWNERDRAWVARIABLE),0
					dd -1,0
					dd -1 xor (CBS_OWNERDRAWFIXED or CBS_OWNERDRAWVARIABLE),CBS_OWNERDRAWFIXED
					dd -1,0
					dd -1 xor (CBS_OWNERDRAWFIXED or CBS_OWNERDRAWVARIABLE),CBS_OWNERDRAWVARIABLE
					dd -1,0
ElliStc				db 'None,EndEllipsis,PathEllipsis,WordEllipsis',0
					dd -1 xor SS_ELLIPSISMASK,0
					dd -1,0
					dd -1 xor SS_ELLIPSISMASK,SS_ENDELLIPSIS
					dd -1,0
					dd -1 xor SS_ELLIPSISMASK,SS_PATHELLIPSIS
					dd -1,0
					dd -1 xor SS_ELLIPSISMASK,SS_WORDELLIPSIS
					dd -1,0

szPropErr			db 'Invalid property value.',0
StyleEx				dd 0
szMaxWt				db 'QwnerDraw',0

.data?

lbtxtbuffer			db 4096 dup(?)
szLbString			db 64 dup(?)
OldPrpCboDlgProc	dd ?
hPrpLstDlg			dd ?
OldPrpLstDlgProc	dd ?
hPrpEdtDlgCld		dd ?
OldPrpEdtDlgCldProc	dd ?
hPrpEdtDlgCldMulti	dd ?
OldPrpEdtDlgCldMultiProc	dd ?
hPrpLstDlgCld		dd ?
OldPrpLstDlgCldProc	dd ?
hPrpBtnDlgCld		dd ?

tempbuff			db 256 dup(?)

lpResType			dd ?
lpResName			dd ?
lpResID				dd ?
lpResStartID		dd ?
lpResFile			dd ?
lpResLang			dd ?
lpResHeight			dd ?
lpResWidth			dd ?
lpResMenuEx			dd ?

.code

UpdateCbo proc uses esi,lpData:DWORD
	LOCAL	nInx:DWORD
	LOCAL	buffer[128]:BYTE
	LOCAL	buffer1[1024]:BYTE
	LOCAL	buffer2[64]:BYTE

	mov		nInx,0
	invoke SendMessage,hPrpCboDlg,CB_RESETCONTENT,0,0
	mov		esi,lpData
	add		esi,sizeof DLGHEAD
  @@:
	mov		eax,[esi].DIALOG.hwnd
	.if eax
		.if eax!=-1
			mov		al,[esi].DIALOG.idname
			.if al
				invoke strcpy,addr buffer,addr [esi].DIALOG.idname
			.else
				invoke ResEdBinToDec,[esi].DIALOG.id,addr buffer
			.endif
			invoke strcpy,addr buffer1,addr szCtlText
			mov		eax,[esi].DIALOG.ntype
			inc		eax
			.while eax
				push	eax
				invoke GetStrItem,addr buffer1,addr buffer2
				pop		eax
				dec		eax
			.endw
			push	esi
			invoke strlen,addr buffer
			lea		esi,buffer
			add		esi,eax
			mov		al,' '
			mov		[esi],al
			inc		esi
			invoke strcpy,esi,addr buffer2
			pop		esi
			invoke SendMessage,hPrpCboDlg,CB_ADDSTRING,0,addr buffer
			invoke SendMessage,hPrpCboDlg,CB_SETITEMDATA,eax,nInx
		.endif
		inc		nInx
		add		esi,sizeof DIALOG
		jmp		@b
	.endif
	ret

UpdateCbo endp

SetCbo proc nID:DWORD
	LOCAL	nInx:DWORD

	invoke SendMessage,hPrpCboDlg,CB_GETCOUNT,0,0
	mov		nInx,eax
  @@:
	.if nInx
		dec		nInx
		invoke SendMessage,hPrpCboDlg,CB_GETITEMDATA,nInx,0
		.if eax==nID
			invoke SendMessage,hPrpCboDlg,CB_SETCURSEL,nInx,0
		.endif
		jmp		@b
	.endif
	ret

SetCbo endp

PropListSetTxt proc uses esi,hWin:HWND
	LOCAL	nInx:DWORD
	LOCAL	buffer[512]:BYTE

	invoke SendMessage,hWin,LB_GETCURSEL,0,0
	.if eax!=LB_ERR
		mov		nInx,eax
		invoke SendMessage,hWin,LB_GETTEXT,nInx,addr buffer
		lea		esi,buffer
	  @@:
		mov		al,[esi]
		inc		esi
		cmp		al,09h
		jne		@b
		invoke SendMessage,hWin,LB_GETITEMDATA,nInx,0
		.if eax==PRP_STR_CAPTION || eax==PRP_STR_CAPMULTI || eax==PRP_STR_IMAGE || eax==PRP_STR_AVI
			invoke SendMessage,hPrpEdtDlgCld,EM_LIMITTEXT,MaxCap-1,0
			invoke SendMessage,hPrpEdtDlgCldMulti,EM_LIMITTEXT,MaxCap-1,0
		.elseif eax==PRP_STR_NAME || eax==PRP_STR_NAMEBTN || eax==PRP_STR_NAMESTC
			invoke SendMessage,hPrpEdtDlgCld,EM_LIMITTEXT,MaxName-1,0
		.elseif eax==PRP_STR_FILE
			invoke SendMessage,hPrpEdtDlgCld,EM_LIMITTEXT,MAX_PATH-1,0
		.elseif eax==PRP_FUN_STYLE || eax==PRP_FUN_EXSTYLE
			invoke SendMessage,hPrpEdtDlgCld,EM_LIMITTEXT,8,0
		.else
			invoke SendMessage,hPrpEdtDlgCld,EM_LIMITTEXT,32-1,0
		.endif
		invoke SetWindowText,hPrpEdtDlgCld,esi
	.endif
	ret

PropListSetTxt endp

PropListSetPos proc
	LOCAL	rect:RECT
	LOCAL	nInx:DWORD
	LOCAL	lbid:DWORD

	invoke ShowWindow,hPrpEdtDlgCld,SW_HIDE
	invoke ShowWindow,hPrpEdtDlgCldMulti,SW_HIDE
	invoke ShowWindow,hPrpBtnDlgCld,SW_HIDE
	invoke SendMessage,hPrpLstDlg,LB_GETCURSEL,0,0
	.if eax!=LB_ERR
		mov		nInx,eax
		invoke SendMessage,hPrpLstDlg,LB_GETTEXT,nInx,addr lbtxtbuffer
		mov		ecx,offset lbtxtbuffer
		mov		edx,offset szLbString
		.while byte ptr [ecx]!=VK_TAB
			mov		al,[ecx]
			mov		[edx],al
			inc		ecx
			inc		edx
		.endw
		mov		byte ptr [edx],0
		invoke SendMessage,hPrpLstDlg,LB_GETITEMRECT,nInx,addr rect
		invoke SendMessage,hPrpLstDlg,LB_GETITEMDATA,nInx,0
		mov		lbid,eax
		invoke SetWindowLong,hPrpBtnDlgCld,GWL_USERDATA,eax
		mov		eax,lbid
		.if (eax>=PRP_BOOL_SYSMENU && eax<=499) || eax==PRP_FUN_LANG || eax>65535
			mov		ecx,nPropHt
			sub		rect.right,ecx
			mov		eax,rect.right
			sub		eax,rect.left
			mov		edx,nPropWt
			add		edx,32
			sub		edx,ecx
			.if eax<edx
				mov		rect.right,edx
			.endif
			invoke SetWindowPos,hPrpBtnDlgCld,HWND_TOP,rect.right,rect.top,nPropHt,nPropHt,0
			invoke ShowWindow,hPrpBtnDlgCld,SW_SHOWNOACTIVATE
		.elseif eax==PRP_FUN_STYLE || eax==PRP_FUN_EXSTYLE
			invoke PropListSetTxt,hPrpLstDlg
			mov		ecx,nPropHt
			sub		rect.right,ecx
			mov		eax,rect.right
			sub		eax,rect.left
			mov		edx,nPropWt
			add		edx,32
			sub		edx,ecx
			.if eax<edx
				mov		rect.right,edx
			.endif
			invoke SetWindowPos,hPrpBtnDlgCld,HWND_TOP,rect.right,rect.top,nPropHt,nPropHt,0
			invoke ShowWindow,hPrpBtnDlgCld,SW_SHOWNOACTIVATE
			mov		edx,nPropWt
			add		edx,1
			mov		rect.left,edx
			sub		rect.right,edx
			invoke SetWindowPos,hPrpEdtDlgCld,HWND_TOP,rect.left,rect.top,rect.right,nPropHt,0
			invoke ShowWindow,hPrpEdtDlgCld,SW_SHOWNOACTIVATE
			mov		rect.left,1
			mov		rect.top,0
			mov		eax,nPropHt
			mov		rect.bottom,eax
			invoke SendMessage,hPrpEdtDlgCld,EM_SETRECT,0,addr rect
		.else
			invoke PropListSetTxt,hPrpLstDlg
			mov		eax,lbid
			.if eax==PRP_STR_MENU || eax==PRP_STR_IMAGE || eax==PRP_STR_AVI || eax==PRP_STR_NAMEBTN || eax==PRP_STR_NAMESTC || eax==PRP_STR_FILE || eax==PRP_STR_FONT
				mov		ecx,nPropHt
				dec		ecx
				sub		rect.right,ecx
				invoke SetWindowPos,hPrpBtnDlgCld,HWND_TOP,rect.right,rect.top,nPropHt,nPropHt,0
				invoke ShowWindow,hPrpBtnDlgCld,SW_SHOWNOACTIVATE
			.elseif lbid==PRP_STR_CAPMULTI
				mov		ecx,nPropHt
				dec		ecx
				sub		rect.right,ecx
				invoke SetWindowPos,hPrpBtnDlgCld,HWND_TOP,rect.right,rect.top,nPropHt,nPropHt,0
				invoke ShowWindow,hPrpBtnDlgCld,SW_SHOWNOACTIVATE
			.endif
			mov		edx,nPropWt
			add		edx,1
			mov		rect.left,edx
			sub		rect.right,edx
			invoke SetWindowPos,hPrpEdtDlgCld,HWND_TOP,rect.left,rect.top,rect.right,nPropHt,0
			invoke ShowWindow,hPrpEdtDlgCld,SW_SHOWNOACTIVATE
			mov		rect.left,1
			mov		rect.top,0
			mov		eax,nPropHt
			mov		rect.bottom,eax
			invoke SendMessage,hPrpEdtDlgCld,EM_SETRECT,0,addr rect
		.endif
		xor		eax,eax
	.endif
	ret

PropListSetPos endp

TxtLstFalseTrue proc uses esi,CtlVal:DWORD,lpVal:DWORD

	invoke SendMessage,hPrpLstDlgCld,LB_RESETCONTENT,0,0
	invoke SendMessage,hPrpLstDlgCld,LB_ADDSTRING,0,addr szFalse
	mov		eax,lpVal
	invoke SendMessage,hPrpLstDlgCld,LB_SETITEMDATA,0,eax
	invoke SendMessage,hPrpLstDlgCld,LB_ADDSTRING,0,addr szTrue
	mov		eax,lpVal
	add		eax,8
	invoke SendMessage,hPrpLstDlgCld,LB_SETITEMDATA,1,eax
	mov		esi,lpVal
	mov		eax,[esi]
	xor		eax,-1
	and		eax,CtlVal
	.if eax==[esi+4]
		invoke SendMessage,hPrpLstDlgCld,LB_SETCURSEL,0,0
	.else
		invoke SendMessage,hPrpLstDlgCld,LB_SETCURSEL,1,0
	.endif
	ret

TxtLstFalseTrue endp

TxtLstMulti proc uses esi,CtlValSt:DWORD,CtlValExSt:DWORD,lpVal:DWORD
	LOCAL	buffer[512]:BYTE
	LOCAL	buffer1[64]:BYTE
	LOCAL	nInx:DWORD

	invoke SendMessage,hPrpLstDlgCld,LB_RESETCONTENT,0,0
	invoke strcpy,addr buffer,lpVal
	invoke strlen,lpVal
	add		lpVal,eax
	inc		lpVal
 @@:
	invoke GetStrItem,addr buffer,addr buffer1
	invoke SendMessage,hPrpLstDlgCld,LB_ADDSTRING,0,addr buffer1
	mov		nInx,eax
	invoke SendMessage,hPrpLstDlgCld,LB_SETITEMDATA,nInx,lpVal
	mov		esi,lpVal
	mov		eax,[esi]
	xor		eax,-1
	and		eax,CtlValSt
	.if eax==[esi+4]
		mov		eax,[esi+8]
		xor		eax,-1
		and		eax,CtlValExSt
		.if eax==[esi+12]
			invoke SendMessage,hPrpLstDlgCld,LB_SETCURSEL,nInx,0
		.endif
	.endif
	add		lpVal,16
	mov		al,buffer[0]
	or		al,al
	jne		@b
	ret

TxtLstMulti endp

PropTxtLst proc uses ebx esi edi,hCtl:DWORD,lbid:DWORD
	LOCAL	nType:DWORD
	LOCAL	buffer[32]:BYTE

	invoke SetWindowLong,hPrpLstDlgCld,GWL_USERDATA,hCtl
;	invoke SetWindowLong,hPrpLstDlgCld,GWL_ID,lbid
	.if hCtl==-7
		.if lbid==PRP_BOOL_MENUEX
			mov		eax,lpResMenuEx
			mov		eax,[eax]
			invoke TxtLstFalseTrue,eax,addr MenuEx
		.endif
	.else
		invoke GetCtrlMem,hCtl
		mov		esi,eax
		assume esi:ptr DIALOG
		push	[esi].ntype
		pop		nType
		mov		eax,lbid
		.if eax==PRP_BOOL_SYSMENU
			invoke TxtLstFalseTrue,[esi].style,addr SysMDlg
		.elseif eax==PRP_BOOL_MAXBUTTON
			invoke TxtLstFalseTrue,[esi].style,addr MaxBDlg
		.elseif eax==PRP_BOOL_MINBUTTON
			invoke TxtLstFalseTrue,[esi].style,addr MinBDlg
		.elseif eax==PRP_BOOL_ENABLED
			invoke TxtLstFalseTrue,[esi].style,addr EnabAll
		.elseif eax==PRP_BOOL_VISIBLE
			invoke TxtLstFalseTrue,[esi].style,addr VisiAll
		.elseif eax==PRP_BOOL_DEFAULT
			invoke TxtLstFalseTrue,[esi].style,addr DefaBtn
		.elseif eax==PRP_BOOL_AUTO
			.if nType==5
				invoke TxtLstFalseTrue,[esi].style,addr AutoChk
			.elseif nType==6
				invoke TxtLstFalseTrue,[esi].style,addr AutoRbt
			.elseif nType==16
				invoke TxtLstFalseTrue,[esi].style,addr AutoSpn
			.endif
		.elseif eax==PRP_BOOL_AUTOSCROLL
			.if nType==7
				invoke TxtLstFalseTrue,[esi].style,addr AutoCbo
			.endif
		.elseif eax==PRP_BOOL_AUTOPLAY
			.if nType==27
				invoke TxtLstFalseTrue,[esi].style,addr AutoAni
			.endif
		.elseif eax==PRP_BOOL_AUTOSIZE
			.if nType==18 || nType==19
				invoke TxtLstFalseTrue,[esi].style,addr AutoTbr
			.endif
		.elseif eax==PRP_BOOL_MNEMONIC
			invoke TxtLstFalseTrue,[esi].style,addr MnemStc
		.elseif eax==PRP_BOOL_WORDWRAP
			invoke TxtLstFalseTrue,[esi].style,addr WordStc
		.elseif eax==PRP_BOOL_MULTI
			.if nType==1 || nType==22
				invoke TxtLstFalseTrue,[esi].style,addr MultEdt
			.elseif nType==4 || nType==5 || nType==6
				invoke TxtLstFalseTrue,[esi].style,addr MultBtn
			.elseif nType==8
				invoke TxtLstFalseTrue,[esi].style,addr MultLst
			.elseif nType==11
				invoke TxtLstFalseTrue,[esi].style,addr MultTab
			.elseif nType==21
				invoke TxtLstFalseTrue,[esi].style,addr MultMvi
			.endif
		.elseif eax==PRP_BOOL_LOCK
			invoke TxtLstFalseTrue,[esi].style,addr LockEdt
		.elseif eax==PRP_BOOL_CHILD
			invoke TxtLstFalseTrue,[esi].style,addr ChilAll
		.elseif eax==PRP_BOOL_SIZE
			.if nType==0
				invoke TxtLstFalseTrue,[esi].style,addr SizeDlg
			.elseif nType==19
				invoke TxtLstFalseTrue,[esi].style,addr SizeSbr
			.endif
		.elseif eax==PRP_BOOL_TABSTOP
			invoke TxtLstFalseTrue,[esi].style,addr TabSAll
		.elseif eax==PRP_BOOL_NOTIFY
			.if nType==2 || nType==17 || nType==25
				invoke TxtLstFalseTrue,[esi].style,addr NotiStc
			.elseif nType==4 || nType==5 || nType==6
				invoke TxtLstFalseTrue,[esi].style,addr NotiBtn
			.elseif nType==8
				invoke TxtLstFalseTrue,[esi].style,addr NotiLst
			.endif
		.elseif eax==PRP_BOOL_WANTCR
			invoke TxtLstFalseTrue,[esi].style,addr WantEdt
		.elseif eax==PRP_BOOL_SORT
			.if nType==7
				invoke TxtLstFalseTrue,[esi].style,addr SortCbo
			.elseif nType==8
				invoke TxtLstFalseTrue,[esi].style,addr SortLst
			.endif
		.elseif eax==PRP_BOOL_FLAT
			invoke TxtLstFalseTrue,[esi].style,addr FlatTbr
		.elseif eax==PRP_BOOL_GROUP
			invoke TxtLstFalseTrue,[esi].style,addr GrouAll
		.elseif eax==PRP_BOOL_ICON
	;		invoke TxtLstFalseTrue,[esi].style,addr IconBtn
		.elseif eax==PRP_BOOL_USETAB
			invoke TxtLstFalseTrue,[esi].style,addr UseTLst
		.elseif eax==PRP_BOOL_SETBUDDY
			invoke TxtLstFalseTrue,[esi].style,addr SetBUdn
		.elseif eax==PRP_BOOL_HIDE
			.if nType==1 || nType==22
				invoke TxtLstFalseTrue,[esi].style,addr HideEdt
			.elseif nType==13
				invoke TxtLstFalseTrue,[esi].style,addr HideTrv
			.elseif nType==14
				invoke TxtLstFalseTrue,[esi].style,addr HideLsv
			.endif
		.elseif eax==PRP_BOOL_TOPMOST
			invoke TxtLstFalseTrue,[esi].exstyle,addr TopMost
		.elseif eax==PRP_BOOL_INTEGRAL
			.if nType==7
				invoke TxtLstFalseTrue,[esi].style,addr IntHtCbo
			.elseif nType==8
				invoke TxtLstFalseTrue,[esi].style,addr IntHtLst
			.endif
		.elseif eax==PRP_BOOL_BUTTON
			.if nType==11
				invoke TxtLstFalseTrue,[esi].style,addr ButtTab
			.elseif nType==13
				invoke TxtLstFalseTrue,[esi].style,addr ButtTrv
			.elseif nType==32
				invoke TxtLstFalseTrue,[esi].style,addr ButtHdr
			.endif
		.elseif eax==PRP_BOOL_POPUP
			invoke TxtLstFalseTrue,[esi].style,addr PopUAll
		.elseif eax==PRP_BOOL_OWNERDRAW
			invoke TxtLstFalseTrue,[esi].style,addr OwneLsv
		.elseif eax==PRP_BOOL_TRANSP
			invoke TxtLstFalseTrue,[esi].style,addr TranAni
		.elseif eax==PRP_BOOL_TIME
			invoke TxtLstFalseTrue,[esi].style,addr TimeAni
		.elseif eax==PRP_BOOL_WEEK
			invoke TxtLstFalseTrue,[esi].style,addr WeekMvi
		.elseif eax==PRP_BOOL_TOOLTIP
			.if nType==11
				invoke TxtLstFalseTrue,[esi].style,addr ToolTab
			.elseif nType==18
				invoke TxtLstFalseTrue,[esi].style,addr ToolTbr
			.else
				invoke TxtLstFalseTrue,[esi].style,addr ToolSbr
			.endif
		.elseif eax==PRP_BOOL_WRAP
			invoke TxtLstFalseTrue,[esi].style,addr WrapTbr
		.elseif eax==PRP_BOOL_DIVIDER
			invoke TxtLstFalseTrue,[esi].style,addr DiviTbr
		.elseif eax==PRP_BOOL_DRAGDROP
			invoke TxtLstFalseTrue,[esi].style,addr DragHdr
		.elseif eax==PRP_BOOL_SMOOTH
			invoke TxtLstFalseTrue,[esi].style,addr SmooPgb
		.elseif eax==PRP_BOOL_HASSTRINGS
			.if nType==7
				invoke TxtLstFalseTrue,[esi].style,addr HasStcb
			.elseif nType==8
				invoke TxtLstFalseTrue,[esi].style,addr HasStlb
			.endif
		.elseif eax==PRP_BOOL_SAVESEL
				invoke TxtLstFalseTrue,[esi].style,addr SaveRich
		.elseif eax==PRP_MULTI_CLIP
			invoke TxtLstMulti,[esi].style,[esi].exstyle,addr ClipAll
		.elseif eax==PRP_MULTI_SCROLL
			invoke TxtLstMulti,[esi].style,[esi].exstyle,addr ScroAll
		.elseif eax==PRP_MULTI_ALIGN
			.if nType==1
				invoke TxtLstMulti,[esi].style,[esi].exstyle,addr AligEdt
			.elseif nType==2
				invoke TxtLstMulti,[esi].style,[esi].exstyle,addr AligStc
			.elseif nType==4
				invoke TxtLstMulti,[esi].style,[esi].exstyle,addr AligBtn
			.elseif nType==5 || nType==6
				invoke TxtLstMulti,[esi].style,[esi].exstyle,addr AligChk
			.elseif nType==11
				invoke TxtLstMulti,[esi].style,[esi].exstyle,addr AligTab
			.elseif nType==14
				invoke TxtLstMulti,[esi].style,[esi].exstyle,addr AligLsv
			.elseif nType==16
				invoke TxtLstMulti,[esi].style,[esi].exstyle,addr AligSpn
			.elseif nType==17
				invoke TxtLstMulti,[esi].style,[esi].exstyle,addr AligIco
			.elseif nType==18 || nType==19
				invoke TxtLstMulti,[esi].style,[esi].exstyle,addr AligTbr
			.elseif nType==27
				invoke TxtLstMulti,[esi].style,[esi].exstyle,addr AligAni
			.endif
		.elseif eax==PRP_MULTI_AUTOSCROLL
			invoke TxtLstMulti,[esi].style,[esi].exstyle,addr AutoEdt
		.elseif eax==PRP_MULTI_FORMAT
			invoke TxtLstMulti,[esi].style,[esi].exstyle,addr FormDtp
		.elseif eax==PRP_MULTI_STARTPOS
			invoke TxtLstMulti,[esi].style,[esi].exstyle,addr StarDlg
		.elseif eax==PRP_MULTI_ORIENT
			.if nType==12
				invoke TxtLstMulti,[esi].style,[esi].exstyle,addr OriePgb
			.elseif nType==16
				invoke TxtLstMulti,[esi].style,[esi].exstyle,addr OrieUdn
			.endif
		.elseif eax==PRP_MULTI_SORT
			invoke TxtLstMulti,[esi].style,[esi].exstyle,addr SortLsv
		.elseif eax==PRP_MULTI_OWNERDRAW
			invoke TxtLstMulti,[esi].style,[esi].exstyle,addr OwneCbo
		.elseif eax==PRP_MULTI_ELLIPSIS
			invoke TxtLstMulti,[esi].style,[esi].exstyle,addr ElliStc
		.elseif eax==PRP_MULTI_BORDER
			mov		eax,nType
			.if eax==0
				invoke TxtLstMulti,[esi].style,[esi].exstyle,addr BordDlg
			.elseif eax==2 || eax==17 || eax==25
				invoke TxtLstMulti,[esi].style,[esi].exstyle,addr BordStc
			.elseif eax==3 || eax==4
				invoke TxtLstMulti,[esi].style,[esi].exstyle,addr BordBtn
			.else
				invoke TxtLstMulti,[esi].style,[esi].exstyle,addr BordAll
			.endif
		.elseif eax==PRP_MULTI_TYPE
			mov		eax,nType
			.if eax==1
				invoke TxtLstMulti,[esi].style,[esi].exstyle,addr TypeEdt
			.elseif eax==4
				invoke TxtLstMulti,[esi].style,[esi].exstyle,addr TypeBtn
			.elseif eax==7 || eax==24
				invoke TxtLstMulti,[esi].style,[esi].exstyle,addr TypeCbo
			.elseif eax==13
				invoke TxtLstMulti,[esi].style,[esi].exstyle,addr TypeTrv
			.elseif eax==14
				invoke TxtLstMulti,[esi].style,[esi].exstyle,addr TypeLsv
			.elseif eax==17
				invoke TxtLstMulti,[esi].style,[esi].exstyle,addr TypeImg
			.elseif eax==20
				invoke TxtLstMulti,[esi].style,[esi].exstyle,addr TypeDtp
			.elseif eax==25
				invoke TxtLstMulti,[esi].style,[esi].exstyle,addr TypeStc
			.endif
		.elseif eax==PRP_STR_MENU
			;Dialog Menu
			invoke SendMessage,hPrpLstDlgCld,LB_RESETCONTENT,0,0
			invoke GetWindowLong,hPrj,0
			mov		edi,eax
			.while [edi].PROJECT.hmem
				.if [edi].PROJECT.ntype==TPE_MENU
					mov		edx,[edi].PROJECT.hmem
					.if [edx].MNUHEAD.menuname
						lea		edx,[edx].MNUHEAD.menuname
					.else
						invoke ResEdBinToDec,[edx].MNUHEAD.menuid,addr buffer
						lea		edx,buffer
					.endif
					invoke SendMessage,hPrpLstDlgCld,LB_ADDSTRING,0,edx
				.endif
				lea		edi,[edi+sizeof PROJECT]
			.endw
		.elseif eax==PRP_STR_IMAGE
			;Image
			invoke SendMessage,hPrpLstDlgCld,LB_RESETCONTENT,0,0
			invoke GetWindowLong,hPrj,0
			mov		edi,eax
			.while [edi].PROJECT.hmem
				.if [edi].PROJECT.ntype==TPE_RESOURCE
					mov		edx,[edi].PROJECT.hmem
					.while [edx].RESOURCEMEM.szname || [edx].RESOURCEMEM.value
						mov		eax,[esi].DIALOG.style
						and		eax,SS_TYPEMASK
						.if eax==SS_BITMAP
							mov		eax,0
						.elseif eax==SS_ICON
							mov		eax,2
						.endif
						.if eax==[edx].RESOURCEMEM.ntype
							push	edx
							.if [edx].RESOURCEMEM.szname
								lea		edx,[edx].RESOURCEMEM.szname
							.else
								mov		buffer,'#'
								invoke ResEdBinToDec,[edx].RESOURCEMEM.value,addr buffer[1]
								lea		edx,buffer
							.endif
							invoke SendMessage,hPrpLstDlgCld,LB_ADDSTRING,0,edx
							pop		edx
						.endif
						lea		edx,[edx+sizeof RESOURCEMEM]
					.endw
				.endif
				lea		edi,[edi+sizeof PROJECT]
			.endw
		.elseif eax==PRP_STR_AVI
			;Avi
			invoke SendMessage,hPrpLstDlgCld,LB_RESETCONTENT,0,0
			invoke GetWindowLong,hPrj,0
			mov		edi,eax
			.while [edi].PROJECT.hmem
				.if [edi].PROJECT.ntype==TPE_RESOURCE
					mov		edx,[edi].PROJECT.hmem
					.while [edx].RESOURCEMEM.szname || [edx].RESOURCEMEM.value
						.if [edx].RESOURCEMEM.ntype==3
							push	edx
							.if [edx].RESOURCEMEM.szname
								lea		edx,[edx].RESOURCEMEM.szname
							.else
								mov		buffer,'#'
								invoke ResEdBinToDec,[edx].RESOURCEMEM.value,addr buffer[1]
								lea		edx,buffer
							.endif
							invoke SendMessage,hPrpLstDlgCld,LB_ADDSTRING,0,edx
							pop		edx
						.endif
						lea		edx,[edx+sizeof RESOURCEMEM]
					.endw
				.endif
				lea		edi,[edi+sizeof PROJECT]
			.endw
		.elseif eax==PRP_STR_NAMEBTN
			;(Name)
			invoke SendMessage,hPrpLstDlgCld,LB_RESETCONTENT,0,0
			invoke SendMessage,hPrpLstDlgCld,LB_ADDSTRING,0,addr szIDOK
			invoke SendMessage,hPrpLstDlgCld,LB_SETITEMDATA,eax,IDOK
			invoke SendMessage,hPrpLstDlgCld,LB_ADDSTRING,0,addr szIDCANCEL
			invoke SendMessage,hPrpLstDlgCld,LB_SETITEMDATA,eax,IDCANCEL
			invoke SendMessage,hPrpLstDlgCld,LB_ADDSTRING,0,addr szIDABORT
			invoke SendMessage,hPrpLstDlgCld,LB_SETITEMDATA,eax,IDABORT
			invoke SendMessage,hPrpLstDlgCld,LB_ADDSTRING,0,addr szIDRETRY
			invoke SendMessage,hPrpLstDlgCld,LB_SETITEMDATA,eax,IDRETRY
			invoke SendMessage,hPrpLstDlgCld,LB_ADDSTRING,0,addr szIDIGNORE
			invoke SendMessage,hPrpLstDlgCld,LB_SETITEMDATA,eax,IDIGNORE
			invoke SendMessage,hPrpLstDlgCld,LB_ADDSTRING,0,addr szIDYES
			invoke SendMessage,hPrpLstDlgCld,LB_SETITEMDATA,eax,IDYES
			invoke SendMessage,hPrpLstDlgCld,LB_ADDSTRING,0,addr szIDNO
			invoke SendMessage,hPrpLstDlgCld,LB_SETITEMDATA,eax,IDNO
			invoke SendMessage,hPrpLstDlgCld,LB_ADDSTRING,0,addr szIDCLOSE
			invoke SendMessage,hPrpLstDlgCld,LB_SETITEMDATA,eax,IDCLOSE
			invoke SendMessage,hPrpLstDlgCld,LB_ADDSTRING,0,addr szIDHELP
			invoke SendMessage,hPrpLstDlgCld,LB_SETITEMDATA,eax,IDHELP
			xor		ebx,ebx
			.while TRUE
				invoke SendMessage,hPrpLstDlgCld,LB_GETTEXT,ebx,addr buffer
				.break .if eax==LB_ERR
				invoke strcmpi,addr [esi].idname,addr buffer
				.if !eax
					invoke SendMessage,hPrpLstDlgCld,LB_SETCURSEL,ebx,0
					.break
				.endif
				inc		ebx
			.endw
		.elseif eax==PRP_STR_NAMESTC
			;(Name)
			invoke SendMessage,hPrpLstDlgCld,LB_RESETCONTENT,0,0
			invoke SendMessage,hPrpLstDlgCld,LB_ADDSTRING,0,addr szIDC_STATIC
			invoke SendMessage,hPrpLstDlgCld,LB_SETITEMDATA,eax,-1;IDC_STATIC
			invoke strcmpi,addr [esi].idname,addr szIDC_STATIC
			.if !eax
				invoke SendMessage,hPrpLstDlgCld,LB_SETCURSEL,0,0
			.endif
		.elseif eax==PRP_FUN_LANG
			;Language
		.elseif eax>65535
			;Custom control
			mov		edx,[eax+4]
			.if dword ptr [eax]==1
				invoke TxtLstFalseTrue,[esi].style,edx
			.elseif dword ptr [eax]==2
				invoke TxtLstFalseTrue,[esi].exstyle,edx
			.elseif dword ptr [eax]==3
				invoke TxtLstMulti,[esi].style,[esi].exstyle,edx
			.endif
		.endif
	.endif
	assume esi:nothing
	ret

PropTxtLst endp

SetTxtLstPos proc lpRect:DWORD
	LOCAL	rect:RECT
	LOCAL	lbht:DWORD
	LOCAL	ht:DWORD

	invoke GetClientRect,hPrpLstDlg,addr rect
	mov		eax,rect.bottom
	mov		ht,eax

	invoke CopyRect,addr rect,lpRect
	invoke SendMessage,hPrpLstDlgCld,LB_GETITEMHEIGHT,0,0
	push	eax
	invoke SendMessage,hPrpLstDlgCld,LB_GETCOUNT,0,0
	.if eax>8
		mov		eax,8
	.endif
	pop		edx
	mul		edx
	add		eax,2
	mov		lbht,eax
	add		eax,rect.top
	.if eax>ht
		mov		eax,lbht
		inc		eax
		add		eax,nPropHt
		sub		rect.top,eax
	.endif
	invoke SetWindowPos,hPrpLstDlgCld,HWND_TOP,rect.left,rect.top,rect.right,lbht,0
	invoke ShowWindow,hPrpLstDlgCld,SW_SHOWNOACTIVATE
	invoke SendMessage,hPrpLstDlgCld,LB_GETCURSEL,0,0
	.if eax!=LB_ERR
		invoke SendMessage,hPrpLstDlgCld,LB_SETCURSEL,eax,0
	.endif
	ret

SetTxtLstPos endp

PropEditChkVal proc uses esi,lpTxt:DWORD,nTpe:DWORD,lpfErr:DWORD
	LOCAL buffer[16]:BYTE
	LOCAL val:DWORD

	mov		eax,lpfErr
	mov		dword ptr [eax],FALSE
	invoke ResEdDecToBin,lpTxt
	mov		val,eax
	invoke ResEdBinToDec,val,addr buffer
	invoke strcmp,lpTxt,addr buffer
	.if eax
		mov		eax,lpfErr
		mov		dword ptr [eax],TRUE
		invoke MessageBox,hPrp,addr szPropErr,addr szAppName,MB_OK or MB_ICONERROR
	.endif
	mov		eax,val
	ret

PropEditChkVal endp

PropEditUpdList proc uses ebx esi edi,lpPtr:DWORD
	LOCAL	nInx:DWORD
	LOCAL	buffer[512]:BYTE
	LOCAL	buffer1[512]:BYTE
	LOCAL	hCtl:DWORD
	LOCAL	lpTxt:DWORD
	LOCAL	fErr:DWORD
	LOCAL	lbid:DWORD
	LOCAL	val:DWORD
	LOCAL	hMem:DWORD
	LOCAL	nDefault:DWORD

	mov		fErr,FALSE
	mov		nDefault,0
	invoke SendMessage,hPrpLstDlg,LB_GETCURSEL,0,0
	.if eax!=LB_ERR
		mov		nInx,eax
		;Get type
		invoke SendMessage,hPrpLstDlg,LB_GETITEMDATA,nInx,0
		mov		lbid,eax
		invoke SendMessage,hPrpLstDlg,LB_SETCURSEL,-1,0
		invoke ShowWindow,hPrpEdtDlgCld,SW_HIDE
		invoke ShowWindow,hPrpEdtDlgCldMulti,SW_HIDE
		invoke ShowWindow,hPrpBtnDlgCld,SW_HIDE
		invoke ShowWindow,hPrpLstDlgCld,SW_HIDE
		;Get text
		invoke SendMessage,hPrpLstDlg,LB_GETTEXT,nInx,addr buffer
		invoke GetWindowText,hPrpEdtDlgCld,addr buffer1,sizeof buffer1
		;Find TAB char
		lea		esi,buffer
	  @@:
		mov		al,[esi]
		inc		esi
		cmp		al,09h
		jne		@b
		mov		lpTxt,esi
		;Text changed ?
		invoke strcmp,lpTxt,addr buffer1
		.if hMultiSel && (lbid==PRP_STR_NAME || lbid==PRP_STR_CAPTION)
			mov		eax,1
		.endif
		.if eax
			;Get controls hwnd
			invoke GetWindowLong,hPrpLstDlg,GWL_USERDATA
			mov		hCtl,eax
			mov		eax,lbid
			;Pos, Size, ID or HelpID
			.if eax>=PRP_NUM_ID && eax<=PRP_NUM_HELPID
				;Test valid num
				invoke PropEditChkVal,addr buffer1,lbid,addr fErr
				mov		val,eax
			.endif
			.if !fErr
				.if hMultiSel
					push	0
					mov		eax,hMultiSel
					.while eax
						push	eax
						invoke GetParent,eax
						mov		edx,eax
						pop		eax
						push	edx
						mov		ecx,8
						.while ecx
							push	ecx
							invoke GetWindowLong,eax,GWL_USERDATA
							pop		ecx
							dec		ecx
						.endw
					.endw
					invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,4096
					mov		ebx,eax
					mov		hMem,eax
					pop		eax
					.while eax
						mov		hCtl,eax
						call SetCtrlData
						pop		eax
					.endw
					invoke GlobalFree,hMem
					invoke GetWindowLong,hDEd,DEWM_MEMORY
					invoke MakeDialog,eax,-1
					invoke PropertyList,-1
					invoke SetChanged,TRUE
				.else
					.if hCtl==-2 || hCtl==-3 || hCtl==-4 || hCtl==-6 || hCtl==-7 || hCtl==-8 || hCtl==-9
						mov		eax,lbid
						.if eax==PRP_STR_NAME
							invoke CheckName,addr buffer1
							.if !eax
								invoke strcpy,lpResName,addr buffer1
							.endif
						.elseif eax==PRP_NUM_ID
							mov		eax,lpResID
							push	val
							pop		[eax]
						.elseif eax==PRP_NUM_SIZEW
							mov		eax,lpResWidth
							push	val
							pop		[eax]
						.elseif eax==PRP_NUM_SIZEH
							mov		eax,lpResHeight
							push	val
							pop		[eax]
						.elseif eax==PRP_NUM_STARTID
							mov		eax,lpResStartID
							push	val
							pop		[eax]
						.elseif eax==PRP_BOOL_MENUEX
							mov		edi,lpPtr
							mov		esi,lpResMenuEx
							mov		eax,[esi]
							and		eax,[edi]
							or		eax,[edi+4]
							mov		[esi],eax
						.elseif eax==PRP_STR_FILE
							invoke GetFileAttributes,lpResFile
							.if eax!=INVALID_HANDLE_VALUE
								invoke MoveFile,lpResFile,addr buffer1
							.endif
							invoke strcpy,lpResFile,addr buffer1
						.endif
						invoke PropertyList,hCtl
						invoke SendMessage,hRes,PRO_SETMODIFY,TRUE,0
					.else
						call SetCtrlData
						.if (lbid==PRP_STR_NAMEBTN || lbid==PRP_STR_NAMESTC) && nDefault
							mov		eax,nDefault
							mov		val,eax
							mov		lbid,PRP_NUM_ID
							call SetCtrlData
						.endif
						invoke GetCtrlMem,hCtl
						invoke GetCtrlID,eax
						push	eax
						invoke GetWindowLong,hDEd,DEWM_MEMORY
						pop		edx
						invoke MakeDialog,eax,edx
						invoke SetChanged,TRUE
					.endif
				.endif
			.endif
		.endif
	.endif
	ret

SetCtrlData:
	;Get ptr data
	invoke GetCtrlMem,hCtl
	mov		esi,eax
	assume esi:ptr DIALOG
	;What is changed
	mov		eax,lbid
	.if eax==PRP_STR_NAME || eax==PRP_STR_NAMEBTN || eax==PRP_STR_NAMESTC
		invoke IsNameDefault,addr buffer1
		.if !eax
			invoke NameExists,addr buffer1,esi
		.else
			mov		nDefault,eax
			xor		eax,eax
		.endif
		.if eax
			invoke strcpy,addr buffer,addr szNameExist
			invoke strcat,addr buffer,addr buffer1
			invoke MessageBox,hDEd,addr buffer,addr szAppName,MB_OK or MB_ICONERROR
		.else
			invoke CheckName,addr buffer1
			.if !eax
				invoke strcpy,addr [esi].idname,addr buffer1
				.if ![esi].ntype
					invoke GetWindowLong,hDEd,DEWM_PROJECT
					mov		edx,eax
					push	edx
					invoke GetProjectItemName,edx,addr buffer1
					pop		edx
					invoke SetProjectItemName,edx,addr buffer1
				.endif
			.endif
		.endif
	.elseif eax==PRP_STR_FONT
		invoke ResEdDecToBin,addr buffer1
		mov		val,eax
		mov		edx,esi
		sub		edx,sizeof DLGHEAD
		mov		[edx].DLGHEAD.fontsize,eax
		lea		eax,buffer1
		.while byte ptr [eax] && byte ptr [eax]!=','
			inc		eax
		.endw
		.if byte ptr [eax]==','
			inc		eax
		.else
			lea		eax,buffer1
		.endif
		invoke lstrcpy,addr [edx].DLGHEAD.font,eax
		mov		edx,esi
		sub		edx,sizeof DLGHEAD
		mov		eax,[edx].DLGHEAD.fontsize
		mov		edx,96
		imul	edx
		mov		ecx,72
		xor		edx,edx
		idiv	ecx
		.if edx>=36
			inc		eax
		.endif
		neg		eax
		mov		edx,esi
		sub		edx,sizeof DLGHEAD
		sub		esi,sizeof DLGHEAD
		add		esi,sizeof DLGHEAD
	.elseif eax==PRP_NUM_ID
		push	val
		pop		[esi].id
		.if ![esi].ntype
			invoke GetWindowLong,hDEd,DEWM_PROJECT
			mov		edx,eax
			push	edx
			invoke GetProjectItemName,edx,addr buffer1
			pop		edx
			invoke SetProjectItemName,edx,addr buffer1
		.endif
	.elseif eax==PRP_NUM_POSL
		mov		eax,val
		mov		[esi].dux,eax
	.elseif eax==PRP_NUM_POST
		mov		eax,val
		mov		[esi].duy,eax
	.elseif eax==PRP_NUM_SIZEW
		mov		eax,val
		mov		[esi].duccx,eax
	.elseif eax==PRP_NUM_SIZEH
		mov		eax,val
		mov		[esi].duccy,eax
	.elseif eax==PRP_NUM_STARTID
		sub		esi,sizeof DLGHEAD
		push	val
		pop		(DLGHEAD ptr [esi]).ctlid
		add		esi,sizeof DLGHEAD
	.elseif eax==PRP_NUM_TAB
		invoke SetNewTab,hCtl,val
	.elseif eax==PRP_NUM_HELPID
		mov		eax,val
		mov		[esi].helpid,eax
	.elseif eax==PRP_STR_CAPTION || eax==PRP_STR_CAPMULTI
		invoke strcpy,addr [esi].caption,addr buffer1
	.elseif eax==PRP_STR_IMAGE
		invoke strcpy,addr [esi].caption,addr buffer1
	.elseif eax==PRP_STR_AVI
		invoke strcpy,addr [esi].caption,addr buffer1
	.elseif eax==PRP_STR_CLASS
		mov		eax,[esi].ntype
		.if eax==0
			mov		edx,esi
			sub		edx,sizeof DLGHEAD
			invoke strcpy,addr (DLGHEAD ptr [edx]).class,addr buffer1
		.elseif eax==23
			invoke strcpy,addr [esi].class,addr buffer1
		.endif
	.elseif eax==PRP_STR_MENU
		mov		edx,esi
		sub		edx,sizeof DLGHEAD
		invoke strcpy,addr (DLGHEAD ptr [edx]).menuid,addr buffer1
	.elseif eax==PRP_FUN_STYLE || eax==PRP_FUN_EXSTYLE
		.if eax==PRP_FUN_STYLE
			invoke HexToBin,addr buffer1
			mov		[esi].style,eax
		.else
			invoke HexToBin,addr buffer1
			mov		[esi].exstyle,eax
		.endif
	.endif
	mov		eax,lbid
	;Is True/False Style or Multi Style changed
	mov		edi,lpPtr
	.if eax>=PRP_BOOL_SYSMENU && eax<=499
		.if eax==223
			mov		eax,[esi].exstyle
			and		eax,[edi]
			or		eax,[edi+4]
			mov		[esi].exstyle,eax
		.else
			mov		eax,[esi].style
			and		eax,[edi]
			or		eax,[edi+4]
			mov		[esi].style,eax
		.endif
		;Is Multi Style changed
		mov		eax,lbid
		.if eax>=PRP_MULTI_CLIP
			mov		eax,[esi].exstyle
			and		eax,[edi+8]
			or		eax,[edi+12]
			mov		[esi].exstyle,eax
		.endif
	.elseif eax>65535
		.if dword ptr [eax]==1
			mov		eax,[esi].style
			and		eax,[edi]
			or		eax,[edi+4]
			mov		[esi].style,eax
		.elseif dword ptr [eax]==2
			mov		eax,[esi].exstyle
			and		eax,[edi]
			or		eax,[edi+4]
			mov		[esi].exstyle,eax
		.elseif dword ptr [eax]==3
			mov		eax,[esi].style
			and		eax,[edi]
			or		eax,[edi+4]
			mov		[esi].style,eax
			mov		eax,[esi].exstyle
			and		eax,[edi+8]
			or		eax,[edi+12]
			mov		[esi].exstyle,eax
		.endif
	.endif
	assume esi:nothing
	retn

PropEditUpdList endp

ListFalseTrue proc uses esi,CtlVal:DWORD,lpVal:DWORD,lpBuff:DWORD

	mov		esi,lpVal
	mov		eax,[esi]
	xor		eax,-1
	and		eax,CtlVal
	.if eax==[esi+4]
		invoke strcpy,lpBuff,addr szFalse
	.else
		invoke strcpy,lpBuff,addr szTrue
	.endif
	ret

ListFalseTrue endp

ListMultiStyle proc uses esi,CtlValSt:DWORD,CtlValExSt:DWORD,lpVal:DWORD,lpBuff:DWORD
	LOCAL	buffer[512]:BYTE
	LOCAL	buffer1[64]:BYTE

	invoke strcpy,addr buffer,lpVal
	invoke strlen,lpVal
	add		lpVal,eax
	inc		lpVal
 @@:
	invoke GetStrItem,addr buffer,addr buffer1
	mov		esi,lpVal
	mov		eax,[esi]
	xor		eax,-1
	and		eax,CtlValSt
	.if eax==[esi+4]
		mov		eax,[esi+8]
		xor		eax,-1
		and		eax,CtlValExSt
		.if eax==[esi+12]
			invoke strcpy,lpBuff,addr buffer1
			ret
		.endif
	.endif
	add		lpVal,16
	mov		al,buffer[0]
	or		al,al
	jne		@b
	ret

ListMultiStyle endp

GetCustProp proc nType:DWORD,nProp:DWORD

	invoke GetTypePtr,nType
	mov		edx,nProp
	sub		edx,[eax].TYPES.nmethod
	mov		eax,[eax].TYPES.methods
	.if eax
		lea		eax,[eax+edx*8]
	.endif
	ret

GetCustProp endp

PropertyList proc uses ebx esi edi,hCtl:DWORD
	LOCAL	buffer[1024]:BYTE
	LOCAL	buffer1[512]:BYTE
	LOCAL	nType:DWORD
	LOCAL	lbid:DWORD
	LOCAL	fList1:DWORD
	LOCAL	fList2:DWORD
	LOCAL	fList3:DWORD
	LOCAL	fList4:DWORD
	LOCAL	nInx:DWORD
	LOCAL	tInx:DWORD

	invoke ShowWindow,hPrpEdtDlgCld,SW_HIDE
	invoke ShowWindow,hPrpEdtDlgCldMulti,SW_HIDE
	invoke ShowWindow,hPrpBtnDlgCld,SW_HIDE
	invoke ShowWindow,hPrpLstDlgCld,SW_HIDE
	invoke SendMessage,hPrpCboDlg,CB_RESETCONTENT,0,0
	invoke SendMessage,hPrpLstDlg,LB_GETTOPINDEX,0,0
	mov		tInx,eax
	invoke SendMessage,hPrpLstDlg,WM_SETREDRAW,FALSE,0
	invoke SendMessage,hPrpLstDlg,LB_RESETCONTENT,0,0
	invoke SetWindowLong,hPrpLstDlg,GWL_USERDATA,hCtl
	.if hCtl
		.if hCtl==-1
			mov		fList1,11111110100111000000000001000000b
						;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
			mov		fList2,00000000000000000000000000000000b
						;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
			mov		fList3,00001000000000000000000000000000b
						;  SELHHFM
			mov		fList4,00000000000000000000000000000000b
						;
			invoke GetParent,hMultiSel
			mov		hCtl,eax
			invoke GetCtrlMem,hCtl
			mov		esi,eax
			mov		eax,[esi].DIALOG.ntype
			mov		nType,eax
			mov		eax,hMultiSel
		  @@:
			push	eax
			invoke GetParent,eax
			invoke GetCtrlMem,eax
			mov		eax,[eax].DIALOG.ntype
			.if eax!=nType
				mov		nType,-1
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
			.if nType!=-1
				; Enable Style and ExStyle
				or		fList2,00000000000000011000000000000000b
							;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
			.endif
			invoke SetWindowLong,hPrpLstDlg,GWL_USERDATA,hCtl
			mov		eax,hMultiSel
		  @@:
			push	eax
			invoke GetParent,eax
			invoke GetCtrlMem,eax
			mov		edi,eax
			mov		eax,[edi].DIALOG.ntype
			mov		nType,eax
			invoke GetTypePtr,nType
			mov		edi,eax
			mov		eax,(TYPES ptr [edi]).flist
			and		fList1,eax
			mov		eax,(TYPES ptr [edi]).flist+4
			and		fList2,eax
			mov		eax,(TYPES ptr [edi]).flist+8
			and		fList3,eax
			mov		eax,(TYPES ptr [edi]).flist+12
			and		fList4,eax
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
		.elseif hCtl==-2
			;Version
			mov		fList1,11000000000000000000000000000000b
						;  NILTWHCBSMMEVCSDAAMWMTLCSTFMCNAW
			mov		fList2,00000000000000000000000000000000b
						;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
			mov		fList3,00000000000000000000000000000000b
						;  SELHHFM
			mov		fList4,00000000000000000000000000000000b
						;
			mov		nType,-2
		.elseif hCtl==-3
			;XP Manifest
			mov		fList1,11000000000000000000000000000000b
						;  NILTWHCBSMMEVCSDAAMWMTLCSTFMCNAW
			mov		fList2,00000000000000000000000000000000b
						;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
			mov		fList3,00000100000000000000000000000000b
						;  SELHHFM
			mov		fList4,00000000000000000000000000000000b
						;
			mov		nType,-2
		.elseif hCtl==-4
			;Accelerator
			mov		fList1,11000000000000000000000000000000b
						;  NILTWHCBSMMEVCSDAAMWMTLCSTFMCNAW
			mov		fList2,00000000000000000000000000000000b
						;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
			mov		fList3,00100000000000000000000000000000b
						;  SELHHFM
			mov		fList4,00000000000000000000000000000000b
						;
			mov		nType,-2
		.elseif hCtl==-5
			;Stringtable
			mov		fList1,00000000000000000000000000000000b
						;  NILTWHCBSMMEVCSDAAMWMTLCSTFMCNAW
			mov		fList2,00000000000000000000000000000000b
						;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
			mov		fList3,00100000000000000000000000000000b
						;  SELHHFM
			mov		fList4,00000000000000000000000000000000b
						;
			mov		nType,-2
		.elseif hCtl==-6
			;Toolbar
			mov		fList1,11001100000000000000000000000000b
						;  NILTWHCBSMMEVCSDAAMWMTLCSTFMCNAW
			mov		fList2,00000000000000000000000000000000b
						;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
			mov		fList3,00000000000000000000000000000000b
						;  SELHHFM
			mov		fList4,00000000000000000000000000000000b
						;
			mov		nType,-2
		.elseif hCtl==-7
			;Menu
			mov		fList1,11000000000000000000000000000000b
						;  NILTWHCBSMMEVCSDAAMWMTLCSTFMCNAW
			mov		fList2,00100000000000000000000000000000b
						;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
			mov		fList3,00100010000000000000000000000000b
						;  SELHHFM
			mov		fList4,00000000000000000000000000000000b
						;
			mov		nType,-2
		.elseif hCtl==-8
			;RCDATA
			mov		fList1,11000000000000000000000000000000b
						;  NILTWHCBSMMEVCSDAAMWMTLCSTFMCNAW
			mov		fList2,00000000000000000000000000000000b
						;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
			mov		fList3,00100000000000000000000000000000b
						;  SELHHFM
			mov		fList4,00000000000000000000000000000000b
						;
			mov		nType,-2
		.elseif hCtl==-9
			;USERDATA
			mov		fList1,11000000000000000000000000000000b
						;  NILTWHCBSMMEVCSDAAMWMTLCSTFMCNAW
			mov		fList2,00000000000000000000000000000000b
						;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
			mov		fList3,00000000000000000000000000000000b
						;  SELHHFM
			mov		fList4,00000000000000000000000000000000b
						;
			mov		nType,-2
		.else
			invoke GetCtrlMem,hCtl
			mov		esi,eax
			mov		eax,[esi].DIALOG.ntype
			mov		nType,eax
			invoke GetTypePtr,nType
			push	(TYPES ptr [eax]).flist
			pop		fList1
			push	(TYPES ptr [eax]).flist+4
			pop		fList2
			push	(TYPES ptr [eax]).flist+8
			pop		fList3
			push	(TYPES ptr [eax]).flist+12
			pop		fList4
			.if fSimpleProperty
				and		fList1,11111110000110000000000001001000b
							;  NILTWHCBSMMEVCSDAAMWMTLCSTFMCNAW
				and		fList2,00110000000000011000000000000000b
							;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
				and		fList3,00001000000000000000000000000000b
							;  SELHHFM
				and		fList4,00000000000000000000000000000000b
							;
			.endif
		.endif
		invoke strcpy,addr buffer,addr PrAll
		mov		nInx,0
	  @@:
		invoke GetStrItem,addr buffer,addr buffer1
		xor		eax,eax
		mov		al,buffer1[0]
		or		al,al
		je		@f
		shl		fList4,1
		rcl		fList3,1
		rcl		fList2,1
		rcl		fList1,1
		.if CARRY?
			invoke strlen,addr buffer1
			lea		edi,buffer1[eax]
			mov		ax,09h
			stosw
			dec		edi
			mov		eax,nType
			mov		edx,nInx
			mov		lbid,0
			.if edx==0
				;(Name)
				mov		lbid,PRP_STR_NAME
				push	eax
				.if eax==-2
					mov		eax,lpResName
				.else
					lea		eax,[esi].DIALOG.idname
				.endif
				invoke strcpy,edi,eax
				pop		eax
				.if hMultiSel
					mov		eax,hMultiSel
					.while eax
						push	eax
						invoke GetParent,eax
						invoke GetCtrlMem,eax
						mov		ebx,eax
						invoke strcmp,addr [esi].DIALOG.idname,addr [ebx].DIALOG.idname
						.if eax
							mov		byte ptr [edi],0
						.endif
						pop		eax
						mov		ecx,8
						.while ecx
							push	ecx
							invoke GetWindowLong,eax,GWL_USERDATA
							pop		ecx
							dec		ecx
						.endw
					.endw
				.else
					.if eax==4
						;Button
						mov		lbid,PRP_STR_NAMEBTN
					.elseif eax==2 || eax==17 || eax==25
						;Static, Image and Shape
						mov		lbid,PRP_STR_NAMESTC
					.endif
				.endif
			.elseif edx==1
				;(ID)
				mov		lbid,PRP_NUM_ID
				.if eax==-2
					mov		eax,lpResID
					mov		eax,[eax]
				.else
					mov		eax,[esi].DIALOG.id
				.endif
				invoke ResEdBinToDec,eax,edi
				.if hMultiSel
					mov		eax,hMultiSel
					.while eax
						push	eax
						invoke GetParent,eax
						invoke GetCtrlMem,eax
						mov		ebx,eax
						mov		eax,[esi].DIALOG.id
						sub		eax,[ebx].DIALOG.id
						.if eax
							mov		byte ptr [edi],0
						.endif
						pop		eax
						mov		ecx,8
						.while ecx
							push	ecx
							invoke GetWindowLong,eax,GWL_USERDATA
							pop		ecx
							dec		ecx
						.endw
					.endw
				.endif
			.elseif edx==2
				;Left
				mov		lbid,PRP_NUM_POSL
				invoke ResEdBinToDec,[esi].DIALOG.dux,edi
				.if hMultiSel
					mov		eax,hMultiSel
					.while eax
						push	eax
						invoke GetParent,eax
						invoke GetCtrlMem,eax
						mov		ebx,eax
						mov		eax,[esi].DIALOG.dux
						sub		eax,[ebx].DIALOG.dux
						.if eax
							mov		byte ptr [edi],0
						.endif
						pop		eax
						mov		ecx,8
						.while ecx
							push	ecx
							invoke GetWindowLong,eax,GWL_USERDATA
							pop		ecx
							dec		ecx
						.endw
					.endw
				.endif
			.elseif edx==3
				;Top
				mov		lbid,PRP_NUM_POST
				invoke ResEdBinToDec,[esi].DIALOG.duy,edi
				.if hMultiSel
					mov		eax,hMultiSel
					.while eax
						push	eax
						invoke GetParent,eax
						invoke GetCtrlMem,eax
						mov		ebx,eax
						mov		eax,[esi].DIALOG.duy
						sub		eax,[ebx].DIALOG.duy
						.if eax
							mov		byte ptr [edi],0
						.endif
						pop		eax
						mov		ecx,8
						.while ecx
							push	ecx
							invoke GetWindowLong,eax,GWL_USERDATA
							pop		ecx
							dec		ecx
						.endw
					.endw
				.endif
			.elseif edx==4
				;Width
				mov		lbid,PRP_NUM_SIZEW
				.if hCtl==-6
					mov		eax,lpResWidth
					mov		eax,[eax]
					invoke ResEdBinToDec,eax,edi
				.else
					invoke ResEdBinToDec,[esi].DIALOG.duccx,edi
					.if hMultiSel
						mov		eax,hMultiSel
						.while eax
							push	eax
							invoke GetParent,eax
							invoke GetCtrlMem,eax
							mov		ebx,eax
							mov		eax,[esi].DIALOG.duccx
							sub		eax,[ebx].DIALOG.duccx
							.if eax
								mov		byte ptr [edi],0
							.endif
							pop		eax
							mov		ecx,8
							.while ecx
								push	ecx
								invoke GetWindowLong,eax,GWL_USERDATA
								pop		ecx
								dec		ecx
							.endw
						.endw
					.endif
				.endif
			.elseif edx==5
				;Height
				mov		lbid,PRP_NUM_SIZEH
				.if hCtl==-6
					mov		eax,lpResHeight
					mov		eax,[eax]
					invoke ResEdBinToDec,eax,edi
				.else
					invoke ResEdBinToDec,[esi].DIALOG.duccy,edi
					.if hMultiSel
						mov		eax,hMultiSel
						.while eax
							push	eax
							invoke GetParent,eax
							invoke GetCtrlMem,eax
							mov		ebx,eax
							mov		eax,[esi].DIALOG.duccy
							sub		eax,[ebx].DIALOG.duccy
							.if eax
								mov		byte ptr [edi],0
							.endif
							pop		eax
							mov		ecx,8
							.while ecx
								push	ecx
								invoke GetWindowLong,eax,GWL_USERDATA
								pop		ecx
								dec		ecx
							.endw
						.endw
					.endif
				.endif
			.elseif edx==6
				;Caption
				mov		lbid,PRP_STR_CAPTION
				push	eax
				invoke strcpy,edi,addr [esi].DIALOG.caption
				pop		eax
				.if hMultiSel
					mov		eax,hMultiSel
					.while eax
						push	eax
						invoke GetParent,eax
						invoke GetCtrlMem,eax
						mov		ebx,eax
						invoke strcmp,addr [esi].DIALOG.caption,addr [ebx].DIALOG.caption
						.if eax
							mov		byte ptr [edi],0
						.endif
						pop		eax
						mov		ecx,8
						.while ecx
							push	ecx
							invoke GetWindowLong,eax,GWL_USERDATA
							pop		ecx
							dec		ecx
						.endw
					.endw
				.else
					.if eax==1
						;Edit
						mov		eax,[esi].DIALOG.style
						test	eax,ES_MULTILINE
						.if !ZERO?
							mov		lbid,PRP_STR_CAPMULTI
						.endif
					.elseif eax==2
						;Static
						mov		lbid,PRP_STR_CAPMULTI
					.elseif eax==4
						;Button
						mov		eax,[esi].DIALOG.style
						test	eax,BS_MULTILINE
						.if !ZERO?
							mov		lbid,PRP_STR_CAPMULTI
						.endif
					.elseif eax==22
						;RichEdit
						mov		eax,[esi].DIALOG.style
						test	eax,ES_MULTILINE
						.if !ZERO?
							mov		lbid,PRP_STR_CAPMULTI
						.endif
					.endif
				.endif
			.elseif edx==7
				;Border
				mov		lbid,PRP_MULTI_BORDER
				.if eax==0
					invoke ListMultiStyle,[esi].DIALOG.style,[esi].DIALOG.exstyle,addr BordDlg,edi
				.elseif eax==2 || eax==17 || eax==25
					invoke ListMultiStyle,[esi].DIALOG.style,[esi].DIALOG.exstyle,addr BordStc,edi
				.elseif eax==3 || eax==4
					invoke ListMultiStyle,[esi].DIALOG.style,[esi].DIALOG.exstyle,addr BordBtn,edi
				.else
					invoke ListMultiStyle,[esi].DIALOG.style,[esi].DIALOG.exstyle,addr BordAll,edi
				.endif
			.elseif edx==8
				;SysMenu
				mov		lbid,PRP_BOOL_SYSMENU
				invoke ListFalseTrue,[esi].DIALOG.style,addr SysMDlg,edi
			.elseif edx==9
				;MaxButton
				mov		lbid,PRP_BOOL_MAXBUTTON
				invoke ListFalseTrue,[esi].DIALOG.style,addr MaxBDlg,edi
			.elseif edx==10
				;MinButton
				mov		lbid,PRP_BOOL_MINBUTTON
				invoke ListFalseTrue,[esi].DIALOG.style,addr MinBDlg,edi
			.elseif edx==11
				;Enabled
				mov		lbid,PRP_BOOL_ENABLED
				invoke ListFalseTrue,[esi].DIALOG.style,addr EnabAll,edi
				.if hMultiSel
					mov		eax,hMultiSel
					.while eax
						push	eax
						invoke GetParent,eax
						invoke GetCtrlMem,eax
						mov		ebx,eax
						mov		eax,[esi].DIALOG.style
						and		eax,WS_DISABLED
						mov		edx,[ebx].DIALOG.style
						and		edx,WS_DISABLED
						sub		eax,edx
						.if eax
							mov		byte ptr [edi],0
						.endif
						pop		eax
						mov		ecx,8
						.while ecx
							push	ecx
							invoke GetWindowLong,eax,GWL_USERDATA
							pop		ecx
							dec		ecx
						.endw
					.endw
				.endif
			.elseif edx==12
				;Visible
				mov		lbid,PRP_BOOL_VISIBLE
				invoke ListFalseTrue,[esi].DIALOG.style,addr VisiAll,edi
				.if hMultiSel
					mov		eax,hMultiSel
					.while eax
						push	eax
						invoke GetParent,eax
						invoke GetCtrlMem,eax
						mov		ebx,eax
						mov		eax,[esi].DIALOG.style
						and		eax,WS_VISIBLE
						mov		edx,[ebx].DIALOG.style
						and		edx,WS_VISIBLE
						sub		eax,edx
						.if eax
							mov		byte ptr [edi],0
						.endif
						pop		eax
						mov		ecx,8
						.while ecx
							push	ecx
							invoke GetWindowLong,eax,GWL_USERDATA
							pop		ecx
							dec		ecx
						.endw
					.endw
				.endif
			.elseif edx==13
				;Clipping
				mov		lbid,PRP_MULTI_CLIP
				invoke ListMultiStyle,[esi].DIALOG.style,[esi].DIALOG.exstyle,addr ClipAll,edi
				.if hMultiSel
					mov		eax,hMultiSel
					.while eax
						push	eax
						invoke GetParent,eax
						invoke GetCtrlMem,eax
						mov		ebx,eax
						mov		eax,[esi].DIALOG.style
						and		eax,WS_CLIPCHILDREN or WS_CLIPSIBLINGS
						mov		edx,[ebx].DIALOG.style
						and		edx,WS_CLIPCHILDREN or WS_CLIPSIBLINGS
						sub		eax,edx
						.if eax
							mov		byte ptr [edi],0
						.endif
						pop		eax
						mov		ecx,8
						.while ecx
							push	ecx
							invoke GetWindowLong,eax,GWL_USERDATA
							pop		ecx
							dec		ecx
						.endw
					.endw
				.endif
			.elseif edx==14
				;ScrollBar
				mov		lbid,PRP_MULTI_SCROLL
				invoke ListMultiStyle,[esi].DIALOG.style,[esi].DIALOG.exstyle,addr ScroAll,edi
			.elseif edx==15
				;Default
				mov		lbid,PRP_BOOL_DEFAULT
				invoke ListFalseTrue,[esi].DIALOG.style,addr DefaBtn,edi
			.elseif edx==16
				;Auto
				mov		lbid,PRP_BOOL_AUTO
				.if eax==5
					invoke ListFalseTrue,[esi].DIALOG.style,addr AutoChk,edi
				.elseif eax==6
					invoke ListFalseTrue,[esi].DIALOG.style,addr AutoRbt,edi
				.elseif eax==16
					invoke ListFalseTrue,[esi].DIALOG.style,addr AutoSpn,edi
				.endif
			.elseif edx==17
				;Alignment
				mov		lbid,PRP_MULTI_ALIGN
				.if eax==1
					invoke ListMultiStyle,[esi].DIALOG.style,[esi].DIALOG.exstyle,addr AligEdt,edi
				.elseif eax==2
					invoke ListMultiStyle,[esi].DIALOG.style,[esi].DIALOG.exstyle,addr AligStc,edi
				.elseif eax==4
					invoke ListMultiStyle,[esi].DIALOG.style,[esi].DIALOG.exstyle,addr AligBtn,edi
				.elseif eax==5 || eax==6
					invoke ListMultiStyle,[esi].DIALOG.style,[esi].DIALOG.exstyle,addr AligChk,edi
				.elseif eax==11
					invoke ListMultiStyle,[esi].DIALOG.style,[esi].DIALOG.exstyle,addr AligTab,edi
				.elseif eax==14
					invoke ListMultiStyle,[esi].DIALOG.style,[esi].DIALOG.exstyle,addr AligLsv,edi
				.elseif eax==16
					invoke ListMultiStyle,[esi].DIALOG.style,[esi].DIALOG.exstyle,addr AligSpn,edi
				.elseif eax==17
					invoke ListMultiStyle,[esi].DIALOG.style,[esi].DIALOG.exstyle,addr AligIco,edi
				.elseif eax==18 || eax==19
					invoke ListMultiStyle,[esi].DIALOG.style,[esi].DIALOG.exstyle,addr AligTbr,edi
				.elseif eax==27
					invoke ListMultiStyle,[esi].DIALOG.style,[esi].DIALOG.exstyle,addr AligAni,edi
				.endif
			.elseif edx==18
				;Mnemonic
				mov		lbid,PRP_BOOL_MNEMONIC
				invoke ListFalseTrue,[esi].DIALOG.style,addr MnemStc,edi
			.elseif edx==19
				;WordWrap
				mov		lbid,PRP_BOOL_WORDWRAP
				invoke ListFalseTrue,[esi].DIALOG.style,addr WordStc,edi
			.elseif edx==20
				;MultiLine
				mov		lbid,PRP_BOOL_MULTI
				.if eax==1 || eax==22
					invoke ListFalseTrue,[esi].DIALOG.style,addr MultEdt,edi
				.elseif eax==4 || eax==5 || eax==6
					invoke ListFalseTrue,[esi].DIALOG.style,addr MultBtn,edi
				.elseif eax==11
					invoke ListFalseTrue,[esi].DIALOG.style,addr MultTab,edi
				.endif
			.elseif edx==21
				;Type
				mov		lbid,PRP_MULTI_TYPE
				.if eax==1
					invoke ListMultiStyle,[esi].DIALOG.style,[esi].DIALOG.exstyle,addr TypeEdt,edi
				.elseif eax==4
					invoke ListMultiStyle,[esi].DIALOG.style,[esi].DIALOG.exstyle,addr TypeBtn,edi
				.elseif eax==7 || eax==24
					invoke ListMultiStyle,[esi].DIALOG.style,[esi].DIALOG.exstyle,addr TypeCbo,edi
				.elseif eax==13
					invoke ListMultiStyle,[esi].DIALOG.style,[esi].DIALOG.exstyle,addr TypeTrv,edi
				.elseif eax==14
					invoke ListMultiStyle,[esi].DIALOG.style,[esi].DIALOG.exstyle,addr TypeLsv,edi
				.elseif eax==17
					invoke ListMultiStyle,[esi].DIALOG.style,[esi].DIALOG.exstyle,addr TypeImg,edi
				.elseif eax==20
					invoke ListMultiStyle,[esi].DIALOG.style,[esi].DIALOG.exstyle,addr TypeDtp,edi
				.elseif eax==25
					invoke ListMultiStyle,[esi].DIALOG.style,[esi].DIALOG.exstyle,addr TypeStc,edi
				.endif
			.elseif edx==22
				;Locked
				mov		lbid,PRP_BOOL_LOCK
				invoke ListFalseTrue,[esi].DIALOG.style,addr LockEdt,edi
			.elseif edx==23
				;Child
				mov		lbid,PRP_BOOL_CHILD
				invoke ListFalseTrue,[esi].DIALOG.style,addr ChilAll,edi
			.elseif edx==24
				;SizeBorder
				mov		lbid,PRP_BOOL_SIZE
				.if eax==0
					invoke ListFalseTrue,[esi].DIALOG.style,addr SizeDlg,edi
				.endif
			.elseif edx==25
				;TabStop
				mov		lbid,PRP_BOOL_TABSTOP
				invoke ListFalseTrue,[esi].DIALOG.style,addr TabSAll,edi
				.if hMultiSel
					mov		eax,hMultiSel
					.while eax
						push	eax
						invoke GetParent,eax
						invoke GetCtrlMem,eax
						mov		ebx,eax
						mov		eax,[esi].DIALOG.style
						and		eax,WS_TABSTOP
						mov		edx,[ebx].DIALOG.style
						and		edx,WS_TABSTOP
						sub		eax,edx
						.if eax
							mov		byte ptr [edi],0
						.endif
						pop		eax
						mov		ecx,8
						.while ecx
							push	ecx
							invoke GetWindowLong,eax,GWL_USERDATA
							pop		ecx
							dec		ecx
						.endw
					.endw
				.endif
			.elseif edx==26
				;Font
				mov		lbid,PRP_STR_FONT
				sub		esi,sizeof DLGHEAD
				.if byte ptr (DLGHEAD ptr [esi]).font
					mov		eax,(DLGHEAD ptr [esi]).fontsize
					invoke ResEdBinToDec,eax,edi
					invoke strlen,edi
					lea		edi,[edi+eax]
					mov		al,','
					stosb
				.endif
				invoke strcpy,edi,addr (DLGHEAD ptr [esi]).font
				add		esi,sizeof DLGHEAD
			.elseif edx==27
				;Menu
				mov		lbid,PRP_STR_MENU
				sub		esi,sizeof DLGHEAD
				invoke strcpy,edi,addr (DLGHEAD ptr [esi]).menuid
				add		esi,sizeof DLGHEAD
			.elseif edx==28
				;Class
				mov		lbid,PRP_STR_CLASS
				.if eax==0
					sub		esi,sizeof DLGHEAD
					invoke strcpy,edi,addr (DLGHEAD ptr [esi]).class
					add		esi,sizeof DLGHEAD
				.elseif eax==23
					invoke strcpy,edi,addr (DIALOG ptr [esi]).class
				.endif
			.elseif edx==29
				;Notify
				mov		lbid,PRP_BOOL_NOTIFY
				.if eax==2 || eax==17 || eax==25
					invoke ListFalseTrue,[esi].DIALOG.style,addr NotiStc,edi
				.elseif eax==4 || eax==5 || eax==6
					invoke ListFalseTrue,[esi].DIALOG.style,addr NotiBtn,edi
				.elseif eax==8
					invoke ListFalseTrue,[esi].DIALOG.style,addr NotiLst,edi
				.endif
			.elseif edx==30
				;AutoScroll
				.if eax==1 || eax==22
					mov		lbid,PRP_MULTI_AUTOSCROLL
					invoke ListMultiStyle,[esi].DIALOG.style,[esi].DIALOG.exstyle,addr AutoEdt,edi
				.elseif eax==7
					mov		lbid,PRP_BOOL_AUTOSCROLL
					invoke ListFalseTrue,[esi].DIALOG.style,addr AutoCbo,edi
				.endif
			.elseif edx==31
				;WantCr
				mov		lbid,PRP_BOOL_WANTCR
				invoke ListFalseTrue,[esi].DIALOG.style,addr WantEdt,edi
;****
			.elseif edx==32
				;Sort
				mov		lbid,PRP_BOOL_SORT
				.if eax==7
					invoke ListFalseTrue,[esi].DIALOG.style,addr SortCbo,edi
				.elseif eax==8
					invoke ListFalseTrue,[esi].DIALOG.style,addr SortLst,edi
				.elseif eax==14
					mov		lbid,PRP_MULTI_SORT
					invoke ListMultiStyle,[esi].DIALOG.style,[esi].DIALOG.exstyle,addr SortLsv,edi
				.endif
			.elseif edx==33
				;Flat
				mov		lbid,PRP_BOOL_FLAT
				invoke ListFalseTrue,[esi].DIALOG.style,addr FlatTbr,edi
			.elseif edx==34
				;(StartID)
				mov		lbid,PRP_NUM_STARTID
				.if hCtl==-7
					mov		eax,lpResStartID
					mov		eax,[eax]
					invoke ResEdBinToDec,eax,edi
				.else
					sub		esi,sizeof DLGHEAD
					invoke ResEdBinToDec,(DLGHEAD ptr [esi]).ctlid,edi
					add		esi,sizeof DLGHEAD
				.endif
			.elseif edx==35
				;TabIndex
				mov		lbid,PRP_NUM_TAB
				invoke ResEdBinToDec,[esi].DIALOG.tab,edi
			.elseif edx==36
				;Format
				mov		lbid,PRP_MULTI_FORMAT
				invoke ListMultiStyle,[esi].DIALOG.style,[esi].DIALOG.exstyle,addr FormDtp,edi
			.elseif edx==37
				;SizeGrip
				mov		lbid,PRP_BOOL_SIZE
				.if eax==19
					invoke ListFalseTrue,[esi].DIALOG.style,addr SizeSbr,edi
				.endif
			.elseif edx==38
				;Group
				mov		lbid,PRP_BOOL_GROUP
				invoke ListFalseTrue,[esi].DIALOG.style,addr GrouAll,edi
			.elseif edx==39
				;Icon
				mov		lbid,PRP_BOOL_ICON
			.elseif edx==40
				;UseTabs
				mov		lbid,PRP_BOOL_USETAB
				invoke ListFalseTrue,[esi].DIALOG.style,addr UseTLst,edi
			.elseif edx==41
				;StartupPos
				mov		lbid,PRP_MULTI_STARTPOS
				invoke ListMultiStyle,[esi].DIALOG.style,[esi].DIALOG.exstyle,addr StarDlg,edi
			.elseif edx==42
				;Orientation
				mov		lbid,PRP_MULTI_ORIENT
				.if eax==12
					invoke ListMultiStyle,[esi].DIALOG.style,[esi].DIALOG.exstyle,addr OriePgb,edi
				.elseif eax==16
					invoke ListMultiStyle,[esi].DIALOG.style,[esi].DIALOG.exstyle,addr OrieUdn,edi
				.endif
			.elseif edx==43
				;SetBuddy
				mov		lbid,PRP_BOOL_SETBUDDY
				invoke ListFalseTrue,[esi].DIALOG.style,addr SetBUdn,edi
			.elseif edx==44
				;MultiSelect
				mov		lbid,PRP_BOOL_MULTI
				.if eax==8
					invoke ListFalseTrue,[esi].DIALOG.style,addr MultLst,edi
				.elseif eax==21
					invoke ListFalseTrue,[esi].DIALOG.style,addr MultMvi,edi
				.endif
			.elseif edx==45
				;HideSel
				mov		lbid,PRP_BOOL_HIDE
				.if eax==1 || eax==22
					invoke ListFalseTrue,[esi].DIALOG.style,addr HideEdt,edi
				.elseif eax==13
					invoke ListFalseTrue,[esi].DIALOG.style,addr HideTrv,edi
				.elseif eax==14
					invoke ListFalseTrue,[esi].DIALOG.style,addr HideLsv,edi
				.endif
			.elseif edx==46
				;TopMost
				mov		lbid,PRP_BOOL_TOPMOST
				invoke ListFalseTrue,[esi].DIALOG.exstyle,addr TopMost,edi
			.elseif edx==47
				;xExStyle
				mov		lbid,PRP_FUN_EXSTYLE
				mov		eax,[esi].DIALOG.exstyle
				invoke hexEax
				invoke strcpy,edi,addr strHex
				.if hMultiSel
					mov		eax,hMultiSel
					.while eax
						push	eax
						invoke GetParent,eax
						invoke GetCtrlMem,eax
						mov		ebx,eax
						mov		eax,[esi].DIALOG.exstyle
						sub		eax,[ebx].DIALOG.exstyle
						.if eax
							mov		byte ptr [edi],0
						.endif
						pop		eax
						mov		ecx,8
						.while ecx
							push	ecx
							invoke GetWindowLong,eax,GWL_USERDATA
							pop		ecx
							dec		ecx
						.endw
					.endw
				.endif
			.elseif edx==48
				;xStyle
				mov		lbid,PRP_FUN_STYLE
				mov		eax,[esi].DIALOG.style
				invoke hexEax
				invoke strcpy,edi,addr strHex
				.if hMultiSel
					mov		eax,hMultiSel
					.while eax
						push	eax
						invoke GetParent,eax
						invoke GetCtrlMem,eax
						mov		ebx,eax
						mov		eax,[esi].DIALOG.style
						sub		eax,[ebx].DIALOG.style
						.if eax
							mov		byte ptr [edi],0
						.endif
						pop		eax
						mov		ecx,8
						.while ecx
							push	ecx
							invoke GetWindowLong,eax,GWL_USERDATA
							pop		ecx
							dec		ecx
						.endw
					.endw
				.endif
			.elseif edx==49
				;IntegralHgt
				mov		lbid,PRP_BOOL_INTEGRAL
				.if eax==7
					invoke ListFalseTrue,[esi].DIALOG.style,addr IntHtCbo,edi
				.elseif eax==8
					invoke ListFalseTrue,[esi].DIALOG.style,addr IntHtLst,edi
				.endif
			.elseif edx==50
				;Image
				mov		lbid,PRP_STR_IMAGE
				invoke strcpy,edi,addr [esi].DIALOG.caption
			.elseif edx==51
				;Buttons
				mov		lbid,PRP_BOOL_BUTTON
				.if eax==11
					invoke ListFalseTrue,[esi].DIALOG.style,addr ButtTab,edi
				.elseif eax==13
					invoke ListFalseTrue,[esi].DIALOG.style,addr ButtTrv,edi
				.elseif eax==32
					invoke ListFalseTrue,[esi].DIALOG.style,addr ButtHdr,edi
				.endif
			.elseif edx==52
				;PopUp
				mov		lbid,PRP_BOOL_POPUP
				invoke ListFalseTrue,[esi].DIALOG.style,addr PopUAll,edi
			.elseif edx==53
				;OwnerDraw
				mov		lbid,PRP_BOOL_OWNERDRAW
				.if eax==14
					invoke ListFalseTrue,[esi].DIALOG.style,addr OwneLsv,edi
				.elseif eax==7 || eax==8
					mov		lbid,PRP_MULTI_OWNERDRAW
					invoke ListMultiStyle,[esi].DIALOG.style,[esi].DIALOG.exstyle,addr OwneCbo,edi
				.endif
			.elseif edx==54
				;Transp
				mov		lbid,PRP_BOOL_TRANSP
				invoke ListFalseTrue,[esi].DIALOG.style,addr TranAni,edi
			.elseif edx==55
				;Timer
				mov		lbid,PRP_BOOL_TIME
				invoke ListFalseTrue,[esi].DIALOG.style,addr TimeAni,edi
			.elseif edx==56
				;AutoPlay
				mov		lbid,PRP_BOOL_AUTOPLAY
				.if eax==27
					invoke ListFalseTrue,[esi].DIALOG.style,addr AutoAni,edi
				.endif
			.elseif edx==57
				;WeekNum
				mov		lbid,PRP_BOOL_WEEK
				invoke ListFalseTrue,[esi].DIALOG.style,addr WeekMvi,edi
			.elseif edx==58
				;AviClip
				mov		lbid,PRP_STR_AVI
				invoke strcpy,edi,addr [esi].DIALOG.caption
			.elseif edx==59
				;AutoSize
				mov		lbid,PRP_BOOL_AUTOSIZE
				.if eax==18 || eax==19
					invoke ListFalseTrue,[esi].DIALOG.style,addr AutoTbr,edi
				.endif
			.elseif edx==60
				;ToolTip
				mov		lbid,PRP_BOOL_TOOLTIP
				.if eax==11
					invoke ListFalseTrue,[esi].DIALOG.style,addr ToolTab,edi
				.elseif eax==18
					invoke ListFalseTrue,[esi].DIALOG.style,addr ToolTbr,edi
				.elseif eax==19
					invoke ListFalseTrue,[esi].DIALOG.style,addr ToolSbr,edi
				.endif
			.elseif edx==61
				;Wrap
				mov		lbid,PRP_BOOL_WRAP
				invoke ListFalseTrue,[esi].DIALOG.style,addr WrapTbr,edi
			.elseif edx==62
				;Divider
				mov		lbid,PRP_BOOL_DIVIDER
				invoke ListFalseTrue,[esi].DIALOG.style,addr DiviTbr,edi
			.elseif edx==63
				;DragDrop
				mov		lbid,PRP_BOOL_DRAGDROP
				invoke ListFalseTrue,[esi].DIALOG.style,addr DragHdr,edi
			.elseif edx==64
				;Smooth
				mov		lbid,PRP_BOOL_SMOOTH
				invoke ListFalseTrue,[esi].DIALOG.style,addr SmooPgb,edi
			.elseif edx==65
				;Ellipsis
				mov		lbid,PRP_MULTI_ELLIPSIS
				invoke ListMultiStyle,[esi].DIALOG.style,[esi].DIALOG.exstyle,addr ElliStc,edi
			.elseif edx==66
				;Language
				mov		lbid,PRP_FUN_LANG
				.if hCtl==-4 || hCtl==-5 || hCtl==-7 || hCtl==-8
					mov		esi,lpResLang
					mov		eax,[esi].LANGUAGEMEM.lang
					invoke ResEdBinToDec,eax,edi
					invoke strlen,edi
					lea		edi,[edi+eax]
					mov		byte ptr [edi],','
					inc		edi
					mov		eax,[esi].LANGUAGEMEM.sublang
					invoke ResEdBinToDec,eax,edi
				.else
					sub		esi,sizeof DLGHEAD
					mov		eax,(DLGHEAD ptr [esi]).lang
					invoke ResEdBinToDec,eax,edi
					invoke strlen,edi
					lea		edi,[edi+eax]
					mov		byte ptr [edi],','
					inc		edi
					mov		eax,(DLGHEAD ptr [esi]).sublang
					invoke ResEdBinToDec,eax,edi
					add		esi,sizeof DLGHEAD
				.endif
			.elseif edx==67
				;HasStrings
				mov		lbid,PRP_BOOL_HASSTRINGS
				.if eax==7
					invoke ListFalseTrue,[esi].DIALOG.style,addr HasStcb,edi
				.elseif eax==8
					invoke ListFalseTrue,[esi].DIALOG.style,addr HasStlb,edi
				.endif
			.elseif edx==68
				;HelpID
				mov		lbid,PRP_NUM_HELPID
				invoke ResEdBinToDec,[esi].DIALOG.helpid,edi
				.if hMultiSel
					mov		eax,hMultiSel
					.while eax
						push	eax
						invoke GetParent,eax
						invoke GetCtrlMem,eax
						mov		ebx,eax
						mov		eax,[esi].DIALOG.helpid
						sub		eax,[ebx].DIALOG.helpid
						.if eax
							mov		byte ptr [edi],0
						.endif
						pop		eax
						mov		ecx,8
						.while ecx
							push	ecx
							invoke GetWindowLong,eax,GWL_USERDATA
							pop		ecx
							dec		ecx
						.endw
					.endw
				.endif
			.elseif edx==69
				;File
				mov		lbid,PRP_STR_FILE
				.if eax==-2
					invoke strcpy,edi,lpResFile
				.endif
			.elseif edx==70
				;MenuEx
				mov		lbid,PRP_BOOL_MENUEX
				.if eax==-2
					mov		eax,lpResMenuEx
					mov		eax,[eax]
					invoke ListFalseTrue,eax,addr MenuEx,edi
				.endif
			.elseif edx==71
				;SaveSel
				mov		lbid,PRP_BOOL_SAVESEL
				invoke ListFalseTrue,[esi].DIALOG.style,addr SaveRich,edi
			.elseif eax>=NoOfButtons
				;Custom properties
				invoke GetCustProp,eax,edx
				mov		lbid,eax
				.if eax
					.if dword ptr [eax]==1
						invoke ListFalseTrue,[esi].DIALOG.style,[eax+4],edi
					.elseif dword ptr [eax]==2
						invoke ListFalseTrue,[esi].DIALOG.exstyle,[eax+4],edi
					.elseif dword ptr [eax]==3
						invoke ListMultiStyle,[esi].DIALOG.style,[esi].DIALOG.exstyle,[eax+4],edi
					.endif
				.endif
			.endif
			invoke SendMessage,hPrpLstDlg,LB_ADDSTRING,0,addr buffer1
			invoke SendMessage,hPrpLstDlg,LB_SETITEMDATA,eax,lbid
		.endif
	  Nxt:
		inc		nInx
		jmp		@b
	  @@:
		invoke SendMessage,hPrpLstDlg,LB_SETTOPINDEX,tInx,0
		.if hCtl==-2 || hCtl==-3 || hCtl==-4 || hCtl==-5 || hCtl==-6 || hCtl==-7 || hCtl==-8 || hCtl==-9
			invoke SendMessage,hPrpCboDlg,CB_RESETCONTENT,0,0
			invoke SendMessage,hPrpCboDlg,CB_ADDSTRING,0,lpResType
			invoke SendMessage,hPrpCboDlg,CB_SETCURSEL,0,0
		.else
			invoke GetWindowLong,hDEd,DEWM_MEMORY
			.if eax
				invoke UpdateCbo,eax
				invoke GetWindowLong,hCtl,GWL_ID
				invoke SetCbo,eax
			.endif
		.endif
	.endif
	invoke SetFocus,hDEd
	invoke SendMessage,hPrpLstDlg,LB_FINDSTRING,-1,addr szLbString
	.if eax==LB_ERR
		xor		eax,eax
	.endif
	invoke SendMessage,hPrpLstDlg,LB_SETCURSEL,eax,0
	invoke SendMessage,hPrpLstDlg,WM_SETREDRAW,TRUE,0
	ret

PropertyList endp

PrpCboDlgProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	nInx:DWORD

	mov		eax,uMsg
	.if eax==WM_COMMAND
		mov		eax,wParam
		shr		eax,16
		.if eax==CBN_SELCHANGE
			invoke SendMessage,hWin,CB_GETCURSEL,0,0
			mov		nInx,eax
			invoke SendMessage,hWin,CB_GETITEMDATA,nInx,0
			.if !eax
				invoke GetWindowLong,hDEd,DEWM_DIALOG
			.else
				push	eax
				invoke GetWindowLong,hDEd,DEWM_DIALOG
				pop		edx
				invoke GetDlgItem,eax,edx
			.endif
			.if eax
				invoke SizeingRect,eax,FALSE
				push	eax
				invoke ShowWindow,hInvisible,SW_HIDE
				invoke ShowWindow,hInvisible,SW_SHOWNA
				pop		eax
			.endif
		.endif
	.endif
	invoke CallWindowProc,OldPrpCboDlgProc,hWin,uMsg,wParam,lParam
	ret

PrpCboDlgProc endp

PrpLstDlgProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	nInx:DWORD
	LOCAL	rect:RECT
	LOCAL	hCtl:DWORD
	LOCAL	lbid:DWORD
	LOCAL	lf:LOGFONT
    LOCAL	hDC:DWORD
    LOCAL	cf:CHOOSEFONT
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	ofn:OPENFILENAME


	mov		eax,uMsg
	.if eax==WM_LBUTTONDBLCLK
		invoke SendMessage,hWin,LB_GETCURSEL,0,0
		mov		nInx,eax
		invoke SendMessage,hWin,LB_GETITEMDATA,nInx,0
		mov		lbid,eax
		.if (eax>=PRP_BOOL_SYSMENU && eax<=499) || eax>65535 || eax==PRP_STR_NAMEBTN || eax==PRP_STR_NAMESTC
			invoke SendMessage,hWin,WM_SETREDRAW,FALSE,0
			invoke SendMessage,hWin,WM_COMMAND,1,0
			invoke ShowWindow,hPrpLstDlgCld,SW_HIDE
			invoke ShowWindow,hPrpEdtDlgCld,SW_HIDE
			invoke SendMessage,hPrpLstDlgCld,LB_GETCURSEL,0,0
			inc		eax
			mov		nInx,eax
			invoke SendMessage,hPrpLstDlgCld,LB_GETCOUNT,0,0
			.if eax==nInx
				mov		nInx,0
			.endif
			invoke SendMessage,hPrpLstDlgCld,LB_SETCURSEL,nInx,0
			invoke SendMessage,hPrpLstDlgCld,WM_LBUTTONUP,0,0
			invoke SendMessage,hWin,WM_SETREDRAW,TRUE,0
			invoke SetFocus,hWin
		.elseif eax==PRP_STR_FONT || eax==PRP_STR_MENU || eax==1003 || eax==1004 || eax==PRP_STR_IMAGE || eax==PRP_STR_AVI || eax==PRP_FUN_LANG || eax==PRP_STR_CAPMULTI || eax==PRP_STR_FILE
			invoke SendMessage,hWin,WM_COMMAND,1,0
		.else
			invoke PropListSetPos
			invoke ShowWindow,hPrpEdtDlgCld,SW_SHOW
			invoke SetFocus,hPrpEdtDlgCld
			invoke SendMessage,hPrpEdtDlgCld,EM_SETSEL,0,-1
		.endif
		xor		eax,eax
		ret
	.elseif eax==WM_LBUTTONDOWN
		invoke ShowWindow,hPrpLstDlgCld,SW_HIDE
	.elseif eax==WM_MOUSEMOVE
		.if hStatus
			invoke SendMessage,hStatus,SB_SETTEXT,nStatus,offset szNULL
		.endif
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED && eax==1
			invoke GetWindowLong,hPrpLstDlgCld,GWL_STYLE
			and		eax,WS_VISIBLE
			.if eax
				invoke ShowWindow,hPrpLstDlgCld,SW_HIDE
			.else
				invoke SendMessage,hWin,LB_GETCURSEL,0,0
				.if eax!=LB_ERR
					mov		nInx,eax
					invoke GetWindowLong,hWin,GWL_USERDATA
					mov		hCtl,eax
					invoke SendMessage,hWin,LB_GETITEMDATA,nInx,0
					mov		lbid,eax
					.if eax==PRP_STR_FONT
						;Font
						invoke RtlZeroMemory,addr lf,sizeof lf
						invoke GetCtrlMem,hCtl
						mov		esi,eax
						sub		esi,sizeof DLGHEAD
						invoke strcpy,addr lf.lfFaceName,addr [esi].DLGHEAD.font
						mov		eax,[esi].DLGHEAD.fontsize
						mov		ecx,96
						mul		ecx
						mov		ecx,72
						xor		edx,edx
						div		ecx
						neg		eax
						mov		lf.lfHeight,eax
						mov		al,[esi].DLGHEAD.charset
						mov		lf.lfCharSet,al
						mov		al,[esi].DLGHEAD.italic
						mov		lf.lfItalic,al
						movzx	eax,word ptr [esi].DLGHEAD.weight
						mov		lf.lfWeight,eax
						mov		cf.lStructSize,sizeof CHOOSEFONT
						invoke GetDC,hWin
						mov		hDC, eax
						mov		cf.hDC,eax
						push	hWin
						pop		cf.hWndOwner
						lea		eax,lf
						mov		cf.lpLogFont,eax
						mov		cf.iPointSize,0
						mov		cf.Flags,CF_SCREENFONTS or CF_INITTOLOGFONTSTRUCT
						mov		cf.rgbColors,0
						mov		cf.lCustData,0
						mov		cf.lpfnHook,0
						mov		cf.lpTemplateName,0
						mov		cf.hInstance,0
						mov		cf.lpszStyle,0
						mov		cf.nFontType,0
						mov		cf.Alignment,0
						mov		cf.nSizeMin,0
						mov		cf.nSizeMax,0
						invoke ChooseFont,addr cf
						push	eax
						invoke ReleaseDC,hWin,hDC
						pop		eax
						.if eax
							.if !fSizeToFont
								mov		eax,cf.iPointSize
								mov		ecx,10
								xor		edx,edx
								div		ecx
								invoke DlgResize,esi,addr [esi].DLGHEAD.font,[esi].DLGHEAD.fontsize,addr lf.lfFaceName,eax
							.endif
							mov		al,lf.lfItalic
							mov		[esi].DLGHEAD.italic,al
							mov		al,lf.lfCharSet
							mov		[esi].DLGHEAD.charset,al
							mov		eax,lf.lfWeight
							mov		[esi].DLGHEAD.weight,ax
							mov		eax,cf.iPointSize
							mov		ecx,10
							xor		edx,edx
							div		ecx
							mov		[esi].DLGHEAD.fontsize,eax
							invoke strcpy,addr [esi].DLGHEAD.font,addr lf.lfFaceName
							invoke MakeDialog,esi,0
							invoke SetChanged,TRUE
						.endif
					.elseif eax==PRP_STR_MENU
						;Dialog Memu
						invoke SendMessage,hWin,LB_GETITEMRECT,nInx,addr rect
						mov		ecx,nPropHt
						add		rect.top,ecx
						mov		edx,nPropWt
						add		edx,1
						add		rect.left,edx
						mov		eax,rect.left
						sub		rect.right,eax
						invoke PropTxtLst,hCtl,lbid
						invoke SetTxtLstPos,addr rect
					.elseif eax==PRP_FUN_EXSTYLE
						;xExStyle
						mov		StyleEx,TRUE
						invoke GetCtrlMem,hCtl
						invoke DialogBoxParam,hInstance,IDD_DLGSTYLEMANA,hWin,addr StyleManaDialogProc,eax
					.elseif eax==PRP_FUN_STYLE
						;xStyle
						mov		StyleEx,FALSE
						invoke GetCtrlMem,hCtl
						invoke DialogBoxParam,hInstance,IDD_DLGSTYLEMANA,hWin,addr StyleManaDialogProc,eax
					.elseif eax==PRP_STR_IMAGE
						;Image
						invoke SendMessage,hWin,LB_GETITEMRECT,nInx,addr rect
						mov		ecx,nPropHt
						add		rect.top,ecx
						mov		edx,nPropWt
						add		edx,1
						add		rect.left,edx
						mov		eax,rect.left
						sub		rect.right,eax
						invoke PropTxtLst,hCtl,lbid
						invoke SetTxtLstPos,addr rect
					.elseif eax==PRP_STR_AVI
						;Avi
						invoke SendMessage,hWin,LB_GETITEMRECT,nInx,addr rect
						mov		ecx,nPropHt
						add		rect.top,ecx
						mov		edx,nPropWt
						add		edx,1
						add		rect.left,edx
						mov		eax,rect.left
						sub		rect.right,eax
						invoke PropTxtLst,hCtl,lbid
						invoke SetTxtLstPos,addr rect
					.elseif eax==PRP_STR_CAPMULTI
						;Multiline caption
						invoke SendMessage,hWin,LB_GETITEMRECT,nInx,addr rect
						mov		eax,nPropHt
						add		rect.top,eax
						mov		eax,nPropWt
						inc		eax
						add		rect.left,eax
						mov		eax,rect.left
						sub		rect.right,eax
						invoke GetCtrlMem,hCtl
						mov		esi,eax
						invoke ConvertCaption,addr lbtxtbuffer,addr (DIALOG ptr [esi]).caption
						invoke SetWindowText,hPrpEdtDlgCldMulti,addr lbtxtbuffer
						mov		eax,nPropHt
						shl		eax,3
						invoke SetWindowPos,hPrpEdtDlgCldMulti,HWND_TOP,rect.left,rect.top,rect.right,eax,0
						invoke ShowWindow,hPrpEdtDlgCldMulti,SW_SHOWNA
						invoke SetFocus,hPrpEdtDlgCldMulti
						;jmp		Ex
					.elseif eax==PRP_FUN_LANG
						;Language
						.if hCtl==-4 || hCtl==-5 || hCtl==-7 || hCtl==-8
							invoke DialogBoxParam,hInstance,IDD_LANGUAGE,hPrj,offset LanguageEditProc2,lpResLang
						.else
							invoke GetCtrlMem,hCtl
							mov		esi,eax
							sub		esi,sizeof DLGHEAD
							invoke DialogBoxParam,hInstance,IDD_LANGUAGE,hPrj,offset LanguageEditProc2,addr [esi].DLGHEAD.lang
							.if [esi+DLGHEAD].DIALOG.idname
								invoke lstrcpy,addr buffer,addr [esi+DLGHEAD].DIALOG.idname
							.else
								mov		edx,[esi+DLGHEAD].DIALOG.id
								invoke ResEdBinToDec,edx,addr buffer
							.endif
							invoke GetWindowLong,hDEd,DEWM_PROJECT
							mov		edx,eax
							invoke SetProjectItemName,edx,addr buffer
						.endif
						.if eax
							invoke PropertyList,hCtl
							.if hCtl==-4 || hCtl==-5 || hCtl==-7 || hCtl==-8
								invoke SendMessage,hRes,PRO_SETMODIFY,TRUE,0
							.else
								invoke SetChanged,TRUE
							.endif
						.endif
					.elseif eax==PRP_STR_FILE
						;File
						;Setup the ofn struct
						invoke RtlZeroMemory,addr ofn,sizeof ofn
						mov		ofn.lStructSize,sizeof ofn
						mov		eax,offset szFilterManifest
						mov		ofn.lpstrFilter,eax
						invoke strcpy,addr buffer,lpResFile
						push	hWin
						pop		ofn.hwndOwner
						push	hInstance
						pop		ofn.hInstance
						mov		ofn.lpstrInitialDir,offset szProjectPath
						lea		eax,buffer
						mov		ofn.lpstrFile,eax
						mov		ofn.nMaxFile,sizeof buffer
						mov		ofn.lpstrDefExt,NULL
						mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
						;Show the Open dialog
						invoke GetOpenFileName,addr ofn
						.if eax
							invoke RemovePath,addr buffer,addr szProjectPath
							invoke strcpy,lpResFile,eax
							invoke PropertyList,hCtl
							invoke SendMessage,hRes,PRO_SETMODIFY,TRUE,0
						.endif
					.else
						invoke SendMessage,hWin,LB_GETITEMRECT,nInx,addr rect
						mov		ecx,nPropHt
						add		rect.top,ecx
						mov		edx,nPropWt
						add		edx,1
						add		rect.left,edx
						mov		eax,rect.left
						sub		rect.right,eax
						invoke PropTxtLst,hCtl,lbid
						invoke SetTxtLstPos,addr rect
					.endif
				.endif
			.endif
		.endif
	.elseif eax==WM_CHAR
		.if wParam==VK_RETURN
			invoke SendMessage,hWin,WM_LBUTTONDBLCLK,0,0
		.elseif wParam==VK_TAB
			invoke SetFocus,hDEd
			invoke SendMessage,hDEd,WM_KEYDOWN,VK_TAB,0
		.endif
	.elseif eax==WM_DRAWITEM
		push	esi
		mov		esi,lParam
		invoke GetWindowLong,[esi].DRAWITEMSTRUCT.hwndItem,GWL_USERDATA
		.if eax<1000 || eax>65535 || eax==PRP_STR_MENU || eax==PRP_STR_IMAGE || eax==PRP_STR_AVI
			mov		edx,DFCS_SCROLLDOWN
			mov		eax,[esi].DRAWITEMSTRUCT.itemState
			and		eax,ODS_FOCUS or ODS_SELECTED
			.if eax==ODS_FOCUS or ODS_SELECTED
				mov		edx,DFCS_SCROLLDOWN or DFCS_PUSHED
			.endif
			invoke DrawFrameControl,[esi].DRAWITEMSTRUCT.hdc,addr [esi].DRAWITEMSTRUCT.rcItem,DFC_SCROLL,edx
		.else
			mov		edx,DFCS_BUTTONPUSH
			mov		eax,[esi].DRAWITEMSTRUCT.itemState
			and		eax,ODS_FOCUS or ODS_SELECTED
			.if eax==ODS_FOCUS or ODS_SELECTED
				mov		edx,DFCS_BUTTONPUSH or DFCS_PUSHED
			.endif
			invoke DrawFrameControl,[esi].DRAWITEMSTRUCT.hdc,addr [esi].DRAWITEMSTRUCT.rcItem,DFC_BUTTON,edx
			invoke SetBkMode,[esi].DRAWITEMSTRUCT.hdc,TRANSPARENT
			invoke DrawText,[esi].DRAWITEMSTRUCT.hdc,addr szDots,3,addr [esi].DRAWITEMSTRUCT.rcItem,DT_CENTER or DT_SINGLELINE
		.endif
		pop		esi
	.elseif eax==WM_KEYDOWN
		mov		edx,wParam
		mov		eax,lParam
		shr		eax,16
		and		eax,3FFh
		.if edx==2Eh && (eax==153h || eax==53h)
			invoke SendMessage,hWin,LB_GETCURSEL,0,0
			.if eax!=LB_ERR
				invoke SendMessage,hWin,LB_GETITEMDATA,eax,0
				.if eax==PRP_STR_FONT
					invoke GetWindowLong,hWin,GWL_USERDATA
					mov		hCtl,eax
					invoke GetCtrlMem,hCtl
					sub		eax,sizeof DLGHEAD
					mov		esi,eax
					mov		[esi].DLGHEAD.font,0
					mov		[esi].DLGHEAD.fontsize,0
				.endif
			.endif
		.endif
	.elseif eax==WM_VSCROLL
		invoke ShowWindow,hPrpBtnDlgCld,SW_HIDE
		invoke ShowWindow,hPrpLstDlgCld,SW_HIDE
		invoke ShowWindow,hPrpEdtDlgCld,SW_HIDE
	.elseif eax==WM_CTLCOLORLISTBOX
		invoke SetBkColor,wParam,color.back
		invoke SetTextColor,wParam,color.text
		mov		eax,hBrBack
		jmp		Ex
	.elseif eax==WM_CTLCOLOREDIT
		invoke SetBkColor,wParam,color.back
		invoke SetTextColor,wParam,color.text
		mov		eax,hBrBack
		jmp		Ex
	.endif
	invoke CallWindowProc,OldPrpLstDlgProc,hWin,uMsg,wParam,lParam
  Ex:
	assume esi:nothing
	ret

PrpLstDlgProc endp

PrpEdtDlgCldProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	nInx:DWORD
	LOCAL	buffer[512]:BYTE
	LOCAL	hCtl:HWND

	mov		eax,uMsg
	.if eax==WM_KILLFOCUS
		invoke PropEditUpdList,0
	.elseif eax==WM_CHAR
		.if wParam==VK_RETURN || wParam==VK_TAB
			invoke SendMessage,hPrpLstDlg,LB_GETCURSEL,0,0
			mov		nInx,eax
			invoke SetFocus,hDEd
			invoke SendMessage,hPrpLstDlg,LB_SETCURSEL,nInx,0
			invoke PropListSetPos
			.if wParam==VK_RETURN
				invoke SetFocus,hPrpLstDlg
			.else
				invoke SendMessage,hDEd,WM_KEYDOWN,VK_TAB,0
			.endif
			xor		eax,eax
			ret
		.endif
	.elseif eax==WM_KEYUP
		invoke SendMessage,hPrpLstDlg,LB_GETCURSEL,0,0
		mov		edx,eax
		invoke SendMessage,hPrpLstDlg,LB_GETTEXT,edx,addr buffer
		.if dword ptr buffer=='tpaC'
			push	esi
			invoke GetWindowText,hWin,addr buffer,sizeof buffer
			invoke ConvertCaption,addr buffer,addr buffer
			invoke GetWindowLong,hPrpLstDlg,GWL_USERDATA
			mov		hCtl,eax
			invoke SetWindowText,hCtl,addr buffer
			pop		esi
		.endif
	.endif
	invoke CallWindowProc,OldPrpEdtDlgCldProc,hWin,uMsg,wParam,lParam
	ret

PrpEdtDlgCldProc endp

PrpEdtDlgCldMultiProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	nInx:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[256]:BYTE
	LOCAL	hCtl:HWND

	mov		eax,uMsg
	.if eax==WM_KILLFOCUS
		invoke SendMessage,hPrpLstDlg,LB_GETCURSEL,0,0
		push	eax
		invoke PropEditUpdList,0
		pop		eax
		invoke SendMessage,hPrpLstDlg,LB_SETCURSEL,eax,0
		invoke PropListSetPos
		invoke SetFocus,hDEd
	.elseif eax==WM_CHAR
		.if wParam==VK_RETURN
			invoke SendMessage,hPrpLstDlg,LB_GETCURSEL,0,0
			mov		nInx,eax
			invoke SetFocus,hRes
			invoke SendMessage,hPrpLstDlg,LB_SETCURSEL,nInx,0
			invoke PropListSetPos
			invoke SetFocus,hPrpLstDlg
			xor		eax,eax
			ret
		.endif
	.elseif eax==WM_KEYUP
		invoke SendMessage,hPrpLstDlg,LB_GETCURSEL,0,0
		mov		edx,eax
		invoke SendMessage,hPrpLstDlg,LB_GETTEXT,edx,addr buffer
		.if dword ptr buffer=='tpaC'
			push	esi
			invoke GetWindowText,hWin,addr buffer,sizeof buffer
			invoke GetWindowLong,hPrpLstDlg,GWL_USERDATA
			mov		hCtl,eax
			invoke SetWindowText,hCtl,addr buffer
			invoke DeConvertCaption,addr buffer1,addr buffer
			invoke SetWindowText,hPrpEdtDlgCld,addr buffer1
			pop		esi
		.endif
	.endif
	invoke CallWindowProc,OldPrpEdtDlgCldMultiProc,hWin,uMsg,wParam,lParam
  Ex:
	ret

PrpEdtDlgCldMultiProc endp

PrpLstDlgCldProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	nInx:DWORD
	LOCAL	buffer[512]:BYTE

	mov		eax,uMsg
	.if eax==WM_LBUTTONUP
		invoke SendMessage,hWin,LB_GETCURSEL,0,0
		.if eax!=LB_ERR
			mov		nInx,eax
			invoke SendMessage,hPrpLstDlg,LB_GETCURSEL,0,0
			push	eax
			invoke SendMessage,hWin,LB_GETTEXT,nInx,addr buffer
			invoke SetWindowText,hPrpEdtDlgCld,addr buffer
			invoke SendMessage,hWin,LB_GETITEMDATA,nInx,0
			invoke PropEditUpdList,eax
			pop		nInx
			invoke SendMessage,hPrpLstDlg,LB_SETCURSEL,nInx,0
			invoke PropListSetPos
			invoke SetFocus,hDEd
		.endif
		xor		eax,eax
		ret
	.elseif uMsg==WM_CHAR
		.if wParam==13
			invoke SendMessage,hWin,WM_LBUTTONUP,0,0
			xor		eax,eax
			ret
		.endif
	.endif
	invoke CallWindowProc,OldPrpLstDlgCldProc,hWin,uMsg,wParam,lParam
	ret

PrpLstDlgCldProc endp

Do_Property proc hWin:HWND

	invoke CreateWindowEx,0,addr szComboBoxClass,NULL,WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or CBS_DROPDOWNLIST or WS_VSCROLL or CBS_SORT,0,0,0,0,hWin,0,hInstance,0
	mov		hPrpCboDlg,eax
	invoke SetWindowLong,hPrpCboDlg,GWL_WNDPROC,addr PrpCboDlgProc
	mov		OldPrpCboDlgProc,eax
	invoke CreateWindowEx,WS_EX_CLIENTEDGE,addr szListBoxClass,NULL,WS_CHILD or WS_VISIBLE or WS_VSCROLL or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or LBS_HASSTRINGS or LBS_NOINTEGRALHEIGHT or LBS_USETABSTOPS or LBS_SORT or LBS_OWNERDRAWFIXED or LBS_NOTIFY,0,0,0,0,hWin,0,hInstance,0
	mov		hPrpLstDlg,eax
	invoke SetWindowLong,hWin,0,eax
	invoke SetWindowLong,hPrpLstDlg,GWL_WNDPROC,addr PrpLstDlgProc
	mov		OldPrpLstDlgProc,eax
	invoke CreateWindowEx,0,addr szEditClass,NULL,WS_CHILD or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or ES_AUTOHSCROLL or ES_MULTILINE,0,0,0,0,hPrpLstDlg,0,hInstance,0
	mov		hPrpEdtDlgCld,eax
	invoke SetWindowLong,hPrpEdtDlgCld,GWL_WNDPROC,addr PrpEdtDlgCldProc
	mov		OldPrpEdtDlgCldProc,eax
	invoke CreateWindowEx,0,addr szEditClass,NULL,WS_CHILD or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or WS_BORDER or ES_AUTOHSCROLL or ES_AUTOVSCROLL or ES_MULTILINE or ES_WANTRETURN,0,0,0,0,hPrpLstDlg,0,hInstance,0
	mov		hPrpEdtDlgCldMulti,eax
	invoke SetWindowLong,hPrpEdtDlgCldMulti,GWL_WNDPROC,addr PrpEdtDlgCldMultiProc
	mov		OldPrpEdtDlgCldMultiProc,eax
	invoke CreateWindowEx,0,addr szListBoxClass,NULL,WS_CHILD or WS_VSCROLL or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or WS_BORDER or LBS_HASSTRINGS,0,0,0,0,hPrpLstDlg,0,hInstance,0
	mov		hPrpLstDlgCld,eax
	invoke SetWindowLong,hPrpLstDlgCld,GWL_WNDPROC,addr PrpLstDlgCldProc
	mov		OldPrpLstDlgCldProc,eax
	invoke CreateWindowEx,0,addr szButtonClass,NULL,WS_CHILD or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or BS_OWNERDRAW,0,0,0,0,hPrpLstDlg,1,hInstance,0
	mov		hPrpBtnDlgCld,eax
	ret

Do_Property endp

