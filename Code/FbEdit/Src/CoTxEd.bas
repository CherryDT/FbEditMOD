

#Include Once "windows.bi"

#Include Once "Inc\RACodeComplete.bi"
#Include Once "Inc\RAProperty.bi"
#Include Once "Inc\RAEdit.bi"
#Include Once "Inc\RAHexEd.bi"

#Include Once "Inc\Addins.bi"
#Include Once "Inc\CodeComplete.bi"
#Include Once "Inc\EditorOpt.bi"
#Include Once "Inc\FbEdit.bi"
#Include Once "Inc\GUIHandling.bi"
#Include Once "Inc\Language.bi"
#Include Once "Inc\Misc.bi"
#Include Once "Inc\Project.bi"
#Include Once "Inc\Property.bi"
#Include Once "Inc\Resource.bi"
#Include Once "Inc\SpecHandling.bi"
#Include Once "Inc\Statusbar.bi"
#Include Once "Inc\TabTool.bi"
#Include Once "Inc\ZStringHandling.bi"

#Include Once "Inc\CoTxEd.bi"
#Include Once "Inc\showvars.bi"


Dim Shared lpOldCoTxEdProc          As WNDPROC
Dim Shared lpOldParCoTxEdProc       As WNDPROC
Dim Shared lpOldCCProc              As WNDPROC

Dim Shared lstpos                   As LASTPOS
Dim Shared szCaseConvert            As ZString * 32
Dim Shared szIndent(MAXBLOCKDEFS)   As ZString * 32
Dim Shared autofmt(MAXBLOCKDEFS)    As AUTOFORMAT

' Code blocks
Dim Shared blk                      As RABLOCKDEF
Dim Shared szSt(MAXBLOCKDEFS)       As ZString * 32
Dim Shared szEn(MAXBLOCKDEFS)       As ZString * 32
Dim Shared szNot1                   As ZString * 32
Dim Shared szNot2                   As ZString * 32
Dim Shared BD(MAXBLOCKDEFS)         As RABLOCKDEF

Dim Shared prechrg                  As CHARRANGE
Dim Shared mdn                      As Integer

Dim Shared EditInfo                 As EditorTypeInfo

#Define IDT_MOUSE_CLK_TIMER         100


Sub GetLineByNo (ByVal hWin As HWND, ByVal LineNo As Integer, Byval pBuff As ZString Ptr)

	' LineNo [in ] zerobased
	' pBuff  [out] receives up to 512 bytes

    Const MaxChars As UShort  = 511     ' + NULL
    Dim   Length   As LRESULT = Any

    *Cast(UShort Ptr, pBuff) = MaxChars

    'pbuff[0] = LoByte (MaxChars)
	'pbuff[1] = HiByte (MaxChars)

    'The copied line will not contain a terminating null character
    Length = SendMessage (hWin, EM_GETLINE, LineNo, Cast (LPARAM, pBuff))

    pBuff[Length] = NULL                ' fix it

End Sub

Sub GetLineByCaret (ByVal hWin As HWND, ByRef pBuff As ZString Ptr, ByRef LineNo As Integer)     ' MOD 21.1.2012   Function GetLineBySel(ByVal hWin As HWND,ByRef lpszBuff As ZString Ptr) As Integer

	' pBuff  [out] receives up to 512 bytes
	' LineNo [out] zerobased

	Dim chrg   As CHARRANGE = Any

	SendMessage hWin, EM_EXGETSEL, 0, Cast (LPARAM, @chrg)
	LineNo = SendMessage (hWin, EM_EXLINEFROMCHAR, 0, chrg.cpMax)
	'chrg.cpMin=SendMessage(hWin,EM_LINEINDEX,ln,0)

	GetLineByNo hWin, LineNo, pBuff

	'*lpszBuff=Chr(255) & Chr(1)
	'ln=SendMessage(hWin,EM_GETLINE,ln,Cast(LPARAM,lpszBuff))
	'lpszBuff[ln]=NULL
	' MOD 21.1.2012    Return ln     (unused)

End Sub                'MOD 21.1.2012 Function -> Sub

Sub GetLineUpToCaret (ByVal hWin As HWND, ByRef pBuff As ZString Ptr, ByRef LineNo As Integer)

	' pBuff  [out] receives up to 512 bytes
	' LineNo [out] zerobased

    Const MaxChars As UShort    = 511     ' + NULL
    Dim   Length   As LRESULT   = Any
	Dim   chrg     As CHARRANGE = Any

   	SendMessage hWin, EM_EXGETSEL, 0, Cast (LPARAM, @chrg)
	LineNo = SendMessage (hWin, EM_EXLINEFROMCHAR, 0, chrg.cpMax)
    Length = chrg.cpMax - SendMessage (hWin, EM_LINEINDEX, LineNo, 0)

    If Length > MaxChars Then
        *Cast(UShort Ptr, pBuff) = MaxChars
    Else
        *Cast(UShort Ptr, pBuff) = Length
    EndIf

    'The copied line will not contain a terminating null character
    Length = SendMessage (hWin, EM_GETLINE, LineNo, Cast (LPARAM, pBuff))

    pBuff[Length] = NULL                ' fix it

End Sub

Sub GetStringLiteralByCaret (ByVal hWin As HWND, ByRef pBuff As ZString Ptr, ByRef LineNo As Integer)

   	' pBuff  [out] receives up to 512 bytes
	' LineNo [out] zerobased

	Dim chrg     As CHARRANGE = Any
    Dim CharType As LRESULT   = Any

	SendMessage hWin, EM_EXGETSEL, 0, Cast (LPARAM, @chrg)
	CharType = SendMessage (hWin, REM_ISCHARPOS, chrg.cpMin, 0)

	If CharType = 3 Then                     ' 3=IsString  (string literal: "xyz")
	    LineNo = SendMessage (hWin, EM_EXLINEFROMCHAR, 0, chrg.cpMax)
	    GetLineByNo hWin, LineNo, pBuff
        GetEnclosedStr 0, *pBuff, *pBuff, CInt (512), CUByte (34), CUByte (34)
	Else
	    SetZStrEmpty (pBuff)
    EndIf

End Sub

Sub TrimTrailingSpaces
	Dim chrg As CHARRANGE
	Dim LnSt As Integer
	Dim LnEn As Integer

	SendMessage(ah.hred,WM_SETREDRAW,FALSE,0)
	SendMessage(ah.hred,REM_LOCKUNDOID,TRUE,0)
	SendMessage(ah.hred,EM_EXGETSEL,0,Cast(Integer,@chrg))
	LnSt=SendMessage(ah.hred,EM_EXLINEFROMCHAR,0,chrg.cpMin)
	If chrg.cpMax>chrg.cpMin Then
		chrg.cpMax=chrg.cpMax-1
	EndIf
	chrg.cpMin=SendMessage(ah.hred,EM_LINEINDEX,LnSt,0)
	LnEn=SendMessage(ah.hred,EM_EXLINEFROMCHAR,0,chrg.cpMax)
	Do While LnSt<=LnEn
		SendMessage(ah.hred,REM_TRIMSPACE,LnSt,FALSE)
		LnSt=LnSt+1
	Loop
	chrg.cpMax=SendMessage(ah.hred,EM_LINEINDEX,LnEn,0)
	chrg.cpMax=chrg.cpMax+SendMessage(ah.hred,EM_LINELENGTH,chrg.cpMax,0)+1
	SendMessage(ah.hred,EM_EXSETSEL,0,Cast(Integer,@chrg))
	SendMessage(ah.hred,REM_LOCKUNDOID,FALSE,0)
	SendMessage(ah.hred,WM_SETREDRAW,TRUE,0)
	SendMessage(ah.hred,REM_REPAINT,0,0)
	SetFocus(ah.hred)

End Sub

Sub IndentComment(Byref char As zString,ByVal fUn As Boolean)
	Dim ochrg As CHARRANGE
	Dim chrg As CHARRANGE
	Dim As Integer LnSt,LnEn,LnCnt,tmp,nmin,n,x,bm
	Dim buffer As String*128

	x=ad.fNoNotify
	ad.fNoNotify=TRUE
	nmin=999
	'SendMessage(ah.hred,WM_SETREDRAW,FALSE,0)
	SendMessage(ah.hred,REM_LOCKUNDOID,TRUE,0)
	SendMessage(ah.hred,EM_EXGETSEL,0,Cast(LPARAM,@ochrg))
	chrg.cpMin=ochrg.cpMin
	chrg.cpMax=ochrg.cpMax
	SendMessage(ah.hred,EM_HIDESELECTION,TRUE,0)
	LnSt=SendMessage(ah.hred,EM_EXLINEFROMCHAR,0,chrg.cpMin)
	If chrg.cpMax>chrg.cpMin Then
		chrg.cpMax-=1
	EndIf
	LnEn=SendMessage(ah.hred,EM_EXLINEFROMCHAR,0,chrg.cpMax)
	LnCnt=LnEn-LnSt
	If LnCnt Then
		ochrg.cpMin=SendMessage(ah.hred,EM_LINEINDEX,LnSt,0)
		ochrg.cpMax=SendMessage(ah.hred,EM_LINEINDEX,LnEn,0)
		ochrg.cpMax=ochrg.cpMax+SendMessage(ah.hred,EM_LINELENGTH,ochrg.cpMax,0)+1
	ElseIf ochrg.cpMin<>ochrg.cpMax Then
		If ochrg.cpMin=SendMessage(ah.hred,EM_LINEINDEX,LnSt,0) And ochrg.cpMax=SendMessage(ah.hred,EM_LINEINDEX,LnEn+1,0) Then
			LnCnt=1
		EndIf
	EndIf
	Do While LnSt<=LnEn
		If fUn Then
			' Uncomment or Outdent
			If char=Chr(9) Then
				' Outdent
				chrg.cpMin=SendMessage(ah.hred,EM_LINEINDEX,LnSt,0)
				chrg.cpMax=chrg.cpMin+1
				SendMessage(ah.hred,EM_EXSETSEL,0,Cast(LPARAM,@chrg))
				SendMessage(ah.hred,EM_GETSELTEXT,0,Cast(LPARAM,@buffer))
				If buffer=Chr(9) Then
					SendMessage(ah.hred,EM_REPLACESEL,TRUE,Cast(LPARAM,StrPtr("")))
					If lnCnt>0 Or chrg.cpMin<ochrg.cpMax Then
						ochrg.cpMax-=1
						If LnCnt=0 And chrg.cpMin<=ochrg.cpMin Then
							ochrg.cpMin-=1
						EndIf
					EndIf
				Else
					tmp=edtopt.tabsize
					While tmp
						chrg.cpMax=chrg.cpMin+tmp
						SendMessage(ah.hred,EM_EXSETSEL,0,Cast(LPARAM,@chrg))
						SendMessage(ah.hred,EM_GETSELTEXT,0,Cast(LPARAM,@buffer))
						If buffer=Space(tmp) Then
							SendMessage(ah.hred,EM_REPLACESEL,TRUE,Cast(LPARAM,StrPtr("")))
							If lnCnt>0 Or chrg.cpMax<=ochrg.cpMax Then
								ochrg.cpMax-=tmp
								If LnCnt=0 And chrg.cpMin<=ochrg.cpMin Then
									ochrg.cpMin-=tmp
								EndIf
							ElseIf chrg.cpMax>ochrg.cpMax Then
								ochrg.cpMin=SendMessage(ah.hred,EM_LINEINDEX,LnSt,0)
								ochrg.cpMax=ochrg.cpMin
							EndIf
							Exit While
						EndIf
						tmp=tmp-1
					Wend
				EndIf
			Else
				' Uncomment
				buffer=Chr(127) & Chr(0)
				n=SendMessage(ah.hred,EM_GETLINE,LnSt,Cast(LPARAM,@buffer))
				buffer[n]=0
				For tmp=0 To 127
					If buffer[tmp]<>VK_SPACE And buffer[tmp]<>VK_TAB And buffer[tmp]<>Asc("'") Then
						Exit For
					ElseIf buffer[tmp]=Asc("'") Then
						chrg.cpMin=SendMessage(ah.hred,EM_LINEINDEX,LnSt,0)+tmp
						chrg.cpMax=chrg.cpMin+1
						SendMessage(ah.hred,EM_EXSETSEL,0,Cast(LPARAM,@chrg))
						SendMessage(ah.hred,EM_REPLACESEL,TRUE,Cast(LPARAM,StrPtr("")))
						If lnCnt>0 Or chrg.cpMin<ochrg.cpMax Then
							ochrg.cpMax-=1
							If LnCnt=0 And chrg.cpMin<=ochrg.cpMin Then
								ochrg.cpMin-=1
							EndIf
						EndIf
						Exit For
					EndIf
				Next
			EndIf
		Else
			' Comment or Indent
			chrg.cpMin=SendMessage(ah.hred,EM_LINEINDEX,LnSt,0)
			chrg.cpMax=chrg.cpMin
			SendMessage(ah.hred,EM_EXSETSEL,0,Cast(LPARAM,@chrg))
			If char=Chr(9) Then
				' Indent
				If edtopt.expand Then
					buffer=Space(edtopt.tabsize)
					SendMessage(ah.hred,EM_REPLACESEL,TRUE,Cast(LPARAM,@buffer))
					ochrg.cpMax+=edtopt.tabsize
					If LnCnt=0 Then
						ochrg.cpMin+=edtopt.tabsize
					EndIf
				Else
					SendMessage(ah.hred,EM_REPLACESEL,TRUE,Cast(LPARAM,@char))
					ochrg.cpMax+=1
					If LnCnt=0 Then
						ochrg.cpMin+=1
					EndIf
				EndIf
			Else
				' Comment
				bm=SendMessage(ah.hred,REM_GETBOOKMARK,LnSt,0)
				If bm=BMT_COLLAPSE Or bm=BMT_EXPAND Then
					SendMessage(ah.hred,REM_SETBOOKMARK,LnSt,BMT_NONE)
					SendMessage(ah.hred,REM_SETDIVIDERLINE,LnSt,FALSE)
				EndIf
				buffer=Chr(127) & Chr(0)
				n=SendMessage(ah.hred,EM_GETLINE,LnSt,Cast(LPARAM,@buffer))
				buffer[n]=0
				n=0
				For tmp=0 To 127
					If buffer[tmp]=VK_SPACE Then
						n+=1
					ElseIf buffer[tmp]=VK_TAB Then
						n+=edtopt.tabsize
						n=(n\edtopt.tabsize)*edtopt.tabsize
					ElseIf buffer[tmp]=0 Then
						n=999
						Exit For
					Else
						Exit For
					EndIf
				Next
				If n<nmin Then
					nmin=n
				EndIf
			EndIf
		EndIf
		LnSt=LnSt+1
	Loop
	If fUn=0 And char="'" Then
		' Comment
		chrg.cpMin=ochrg.cpMin
		chrg.cpMax=ochrg.cpMax
		LnSt=SendMessage(ah.hred,EM_EXLINEFROMCHAR,0,chrg.cpMin)
		If chrg.cpMax>chrg.cpMin Then
			chrg.cpMax=chrg.cpMax-1
		EndIf
		LnEn=SendMessage(ah.hred,EM_EXLINEFROMCHAR,0,chrg.cpMax)
		LnCnt=LnEn-LnSt
		Do While LnSt<=LnEn
			buffer=String(128,0)
			buffer=Chr(127) & Chr(0)
			n=SendMessage(ah.hred,EM_GETLINE,LnSt,Cast(LPARAM,@buffer))
			buffer[n]=0
			n=0
			For tmp=0 To 127
				If n=nmin Then
					chrg.cpMin=SendMessage(ah.hred,EM_LINEINDEX,LnSt,0)+tmp
					chrg.cpMax=chrg.cpMin
					SendMessage(ah.hred,EM_EXSETSEL,0,Cast(LPARAM,@chrg))
					SendMessage(ah.hred,EM_REPLACESEL,TRUE,Cast(LPARAM,@char))
					If lnCnt>0 Or chrg.cpMin<ochrg.cpMax Then
						ochrg.cpMax+=1
						If LnCnt=0 And chrg.cpMin<=ochrg.cpMin Then
							ochrg.cpMin+=1
						EndIf
					EndIf
					Exit For
				EndIf
				If buffer[tmp]=VK_SPACE Then
					n+=1
				ElseIf buffer[tmp]=VK_TAB Then
					n+=edtopt.tabsize
					n=(n\edtopt.tabsize)*edtopt.tabsize
				ElseIf buffer[tmp]=0 Then
					Exit For
				EndIf
			Next
			LnSt=LnSt+1
		Loop
	EndIf
	SendMessage(ah.hred,EM_EXSETSEL,0,Cast(LPARAM,@ochrg))
	SendMessage(ah.hred,EM_HIDESELECTION,FALSE,0)
	SendMessage(ah.hred,REM_LOCKUNDOID,FALSE,0)
	'SendMessage(ah.hred,WM_SETREDRAW,TRUE,0)
	'SendMessage(ah.hred,REM_REPAINT,0,0)
	SetFocus(ah.hred)
	ad.fNoNotify=x

End Sub

Sub AutoBrace(ByVal hWin As HWND,ByVal nChr As Integer)
	Dim chrg As CHARRANGE
	Dim i As Integer

	Select Case nChr
		Case Asc("(")
			i=Asc(")")
		Case Asc("{")
			i=Asc("}")
		Case Asc("[")
			i=Asc("]")
	    Case Asc(!"\"")
		    i=Asc(!"\"")
	End Select
	SendMessage(hWin,EM_EXGETSEL,0,Cast(Integer,@chrg))
	SendMessage(hWin,WM_CHAR,i,0)
	SendMessage(hWin,EM_EXSETSEL,0,Cast(Integer,@chrg))
	SendMessage(hWin,EM_SCROLLCARET,0,0)

End Sub

Sub CaseConvertWord(ByVal hWin As HWND,ByVal cp As Integer)
	Dim lret As ZString Ptr

	If SendMessage(hWin,REM_ISCHARPOS,cp,0)=0 Then
		SendMessage(hWin,REM_SETCHARTAB,Asc("."),CT_CHAR)
		If SendMessage(hWin,REM_GETWORDFROMPOS,cp,Cast(LPARAM,@buff)) Then
			lret=FindExact(@szCaseConvert,@buff,FALSE)
			If lret Then
				lstrcpy(@buff,lret)
				If edtopt.autocase=2 Then
                    CharLower buff                         ' MOD 30.1.2012      buff=LCase(buff)
				ElseIf edtopt.autocase=3 Then
					CharUpper buff                         ' MOD 30.1.2012      buff=UCase(buff)
				EndIf
				SendMessage(hWin,REM_CASEWORD,cp,Cast(LPARAM,@buff))
				SendMessage(hWin,REM_INVALIDATELINE,SendMessage(hWin,EM_LINEFROMCHAR,cp,0),0)
			ElseIf Right(buff,1)="." Then
				cp-=1
				buff[Len (buff) - 1] = 0                   ' MOD 1.3.2012     buff=Left(buff,Len(buff)-1)
				lret=FindExact(StrPtr("n"),@buff,FALSE)
				If lret Then
					lstrcpy(@buff,lret)
					SendMessage(hWin,REM_CASEWORD,cp,Cast(LPARAM,@buff))
					SendMessage(hWin,REM_INVALIDATELINE,SendMessage(hWin,EM_LINEFROMCHAR,cp,0),0)
				EndIf
			EndIf
		EndIf
		SendMessage(hWin,REM_SETCHARTAB,Asc("."),CT_HICHAR)
	EndIf

End Sub

Sub CaseConvertWordFromList(ByVal hWin As HWND,ByVal cp As Integer,ByVal hMem As HGLOBAL,ByVal nCount As Integer)
	Dim lret As ZString Ptr
	Dim lp As Integer
	Dim chrg As CHARRANGE
	Dim ms As MEMSEARCH

	If SendMessage(hWin,REM_ISCHARPOS,cp,0)=0 Then
		If SendMessage(hWin,REM_GETWORDFROMPOS,cp,Cast(LPARAM,@buff)) Then
			ms.lpMem=hMem
			ms.lpFind=@buff
			lp=SendMessage(ah.hpr,PRM_FINDINSORTEDLIST,nCount,Cast(LPARAM,@ms))
			If lp>0 Then
				lp=Cast(Integer,hMem)+lp*4
				lret=Cast(ZString Ptr,Peek(Integer,lp))
				lstrcpy(@buff,lret)
				If edtopt.autocase=2 Then
					CharLower buff                         'MOD 30.1.2012      buff=LCase(buff)
				ElseIf edtopt.autocase=3 Then
					CharUpper buff                         'MOD 30.1.2012      buff=UCase(buff)
				EndIf
				SendMessage(hWin,REM_CASEWORD,cp,Cast(LPARAM,@buff))
			EndIf
		EndIf
	EndIf

End Sub

Sub CaseConvert(ByVal hWin As HWND)
	Dim chrg As CHARRANGE
	Dim tmpchrg As CHARRANGE
	Dim lp As Integer
	Dim hCur As HCURSOR
	Dim hMem As HGLOBAL
	Dim nCount As Integer

	hCur=GetCursor
    ShowCursor FALSE
	SetCursor(LoadCursor(NULL,IDC_WAIT))
	ShowCursor TRUE
	SendMessage(hWin,REM_SETCHARTAB,Asc("."),CT_CHAR)
	hMem=Cast(HGLOBAL,SendMessage(ah.hpr,PRM_GETSORTEDLIST,Cast(WPARAM,@szCaseConvert),Cast(LPARAM,@nCount)))
	SendMessage(hWin,EM_EXGETSEL,0,Cast(LPARAM,@chrg))
	If chrg.cpMin=chrg.cpMax Then
		tmpchrg.cpMin=0
		tmpchrg.cpMax=-1
		While tmpchrg.cpMin<10000000 And tmpchrg.cpMin<>tmpchrg.cpMax
			tmpchrg.cpMax=tmpchrg.cpMin
			CaseConvertWordFromList(hWin,tmpchrg.cpMin,hMem,nCount)
			tmpchrg.cpMin=SendMessage(hWin,EM_FINDWORDBREAK,WB_MOVEWORDRIGHT,tmpchrg.cpMin+1)
		Wend
	Else
		tmpchrg.cpMin=chrg.cpMin
		tmpchrg.cpMax=-1
		While tmpchrg.cpMin<=chrg.cpMax And tmpchrg.cpMin<>tmpchrg.cpMax
			tmpchrg.cpMax=tmpchrg.cpMin
			CaseConvertWordFromList(hWin,tmpchrg.cpMin,hMem,nCount)
			tmpchrg.cpMin=SendMessage(hWin,EM_FINDWORDBREAK,WB_MOVEWORDRIGHT,tmpchrg.cpMin+1)
		Wend
	EndIf
	SendMessage(hWin,REM_SETCHARTAB,Asc("."),CT_HICHAR)
	SendMessage(hWin,REM_REPAINT,0,0)
	GlobalFree(hMem)
	SendMessage(hWin,EM_SETMODIFY,TRUE,0)
	ShowCursor FALSE
	SetCursor(hCur)
    ShowCursor TRUE
End Sub

Function GetIndent(ByVal hWin As HWND,ByVal ln As Integer,ByVal lpszBlockSt As ZString Ptr,ByVal lpErr As Integer Ptr) As String
	Dim lx As Integer = Any
	Dim lz As Integer = Any
	Dim szIndent As ZString*1024

	*lpErr = 1                                                ' MOD  Poke Integer,lpErr,1
	lx=ln+1
	lz=0
	While lx<>-1
		lz=lx
		lx=SendMessage(hWin,REM_PRVBOOKMARK,lx,BMT_COLLAPSE)
		lz=SendMessage(hWin,REM_PRVBOOKMARK,lz,BMT_EXPAND)
		If lz>lx Then
			lx=lz
		EndIf
		If lx>=0 Then
			lz=SendMessage(hWin,REM_GETBLOCKEND,lx,0)
			If lz>=ln Then
				If SendMessage(hWin,REM_ISLINE,lx,Cast(LPARAM,lpszBlockSt))>=0 Then
					' Get indent
					GetLineByNo hWin, lx, @szIndent           ' MOD 21.1.2012
					'szIndent=Chr(255) & Chr(1)
					'lx=SendMessage(hWin,EM_GETLINE,lx,Cast(LPARAM,@szIndent))
					'szIndent[lx]=NULL

                	'======================
                	' MOD 21.1.2012
                	lz=0
                	Do
                	    Select Case szIndent[lz]
                	    Case VK_SPACE, VK_TAB
                	        lz += 1
                	    Case Else
                	        szIndent[lz] = NULL
                	        *lpErr = 0
                	        Exit Do
                	    End Select
                	Loop
					'lz=1
					'While lz<=lx
					'	If Asc(szIndent,lz)<>VK_SPACE And Asc(szIndent,lz)<>VK_TAB Then
					'		szIndent[lz-1]=NULL
					'		Poke Integer,lpErr,0
					'		Exit While
					'	EndIf
					'	lz=lz+1
					'Wend
                	'======================
				EndIf
				Exit While
			ElseIf lz=-1 Then
				Exit While
			EndIf
		EndIf
	Wend
	Return szIndent

End Function

Function SetIndent(ByVal hWin As HWND,ByVal ln As Integer,ByVal lpszIndent As ZString Ptr) As Integer
	Dim szIndent As ZString*1024
	'Dim lx As Integer
	Dim lz As Integer = Any
	Dim chrg As CHARRANGE
	Dim x As Integer  = Any

	' Get indent
	x=ad.fNoNotify
	ad.fNoNotify=TRUE
    GetLineByNo hWin, ln, @szIndent           ' MOD 21.1.2012
	'szIndent=Chr(255) & Chr(1)
	'lx=SendMessage(hWin,EM_GETLINE,ln,Cast(LPARAM,@szIndent))
	'szIndent[lx]=NULL

	'======================
	' MOD 21.1.2012
	lz=0
	Do
	    Select Case szIndent[lz]
	    Case VK_SPACE, VK_TAB
	        lz += 1
	    Case Else
	        szIndent[lz] = NULL
	        Exit Do
	    End Select
	Loop
	'lz=1
	'While lz<=lx
	'	If Asc(szIndent,lz)<>VK_SPACE And Asc(szIndent,lz)<>VK_TAB Then
	'		szIndent[lz-1]=NULL
	'		Exit While
	'	EndIf
	'	lz=lz+1
	'Wend
	'======================
	chrg.cpMin=SendMessage(hWin,EM_LINEINDEX,ln,0)
	chrg.cpMax = chrg.cpMin + lz                   ' MOD lz is now zerobased
	'chrg.cpMax=chrg.cpMin+lz-1
	If lstrcmp(@szIndent,lpszIndent) Then
		SendMessage(hWin,EM_EXSETSEL,0,Cast(LPARAM,@chrg))
		SendMessage(hWin,EM_REPLACESEL,TRUE,Cast(LPARAM,lpszIndent))
		lz=Len(szIndent)-Len(*lpszIndent)
	Else
		chrg.cpMin=chrg.cpMax
		SendMessage(hWin,EM_EXSETSEL,0,Cast(LPARAM,@chrg))
		SendMessage(hWin,EM_SCROLLCARET,0,0)
		lz=0
	EndIf
	ad.fNoNotify=x
	Return lz

End Function

Function AddIndent(ByVal n As Integer,ByVal lpszIndent As ZString Ptr) As String

    ' MOD 1.3.2012
    If edtopt.expand Then
		Return *lpszIndent + Space (n * edtopt.tabsize)
	Else
		Return *lpszIndent + String (n, VK_TAB)
	EndIf

	'Dim szIndent As ZString*1024
	'lstrcpy(@szIndent,lpszIndent)
	'If edtopt.expand Then
	'	szIndent=szIndent & Space(n*edtopt.tabsize)
	'Else
	'	szIndent=szIndent & String(n,Chr(VK_TAB))
	'EndIf
	'Return szIndent

End Function

Sub FormatIndent(ByVal hWin As HWND)
	Dim wp As Integer
	Dim lz As Integer
	Dim ln As Integer
	Dim lm As Integer
	Dim chrg As CHARRANGE
	Dim lnst As Integer
	Dim lntop As Integer
	Dim hCur As HCURSOR
	Dim fAsm As Integer

	' Indent / Outdent
	lstpos.fnohandling=1
	hCur=GetCursor
    ShowCursor FALSE
	SetCursor(LoadCursor(NULL,IDC_WAIT))
	ShowCursor TRUE
	SendMessage(hWin,WM_SETREDRAW,FALSE,0)
	lntop=SendMessage(hWin,EM_GETFIRSTVISIBLELINE,0,0)
	SendMessage(hWin,EM_EXGETSEL,0,Cast(LPARAM,@chrg))
	lnst=SendMessage(hWin,EM_LINEFROMCHAR,chrg.cpMin,0)
	SendMessage(hWin,REM_LOCKUNDOID,TRUE,0)
	lm=SendMessage(hWin,EM_GETLINECOUNT,0,0)
	ln=0
    SetZStrEmpty (buff)             'MOD 26.1.2012
	While ln<=lm
		wp=0
		If fAsm Then
			wp=fAsm
		EndIf
		While wp<(MAXBLOCKDEFS-2)
			If szIndent(wp)<>szNULL Then
				If SendMessage(hWin,REM_ISLINE,ln,Cast(LPARAM,@szIndent(wp)))>=0 Then
					If UCase(szIndent(wp))="ASM" Then
						fAsm=wp
					ElseIf UCase(szIndent(wp))="END ASM" Then
						fAsm=0
					EndIf
					' Get current indent
					lz=0
					s=buff
					buff=GetIndent(hWin,ln,@szIndent(autofmt(wp).st),@lz)
					If lz=0 Then
						If wp=autofmt(wp).st Then
							buff=s
						EndIf
						' Indent word line
						buff=AddIndent(autofmt(wp).add1,@buff)
						SetIndent(hWin,ln,@buff)
						' Indent caret line
						buff=AddIndent(autofmt(wp).add2,@buff)
						Exit While
					EndIf
				EndIf
			EndIf
			wp=wp+1
		Wend
		If wp=(MAXBLOCKDEFS-2) Then
			lz=SendMessage(hWin,EM_LINEINDEX,ln,0)
			If SendMessage(hWin,REM_ISCHARPOS,lz,0)<>1 Then
				SetIndent(hWin,ln,@buff)
			EndIf
		EndIf
		SendMessage(hWin,REM_TRIMSPACE,ln,0)
		ln=ln+1
	Wend
	SendMessage(hWin,REM_LOCKUNDOID,FALSE,0)
	chrg.cpMin=0
	chrg.cpMax=0
	SendMessage(hWin,EM_EXSETSEL,0,Cast(LPARAM,@chrg))
	SendMessage(hWin,EM_SCROLLCARET,0,0)
	SendMessage(hWin,EM_LINESCROLL,0,lntop)
	chrg.cpMin=SendMessage(hWin,EM_LINEINDEX,lnst,0)
	chrg.cpMax=chrg.cpMin
	SendMessage(hWin,EM_EXSETSEL,0,Cast(LPARAM,@chrg))
	SendMessage(hWin,EM_SCROLLCARET,0,Cast(LPARAM,@chrg))
	SendMessage(hWin,WM_SETREDRAW,TRUE,0)
	SendMessage(hWin,REM_REPAINT,0,0)
	SendMessage(hWin,EM_SCROLLCARET,0,0)
	ShowCursor FALSE
	SetCursor(hCur)
	ShowCursor TRUE
	lstpos.fnohandling=0

End Sub

Sub TestCaseConvert(ByVal hWin As HWND,ByVal wParam As Integer)
	Dim chrg As CHARRANGE

	If edtopt.autocase<>0 And wParam<>VK_BACK Then
		If Peek(Byte,ad.lpCharTab+wParam)<>1 Then
			If prechrg.cpMin=prechrg.cpMax Then
				SendMessage(hWin,EM_EXGETSEL,0,Cast(LPARAM,@chrg))
				SendMessage(hWin,EM_EXSETSEL,0,Cast(LPARAM,@prechrg))
				CaseConvertWord(hWin,prechrg.cpMin)
				SendMessage(hWin,EM_EXSETSEL,0,Cast(LPARAM,@chrg))
			EndIf
		EndIf
	EndIf

End Sub


Function AutoFormatLine(ByVal hWin As HWND,ByVal lpchrg As CHARRANGE Ptr) As Integer
	Dim chrg As CHARRANGE
	Dim ln As Integer
	Dim lz As Integer = 0
	Dim wp As Integer

	If edtopt.autoformat Then
		' Indent / Outdent
		If lpchrg=0 Then
			SendMessage(hWin,EM_EXGETSEL,0,Cast(LPARAM,@chrg))
			ln = SendMessage (hWin, EM_LINEFROMCHAR, chrg.cpMin, 0)
            If ln > 0 Then ln -= 1
		Else
			chrg=*lpchrg
			ln=SendMessage(hWin,EM_LINEFROMCHAR,chrg.cpMin,0)
		EndIf
		wp=0
		While wp<(MAXBLOCKDEFS)
			If szIndent(wp)<>szNULL Then
				If SendMessage(hWin,REM_ISLINE,ln,Cast(LPARAM,@szIndent(wp)))>=0 Then
					' Get current indent
					lz=0
					buff=GetIndent(hWin,ln,@szIndent(autofmt(wp).st),@lz)
					If lz=0 Then
						' Indent word line
						lz=Len(buff)
						buff=AddIndent(autofmt(wp).add1,@buff)
						lz-=Len(buff)
						lz=SetIndent(hWin,ln,@buff)
						If lpchrg=0 Then
							' Indent caret line
							buff=AddIndent(autofmt(wp).add2,@buff)
							SetIndent(hWin,ln+1,@buff)
						EndIf
						Exit While
					EndIf
				EndIf
			EndIf
			wp+=1
		Wend
	EndIf
	Return lz

End Function

Function SmartMath(ByVal hWin As HWND,ByVal nChr As Integer) As Integer
	Dim trng As TEXTRANGE

	If nChr=Asc("+") Or nChr=Asc("-") Or nChr=Asc("*") Or nChr=Asc("/") Or nChr=Asc("\") Then
		SendMessage(hWin,EM_EXGETSEL,0,Cast(LPARAM,@trng.chrg))
		trng.chrg.cpMin-=1
		trng.lpstrText=@buff
		SendMessage(hWin,EM_GETTEXTRANGE,0,Cast(LPARAM,@trng))
		If Asc(buff)=nChr Then
			SendMessage(hWin,EM_REPLACESEL,0,Cast(LPARAM,StrPtr("=")))
			Return TRUE
		EndIf
	EndIf
	Return FALSE

End Function

Sub CodeComplete(ByVal hWin As HWND)
	Dim chrg As CHARRANGE
	Dim i As Integer
	Dim buff As ZString*512

	' Update edit from code complete list
	SendMessage(hWin,EM_EXGETSEL,0,Cast(Integer,@chrg))
	i=SendMessage(hWin,EM_EXLINEFROMCHAR,0,chrg.cpMax)
	chrg.cpMin=SendMessage(hWin,EM_LINEINDEX,i,0)
	GetLineByNo hWin, i, @buff           ' MOD 21.1.2012
	'buff=Chr(255) & Chr(1)
	'i=SendMessage(hWin,EM_GETLINE,i,Cast(LPARAM,@buff))
	'buff[i]=NULL
	If fincliblist Or fincludelist Then
		SendMessage(ah.hout,REM_SETCHARTAB,Asc("."),CT_CHAR)
		SendMessage(ah.hout,REM_SETCHARTAB,Asc("\"),CT_CHAR)
		SendMessage(ah.hpr,PRM_GETWORD,chrg.cpMax-chrg.cpMin,Cast(LPARAM,@buff))
		SendMessage(ah.hout,REM_SETCHARTAB,Asc("."),CT_HICHAR)
		SendMessage(ah.hout,REM_SETCHARTAB,Asc("\"),CT_OPER)
		chrg.cpMin=chrg.cpMax-Len(buff)
	Else
		SendMessage(ah.hpr,PRM_GETWORD,chrg.cpMax-chrg.cpMin,Cast(LPARAM,@buff))
		chrg.cpMin=chrg.cpMax-Len(buff)
		SendMessage(hWin,REM_GETWORD,256,Cast(LPARAM,@buff))
		chrg.cpMax=chrg.cpMin+Len(buff)
	EndIf
	i=SendMessage(ah.hcc,CCM_GETITEM,SendMessage(ah.hcc,CCM_GETCURSEL,0,0),0)
	If i Then
		SendMessage(hWin,EM_EXSETSEL,0,Cast(LPARAM,@chrg))
		lstrcpy(@buff,Cast(ZString Ptr,i))
		i=InStr(buff,":")
		If i Then
			buff[i-1]=NULL
		EndIf
		If fincliblist Or fincludelist Then
			buff &=Chr(34)
		EndIf
		SendMessage(hWin,EM_REPLACESEL,TRUE,Cast(LPARAM,@buff))
	EndIf
	If fconstlist=FALSE Then
		HideCCLists()
	Else
		ShowWindow(ah.hcc,SW_HIDE)
	EndIf

End Sub

Function ReplaceType(ByVal lpProc As ZString Ptr,ByVal nOwner As Integer,ByVal nLine As Integer) As Boolean
	'Dim x As Integer
	'Dim y As Integer
	Dim lret As ZString Ptr
	Dim sItem As ZString*256
	Dim sTest As ZString*256

	sItem=buff
	If Asc(sItem)=Asc(".") Then
		lret=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_ISINWITHBLOCK,nOwner,nLine))
		If lret Then
			lstrcpy(@sTest,lret)
		EndIf
		sItem=sTest & sItem
		buff=sItem
	EndIf
	s=sItem
	sItem=Left(buff,InStr(buff,".")-1)
	If lpProc Then
		lpProc=lpProc+Len(*lpProc)+1
		sTest=sItem
		SendMessage(ah.hpr,PRM_FINDITEMDATATYPE,Cast(Integer,@sTest),Cast(Integer,lpProc))
		If IsZStrEmpty (sTest) Then
			lpProc=lpProc+Len(*lpProc)+1
			sTest=sItem
			SendMessage(ah.hpr,PRM_FINDITEMDATATYPE,Cast(Integer,@sTest),Cast(Integer,lpProc))
		EndIf
		If IsZStrNotEmpty (sTest) Then
			If FindExact(StrPtr("s"),@sTest,TRUE) Then
				buff=sTest & Mid(buff,InStr(buff,"."))
				Return TRUE
			EndIf
		EndIf
	EndIf
	lret=FindExact(StrPtr("d"),@sItem,TRUE)
	If lret Then
		lret=lret+Len(*lret)+1
		lstrcpy(@sItem,lret)
		If FindExact(StrPtr("s"),@sItem,TRUE) Then
			buff=sTest & Mid(buff,InStr(buff,"."))
			Return TRUE
		EndIf
	EndIf
	Return FALSE

End Function

Function CoTxEdProc (ByVal hWin As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As Integer
	Dim pt As Point
	Dim rect As RECT
	Dim lret As Integer
	Dim ln As Integer
	Dim lp As Integer
	Dim wp As Integer
	Dim lx As Integer
	Dim chrg As CHARRANGE
	Dim chrg1 As CHARRANGE
	Dim tti As TTITEM
	Dim tt As TOOLTIP
	Dim hMnu As HMENU
	Dim trng As TEXTRANGE
	Dim hPar As HWND
	Dim p As ZString Ptr
	Dim ft As FINDTEXTEX
	Dim tp As Integer
	Dim lz As Integer
	Dim isinp As ISINPROC
	Dim buffer As ZString*256
	Dim Path   As ZString * MAX_PATH
	Dim i As Integer
	Dim fnoret As Integer
    Dim hPrevCur As HCURSOR = Any
	Static OldPt          As Point
	Static LButtonUPCount As UInteger
	Static TimerRunning   As UINT

	'Print uMsg;" ";
	Select Case uMsg
		Case WM_CHAR
			hPar=GetParent(hWin)          ' ah.hred
			If SendMessage(hPar,REM_GETMODE,0,0)=0 Then				' Mode Normal
				If wParam=VK_ESCAPE Then
					ShowWindow(ah.htt,SW_HIDE)
					HideCCLists()
					Return 0
				ElseIf wParam=VK_TAB Or wParam=VK_RETURN Then
					If IsWindowVisible(ah.hcc) Then
						CodeComplete(hPar)
						Return 0
					EndIf
				EndIf

				SendMessage(hPar,EM_EXGETSEL,0,Cast(LPARAM,@prechrg))
				If wParam=VK_TAB Then                               ' Indent / Outdent
					If (GetKeyState(VK_SHIFT) And &H80)<>0 Then
						SendMessage(ah.hwnd,WM_COMMAND,IDM_EDIT_BLOCKOUTDENT,0)
						Return 0
					Else
						If prechrg.cpMin<>prechrg.cpMax Then
							SendMessage(ah.hwnd,WM_COMMAND,IDM_EDIT_BLOCKINDENT,0)
							Return 0
						EndIf
					EndIf
					Return CallWindowProc(lpOldCoTxEdProc,hWin,uMsg,wParam,lParam)
				EndIf

				If SendMessage(hPar,REM_GETWORDGROUP,0,0)=0 Then
					' Code edit
					If wParam=VK_SPACE And (GetKeyState(VK_CONTROL) And &H80)<>0 Then
						Return 0
					EndIf
					i=SendMessage(hPar,REM_ISCHARPOS,prechrg.cpMin,0)
					Select Case i
						Case 0		' Normal
							If edtopt.autobrace then
								If     wParam=Asc("(") _
								OrElse wParam=Asc("{") _
								OrElse wParam=Asc("[") _
								OrElse wParam=Asc(!"\"") Then
									' Auto brace
									lret=CallWindowProc(lpOldCoTxEdProc,hWin,uMsg,wParam,lParam)
									TestCaseConvert(hPar,wParam)
									AutoBrace(hPar,wParam)
									Return lret
								EndIf
							EndIf
							If edtopt.smartmath Then
									' Smart maths
								If SmartMath(hPar,wParam) Then
									Return 0
								EndIf
							EndIf
							If wParam=VK_BACK Then
								trng.chrg=prechrg
								If trng.chrg.cpMin>0 And trng.chrg.cpMin=trng.chrg.cpMax Then
									' Get the deleted character
									trng.chrg.cpMin-=1
									trng.lpstrText=@buff
									SendMessage(hPar,EM_GETTEXTRANGE,0,Cast(LPARAM,@trng))
									Select Case As Const buff[0]
										Case Asc("."),Asc(","),Asc("("),Asc(">")
											HideCCLists()
											ShowWindow(ah.htt,SW_HIDE)
										Case 34
											HideCCLists()
											ShowWindow(ah.htt,SW_HIDE)
											If edtopt.autoinclude Then
												trng.chrg.cpMin=SendMessage(hPar,EM_LINEINDEX,SendMessage(hPar,EM_EXLINEFROMCHAR,0,trng.chrg.cpMax),0)
												trng.chrg.cpMax-=1
												SendMessage(hPar,EM_GETTEXTRANGE,0,Cast(LPARAM,@trng))
												lp=InStr(buff,Chr(34))
												lp=InStr(lp+1,buff,Chr(34))
												CharLower buff
												If InStr(buff,"#include")<>0 And lp=0 Then
													buff=Mid(buff,InStr(buff,Chr(34))+1)
													'reset last dir
													DirList = ""
												    If IsZStrNotEmpty (ad.FbcIncPath) Then
    													BuildDirList(ad.FbcIncPath,NULL,6)
												    EndIf
													If fProject Then
														BuildDirList(ad.ProjectPath,NULL,7)
													Else
													    Path = ad.filename
													    PathRemoveFileSpec @Path
													    BuildDirList(Path,NULL,7)
													EndIf
													DirListLCase = DirList
	                                                CharLower StrPtr (DirListLCase)
													UpdateIncludeList()
													Return CallWindowProc(lpOldCoTxEdProc,hWin,uMsg,wParam,lParam)
												ElseIf InStr(buff,"#inclib")<>0 And lp=0 Then
													buff=Mid(buff,InStr(buff,Chr(34))+1)
													'reset last dir
													DirList = ""
												    If IsZStrNotEmpty (ad.FbcLibPath) Then
    													BuildDirList(ad.FbcLibPath,NULL,8)
                                                    EndIf
													If fProject Then
														BuildDirList(ad.ProjectPath,NULL,9)
													Else
													    Path = ad.filename
													    PathRemoveFileSpec @Path
													    BuildDirList(Path,NULL,9)
													EndIf
													DirListLCase = DirList
	                                                CharLower StrPtr (DirListLCase)
													UpdateInclibList()
													Return CallWindowProc(lpOldCoTxEdProc,hWin,uMsg,wParam,lParam)
												EndIf
											EndIf
									End Select
								EndIf
							EndIf
						Case 3		' String
							lret=CallWindowProc(lpOldCoTxEdProc,hWin,uMsg,wParam,lParam)
							If fincludelist Or fincliblist Then
								If wParam=34 Then
									HideCCLists()
								Else
									GetLineUpToCaret hPar, @buff, 0
									i=InStr(buff,Chr(34))
									If i Then
										buff=Mid(buff,i+1)
										CharLower buff
										If fincludelist Then
											UpdateIncludeList()
										ElseIf fincliblist Then
											UpdateInclibList()
										EndIf
									Else
										HideCCLists()
									EndIf
								EndIf
							EndIf
							Return lret
						Case Else	' Comment or Comment Block
							Return CallWindowProc(lpOldCoTxEdProc,hWin,uMsg,wParam,lParam)
					End Select
					If IsWindowVisible(ah.hcc) Then
						If wParam=Asc(".") Then
							trng.chrg=prechrg
							trng.chrg.cpMin-=1
							trng.lpstrText=@buff
							SendMessage(hPar,EM_GETTEXTRANGE,0,Cast(LPARAM,@trng))
							If SendMessage(ah.hcc,CCM_GETCOUNT,0,0)<=1 Then
								HideCCLists
							ElseIf buff[0]=Asc(".") Then
								Return 0
							EndIf
						'ElseIf wParam=VK_SPACE Then
						'	Print "Hide"
						'	HideList
						'	Return CallWindowProc(lpOldCoTxEdProc,hWin,uMsg,wParam,lParam)
						EndIf
					EndIf
					If wParam=VK_SPACE Or wParam=VK_TAB Or wParam=Asc("(") Or wParam=Asc(",") Or wParam=VK_BACK Or fmessagelist<>0 Or fenumlist<>0 Then
						lret=CallWindowProc(lpOldCoTxEdProc,hWin,uMsg,wParam,lParam)
						TestCaseConvert(hPar,wParam)
					  TT:
						SendMessage(hPar,EM_EXGETSEL,0,Cast(LPARAM,@prechrg))
						ShowWindow(ah.htt,SW_HIDE)
						TestCaseConvert(hPar,wParam)
						chrg=prechrg
						GetLineUpToCaret hPar, @buff, 0
						'lp=SendMessage(hPar,EM_EXLINEFROMCHAR,0,chrg.cpMax)
						'chrg.cpMin=SendMessage(hPar,EM_LINEINDEX,lp,0)
						'buff=Chr(255) & Chr(1)
						'SendMessage(hPar,EM_GETLINE,lp,Cast(LPARAM,@buff))
						'buff[chrg.cpMax-chrg.cpMin]=NULL
						buff = LTrim (buff, Any WHITESPACE)       ' MOD 15.1.2012
						tt.lpszType=StrPtr("Ppt")
						tt.lpszLine=@buff
						SendMessage(ah.hout,REM_SETCHARTAB,Asc("."),CT_CHAR)
						' Is line function or sub
						lx=SendMessage(hPar,REM_ISLINE,lp,Cast(LPARAM,@szST(0)))
						If lx=-1 Then
							lx=SendMessage(hPar,REM_ISLINE,lp,Cast(LPARAM,@szST(1)))
						EndIf
						If SendMessage(ah.hpr,PRM_GETTOOLTIP,TT_NOMATCHCASE Or TT_PARANTESES,Cast(LPARAM,@tt))<>0 And (InStr(buff,"(")<>0 Or InStr(buff," ")<>0) And lx=-1 Then
							If ShowTooltip(hWin,@tt)=FALSE Then
								If InStr(buff,".") Then
									buff=Mid(buff,InStr(buff,".")+1)
								EndIf
							EndIf
						Else
							If InStr(buff,".") And InStr(buff,".")<InStr(buff,"(") Then
								lp=SendMessage(hPar,EM_EXLINEFROMCHAR,0,chrg.cpMax)
								isinp.nLine=lp
								If fProject Then
									lx=GetFileIDByEditor(hPar)
								Else
									lx=Cast(Integer,hPar)
								EndIf
								isinp.nOwner=lx
								isinp.lpszType=StrPtr("pxyzo")
								p=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_ISINPROC,0,Cast(LPARAM,@isinp)))
								If ReplaceType(p,lx,lp) Then
									If SendMessage(ah.hpr,PRM_GETTOOLTIP,TT_NOMATCHCASE Or TT_PARANTESES,Cast(LPARAM,@tt)) Then
										s=Left(buff,InStr(buff,"(")-1)
										tt.lpszApi=@s
										ShowTooltip(hWin,@tt)
									Else
										' udt.sub( udt->sub(
										SendMessage(ah.hout,REM_SETCHARTAB,Asc("."),CT_HICHAR)
										If SendMessage(ah.hpr,PRM_GETTOOLTIP,TT_NOMATCHCASE Or TT_PARANTESES,Cast(LPARAM,@tt)) Then
											ShowTooltip(hWin,@tt)
										EndIf
									EndIf
								EndIf
							Else
								SendMessage(ah.hout,REM_SETCHARTAB,Asc("."),CT_HICHAR)
								GoTo	TestUpdate
							EndIf
						EndIf
						SendMessage(ah.hout,REM_SETCHARTAB,Asc("."),CT_HICHAR)
						Return lret
					ElseIf wParam=Asc(")") Then
						' Hide list and tooltip
						ShowWindow(ah.htt,SW_HIDE)
						HideCCLists
					EndIf
					If wParam=VK_RETURN Then
						lstpos.fnohandling=1
					EndIf
					lret=CallWindowProc(lpOldCoTxEdProc,hWin,uMsg,wParam,lParam)
					TestCaseConvert(hPar,wParam)
					SendMessage(hPar,EM_EXGETSEL,0,Cast(LPARAM,@prechrg))
					If (wParam=Asc(".") Or wParam=Asc(">")) And fconstlist=TRUE Then
						HideCCLists
					EndIf
				    TestUpdate:
					If (IsWindowVisible(ah.hcc) Or fconstlist) Then
						If fconstlist=TRUE Then
							GetLineByCaret(hPar,@buff,0)
							TrimWhiteSpace buff
							tt.lpszType=StrPtr("Pp")
							tt.lpszLine=@buff
							SendMessage(ah.hpr,PRM_GETTOOLTIP,TT_NOMATCHCASE Or TT_PARANTESES,Cast(LPARAM,@tt))
							' Show tooltip
							tti.lpszApi=tt.lpszApi
							tti.lpszParam=tt.ovr(0).lpszParam
							tti.lpszRetType=tt.ovr(0).lpszRetType
							tti.nitem=tt.nPos
							UpdateConstList(tti.lpszApi,tti.nitem+1)
						Else
							chrg=prechrg
							isinp.nLine=SendMessage(hPar,EM_EXLINEFROMCHAR,0,chrg.cpMax)
							If fProject Then
								isinp.nOwner=GetFileIDByEditor(hPar)
							Else
							    isinp.nOwner=Cast(Integer,hPar)
							EndIf
							isinp.lpszType=StrPtr("pxyzo")
							p=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_ISINPROC,0,Cast(LPARAM,@isinp)))
							If ftypelist Then
								If wParam=VK_SPACE Or wParam=VK_TAB Then
									HideCCLists
								Else
									UpdateTypeList
								EndIf
							ElseIf fstructlist Then
								UpdateStructList(p)
							Else
								UpdateList(p)
							EndIf
						EndIf
						' Move code complete list
						MoveList
					ElseIf wParam=Asc(".") And IsWindowVisible(ah.hcc)=FALSE And edtopt.codecomplete<>0 Then
						trng.chrg=prechrg
						fconstlist=FALSE
						IsStructList
					ElseIf wParam=Asc(">") And IsWindowVisible(ah.hcc)=FALSE And edtopt.codecomplete<>0 Then
						trng.chrg=prechrg
						trng.chrg.cpMin=trng.chrg.cpMin-2
						trng.lpstrText=@s
						SendMessage(hPar,EM_GETTEXTRANGE,0,Cast(LPARAM,@trng))
						If s="->" Then
							fconstlist=FALSE
							IsStructList
						EndIf
					ElseIf (wParam=VK_TAB Or wParam=VK_SPACE) And edtopt.codecomplete<>0 Then
						chrg=prechrg
						chrg.cpMin=chrg.cpMin-1
						chrg.cpMax=chrg.cpMax-1
						SendMessage(hPar,EM_EXSETSEL,0,Cast(LPARAM,@chrg))
						SendMessage(hPar,REM_GETWORD,256,Cast(LPARAM,@s))
						chrg.cpMin=chrg.cpMin+1
						chrg.cpMax=chrg.cpMax+1
						SendMessage(hPar,EM_EXSETSEL,0,Cast(LPARAM,@chrg))
						CharUpper s                         'MOD 30.1.2012      s=UCase(s)
						If s="AS" Then
							UpdateTypeList
							' Move code complete list
							MoveList
							ftypelist=TRUE
						EndIf
					ElseIf wParam=34 And edtopt.autoinclude Then
						GetLineByCaret(hPar,@s,0)
						CharLower s                         'MOD 30.1.2012      s=UCase(s)
						lp=InStr(s,Chr(34))
						lp=InStr(lp+1,s,Chr(34))
						If InStr(s,"#include")<>0 And lp=0 Then
							'reset last dir
							dirlist=""
						    If IsZStrNotEmpty (ad.FbcIncPath) Then
    							BuildDirList(ad.FbcIncPath,NULL,6)
						    EndIf
							If fProject Then
								BuildDirList(ad.ProjectPath,NULL,7)
							Else
							    'Print "ad.filename:*";ad.filename;"*"

                                ' TODO: ERROR

							    Path = ad.filename
							    PathRemoveFileSpec @Path
							    BuildDirList(Path,NULL,7)
							EndIf
							DirListLCase = DirList
                            CharLower StrPtr (DirListLCase)
							UpdateIncludeList()
						ElseIf InStr(s,"#inclib")<>0 And lp=0 Then
							'reset last dir
							dirlist=""
						    If IsZStrNotEmpty (ad.FbcLibPath) Then
							    BuildDirList(ad.FbcLibPath,NULL,8+6)
							EndIf
							If fProject Then
								BuildDirList(ad.ProjectPath,NULL,8+7)
							Else
							    Path = ad.filename
							    PathRemoveFileSpec @Path
							    BuildDirList(Path,NULL,8+7)
							EndIf
							DirListLCase = DirList
                            CharLower StrPtr (DirListLCase)
							UpdateInclibList()
						ElseIf IsWindowVisible(ah.hcc) Then
							HideCCLists
						EndIf
					ElseIf wParam=VK_RETURN Then
						If edtopt.autoblock Then
							' Block Complete
							chrg=prechrg
						    trng.chrg.cpMin=chrg.cpMin
							trng.chrg.cpMax=chrg.cpMin+255
							trng.lpstrText=@buffer
							SendMessage(hPar,EM_GETTEXTRANGE,0,Cast(LPARAM,@trng))
							i=0
							While buffer[i]<>0 And buffer[i]<>VK_RETURN
								i+=1
							Wend
							If buffer[i]=0 Then
								fnoret=1
							Else
								buffer[i]=0
							EndIf
							tp=0
							While buffer[tp]=VK_SPACE Or buffer[tp]=VK_TAB
								tp+=1
							Wend
							buffer=Mid(buffer,tp+1)
							' MOD 26.1.2012         Crash:  Move caret to line 1 > Change to BlockMode > Press ENTER
							ln = SendMessage (hPar, EM_LINEFROMCHAR, chrg.cpMin, 0)
							If ln > 0 Then ln -= 1
							' =========================
							ln=SendMessage(hPar,REM_GETLINEBEGIN,ln,0)
							If SendMessage(hPar,REM_GETBOOKMARK,ln,0)=BMT_COLLAPSE Then
								wp=0
								While wp<(MAXBLOCKDEFS-2)
									If SendMessage(hPar,REM_ISLINE,ln,Cast(LPARAM,@szSt(wp)))>=0 Then
										lx=ln+1
										lz=0
										While lx<>-1
											lx=SendMessage(hPar,REM_PRVBOOKMARK,lx,BMT_COLLAPSE)
											If lx<>-1 Then
												lz=SendMessage(hPar,REM_GETBLOCKEND,lx,0)
												tp=0
												If lz=-1 Then
													tp=SendMessage(hPar,REM_ISLINE,lx,Cast(LPARAM,@szSt(wp)))
													Exit While
												ElseIf lz>ln Then
													tp=SendMessage(hPar,REM_ISLINE,lx,Cast(LPARAM,@szSt(wp)))
													If tp=-1 Then
														Exit While
													EndIf
												EndIf
											EndIf
										Wend
										If lz<>-1 Or tp=-1 Then
											SendMessage(hPar,EM_EXSETSEL,0,Cast(LPARAM,@chrg))
											SendMessage(hPar,EM_SCROLLCARET,0,0)
											Exit While
										EndIf
										' Get indent
										GetLineByNo hPar, ln, @buff           ' MOD 21.1.2012
										'buff=Chr(255) & Chr(1)
										'lp=SendMessage(hPar,EM_GETLINE,ln,Cast(LPARAM,@buff))
										'buff[lp]=NULL
										'======================
										' MOD 21.1.2012
										lz=0
                                    	Do
                                    	    Select Case Buff[lz]
                                    	    Case VK_SPACE, VK_TAB
                                    	        lz += 1
                                    	    Case Else
                                    	        Buff[lz] = NULL
                                    	        Exit Do
                                    	    End Select
                                    	Loop
                                    	'lp = lstrlen (buff)
                                    	'lz=1
										'While lz<lp
										'	If Asc(buff,lz)<>VK_SPACE And Asc(buff,lz)<>VK_TAB Then
										'		buff[lz-1]=NULL
										'		Exit While
										'	EndIf
										'	lz=lz+1
										'Wend
										'======================
										buff=CR & buff & szEn(wp)

										If fnoret Then
											buff &=CR
										EndIf
										If edtopt.autocase=2 Then
											CharLower buff                         'MOD 30.1.2012      buff=LCase(buff)
										ElseIf edtopt.autocase=3 Then
											CharUpper buff                         'MOD 30.1.2012      buff=UCase(buff)
										EndIf
										If i Then
											chrg.cpMax+=i
											SendMessage(hPar,EM_EXSETSEL,0,Cast(LPARAM,@chrg))
											chrg.cpMax=chrg.cpMin
										EndIf
										SendMessage(hPar,REM_LOCKUNDOID,TRUE,0)
										SendMessage(hPar,EM_REPLACESEL,TRUE,Cast(LPARAM,@buff))
										SendMessage(hPar,EM_EXSETSEL,0,Cast(LPARAM,@chrg))
										SendMessage(hPar,EM_REPLACESEL,TRUE,Cast(LPARAM,@buffer))
										SendMessage(hPar,EM_EXSETSEL,0,Cast(LPARAM,@chrg))
										SendMessage(hPar,EM_SCROLLCARET,0,0)
										AutoFormatLine(hPar,0)
										lstpos.fnohandling=0
										SendMessage(hPar,REM_LOCKUNDOID,FALSE,0)
										Return lret
									EndIf
									wp=wp+1
								Wend
							EndIf
						EndIf
						AutoFormatLine(hPar,0)
						lstpos.fnohandling=0
					EndIf
					Return lret
				EndIf
			EndIf
		Case WM_KEYDOWN
			hPar=GetParent(hWin)
			lp=(lParam Shr 16) And &H3FF
			wp=wParam
			If IsWindowVisible(ah.hcc) Then
				If (wp=&H28 And (lp=&H150 Or lp=&H50)) Or (wp=&H26 And (lp=&H148 Or lp=&H48)) Or (wp=&H21 And (lp=&H149 Or lp=&H49)) Or (wp=&H22 And (lp=&H151 Or lp=&H51)) Then
					' Down / Up /PgUp / PgDn
					' Relay event to the code complete list
					PostMessage(ah.hcc,uMsg,wParam,lParam)
					Return 0
				ElseIf (wp=&H27 And lp=&H14D) Or (wp=&H25 And lp=&H14B) Then
					' Right, Left
					lret=CallWindowProc(lpOldCoTxEdProc,hWin,uMsg,wParam,lParam)
					If IsWindowVisible(ah.hcc) Then
						SendMessage(hPar,EM_EXGETSEL,0,Cast(LPARAM,@chrg))
						trng.chrg.cpMin=chrg.cpMin
						trng.chrg.cpMax=chrg.cpMin+1
						trng.lpstrText=@buff
						SendMessage(hPar,EM_GETTEXTRANGE,0,Cast(LPARAM,@trng))
						If buff="," Or buff="(" Or buff=")" Then
							HideCCLists()
						Else
							MoveList()
						EndIf
					EndIf
					Return lret
				EndIf
			ElseIf IsWindowVisible(ah.htt)<>0 Then
				lp=(lParam Shr 16) And &H3FF
				wp=wParam
				If (wp=&H28 And (lp=&H150 Or lp=&H50)) And novr>1 Then
					' Down
					If nsel<novr-1 Then
						nsel+=1
						GoTo TT
					EndIf
					Return 0
				ElseIf wp=&H26 And (lp=&H148 Or lp=&H48) And novr>1 Then
					' Up
					If nsel Then
						nsel-=1
						GoTo TT
					EndIf
					Return 0
				ElseIf (wp=&H27 And lp=&H14D) Then
					' Right
					lret=CallWindowProc(lpOldCoTxEdProc,hWin,uMsg,wParam,lParam)
					SendMessage(hPar,EM_EXGETSEL,0,Cast(LPARAM,@chrg))
					If chrg.cpMin Then
						trng.chrg.cpMin=chrg.cpMin-1
						trng.chrg.cpMax=chrg.cpMin
						trng.lpstrText=@buff
						SendMessage(hPar,EM_GETTEXTRANGE,0,Cast(LPARAM,@trng))
						If buff="," Or buff="(" Or buff=")" Then
							GoTo TT
						EndIf
					EndIf
					Return lret
				ElseIf (wp=&H25 And lp=&H14B) Then
					' Left
					lret=CallWindowProc(lpOldCoTxEdProc,hWin,uMsg,wParam,lParam)
					SendMessage(hPar,EM_EXGETSEL,0,Cast(LPARAM,@chrg))
					If chrg.cpMin Then
						trng.chrg.cpMin=chrg.cpMin
						trng.chrg.cpMax=chrg.cpMin+1
						trng.lpstrText=@buff
						SendMessage(hPar,EM_GETTEXTRANGE,0,Cast(LPARAM,@trng))
						If buff="," Or buff="(" Or buff=")" Then
							GoTo TT
						EndIf
					EndIf
					Return lret
				EndIf
			EndIf
			If wParam=VK_INSERT Then
			    CallWindowProc lpOldCoTxEdProc, hWin, uMsg, wParam, lParam
			    SbarSetWriteMode
			    Return 0
			    'fTimer=1
			ElseIf (wParam=Asc("Z") Or wParam=Asc("Y")) And (GetKeyState(VK_CONTROL) And &H80)<>0 Then
				lret=ad.fNoNotify
				ad.fNoNotify=TRUE
				CallWindowProc(lpOldCoTxEdProc,hWin,uMsg,wParam,lParam)
				ad.fNoNotify=lret
				Return 0
			ElseIf wParam=VK_SPACE And (GetKeyState(VK_CONTROL) And &H80)<>0 Then
				If SendMessage(hPar,REM_GETWORDGROUP,0,0)=0 Then
					' Show code complete list
					ShowWindow(ah.htt,SW_HIDE)
					HideCCLists
					SendMessage(hPar,EM_EXGETSEL,0,Cast(LPARAM,@chrg))
					isinp.nLine=SendMessage(hPar,EM_EXLINEFROMCHAR,0,chrg.cpMax)
					If fProject Then
						isinp.nOwner=GetFileIDByEditor(hPar)
					Else
					    isinp.nOwner=Cast(Integer,hPar)
					EndIf
					isinp.lpszType=StrPtr("pxyzo")
					p=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_ISINPROC,0,Cast(LPARAM,@isinp)))
					If p<>0 And (GetKeyState(VK_SHIFT) And &H80)<>0 Then
						flocallist=TRUE
					EndIf
					UpdateList(p)
					' Move code complete list
					MoveList
				EndIf
				Return 0
			EndIf
		Case WM_CONTEXTMENU
			If CallAddins(hWin,AIM_CONTEXTMEMU,wParam,lParam,HOOK_CONTEXTMEMU)=FALSE Then
		    	If lParam = -1 Then               ' context menu called by keyboard
					GetCaretPos @pt
					ClientToScreen Cast (HWND, wParam), @pt
					pt.x += 10
		    	Else                              ' context menu called by R-button-click
					pt.x = LoWord (lParam)
					pt.y = HiWord (lParam)
		    	EndIf

				hMnu = GetSubMenu (GetMenu (ah.hwnd), 1)

				ShowCursor FALSE
    			hPrevCur = SetCursor (LoadCursor (NULL, IDC_ARROW))
				ShowCursor TRUE
				TrackPopupMenu hMnu, TPM_LEFTALIGN Or TPM_RIGHTBUTTON, pt.x, pt.y, 0, ah.hwnd, 0
				ShowCursor FALSE
				SetCursor hPrevCur
				ShowCursor TRUE

				Return 0
			EndIf

		Case WM_LBUTTONDOWN
			'Print "CoTxEdProc:WM_LBUTTONDOWN"
			mdn=GetKeyState(VK_CONTROL) And &H80
			TimerRunning = SetTimer (hWin, IDT_MOUSE_CLK_TIMER, GetDoubleClickTime, NULL)
			GetCursorPos @OldPt
		Case WM_TIMER
			KillTimer hWin, IDT_MOUSE_CLK_TIMER
			TimerRunning = 0
		    If LButtonUPCount = 1 Then
				GetCursorPos @pt
				If      Abs (pt.x - OldPt.x) < GetSystemMetrics (SM_CXDOUBLECLK) _
				AndAlso Abs (pt.y - OldPt.y) < GetSystemMetrics (SM_CYDOUBLECLK) Then
					ShowCursor FALSE
					SetCursorPos pt.x + 15, pt.y + 30
					ShowCursor TRUE
				EndIf
		    EndIf
		    LButtonUPCount = 0
		Case WM_LBUTTONUP
			If mdn Then	SendMessage ah.hwnd, WM_COMMAND, IDM_FILE_OPEN_STD, 0
			If TimerRunning Then LButtonUPCount += 1
	    Case WM_KILLFOCUS                   ' wParam: Handle to the window that receives the keyboard focus
	        'Print "CoTxEd:KILLFOCUS"
			ShowWindow(ah.htt,SW_HIDE)
			If wParam<>ah.hcc Then
				HideCCLists()
			EndIf
			hPar=GetParent(Cast(HWND,wParam))
			If GetWindowLong(hPar,GWL_USERDATA)=1 Then
				' Must be parsed
				SetPropertyDirty hPar
			EndIf
			'temp fix split focus bug
			If ah.hpane(0) Then
    			While hPar
    				If ah.hres = hPar Then
    					If ah.hpane(0) <> ah.hred Then
    						ah.hpane(1) = ah.hred
    					EndIf
    					SelectTabByWindow ah.hres          ' MOD 1.2.2012 removed ah.hwnd
    					Exit While
    				EndIf
    				hPar=GetParent(hPar)
    			Wend
			EndIf
			'SendMessage ah.hwnd, FBE_CHILDLOOSINGFOCUS, 0, Cast (LPARAM, GetParent (hWin))     ' notify: window is loosing focus
			SbarClear

	    Case WM_SETFOCUS
	        'Print "CoTxEd:SETFOCUS"
			'temp fix split focus bug
			If ah.hpane(0) Then
    			If ah.hred <> GetParent(hWin) Then
    				If ah.hpane(0) <> ah.hred Then
    					ah.hpane(1) = ah.hred
    				EndIf
    				SelectTabByWindow (GetParent (hWin))      ' MOD 1.2.2012 removed ah.hwnd
    			EndIf
			EndIf
	        SbarSetBlockMode
	        SbarLabelLockState
	        SbarSetWriteMode
			'Return 0
		Case WM_MOUSEWHEEL,WM_VSCROLL
			If IsWindowVisible(ah.htt) Then
				CallWindowProc(lpOldCoTxEdProc,hWin,uMsg,wParam,lParam)
				GetCaretPos(@pt)
				ClientToScreen(hWin,@pt)
				pt.x=pt.x-ttpos
				SetWindowPos(ah.htt,HWND_TOP,pt.x,pt.y+20,0,0,SWP_NOSIZE Or SWP_NOACTIVATE Or SWP_SHOWWINDOW)
				InvalidateRect(ah.htt,NULL,TRUE)
				Return 0
			ElseIf IsWindowVisible(ah.hcc) Then
				CallWindowProc(lpOldCoTxEdProc,hWin,uMsg,wParam,lParam)
				MoveList
				Return 0
			End If
	End Select
	Return CallWindowProc(lpOldCoTxEdProc,hWin,uMsg,wParam,lParam)

End Function

Function ParCoTxEdProc(ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer
	Dim pt As Point
	Dim lret As Integer

	Select Case uMsg
		Case WM_SHOWWINDOW
			If ah.hfullscreen<>0 And fInUse=FALSE Then
				fInUse=TRUE
				If wParam Then
					If GetParent(hWin)<>ah.hfullscreen Then
						SetFullScreen(hWin)
					EndIf
				Else
					If GetParent(hWin)=ah.hfullscreen Then
						SetParent(hWin,ah.hwnd)
					EndIf
				EndIf
				fInUse=FALSE
			EndIf
		Case WM_HSCROLL
			If IsWindowVisible(ah.htt) Then
				CallWindowProc(lpOldParCoTxEdProc,hWin,uMsg,wParam,lParam)
				GetCaretPos(@pt)
				ClientToScreen(hWin,@pt)
				pt.x=pt.x-ttpos
				SetWindowPos(ah.htt,HWND_TOP,pt.x,pt.y+20,0,0,SWP_NOSIZE Or SWP_NOACTIVATE Or SWP_SHOWWINDOW)
				InvalidateRect(ah.htt,NULL,TRUE)
				Return 0
			ElseIf IsWindowVisible(ah.hcc) Then
				CallWindowProc(lpOldParCoTxEdProc,hWin,uMsg,wParam,lParam)
				MoveList
				Return 0
			End If
		Case EM_UNDO,EM_REDO
			lret=ad.fNoNotify
			ad.fNoNotify=TRUE
			CallWindowProc(lpOldParCoTxEdProc,hWin,uMsg,wParam,lParam)
			ad.fNoNotify=lret
			Return 0
	End Select
	Return CallWindowProc(lpOldParCoTxEdProc,hWin,uMsg,wParam,lParam)

End Function

Function CCProc(ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer

	Select Case uMsg
		Case WM_CHAR
			If wParam=VK_TAB Or wParam=VK_RETURN Then
				SendMessage(ah.hred,WM_CHAR,VK_TAB,0)
				Return 0
			ElseIf wParam=VK_ESCAPE Then
				ShowWindow(hWin,SW_HIDE)
				ftypelist=FALSE
				fconstlist=FALSE
				fstructlist=FALSE
				flocallist=FALSE
				fincludelist=FALSE
				fincliblist=FALSE
				Return 0
			EndIf
			'
		Case WM_LBUTTONDBLCLK
			SendMessage(ah.hred,WM_CHAR,VK_TAB,0)
			Return 0
			'
		Case WM_ACTIVATE
			SendMessage(ah.hwnd,WM_NCACTIVATE,TRUE,0)
			'
		Case WM_SIZING
			wpos.ptcclist.y=Cast(RECT Ptr,lParam)->bottom-Cast(RECT Ptr,lParam)->top
			'
	End Select
	Return CallWindowProc(lpOldCCProc,hWin,uMsg,wParam,lParam)

End Function

Sub BlockModeToggle (ByVal hEditor As HWND = ah.hred)

    Dim Mode As Long

    If EditInfo.CoTxEd Then
	    Mode = SendMessage (hEditor, REM_GETMODE, 0, 0) Xor MODE_BLOCK
	    SendMessage hEditor, REM_SETMODE, Mode, 0
	Else

    EndIf

	'CheckMenuItem ah.hmenu, IDM_EDIT_BLOCKMODE, IIf (Mode, MF_CHECKED, MF_UNCHECKED)

End Sub

'Sub BlockModeUnset (ByVal hEditor As HWND = ah.hred)
'
'    SendMessage hEditor, REM_SETMODE, FALSE, 0
'    CheckMenuItem ah.hmenu, IDM_EDIT_BLOCKMODE, MF_UNCHECKED
'
'End Sub

'Function IsEditorWindow (ByVal hWin As HWND, ByVal TestForType As EditorType) As BOOL
'
'    Dim EditorMode As Long = Any
'
'    If hWin Then
'        EditorMode = GetWindowLong (hWin, GWL_ID)
'
'        Select Case As Const TestForType
'        Case ET_CoTxEd   : Return (EditorMode = IDC_CODEED) OrElse (EditorMode = IDC_TEXTED)
'        Case ET_CodeEd   : Return (EditorMode = IDC_CODEED)
'        Case ET_TextEd   : Return (EditorMode = IDC_TEXTED)
'        Case ET_ResEd    : Return (EditorMode = IDC_RESED)
'        Case ET_HexEd    : Return (EditorMode = IDC_HEXED)
'        Case ET_AlphaEd  : Return (EditorMode = IDC_CODEED) OrElse (EditorMode = IDC_TEXTED) OrElse (EditorMode = IDC_HEXED)
'        End Select
'    EndIf
'
'    Return FALSE
'
'End Function

Function EditorHasFocus () As BOOL

    Return (ah.hred = GetParent (GetFocus ()))

End Function

Sub SetEditorTypeInfo (ByVal hWin As HWND)

    Dim    EditorMode As Long           = Any

    If hWin Then
        EditorMode = GetWindowLong (hWin, GWL_ID)

		EditInfo.ResEd   = (EditorMode = IDC_RESED)
		EditInfo.CodeEd  = (EditorMode = IDC_CODEED)
		EditInfo.HexEd   = (EditorMode = IDC_HEXED)
		EditInfo.TextEd  = (EditorMode = IDC_TEXTED)
		EditInfo.CoTxEd  = EditInfo.CodeEd Orelse EditInfo.TextEd
		EditInfo.AlphaEd = Not (EditInfo.ResEd)
    Else
        Dim InitialEditInfo As EditorTypeInfo
        EditInfo = InitialEditInfo
    EndIf

End Sub

Function CreateCodeEd (Byref sFile As zString) As HWND

	Dim hTmp    As HWND         = Any
    Dim i       As Integer      = Any
	Dim buffer  As ZString * 64

	Const Style As DWORD        = WS_CHILD                Or WS_VISIBLE        Or WS_CLIPCHILDREN   _
	         	               Or WS_CLIPSIBLINGS         Or STYLE_SCROLLTIP   Or STYLE_DRAGDROP    _
	      	                   Or STYLE_AUTOSIZELINENUM

	hTmp = CreateWindowEx (WS_EX_CLIENTEDGE, @"RAEDIT", NULL, Style, 0, 0, 0, 0, ah.hwnd, Cast (HMENU, IDC_RAEDIT), hInstance, 0)

    If hTmp Then                                            ' MOD 1.3.2012
    	SetWindowLong hTmp, GWL_ID, IDC_CODEED              ' MOD 10.2.2012
    	UpdateEditOptions hTmp

		'SetWindowLong hTmp, GWL_USERDATA, 2  				' must be parsed
		SendMessage hTmp, REM_SETSTYLEEX, STYLEEX_BLOCKGUIDE Or STILEEX_LINECHANGED Or STILEEX_STRINGMODEFB, 0
    	SendMessage hTmp, WM_SETTEXT, 0, Cast (LPARAM, @"")
    	SendMessage hTmp, EM_SETMODIFY, FALSE, 0

    	' Set tooltips
    	For i = 1 To 6
    		buffer = GetInternalString (IS_RAEDIT_BASE + i)
    		SendMessage hTmp, REM_SETTOOLTIP, i, Cast (LPARAM, @buffer)
    	Next

    	lpOldParCoTxEdProc = Cast (WNDPROC, SetWindowLong (hTmp, GWL_WNDPROC, Cast (LONG, @ParCoTxEdProc)))
    	lpOldCoTxEdProc = Cast (WNDPROC, SendMessage (hTmp, REM_SUBCLASS, 0, Cast (LPARAM, @CoTxEdProc)))
    	CallAddins ah.hwnd, AIM_CREATEEDIT, Cast (WPARAM, hTmp), 0, HOOK_CREATEEDIT

    	If edtopt.linenumbers Then
    		SendDlgItemMessage hTmp, -2, BM_CLICK, 0, 0
    	EndIf
    EndIf
	Return hTmp

End Function

Function CreateTxtEd (Byref sFile As zString) As HWND

	Dim hTmp    As HWND         = Any
	Dim i       As Integer      = Any
	Dim buffer  As ZString * 64

	Const Style As DWORD        = WS_CHILD                Or WS_VISIBLE        Or WS_CLIPCHILDREN   Or _
	    		                  WS_CLIPSIBLINGS         Or STYLE_SCROLLTIP   Or STYLE_DRAGDROP    Or _
	      	                      STYLE_AUTOSIZELINENUM   Or STYLE_NOHILITE    Or STYLE_NOCOLLAPSE  Or _
	                              STYLE_NODIVIDERLINE

	hTmp = CreateWindowEx (WS_EX_CLIENTEDGE, @"RAEDIT", NULL, Style, 0, 0, 0, 0, ah.hwnd, Cast (HMENU, IDC_RAEDIT), hInstance, 0)

    If hTmp Then                                            ' MOD 1.3.2012
    	SetWindowLong hTmp, GWL_ID, IDC_TEXTED              ' MOD 10.2.2012
    	UpdateEditOptions hTmp

   		SendMessage hTmp, REM_SETWORDGROUP, 0, 15
		SendMessage hTmp, REM_SETSTYLEEX, STILEEX_LINECHANGED Or STILEEX_STRINGMODEFB, 0
    	SendMessage hTmp, WM_SETTEXT, 0, Cast (LPARAM, @"")
    	SendMessage hTmp, EM_SETMODIFY, FALSE, 0

    	' Set tooltips
    	For i = 1 To 3
    		buffer = GetInternalString (IS_RAEDIT_BASE + i)
    		SendMessage hTmp, REM_SETTOOLTIP, i, Cast (LPARAM, @buffer)
    	Next

    	lpOldParCoTxEdProc = Cast (WNDPROC, SetWindowLong (hTmp, GWL_WNDPROC, Cast(Long, @ParCoTxEdProc)))
    	lpOldCoTxEdProc = Cast (WNDPROC, SendMessage (hTmp, REM_SUBCLASS, 0, Cast (LPARAM, @CoTxEdProc)))
    	CallAddins ah.hwnd, AIM_CREATEEDIT, Cast (WPARAM, hTmp), 0, HOOK_CREATEEDIT

		If edtopt.linenumbers Then
    		SendDlgItemMessage hTmp, -2, BM_CLICK, 0, 0
    	EndIf
    EndIf
	Return hTmp

End Function
