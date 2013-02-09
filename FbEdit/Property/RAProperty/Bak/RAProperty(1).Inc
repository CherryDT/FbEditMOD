InstallRAProperty		PROTO :DWORD,:DWORD
UnInstallRAProperty		PROTO

;Messages
PRM_SELECTPROPERTY			equ WM_USER+0		;wParam=dwType, lParam=0
PRM_ADDPROPERTYTYPE			equ WM_USER+1		;wParam=dwType, lParam=lpszType
PRM_ADDPROPERTYFILE			equ WM_USER+2		;wParam=dwType, lParam=lpszFile
PRM_SETGENDEF				equ WM_USER+3		;wParam=0, lParam=lpGENDEF
PRM_ADDIGNORE				equ WM_USER+4		;wParam=IgnoreType, lParam=lpszWord
PRM_ADDDEFTYPE				equ WM_USER+5		;wParam=0, lParam=lpTYPEDEF
PRM_PARSEFILE				equ WM_USER+6		;wParam=nOwner, lParam=lpFileData
PRM_SETCHARTAB				equ WM_USER+7		;wParam=0, lParam=lpCharTab
PRM_DELPROPERTY				equ WM_USER+8		;wParam=nOwner, lParam=0
PRM_REFRESHLIST				equ WM_USER+9		;wParam=0, lParam=0
PRM_SELOWNER				equ WM_USER+10		;wParam=nOwner, lParam=0      (invokes PRM_REFRESHLIST)
PRM_GETSELBUTTON			equ WM_USER+11		;wParam=0, lParam=0
PRM_SETSELBUTTON			equ WM_USER+12		;wParam=nButton, lParam=0
PRM_FINDFIRST				equ WM_USER+13		;wParam=lpszTypes, lParam=lpszText
PRM_FINDNEXT				equ WM_USER+14		;wParam=0, lParam=0
PRM_FINDGETTYPE				equ WM_USER+15		;wParam=0, lParam=0
PRM_GETWORD					equ WM_USER+16		;wParam=pos, lParam=lpszLine
PRM_GETTOOLTIP				equ WM_USER+17		;wParam=TRUE/FALSE (No case), lParam=lpTOOLTIP
PRM_SETBACKCOLOR			equ WM_USER+18		;wParam=0, lParam=nColor
PRM_GETBACKCOLOR			equ WM_USER+19		;wParam=0, lParam=0
PRM_SETTEXTCOLOR			equ WM_USER+20		;wParam=0, lParam=nColor
PRM_GETTEXTCOLOR			equ WM_USER+21		;wParam=0, lParam=0
PRM_ISINPROC				equ WM_USER+22		;wParam=0, lParam=lpISINPROC
PRM_GETSTRUCTWORD			equ WM_USER+23		;wParam=pos, lParam=lpszLine
PRM_FINDITEMDATATYPE		equ WM_USER+24		;wParam=lpszItemName, lParam=lpszItemList
PRM_MEMSEARCH				equ WM_USER+25		;wParam=0, lParam=lpMEMSEARCH
PRM_FINDGETOWNER			equ WM_USER+26		;wParam=0, lParam=0
PRM_FINDGETLINE				equ WM_USER+27		;wParam=0, lParam=0
PRM_ISINWITHBLOCK			equ WM_USER+28		;wParam=nOwner, lParam=nLine
PRM_FINDGETENDLINE			equ WM_USER+29		;wParam=0, lParam=0
PRM_ADDISWORD				equ WM_USER+30		;wParam=IsWordType, lParam=lpszWord
PRM_SETOPRCOLOR				equ WM_USER+31		;wParam=0, lParam=nColor
PRM_GETOPRCOLOR				equ WM_USER+32		;wParam=0, lParam=0
PRM_CLEARWORDLIST			equ WM_USER+33		;wParam=0, lParam=0
PRM_GETSTRUCTSTART			equ WM_USER+34		;wParam=pos, lParam=lpszLine
PRM_GETCURSEL				equ WM_USER+35		;wParam=0, lParam=0
PRM_GETSELTEXT				equ WM_USER+36		;wParam=0, lParam=lpBuff
PRM_GETSORTEDLIST			equ WM_USER+37		;wParam=lpTypes, lParam=lpCount
PRM_FINDINSORTEDLIST		equ WM_USER+38		;wParam=nCount, lParam=lpMEMSEARCH
PRM_ISTOOLTIPMESSAGE		equ WM_USER+39		;wParam=lpMESSAGE, lParam=lpTOOLTIP
PRM_SETLANGUAGE				equ WM_USER+40		;wParam=nLanguage, lParam=0
PRM_SETTOOLTIP				equ WM_USER+41		;wParam=n (1-5), lParam=lpszText
PRM_PREPARSE				equ WM_USER+42		;wParam=fKeepStrings, lParam=lpFileData
PRM_ISINLIST				equ WM_USER+43		;wParam=lpWord, lParam=lpList
PRM_ADDPROPERTYWORD			equ WM_USER+44		;wParam=dwType, lParam=lpszWord
PRM_ADDPROPERTYLIST			equ WM_USER+45		;wParam=dwType, lParam=lpszListOfWords
PRM_COMPACTLIST				equ WM_USER+46		;wParam=fProject, lParam=0
PRM_RESET					equ WM_USER+47		;wParam=0, lParam=0
PRM_GETSELTYP				equ WM_USER+48		;wParam=0, lParam=0
PRM_ADDPROPERTYITEM			equ WM_USER+49		;wParam=0, lParam=lpPROPERTYITEM

;Languages
nMASM						equ 1
nTASM						equ 2
nFASM						equ 3
nGOASM						equ 4
nNASM						equ 5
nHLA						equ 6
nCPP						equ 7
nFREEBASIC					equ 8
nFREEPASCAL					equ 9
nSOLASM						equ 10
nASEMW						equ 11
nOTHER						equ 99

;Styles
PRSTYLE_FLATTOOLBAR			equ 1
PRSTYLE_DIVIDERLINE			equ 2
PRSTYLE_PROJECT				equ 4

DEFGEN struct
	szCmntBlockSt	db 16 dup(?)
	szCmntBlockEn	db 16 dup(?)
	szCmntChar		db 16 dup(?)
	szString		db 16 dup(?)
	szLineCont		db 16 dup(?)
DEFGEN ends

;Ignore types
IGNORE_LINEFIRSTWORD		equ 1
IGNORE_LINESECONDWORD		equ 2
IGNORE_FIRSTWORD			equ 3
IGNORE_SECONDWORD			equ 4
IGNORE_FIRSTWORDTWOWORDS	equ 5
IGNORE_SECONDWORDTWOWORDS	equ 6
IGNORE_PROCPARAM			equ 7
IGNORE_DATATYPEINIT			equ 8
IGNORE_STRUCTITEMFIRSTWORD	equ 9
IGNORE_STRUCTITEMSECONDWORD	equ 10
IGNORE_STRUCTTHIRDWORD		equ 11
IGNORE_STRUCTITEMINIT		equ 12
IGNORE_PTR					equ 13
IGNORE_STRUCTLINEFIRSTWORD	equ 14
IGNORE_DATATYPE				equ 15
IGNORE_CONSTANT				equ 16

;IsWord types
ISWORD_STRUCTCLASS			equ 1

;Parse types
TYPE_NAMEFIRST				equ 1
TYPE_OPTNAMEFIRST			equ 2
TYPE_NAMESECOND				equ 3
TYPE_OPTNAMESECOND			equ 4
TYPE_TWOWORDS				equ 5
TYPE_ONEWORD				equ 6

DEFTYPE_PROC				equ 1
DEFTYPE_ENDPROC				equ 2
DEFTYPE_DATA				equ 3
DEFTYPE_ARG					equ 4
DEFTYPE_CONST				equ 5
DEFTYPE_ENDCONST			equ 6
DEFTYPE_STRUCT				equ 7
DEFTYPE_ENDSTRUCT			equ 8
DEFTYPE_TYPE				equ 9
DEFTYPE_ENDTYPE				equ 10
DEFTYPE_LOCALDATA			equ 11
DEFTYPE_NAMESPACE			equ 12
DEFTYPE_ENDNAMESPACE		equ 13
DEFTYPE_ENUM				equ 14
DEFTYPE_ENDENUM				equ 15
DEFTYPE_WITHBLOCK			equ 16
DEFTYPE_ENDWITHBLOCK		equ 17
DEFTYPE_MACRO				equ 18
DEFTYPE_ENDMACRO			equ 19
DEFTYPE_PROPERTY			equ 20
DEFTYPE_ENDPROPERTY			equ 21
DEFTYPE_OPERATOR			equ 22
DEFTYPE_ENDOPERATOR			equ 23
DEFTYPE_CONSTRUCTOR			equ 24
DEFTYPE_ENDCONSTRUCTOR		equ 25
DEFTYPE_DESTRUCTOR			equ 26
DEFTYPE_ENDDESTRUCTOR		equ 27
DEFTYPE_LABEL				equ 28
DEFTYPE_FUNCTION			equ 29
DEFTYPE_ENDFUNCTION			equ 30
DEFTYPE_OBJECT				equ 31
DEFTYPE_ENDOBJECT			equ 32
DEFTYPE_METHOD				equ 33
DEFTYPE_ENDMETHOD			equ 34
DEFTYPE_IGNORE				equ 35
DEFTYPE_ENDIGNORE			equ 36

DEFTYPE struct
	nType			db ?
	nDefType		db ?
	Def				db ?
	len				db ?
	szWord			db 32 dup(?)
DEFTYPE ends

;Character table types
CT_NONE						equ 0
CT_CHAR						equ 1
CT_OPER						equ 2
CT_HICHAR					equ 3
CT_CMNTCHAR					equ 4
CT_STRING					equ 5
CT_CMNTDBLCHAR				equ 6
CT_CMNTINITCHAR				equ 7

RAPNOTIFY struct
	nmhdr			NMHDR <?>
	nid				dd ?
	nline			dd ?
RAPNOTIFY ends

ISINPROC struct
	nLine			dd ?
	nOwner			dd ?
	lpszType		dd ?
ISINPROC ends

TT_NOMATCHCASE				equ 1
TT_PARANTESES				equ 2

OVERRIDE struct
	lpszParam		dd ?
	lpszRetType		dd ?
OVERRIDE ends

TOOLTIP struct
	lpszType		dd ?
	lpszLine		dd ?
	lpszApi			dd ?
	nPos			dd ?
	novr			dd ?
	ovr				OVERRIDE 32 dup(<>)
TOOLTIP ends

MSGAPI struct
	nPos			dd ?
	lpszApi			dd ?
MSGAPI ends

MESSAGE struct
	szType			db 4 dup(?)
	lpMsgApi		MSGAPI 32 dup(<>)
MESSAGE ends

MEMSEARCH struct
	lpMem			dd ?
	lpFind			dd ?
	lpCharTab		dd ?
	fr				dd ?
MEMSEARCH ends

PROPERTYITEM struct
	nType			dd ?				;Type 1 to 255
	nOwner			dd ?				;Project file ID
	nLine			dd ?				;Line number
	nEndLine		dd ?				;Line number
	lpszStr			dd ?				;Pointer to one or more zero terminated strings
	nParts			dd ?				;Number of zero terminated strings
PROPERTYITEM ends

.const

;Class
szClassName					db 'RAPROPERTY',0
