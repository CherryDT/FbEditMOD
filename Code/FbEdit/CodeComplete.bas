

#Include Once "windows.bi"

#Include Once "Inc\RAEdit.bi"
#Include Once "Inc\RAProperty.bi"
#Include Once "Inc\RACodeComplete.bi"

#Include Once "Inc\Addins.bi"
#Include Once "Inc\CoTxEd.bi"
#Include Once "Inc\EditorOpt.bi"
#Include Once "Inc\FbEdit.bi"
#Include Once "Inc\Project.bi"
#Include Once "Inc\SpecHandling.bi"
#Include Once "Inc\TabTool.bi"
#Include Once "Inc\ZStringHandling.bi"

#Include Once "Inc\CodeComplete.bi"
#Include Once "Inc\showvars.bi"


Const szCode                     As String = "Functions"
Const szConst                    As String = "Constants"
Const szData                     As String = "Variables"
Const szStruct                   As String = "UDTs"
Const szEnum                     As String = "Enums"
Const szNamespace                As String = "Namespaces"
Const szMacro                    As String = "Macros"
Const szConstructor              As String = "Constructors"
Const szDestructor               As String = "Destructors"
Const szProperty                 As String = "Properties"
Const szOperator                 As String = "Operators"

Dim Shared ftypelist             As Boolean
Dim Shared fconstlist            As Boolean
Dim Shared fstructlist           As Boolean
Dim Shared fmessagelist          As Boolean
Dim Shared flocallist            As Boolean
Dim Shared fincludelist          As Boolean
Dim Shared fincliblist           As Boolean
Dim Shared fenumlist             As Boolean
Dim Shared sEditFileName         As ZString * MAX_PATH 
Dim Shared ccpos                 As ZString Ptr
Dim Shared ccstring              As ZString * 65536

Dim Shared defgen                As DEFGEN  = (!"/'", !"'/", "'", !"\"", "_")                       ' MOD:   Dim Shared defgen As DEFGEN = ("/'" & szNULL,"'/" & szNULL,"'" & szNULL,"""" & szNULL,"_" & szNULL)
Dim Shared deftypesub            As DEFTYPE = (TYPE_NAMESECOND   , DEFTYPE_PROC          , Asc ("p"), 3, "sub")
Dim Shared deftypeendsub         As DEFTYPE = (TYPE_TWOWORDS     , DEFTYPE_ENDPROC       , Asc ("p"), 3, "end" & Chr(3) & "sub")
Dim Shared deftypefun            As DEFTYPE = (TYPE_NAMESECOND   , DEFTYPE_FUNCTION      , Asc ("p"), 8, "function")
Dim Shared deftypeendfun         As DEFTYPE = (TYPE_TWOWORDS     , DEFTYPE_ENDFUNCTION   , Asc ("p"), 3, "end" & Chr(8) & "function")
Dim Shared deftypedata           As DEFTYPE = (TYPE_NAMESECOND   , DEFTYPE_DATA          , Asc ("d"), 3, "dim")
Dim Shared deftypecommon         As DEFTYPE = (TYPE_NAMESECOND   , DEFTYPE_DATA          , Asc ("d"), 6, "common")
Dim Shared deftypestatic         As DEFTYPE = (TYPE_NAMESECOND   , DEFTYPE_DATA          , Asc ("d"), 6, "static")
Dim Shared deftypevar            As DEFTYPE = (TYPE_NAMESECOND   , DEFTYPE_DATA          , Asc ("d"), 3, "var")
Dim Shared deftypeconst          As DEFTYPE = (TYPE_NAMESECOND   , DEFTYPE_CONST         , Asc ("c"), 7, "#define")
Dim Shared deftypeconst2         As DEFTYPE = (TYPE_NAMESECOND   , DEFTYPE_CONST         , Asc ("c"), 5, "const")
Dim Shared deftypestruct         As DEFTYPE = (TYPE_OPTNAMESECOND, DEFTYPE_STRUCT        , Asc ("s"), 4, "type")
Dim Shared deftypeendstruct      As DEFTYPE = (TYPE_TWOWORDS     , DEFTYPE_ENDSTRUCT     , Asc ("s"), 3, "end" & Chr(4) & "type")
Dim Shared deftypeunion          As DEFTYPE = (TYPE_OPTNAMESECOND, DEFTYPE_STRUCT        , Asc ("s"), 5, "union")
Dim Shared deftypeendunion       As DEFTYPE = (TYPE_TWOWORDS     , DEFTYPE_ENDSTRUCT     , Asc ("s"), 3, "end" & Chr(5) & "union")
Dim Shared deftypeenum           As DEFTYPE = (TYPE_NAMESECOND   , DEFTYPE_ENUM          , Asc ("e"), 4, "enum")
Dim Shared deftypeendenum        As DEFTYPE = (TYPE_TWOWORDS     , DEFTYPE_ENDENUM       , Asc ("e"), 3, "end" & Chr(4) & "enum")
Dim Shared deftypenamespace      As DEFTYPE = (TYPE_NAMESECOND   , DEFTYPE_NAMESPACE     , Asc ("n"), 9, "namespace")
Dim Shared deftypeendnamespace   As DEFTYPE = (TYPE_TWOWORDS     , DEFTYPE_ENDNAMESPACE  , Asc ("n"), 3, "end" & Chr(9) & "namespace")
Dim Shared deftypewithblock      As DEFTYPE = (TYPE_NAMESECOND   , DEFTYPE_WITHBLOCK     , Asc ("w"), 4, "with")
Dim Shared deftypeendwithblock   As DEFTYPE = (TYPE_TWOWORDS     , DEFTYPE_ENDWITHBLOCK  , Asc ("w"), 3, "end" & Chr(4) & "with")
Dim Shared deftypemacro          As DEFTYPE = (TYPE_NAMESECOND   , DEFTYPE_MACRO         , Asc ("m"), 6, "#macro")
Dim Shared deftypeendmacro       As DEFTYPE = (TYPE_ONEWORD      , DEFTYPE_ENDMACRO      , Asc ("m"), 9, "#endmacro")
Dim Shared deftypeconstructor    As DEFTYPE = (TYPE_NAMESECOND   , DEFTYPE_CONSTRUCTOR   , Asc ("x"), 11,"constructor")
Dim Shared deftypeendconstructor As DEFTYPE = (TYPE_TWOWORDS     , DEFTYPE_ENDCONSTRUCTOR, Asc ("x"), 3, "end" & Chr(11) & "constructor")
Dim Shared deftypedestructor     As DEFTYPE = (TYPE_NAMESECOND   , DEFTYPE_DESTRUCTOR    , Asc ("y"), 10,"destructor")
Dim Shared deftypeenddestructor  As DEFTYPE = (TYPE_TWOWORDS     , DEFTYPE_ENDDESTRUCTOR , Asc ("y"), 3, "end" & Chr(10) & "destructor")
Dim Shared deftypeproperty       As DEFTYPE = (TYPE_NAMESECOND   , DEFTYPE_PROPERTY      , Asc ("z"), 8, "property")
Dim Shared deftypeendproperty    As DEFTYPE = (TYPE_TWOWORDS     , DEFTYPE_ENDPROPERTY   , Asc ("z"), 3, "end" & Chr(8) & "property")
Dim Shared deftypeoperator       As DEFTYPE = (TYPE_OPTNAMESECOND, DEFTYPE_OPERATOR      , Asc ("o"), 8, "operator")
Dim Shared deftypeendoperator    As DEFTYPE = (TYPE_TWOWORDS     , DEFTYPE_ENDOPERATOR   , Asc ("o"), 3, "end" & Chr(8) & "operator")
Dim Shared deftypeignore         As DEFTYPE = (TYPE_OPTNAMESECOND, DEFTYPE_IGNORE        , Asc ("i"), 3, "asm")
Dim Shared deftypeendignore      As DEFTYPE = (TYPE_TWOWORDS     , DEFTYPE_ENDIGNORE     , Asc ("i"), 3, "end" & Chr(3) & "asm")



Sub SetupProperty()
    
	SendMessage(ah.hpr,PRM_SETCHARTAB,0,Cast(LPARAM,ad.lpCharTab))
	SendMessage(ah.hpr,PRM_SETGENDEF,0,Cast(Integer,@defgen))
	' Lines to skip
	SendMessage(ah.hpr,PRM_ADDIGNORE,IGNORE_LINEFIRSTWORD,Cast(Integer,StrPtr("declare")))
	' Words to skip
	SendMessage(ah.hpr,PRM_ADDIGNORE,IGNORE_FIRSTWORD,Cast(Integer,StrPtr("private")))
	SendMessage(ah.hpr,PRM_ADDIGNORE,IGNORE_FIRSTWORD,Cast(Integer,StrPtr("public")))
	SendMessage(ah.hpr,PRM_ADDIGNORE,IGNORE_SECONDWORD,Cast(Integer,StrPtr("shared")))
	SendMessage(ah.hpr,PRM_ADDIGNORE,IGNORE_DATATYPEINIT,Cast(Integer,StrPtr("as")))
	SendMessage(ah.hpr,PRM_ADDIGNORE,IGNORE_PROCPARAM,Cast(Integer,StrPtr("byval")))
	SendMessage(ah.hpr,PRM_ADDIGNORE,IGNORE_PROCPARAM,Cast(Integer,StrPtr("byref")))
	SendMessage(ah.hpr,PRM_ADDIGNORE,IGNORE_PROCPARAM,Cast(Integer,StrPtr("alias")))
	SendMessage(ah.hpr,PRM_ADDIGNORE,IGNORE_PROCPARAM,Cast(Integer,StrPtr("cdecl")))
	SendMessage(ah.hpr,PRM_ADDIGNORE,IGNORE_PROCPARAM,Cast(Integer,StrPtr("stdcall")))
	SendMessage(ah.hpr,PRM_ADDIGNORE,IGNORE_PROCPARAM,Cast(Integer,StrPtr("overload")))
	SendMessage(ah.hpr,PRM_ADDIGNORE,IGNORE_STRUCTITEMFIRSTWORD,Cast(Integer,StrPtr("as")))
	SendMessage(ah.hpr,PRM_ADDIGNORE,IGNORE_STRUCTITEMSECONDWORD,Cast(Integer,StrPtr("as")))
	SendMessage(ah.hpr,PRM_ADDIGNORE,IGNORE_STRUCTTHIRDWORD,Cast(Integer,StrPtr("as")))
	SendMessage(ah.hpr,PRM_ADDIGNORE,IGNORE_STRUCTITEMINIT,Cast(Integer,StrPtr("declare")))
	SendMessage(ah.hpr,PRM_ADDIGNORE,IGNORE_STRUCTITEMINIT,Cast(Integer,StrPtr("static")))
	SendMessage(ah.hpr,PRM_ADDIGNORE,IGNORE_PTR,Cast(Integer,StrPtr("ptr")))
	SendMessage(ah.hpr,PRM_ADDIGNORE,IGNORE_DATATYPE,Cast(Integer,StrPtr("const")))
	SendMessage(ah.hpr,PRM_ADDIGNORE,IGNORE_STRUCTLINEFIRSTWORD,Cast(Integer,StrPtr("private")))
	SendMessage(ah.hpr,PRM_ADDIGNORE,IGNORE_STRUCTLINEFIRSTWORD,Cast(Integer,StrPtr("public")))
	
    'SendMessage(ah.hpr,PRM_ADDIGNORE,IGNORE_STRUCTLINEFIRSTWORD,Cast(Integer,StrPtr("const")))

	
	
	
	' Property types
	SendMessage(ah.hpr,PRM_ADDPROPERTYTYPE,Asc("p")+256,Cast(Integer,StrPtr(szCode)))
	SendMessage(ah.hpr,PRM_ADDPROPERTYTYPE,Asc("c"),Cast(Integer,StrPtr(szConst)))
	SendMessage(ah.hpr,PRM_ADDPROPERTYTYPE,Asc("d")+512,Cast(Integer,StrPtr(szData)))
	SendMessage(ah.hpr,PRM_ADDPROPERTYTYPE,Asc("s"),Cast(Integer,StrPtr(szStruct)))
	SendMessage(ah.hpr,PRM_ADDPROPERTYTYPE,Asc("e"),Cast(Integer,StrPtr(szEnum)))
	SendMessage(ah.hpr,PRM_ADDPROPERTYTYPE,Asc("n"),Cast(Integer,StrPtr(szNamespace)))
	SendMessage(ah.hpr,PRM_ADDPROPERTYTYPE,Asc("m"),Cast(Integer,StrPtr(szMacro)))
	SendMessage(ah.hpr,PRM_ADDPROPERTYTYPE,Asc("x")+256,Cast(Integer,StrPtr(szConstructor)))
	SendMessage(ah.hpr,PRM_ADDPROPERTYTYPE,Asc("y")+256,Cast(Integer,StrPtr(szDestructor)))
	SendMessage(ah.hpr,PRM_ADDPROPERTYTYPE,Asc("z")+256,Cast(Integer,StrPtr(szProperty)))
	SendMessage(ah.hpr,PRM_ADDPROPERTYTYPE,Asc("o")+256,Cast(Integer,StrPtr(szOperator)))
	
	'TODO
	
	'SendMessage(ah.hpr,PRM_ADDPROPERTYTYPE,Asc("t")+256,Cast(Integer,@"TEST"))
     
    
	' Parse defs
	SendMessage(ah.hpr,PRM_ADDDEFTYPE,0,Cast(Integer,@deftypesub))
	SendMessage(ah.hpr,PRM_ADDDEFTYPE,0,Cast(Integer,@deftypeendsub))
	SendMessage(ah.hpr,PRM_ADDDEFTYPE,0,Cast(Integer,@deftypefun))
	SendMessage(ah.hpr,PRM_ADDDEFTYPE,0,Cast(Integer,@deftypeendfun))
	SendMessage(ah.hpr,PRM_ADDDEFTYPE,0,Cast(Integer,@deftypedata))
	SendMessage(ah.hpr,PRM_ADDDEFTYPE,0,Cast(Integer,@deftypecommon))
	SendMessage(ah.hpr,PRM_ADDDEFTYPE,0,Cast(Integer,@deftypestatic))
	SendMessage(ah.hpr,PRM_ADDDEFTYPE,0,Cast(Integer,@deftypevar))
	SendMessage(ah.hpr,PRM_ADDDEFTYPE,0,Cast(Integer,@deftypeconst))
	SendMessage(ah.hpr,PRM_ADDDEFTYPE,0,Cast(Integer,@deftypeconst2))
	SendMessage(ah.hpr,PRM_ADDDEFTYPE,0,Cast(Integer,@deftypestruct))
	SendMessage(ah.hpr,PRM_ADDDEFTYPE,0,Cast(Integer,@deftypeendstruct))
	SendMessage(ah.hpr,PRM_ADDDEFTYPE,0,Cast(Integer,@deftypeunion))
	SendMessage(ah.hpr,PRM_ADDDEFTYPE,0,Cast(Integer,@deftypeendunion))
	SendMessage(ah.hpr,PRM_ADDDEFTYPE,0,Cast(Integer,@deftypeenum))
	SendMessage(ah.hpr,PRM_ADDDEFTYPE,0,Cast(Integer,@deftypeendenum))
	SendMessage(ah.hpr,PRM_ADDDEFTYPE,0,Cast(Integer,@deftypenamespace))
	SendMessage(ah.hpr,PRM_ADDDEFTYPE,0,Cast(Integer,@deftypeendnamespace))
	SendMessage(ah.hpr,PRM_ADDDEFTYPE,0,Cast(Integer,@deftypewithblock))
	SendMessage(ah.hpr,PRM_ADDDEFTYPE,0,Cast(Integer,@deftypeendwithblock))
	SendMessage(ah.hpr,PRM_ADDDEFTYPE,0,Cast(Integer,@deftypemacro))
	SendMessage(ah.hpr,PRM_ADDDEFTYPE,0,Cast(Integer,@deftypeendmacro))
	SendMessage(ah.hpr,PRM_ADDDEFTYPE,0,Cast(Integer,@deftypeconstructor))
	SendMessage(ah.hpr,PRM_ADDDEFTYPE,0,Cast(Integer,@deftypeendconstructor))
	SendMessage(ah.hpr,PRM_ADDDEFTYPE,0,Cast(Integer,@deftypedestructor))
	SendMessage(ah.hpr,PRM_ADDDEFTYPE,0,Cast(Integer,@deftypeenddestructor))
	SendMessage(ah.hpr,PRM_ADDDEFTYPE,0,Cast(Integer,@deftypeproperty))
	SendMessage(ah.hpr,PRM_ADDDEFTYPE,0,Cast(Integer,@deftypeendproperty))
	SendMessage(ah.hpr,PRM_ADDDEFTYPE,0,Cast(Integer,@deftypeoperator))
	SendMessage(ah.hpr,PRM_ADDDEFTYPE,0,Cast(Integer,@deftypeendoperator))
	SendMessage(ah.hpr,PRM_ADDDEFTYPE,0,Cast(Integer,@deftypeignore))
	SendMessage(ah.hpr,PRM_ADDDEFTYPE,0,Cast(Integer,@deftypeendignore))

	' Set cbo selection
	SendMessage(ah.hpr,PRM_SELECTPROPERTY,Asc("p")+256,0)
	' Set button 'All Files Button'
	SendMessage(ah.hpr,PRM_SETSELBUTTON,2,0)
End Sub

Sub HideCCLists()

	ShowWindow(ah.hcc,SW_HIDE)
	ftypelist=FALSE
	fconstlist=FALSE
	fstructlist=FALSE
	fmessagelist=FALSE
	flocallist=FALSE
	fincludelist=FALSE
	fincliblist=FALSE
	fenumlist=FALSE

End Sub

Sub MoveList()
    
	Dim CCRect     As RECT    = Any
	Dim EDRect     As RECT    = Any 
    Dim CaretPos   As Point   = Any
    Dim Hreq       As Integer = Any 
    Dim ItemRect   As RECT    = Any
    Dim ItemCount  As Long    = Any 
    Dim Boarder    As Integer = Any 
    Dim CellHeight As Long    = Any            ' Editor: Textheight + Extra Linespacing
    Dim hEDSplitt  As HWND    = Any 
    
    #Define ItemHeight    ItemRect.bottom
    #Define EDHeight      EDRect.bottom

    hEDSplitt  = GetFocus ()
    Boarder    = 2 * GetSystemMetrics (SM_CYFIXEDFRAME)
    CellHeight = SendMessage (ah.hred, REM_GETCELLHEIGHT, 0, 0)
    
    GetClientRect hEDSplitt, @EDRect
	GetCaretPos @CaretPos         

	If CaretPos.y < -CellHeight OrElse CaretPos.y > EDHeight Then
	    Exit Sub 
	EndIf

	SendMessage ah.hcc, CCM_GETITEMRECT, 0, Cast (LPARAM, @ItemRECT)
	ItemCount = SendMessage (ah.hcc, CCM_GETCOUNT, 0, 0)
	Hreq      = ItemCount * ItemHeight + Boarder
	
	If EDHeight - (CaretPos.y + CellHeight) > Hreq Then       ' enough space below: SET BELOW
	    CCRect.top = CaretPos.y + CellHeight
        CCRect.bottom = Hreq
	Else                                                      ' not enough space below
	    If CaretPos.y > EDHeight \ 2 Then     	              ' space above is larger
            If CaretPos.y > Hreq Then                         ' enough space above: SET ABOVE
	            CCRect.top = CaretPos.y - Hreq 
                CCRect.bottom = Hreq 
            Else                                              ' not enough space above: FIT ABOVE
	            Hreq = (CaretPos.y \ ItemHeight) * ItemHeight + Boarder
                CCRect.top = CaretPos.y - Hreq
                CCRect.bottom = Hreq
	        EndIf
	    Else	                                              ' space above is smaller: FIT BELOW
            CCRect.top = CaretPos.y + CellHeight
	        CCRect.bottom = ((EDHeight - CaretPos.y - CellHeight) \ ItemHeight) * ItemHeight + Boarder
	    EndIf
	EndIf

	CCRect.left = CaretPos.x 
	If edtopt.autowidth Then
		CCRect.right = SendMessage (ah.hcc, CCM_GETMAXWIDTH, 0, 0) + Boarder + 5   ' 5 = some space behind the last char
	    If CCRect.right < 100 Then
			CCRect.right = 100
		EndIf
	Else
		CCRect.right = wpos.ptcclist.x
	EndIf
	
    If ItemCount Then
	    ClientToScreen hEDSplitt, Cast (Point Ptr, @CCRect)
	    ShowWindow ah.htt, SW_HIDE
	    SetWindowPos ah.hcc, HWND_TOP, CCRect.left, CCRect.top, CCRect.right, CCRect.bottom, SWP_NOACTIVATE Or SWP_SHOWWINDOW
    Else
        ShowWindow ah.hcc, SW_HIDE
    EndIf 

    #Undef ItemHeight
    #Undef EDHeight

	'Dim pt As Point
	'Dim rect As RECT
	'Dim rect1 As RECT
    '
	'GetCaretPos(@pt)
	'GetWindowRect(ah.hcc,@rect1)
	'SendMessage(ah.hred,EM_GETRECT,0,Cast(Integer,@rect))
	'ClientToScreen(ah.hred,Cast(Point Ptr,@rect))
	'rect.top=rect.top+pt.y+18
	'If rect.top+rect1.bottom-rect1.top+8>GetSystemMetrics(SM_CYMAXIMIZED) Then
	'	rect.top=rect.top-rect1.bottom+rect1.top-22
	'EndIf
	'If edtopt.autowidth Then
	'	rect.right=SendMessage(ah.hcc,CCM_GETMAXWIDTH,0,0)+8
	'	If rect.right<100 Then
	'		rect.right=100
	'	EndIf
	'Else
	'	rect.right=rect1.right-rect1.left
	'EndIf
	'rect.bottom=wpos.ptcclist.y
	'SetWindowPos(ah.hcc,HWND_TOP,rect.left+pt.x+5,rect.top,rect.right,rect.bottom,SWP_NOACTIVATE Or SWP_SHOWWINDOW)
	'ShowWindow(ah.htt,SW_HIDE)

End Sub

Function FindExact(ByVal lpTypes As ZString Ptr,ByVal lpFind As ZString Ptr,ByVal fMatchCase As Boolean) As ZString Ptr
	Dim lret As ZString Ptr
   
	lret=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_FINDFIRST,Cast(Integer,lpTypes),Cast(Integer,lpFind)))
	While lret
		If fMatchCase Then
			If lstrcmp(lret,lpFind)=0 Then
				Return lret
			EndIf
		Else
			If lstrcmpi(lret,lpFind)=0 Then
				Return lret
			EndIf
		EndIf
		lret=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_FINDNEXT,Cast(Integer,lpTypes),Cast(Integer,lpFind)))
	Wend
	Return 0

End Function

Sub GetItems(ByVal ntype As Integer)
	Dim x As Integer
	Dim sItem As ZString*256
	Dim lps As ZString Ptr

	lps=@s
	x=1
	Do While x
		x=InStr(s,",")
		If x Then
			lstrcpyn(ccpos,@s,x)
			s=*(lps+x)
		Else
			lstrcpy(ccpos,@s)
		EndIf
		If IsZStrNotEmpty (*ccpos) Then
			lstrcpyn(@sItem,ccpos,Len(buff)+1)
			If lstrcmpi(@sItem,@buff)=0 Then
				'TODO
				If InStr(UCase(*ccpos),":SUB") Or InStr(UCase(*ccpos),":FUNCTION") Then
					SendMessage(ah.hcc,CCM_ADDITEM,1,Cast(Integer,ccpos))
				ElseIf InStr(UCase(*ccpos),":CONSTRUCTOR")=0 And InStr(UCase(*ccpos),":DESTRUCTOR")=0 Then
					SendMessage(ah.hcc,CCM_ADDITEM,ntype,Cast(Integer,ccpos))
				EndIf
				ccpos=ccpos+Len(*ccpos)+1
			EndIf
		EndIf
	Loop 

End Sub

Sub UpdateList(ByVal lpProc As ZString Ptr)
	Dim lret As Integer
	Dim chrg As CHARRANGE
	Dim ntype As Integer
    
	ccpos=@ccstring
	SendMessage(ah.hcc,CCM_CLEAR,0,0)
	SendMessage(ah.hred,EM_EXGETSEL,0,Cast(Integer,@chrg))
	If chrg.cpMin=chrg.cpMax Then
		lret=SendMessage(ah.hred,EM_EXLINEFROMCHAR,0,chrg.cpMax)
		chrg.cpMin=SendMessage(ah.hred,EM_LINEINDEX,lret,0)
		GetLineByNo ah.hred, lret, @buff           ' MOD 21.1.2012
		'buff=Chr(255) & Chr(1)
		'lret=SendMessage(ah.hred,EM_GETLINE,lret,Cast(Integer,@buff))
		'buff[lret]=NULL
		SendMessage(ah.hpr,PRM_GETWORD,chrg.cpMax-chrg.cpMin,Cast(Integer,@buff))
		If flocallist=FALSE Then
			lret=SendMessage(ah.hpr,PRM_FINDFIRST,Cast(Integer,StrPtr("PpWcSsdTnEe")),Cast(Integer,@buff))
			Do While lret
				ntype=SendMessage(ah.hpr,PRM_FINDGETTYPE,0,0)
				Select Case ntype
					Case Asc("p")
						ntype=1
					Case Asc("W")
						ntype=2
					Case Asc("c")
						ntype=3
					Case Asc("S")
						ntype=4
					Case Asc("s")
						ntype=5
					Case Asc("d")
						lstrcpy(ccpos,Cast(ZString Ptr,lret))
						lstrcat(ccpos,COLON)
						lret=lret+Len(*Cast(ZString Ptr,lret))+1
						lstrcat(ccpos,Cast(ZString Ptr,lret))
						lret=Cast(Integer,ccpos)
						ccpos=ccpos+Len(*ccpos)+1
						ntype=14
					Case Asc("T")
						ntype=10
					Case Asc("E")
						ntype=14
					Case Asc("e")
						ntype=14
					Case Else
						ntype=0
				End Select
				SendMessage(ah.hcc,CCM_ADDITEM,ntype,lret)
				lret=SendMessage(ah.hpr,PRM_FINDNEXT,0,0)
			Loop
		EndIf
		If lpProc Then
			'ccpos=@ccstring
			lpProc=lpProc+Len(*lpProc)+1
			lstrcpy(@s,lpProc)
			If IsZStrNotEmpty (s) Then                ' MOD 8.2.2012   If Asc(s)<>NULL Then
				GetItems(8)
			EndIf
			lpProc=lpProc+Len(*lpProc)+1
			' Skip return type
			lpProc=lpProc+Len(*lpProc)+1
			lstrcpy(@s,lpProc)
			If IsZStrNotEmpty (s) Then                ' MOD 8.2.2012   If Asc(s)<>NULL Then
				GetItems(9)
			EndIf
		EndIf
		SendMessage(ah.hcc,CCM_SORT,0,TRUE)
		SendMessage(ah.hcc,CCM_SETCURSEL,0,0)
	EndIf

End Sub

Sub GetStructItemsFromList(ByVal lpsz As ZString Ptr)

	ccpos=@ccstring
	lstrcpy(@s,lpsz)
	If s[0] Then
		GetItems(15)
	EndIf
	SendMessage(ah.hcc,CCM_SETCURSEL,0,0)
	If SendMessage(ah.hcc,CCM_GETCOUNT,0,0) Then
		fstructlist=TRUE
	EndIf

End Sub

Sub GetStructItemsFromNamespace(ByVal lpsz As ZString Ptr)
	Dim sItem As ZString*1024
	Dim lret As ZString Ptr
	Dim As Integer x,ntype

	sItem=*lpsz & "." & buff
	lret=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_FINDFIRST,Cast(WPARAM,StrPtr("psdcen")),Cast(LPARAM,@sItem)))
	While lret
		x=InStr(*lret,".")
		lret=lret+x
		ntype=SendMessage(ah.hpr,PRM_FINDGETTYPE,0,0)
		Select Case Chr(ntype)
			Case "p"
				ntype=1
			Case "c","e"
				ntype=3
			Case "s"
				ntype=5
			Case "d"
				ntype=14
			Case Else
				ntype=0
		End Select
		SendMessage(ah.hcc,CCM_ADDITEM,ntype,Cast(Integer,lret))
		lret=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_FINDNEXT,Cast(WPARAM,StrPtr("psdc")),Cast(LPARAM,@sItem)))
	Wend
	SendMessage(ah.hcc,CCM_SETCURSEL,0,0)
	If SendMessage(ah.hcc,CCM_GETCOUNT,0,0) Then
		fstructlist=TRUE
	EndIf

End Sub

Sub UpdateStructList(ByVal lpProc As ZString Ptr)
	
	'Dim chrg As CHARRANGE
	Dim nLine  As Integer = Any 
	Dim nowner As Integer = Any
    Dim x      As Integer = Any
    Dim n      As Integer = Any
    Dim i      As Integer = Any
    Dim k      As Integer = Any
	Dim sLine  As ZString * 512
	Dim sTemp  As ZString * 512
	Dim sz(32) As ZString * 256
	'Dim As ZString Ptr p(32)
	Dim lpsz   As ZString Ptr 

	SendMessage(ah.hcc,CCM_CLEAR,0,0)
	GetLineUpToCaret ah.hred, @sLine, nLine

	'SendMessage(ah.hred,EM_EXGETSEL,0,Cast(LPARAM,@chrg))
	'If chrg.cpMin=chrg.cpMax Then
		' Get the line
		'nline=SendMessage(ah.hred,EM_EXLINEFROMCHAR,0,chrg.cpMax)
		'GetLineByNo ah.hred, nline, @sLine     ' MOD 21.1.2012
		'chrg.cpMin=SendMessage(ah.hred,EM_LINEINDEX,nline,0)
		'x=chrg.cpMax-chrg.cpMin
   	    'buff=String(1024,0)
		'buff=Chr(x And 255) & Chr(x\256)
		'x=SendMessage(ah.hred,EM_GETLINE,nline,Cast(LPARAM,@buff))
		'buff[x]=NULL
		'lstrcpy(@sLine,@buff)

		'If fProject Then
		'	nowner=GetFileID(ad.filename)
		'Else
		    nowner=Cast(Integer,ah.hred)    
		'EndIf

		SendMessage(ah.hpr,PRM_GETSTRUCTSTART,Len(sLine),Cast(LPARAM,@sLine))
		If sLine[0] = Asc(".") Then                   'MOD 21.1.2012   Left(sLine,1)="." Then
			x=SendMessage(ah.hpr,PRM_ISINWITHBLOCK,nowner,nLine)
			If x Then
				sLine=*Cast(ZString Ptr,x) & sLine
			Else
				Exit Sub
			EndIf
		EndIf
		' Split the line into words
        i = 0  :  n = 0  :  k = 0
        Do
            Select Case sLine[i]
            Case Asc("-")
                If sLine[i + 1] = Asc (">") Then
                    sz(n)[k] = 0
                    i += 2
                    n += 1
                    k = 0
                EndIf
            Case Asc(".")
                sz(n)[k] = 0
                i += 1
                n += 1
                k = 0
            Case Asc(" ")
                i += 1
            Case 0
                sz(n)[k] = 0
                n += 1
                Exit Do
            Case Else
                sz(n)[k] = sLine[i]
                i += 1
                k += 1
            End Select
        Loop
        
		'lpsz=@sLine
		'p(0)=lpsz
		'n=1
		'While lpsz[0]
		'	If Left(*lpsz,1)="." Then
		'		lpsz[0]=0
		'		p(n)=lpsz+1
		'		n+=1
		'	ElseIf Left(*lpsz,2)="->" Then
		'		lpsz[0]=0
		'		p(n)=lpsz+2
		'		n+=1
		'		lpsz+=1
		'	EndIf
		'	lpsz+=1
		'Wend
		'x=0
		'While x<n
		'	sz(x)=*p(x)
		'	x+=1
		'Wend
		
		x=0
		While x<n
			If UCase(Left(sz(x),5))="CAST(" Then
				' Cast(RECT,myrect).left=5
				sz(x) = *(@sz(x) + 5)                'sz(x)=Mid(sz(x),6)
				i=InStr(sz(x),",")
				If i Then 
				    sz(x)[i - 1] = 0                 'sz(x)=Left(sz(x),i-1)
				EndIf
				' Remove leading whitespace
				'While sz(x)[0]=VK_SPACE Or sz(x)[0]=VK_TAB
				'	sz(x)=Mid(sz(x),2)
				'Wend
				' Remove trailing whitespace
				'i=0
				'While sz(x)[i]
				'	If sz(x)[i]=VK_SPACE Or sz(x)[i]=VK_TAB Then
				'		sz(x)[i]=0
				'		Exit While
				'	EndIf
				'	i+=1
				'Wend
			EndIf
			If sz(x)[0] Then
				sz(x)&="."
				SendMessage(ah.hpr,PRM_GETSTRUCTWORD,Len(sz(x)),Cast(LPARAM,@sz(x)))
			EndIf
			x+=1
		Wend
		If lpProc Then
			' Skip proc name
			lpProc=lpProc+Len(*lpProc)+1
			' Get parameters list
			sTemp=sz(0)
			SendMessage(ah.hpr,PRM_FINDITEMDATATYPE,Cast(WPARAM,@sTemp),Cast(LPARAM,lpProc))
			If sTemp[0]=0 Then
				' Skip parameters list
				lpProc=lpProc+Len(*lpProc)+1
				' Skip return type
				lpProc=lpProc+Len(*lpProc)+1
				' Get local data list
				sTemp=sz(0)
				SendMessage(ah.hpr,PRM_FINDITEMDATATYPE,Cast(WPARAM,@sTemp),Cast(LPARAM,lpProc))
			EndIf
			If sTemp[0] Then
				sz(0)=sTemp
			EndIf
		EndIf
		While TRUE
			' trim init value [xxx]
			x = InStr(sz(0),"[")
			If x Then sz(0)[x - 1] = 0

			lpsz=FindExact(StrPtr("eEsSnfd"),sz(0),TRUE)
			If lpsz=0 Then
				Exit Sub
			EndIf
			x=SendMessage(ah.hpr,PRM_FINDGETTYPE,0,0)
			Select Case x
				Case Asc("e"), Asc("E")
					' Enum
					If n=2 Then
						buff=sz(1)
						lpsz+=Len(*lpsz)+1
						GetStructItemsFromList(lpsz)
					EndIf
					Exit Sub
				Case Asc("s"), Asc("S")
					' Struct
					lpsz+=Len(*lpsz)+1
					If n=2 Then
						buff=sz(1)
						GetStructItemsFromList(lpsz)
						Exit Sub
					Else
						SendMessage(ah.hpr,PRM_FINDITEMDATATYPE,Cast(WPARAM,@sz(1)),Cast(LPARAM,lpsz))
						sz(0)=sz(1)
						i=InStr(sz(0)," ")
						If i Then
							sz(0)[i-1]=0
						EndIf
						x=1
						While x<n
							sz(x)=sz(x+1)
							x+=1
						Wend
						n-=1
					EndIf
			    Case Asc("n")
					' Namespace
					If n=2 Then
						buff=sz(1)
						GetStructItemsFromNamespace(lpsz)
						Exit Sub
					Else
						sz(0)&="." & sz(1)
						x=1
						While x<n
							sz(x)=sz(x+1)
							x+=1
						Wend
						n-=1
					EndIf
				Case Asc("f")
					' Function MyFunc(ByVal a As Integer) As RECT Ptr
					lpsz+=Len(*lpsz)+1
					sz(0)=*lpsz
					i=InStr(sz(0)," ")
					If i Then
						sz(0)[i-1]=0
					EndIf
				Case Asc("d")
					' Dim rect As RECT
					' rect.left
					lpsz+=Len(*lpsz)+1
					sz(0)=*lpsz
					i=InStr(sz(0)," ")
					If i Then
						sz(0)[i-1]=0
					EndIf
			End Select
		Wend
	'EndIf

End Sub

Sub UpdateTypeList()
	Dim lret As Integer
	Dim chrg As CHARRANGE
	Dim ntype As Integer

	SendMessage(ah.hcc,CCM_CLEAR,0,0)
	'SendMessage(ah.hred,EM_EXGETSEL,0,Cast(Integer,@chrg))
	'If chrg.cpMin=chrg.cpMax Then
		'lret=SendMessage(ah.hred,EM_EXLINEFROMCHAR,0,chrg.cpMax)
		'chrg.cpMin=SendMessage(ah.hred,EM_LINEINDEX,lret,0)
        'GetLineByNo ah.hred, lret, @buff           ' MOD 21.1.2012
		''buff=Chr(255) & Chr(1)
		''lret=SendMessage(ah.hred,EM_GETLINE,lret,Cast(Integer,@buff))
		''buff[lret]=NULL
		'SendMessage(ah.hpr,PRM_GETWORD,chrg.cpMax-chrg.cpMin,Cast(Integer,@buff))

		GetLineUpToCaret ah.hred, @buff, 0
		SendMessage ah.hpr, PRM_GETWORD, lstrlen (@buff), Cast (LPARAM, @buff)
		lret=SendMessage(ah.hpr,PRM_FINDFIRST,Cast(Integer,StrPtr("SsTEe")),Cast(Integer,@buff))
		Do While lret
			ntype=SendMessage(ah.hpr,PRM_FINDGETTYPE,0,0)
			Select Case ntype
				Case Asc("S")
					ntype=4
				Case Asc("s")
					ntype=5
				Case Asc("T")
					ntype=10
				Case Asc("E")
					ntype=14
				Case Asc("e")
					ntype=14
			End Select
			SendMessage(ah.hcc,CCM_ADDITEM,ntype,lret)
			lret=SendMessage(ah.hpr,PRM_FINDNEXT,0,0)
		Loop
		SendMessage(ah.hcc,CCM_SORT,0,TRUE)
		SendMessage(ah.hcc,CCM_SETCURSEL,0,0)
		If SendMessage(ah.hcc,CCM_GETCOUNT,0,0) Then
			ftypelist=TRUE
		EndIf
	'EndIf

End Sub

Function UpdateConstList(ByVal lpszApi As ZString Ptr,ByVal npos As Integer) As Integer
	Dim lret As ZString Ptr
	Dim chrg As CHARRANGE
	Dim ln As Integer
	Dim ccal As CC_ADDLIST
	Dim ntype As Integer
    
    buff=Str(npos)
	lstrcat(@buff,lpszApi)
	lret=FindExact(StrPtr("A"),@buff,TRUE)
	If lret Then
		'Print "foundexact:";*lret
		SendMessage(ah.hcc,CCM_CLEAR,0,0)
		'SendMessage(ah.hred,EM_EXGETSEL,0,Cast(Integer,@chrg))
		'If chrg.cpMin=chrg.cpMax Then
			'ln=SendMessage(ah.hred,EM_EXLINEFROMCHAR,0,chrg.cpMax)
			'chrg.cpMin=SendMessage(ah.hred,EM_LINEINDEX,ln,0)
		    GetLineUpToCaret ah.hred, @buff, 0
		    'GetLineByNo ah.hred, ln, @buff           ' MOD 21.1.2012
		    'GetSubStr 0, buff, buff, !"\t "          ' whitespace delimited (preserve pending comment)
			'buff=Chr(255) & Chr(1)
			'ln=SendMessage(ah.hred,EM_GETLINE,ln,Cast(Integer,@buff))
			'buff[ln]=NULL
			'SendMessage(ah.hpr,PRM_GETWORD,chrg.cpMax-chrg.cpMin,Cast(Integer,@buff))
			SendMessage ah.hpr, PRM_GETWORD, lstrlen (@buff), Cast (LPARAM, @buff)
			If lstrlen(lret+lstrlen(lret)+1) Then
				' Handles 3SendDlgItemMessage,2SendMessage and 2PostMessage
				SetZStrEmpty (s)             'MOD 26.1.2012 
				ccal.lpszList=@s
				ccal.lpszFilter=@buff
				ccal.nType=2
				While lret
					If IsZStrNotEmpty (s) Then
						s &=","
					EndIf
					lret+=Len(*lret)+1
					s &=*lret
					lret=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_FINDNEXT,0,0))
				Wend
				SendMessage(ah.hcc,CCM_ADDLIST,0,Cast(Integer,@ccal))
				SendMessage(ah.hcc,CCM_SORT,0,TRUE)
				SendMessage(ah.hcc,CCM_SETCURSEL,0,0)
				Return 1
			Else
				' Handles Cast(
				lret=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_FINDFIRST,Cast(WPARAM,StrPtr("SsTEe")),Cast(LPARAM,@buff)))
				Do While lret
					ntype=SendMessage(ah.hpr,PRM_FINDGETTYPE,0,0)
					Select Case ntype
						Case Asc("S")
							ntype=4
						Case Asc("s")
							ntype=5
						Case Asc("T")
							ntype=10
						Case Asc("e")
							ntype=14
						Case Asc("E")
							ntype=14
					End Select
					SendMessage(ah.hcc,CCM_ADDITEM,ntype,Cast(LPARAM,lret))
					lret=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_FINDNEXT,0,0))
				Loop
				SendMessage(ah.hcc,CCM_SORT,0,TRUE)
				SendMessage(ah.hcc,CCM_SETCURSEL,0,0)
				fconstlist=FALSE
				ftypelist=TRUE
				Return 2
			EndIf
		'EndIf
	EndIf
	Return 0

End Function

Function UpdateEnumList(ByVal lpszEnum As ZString Ptr) As Boolean
	Dim lret As ZString Ptr
	Dim chrg As CHARRANGE
	Dim ln As Integer
	Dim ccal As CC_ADDLIST

	SendMessage(ah.hcc,CCM_CLEAR,0,0)
	SendMessage(ah.hred,EM_EXGETSEL,0,Cast(Integer,@chrg))
	If chrg.cpMin=chrg.cpMax Then
		lret=lpszEnum+Len(*lpszEnum)+1
		ln=SendMessage(ah.hred,EM_EXLINEFROMCHAR,0,chrg.cpMax)
		chrg.cpMin=SendMessage(ah.hred,EM_LINEINDEX,ln,0)
		GetLineByNo ah.hred, ln, @buff           ' MOD 21.1.2012
		'buff=Chr(255) & Chr(1)
		'ln=SendMessage(ah.hred,EM_GETLINE,ln,Cast(Integer,@buff))
		'buff[ln]=NULL
		SendMessage(ah.hpr,PRM_GETWORD,chrg.cpMax-chrg.cpMin,Cast(Integer,@buff))
		lstrcpy(@s,lret)
		ccal.lpszList=@s
		ccal.lpszFilter=@buff
		ccal.nType=14
		SendMessage(ah.hcc,CCM_ADDLIST,0,Cast(Integer,@ccal))
		SendMessage(ah.hcc,CCM_SETCURSEL,0,0)
		Return TRUE
	EndIf
	Return FALSE

End Function

Sub IsStructList()
	Dim x As Integer
	Dim lret As ZString Ptr
	Dim chrg As CHARRANGE
	Dim isinp As ISINPROC

	SendMessage(ah.hred,EM_EXGETSEL,0,Cast(Integer,@chrg))
	isinp.nLine=SendMessage(ah.hred,EM_EXLINEFROMCHAR,0,chrg.cpMax)
	If fProject Then
		isinp.nOwner=GetFileIDByEditor(ah.hred)
	Else
	    isinp.nOwner=Cast(Integer,ah.hred)    
	EndIf
	isinp.lpszType=StrPtr("pxyzo")
	lret=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_ISINPROC,0,Cast(LPARAM,@isinp)))
	UpdateStructList(lret)
	If fstructlist Then
		MoveList
	EndIf

End Sub


Function ExtractDirFile(ByVal lpsrc As ZString Ptr, ByVal lpdst As ZString Ptr) As Integer
	Dim As UByte Ptr ps,pd
	
	ps=lpsrc
	pd=lpdst
	
	While *ps
		If *ps=Asc("#") Then Exit While
		*pd=*ps
		ps+=1
		pd+=1
	Wend
	*pd=0
	Return valInt(*lpdst)
	
End Function

Sub UpdateIncludeList()
	Dim As Integer sFind,nType,nLen
	Dim d As Integer = Any 
	Dim As ZString*260 buffer,txt
	Dim As ZString Ptr p
	
	ccpos=@ccstring
	p=StrPtr(DirList)
    'GetSubStr 0, buff, buff, !"\t "                     ' whitespace delimited (preserve pending comment)
	txt = "," + buff                                    ' MOD 4.1.2012    txt=","+LCase(buff)
	SendMessage(ah.hcc,CCM_CLEAR,0,0)
	sFind = InStr (DirListLCase, txt)                   ' MOD 4.1.2012    dirlist -> DirListLCase
	While sFind<>0 And nLen<65450
		nType=ExtractDirFile(p+sFind-2,@buffer)
		If LCase (Right (buffer, 3)) = ".bi" OrElse LCase (Right (buffer, 4)) = ".bas" Then
			lstrcpy(ccpos,@buffer+2)
			SendMessage(ah.hcc,CCM_ADDITEM,nType,Cast(LPARAM,ccpos))
			d = lstrlen (ccpos) + 1
			nLen += d
			ccpos += d
		EndIf
		sFind = InStr (sFind + 1, DirListLCase, txt)    ' MOD 4.1.2012    dirlist -> DirListLCase
		fincludelist=TRUE
	Wend
	If fincludelist Then
		SendMessage(ah.hcc,CCM_SORT,0,0)
		SendMessage(ah.hcc,CCM_SETCURSEL,0,0)
		MoveList
	EndIf

End Sub

Sub UpdateInclibList()
	Dim As Integer sFind,nType,nLen,i
	Dim As ZString*260 buffer,txt
	Dim As ZString Ptr p
	
	ccpos=@ccstring
	p=StrPtr(DirList)
    'GetSubStr 0, buff, buff, SizeOf(buff), !"\t "       ' whitespace delimited (preserve pending comment)
	txt = "," + buff                                    ' MOD 4.1.2012    txt=","+LCase(buff)
	SendMessage(ah.hcc,CCM_CLEAR,0,0)
	sFind = InStr (DirListLCase, txt)                   ' MOD 4.1.2012    dirlist -> DirListLCase
	While sFind<>0 And nLen<65450
		nType=ExtractDirFile(p+sFind-2,@buffer)
		buffer=Mid(buffer,3)
		lstrcpy(ccpos,@buffer)
		SendMessage(ah.hcc,CCM_ADDITEM,nType,Cast(LPARAM,ccpos))
		nLen+=Len(*ccpos)+1
		ccpos=ccpos+Len(*ccpos)+1
		sFind = InStr (sFind + 1, DirListLCase, txt)    ' MOD 4.1.2012    dirlist -> DirListLCase
		fincliblist=TRUE
	Wend
	If fincliblist Then
		SendMessage(ah.hcc,CCM_SORT,0,0)
		SendMessage(ah.hcc,CCM_SETCURSEL,0,0)
		MoveList
	EndIf

End Sub
