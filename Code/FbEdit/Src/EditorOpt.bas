

#Include Once "windows.bi"

#Include Once "Inc\RAEdit.bi"
#Include Once "Inc\RAResEd.bi"
#Include Once "Inc\RACodeComplete.bi"
#Include Once "Inc\RAFile.bi"
#Include Once "Inc\RAHexEd.bi"
#Include Once "Inc\RAProperty.bi"

#Include Once "Inc\Addins.bi"
#Include Once "Inc\FbEdit.bi"
#Include Once "Inc\GUIHandling.bi"
#Include Once "Inc\IniFile.bi"
#Include Once "Inc\Language.bi"
#Include Once "Inc\Misc.bi"
#Include Once "Inc\Project.bi"
#Include Once "Inc\Property.bi"
#Include Once "Inc\TabTool.bi"
#Include Once "Inc\ZStringHandling.bi"

#Include Once "Inc\EditorOpt.bi"

Dim Shared hCFont        As HFONT         ' editor font
Dim Shared hLFont        As HFONT         ' line number font
Dim Shared hTFont        As HFONT         ' tool window font
Dim Shared hOFont        As HFONT         ' output window font

Dim Shared oldsel        As Integer
Dim Shared tmpcol        As FBCOLOR

Dim Shared sKeyWords(21) As String
Dim Shared edtopt        As EDITOPTION = (3,0,0,1,0,0,3,1,1,1,1,1,1,0,0,0,1,1,1,0,0)
Dim Shared fbcol         As FBCOLOR    = ((DEFBCKCOLOR,DEFTXTCOLOR,DEFSELBCKCOLOR,DEFSELTXTCOLOR,DEFCMNTCOLOR,DEFSTRCOLOR,DEFOPRCOLOR,DEFHILITE1,DEFHILITE2,DEFHILITE3,DEFSELBARCOLOR,DEFSELBARPEN,DEFLNRCOLOR,DEFNUMCOLOR,DEFCMNTBCK,DEFSTRBCK,DEFNUMBCK,DEFOPRBCK,DEFCHANGEDCLR,DEFCHANGESAVEDCLR),DEFBCKCOLOR,DEFTXTCOLOR,DEFBCKCOLOR,DEFTXTCOLOR)
Dim Shared kwcol         As KWCOLOR    = (RGB(0,0,128),RGB(0,0,128),RGB(0,0,128),RGB(64,64,0),RGB(128,0,0),RGB(0,0,128),RGB(0,0,128),RGB(0,0,128),RGB(0,0,128),&H1000000+RGB(0,0,128),&H4000000+RGB(0,0,128),RGB(0,0,128),RGB(0,0,128),RGB(0,0,128),RGB(0,0,128),RGB(0,0,128),&H1000000+RGB(0,255,255),&H1000000+RGB(0,255,255),&H1000000+RGB(0,255,255))

Dim Shared edtfnt        As EDITFONT   = (-12, 0, @"Courier New", 400, 0)
Dim Shared lnrfnt        As EDITFONT   = ( -6, 0, @"Terminal"   , 400, 0)
Dim Shared outpfnt       As EDITFONT   = (-11, 0, @"Tahoma"     , 400, 0)
Dim Shared toolfnt       As EDITFONT   = (-11, 0, @"Tahoma"     , 400, 0)

Dim Shared custcol       As KWCOLOR
Dim Shared thme(15)      As THEME
Dim Shared szTheme(15)   As ZString * 32


Const sColors="Back,Text,Selected back,Selected text,Comments,Strings,Operators,Comments back,Active line back,Indent markers,Selection bar,Selection bar pen,Line numbers,Numbers & hex,Line changed,Saved line change,Tools Back,Tools Text,Dialog Back,Dialog Text,CodeComplete Back,CodeComplete Text,CodeTip Back,CodeTip Text,CodeTip Api,CodeTip Sel,Properties parameters"


Sub SetToolsColors ()
	Dim racol As RACOLOR
	Dim rescol As RARESEDCOLOR
	Dim cccol As CC_COLOR
	Dim ttcol As TT_COLOR

	SendMessage(ah.hprj,TVM_SETBKCOLOR,0,fbcol.toolback)
	SendMessage(ah.hprj,TVM_SETTEXTCOLOR,0,fbcol.tooltext)
	SendMessage(ah.hfib,FBM_SETBACKCOLOR,0,fbcol.toolback)
	SendMessage(ah.hfib,FBM_SETTEXTCOLOR,0,fbcol.tooltext)
	SendMessage(ah.hpr,PRM_SETBACKCOLOR,0,fbcol.toolback)
	SendMessage(ah.hpr,PRM_SETTEXTCOLOR,0,fbcol.tooltext)
	SendMessage(ah.hpr,PRM_SETOPRCOLOR,0,fbcol.propertiespar)
	SendMessage(ah.hout,REM_GETCOLOR,0,Cast(Integer,@racol))
	racol.bckcol=fbcol.toolback
	racol.txtcol=fbcol.tooltext
	SendMessage(ah.hout,REM_SETCOLOR,0,Cast(Integer,@racol))
	SendMessage(ah.himm,REM_SETCOLOR,0,Cast(Integer,@racol))
	SendMessage(ah.hregister,REM_SETCOLOR,0,Cast(Integer,@racol))
	SendMessage(ah.hfpu,REM_SETCOLOR,0,Cast(Integer,@racol))
	SendMessage(ah.hmmx,REM_SETCOLOR,0,Cast(Integer,@racol))
	rescol.back=fbcol.dialogback
	rescol.text=fbcol.dialogtext
	SendMessage(ah.hraresed,DEM_SETCOLOR,0,Cast(Integer,@rescol))
	cccol.back=fbcol.codelistback
	cccol.text=fbcol.codelisttext
	SendMessage(ah.hcc,CCM_SETCOLOR,0,Cast(LPARAM,@cccol))
	ttcol.back=fbcol.codetipback
	ttcol.text=fbcol.codetiptext
	ttcol.api=fbcol.codetipapi
	ttcol.hilite=fbcol.codetipsel
	SendMessage(ah.htt,TTM_SETCOLOR,0,Cast(LPARAM,@ttcol))

End Sub

Sub SetHiliteWords(ByVal hWin As HWND)

    Dim i   As Integer = Any
    Dim Key As ZString * 32

	' Reset all words
	SendMessage ah.hout, REM_SETHILITEWORDS, 0, 0

	' Set colors and words to hilite
    For i = 0 To 20
    	Key = "C" + Str(i)
    	GetPrivateProfileString @"Edit", @Key, NULL, @buff, SizeOf (buff), @ad.IniFile
    	SendMessage ah.hout, REM_SETHILITEWORDS, Cast (COLORREF Ptr, @kwcol)[i], Cast (LPARAM, @buff)
    Next




	'GetPrivateProfileString (StrPtr("Edit"),StrPtr("C0"),@C0,@buff,SizeOf(buff),@ad.IniFile)
	'SendMessage(ah.hout,REM_SETHILITEWORDS,kwcol.C0,Cast(Integer,@buff))
	'GetPrivateProfileString(StrPtr("Edit"),StrPtr("C1"),@C1,@buff,SizeOf(buff),@ad.IniFile)
	'SendMessage(ah.hout,REM_SETHILITEWORDS,kwcol.C1,Cast(Integer,@buff))
	'GetPrivateProfileString(StrPtr("Edit"),StrPtr("C2"),@C2,@buff,SizeOf(buff),@ad.IniFile)
	'SendMessage(ah.hout,REM_SETHILITEWORDS,kwcol.C2,Cast(Integer,@buff))
	'GetPrivateProfileString(StrPtr("Edit"),StrPtr("C3"),@C3,@buff,SizeOf(buff),@ad.IniFile)
	'SendMessage(ah.hout,REM_SETHILITEWORDS,kwcol.C3,Cast(Integer,@buff))
	'GetPrivateProfileString(StrPtr("Edit"),StrPtr("C4"),@C4,@buff,SizeOf(buff),@ad.IniFile)
	'SendMessage(ah.hout,REM_SETHILITEWORDS,kwcol.C4,Cast(Integer,@buff))
	'GetPrivateProfileString(StrPtr("Edit"),StrPtr("C5"),@C5,@buff,SizeOf(buff),@ad.IniFile)
	'SendMessage(ah.hout,REM_SETHILITEWORDS,kwcol.C5,Cast(Integer,@buff))
	'GetPrivateProfileString(StrPtr("Edit"),StrPtr("C6"),@C6,@buff,SizeOf(buff),@ad.IniFile)
	'SendMessage(ah.hout,REM_SETHILITEWORDS,kwcol.C6,Cast(Integer,@buff))
	'GetPrivateProfileString(StrPtr("Edit"),StrPtr("C7"),@C7,@buff,SizeOf(buff),@ad.IniFile)
	'SendMessage(ah.hout,REM_SETHILITEWORDS,kwcol.C7,Cast(Integer,@buff))
	'GetPrivateProfileString(StrPtr("Edit"),StrPtr("C8"),@C8,@buff,SizeOf(buff),@ad.IniFile)
	'SendMessage(ah.hout,REM_SETHILITEWORDS,kwcol.C8,Cast(Integer,@buff))
	'GetPrivateProfileString(StrPtr("Edit"),StrPtr("C9"),@C9,@buff,SizeOf(buff),@ad.IniFile)
	'SendMessage(ah.hout,REM_SETHILITEWORDS,kwcol.C9,Cast(Integer,@buff))
	'GetPrivateProfileString(StrPtr("Edit"),StrPtr("C10"),@C10,@buff,SizeOf(buff),@ad.IniFile)
	'SendMessage(ah.hout,REM_SETHILITEWORDS,kwcol.C10,Cast(Integer,@buff))
	'GetPrivateProfileString(StrPtr("Edit"),StrPtr("C11"),@C11,@buff,SizeOf(buff),@ad.IniFile)
	'SendMessage(ah.hout,REM_SETHILITEWORDS,kwcol.C11,Cast(Integer,@buff))
	'GetPrivateProfileString(StrPtr("Edit"),StrPtr("C12"),@C12,@buff,SizeOf(buff),@ad.IniFile)
	'SendMessage(ah.hout,REM_SETHILITEWORDS,kwcol.C12,Cast(Integer,@buff))
	'GetPrivateProfileString(StrPtr("Edit"),StrPtr("C13"),@C13,@buff,SizeOf(buff),@ad.IniFile)
	'SendMessage(ah.hout,REM_SETHILITEWORDS,kwcol.C13,Cast(Integer,@buff))
	'GetPrivateProfileString(StrPtr("Edit"),StrPtr("C14"),@C14,@buff,SizeOf(buff),@ad.IniFile)
	'SendMessage(ah.hout,REM_SETHILITEWORDS,kwcol.C14,Cast(Integer,@buff))
	'GetPrivateProfileString(StrPtr("Edit"),StrPtr("C15"),@C15,@buff,SizeOf(buff),@ad.IniFile)
	'SendMessage(ah.hout,REM_SETHILITEWORDS,kwcol.C15,Cast(Integer,@buff))
	'GetPrivateProfileString(StrPtr("Edit"),StrPtr("C16"),@C16,@buff,SizeOf(buff),@ad.IniFile)
	'SendMessage(ah.hout,REM_SETHILITEWORDS,kwcol.C16,Cast(Integer,@buff))
	'GetPrivateProfileString(StrPtr("Edit"),StrPtr("C17"),@C17,@buff,SizeOf(buff),@ad.IniFile)
	'SendMessage(ah.hout,REM_SETHILITEWORDS,kwcol.C17,Cast(Integer,@buff))
	'GetPrivateProfileString(StrPtr("Edit"),StrPtr("C18"),@C18,@buff,SizeOf(buff),@ad.IniFile)
	'SendMessage(ah.hout,REM_SETHILITEWORDS,kwcol.C18,Cast(Integer,@buff))
	'GetPrivateProfileString(StrPtr("Edit"),StrPtr("C19"),@C19,@buff,SizeOf(buff),@ad.IniFile)
	'SendMessage(ah.hout,REM_SETHILITEWORDS,kwcol.C19,Cast(Integer,@buff))
	'GetPrivateProfileString(StrPtr("Edit"),StrPtr("C20"),@C20,@buff,SizeOf(buff),@ad.IniFile)
	'SendMessage(ah.hout,REM_SETHILITEWORDS,kwcol.C20,Cast(Integer,@buff))
	SendMessage(ah.hraresed,PRO_SETHIGHLIGHT,kwcol.C10,kwcol.C10)

End Sub

Sub SetHiliteWordsFromApi(ByVal hWin As HWND)
	Dim lret As Integer
	Dim sItem As ZString*256
	Dim x As Integer
	Dim y As Integer

	' Data types
	lret=SendMessage(ah.hpr,PRM_FINDFIRST,Cast(Integer,StrPtr("T")),Cast(Integer,StrPtr("")))
	Do While lret
		sItem= "^"
		lstrcpy(@sItem,Cast(ZString Ptr,lret))
		If sItem=UCase(sItem) Then
			' Case sensitive
			sItem="^" & sItem
		EndIf
		SendMessage(ah.hout,REM_SETHILITEWORDS,kwcol.C12,Cast(Integer,@sItem))
		lret=SendMessage(ah.hpr,PRM_FINDNEXT,0,0)
	Loop
	' Api struct
	lret=SendMessage(ah.hpr,PRM_FINDFIRST,Cast(Integer,StrPtr("S")),Cast(Integer,StrPtr("")))
	Do While lret
		sItem= "^"
		lstrcat(@sItem,Cast(ZString Ptr,lret))
		SendMessage(ah.hout,REM_SETHILITEWORDS,kwcol.C13,Cast(Integer,@sItem))
		lret=SendMessage(ah.hpr,PRM_FINDNEXT,0,0)
	Loop
	' Api words
	lret=SendMessage(ah.hpr,PRM_FINDFIRST,Cast(Integer,StrPtr("W")),Cast(Integer,StrPtr("")))
	Do While lret
		sItem= "^"
		lstrcat(@sItem,Cast(ZString Ptr,lret))
		SendMessage(ah.hout,REM_SETHILITEWORDS,kwcol.C14,Cast(Integer,@sItem))
		lret=SendMessage(ah.hpr,PRM_FINDNEXT,0,0)
	Loop
	' Api constants
	lret=SendMessage(ah.hpr,PRM_FINDFIRST,Cast(Integer,StrPtr("A")),Cast(Integer,StrPtr("")))
	Do While lret
		lret=lret+Len(*Cast(ZString Ptr,lret))+1
		lstrcpy(@buff,Cast(ZString Ptr,lret))
'''*** This is a bit slow
'		lret=1
'		while TRUE
'			x=instr(lret,buff,",")
'			if x then
'				sItem="^" & mid(buff,lret,x-lret)
'				SendMessage(ah.hout,REM_SETHILITEWORDS,kwcol.C14,@sItem)
'				lret=x+1
'			else
'				sItem="^" & mid(buff,lret)
'				SendMessage(ah.hout,REM_SETHILITEWORDS,kwcol.C14,@sItem)
'				exit while
'			endif
'		wend
'''***

'''*** Speed it up with some inline assembly
		Asm
			push	esi
			push	edi
			lea	esi,buff
			lea	edi,s
			mov	al,&H5e
			mov	[edi],al
			Inc	edi
		NextChar0:
			mov	ax,[esi]
			add	esi,2
			cmp	ax,&H2c30
			je		NextChar0
			cmp	ax,&H2c31
			je		NextChar0
			cmp	ax,&H2c32
			je		NextChar0
			cmp	ax,&H2c33
			je		NextChar0
			cmp	ax,&H34
			je		EndLine
			dec	esi
			dec	esi
		NextChar:
			mov	ax,[esi]
			cmp	al,&H2c
			jne	NextChar1
			mov	al,&H20
			mov	[edi],al
			Inc	edi
			mov	al,&H5e
		NextChar1:
			mov	[edi],al
			Inc	esi
			Inc	edi
			Or		al,al
			jne	NextChar
		EndLine:
			Xor	al,al
			mov	[edi],al
			pop	edi
			pop	esi
		End Asm
		If s<>"^" Then
			SendMessage(ah.hout,REM_SETHILITEWORDS,kwcol.C14,Cast(Integer,@s))
		EndIf
'''***
		lret=SendMessage(ah.hpr,PRM_FINDNEXT,0,0)
	Loop
	' Api calls
	lret=SendMessage(ah.hpr,PRM_FINDFIRST,Cast(Integer,StrPtr("P")),Cast(Integer,StrPtr("")))
	Do While lret
		'sItem= "^"
		'lstrcat(@sItem,Cast(ZString ptr,lret))
		lstrcpy(@sItem,Cast(ZString Ptr,lret))
		SendMessage(ah.hout,REM_SETHILITEWORDS,kwcol.C15,Cast(Integer,@sItem))
		lret=SendMessage(ah.hpr,PRM_FINDNEXT,0,0)
	Loop

End Sub

Sub HLUDT()
	Dim lret As ZString Ptr
	Dim sItem As ZString*256

	lret=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_FINDFIRST,Cast(Integer,StrPtr("s")),Cast(Integer,StrPtr(""))))
	Do While lret
		sItem= "^"
		lstrcat(@sItem,lret)
		SendMessage(ah.hout,REM_SETHILITEWORDS,kwcol.C16,Cast(Integer,@sItem))
		lret=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_FINDNEXT,0,0))
	Loop

End Sub

Sub HLConstants()
	Dim lret As ZString Ptr
	Dim sItem As ZString*256

	lret=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_FINDFIRST,Cast(Integer,StrPtr("c")),Cast(Integer,StrPtr(""))))
	Do While lret
		sItem= "^"
		lstrcat(@sItem,lret)
		SendMessage(ah.hout,REM_SETHILITEWORDS,kwcol.C17,Cast(Integer,@sItem))
		lret=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_FINDNEXT,0,0))
	Loop

End Sub

Sub HLVariable()
	Dim lret As ZString Ptr
	Dim sItem As ZString*256

	lret=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_FINDFIRST,Cast(Integer,StrPtr("d")),Cast(Integer,StrPtr(""))))
	Do While lret
		sItem= "^"
		lstrcat(@sItem,lret)
		SendMessage(ah.hout,REM_SETHILITEWORDS,kwcol.C17,Cast(Integer,@sItem))
		lret=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_FINDNEXT,0,0))
	Loop

End Sub

Sub HLFunction()
	Dim lret As ZString Ptr
	Dim sItem As ZString*256

	lret=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_FINDFIRST,Cast(Integer,StrPtr("p")),Cast(Integer,StrPtr(""))))
	Do While lret
		sItem= "^"
		lstrcat(@sItem,lret)
		SendMessage(ah.hout,REM_SETHILITEWORDS,kwcol.C18,Cast(Integer,@sItem))
		lret=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_FINDNEXT,0,0))
	Loop

End Sub

Sub PropertyHL(ByVal bUpdate As Integer)

	If bUpdate Then
		HLUDT()
		HLConstants()
		HLVariable()
		HLFunction()
	Else
		SetHiliteWords(ah.hwnd)
		SetHiliteWordsFromApi(ah.hwnd)
	EndIf
	SendMessage(ah.hred,REM_REPAINT,0,TRUE)

End Sub

Sub GetTheme(ByVal hWin As HWND,ByVal nInx As Integer)
	Dim ofs As Any Ptr
	Dim col As Integer

	tmpcol.racol.cmntback=thme(nInx).fbc.racol.cmntback
	tmpcol.racol.strback=thme(nInx).fbc.racol.strback
	tmpcol.racol.numback=thme(nInx).fbc.racol.numback
	tmpcol.racol.oprback=thme(nInx).fbc.racol.oprback
	ofs=@thme(nInx)
	nInx=0
	Do While nInx<21
		ofs=ofs+4
		RtlMoveMemory(@col,ofs,4)
		SendDlgItemMessage(hWin,IDC_LSTKWCOLORS,LB_SETITEMDATA,nInx,col)
		nInx=nInx+1
	Loop
	InvalidateRect(GetDlgItem(hWin,IDC_LSTKWCOLORS),NULL,TRUE)
	nInx=0
	Do While nInx<27
		ofs+=4
		RtlMoveMemory(@col,ofs,4)
		SendDlgItemMessage(hWin,IDC_LSTCOLORS,LB_SETITEMDATA,nInx,col)
		If nInx=13 Then
			ofs+=16
		EndIf
		nInx+=1
	Loop
	InvalidateRect(GetDlgItem(hWin,IDC_LSTCOLORS),NULL,TRUE)

End Sub

Sub PutTheme(ByVal hWin As HWND,ByVal nInx As Integer)
	Dim ofs As Any Ptr
	Dim col As Integer

	thme(nInx).fbc.racol.cmntback=tmpcol.racol.cmntback
	thme(nInx).fbc.racol.strback=tmpcol.racol.strback
	thme(nInx).fbc.racol.numback=tmpcol.racol.numback
	thme(nInx).fbc.racol.oprback=tmpcol.racol.oprback
	ofs=@thme(nInx)
	nInx=0
	Do While nInx<21
		ofs+=4
		col=SendDlgItemMessage(hWin,IDC_LSTKWCOLORS,LB_GETITEMDATA,nInx,0)
		RtlMoveMemory(ofs,@col,4)
		nInx+=1
	Loop
	nInx=0
	Do While nInx<27
		ofs+=4
		col=SendDlgItemMessage(hWin,IDC_LSTCOLORS,LB_GETITEMDATA,nInx,0)
		RtlMoveMemory(ofs,@col,4)
		If nInx=13 Then
			ofs+=16
		EndIf
		nInx+=1
	Loop

End Sub

Sub SaveEditOptions (ByVal hWin As HWND)

	Dim nInx    As Integer
	Dim ofs     As Any Ptr
	Dim col     As Integer
	Dim lfnt    As LOGFONT
	Dim sItem   As ZString * 256
    Dim Success As BOOL          = Any

	' Window colors
	ofs=@fbcol
	nInx=0
	Do While nInx<27
		col=SendDlgItemMessage(hWin,IDC_LSTCOLORS,LB_GETITEMDATA,nInx,0)
		RtlMoveMemory(ofs,@col,4)
		If nInx=13 Then
			ofs+=16
		EndIf
		ofs+=4
		nInx+=1
	Loop
	' Syntax back colors
	fbcol.racol.cmntback=tmpcol.racol.cmntback
	fbcol.racol.strback=tmpcol.racol.strback
	fbcol.racol.oprback=tmpcol.racol.oprback
	fbcol.racol.numback=tmpcol.racol.numback
	SaveToIni(StrPtr("Win"),StrPtr("Colors"),"4444444444444444444444444444444",@fbcol,FALSE)
	' Keyword colors
	ofs=@kwcol
	nInx=0
	Do While nInx<21
		col=SendDlgItemMessage(hWin,IDC_LSTKWCOLORS,LB_GETITEMDATA,nInx,0)
		RtlMoveMemory(ofs,@col,4)
		ofs=ofs+4
		nInx=nInx+1
	Loop
	SaveToIni(StrPtr("Edit"),StrPtr("Colors"),"444444444444444444444",@kwcol,FALSE)
	' Custom colors
	SaveToIni(StrPtr("Edit"),StrPtr("CustColors"),"444444444444444444444",@custcol,FALSE)
	' KeyWords
	nInx=0
	Do While nInx<22
		buff=Chr(34) & sKeyWords(nInx) & Chr(34)
		WritePrivateProfileString("Edit","C" & Str(nInx),@buff,@ad.IniFile)
		nInx=nInx+1
	Loop


    ' TODO

	GetObject hCFont, SizeOf (LOGFONT), @lfnt
	DeleteObject ah.rafnt.hFont
	ah.rafnt.hFont    = CreateFontIndirect (@lfnt)
	edtfnt.size       = lfnt.lfHeight
	edtfnt.charset    = lfnt.lfCharSet
	edtfnt.weight     = lfnt.lfWeight
	edtfnt.italics    = lfnt.lfItalic
	*edtfnt.szFont    = lfnt.lfFaceName
    SaveToIni @"Edit", @"EditFont", "54044", @edtfnt, FALSE

	lfnt.lfItalic     = TRUE
	DeleteObject ah.rafnt.hIFont
	ah.rafnt.hIFont   = CreateFontIndirect (@lfnt)

	GetObject hLFont, SizeOf (LOGFONT), @lfnt
	DeleteObject ah.rafnt.hLnrFont
	ah.rafnt.hLnrFont = CreateFontIndirect (@lfnt)
	lnrfnt.size       = lfnt.lfHeight
	lnrfnt.charset    = lfnt.lfCharSet
	lnrfnt.weight     = lfnt.lfWeight
	lnrfnt.italics    = lfnt.lfItalic
	*lnrfnt.szFont    = lfnt.lfFaceName
	SaveToIni @"Edit", @"LnrFont", "54044", @lnrfnt, FALSE

	GetObject hTFont, SizeOf (LOGFONT), @lfnt
	ah.hToolFont      = CreateFontIndirect (@lfnt)
	toolfnt.size      = lfnt.lfHeight
	toolfnt.charset   = lfnt.lfCharSet
	toolfnt.weight    = lfnt.lfWeight
	toolfnt.italics   = lfnt.lfItalic
	*toolfnt.szFont   = lfnt.lfFaceName
	SaveToIni @"Edit", @"ToolFont", "54044", @toolfnt, FALSE

	GetObject hOFont, SizeOf (LOGFONT), @lfnt
	ah.hOutFont       = CreateFontIndirect (@lfnt)
	outpfnt.size      = lfnt.lfHeight
	outpfnt.charset   = lfnt.lfCharSet
	outpfnt.weight    = lfnt.lfWeight
	outpfnt.italics   = lfnt.lfItalic
	*outpfnt.szFont   = lfnt.lfFaceName
	SaveToIni @"Edit", @"OutpFont", "54044", @outpfnt, FALSE

	SendMessage ah.hcc,       WM_SETFONT, Cast (WPARAM, ah.hToolFont), FALSE
	SendMessage ah.htt,       WM_SETFONT, Cast (WPARAM, ah.hToolFont), FALSE
	SendMessage ah.hpr,       WM_SETFONT, Cast (WPARAM, ah.hToolFont), FALSE
	SendMessage ah.hprj,      WM_SETFONT, Cast (WPARAM, ah.hToolFont), FALSE
	SendMessage ah.hfib,      WM_SETFONT, Cast (WPARAM, ah.hToolFont), FALSE
	SendMessage ah.htab,      WM_SETFONT, Cast (WPARAM, ah.hToolFont), FALSE
	SendMessage ah.htabtool,  WM_SETFONT, Cast (WPARAM, ah.hToolFont), FALSE

	SendMessage ah.hout,      WM_SETFONT, Cast (WPARAM, ah.hOutFont ), FALSE
	SendMessage ah.himm,      WM_SETFONT, Cast (WPARAM, ah.hOutFont ), FALSE
	SendMessage ah.hregister, WM_SETFONT, Cast (WPARAM, ah.hOutFont ), FALSE
	SendMessage ah.hfpu,      WM_SETFONT, Cast (WPARAM, ah.hOutFont ), FALSE
	SendMessage ah.hmmx,      WM_SETFONT, Cast (WPARAM, ah.hOutFont ), FALSE
    SendMessage ah.hpr,       PRM_REFRESHLIST, 0, 0

	' Edit options
	edtopt.tabsize=GetDlgItemInt(hWin,IDC_EDTTABSIZE,NULL,FALSE)
	edtopt.ExtraLineSpace=GetDlgItemInt(hWin,IDC_EDTEXTRALINESPACE,NULL,FALSE)
	edtopt.expand=IsDlgButtonChecked(hWin,IDC_CHKEXPAND)
	edtopt.hiliteline=IsDlgButtonChecked(hWin,IDC_CHKHILITELINE)
	edtopt.autoindent=IsDlgButtonChecked(hWin,IDC_CHKAUTOINDENT)
	edtopt.hilitecmnt=IsDlgButtonChecked(hWin,IDC_CHKHILITECMNT)
	edtopt.linenumbers=IsDlgButtonChecked(hWin,IDC_CHKLINENUMBERS)
	wpos.singleinstance=IsDlgButtonChecked(hWin,IDC_CHKSINGLEINSTANCE)
	edtopt.backup=GetDlgItemInt(hWin,IDC_EDTBACKUP,NULL,FALSE)
	edtopt.bracematch=IsDlgButtonChecked(hWin,IDC_CHKBRACEMATCH)
	edtopt.autobrace=IsDlgButtonChecked(hWin,IDC_CHKAUTOBRACE)
	If IsDlgButtonChecked(hWin,IDC_RBNCASENONE) Then
		edtopt.autocase=0
	ElseIf IsDlgButtonChecked(hWin,IDC_RBNCASEMIXED) Then
		edtopt.autocase=1
	ElseIf IsDlgButtonChecked(hWin,IDC_RBNCASELOWER) Then
		edtopt.autocase=2
	ElseIf IsDlgButtonChecked(hWin,IDC_RBNCASEUPPER) Then
		edtopt.autocase=3
	EndIf
	edtopt.autoblock=IsDlgButtonChecked(hWin,IDC_CHKAUTOBLOCK)
	edtopt.autoformat=IsDlgButtonChecked(hWin,IDC_CHKAUTOFORMAT)
	edtopt.codecomplete=IsDlgButtonChecked(hWin,IDC_CHKCODECOMPLETE)
	edtopt.autosave=IsDlgButtonChecked(hWin,IDC_CHKSAVE)
	edtopt.autoload=IsDlgButtonChecked(hWin,IDC_CHKAUTOLOAD)
	edtopt.autowidth=IsDlgButtonChecked(hWin,IDC_CHKAUTOWIDTH)
	edtopt.autoinclude=IsDlgButtonChecked(hWin,IDC_CHKAUTOINCLUDE)
	edtopt.closeonlocks=IsDlgButtonChecked(hWin,IDC_CHKCLOSEONLOCKS)
	edtopt.tooltip=IsDlgButtonChecked(hWin,IDC_CHKTOOLTIP)
	edtopt.smartmath=IsDlgButtonChecked(hWin,IDC_CHKSMARTMATHS)
	'================ MOD
	SaveToIni @"Edit", @"EditOpt", "444444444444444444444", @edtopt, FALSE
	SaveToIni @"Win",  @"Winpos",  "444444444444444",       @wpos,   FALSE
	WritePrivateProfileString "Win", "Splash", Str (IsDlgButtonChecked (hWin, IDC_CHKSHOWSPLASH)), @ad.IniFile
	' Save theme
	sItem=String(32,0)
	WritePrivateProfileSection(StrPtr("Theme"),@sItem,@ad.IniFile)
	nInx=SendDlgItemMessage(hWin,IDC_CBOTHEME,CB_GETCURSEL,0,0)
	sItem=Str(nInx)
	WritePrivateProfileString(StrPtr("Theme"),StrPtr("Current"),@sItem,@ad.IniFile)
	PutTheme(hWin,nInx)
	For nInx=1 To 15
		If lstrlen(thme(nInx).lpszTheme) Then
			SaveToIni(StrPtr("Theme"),Str(nInx),"04444444444444444444444444444444444444444444444444444",@thme(nInx),FALSE)
		EndIf
	Next

	GetDlgItemText hWin, IDC_EDTCODEFILES, @CodeFiles, SizeOf (CodeFiles)
	Success = FormatDEVStr (CodeFiles, SizeOf (CodeFiles))
 	If Success = FALSE Then
        TextToOutput "*** invalid extension list ***", MB_ICONASTERISK
 	EndIf
	WritePrivateProfileString @"Edit", @"CodeFiles", @CodeFiles, @ad.IniFile

	GetDlgItemText hWin, IDC_EDTOPENEXTERN, @OpenExternFiles, SizeOf (OpenExternFiles)
    Success = FormatDEVStr (OpenExternFiles, SizeOf (OpenExternFiles))
 	If Success = FALSE Then
        TextToOutput "*** invalid extension list ***", MB_ICONASTERISK
 	EndIf
	WritePrivateProfileString @"Open", @"Extern", @OpenExternFiles, @ad.IniFile

	If edtopt.bracematch Then
		SendMessage(ah.hout,REM_BRACKETMATCH,0,Cast(Integer,@szBracketMatch))
	Else
		SendMessage(ah.hout,REM_BRACKETMATCH,0,Cast(Integer,StrPtr("")))
	EndIf
	SetToolsColors
	SetHiliteWords(ah.hwnd)
	SetHiliteWordsFromApi(ah.hwnd)
	UpdateAllTabs(1)                     ' update editor options

End Sub

Sub UpdateEditOptions (ByVal hEditor As HWND)

	Dim style      As Integer = Any
    Dim EditorMode As Long    = Any
    Dim HexFont    As HEFONT  = Any
    Dim HexColor   As HECOLOR = Any

    If hEditor Then
        EditorMode = GetWindowLong (hEditor, GWL_ID)

        Select Case EditorMode
        Case IDC_CODEED, IDC_TEXTED
        	SendMessage hEditor, REM_SETCOLOR, 0, Cast (LPARAM, @fbcol.racol)
        	SendMessage hEditor, REM_SETFONT, Abs (edtfnt.size) * edtopt.ExtraLineSpace \ 4, Cast (LPARAM, @ah.rafnt)
        	SendMessage hEditor, REM_TABWIDTH, edtopt.tabsize, edtopt.expand
        	SendMessage hEditor, REM_AUTOINDENT, 0, edtopt.autoindent
        	SendMessage hEditor, REM_HILITEACTIVELINE, 0, IIf (edtopt.hiliteline, 2, 0)

        	style = GetWindowLong (hEditor, GWL_STYLE)

        	If edtopt.hilitecmnt Then
        		style = style Or STYLE_HILITECOMMENT              ' set bit
        	Else
               	style = style And (-1 Xor STYLE_HILITECOMMENT)    ' reset bit
        	EndIf
        	SetWindowLong hEditor, GWL_STYLE, style

        	'TODO
            'SendMessage(hEdt,REM_SETSTYLEEX,STYLEEX_LOCK Or STYLEEX_BLOCKGUIDE Or STILEEX_LINECHANGED Or STILEEX_STRINGMODEFB,0)
        	'SendMessage(hEdt,REM_SETSTYLEEX,STYLEEX_BLOCKGUIDE Or STILEEX_LINECHANGED Or STILEEX_STRINGMODEFB,0)

        Case IDC_HEXED

            Hexcolor.bckcol		  =	fbcol.racol.bckcol		    ' Back color
            Hexcolor.adrtxtcol	  =	fbcol.racol.numcol		    ' Address text color
            Hexcolor.dtatxtcol	  =	fbcol.racol.txtcol		    ' Data text color
            Hexcolor.asctxtcol	  =	fbcol.racol.cmntcol		    ' ASCII text color
            Hexcolor.selbckcol	  =	fbcol.racol.selbckcol		' Sel back color
            Hexcolor.sellfbckcol  = fbcol.racol.selbckcol		' Sel lost focus back color
            Hexcolor.seltxtcol	  =	fbcol.racol.seltxtcol		' Sel text color
            Hexcolor.selascbckcol =	fbcol.racol.selbckcol		' Sel back color
            Hexcolor.selbarbck	  =	fbcol.racol.selbarbck		' Selection bar
            Hexcolor.selbarpen	  =	fbcol.racol.selbarpen		' Selection bar pen
            Hexcolor.lnrcol		  =	fbcol.racol.lnrcol		    ' Line numbers color
            SendMessage hEditor, HEM_SETCOLOR, 0, Cast (LPARAM, @HexColor)

    	    HexFont.hFont    = ah.rafnt.hFont
    	    HexFont.hLnrFont = ah.rafnt.hLnrFont
    	    SendMessage hEditor, HEM_SETFONT, Abs (edtfnt.size) * edtopt.ExtraLineSpace \ 4, Cast (LPARAM, @HexFont)
            'SendMessage hEdt, HEM_LINENUMBERWIDTH, 50, 0
            'SendMessage hEdt, HEM_SELBARWIDTH, 50, 0
        End Select
    EndIf

End Sub

Sub GetList(ByVal hWin As HWND)
	Dim nInx As Integer
	Dim sItem As String*256
	Dim x As Integer

	SetZStrEmpty (buff)             'MOD 26.1.2012
	nInx=0
	Do While SendDlgItemMessage(hWin,IDC_LSTKWACTIVE,LB_GETTEXT,nInx,Cast(Integer,@sItem))<>LB_ERR
		buff=buff & sItem & " "
		nInx=nInx+1
	Loop
	sKeyWords(oldsel)=buff
	x=SendDlgItemMessage(hWin,IDC_LSTKWCOLORS,LB_GETITEMDATA,oldsel,0)
	x=x And &HFFFFFF
	If IsDlgButtonChecked(hWin,IDC_CHKBOLD) Then
		x=x Or (1 Shl 24)
	EndIf
	If IsDlgButtonChecked(hWin,IDC_CHKITALIC) Then
		x=x Or (1 Shl 25)
	EndIf
	If IsDlgButtonChecked(hWin,IDC_CHKRCFILE) Then
		x=x Or (2 Shl 28)
	EndIf
	If IsDlgButtonChecked(hWin,IDC_CHKASM) Then
		x=x Or (1 Shl 28)
	EndIf
	SendDlgItemMessage(hWin,IDC_LSTKWCOLORS,LB_SETITEMDATA,oldsel,x)

End Sub

Sub FillList(ByVal hWin As HWND)
	Dim nInx As Integer
	Dim sItem As String*256
	Dim x As Integer

	SendDlgItemMessage(hWin,IDC_LSTKWACTIVE,LB_RESETCONTENT,0,0)
	nInx=SendDlgItemMessage(hWin,IDC_LSTKWCOLORS,LB_GETCURSEL,0,0)

	'TODO
	buff=sKeyWords(nInx) & szNULL
	Do While Len(buff)
		x=InStr(buff," ")
		If x=0 Then
			x=Len(buff)+1
		EndIf
		sItem=Left(buff,x-1)
		SendDlgItemMessage(hWin,IDC_LSTKWACTIVE,LB_ADDSTRING,0,Cast(Integer,@sItem))
		buff=Mid(buff,x+1)
	Loop
	x=SendDlgItemMessage(hWin,IDC_LSTKWCOLORS,LB_GETITEMDATA,nInx,0)
	CheckDlgButton(hWin,IDC_CHKBOLD,((x Shr 24) And 1))
	CheckDlgButton(hWin,IDC_CHKITALIC,((x Shr 25) And 1))
	CheckDlgButton(hWin,IDC_CHKRCFILE,((x Shr 28) And 2))
	CheckDlgButton(hWin,IDC_CHKASM,((x Shr 28) And 1))
	oldsel=nInx

End Sub

Sub GetHold(ByVal hWin As HWND)
	Dim nInx As Integer
	Dim sItem As ZString*256

	SetZStrEmpty (buff)             'MOD 26.1.2012
	nInx=0
	Do While SendDlgItemMessage(hWin,IDC_LSTKWHOLD,LB_GETTEXT,nInx,Cast(Integer,@sItem))<>LB_ERR
		buff=buff & sItem & " "
		nInx=nInx+1
	Loop
	sKeyWords(21)=buff

End Sub

Sub FillHold(ByVal hWin As HWND)
	Dim nInx As Integer
	Dim sItem As ZString*256
	Dim x As Integer

    ' TODO
	buff=sKeyWords(21)
	Do While Len(buff)
		x=InStr(buff," ")
		If x=0 Then
			x=Len(buff)+1
		EndIf
		sItem=Left(buff,x-1)
		SendDlgItemMessage(hWin,IDC_LSTKWHOLD,LB_ADDSTRING,0,Cast(Integer,@sItem))
		buff=Mid(buff,x+1)
	Loop
	oldsel=nInx
End Sub

Function EditorOptDlgProc(ByVal hWin As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As Integer

	Dim As Long id, Event
	Static hBtnApply As HWND
	Dim lfnt As LOGFONT
	Dim cf As ChooseFont
	Dim hCtl As HWND
	Dim lpDRAWITEMSTRUCT As DRAWITEMSTRUCT Ptr
	Dim sItem As ZString*256
	Dim nInx As Integer
	Dim rect As RECT
	Dim hBr As HBRUSH
	Dim ofs As Any Ptr
	Dim col As Integer
	Dim cc As ChooseColor
	Dim x As Integer
	Dim pt As Point
    Dim i   As Integer = Any
    Dim Key As ZString * 32
    Dim Success As BOOL = Any

	Select Case uMsg
		Case WM_INITDIALOG
			TranslateDialog(hWin,IDD_DLG_EDITOROPTION)
			CenterOwner(hWin)

			' Bitmap buttons
			SendDlgItemMessage hWin, IDC_BTNHOLD  , BM_SETIMAGE, IMAGE_ICON, Cast (LPARAM, ImageList_GetIcon (ah.hmnuiml, 1, ILD_NORMAL))
			SendDlgItemMessage hWin, IDC_BTNACTIVE, BM_SETIMAGE, IMAGE_ICON, Cast (LPARAM, ImageList_GetIcon (ah.hmnuiml, 0, ILD_NORMAL))

			' Themes
			SendDlgItemMessage(hWin,IDC_CBOTHEME,CB_ADDSTRING,0,Cast(Integer,StrPtr("New Theme")))
			nInx=0
			For col=1 To 15
				sItem=Str(col)
				szTheme(0)=String(32,0)
				LoadFromIni "Theme", @sItem, "044444444444444444444444444444444444444444444444444", @thme(col), FALSE
				If lstrlen(thme(col).lpszTheme) Then
					sItem=String(32,0)
					lstrcpy(@sItem,thme(col).lpszTheme)
					nInx=SendDlgItemMessage(hWin,IDC_CBOTHEME,CB_ADDSTRING,0,Cast(Integer,@sItem))
				EndIf
			Next
			If nInx=0 Then
				PutTheme(hWin,1)
				szTheme(1)="Default"
				SendDlgItemMessage(hWin,IDC_CBOTHEME,CB_ADDSTRING,0,Cast(Integer,StrPtr("Default")))
			EndIf
			nInx=GetPrivateProfileInt(StrPtr("Theme"),StrPtr("Current"),1,@ad.IniFile)
			SendDlgItemMessage(hWin,IDC_CBOTHEME,CB_SETCURSEL,nInx,0)
			SendDlgItemMessage(hWin,IDC_CBOTHEME,CB_GETLBTEXT,nInx,Cast(Integer,@sItem))
			SetDlgItemText hWin, IDC_EDTTHEME, @sItem

			' Keywords
    	    For i = 0 To 21
         	Key = "C" + Str(i)
    			GetPrivateProfileString @"Edit", @Key, NULL, @buff, SizeOf (buff), @ad.IniFile
    			sKeyWords(i) = buff
			Next


			'GetPrivateProfileString(StrPtr("Edit"),StrPtr("C0"),@C0,@buff,SizeOf(buff),@ad.IniFile)
			'sKeyWords(0)=buff
			'GetPrivateProfileString(StrPtr("Edit"),StrPtr("C1"),@C1,@buff,SizeOf(buff),@ad.IniFile)
			'sKeyWords(1)=buff
			'GetPrivateProfileString(StrPtr("Edit"),StrPtr("C2"),@C2,@buff,SizeOf(buff),@ad.IniFile)
			'sKeyWords(2)=buff
			'GetPrivateProfileString(StrPtr("Edit"),StrPtr("C3"),@C3,@buff,SizeOf(buff),@ad.IniFile)
			'sKeyWords(3)=buff
			'GetPrivateProfileString(StrPtr("Edit"),StrPtr("C4"),@C4,@buff,SizeOf(buff),@ad.IniFile)
			'sKeyWords(4)=buff
			'GetPrivateProfileString(StrPtr("Edit"),StrPtr("C5"),@C5,@buff,SizeOf(buff),@ad.IniFile)
			'sKeyWords(5)=buff
			'GetPrivateProfileString(StrPtr("Edit"),StrPtr("C6"),@C6,@buff,SizeOf(buff),@ad.IniFile)
			'sKeyWords(6)=buff
			'GetPrivateProfileString(StrPtr("Edit"),StrPtr("C7"),@C7,@buff,SizeOf(buff),@ad.IniFile)
			'sKeyWords(7)=buff
			'GetPrivateProfileString(StrPtr("Edit"),StrPtr("C8"),@C8,@buff,SizeOf(buff),@ad.IniFile)
			'sKeyWords(8)=buff
			'GetPrivateProfileString(StrPtr("Edit"),StrPtr("C9"),@C9,@buff,SizeOf(buff),@ad.IniFile)
			'sKeyWords(9)=buff
			'GetPrivateProfileString(StrPtr("Edit"),StrPtr("C10"),@C10,@buff,SizeOf(buff),@ad.IniFile)
			'sKeyWords(10)=buff
			'GetPrivateProfileString(StrPtr("Edit"),StrPtr("C11"),@C11,@buff,SizeOf(buff),@ad.IniFile)
			'sKeyWords(11)=buff
			'GetPrivateProfileString(StrPtr("Edit"),StrPtr("C12"),@C12,@buff,SizeOf(buff),@ad.IniFile)
			'sKeyWords(12)=buff
			'GetPrivateProfileString(StrPtr("Edit"),StrPtr("C13"),@C13,@buff,SizeOf(buff),@ad.IniFile)
			'sKeyWords(13)=buff
			'GetPrivateProfileString(StrPtr("Edit"),StrPtr("C14"),@C14,@buff,SizeOf(buff),@ad.IniFile)
			'sKeyWords(14)=buff
			'GetPrivateProfileString(StrPtr("Edit"),StrPtr("C15"),@C15,@buff,SizeOf(buff),@ad.IniFile)
			'sKeyWords(15)=buff
			'GetPrivateProfileString(StrPtr("Edit"),StrPtr("C16"),@C16,@buff,SizeOf(buff),@ad.IniFile)
			'sKeyWords(16)=buff
			'GetPrivateProfileString(StrPtr("Edit"),StrPtr("C17"),@C17,@buff,SizeOf(buff),@ad.IniFile)
			'sKeyWords(17)=buff
			'GetPrivateProfileString(StrPtr("Edit"),StrPtr("C18"),@C18,@buff,SizeOf(buff),@ad.IniFile)
			'sKeyWords(18)=buff
			'GetPrivateProfileString(StrPtr("Edit"),StrPtr("C19"),@C19,@buff,SizeOf(buff),@ad.IniFile)
			'sKeyWords(19)=buff
			'GetPrivateProfileString(StrPtr("Edit"),StrPtr("C20"),@C20,@buff,SizeOf(buff),@ad.IniFile)
			'sKeyWords(20)=buff
			'GetPrivateProfileString(StrPtr("Edit"),StrPtr("C21"),@C21,@buff,SizeOf(buff),@ad.IniFile)
			'sKeyWords(21)=buff

			' Misc
			SendDlgItemMessage(hWin,IDC_SPNTABSIZE,UDM_SETRANGE,0,&H00010014)		            ' Set range
			SendDlgItemMessage(hWin,IDC_SPNTABSIZE,UDM_SETPOS,0,edtopt.tabsize)	                ' Set default value
			'
			SendDlgItemMessage(hWin,IDC_SPNBACKUP,UDM_SETRANGE,0,&H00000009)	              	' Set range
			SendDlgItemMessage(hWin,IDC_SPNBACKUP,UDM_SETPOS,0,edtopt.backup)	                ' Set default value
			'
			SendDlgItemMessage(hWin,IDC_SPNEXTRALINESPACE,UDM_SETRANGE,0,&H00000008)		    ' Set range
			SendDlgItemMessage(hWin,IDC_SPNEXTRALINESPACE,UDM_SETPOS,0,edtopt.ExtraLineSpace)	' Set default value
			'
			CheckDlgButton(hWin,IDC_CHKEXPAND,edtopt.expand)
			CheckDlgButton(hWin,IDC_CHKAUTOINDENT,edtopt.autoindent)
			CheckDlgButton(hWin,IDC_CHKHILITELINE,edtopt.hiliteline)
			CheckDlgButton(hWin,IDC_CHKHILITECMNT,edtopt.hilitecmnt)
			CheckDlgButton(hWin,IDC_CHKLINENUMBERS,edtopt.linenumbers)
			CheckDlgButton(hWin,IDC_CHKSINGLEINSTANCE,wpos.singleinstance)
			CheckDlgButton(hWin,IDC_CHKBRACEMATCH,edtopt.bracematch)
			CheckDlgButton(hWin,IDC_CHKAUTOBRACE,edtopt.autobrace)
			CheckDlgButton(hWin,IDC_RBNCASENONE+edtopt.autocase,BST_CHECKED)
			CheckDlgButton(hWin,IDC_CHKAUTOBLOCK,edtopt.autoblock)
			CheckDlgButton(hWin,IDC_CHKAUTOFORMAT,edtopt.autoformat)
			CheckDlgButton(hWin,IDC_CHKCODECOMPLETE,edtopt.codecomplete)
			CheckDlgButton(hWin,IDC_CHKSAVE,edtopt.autosave)
			CheckDlgButton(hWin,IDC_CHKAUTOLOAD,edtopt.autoload)
			CheckDlgButton(hWin,IDC_CHKAUTOWIDTH,edtopt.autowidth)
			CheckDlgButton(hWin,IDC_CHKAUTOINCLUDE,edtopt.autoinclude)
			CheckDlgButton(hWin,IDC_CHKCLOSEONLOCKS,edtopt.closeonlocks)
			CheckDlgButton(hWin,IDC_CHKTOOLTIP,edtopt.tooltip)
			CheckDlgButton(hWin,IDC_CHKSMARTMATHS,edtopt.smartmath)
			CheckDlgButton(hWin,IDC_CHKSHOWSPLASH, GetPrivateProfileInt ("Win", "Splash", 1, @ad.IniFile))
			' Fonts
			GetObject(ah.rafnt.hFont,SizeOf(LOGFONT),@lfnt)
			hCFont=CreateFontIndirect(@lfnt)
			SendDlgItemMessage(hWin,IDC_STCCODEFONT,WM_SETFONT,Cast(Integer,hCFont),FALSE)
			GetObject(ah.rafnt.hLnrFont,SizeOf(LOGFONT),@lfnt)
			hLFont=CreateFontIndirect(@lfnt)
			SendDlgItemMessage(hWin,IDC_STCLNRFONT,WM_SETFONT,Cast(Integer,hLFont),FALSE)
			GetObject(ah.hToolFont,SizeOf(LOGFONT),@lfnt)
			hTFont=CreateFontIndirect(@lfnt)
			SendDlgItemMessage(hWin,IDC_STCTOOLSFONT,WM_SETFONT,Cast(Integer,hTFont),FALSE)

			GetObject ah.hOutFont, SizeOf (LOGFONT), @lfnt
			hOFont = CreateFontIndirect (@lfnt)
			SendDlgItemMessage   hWin, IDC_STCOUTPFONT, WM_SETFONT, Cast (WPARAM, hOFont), FALSE

			hBtnApply=GetDlgItem(hWin,IDC_BTNKWAPPLY)
			' Colors
			tmpcol=fbcol
			buff=sColors
			ofs=@fbcol
			' TODO
			nInx=0
			Do While Len(buff)
				nInx=InStr(buff,",")
				If nInx=0 Then
					nInx=Len(buff)+1
				EndIf
				sItem=Left(buff,nInx-1)
				buff=Mid(buff,nInx+1)
				RtlMoveMemory(@col,ofs,4)
				nInx=SendDlgItemMessage(hWin,IDC_LSTCOLORS,LB_ADDSTRING,0,Cast(Integer,@sItem))
				SendDlgItemMessage(hWin,IDC_LSTCOLORS,LB_SETITEMDATA,nInx,col)
				If nInx=13 Then
					ofs+=16
				EndIf
				ofs+=4
			Loop
			SendDlgItemMessage(hWin,IDC_LSTCOLORS,LB_SETCURSEL,0,0)
			' Keyword colors
			ofs=@kwcol
			nInx=0
			Do While nInx<21
				If nInx<12 Or nInx>18 Then
					sItem="C" & Str(nInx)
				ElseIf nInx=12 Then
					sItem="Data types"
				ElseIf nInx=13 Then
					sItem="Api struct"
				ElseIf nInx=14 Then
					sItem="Api const"
				ElseIf nInx=15 Then
					sItem="Api calls"
				ElseIf nInx=16 Then
					sItem="Custom1" 		'struct's project
				ElseIf nInx=17 Then
					sItem="Custom2" 		'const's project
				ElseIf nInx=18 Then
					sItem="Custom3" 		'sub/function's project
				EndIf
				RtlMoveMemory(@col,ofs,4)
				SendDlgItemMessage(hWin,IDC_LSTKWCOLORS,LB_ADDSTRING,0,Cast(Integer,@sItem))
				SendDlgItemMessage(hWin,IDC_LSTKWCOLORS,LB_SETITEMDATA,nInx,col)
				ofs=ofs+4
				nInx=nInx+1
			Loop
			SendDlgItemMessage(hWin,IDC_LSTKWCOLORS,LB_SETCURSEL,0,0)
			SetDlgItemText(hWin,IDC_EDTCODEFILES,@CodeFiles)
			SetDlgItemText(hWin,IDC_EDTOPENEXTERN,@OpenExternFiles)
			FillList(hWin)
			FillHold(hWin)
			EnableWindow(hBtnApply,FALSE)

		Case WM_COMMAND
			id = LoWord (wParam)
			Event = HiWord (wParam)
			Select Case Event
				Case BN_CLICKED
					Select Case id
						Case IDOK
							If IsWindowEnabled(hBtnApply) Then
								GetList(hWin)
								GetHold(hWin)
								SaveEditOptions hWin
							EndIf
							SendMessage(hWin,WM_CLOSE,0,0)
							'
						Case IDCANCEL
							SendMessage(hWin,WM_CLOSE,0,0)
							'
						Case IDC_BTNKWAPPLY
							GetList(hWin)
							GetHold(hWin)
							SaveEditOptions hWin
							EnableWindow(hBtnApply,FALSE)
							'
						Case IDC_BTNACTIVE
							nInx=0
							Do While TRUE
								col=SendDlgItemMessage(hWin,IDC_LSTKWHOLD,LB_GETSEL,nInx,0)
								If col=LB_ERR Then
									Exit Do
								ElseIf col Then
									SendDlgItemMessage(hWin,IDC_LSTKWHOLD,LB_GETTEXT,nInx,Cast(Integer,@buff))
									SendDlgItemMessage(hWin,IDC_LSTKWACTIVE,LB_ADDSTRING,0,Cast(Integer,@buff))
									SendDlgItemMessage(hWin,IDC_LSTKWHOLD,LB_DELETESTRING,nInx,0)
									EnableWindow(hBtnApply,TRUE)
								Else
									nInx=nInx+1
								EndIf
							Loop
							EnableDlgItem(hWin,IDC_BTNACTIVE,FALSE)
							'
						Case IDC_BTNHOLD
							nInx=0
							Do
								col=SendDlgItemMessage(hWin,IDC_LSTKWACTIVE,LB_GETSEL,nInx,0)
								If col=LB_ERR Then
									Exit Do
								ElseIf col Then
									SendDlgItemMessage(hWin,IDC_LSTKWACTIVE,LB_GETTEXT,nInx,Cast(Integer,@buff))
									SendDlgItemMessage(hWin,IDC_LSTKWHOLD,LB_ADDSTRING,0,Cast(Integer,@buff))
									SendDlgItemMessage(hWin,IDC_LSTKWACTIVE,LB_DELETESTRING,nInx,0)
									EnableWindow(hBtnApply,TRUE)
								Else
									nInx=nInx+1
								EndIf
							Loop
							EnableDlgItem(hWin,IDC_BTNDEL,FALSE)
							EnableDlgItem(hWin,IDC_BTNHOLD,FALSE)
							'
						Case IDC_BTNADD
							GetDlgItemText(hWin,IDC_EDTKW,@buff,32)
							SendDlgItemMessage(hWin,IDC_LSTKWACTIVE,LB_ADDSTRING,0,Cast(Integer,@buff))
							SetDlgItemText(hWin,IDC_EDTKW,StrPtr(""))
							EnableWindow(hBtnApply,TRUE)
							'
						Case IDC_BTNDEL
							nInx=0
							Do
								col=SendDlgItemMessage(hWin,IDC_LSTKWACTIVE,LB_GETSEL,nInx,0)
								If col=LB_ERR Then
									Exit Do
								ElseIf col Then
									SendDlgItemMessage(hWin,IDC_LSTKWACTIVE,LB_DELETESTRING,nInx,0)
								Else
									nInx=nInx+1
								EndIf
							Loop
							nInx=SendDlgItemMessage(hWin,IDC_LSTKWACTIVE,LB_GETSELCOUNT,0,0)
							EnableDlgItem(hWin,IDC_BTNDEL,nInx)
							EnableDlgItem(hWin,IDC_BTNHOLD,nInx)
							EnableWindow(hBtnApply,TRUE)
							'
					    Case IDC_CHKITALIC,         IDC_CHKBOLD,         IDC_CHKRCFILE,     IDC_CHKASM, _
							 IDC_CHKAUTOINDENT,     IDC_CHKHILITELINE,   IDC_CHKHILITECMNT, IDC_CHKLINENUMBERS, _
							 IDC_CHKSINGLEINSTANCE, IDC_CHKBRACEMATCH,   IDC_CHKAUTOBRACE,  IDC_RBNCASENONE, _
                             IDC_RBNCASEMIXED,      IDC_RBNCASELOWER,    IDC_RBNCASEUPPER,  IDC_CHKAUTOBLOCK, _
                             IDC_CHKAUTOFORMAT,     IDC_CHKCODECOMPLETE, IDC_CHKSAVE,       IDC_CHKAUTOLOAD, _
                             IDC_CHKAUTOWIDTH,      IDC_CHKAUTOINCLUDE,  IDC_CHKTOOLTIP,    IDC_CHKCLOSEONLOCKS, _
                             IDC_CHKSHOWSPLASH,     IDC_CHKSMARTMATHS,   IDC_CHKEXPAND
							EnableWindow(hBtnApply,TRUE)
							'
						Case IDC_CHKCOLORBOLD
							EnableWindow(hBtnApply,TRUE)
							nInx=SendDlgItemMessage(hWin,IDC_LSTCOLORS,LB_GETCURSEL,0,0)
							col=SendDlgItemMessage(hWin,IDC_LSTCOLORS,LB_GETITEMDATA,nInx,0)
							col=col And (-1 Xor 2^24)
							If IsDlgButtonChecked(hWin,IDC_CHKCOLORBOLD) Then
								col=col Or 2^24
							EndIf
							SendDlgItemMessage(hWin,IDC_LSTCOLORS,LB_SETITEMDATA,nInx,col)
							'
						Case IDC_CHKCOLORITALIC
							EnableWindow(hBtnApply,TRUE)
							nInx=SendDlgItemMessage(hWin,IDC_LSTCOLORS,LB_GETCURSEL,0,0)
							col=SendDlgItemMessage(hWin,IDC_LSTCOLORS,LB_GETITEMDATA,nInx,0)
							col=col And (-1 Xor 2^25)
							If IsDlgButtonChecked(hWin,IDC_CHKCOLORITALIC) Then
								col=col Or 2^25
							EndIf
							SendDlgItemMessage(hWin,IDC_LSTCOLORS,LB_SETITEMDATA,nInx,col)
							'
						Case IDC_BTNCODEFONT
							GetObject(hCFont,SizeOf(LOGFONT),@lfnt)
							cf.lStructSize=SizeOf(cf)
							cf.hwndOwner=hWin
							cf.lpLogFont=@lfnt
							cf.Flags=CF_SCREENFONTS Or CF_INITTOLOGFONTSTRUCT
							If ChooseFont(@cf) Then
								DeleteObject(hCFont)
								hCFont=CreateFontIndirect(@lfnt)
								SendDlgItemMessage(hWin,IDC_STCCODEFONT,WM_SETFONT,Cast(Integer,hCFont),TRUE)
								EnableWindow(hBtnApply,TRUE)
							EndIf
							'
						Case IDC_BTNLNRFONT
							GetObject(hLFont,SizeOf(LOGFONT),@lfnt)
							cf.lStructSize=SizeOf(cf)
							cf.hwndOwner=hWin
							cf.lpLogFont=@lfnt
							cf.Flags=CF_SCREENFONTS Or CF_INITTOLOGFONTSTRUCT
							If ChooseFont(@cf) Then
								DeleteObject(hLFont)
								hLFont=CreateFontIndirect(@lfnt)
								SendDlgItemMessage(hWin,IDC_STCLNRFONT,WM_SETFONT,Cast(Integer,hLFont),TRUE)
								EnableWindow(hBtnApply,TRUE)
							EndIf
							'
						Case IDC_BTNTOOLSFONT
							GetObject(hTFont,SizeOf(LOGFONT),@lfnt)
							cf.lStructSize=SizeOf(cf)
							cf.hwndOwner=hWin
							cf.lpLogFont=@lfnt
							cf.Flags=CF_SCREENFONTS Or CF_INITTOLOGFONTSTRUCT
							If ChooseFont(@cf) Then
								DeleteObject(hTFont)
								hTFont=CreateFontIndirect(@lfnt)
								SendDlgItemMessage(hWin,IDC_STCTOOLSFONT,WM_SETFONT,Cast(Integer,hTFont),TRUE)
								EnableWindow(hBtnApply,TRUE)
							EndIf
							'
						Case IDC_BTNOUTPFONT
							GetObject(hOFont,SizeOf(LOGFONT),@lfnt)
							cf.lStructSize=SizeOf(cf)
							cf.hwndOwner=hWin
							cf.lpLogFont=@lfnt
							cf.Flags=CF_SCREENFONTS Or CF_INITTOLOGFONTSTRUCT
							If ChooseFont(@cf) Then
								DeleteObject(hOFont)
								hOFont=CreateFontIndirect(@lfnt)
								SendDlgItemMessage(hWin,IDC_STCOUTPFONT,WM_SETFONT,Cast(Integer,hOFont),TRUE)
								EnableWindow(hBtnApply,TRUE)
							EndIf
							'
					    Case IDC_BTNSAVETHEME
							GetDlgItemText(hWin,IDC_EDTTHEME,@sItem,32)
							nInx=SendDlgItemMessage(hWin,IDC_CBOTHEME,CB_ADDSTRING,0,Cast(Integer,@sItem))
							SendDlgItemMessage(hWin,IDC_CBOTHEME,CB_SETCURSEL,nInx,0)
							szTheme(nInx)=sItem
							PutTheme(hWin,nInx)
							EnableWindow(hBtnApply,TRUE)
							'
					End Select
					'
				Case EN_CHANGE
					Select Case id
					    Case IDC_EDTTABSIZE        , _
					         IDC_EDTEXTRALINESPACE , _
					         IDC_EDTBACKUP         , _
					         IDC_EDTOPENEXTERN     , _
					         IDC_EDTCODEFILES
							EnableWindow hBtnApply, TRUE
							'
					    Case IDC_EDTKW
							hCtl=GetDlgItem(hWin,IDC_BTNADD)
							EnableWindow(hCtl,GetDlgItemText(hWin,IDC_EDTKW,@buff,32))
							'
					End Select

			    Case EN_KILLFOCUS
			        Select Case id
        			Case IDC_EDTOPENEXTERN
        			    GetDlgItemText hWin, IDC_EDTOPENEXTERN, @buff, SizeOf (OpenExternFiles)
        		        Success = FormatDEVStr (buff, SizeOf (OpenExternFiles))
                     	If Success = FALSE Then
                            TextToOutput "*** invalid extension list ***", MB_ICONASTERISK
                     	EndIf
               			SetDlgItemText hWin, IDC_EDTOPENEXTERN, @buff
			        Case IDC_EDTCODEFILES
        			    GetDlgItemText hWin, IDC_EDTCODEFILES, @buff, SizeOf (CodeFiles)
        		        Success = FormatDEVStr (buff, SizeOf (CodeFiles))
                     	If Success = FALSE Then
                            TextToOutput "*** invalid extension list ***", MB_ICONASTERISK
                     	EndIf
               			SetDlgItemText hWin, IDC_EDTCODEFILES, @buff
			        End Select

				Case LBN_SELCHANGE
					Select Case id
						Case IDC_LSTKWCOLORS
							GetList(hWin)
							FillList(hWin)
							EnableDlgItem(hWin,IDC_BTNDEL,FALSE)
							EnableDlgItem(hWin,IDC_BTNHOLD,FALSE)
							'
						Case IDC_LSTKWACTIVE
							nInx=SendDlgItemMessage(hWin,IDC_LSTKWACTIVE,LB_GETSELCOUNT,0,0)
							EnableDlgItem(hWin,IDC_BTNDEL,nInx)
							EnableDlgItem(hWin,IDC_BTNHOLD,nInx)
							'
						Case IDC_LSTKWHOLD
							nInx=SendDlgItemMessage(hWin,IDC_LSTKWHOLD,LB_GETSELCOUNT,0,0)
							EnableDlgItem(hWin,IDC_BTNACTIVE,nInx)
							'
						Case IDC_CBOTHEME
							nInx=SendDlgItemMessage(hWin,IDC_CBOTHEME,CB_GETCURSEL,0,0)
							x=SendDlgItemMessage(hWin,IDC_CBOTHEME,CB_GETCOUNT,0,0)
							If x<16 And nInx=0 Then
								x=TRUE
							Else
								x=FALSE
							EndIf
							EnableDlgItem(hWin,IDC_BTNSAVETHEME,x)
							EnableDlgItem(hWin,IDC_EDTTHEME,x)
							SendDlgItemMessage(hWin,IDC_CBOTHEME,CB_GETLBTEXT,nInx,Cast(Integer,@sItem))
							SetDlgItemText hWin, IDC_EDTTHEME, @sItem
							If nInx Then
								GetTheme(hWin,nInx)
								EnableWindow(hBtnApply,TRUE)
							EndIf
							'
						Case IDC_LSTCOLORS
							nInx=SendDlgItemMessage(hWin,IDC_LSTCOLORS,LB_GETCURSEL,0,0)
							If nInx=4 Or nInx=5 Or nInx=6 Or nInx=13 Then
								EnableDlgItem(hWin,IDC_CHKCOLORBOLD,TRUE)
								EnableDlgItem(hWin,IDC_CHKCOLORITALIC,TRUE)
							Else
								EnableDlgItem(hWin,IDC_CHKCOLORBOLD,FALSE)
								EnableDlgItem(hWin,IDC_CHKCOLORITALIC,FALSE)
							EndIf
							col=SendDlgItemMessage(hWin,IDC_LSTCOLORS,LB_GETITEMDATA,nInx,0)
							CheckDlgButton(hWin,IDC_CHKCOLORBOLD,IIf(col And 2^24,BST_CHECKED,BST_UNCHECKED))
							CheckDlgButton(hWin,IDC_CHKCOLORITALIC,IIf(col And 2^25,BST_CHECKED,BST_UNCHECKED))
							'
					End Select
					'
				Case LBN_DBLCLK
					Select Case id
						Case IDC_LSTCOLORS
							cc.lStructSize=SizeOf(ChooseColor)
							cc.hwndOwner=hWin
							cc.hInstance=Cast(Any Ptr,hInstance)
							cc.lpCustColors=Cast(Any Ptr,@custcol)
							cc.Flags=CC_FULLOPEN Or CC_RGBINIT
							cc.lCustData=0
							cc.lpfnHook=0
							cc.lpTemplateName=0
							nInx=SendDlgItemMessage(hWin,IDC_LSTCOLORS,LB_GETCURSEL,0,0)
							col=SendDlgItemMessage(hWin,IDC_LSTCOLORS,LB_GETITEMDATA,nInx,0)
							If (nInx>=4 And nInx<=6) Or nInx=13 Then
								GetCursorPos(@pt)
								ScreenToClient(Cast(HWND,lParam),@pt)
								If pt.x>30 And pt.x<55 Then
									Select Case nInx
										Case 4
											col=tmpcol.racol.cmntback
										Case 5
											col=tmpcol.racol.strback
										Case 6
											col=tmpcol.racol.oprback
										Case 13
											col=tmpcol.racol.numback
									End Select
								EndIf
							EndIf
							cc.rgbResult=col And &HFFFFFF
							If ChooseColor(@cc) Then
								If pt.x>30 And pt.x<55 Then
									Select Case nInx
										Case 4
											tmpcol.racol.cmntback=cc.rgbResult
										Case 5
											tmpcol.racol.strback=cc.rgbResult
										Case 6
											tmpcol.racol.oprback=cc.rgbResult
										Case 13
											tmpcol.racol.numback=cc.rgbResult
									End Select
								Else
									col=(col And &HFF000000) Or cc.rgbResult
									SendDlgItemMessage(hWin,IDC_LSTCOLORS,LB_SETITEMDATA,nInx,col)
								EndIf
								InvalidateRect(GetDlgItem(hWin,IDC_LSTCOLORS),NULL,TRUE)
								EnableWindow(hBtnApply,TRUE)
							EndIf
							'
						Case IDC_LSTKWCOLORS
							cc.lStructSize=SizeOf(ChooseColor)
							cc.hwndOwner=hWin
							cc.hInstance=Cast(Any Ptr,hInstance)
							cc.lpCustColors=Cast(Any Ptr,@custcol)
							cc.Flags=CC_FULLOPEN Or CC_RGBINIT
							cc.lCustData=0
							cc.lpfnHook=0
							cc.lpTemplateName=0
							nInx=SendDlgItemMessage(hWin,IDC_LSTKWCOLORS,LB_GETCURSEL,0,0)
							col=SendDlgItemMessage(hWin,IDC_LSTKWCOLORS,LB_GETITEMDATA,nInx,0)
							cc.rgbResult=col And &HFFFFFF
							If ChooseColor(@cc) Then
								col=(col And &HFF000000) Or cc.rgbResult
								SendDlgItemMessage(hWin,IDC_LSTKWCOLORS,LB_SETITEMDATA,nInx,col)
								InvalidateRect(GetDlgItem(hWin,IDC_LSTKWCOLORS),NULL,TRUE)
								EnableWindow(hBtnApply,TRUE)
							EndIf
							'
					End Select
					'
			End Select
			'
		Case WM_DRAWITEM
			lpDRAWITEMSTRUCT=Cast(DRAWITEMSTRUCT Ptr,lParam)
			' Select back and text colors
			If lpDRAWITEMSTRUCT->itemState And ODS_SELECTED Then
				SetTextColor(lpDRAWITEMSTRUCT->hdc,GetSysColor(COLOR_HIGHLIGHTTEXT))
				SetBkColor(lpDRAWITEMSTRUCT->hdc,GetSysColor(COLOR_HIGHLIGHT))
			Else
				SetTextColor(lpDRAWITEMSTRUCT->hdc,GetSysColor(COLOR_WINDOWTEXT))
				SetBkColor(lpDRAWITEMSTRUCT->hdc,GetSysColor(COLOR_WINDOW))
			EndIf
			' Draw selected / unselected back color
			ExtTextOut(lpDRAWITEMSTRUCT->hdc,0,0,ETO_OPAQUE,@lpDRAWITEMSTRUCT->rcItem,NULL,0,NULL)
			' Draw the color
			rect.left=lpDRAWITEMSTRUCT->rcItem.left+1
			rect.right=rect.left+25
			rect.top=lpDRAWITEMSTRUCT->rcItem.top+1
			rect.bottom=lpDRAWITEMSTRUCT->rcItem.bottom-1
			hBr=CreateSolidBrush(lpDRAWITEMSTRUCT->itemData And &HFFFFFF)
			FillRect(lpDRAWITEMSTRUCT->hdc,@rect,hBr)
			DeleteObject(hBr)
			' Draw a black frame
			FrameRect(lpDRAWITEMSTRUCT->hdc,@rect,GetStockObject(BLACK_BRUSH))
			If lpDRAWITEMSTRUCT->CtlID=IDC_LSTCOLORS Then
				x=lpDRAWITEMSTRUCT->itemID
				If (x>=4 And x<=6) Or x=13 Then
					rect.left=rect.left+30
					rect.right=rect.left+25
					Select Case x
						Case 4
							col=tmpcol.racol.cmntback
						Case 5
							col=tmpcol.racol.strback
						Case 6
							col=tmpcol.racol.oprback
						Case 13
							col=tmpcol.racol.numback
					End Select
					hBr=CreateSolidBrush(col)
					FillRect(lpDRAWITEMSTRUCT->hdc,@rect,hBr)
					DeleteObject(hBr)
					' Draw a black frame
					FrameRect(lpDRAWITEMSTRUCT->hdc,@rect,GetStockObject(BLACK_BRUSH))
					x=30
				Else
					x=0
				EndIf
			EndIf
			' Draw the text
			SendMessage(lpDRAWITEMSTRUCT->hwndItem,LB_GETTEXT,lpDRAWITEMSTRUCT->itemID,Cast(Integer,@sItem))
			TextOut(lpDRAWITEMSTRUCT->hdc,lpDRAWITEMSTRUCT->rcItem.left+x+30,lpDRAWITEMSTRUCT->rcItem.top,@sItem,Len(sItem))
			If lpDRAWITEMSTRUCT->hwndItem=GetFocus() Then
				' Let windows draw the focus rectangle
				Return FALSE
			EndIf
			'
	    Case WM_CLOSE
			DeleteObject hCFont
			DeleteObject hLFont
			DeleteObject hTFont
			DeleteObject hOFont

			EndDialog hWin, 0
			'
		Case Else
			Return FALSE
			'
	End Select

	Return TRUE

End Function
