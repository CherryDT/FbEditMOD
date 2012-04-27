Dim Shared As String dirlist

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
	SendMessage(ah.hpr,PRM_ADDIGNORE,IGNORE_STRUCTITEMFIRSTWORD,Cast(Integer,StrPtr("as")))
	SendMessage(ah.hpr,PRM_ADDIGNORE,IGNORE_STRUCTITEMSECONDWORD,Cast(Integer,StrPtr("as")))
	SendMessage(ah.hpr,PRM_ADDIGNORE,IGNORE_STRUCTTHIRDWORD,Cast(Integer,StrPtr("as")))
	SendMessage(ah.hpr,PRM_ADDIGNORE,IGNORE_STRUCTITEMINIT,Cast(Integer,StrPtr("declare")))
	SendMessage(ah.hpr,PRM_ADDIGNORE,IGNORE_STRUCTITEMINIT,Cast(Integer,StrPtr("static")))
	SendMessage(ah.hpr,PRM_ADDIGNORE,IGNORE_PTR,Cast(Integer,StrPtr("ptr")))
	SendMessage(ah.hpr,PRM_ADDIGNORE,IGNORE_DATATYPE,Cast(Integer,StrPtr("const")))
	SendMessage(ah.hpr,PRM_ADDIGNORE,IGNORE_STRUCTLINEFIRSTWORD,Cast(Integer,StrPtr("private")))
	SendMessage(ah.hpr,PRM_ADDIGNORE,IGNORE_STRUCTLINEFIRSTWORD,Cast(Integer,StrPtr("public")))
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
	' Set button 'Open files'
	SendMessage(ah.hpr,PRM_SETSELBUTTON,2,0)
End Sub

Sub HideList()

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
	Dim pt As Point
	Dim rect As RECT
	Dim rect1 As RECT

	GetCaretPos(@pt)
	GetWindowRect(ah.hcc,@rect1)
	SendMessage(ah.hred,EM_GETRECT,0,Cast(Integer,@rect))
	ClientToScreen(ah.hred,Cast(Point Ptr,@rect))
	rect.top=rect.top+pt.y+18
	If rect.top+rect1.bottom-rect1.top+8>GetSystemMetrics(SM_CYMAXIMIZED) Then
		rect.top=rect.top-rect1.bottom+rect1.top-22
	EndIf
	If edtopt.autowidth Then
		rect.right=SendMessage(ah.hcc,CCM_GETMAXWIDTH,0,0)+8
		If rect.right<100 Then
			rect.right=100
		EndIf
	Else
		rect.right=rect1.right-rect1.left
	EndIf
	rect.bottom=wpos.ptcclist.y
	SetWindowPos(ah.hcc,HWND_TOP,rect.left+pt.x+5,rect.top,rect.right,rect.bottom,SWP_NOACTIVATE Or SWP_SHOWWINDOW)
	ShowWindow(ah.htt,SW_HIDE)

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
		If Len(*ccpos) Then
			lstrcpyn(@sItem,ccpos,Len(buff)+1)
			If lstrcmpi(@sItem,@buff)=0 Then
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
		buff=Chr(255) & Chr(1)
		lret=SendMessage(ah.hred,EM_GETLINE,lret,Cast(Integer,@buff))
		buff[lret]=NULL
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
						lstrcat(ccpos,@szColon)
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
			If Asc(s)<>NULL Then
				GetItems(8)
			EndIf
			lpProc=lpProc+Len(*lpProc)+1
			' Skip return type
			lpProc=lpProc+Len(*lpProc)+1
			lstrcpy(@s,lpProc)
			If Asc(s)<>NULL Then
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
	Dim chrg As CHARRANGE
	Dim As Integer nLine,nowner,x,n,i
	Dim sLine As ZString*1024
	Dim sTemp As ZString*1024
	Dim sz(32) As ZString*256
	Dim As ZString Ptr p(32),lpsz

	SendMessage(ah.hcc,CCM_CLEAR,0,0)
	SendMessage(ah.hred,EM_EXGETSEL,0,Cast(LPARAM,@chrg))
	If chrg.cpMin=chrg.cpMax Then
		' Get the line
		nline=SendMessage(ah.hred,EM_EXLINEFROMCHAR,0,chrg.cpMax)
		chrg.cpMin=SendMessage(ah.hred,EM_LINEINDEX,nline,0)
		x=chrg.cpMax-chrg.cpMin
		buff=String(1024,0)
		buff=Chr(x And 255) & Chr(x\256)
		x=SendMessage(ah.hred,EM_GETLINE,nline,Cast(LPARAM,@buff))
		buff[x]=NULL
		lstrcpy(@sLine,@buff)
		nowner=Cast(Integer,ah.hred)
		If fProject Then
			nowner=IsProjectFile(ad.filename)
		EndIf
		SendMessage(ah.hpr,PRM_GETSTRUCTSTART,Len(sLine),Cast(LPARAM,@sLine))
		If Left(sLine,1)="." Then
			x=SendMessage(ah.hpr,PRM_ISINWITHBLOCK,nowner,nline)
			If x Then
				sLine=*Cast(ZString Ptr,x) & sLine
			Else
				Exit Sub
			EndIf
		EndIf
		' Split the line into words
		lpsz=@sLine
		p(0)=lpsz
		n=1
		While lpsz[0]
			If Left(*lpsz,1)="." Then
				lpsz[0]=0
				p(n)=lpsz+1
				n+=1
			ElseIf Left(*lpsz,2)="->" Then
				lpsz[0]=0
				p(n)=lpsz+2
				n+=1
				lpsz+=1
			EndIf
			lpsz+=1
		Wend
		x=0
		While x<n
			sz(x)=*p(x)
			x+=1
		Wend
		x=0
		While x<n
			If UCase(Left(sz(x),5))="CAST(" Then
				' Cast(RECT,myrect).left=5
				sz(x)=Mid(sz(x),6)
				i=InStr(sz(x),",")
				If i Then
					sz(x)=Left(sz(x),i-1)
				EndIf
				' Remove leading whitespace
				While sz(x)[0]=VK_SPACE Or sz(x)[0]=VK_TAB
					sz(x)=Mid(sz(x),2)
				Wend
				' Remove trailing whitespace
				i=0
				While sz(x)[i]
					If sz(x)[i]=VK_SPACE Or sz(x)[i]=VK_TAB Then
						sz(x)[i]=0
						Exit While
					EndIf
					i+=1
				Wend
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
			lpsz=FindExact(StrPtr("eEsSnfd"),sz(0),TRUE)
			If lpsz=0 Then
				Exit Sub
			EndIf
			x=SendMessage(ah.hpr,PRM_FINDGETTYPE,0,0)
			Select Case Chr(x)
				Case "e","E"
					' Enum
					If n=2 Then
						buff=sz(n-1)
						lpsz+=Len(*lpsz)+1
						GetStructItemsFromList(lpsz)
					EndIf
					Exit Sub
				Case "s","S"
					' Struct
					lpsz+=Len(*lpsz)+1
					If n=2 Then
						buff=sz(n-1)
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
				Case "n"
					' Namespace
					If n=2 Then
						buff=sz(n-1)
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
				Case "f"
					' Function MyFunc(ByVal a As Integer) As RECT Ptr
					lpsz+=Len(*lpsz)+1
					sz(0)=*lpsz
					i=InStr(sz(0)," ")
					If i Then
						sz(0)[i-1]=0
					EndIf
				Case "d"
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
	EndIf

End Sub

Sub UpdateTypeList()
	Dim lret As Integer
	Dim chrg As CHARRANGE
	Dim ntype As Integer

	SendMessage(ah.hcc,CCM_CLEAR,0,0)
	SendMessage(ah.hred,EM_EXGETSEL,0,Cast(Integer,@chrg))
	If chrg.cpMin=chrg.cpMax Then
		lret=SendMessage(ah.hred,EM_EXLINEFROMCHAR,0,chrg.cpMax)
		chrg.cpMin=SendMessage(ah.hred,EM_LINEINDEX,lret,0)
		buff=Chr(255) & Chr(1)
		lret=SendMessage(ah.hred,EM_GETLINE,lret,Cast(Integer,@buff))
		buff[lret]=NULL
		SendMessage(ah.hpr,PRM_GETWORD,chrg.cpMax-chrg.cpMin,Cast(Integer,@buff))
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
	EndIf

End Sub

Function UpdateConstList(ByVal lpszApi As ZString Ptr,npos As Integer) As Integer
	Dim lret As ZString Ptr
	Dim chrg As CHARRANGE
	Dim ln As Integer
	Dim ccal As CC_ADDLIST
	Dim ntype As Integer

	buff=Str(npos)
	lstrcat(@buff,lpszApi)
	lret=FindExact(StrPtr("A"),@buff,TRUE)
	If lret Then
		SendMessage(ah.hcc,CCM_CLEAR,0,0)
		SendMessage(ah.hred,EM_EXGETSEL,0,Cast(Integer,@chrg))
		If chrg.cpMin=chrg.cpMax Then
			ln=SendMessage(ah.hred,EM_EXLINEFROMCHAR,0,chrg.cpMax)
			chrg.cpMin=SendMessage(ah.hred,EM_LINEINDEX,ln,0)
			buff=Chr(255) & Chr(1)
			ln=SendMessage(ah.hred,EM_GETLINE,ln,Cast(Integer,@buff))
			buff[ln]=NULL
			SendMessage(ah.hpr,PRM_GETWORD,chrg.cpMax-chrg.cpMin,Cast(Integer,@buff))
			If lstrlen(lret+lstrlen(lret)+1) Then
				' Handles 3SendDlgItemMessage,2SendMessage and 2PostMessage
				s=""
				ccal.lpszList=@s
				ccal.lpszFilter=@buff
				ccal.nType=2
				While lret
					If Len(s) Then
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
		EndIf
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
		buff=Chr(255) & Chr(1)
		ln=SendMessage(ah.hred,EM_GETLINE,ln,Cast(Integer,@buff))
		buff[ln]=NULL
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
	isinp.nOwner=Cast(Integer,ah.hred)
	If fProject Then
		isinp.nOwner=GetProjectFileID(ah.hred)
	EndIf
	isinp.lpszType=StrPtr("pxyzo")
	lret=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_ISINPROC,0,Cast(LPARAM,@isinp)))
	UpdateStructList(lret)
	If fstructlist Then
		MoveList
	EndIf

End Sub

Sub BuildDirList(ByVal lpDir As ZString Ptr,ByVal lpSub As ZString Ptr,ByVal nType As Integer)
	Dim wfd As WIN32_FIND_DATA
	Dim hwfd As HANDLE
	Dim buffer As ZString*260
	Dim subdir As ZString*260
	Dim l As Integer
	Dim ls As Integer

	lstrcpy(@buffer,lpDir)
	lstrcpy(@subdir,lpSub)
	lstrcat(@buffer,"\*")
	hwfd=FindFirstFile(@buffer,@wfd)
	If hwfd<>INVALID_HANDLE_VALUE Then
		While TRUE
			If wfd.dwFileAttributes And FILE_ATTRIBUTE_DIRECTORY Then
				lstrcpy(@s,@wfd.cFileName)
				If Asc(s)<>Asc(".") Then
					buffer[Len(buffer)-1]=0
					l=Len(buffer)
					lstrcat(@buffer,@wfd.cFileName)
					ls=Len(subdir)
					lstrcat(@subdir,@wfd.cFileName)
					lstrcat(@subdir,"/")
					BuildDirList(@buffer,@subdir,nType)
					buffer[l]=0
					lstrcat(@buffer,"*")
					subdir[ls]=0
				EndIf
			Else
				If ntype<8 Then
					If lpSub Then
						lstrcpy(@s,lpSub)
						lstrcat(@s,@wfd.cFileName)
					Else
						lstrcpy(@s,@wfd.cFileName)
					EndIf
					dirlist+=Str(nType)+","+LCase(s)+"#"
				Else
					lstrcpy(@s,@wfd.cFileName)
					s=LCase(s)
					If Right(s,2)=".a" Then
						s=Left(s,Len(s)-2)
						If Right(s,4)=".dll" Then
							s=Left(s,Len(s)-4)
						EndIf
						dirlist+=Str(nType And 7)+","+s+"#"
					EndIf
				EndIf
			EndIf
			If FindNextFile(hwfd,@wfd)=FALSE Then
				Exit While
			EndIf
		Wend
		FindClose(hwfd)
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
	Dim As ZString*260 buffer,txt
	Dim As ZString Ptr p
	
	ccpos=@ccstring
	p=StrPtr(dirlist)
	txt=","+LCase(buff)
	SendMessage(ah.hcc,CCM_CLEAR,0,0)
	sFind=InStr(dirlist,txt)
	While sFind<>0 And nLen<65450
		nType=ExtractDirFile(p+sFind-2,@buffer)
		If Right(buffer,3)=".bi" Or Right(buffer,4)=".bas" Then
			lstrcpy(ccpos,@buffer+2)
			SendMessage(ah.hcc,CCM_ADDITEM,nType,Cast(LPARAM,ccpos))
			nLen+=Len(*ccpos)+1
			ccpos=ccpos+Len(*ccpos)+1
		EndIf
		sFind=InStr(sFind+1,dirlist,txt)
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
	p=StrPtr(dirlist)
	txt=","+LCase(buff)
	SendMessage(ah.hcc,CCM_CLEAR,0,0)
	sFind=InStr(dirlist,txt)
	While sFind<>0 And nLen<65450
		nType=ExtractDirFile(p+sFind-2,@buffer)
		buffer=Mid(buffer,3)
		lstrcpy(ccpos,@buffer)
		SendMessage(ah.hcc,CCM_ADDITEM,nType,Cast(LPARAM,ccpos))
		nLen+=Len(*ccpos)+1
		ccpos=ccpos+Len(*ccpos)+1
		sFind=InStr(sFind+1,dirlist,txt)
		fincliblist=TRUE
	Wend
	If fincliblist Then
		SendMessage(ah.hcc,CCM_SORT,0,0)
		SendMessage(ah.hcc,CCM_SETCURSEL,0,0)
		MoveList
	EndIf

End Sub
