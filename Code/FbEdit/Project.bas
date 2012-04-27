
#Define IDD_NEWPROJECT						5300
#Define IDC_EDTPROJECTNAME					1003
#Define IDC_EDTPROJECTDESCRIPTION		1004
#Define IDC_EDTPROJECTPATH					1001
#Define IDC_CBOPROJECTTYPE					1002
#Define IDC_BTNPROJECTPATH					1005
#Define IDC_CHKCODE							1006
#Define IDC_CHKINCLUDE						1007
#Define IDC_CHKRESOURCE						1008
#Define IDC_CHKTEXT							1009
#Define IDC_CHKMOD							1010
#Define IDC_CHKRES							1011
#Define IDC_CHKBAK							1012
#Define IDC_CHKINC							1013
#Define IDC_CHKSUB							1014
#Define IDC_LSTNEWPROJECTTPL				1001
#Define IDC_STCNEWPROJECTTPL				1002

#Define IDC_TABNEWPROJECT					5301
#Define IDD_NEWPROJECT1						5360
#Define IDD_NEWPROJECT2						5380

'ProjectOption.dlg
#Define IDD_DLGPROJECTOPTION				5500
#Define IDC_EDTPODESCRIPTION				1001
#Define IDC_EDTPOTYPE						1003
#Define IDC_EDTPOBUILD						1005
#Define IDC_EDTPOMODULE						1007
#Define IDC_EDTOUTFILE						1006
#Define IDC_EDTRUN							1008
#Define IDC_BTNMAKEOPT						1004
#Define IDC_RBNGRPNONE          			5501
#Define IDC_RBNGRPFOLDER        			5502
#Define IDC_RBNGRPTYPE          			5503
#Define IDC_RBNMODMANUAL        			5504
#Define IDC_RBNMODAUTO          			5505
#Define IDC_RBNMODCMD           			5506
#Define IDC_EDTRESOURCEEXPORT				5507
#Define IDC_EDTAPIFILES						5509
#Define IDC_BTNAPIFILES						5508
#Define IDC_CHKADDMAINFILES				5510
#Define IDC_CHKCOMPILENEWER				5521
#Define IDC_CHKADDMODULEFILES				5522
#Define IDC_CHKINCVERSION					5523
#Define IDC_EDTDELETE						5524
#Define IDC_CHKRUN							5526

' Api select
#Define IDD_DLGPROJECTOPTIONAPI			6200
#Define IDC_LSTAPIFILES						6201

Dim Shared hTabNewProject1 	As HWND
Dim Shared hTabNewProject2 	As HWND
Dim Shared lpOldApiListProc	As Any Ptr

' ---------------------------------------------------------------------
' TYPE: MODULEPATH
' helper to handle the paths in project panel in folder view
' ---------------------------------------------------------------------

Type MODULEPATH
  	Public:
  		Declare Sub SetPath(path As String, setmembers As Integer)
	   Declare Function GetNextFolder() As String
	   Declare Function GetPathFromProjectFile(hwndtv As HWND, itemid As HTREEITEM) As String
	   Declare Function GetPathName() As String
	Private:
		relpath As String
		currentpath As String
		currentdepth As Integer
		maxdepth As Integer
End Type

Dim Shared ModPath As MODULEPATH

' ---------------------------------------------------------------------


Function BrowseCallbackProc(ByVal hwnd As HWND,ByVal uMsg As UINT,ByVal lParam As LPARAM,ByVal lpData As Integer) As Integer

	If uMsg=BFFM_INITIALIZED Then
		PostMessage(hwnd,BFFM_SETSELECTION,TRUE,lpData)
		PostMessage(hwnd,BFFM_SETSTATUSTEXT,0,Cast(Integer,GetInternalString(IS_BROWSE_FOR_FOLDER)))
	EndIf
	Return 0

End Function


Sub BrowseFolder(ByVal hWin As HWND,ByVal nID As Integer)
	Dim pidl As Any Ptr
	Dim bri As BROWSEINFO

	bri.pidlRoot=0
	bri.pszDisplayName=0
	bri.lpszTitle=0
	bri.ulFlags=BIF_RETURNONLYFSDIRS Or BIF_STATUSTEXT 
	bri.lpfn=@BrowseCallbackProc
	' get path   
	SendDlgItemMessage(hWin,nID,WM_GETTEXT,260,Cast(Integer,@buff))
	bri.lParam=Cast(LPARAM,@buff) 
	bri.iImage=0
	pidl=SHBrowseForFolder(@bri)
	If pidl Then
		SHGetPathFromIDList(pidl,@buff)
		' set new path back to edit
		SendDlgItemMessage(hWin,nID,WM_SETTEXT,0,Cast(Integer,@buff))
	EndIf

End Sub

Function MakeProjectFileName(ByVal sFile As String) As String
	Dim sItem As String*260
	Dim sPath As String*260
	Dim As Integer x,y

	sItem=sFile
	sPath=ad.ProjectPath
	Do While TRUE
		If Left(sItem,3)="..\" Then
			sItem=Mid(sItem,4)
			x=InStr(sPath,"\")
			y=x
			Do While x
				y=x
				x=InStr(x+1,sPath,"\")
			Loop
			sPath=Left(sPath,y-1)
		Else
			Exit Do
		EndIf
	Loop
	Return sPath & "\" & sItem

End Function

Function IsProjectFile(ByVal sFile As String) As Integer
	Dim nInx As Integer
	Dim nMiss As Integer
	Dim sItem As ZString*260

	nInx=1
	nMiss=0
	Do While nInx<256 And nMiss<MAX_MISS
		sItem=szNULL
		GetPrivateProfileString(StrPtr("File"),Str(nInx),@szNULL,@sItem,SizeOf(sItem),@ad.ProjectFile)
		If Len(sItem) Then
			nMiss=0
			If Mid(sItem,2,2)<>":\" Then
				sItem=MakeProjectFileName(sItem)
			EndIf
			If lstrcmpi(@sItem,@sFile)=0 Then
				Return nInx
			EndIf
		Else
			nMiss+=1
		EndIf
		nInx+=1
	Loop
	nInx=1001
	nMiss=0
	Do While nInx<1256 And nMiss<MAX_MISS
		sItem=szNULL
		GetPrivateProfileString(StrPtr("File"),Str(nInx),@szNULL,@sItem,SizeOf(sItem),@ad.ProjectFile)
		If Len(sItem) Then
			nMiss=0
			If Mid(sItem,2,2)<>":\" Then
				sItem=MakeProjectFileName(sItem)
			EndIf
			If lstrcmpi(@sItem,@sFile)=0 Then
				Return nInx
			EndIf
		Else
			nMiss+=1
		EndIf
		nInx+=1
	Loop
	Return 0

End Function

Sub UpdateProjectFileName(ByVal sOldFile As String,ByVal sNewFile As String)
	Dim nInx As Integer
	Dim nMiss As Integer
	Dim sItem As ZString*260

	nInx=1
	nMiss=0
	Do While nInx<256 And nMiss<MAX_MISS
		sItem=szNULL
		GetPrivateProfileString(StrPtr("File"),Str(nInx),@szNULL,@sItem,SizeOf(sItem),@ad.ProjectFile)
		If Len(sItem) Then
			nMiss=0
			If lstrcmpi(@sItem,@sOldFile)=0 Then
				WritePrivateProfileString(StrPtr("File"),Str(nInx),@sNewFile,@ad.ProjectFile)
				Exit Sub
			EndIf
		Else
			nMiss+=1
		EndIf
		nInx+=1
	Loop
	nInx=1001
	nMiss=0
	Do While nInx<1256 And nMiss<MAX_MISS
		sItem=szNULL
		GetPrivateProfileString(StrPtr("File"),Str(nInx),@szNULL,@sItem,SizeOf(sItem),@ad.ProjectFile)
		If Len(sItem) Then
			nMiss=0
			If lstrcmpi(@sItem,@sOldFile)=0 Then
				WritePrivateProfileString(StrPtr("File"),Str(nInx),@sNewFile,@ad.ProjectFile)
				Exit Sub
			EndIf
		Else
			nMiss+=1
		EndIf
		nInx+=1
	Loop

End Sub

Function GetFileImg(ByVal sFile As String) As Integer

	If UCase(Right(sFile,4))=".BAS" Then
		Return 1
	ElseIf UCase(Right(sFile,3))=".BI" Then
		Return 2
	ElseIf UCase(Right(sFile,3))=".RC" Then
		Return 3
	ElseIf UCase(Right(sFile,4))=".TXT" Then
		Return 4
	EndIf
	Return 5

End Function

Function TrvAddNode(ByVal hPar As HTREEITEM,ByVal lpPth As ZString Ptr,ByVal nImg As Integer,ByVal lParam As Integer) As HTREEITEM
	Dim tvins As TV_INSERTSTRUCT
	Dim tvi As TVITEM
	Dim hItem As HTREEITEM
	Dim sPath As ZString*260
	Dim sItem As ZString*260
	Dim As Integer x,y
	Dim hCld As HTREEITEM
	Dim As String currentPath, nextPath

	lstrcpy(@sPath,lpPth)
	If nProjectGroup=1 Then
		
		currentPath = sPath
		ModPath.SetPath(currentPath, 1)
		Do
			nextPath = ModPath.GetNextFolder()
			If nextPath<>"" Then
				sPath = nextPath
				
				hCld=Cast(HTREEITEM,SendMessage(ah.hprj,TVM_GETNEXTITEM,TVGN_CHILD,Cast(LPARAM,hPar)))
				While hCld
					tvi.hItem=hCld
					tvi.mask=TVIF_HANDLE Or TVIF_PARAM Or TVIF_TEXT
					tvi.pszText=@sItem
					tvi.cchTextMax=SizeOf(sItem)
					SendMessage(ah.hprj,TVM_GETITEM,0,Cast(LPARAM,@tvi))
					If tvi.lParam=0 Then
						If sItem=sPath Then
							hPar=hCld
							Exit While
						EndIf
					EndIf
					hCld=Cast(HTREEITEM,SendMessage(ah.hprj,TVM_GETNEXTITEM,TVGN_NEXT,Cast(LPARAM,hCld)))
				Wend
				If hCld=0 Then
					tvins.hParent=hPar
					tvins.item.lParam=0
					tvins.hInsertAfter=0
					tvins.item.mask=TVIF_TEXT Or TVIF_PARAM Or TVIF_IMAGE Or TVIF_SELECTEDIMAGE
					tvins.item.pszText=@sPath
					tvins.item.iImage=0
					tvins.item.iSelectedImage=0
					hPar=Cast(HTREEITEM,SendMessage(ah.hprj,TVM_INSERTITEM,0,Cast(Integer,@tvins)))
				EndIf
				
			EndIf
		Loop While nextPath<>""
		
	ElseIf nProjectGroup=2 And hPar<>0 Then
		x=GetFileImg(sPath)
		If x=5 Then
			sPath=UCase(sPath)
			If Right(sPath,4)=".TBR" Or Right(sPath,4)=".BMP" Or Right(sPath,4)=".ICO" Or Right(sPath,4)=".CUR" Then
				x=3
			EndIf
		EndIf
		Select Case x
			Case 1
				sPath=GetInternalString(IS_BASIC_SOURCE)
			Case 2
				sPath=GetInternalString(IS_INCLUDE)
			Case 3
				sPath=GetInternalString(IS_RESOURCE)
			Case Else
				sPath=GetInternalString(IS_MISC)
		End Select
		hCld=Cast(HTREEITEM,SendMessage(ah.hprj,TVM_GETNEXTITEM,TVGN_CHILD,Cast(LPARAM,hPar)))
		While hCld
			tvi.hItem=hCld
			tvi.mask=TVIF_HANDLE Or TVIF_PARAM Or TVIF_TEXT
			tvi.pszText=@sItem
			tvi.cchTextMax=SizeOf(sItem)
			SendMessage(ah.hprj,TVM_GETITEM,0,Cast(LPARAM,@tvi))
			If tvi.lParam=0 Then
				If sItem=sPath Then
					hPar=hCld
					Exit While
				EndIf
			EndIf
			hCld=Cast(HTREEITEM,SendMessage(ah.hprj,TVM_GETNEXTITEM,TVGN_NEXT,Cast(LPARAM,hCld)))
		Wend
		If hCld=0 Then
			tvins.hParent=hPar
			tvins.item.lParam=0
			tvins.hInsertAfter=0
			tvins.item.mask=TVIF_TEXT Or TVIF_PARAM Or TVIF_IMAGE Or TVIF_SELECTEDIMAGE
			tvins.item.pszText=@sPath
			tvins.item.iImage=0
			tvins.item.iSelectedImage=0
			hPar=Cast(HTREEITEM,SendMessage(ah.hprj,TVM_INSERTITEM,0,Cast(Integer,@tvins)))
		EndIf
	EndIf
	
	tvins.hParent=hPar
	tvins.item.lParam=lParam
	tvins.hInsertAfter=0
	tvins.item.mask=TVIF_TEXT Or TVIF_PARAM Or TVIF_IMAGE Or TVIF_SELECTEDIMAGE
	If nProjectGroup=1 Then
		currentPath = ModPath.GetPathName()
		tvins.item.pszText= StrPtr(currentPath)
	Else
		tvins.item.pszText=lpPth
	EndIf
	If lParam>=1001 And nImg=1 Then
		' Module
		nImg=6
	ElseIf lParam=nMain And nImg=1 Then
		' Main file
		nImg=7
	EndIf
	tvins.item.iImage=nImg
	tvins.item.iSelectedImage=nImg
	hItem=Cast(HTREEITEM,SendMessage(ah.hprj,TVM_INSERTITEM,0,Cast(Integer,@tvins)))
	If hPar Then
		SendMessage(ah.hprj,TVM_SORTCHILDREN,0,Cast(LPARAM,hPar))
		If nProjectGroup<>1 Then
			SendMessage(ah.hprj,TVM_EXPAND,TVE_EXPAND,Cast(LPARAM,hPar))
		EndIf
	EndIf
	Return hItem

End Function

Sub SetProjectFileInfo(ByVal hWin As HWND,ByVal lpPFI As PFI Ptr)
	Dim chrg As CHARRANGE
	Dim As Integer i,b,nLine

	nLine=SendMessage(hWin,EM_GETLINECOUNT,0,0)
	i=0
	While i<16
		b=1
		While b
			nLine=SendMessage(hWin,REM_PRVBOOKMARK,nLine,1)
			If nLine=-1 Then
				Exit While
			EndIf
			If lpPFI->nColl(i) And b Then
				SendMessage(hWin,REM_COLLAPSE,nLine,0)
			EndIf
			b=b Shl 1
		Wend
		If nLine=-1 Then
			Exit While
		EndIf
		i=i+1
	Wend
	chrg.cpMin=SendMessage(hWin,EM_LINEINDEX,lpPFI->nPos,0)
	chrg.cpMax=chrg.cpMin
	SendMessage(hWin,EM_EXSETSEL,0,Cast(Integer,@chrg))
	SendMessage(hWin,REM_VCENTER,0,0)
	SendMessage(hWin,EM_SCROLLCARET,0,0)

End Sub

Function TVCompare(ByVal lParam1 As LPARAM,ByVal lParam2 As LPARAM,ByVal lParamSort As LPARAM) As Integer

	If lParam1=0 And lParam2=0 Then
		Return 0
	ElseIf lParam1=0 Then
		Return -1
	ElseIf lParam2=0 Then
		Return 1
	EndIf
	Return 0

End Function

Sub RefreshProjectTree
	Dim nInx As Integer
	Dim nMiss As Integer
	Dim sItem As ZString*260
	Dim hPar As HTREEITEM
	Dim tvs As TVSORTCB

	SendMessage(ah.hprj,TVM_DELETEITEM,0,Cast(LPARAM,TVI_ROOT))
	hPar=TrvAddNode(0,@ProjectDescription,0,0)
	nInx=1
	nMiss=0
	Do While nInx<256 And nMiss<MAX_MISS
		GetPrivateProfileString(StrPtr("File"),Str(nInx),@szNULL,@sItem,SizeOf(sItem),@ad.ProjectFile)
		If Len(sItem) Then
			nMiss=0
			TrvAddNode(hPar,@sItem,GetFileImg(sItem),nInx)
			
		Else
			nMiss+=1
		EndIf
		nInx+=1
	Loop
	nInx=1001
	nMiss=0
	Do While nInx<1256 And nMiss<MAX_MISS
		GetPrivateProfileString(StrPtr("File"),Str(nInx),@szNULL,@sItem,SizeOf(sItem),@ad.ProjectFile)
		If Len(sItem) Then
			nMiss=0
			TrvAddNode(hPar,@sItem,GetFileImg(sItem),nInx)
		Else
			nMiss+=1
		EndIf
		nInx+=1
	Loop
	SendMessage(ah.hprj,TVM_EXPAND,TVE_EXPAND,Cast(Integer,hPar))
	tvs.hParent=hPar
	tvs.lpfnCompare=@TVCompare
	tvs.lParam=0
	SendMessage(ah.hprj,TVM_SORTCHILDRENCB,0,Cast(LPARAM,@tvs))

End Sub

Sub ReparseProject
	Dim nInx As Integer
	Dim nMiss As Integer
	Dim sItem As ZString*260
	Dim hPar As HTREEITEM
	Dim x As Integer
	Dim p As ZString Ptr
	Dim tpe As Integer
	Dim pfi As PFI
	Dim tvs As TVSORTCB

	nInx=1
	nMiss=0
	Do While nInx<256 And nMiss<MAX_MISS
		GetPrivateProfileString(StrPtr("File"),Str(nInx),@szNULL,@sItem,SizeOf(sItem),@ad.ProjectFile)
		If Len(sItem) Then
			nMiss=0
			tpe=FileType(sItem)
			If tpe=1 Then
				sItem=MakeProjectFileName(sItem)
				ParseFile(ah.hwnd,0,sItem)
			EndIf
		Else
			nMiss+=1
		EndIf
		nInx+=1
	Loop
	nInx=1001
	nMiss=0
	Do While nInx<1256 And nMiss<MAX_MISS
		GetPrivateProfileString(StrPtr("File"),Str(nInx),@szNULL,@sItem,SizeOf(sItem),@ad.ProjectFile)
		If Len(sItem) Then
			nMiss=0
			tpe=FileType(sItem)
			If tpe=1 Then
				sItem=MakeProjectFileName(sItem)
				ParseFile(ah.hwnd,0,sItem)
			EndIf
		Else
			nMiss+=1
		EndIf
		nInx+=1
	Loop

End Sub

Function OpenProject() As Integer
	Dim nInx As Integer
	Dim nMiss As Integer
	Dim sItem As ZString*260
	Dim hPar As HTREEITEM
	Dim x As Integer
	Dim p As ZString Ptr
	Dim tpe As Integer
	Dim pfi As PFI
	Dim tvs As TVSORTCB
	Dim szTabOrder As ZString*1024

	fProject=TRUE
	GetPrivateProfileString(StrPtr("Project"),StrPtr("Description"),@szNULL,@ProjectDescription,SizeOf(ProjectDescription),@ad.ProjectFile)
	tpe=GetPrivateProfileInt(StrPtr("Project"),StrPtr("Version"),0,@ad.ProjectFile)
	If tpe=0 Then
		' Convert project file to version 1
		p=@buff
		sItem="Version=1"
		lstrcpy(p,@sItem)
		p=p+Len(*p)+1
		sItem="Description=" & ProjectDescription
		lstrcpy(p,@sItem)
		p=p+Len(*p)+1
		GetPrivateProfileString(StrPtr("Project"),StrPtr("Make"),@szNULL,@sItem,SizeOf(sItem),@ad.ProjectFile)
		sItem="Make=" & sItem
		lstrcpy(p,@sItem)
		p=p+Len(*p)+1
		GetPrivateProfileString(StrPtr("Project"),StrPtr("Module"),StrPtr("Module Build,fbc -c"),@sItem,SizeOf(sItem),@ad.ProjectFile)
		sItem="Module=" & sItem
		lstrcpy(p,@sItem)
		p=p+Len(*p)+1
		GetPrivateProfileString(StrPtr("Project"),StrPtr("Recompile"),"0",@sItem,SizeOf(sItem),@ad.ProjectFile)
		sItem="Recompile=" & sItem
		lstrcpy(p,@sItem)
		p=p+Len(*p)+1
		sItem=szNULL
		lstrcpy(p,@sItem)
		nInx=1
		x=1
		Do While nInx<256
			GetPrivateProfileString(StrPtr("Project"),Str(nInx),@szNULL,@sItem,SizeOf(sItem),@ad.ProjectFile)
			If Len(sItem) Then
				WritePrivateProfileString(StrPtr("File"),Str(x),@sItem,@ad.ProjectFile)
				x=x+1
			EndIf
			nInx+=1
		Loop
		nInx=1001
		x=1001
		Do While nInx<1256
			GetPrivateProfileString(StrPtr("Project"),Str(nInx),@szNULL,@sItem,SizeOf(sItem),@ad.ProjectFile)
			If Len(sItem) Then
				WritePrivateProfileString(StrPtr("File"),Str(x),@sItem,@ad.ProjectFile)
				x=x+1
			EndIf
			nInx+=1
		Loop
		WritePrivateProfileSection(StrPtr("Project"),@buff,@ad.ProjectFile)
		tpe=1
	EndIf
	If tpe=1 Then
		' Convert project file to version 2
		GetPrivateProfileString(StrPtr("Project"),StrPtr("Recompile"),"0",@sItem,SizeOf(sItem),@ad.ProjectFile)
		WritePrivateProfileString(StrPtr("Make"),StrPtr("Recompile"),@sItem,@ad.ProjectFile)
		GetPrivateProfileString(StrPtr("Project"),StrPtr("Module"),StrPtr("Module Build,fbc -c"),@sItem,SizeOf(sItem),@ad.ProjectFile)
		WritePrivateProfileString(StrPtr("Make"),StrPtr("Module"),@sItem,@ad.ProjectFile)
		WritePrivateProfileString(StrPtr("Make"),StrPtr("Current"),StrPtr("1"),@ad.ProjectFile)
		GetPrivateProfileString(StrPtr("Project"),StrPtr("Make"),@szNULL,@sItem,SizeOf(sItem),@ad.ProjectFile)
		WritePrivateProfileString(StrPtr("Make"),StrPtr("1"),@sItem,@ad.ProjectFile)
		p=@buff
		sItem="Version=2"
		lstrcpy(p,@sItem)
		p=p+Len(*p)+1
		sItem="Description=" & ProjectDescription
		lstrcpy(p,@sItem)
		p=p+Len(*p)+1
		sItem=szNULL
		lstrcpy(p,@sItem)
		WritePrivateProfileSection(StrPtr("Project"),@buff,@ad.ProjectFile)
		tpe=2
	EndIf
	If tpe=2 Then
		' Convert project file to version 3
		nInx=1
		nMiss=0
		Do While nInx<256 And nMiss<MAX_MISS
			GetPrivateProfileString(StrPtr("File"),Str(nInx),@szNULL,@sItem,SizeOf(sItem),@ad.ProjectFile)
			If Len(sItem) Then
				nMiss=0
				ReadProjectFileInfo(nInx,@pfi)
				If pfi.nLoad Then
					szTabOrder &="," & Str(nInx)
				EndIf
			Else
				nMiss+=1
			EndIf
			nInx+=1
		Loop
		nInx=1001
		nMiss=0
		Do While nInx<1256 And nMiss<MAX_MISS
			GetPrivateProfileString(StrPtr("File"),Str(nInx),@szNULL,@sItem,SizeOf(sItem),@ad.ProjectFile)
			If Len(sItem) Then
				nMiss=0
				ReadProjectFileInfo(nInx,@pfi)
				If pfi.nLoad Then
					szTabOrder &="," & Str(nInx)
				EndIf
			Else
				nMiss+=1
			EndIf
			nInx+=1
		Loop
		WritePrivateProfileString(StrPtr("TabOrder"),StrPtr("TabOrder"),@szTabOrder,@ad.ProjectFile)
		WritePrivateProfileString(StrPtr("Project"),StrPtr("Version"),StrPtr("3"),@ad.ProjectFile)
		tpe=3
	EndIf
	nMain=GetPrivateProfileInt(StrPtr("File"),StrPtr("Main"),1,ad.ProjectFile)
	GetPrivateProfileString(StrPtr("Project"),StrPtr("ResExport"),"",@ad.resexport,SizeOf(ad.resexport),@ad.ProjectFile)
	nProjectGroup=GetPrivateProfileInt(StrPtr("Project"),StrPtr("Grouping"),1,@ad.ProjectFile)
	fAddMainFiles=GetPrivateProfileInt(StrPtr("Project"),StrPtr("AddMainFiles"),1,@ad.ProjectFile)
	fAddModuleFiles=GetPrivateProfileInt(StrPtr("Project"),StrPtr("AddModuleFiles"),1,@ad.ProjectFile)
	fCompileIfNewer=GetPrivateProfileInt(StrPtr("Project"),StrPtr("CompileIfNewer"),0,@ad.ProjectFile)
	fIncVersion=GetPrivateProfileInt(StrPtr("Project"),StrPtr("IncVersion"),0,@ad.ProjectFile)
	fRunCmd=GetPrivateProfileInt(StrPtr("Project"),StrPtr("RunCmd"),0,@ad.ProjectFile)
	hPar=TrvAddNode(0,@ProjectDescription,0,0)
	SendMessage(ah.htab,TCM_SETCURSEL,1,0)
	ShowWindow(ah.hprj,SW_SHOWNA)
	ShowWindow(ah.hfib,SW_HIDE)
	SendMessage(ah.hpr,PRM_DELPROPERTY,0,0)
	SendMessage(ah.hpr,PRM_SELECTPROPERTY,Asc("p")+256,0)
	sItem=ad.ProjectFile
	x=InStr(sItem,"\")
	Do While x
		tpe=x
		x=InStr(x+1,sItem,"\")
	Loop
	ad.ProjectPath=Left(sItem,tpe-1)
	SetCurrentDirectory(ad.ProjectPath)
	SetHiliteWords(ah.hwnd)
	GetPrivateProfileString(StrPtr("Project"),StrPtr("Api"),@DefApiFiles,@ProjectApiFiles,SizeOf(ProjectApiFiles),@ad.ProjectFile)
	' Add api files
	LoadApiFiles
	SetHiliteWordsFromApi(ah.hwnd)
	GetPrivateProfileString(StrPtr("TabOrder"),StrPtr("TabOrder"),@szNULL,@szTabOrder,SizeOf(szTabOrder),@ad.ProjectFile)
	nInx=1
	nMiss=0
	Do While nInx<256 And nMiss<MAX_MISS
		GetPrivateProfileString(StrPtr("File"),Str(nInx),@szNULL,@sItem,SizeOf(sItem),@ad.ProjectFile)
		If Len(sItem) Then
			nMiss=0
			tpe=FileType(sItem)
			TrvAddNode(hPar,@sItem,GetFileImg(sItem),nInx)
			If Mid(sItem,2,2)<>":\" Then
				sItem=MakeProjectFileName(sItem)
			EndIf
			If tpe=1 Then
				ParseFile(ah.hwnd,0,sItem)
			EndIf
		Else
			nMiss+=1
		EndIf
		nInx+=1
	Loop
	nInx=1001
	nMiss=0
	Do While nInx<1256 And nMiss<MAX_MISS
		GetPrivateProfileString(StrPtr("File"),Str(nInx),@szNULL,@sItem,SizeOf(sItem),@ad.ProjectFile)
		If Len(sItem) Then
			nMiss=0
			tpe=FileType(sItem)
			TrvAddNode(hPar,@sItem,GetFileImg(sItem),nInx)
			sItem=MakeProjectFileName(sItem)
			If tpe=1 Then
				ParseFile(ah.hwnd,0,sItem)
			EndIf
		Else
			nMiss+=1
		EndIf
		nInx+=1
	Loop
	' Open files
	While Len(szTabOrder)
		nInx=Val(szTabOrder)
		GetPrivateProfileString(StrPtr("File"),Str(nInx),@szNULL,@sItem,SizeOf(sItem),@ad.ProjectFile)
		If Len(sItem) Then
			sItem=MakeProjectFileName(sItem)
			ReadProjectFileInfo(nInx,@pfi)
			If pfi.nLoad Then
				If pfi.nLoad=2 Then
					fNoResMode=TRUE
				EndIf
				OpenTheFile(sItem,FALSE)
				fNoResMode=FALSE
			EndIf
		EndIf
		x=InStr(szTabOrder,",")
		If x Then
			szTabOrder=Mid(szTabOrder,x+1)
		Else
			szTabOrder=""
		EndIf
	Wend
	SendMessage(ah.hprj,TVM_EXPAND,TVE_EXPAND,Cast(Integer,hPar))
	tvs.hParent=hPar
	tvs.lpfnCompare=@TVCompare
	tvs.lParam=0
	SendMessage(ah.hprj,TVM_SORTCHILDRENCB,0,Cast(LPARAM,@tvs))
	SendMessage(ah.hpr,PRM_REFRESHLIST,0,0)
	GetMakeOption
	SetWinCaption
	NextTab(FALSE)
	AddMruProject
	CallAddins(ah.hwnd,AIM_PROJECTOPEN,0,0,HOOK_PROJECTOPEN)
	szLastDir=ad.ProjectPath
	Return 0

End Function

Function CloseProject() As Integer

	If CloseAllTabs(ah.hwnd,fProject,0,edtopt.closeonlocks)=FALSE Then
		SendMessage(ah.hprj,TVM_DELETEITEM,0,Cast(Integer,TVI_ROOT))
		SendMessage(ah.htab,TCM_SETCURSEL,0,0)
		ShowWindow(ah.hfib,SW_SHOWNA)
		ShowWindow(ah.hprj,SW_HIDE)
		SendMessage(ah.hpr,PRM_DELPROPERTY,0,0)
		SendMessage(ah.hpr,PRM_SELECTPROPERTY,Asc("p")+256,0)
		fProject=FALSE
		ad.ProjectFile=""
		SetHiliteWords(ah.hwnd)
		' Add api files
		LoadApiFiles
		SetHiliteWordsFromApi(ah.hwnd)
		SetCurrentDirectory(@ad.AppPath)
		SetWinCaption
		GetMakeOption
		CallAddins(ah.hwnd,AIM_PROJECTCLOSE,0,0,HOOK_PROJECTCLOSE)
		' Search Module
		f.fsearch=1
		Return TRUE
	Else
		Return FALSE
	EndIf

End Function

Function GetProjectResource() As String
	Dim nInx As Integer
	Dim nMiss As Integer
	Dim sItem As ZString*260
	Dim sFile As String

	nInx=1
	nMiss=0
	Do While nInx<256 And nMiss<MAX_MISS
		GetPrivateProfileString(StrPtr("File"),Str(nInx),"",@sItem,SizeOf(sItem),@ad.ProjectFile)
		sFile=sItem
		If Len(sFile) Then
			nMiss=0
			If UCase(Right(sFile,3))=".RC" Then
				Return sFile
			EndIf
		Else
			nMiss+=1
		EndIf
		nInx+=1
	Loop
	Return ""

End Function

Function RemoveProjectPath(ByVal sFile As String) As String
	Dim x As Integer
	Dim y As Integer
	Dim sItem As String*260
	Dim sPath As String*260

	' Get a filename relative to project path
	sItem=ad.ProjectPath & "\"
	x=InStr(sItem,"\")
	y=0
	Do While UCase(Left(sItem,x))=UCase(Left(sFile,x))
		y=x
		x=InStr(x+1,sItem,"\")
		If x=0 Then
			Exit Do
		EndIf
	Loop
	sItem=Mid(sFile,y+1)
	sPath=Left(sFile,y-1)
	x=y-1
	Do While TRUE
		x=InStr(x+1,ad.ProjectPath,"\")
		If x=0 Then
			Exit Do
		Else
			sItem="..\" & sItem
		EndIf
	Loop
	Return sItem

End Function

Sub GetTrvItems(ByVal hPar As HTREEITEM,ByRef sFile As String)
	Dim hCld As HTREEITEM
	Dim tvi As TVITEM
	Dim sItem As ZString*260

	hCld=Cast(HTREEITEM,SendMessage(ah.hprj,TVM_GETNEXTITEM,TVGN_CHILD,Cast(LPARAM,hPar)))
	If hCld Then
		While hCld
			tvi.hItem=hCld
			tvi.mask=TVIF_PARAM Or TVIF_TEXT
			tvi.pszText=@sItem
			tvi.cchTextMax=SizeOf(sItem)
			SendMessage(ah.hprj,TVM_GETITEM,0,Cast(LPARAM,@tvi))
			If UCase(sFile)=UCase(sItem) Then
				SendMessage(ah.hprj,TVM_SELECTITEM,TVGN_CARET,Cast(LPARAM,hCld))
				Exit Sub
			EndIf
			GetTrvItems(hCld,sFile)
			hCld=Cast(HTREEITEM,SendMessage(ah.hprj,TVM_GETNEXTITEM,TVGN_NEXT,Cast(LPARAM,hCld)))
		Wend
	EndIf

End Sub

Sub SelectProjectFile(ByVal sFile As String)
	Dim sSelect As String

	If fProject Then
		sSelect=sFile
		sSelect=RemoveProjectPath(sSelect)
		GetTrvItems(Cast(HTREEITEM,SendMessage(ah.hprj,TVM_GETNEXTITEM,TVGN_ROOT,NULL)),sSelect)
	EndIf

End Sub

Sub AddProjectFile(ByVal sFile As String,ByVal fModule As Boolean)
	Dim sItem As ZString*260
	Dim nInx As Integer
	Dim hPar As HTREEITEM

	' Find free project file index
	nInx=1
	If fModule Then
		nInx=1001
	EndIf
	While TRUE
		sItem=szNULL
		GetPrivateProfileString(StrPtr("File"),Str(nInx),@szNULL,@sItem,SizeOf(sItem),@ad.ProjectFile)
		If Len(sItem) Then
			nInx+=1
		Else
			Exit While
		EndIf
	Wend
	ad.filename=sFile
	sItem=sFile
	sItem=RemoveProjectPath(sItem)
	WritePrivateProfileString(StrPtr("File"),Str(nInx),@sItem,@ad.ProjectFile)
	RefreshProjectTree
	OpenTheFile(sFile,FALSE)

End Sub

Sub AddAProjectFile(ByVal sFile As String,ByVal fModule As Boolean,ByVal fCreate As Boolean)
	Dim hFile As HANDLE
	Dim buff As ZString*256
	
	If IsProjectFile(sFile) Then
		buff=GetInternalString(IS_FILE_EXISTS_IN_PROJECT)
		MessageBox(ah.hwnd,buff & CRLF & sFile,@szAppName,MB_OK Or MB_ICONERROR)
	Else
		If fCreate Then
			hFile=CreateFile(@sFile,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0)
			CloseHandle(hFile)
		EndIf
		AddProjectFile(sFile,fModule)
	EndIf

End Sub

Sub AddNewProjectFile()
	Dim sFile As ZString*MAX_PATH
	Dim ofn As OPENFILENAME

	ofn.lStructSize=SizeOf(OPENFILENAME)
	ofn.hwndOwner=GetOwner
	ofn.hInstance=hInstance
	ofn.lpstrInitialDir=@ad.ProjectPath
	buff=String(260,0)
	ofn.lpstrFile=@buff
	ofn.nMaxFile=260
	ofn.lpstrFilter=StrPtr(ALLFilterString)
	sFile=GetInternalString(IS_ADD_NEW_FILE)
	ofn.lpstrTitle=@sFile
	ofn.Flags=OFN_EXPLORER Or OFN_PATHMUSTEXIST Or OFN_HIDEREADONLY Or OFN_OVERWRITEPROMPT Or OFN_EXPLORER
	If GetSaveFileName(@ofn) Then
		sFile=buff
		AddAProjectFile(sFile,FALSE,TRUE)
	EndIf

End Sub

Sub AddExistingProjectFile()
	Dim sFile As String
	Dim ofn As OPENFILENAME
	Dim i As Integer
	Dim x As Integer
	Dim pth As ZString*260
	Dim s As ZString*260

	ofn.lStructSize=SizeOf(OPENFILENAME)
	ofn.hwndOwner=GetOwner
	ofn.hInstance=hInstance
	ofn.lpstrInitialDir=@ad.ProjectPath
	buff=String(260,0)
	ofn.lpstrFile=@buff
	ofn.nMaxFile=16*1024
	ofn.lpstrFilter=StrPtr(ALLFilterString)
	s=GetInternalString(IS_ADD_EXISTING_FILE)
	ofn.lpstrTitle=@s
	ofn.Flags=OFN_EXPLORER Or OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST Or OFN_HIDEREADONLY Or OFN_EXPLORER Or OFN_ALLOWMULTISELECT
	If GetOpenFileName(@ofn) Then
		lstrcpy(@pth,@buff)
		i=Len(pth)+1
		x=Cast(Integer,@buff)
		lstrcpy(@s,Cast(ZString Ptr,x+i))
		If Asc(s)=0 Then
			' Add single file
			AddAProjectFile(pth,FALSE,FALSE)
		Else
			' Open multiple files
			Do While Asc(s)<>0
				sFile=pth & "\" & s
				AddAProjectFile(sFile,FALSE,FALSE)
				i=i+Len(s)+1
				lstrcpy(@s,Cast(ZString Ptr,x+i))
			Loop
		EndIf
	EndIf

End Sub

Sub AddNewProjectModule()
	Dim ofn As OPENFILENAME
	Dim sFile As ZString*260

	ofn.lStructSize=SizeOf(OPENFILENAME)
	ofn.hwndOwner=GetOwner
	ofn.hInstance=hInstance
	ofn.lpstrInitialDir=@ad.ProjectPath
	buff=String(260,0)
	ofn.lpstrFile=@buff
	ofn.nMaxFile=260
	ofn.lpstrFilter=StrPtr(MODFilterString)
	sFile=GetInternalString(IS_ADD_NEW_MODULE)
	ofn.lpstrTitle=@sFile
	ofn.Flags=OFN_EXPLORER Or OFN_PATHMUSTEXIST Or OFN_HIDEREADONLY Or OFN_OVERWRITEPROMPT Or OFN_EXPLORER
	ofn.lpstrDefExt=StrPtr("bas")
	If GetSaveFileName(@ofn) Then
		sFile=buff
		AddAProjectFile(sFile,TRUE,TRUE)
	EndIf

End Sub

Sub AddExistingProjectModule()
	Dim ofn As OPENFILENAME
	Dim sFile As String*260
	Dim i As Integer
	Dim x As Integer
	Dim pth As ZString*260
	Dim s As ZString*260

	ofn.lStructSize=SizeOf(OPENFILENAME)
	ofn.hwndOwner=GetOwner
	ofn.hInstance=hInstance
	ofn.lpstrInitialDir=@ad.ProjectPath
	buff=String(260,0)
	ofn.lpstrFile=@buff
	ofn.nMaxFile=16*1024
	ofn.lpstrFilter=StrPtr(MODFilterString)
	s=GetInternalString(IS_ADD_EXISTING_MODULE)
	ofn.lpstrTitle=@s
	ofn.Flags=OFN_EXPLORER Or OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST Or OFN_HIDEREADONLY Or OFN_EXPLORER Or OFN_ALLOWMULTISELECT
	If GetOpenFileName(@ofn) Then
		lstrcpy(@pth,@buff)
		i=Len(pth)+1
		x=Cast(Integer,@buff)
		lstrcpy(@s,Cast(ZString Ptr,x+i))
		If Asc(s)=0 Then
			' Add single file
			AddAProjectFile(pth,TRUE,FALSE)
		Else
			' Open multiple files
			Do While Asc(s)<>0
				sFile=pth & "\" & s
				AddAProjectFile(sFile,TRUE,FALSE)
				i=i+Len(s)+1
				lstrcpy(@s,Cast(ZString Ptr,x+i))
			Loop
		EndIf
	EndIf

End Sub

Sub SetAsMainProjectFile
	Dim tvi As TV_ITEM
	Dim nInx As Integer
	Dim nMiss As Integer
	Dim sItem As ZString*260
	
	Dim path As String
	tvi.hItem=Cast(HTREEITEM,SendMessage(ah.hprj,TVM_GETNEXTITEM,TVGN_CARET,0))
	
	If tvi.hItem Then
		If nProjectGroup=1 Then
			path = ModPath.GetPathFromProjectFile(ah.hprj, tvi.hItem)
			buff = *StrPtr(path)
		Else
			tvi.Mask=TVIF_TEXT
			tvi.pszText=@buff
			tvi.cchTextMax=260
			SendMessage(ah.hprj,TVM_GETITEM,0,Cast(Integer,@tvi))
		EndIf 
		
		nInx=1
		nMiss=0
		Do While nInx<256 And nMiss<MAX_MISS
			sItem=szNULL
			GetPrivateProfileString(StrPtr("File"),Str(nInx),@szNULL,@sItem,SizeOf(sItem),@ad.ProjectFile)
			If Len(sItem) Then
				nMiss=0
				If lstrcmpi(@buff,@sItem)=0 Then
					WritePrivateProfileString(StrPtr("File"),StrPtr("Main"),Str(nInx),@ad.ProjectFile)
					nMain=nInx
					RefreshProjectTree
					Exit Sub
				EndIf
			Else
				nMiss+=1
			EndIf
			nInx+=1
		Loop
		nInx=1001
		nMiss=0
		Do While nInx<1256 And nMiss<MAX_MISS
			sItem=szNULL
			GetPrivateProfileString(StrPtr("File"),Str(nInx),@szNULL,@sItem,SizeOf(sItem),@ad.ProjectFile)
			If Len(sItem) Then
				nMiss=0
				If lstrcmpi(@buff,@sItem)=0 Then
					WritePrivateProfileString(StrPtr("File"),StrPtr("Main"),Str(nInx),@ad.ProjectFile)
					nMain=nInx
					RefreshProjectTree
					Exit Sub
				EndIf
			Else
				nMiss+=1
			EndIf
			nInx+=1
		Loop
	EndIf

End Sub

Sub RemoveProjectFile(ByVal fDontAsk As Boolean)
	Dim tvi As TV_ITEM
	Dim nInx As Integer
	Dim nMiss As Integer
	Dim sItem As ZString*260
	Dim buff As ZString*260
	
	Dim path As String
	tvi.hItem=Cast(HTREEITEM,SendMessage(ah.hprj,TVM_GETNEXTITEM,TVGN_CARET,0))
	
	If tvi.hItem Then
		If nProjectGroup=1 Then
			path = ModPath.GetPathFromProjectFile(ah.hprj, tvi.hItem)
			buff = *StrPtr(path)
		Else
			tvi.Mask=TVIF_TEXT
			tvi.pszText=@buff
			tvi.cchTextMax=260
			SendMessage(ah.hprj,TVM_GETITEM,0,Cast(Integer,@tvi))
		EndIf 
		
		nInx=1
		nMiss=0
		Do While nInx<256 And nMiss<MAX_MISS
			sItem=szNULL
			GetPrivateProfileString(StrPtr("File"),Str(nInx),@szNULL,@sItem,SizeOf(sItem),@ad.ProjectFile)
			If Len(sItem) Then
				nMiss=0
				If lstrcmpi(@buff,@sItem)=0 Then
					If fDontAsk=FALSE Then
						buff=GetInternalString(IS_REMOVE_FILE_FROM_PROJECT)
						If MessageBox(ah.hwnd,buff & CRLF & sItem,@szAppName,MB_YESNO Or MB_ICONQUESTION)=IDNO Then
							Exit Sub
						EndIf
					EndIf
					SendMessage(ah.hprj,TVM_DELETEITEM,0,Cast(Integer,tvi.hItem))
					WritePrivateProfileString(StrPtr("File"),Str(nInx),StrPtr(szNULL),@ad.ProjectFile)
					SendMessage(ah.hpr,PRM_DELPROPERTY,nInx,0)
					SendMessage(ah.hpr,PRM_REFRESHLIST,0,0)
					If fDontAsk=FALSE Then
						CallAddins(ah.hwnd,AIM_PROJECTREMOVE,nInx,Cast(LPARAM,@sItem),HOOK_PROJECTREMOVE)
					EndIf
					Exit Sub
				EndIf
			Else
				nMiss+=1
			EndIf
			nInx+=1
		Loop
		nInx=1001
		nMiss=0
		Do While nInx<1256 And nMiss<MAX_MISS
			sItem=szNULL
			GetPrivateProfileString(StrPtr("File"),Str(nInx),@szNULL,@sItem,SizeOf(sItem),@ad.ProjectFile)
			If Len(sItem) Then
				nMiss=0
				If lstrcmpi(@buff,@sItem)=0 Then
					If fDontAsk=FALSE Then
						buff=GetInternalString(IS_REMOVE_FILE_FROM_PROJECT)
						If MessageBox(ah.hwnd,buff & CRLF & sItem,@szAppName,MB_YESNO Or MB_ICONQUESTION)=IDNO Then
							Exit Sub
						EndIf
					EndIf
					SendMessage(ah.hprj,TVM_DELETEITEM,0,Cast(Integer,tvi.hItem))
					WritePrivateProfileString(StrPtr("File"),Str(nInx),StrPtr(szNULL),@ad.ProjectFile)
					SendMessage(ah.hpr,PRM_DELPROPERTY,nInx,0)
					SendMessage(ah.hpr,PRM_REFRESHLIST,0,0)
					If fDontAsk=FALSE Then
						CallAddins(ah.hwnd,AIM_PROJECTREMOVE,nInx,Cast(LPARAM,@sItem),HOOK_PROJECTREMOVE)
					EndIf
					Exit Sub
				EndIf
			Else
				nMiss+=1
			EndIf
			nInx+=1
		Loop
	EndIf

End Sub

Sub InsertInclude()
	Dim tvi As TV_ITEM
	Dim buffer As ZString*260

	Dim path As String
	tvi.hItem=Cast(HTREEITEM,SendMessage(ah.hprj,TVM_GETNEXTITEM,TVGN_CARET,0))
	If tvi.hItem Then
		If nProjectGroup=1 Then
			path = ModPath.GetPathFromProjectFile(ah.hprj, tvi.hItem)
			buffer = *StrPtr(path)
		Else
			tvi.Mask=TVIF_TEXT
			tvi.pszText=@buffer
			tvi.cchTextMax=260
			SendMessage(ah.hprj,TVM_GETITEM,0,Cast(Integer,@tvi))
		EndIf 
		SendMessage(ah.hprj,TVM_GETITEM,0,Cast(Integer,@tvi))
		buffer="#Include " & Chr(34) & buffer & Chr(34) & CR
		SendMessage(ah.hred,EM_REPLACESEL,TRUE,Cast(LPARAM,@buffer))
	EndIf	

End Sub

Function GetProjectFile(ByVal nInx As Integer) As String
	Dim sFile As ZString*260

	GetPrivateProfileString(StrPtr("File"),Str(nInx),@szNULL,@sFile,SizeOf(sFile),@ad.ProjectFile)
	Return sFile

End Function

Function GetProjectFileName(ByVal nInx As Integer) As String
	Dim sFile As ZString*260

	GetPrivateProfileString(StrPtr("File"),Str(nInx),@szNULL,@sFile,SizeOf(sFile),@ad.ProjectFile)
	If Len(sFile) Then
		sFile=MakeProjectFileName(sFile)
		Return sFile
	EndIf
	Return ""

End Function

Sub ToggleProjectFile
	Dim tvi As TV_ITEM
	Dim nInx As Integer
	Dim sItem As ZString*260
	Dim buff As ZString*260
	Dim tci As TCITEM
	Dim lpTABMEM As TABMEM Ptr
	Dim i As Integer
	Dim nOldID As Integer
	
	Dim path As String
	tvi.hItem=Cast(HTREEITEM,SendMessage(ah.hprj,TVM_GETNEXTITEM,TVGN_CARET,0))
	
	If tvi.hItem Then
		tvi.Mask=TVIF_TEXT Or TVIF_PARAM
		tvi.pszText=@buff
		tvi.cchTextMax=260
		SendMessage(ah.hprj,TVM_GETITEM,0,Cast(Integer,@tvi))
		
		If nProjectGroup=1 Then
			path = ModPath.GetPathFromProjectFile(ah.hprj, tvi.hItem)
			buff = *StrPtr(path)
		EndIf
		
		If tvi.lParam Then
			' Remove the file from project
			nOldID=tvi.lParam
			RemoveProjectFile(TRUE)
			If tvi.lParam<1000 Then
				nInx=1001
			Else
				nInx=1
			EndIf
			' Find free project file ID
			While TRUE
				sItem=szNULL
				GetPrivateProfileString(StrPtr("File"),Str(nInx),@szNULL,@sItem,SizeOf(sItem),@ad.ProjectFile)
				If Len(sItem) Then
					nInx+=1
				Else
					Exit While
				EndIf
			Wend
			' Add the file to project file
			WritePrivateProfileString(StrPtr("File"),Str(nInx),@buff,@ad.ProjectFile)
			RefreshProjectTree
			' Get full file name
			buff=GetProjectFileName(nInx)
			' Update tab
			tci.mask=TCIF_PARAM
			i=0
			Do While TRUE
				If SendMessage(ah.htabtool,TCM_GETITEM,i,Cast(Integer,@tci)) Then
					lpTABMEM=Cast(TABMEM Ptr,tci.lParam)
					If lstrcmpi(@buff,lpTABMEM->filename)=0 Then
						lpTABMEM->profileinx=nInx
						tci.mask=TCIF_IMAGE
						If nInx>1000 Then
							' Module
							tci.iImage=6
						Else
							tci.iImage=GetFileImg(buff)
						EndIf
						SendMessage(ah.htabtool,TCM_SETITEM,i,Cast(Integer,@tci))
						CallAddins(ah.hwnd,AIM_PROJECTTOGGLE,nOldID,nInx,HOOK_PROJECTTOGGLE)
						Exit Do
					EndIf
				Else
					Exit Do
				EndIf
				i=i+1
			Loop
		EndIf
	EndIf

End Sub

Sub OpenProjectFile(ByVal nInx As Integer)
	Dim sFile As String*260

	sFile=GetProjectFileName(nInx)
	' Open single file
	OpenTheFile(sFile,FALSE)

End Sub

Sub ReadProjectFileInfo(ByVal nInx As Integer,ByVal lpPFI As PFI Ptr)
	Dim i As Integer

	lpPFI->nGroup=0
	lpPFI->nPos=0
	lpPFI->nLoad=0
	For i=0 To 15
		lpPFI->nColl(i)=0
	Next i
	LoadFromIni(StrPtr("FileInfo"),Str(nInx),"4444444444444444444",lpPFI,TRUE)

End Sub

Sub WriteProjectFileInfo(ByVal hWin As HWND,ByVal nInx As Integer,ByVal fProjectClose As Boolean)
	Dim pfi As PFI
	Dim chrg As CHARRANGE
	Dim sTmp As ZString*32
	Dim sFile As ZString*260
	Dim As Integer i,v,b,x,y,nLine

	sTmp=Str(nInx)
	LoadFromIni(StrPtr("FileInfo"),@sTmp,"4444444444444444444",@pfi,TRUE)
	pfi.nLoad=fProjectClose
	If hWin<>ah.hres Then
		If fProjectClose Then
			sFile=GetProjectFileName(nInx)
			If FileType(sFile)=2 Then
				pfi.nLoad=2
			EndIf
		EndIf
		SendMessage(hWin,EM_EXGETSEL,0,Cast(Integer,@chrg))
		pfi.nPos=SendMessage(hWin,EM_LINEFROMCHAR,chrg.cpMin,0)
		i=0
		nLine=SendMessage(hWin,EM_GETLINECOUNT,0,0)
		While i<16
			b=1
			v=0
			While b
				x=SendMessage(hWin,REM_PRVBOOKMARK,nLine,1)
				y=SendMessage(hWin,REM_PRVBOOKMARK,nLine,2)
				If x>y Then
					nLine=x
				Else
					nLine=y
					If nLine<>-1 Then
						v=v Or b
					EndIf
				EndIf
				If nLine=-1 Then
					Exit While
				EndIf
				b=b Shl 1
			Wend
			pfi.nColl(i)=v
			If nLine=-1 Then
				Exit While
			EndIf
			i=i+1
		Wend
	EndIf
	SaveToIni(StrPtr("FileInfo"),@sTmp,"4444444444444444444",@pfi,TRUE)

End Sub

Function ConvertLine(ByVal sLine As String,ByVal sName As String) As String
	Dim x As Integer

	x=InStr(sLine,szNAME)
	If x Then
		Return Left(sLine,x-1) & sName & Mid(sLine,x+11)
	EndIf
	Return sLine

End Function

Sub UseTemplate(ByVal sTemplateFile As String,ByVal sProName As String)
	Dim sLine As String
	Dim n As Integer
	Dim sName As String
	Dim sFile As String
	Dim sPath As String
	Dim fPro As Boolean
	Dim nlen As Integer
	Dim npos As Integer
	Dim sData As ZString*32
	Dim hTxtFile As HANDLE
	Dim hBinFile As HANDLE
	Dim f As Integer

	f=FreeFile
	Open sTemplateFile For Input As #f
	' Get project name
	Line Input #f,sName
	n=0
	While Not Eof(f)
		Line Input #f,sLine
		sLine=ConvertLine(sLine,sProName)
		Select Case n
			Case 0
				' Wait for [*BEGINPRO*]
				If sLine=szBPRO Then
					n=1
					fPro=TRUE
				EndIf
			Case 1
				' Wait for [*BEGINTXT*], [*BEGINBIN*] or [*ENDPRO*]
				If sLine=szBTXT Then
				   Line Input #f,sFile
					sFile=ConvertLine(sFile,sProName)
					sFile=ad.ProjectPath & "\" & sFile
					sPath=sFile
					GetFilePath(sPath)
					MkDir sPath
					hTxtFile=CreateFile(sFile,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0)
					n=2
				ElseIf sLine=szBBIN Then
				   Line Input #f,sFile
					sFile=ConvertLine(sFile,sProName)
					sFile=ad.ProjectPath & "\" & sFile
					sPath=sFile
					GetFilePath(sPath)
					MkDir sPath
					hBinFile=CreateFile(sFile,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0)
					npos=0
					n=3
				ElseIf sLine=szEPRO Then
					fPro=FALSE
					n=1
				EndIf
			Case 2
				' Text file
				If sLine=szETXT Then
					CloseHandle(hTxtFile)
					If fPro Then
						AddAProjectFile(sFile,FALSE,FALSE)
					EndIf
					n=1
				Else
					buff=sLine & CRLF
					nlen=Len(buff)
					WriteFile(hTxtFile,@buff,nlen,@nlen,NULL)
				EndIf
			Case 3
				' Binary file
				If sLine=szEBIN Then
					CloseHandle(hBinFile)
					If fPro Then
						AddAProjectFile(sFile,FALSE,FALSE)
					EndIf
					n=1
				Else
					' Convert hex string
					nlen=Len(sLine)/2
					buff=sLine
					Asm
						push	esi
						push	edi
						lea	esi,buff
						mov	edi,esi
						Xor	ecx,ecx
					L0:
						mov	al,[esi]
						Inc	esi
						Sub	al,48
						cmp	al,10
						jb		L1
						Sub	al,7
					L1:
						mov	dl,al
						mov	al,[esi]
						Inc	esi
						Sub	al,48
						cmp	al,10
						jb		L2
						Sub	al,7
					L2:
						Shl	dl,4
						Or		dl,al
						mov	[edi],dl
						Inc	edi
						Inc	ecx
						cmp	ecx,[nlen]
						jne	L0
						pop	edi
						pop	esi
					End Asm
					WriteFile(hBinFile,@buff,nlen,@nlen,NULL)
				EndIf
		End Select
	Wend
	Close

End Sub

Function CreateNewProject(ByVal hWin As HWND,ByVal hTab1 As HWND,ByVal hTab2 As HWND) As Boolean
	Dim nInx As Integer
	Dim sItem As ZString*260
	Dim sFile As ZString*260
	Dim hFile As HANDLE
	Dim lret As Integer
	Dim sProName As String

	' Create project path
	GetDlgItemText(hWin,IDC_EDTPROJECTPATH,@buff,260)
	GetDlgItemText(hWin,IDC_EDTPROJECTNAME,@sItem,SizeOf(sItem))
	If IsDlgButtonChecked(hWin,IDC_CHKSUB) Then
		lstrcat(@buff,StrPtr("\"))
		lstrcat(@buff,@sItem)
	EndIf
	sProName=sItem
	lret=GetFileAttributes(@buff)
	If lret=-1 Then
		If CreateDirectory(@buff,NULL)=0 Then
			sFile=GetInternalString(IS_FAILED_TO_CREATE_THE_FOLDER)
			MessageBox(hWin,sFile & CRLF & CRLF & buff,@szAppName,MB_OK Or MB_ICONERROR)
			Return FALSE
		EndIf
	Else
		sFile=GetInternalString(IS_FOLDER_EXISTS)
		If MessageBox(hWin,buff & CRLF & CRLF & sFile,@szAppName,MB_YESNO Or MB_ICONWARNING)=IDNO Then
			Return FALSE
		EndIf
	EndIf
	ad.ProjectPath=buff
	' Create project file
	lstrcat(@buff,StrPtr("\"))
	lstrcat(@buff,@sItem)
	sItem=buff
	lstrcat(@sItem,StrPtr(".fbp"))
	If GetFileAttributes(@sItem)<>-1 Then
		sFile=GetInternalString(IS_PROJECT_FILE_EXISTS)
		If MessageBox(hWin,sItem & CRLF & CRLF & sFile,@szAppName,MB_YESNO Or MB_ICONWARNING)=IDNO Then
			Return FALSE
		EndIf
	EndIf
	hFile=CreateFile(@sItem,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0)
	If hFile<>INVALID_HANDLE_VALUE Then
		CloseHandle(hFile)
		fProject=TRUE
		ad.ProjectFile=sItem
		GetDlgItemText(hWin,IDC_EDTPROJECTDESCRIPTION,@ProjectDescription,SizeOf(ProjectDescription))
		nInx=SendDlgItemMessage(hTab2,IDC_LSTNEWPROJECTTPL,LB_GETCURSEL,0,0)
		If nInx Then
			' Template used
			SendDlgItemMessage(hTab2,IDC_LSTNEWPROJECTTPL,LB_GETTEXT,nInx,Cast(LPARAM,@sFile))
			sFile=ad.AppPath & "\Templates\" & sFile
			GetPrivateProfileSection(StrPtr("Project"),@s,4096,@sFile)
			WritePrivateProfileSection(StrPtr("Project"),@s,@ad.ProjectFile)
			GetPrivateProfileSection(StrPtr("Make"),@s,4096,@sFile)
			WritePrivateProfileSection(StrPtr("Make"),@s,@ad.ProjectFile)
			GetPrivateProfileString(StrPtr("Make"),StrPtr("Output"),@szNULL,@s,4096,@ad.ProjectFile)
			lret=InStr(s,"[*PRONAME*]")
			If lret Then
				s=Left(s,lret-1) & sProName & Mid(s,lret+11)
				WritePrivateProfileString(StrPtr("Make"),StrPtr("Output"),@s,@ad.ProjectFile)
			EndIf
			WritePrivateProfileString(StrPtr("Project"),StrPtr("Description"),@ProjectDescription,@ad.ProjectFile)
			OpenProject
			UseTemplate(sFile,sProName)
		Else
			' No template used
			WritePrivateProfileString(StrPtr("Project"),StrPtr("Version"),StrPtr("2"),@ad.ProjectFile)
			WritePrivateProfileString(StrPtr("Project"),StrPtr("Description"),@ProjectDescription,@ad.ProjectFile)
			WritePrivateProfileString(StrPtr("Project"),StrPtr("Api"),@DefApiFiles,@ad.ProjectFile)
			' Project type
			nInx=SendDlgItemMessage(hTab1,IDC_CBOPROJECTTYPE,CB_GETCURSEL,0,0)
			GetPrivateProfileString(StrPtr("Make"),Str(nInx+1),@szNULL,@sItem,SizeOf(sItem),@ad.IniFile)
			WritePrivateProfileString(StrPtr("Make"),StrPtr("Current"),StrPtr("1"),@ad.ProjectFile)
			WritePrivateProfileString(StrPtr("Make"),StrPtr("1"),@sItem,@ad.ProjectFile)
			WritePrivateProfileString(StrPtr("Make"),StrPtr("Recompile"),StrPtr("2"),@ad.ProjectFile)
			WritePrivateProfileString(StrPtr("Make"),StrPtr("Module"),StrPtr("Module Build,fbc -c"),@ad.ProjectFile)
			sItem=buff
			OpenProject
			' Add files
			If IsDlgButtonChecked(hTab1,IDC_CHKCODE) Then
				sFile=sItem
				lstrcat(@sFile,StrPtr(".bas"))
				If GetFileAttributes(@sFile)=-1 Then
					AddAProjectFile(sFile,FALSE,TRUE)
				Else
					AddAProjectFile(sFile,FALSE,FALSE)
				EndIf
			EndIf
			If IsDlgButtonChecked(hTab1,IDC_CHKRESOURCE) Then
				sFile=sItem
				lstrcat(@sFile,StrPtr(".rc"))
				If GetFileAttributes(@sFile)=-1 Then
					AddAProjectFile(sFile,FALSE,TRUE)
				Else
					AddAProjectFile(sFile,FALSE,FALSE)
				EndIf
			EndIf
			If IsDlgButtonChecked(hTab1,IDC_CHKINCLUDE) Then
				sFile=sItem
				lstrcat(@sFile,StrPtr(".bi"))
				If GetFileAttributes(@sFile)=-1 Then
					AddAProjectFile(sFile,FALSE,TRUE)
				Else
					AddAProjectFile(sFile,FALSE,FALSE)
				EndIf
			EndIf
			If IsDlgButtonChecked(hTab1,IDC_CHKTEXT) Then
				sFile=sItem
				lstrcat(@sFile,StrPtr(".txt"))
				If GetFileAttributes(@sFile)=-1 Then
					AddAProjectFile(sFile,FALSE,TRUE)
				Else
					AddAProjectFile(sFile,FALSE,FALSE)
				EndIf
			EndIf
		EndIf
		' Create folders
		If IsDlgButtonChecked(hWin,IDC_CHKBAK) Then
			buff=ad.ProjectPath & "\Bak"
			CreateDirectory(@buff,NULL)
		EndIf
		If IsDlgButtonChecked(hWin,IDC_CHKRES) Then
			buff=ad.ProjectPath & "\Res"
			CreateDirectory(@buff,NULL)
		EndIf
		If IsDlgButtonChecked(hWin,IDC_CHKMOD) Then
			buff=ad.ProjectPath & "\Mod"
			CreateDirectory(@buff,NULL)
		EndIf
		If IsDlgButtonChecked(hWin,IDC_CHKINC) Then
			buff=ad.ProjectPath & "\Inc"
			CreateDirectory(@buff,NULL)
		EndIf
		Return TRUE
	Else
		sFile=GetInternalString(IS_FAILED_TO_CREATE_THE_FILE)
		MessageBox(hWin,sFile & CRLF & CRLF & sItem,@szAppName,MB_OK Or MB_ICONERROR)
	EndIf
	Return FALSE

End Function

Function NewProjectTab1Proc(ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer
	Dim nInx As Integer
	Dim sItem As ZString*260
	Dim x As Integer

	Select Case uMsg
		Case WM_INITDIALOG
			TranslateDialog(hWin,IDD_NEWPROJECT1)
			nInx=1
			Do While nInx<20
				sItem=Str(nInx)
				GetPrivateProfileString(StrPtr("Make"),@sItem,@szNULL,@buff,260,@ad.IniFile)
				If Len(buff) Then
					x=InStr(buff,",")
					buff[x-1]=NULL
					SendDlgItemMessage(hWin,IDC_CBOPROJECTTYPE,CB_ADDSTRING,0,Cast(Integer,@buff))
				EndIf
				nInx+=1
			Loop
			SendDlgItemMessage(hWin,IDC_CBOPROJECTTYPE,CB_SETCURSEL,0,0)
			CheckDlgButton(hWin,IDC_CHKCODE,BST_CHECKED)
			'
		Case Else
			Return FALSE
			'
	End Select
	Return TRUE

End Function

Function NewProjectTab2Proc(ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer
	Dim wfd As WIN32_FIND_DATA
	Dim hwfd As HANDLE
	Dim nInx As Integer
	Dim hFile As HANDLE

	Select Case uMsg
		Case WM_INITDIALOG
			TranslateDialog(hWin,IDD_NEWPROJECT2)
			SendDlgItemMessage(hWin,IDC_LSTNEWPROJECTTPL,LB_ADDSTRING,0,Cast(LPARAM,StrPtr("(None)")))
			buff=ad.AppPath & "\Templates\*.tpl"
			hwfd=FindFirstFile(@buff,@wfd)
			If hwfd<>INVALID_HANDLE_VALUE Then
				While TRUE
					SendDlgItemMessage(hWin,IDC_LSTNEWPROJECTTPL,LB_ADDSTRING,0,Cast(LPARAM,@wfd.cFileName))
					If FindNextFile(hwfd,@wfd)=FALSE Then
						Exit While
					EndIf
				Wend
				FindClose(hwfd)
			EndIf
			SendDlgItemMessage(hWin,IDC_LSTNEWPROJECTTPL,LB_SETCURSEL,0,0)
			'
		Case WM_COMMAND
			Select Case HiWord(wParam)
				Case LBN_SELCHANGE
					buff=szNULL
					nInx=SendDlgItemMessage(hWin,IDC_LSTNEWPROJECTTPL,LB_GETCURSEL,0,0)
					If nInx Then
						SendDlgItemMessage(hWin,IDC_LSTNEWPROJECTTPL,LB_GETTEXT,nInx,Cast(LPARAM,@buff))
						buff=ad.AppPath & "\Templates\" & buff
						hFile=CreateFile(@buff,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0)
						If hFile<>INVALID_HANDLE_VALUE Then
							ReadFile(hFile,@buff,1024,@nInx,NULL)
							nInx=InStr(buff,CRLF)
							buff=Mid(buff,nInx+2)
							nInx=InStr(buff,szBPRO)
							buff=Left(buff,nInx-1)
							CloseHandle(hFile)
						EndIf
					EndIf
					SetDlgItemText(hWin,IDC_STCNEWPROJECTTPL,@buff)
					'
			End Select
			'
		Case Else
			Return FALSE
			'
	End Select
	Return TRUE

End Function

Function NewProjectDlgProc(ByVal hWin As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As Integer
	Dim nInx As Integer
	Dim sItem As ZString*260
	Dim x As Integer
	Dim ts As TCITEM
	Dim lpNMHDR As NMHDR Ptr
	Dim hNPTab As HWND

	Select Case uMsg
		Case WM_INITDIALOG
			TranslateDialog(hWin,IDD_NEWPROJECT)
			CenterOwner(hWin)
			hNPTab=GetDlgItem(hWin,IDC_TABNEWPROJECT)
			ts.mask=TCIF_TEXT
			sItem=GetInternalString(IS_FILES)
			ts.pszText=@sItem
			SendMessage(hNPTab,TCM_INSERTITEM,0,Cast(LPARAM,@ts))
			sItem=GetInternalString(IS_TEMPLATE)
			ts.pszText=@sItem
			SendMessage(hNPTab,TCM_INSERTITEM,1,Cast(LPARAM,@ts))
			'Create the tab dialogs
			hTabNewProject1=CreateDialogParam(hInstance,Cast(ZString Ptr,IDD_NEWPROJECT1),hNPTab,@NewProjectTab1Proc,0)
			hTabNewProject2=CreateDialogParam(hInstance,Cast(ZString Ptr,IDD_NEWPROJECT2),hNPTab,@NewProjectTab2Proc,0)
			SetDlgItemText(hWin,IDC_EDTPROJECTPATH,@ad.DefProjectPath)
			SendDlgItemMessage(hWin,IDC_EDTPROJECTNAME,EM_LIMITTEXT,64,0)
			SendDlgItemMessage(hWin,IDC_EDTPROJECTDESCRIPTION,EM_LIMITTEXT,64,0)
			CheckDlgButton(hWin,IDC_CHKSUB,BST_CHECKED)
			CheckDlgButton(hWin,IDC_CHKBAK,BST_CHECKED)
			'
		Case WM_CLOSE
			EndDialog(hWin, 0)
			'
		Case WM_COMMAND
			Select Case HiWord(wParam)
				Case BN_CLICKED
					Select Case LoWord(wParam)
						Case IDOK
							If CloseProject Then
								If CreateNewProject(hWin,hTabNewProject1,hTabNewProject2) Then
									EndDialog(hWin, 0)
								EndIf
							EndIf
							'
						Case IDCANCEL
							EndDialog(hWin, 0)
							'
						Case IDC_BTNPROJECTPATH
							BrowseFolder(hWin,IDC_EDTPROJECTPATH)
							'
					End Select
					'
				Case EN_CHANGE
					GetDlgItemText(hWin,IDC_EDTPROJECTNAME,@sItem,SizeOf(sItem))
					If Len(sItem) Then
						GetDlgItemText(hWin,IDC_EDTPROJECTDESCRIPTION,@sItem,SizeOf(sItem))
						If Len(sItem) Then
							EnableWindow(GetDlgItem(hWin,IDOK),TRUE)
							Return TRUE
						EndIf
					EndIf
					EnableWindow(GetDlgItem(hWin,IDOK),FALSE)
					'
			End Select
			'
		Case WM_NOTIFY
			lpNMHDR=Cast(NMHDR Ptr,lParam)
			If lpNMHDR->code=TCN_SELCHANGE Then
				'A tab selection is made
				nInx=SendDlgItemMessage(hWin,IDC_TABNEWPROJECT,TCM_GETCURSEL,0,0)
				Select Case nInx
					Case 0
						ShowWindow(hTabNewProject2,SW_HIDE)
						ShowWindow(hTabNewProject1,SW_SHOWDEFAULT)
					Case 1
						ShowWindow(hTabNewProject1,SW_HIDE)
						ShowWindow(hTabNewProject2,SW_SHOWDEFAULT)
				End Select
			EndIf
			'
		Case Else
			Return FALSE
			'
	End Select
	Return TRUE

End Function

Function ApiListProc(ByVal hWin As HWND,ByVal uMsg As UINT,wParam As WPARAM,lParam As LPARAM) As Integer
	Dim pt As Point
	Dim cursel As Integer
	Dim chkval As Integer

	Select Case uMsg
		Case WM_LBUTTONDOWN
			SetCapture(hWin)
			'
		Case WM_LBUTTONUP
			pt.x=LoWord(lParam)
			pt.y=HiWord(lParam)
			If pt.x>=1 And pt.x<=14 Then
				cursel=SendMessage(hWin,LB_GETCURSEL,0,0)
				chkval=SendMessage(hWin,LB_GETITEMDATA,cursel,0) Xor 1
				SendMessage(hWin,LB_SETITEMDATA,cursel,chkval)
				InvalidateRect(hWin,NULL,TRUE)
			EndIf
			ReleaseCapture
			'
	End Select
	Return CallWindowProc(lpOldApiListProc,hWin,uMsg,wParam,lParam)

End Function

Function ApiOptionProc(ByVal hWin As HWND,ByVal uMsg As UINT,wParam As WPARAM,lParam As LPARAM) As Integer
	Dim nInx As Integer
	Dim lpDRAWITEMSTRUCT As DRAWITEMSTRUCT Ptr
	Dim rect As RECT
	Dim sItem As ZString*256
	Dim hLst As HWND
	Dim x As Integer
	Dim s As String

	Select Case uMsg
		Case WM_INITDIALOG
			TranslateDialog(hWin,IDD_DLGPROJECTOPTIONAPI)
			CenterOwner(hWin)
			hLst=GetDlgItem(hWin,IDC_LSTAPIFILES)
			lpOldApiListProc=Cast(Any Ptr,SetWindowLong(hLst,GWL_WNDPROC,Cast(Integer,@ApiListProc)))
			s=ApiFiles
			While Len(s)
				sItem=GetTextItem(s)
				nInx=SendMessage(hLst,LB_ADDSTRING,0,Cast(LPARAM,@sItem))
				If InStr(ProjectApiFiles,sItem) Then
					SendMessage(hLst,LB_SETITEMDATA,nInx,1)
				EndIf
			Wend
			SendMessage(hLst,LB_SETCURSEL,0,0)
			'
		Case WM_CLOSE
			EndDialog(hWin, 0)
			'
		Case WM_COMMAND
			Select Case HiWord(wParam)
				Case BN_CLICKED
					Select Case LoWord(wParam)
						Case IDCANCEL
							EndDialog(hWin, 0)
							'
						Case IDOK
							nInx=0
							buff=""
							While TRUE
								If SendDlgItemMessage(hWin,IDC_LSTAPIFILES,LB_GETTEXT,nInx,Cast(LPARAM,@sItem))=LB_ERR Then
									Exit While
								EndIf
								x=SendDlgItemMessage(hWin,IDC_LSTAPIFILES,LB_GETITEMDATA,nInx,0)
								If x Then
									If Len(buff) Then
										buff=buff & ","
									EndIf
									buff=buff & sItem
								EndIf
								nInx+=1
							Wend
							EndDialog(hWin,TRUE)
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
			' Draw the checkbox
			rect.left=lpDRAWITEMSTRUCT->rcItem.left+1
			rect.right=rect.left+13
			rect.top=lpDRAWITEMSTRUCT->rcItem.top+1
			rect.bottom=rect.top+13
			If lpDRAWITEMSTRUCT->itemData Then
				nInx=DFCS_BUTTONCHECK Or DFCS_FLAT Or DFCS_CHECKED
			Else
				nInx=DFCS_BUTTONCHECK Or DFCS_FLAT
			EndIf
			DrawFrameControl(lpDRAWITEMSTRUCT->hdc,@rect,DFC_BUTTON,nInx)
			' Draw the text
			SendMessage(lpDRAWITEMSTRUCT->hwndItem,LB_GETTEXT,lpDRAWITEMSTRUCT->itemID,Cast(Integer,@sItem))
			TextOut(lpDRAWITEMSTRUCT->hdc,lpDRAWITEMSTRUCT->rcItem.left+18,lpDRAWITEMSTRUCT->rcItem.top,@sItem,Len(sItem))
			If lpDRAWITEMSTRUCT->hwndItem=GetFocus() Then
				' Let windows draw the focus rectangle
				Return FALSE
			EndIf
			'
		Case Else
			Return FALSE
			'
	End Select
	Return TRUE

End Function

Function ProjectOptionDlgProc(ByVal hWin As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As Integer
	Dim x As Integer
	Dim sItem As ZString*260
	Dim sText As ZString*260

	Select Case uMsg
		Case WM_INITDIALOG
			TranslateDialog(hWin,IDD_DLGPROJECTOPTION)
			CenterOwner(hWin)
			SendDlgItemMessage(hWin,IDC_EDTPODESCRIPTION,EM_LIMITTEXT,64,0)
			SendDlgItemMessage(hWin,IDC_EDTPOTYPE,EM_LIMITTEXT,64,0)
			SendDlgItemMessage(hWin,IDC_EDTPOBUILD,EM_LIMITTEXT,128,0)
			SendDlgItemMessage(hWin,IDC_EDTPOMODULE,EM_LIMITTEXT,128,0)
			SendDlgItemMessage(hWin,IDC_EDTOUTFILE,EM_LIMITTEXT,64,0)
			SendDlgItemMessage(hWin,IDC_EDTRUN,EM_LIMITTEXT,64,0)
			SendDlgItemMessage(hWin,IDC_EDTDELETE,EM_LIMITTEXT,128,0)
			SetDlgItemText(hWin,IDC_EDTPODESCRIPTION,@ProjectDescription)
			x=GetPrivateProfileInt(StrPtr("Make"),StrPtr("Current"),1,@ad.ProjectFile)
			GetPrivateProfileString(StrPtr("Make"),Str(x),@szNULL,@sItem,SizeOf(sItem),@ad.ProjectFile)
			If Len(sItem) Then
				x=InStr(sItem,",")
				sText=Left(sItem,x-1)
				SetDlgItemText(hWin,IDC_EDTPOTYPE,@sText)
				sItem=Mid(sItem,x+1)
				SetDlgItemText(hWin,IDC_EDTPOBUILD,@sItem)
			EndIf
			GetPrivateProfileString(StrPtr("Make"),StrPtr("Module"),StrPtr("Module Build,fbc -c"),@sItem,SizeOf(sItem),@ad.ProjectFile)
			If Len(sItem) Then
				x=InStr(sItem,",")
				sItem=Mid(sItem,x+1)
				SetDlgItemText(hWin,IDC_EDTPOMODULE,@sItem)
			EndIf
			SetDlgItemText(hWin,IDC_EDTAPIFILES,@ProjectApiFiles)
			SetDlgItemText(hWin,IDC_EDTDELETE,@ProjectDeleteFiles)
			CheckDlgButton(hWin,IDC_RBNMODMANUAL+fRecompile,TRUE)
			CheckDlgButton(hWin,IDC_CHKADDMAINFILES,fAddMainFiles)
			GetPrivateProfileString(StrPtr("Make"),StrPtr("Output"),@szNULL,@sItem,SizeOf(sItem),@ad.ProjectFile)
			SetDlgItemText(hWin,IDC_EDTOUTFILE,@sItem)
			GetPrivateProfileString(StrPtr("Make"),StrPtr("Run"),@szNULL,@sItem,SizeOf(sItem),@ad.ProjectFile)
			SetDlgItemText(hWin,IDC_EDTRUN,@sItem)
			CheckDlgButton(hWin,IDC_RBNGRPNONE+nProjectGroup,BST_CHECKED)
			SetDlgItemText(hWin,IDC_EDTRESOURCEEXPORT,@ad.resexport)
			CheckDlgButton(hWin,IDC_CHKCOMPILENEWER,fCompileIfNewer)
			CheckDlgButton(hWin,IDC_CHKADDMODULEFILES,fAddModuleFiles)
			CheckDlgButton(hWin,IDC_CHKINCVERSION,fIncVersion)
			CheckDlgButton(hWin,IDC_CHKRUN,fRunCmd)
			'
		Case WM_CLOSE
			EndDialog(hWin, 0)
			'
		Case WM_COMMAND
			Select Case LoWord(wParam)
				Case IDOK
					GetDlgItemText(hWin,IDC_EDTPODESCRIPTION,@ProjectDescription,SizeOf(ProjectDescription))
					WritePrivateProfileString(StrPtr("Project"),StrPtr("Description"),@ProjectDescription,@ad.ProjectFile)
					x=GetPrivateProfileInt(StrPtr("Make"),StrPtr("Current"),1,@ad.ProjectFile)
					GetDlgItemText(hWin,IDC_EDTPOTYPE,@sItem,SizeOf(sItem))
					GetDlgItemText(hWin,IDC_EDTPOBUILD,@sText,SizeOf(sText))
					sItem=sItem & "," & sText
					WritePrivateProfileString(StrPtr("Make"),Str(x),@sItem,@ad.ProjectFile)
					GetDlgItemText(hWin,IDC_EDTPOMODULE,@sItem,SizeOf(sItem))
					sItem="Module Build," & sItem
					WritePrivateProfileString(StrPtr("Make"),StrPtr("Module"),@sItem,@ad.ProjectFile)
					GetDlgItemText(hWin,IDC_EDTAPIFILES,@ProjectApiFiles,SizeOf(ProjectApiFiles))
					WritePrivateProfileString(StrPtr("Project"),StrPtr("Api"),@ProjectApiFiles,@ad.ProjectFile)
					If IsDlgButtonChecked(hWin,IDC_RBNMODMANUAL) Then
						fRecompile=0
					ElseIf IsDlgButtonChecked(hWin,IDC_RBNMODAUTO) Then
						fRecompile=1
					ElseIf IsDlgButtonChecked(hWin,IDC_RBNMODCMD) Then
						fRecompile=2
					EndIf
					WritePrivateProfileString(StrPtr("Make"),StrPtr("Recompile"),Str(fRecompile),@ad.ProjectFile)
					GetDlgItemText(hWin,IDC_EDTOUTFILE,@sItem,SizeOf(sItem))
					WritePrivateProfileString(StrPtr("Make"),StrPtr("Output"),@sItem,@ad.ProjectFile)
					GetDlgItemText(hWin,IDC_EDTRUN,@sItem,SizeOf(sItem))
					WritePrivateProfileString(StrPtr("Make"),StrPtr("Run"),@sItem,@ad.ProjectFile)
					GetDlgItemText(hWin,IDC_EDTDELETE,@sItem,SizeOf(sItem))
					WritePrivateProfileString(StrPtr("Make"),StrPtr("Delete"),@sItem,@ad.ProjectFile)
					If IsDlgButtonChecked(hWin,IDC_RBNGRPNONE) Then
						nProjectGroup=0
					ElseIf IsDlgButtonChecked(hWin,IDC_RBNGRPFOLDER) Then
						nProjectGroup=1
					ElseIf IsDlgButtonChecked(hWin,IDC_RBNGRPTYPE) Then
						nProjectGroup=2
					EndIf
					WritePrivateProfileString(StrPtr("Project"),StrPtr("Grouping"),Str(nProjectGroup),@ad.ProjectFile)
					fAddMainFiles=IsDlgButtonChecked(hWin,IDC_CHKADDMAINFILES)
					WritePrivateProfileString(StrPtr("Project"),StrPtr("AddMainFiles"),Str(fAddMainFiles),@ad.ProjectFile)
					fAddModuleFiles=IsDlgButtonChecked(hWin,IDC_CHKADDMODULEFILES)
					WritePrivateProfileString(StrPtr("Project"),StrPtr("AddModuleFiles"),Str(fAddModuleFiles),@ad.ProjectFile)
					GetDlgItemText(hWin,IDC_EDTRESOURCEEXPORT,@ad.resexport,SizeOf(ad.resexport))
					WritePrivateProfileString(StrPtr("Project"),StrPtr("ResExport"),@ad.resexport,@ad.ProjectFile)
					fCompileIfNewer=IsDlgButtonChecked(hWin,IDC_CHKCOMPILENEWER)
					WritePrivateProfileString(StrPtr("Project"),StrPtr("CompileIfNewer"),Str(fCompileIfNewer),@ad.ProjectFile)
					fIncVersion=IsDlgButtonChecked(hWin,IDC_CHKINCVERSION)
					WritePrivateProfileString(StrPtr("Project"),StrPtr("IncVersion"),Str(fIncVersion),@ad.ProjectFile)
					fRunCmd=IsDlgButtonChecked(hWin,IDC_CHKRUN)
					WritePrivateProfileString(StrPtr("Project"),StrPtr("RunCmd"),Str(fRunCmd),@ad.ProjectFile)
					RefreshProjectTree
					GetMakeOption
					SetWinCaption
					AddMruProject
					SetHiliteWords(ah.hwnd)
					' Add api files
					LoadApiFiles
					SetHiliteWordsFromApi(ah.hwnd)
					UpdateAllTabs(1)
					ReparseProject
					EndDialog(hWin, 0)
					'
				Case IDCANCEL
					EndDialog(hWin, 0)
					'
				Case IDC_BTNMAKEOPT
					DialogBoxParam(hInstance,Cast(ZString Ptr,IDD_DLGOPTMNU),hWin,@MenuOptionDlgProc,4)
					x=GetPrivateProfileInt(StrPtr("Make"),StrPtr("Current"),1,@ad.ProjectFile)
					GetPrivateProfileString(StrPtr("Make"),Str(x),@szNULL,@sItem,SizeOf(sItem),@ad.ProjectFile)
					If Len(sItem) Then
						x=InStr(sItem,",")
						sText=Left(sItem,x-1)
						SetDlgItemText(hWin,IDC_EDTPOTYPE,@sText)
						sItem=Mid(sItem,x+1)
						SetDlgItemText(hWin,IDC_EDTPOBUILD,@sItem)
					EndIf
					'
				Case IDC_BTNAPIFILES
					If DialogBoxParam(hInstance,Cast(ZString Ptr,IDD_DLGPROJECTOPTIONAPI),hWin,@ApiOptionProc,0) Then
						SetDlgItemText(hWin,IDC_EDTAPIFILES,@buff)
					EndIf
					'
			End Select
		Case Else
			Return FALSE
			'
	End Select
	Return TRUE

End Function

Function ProjectProc(ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer
	Dim lret As Integer
	Dim id As Integer
	Dim hItem As Integer
	Dim ht As TVHITTESTINFO
	Dim tvi As TV_ITEM
	Dim sFile As String*260
	Dim fCtrl As Boolean

	Select Case uMsg
		Case WM_LBUTTONDBLCLK
			lret=CallWindowProc(lpOldProjectProc,hWin,uMsg,wParam,lParam)
			ht.pt.x=LoWord(lParam)
			ht.pt.y=HiWord(lParam)
			If SendMessage(hWin,TVM_HITTEST,0,Cast(Integer,@ht)) Then
				tvi.hItem=ht.hItem
				tvi.mask=TVIF_PARAM Or TVIF_TEXT
				tvi.pszText=@buff
				tvi.cchTextMax=260
				SendMessage(hWin,TVM_GETITEM,0,Cast(Integer,@tvi))
				If tvi.lParam Then
					If nProjectGroup<>1 Then
						If Mid(buff,2,2)=":\" Then
							sFile=buff
						Else
							sFile=MakeProjectFileName(buff)
						EndIf
					Else
						Dim path As String
						path = ModPath.GetPathFromProjectFile(ah.hprj, tvi.hItem)
						sFile = *StrPtr(path)
						If Mid(sFile,2,2)=":\" Then
						Else
							sFile=MakeProjectFileName(sFile)
						EndIf
					EndIf 
					OpenTheFile(sFile,FALSE)
					fTimer=1
				EndIf
			EndIf
			Return lret
		Case WM_RBUTTONDOWN
			ht.pt.x=LoWord(lParam)
			ht.pt.y=HiWord(lParam)
			SendMessage(hWin,TVM_HITTEST,0,Cast(Integer,@ht))
			SendMessage(hWin,TVM_SELECTITEM,TVGN_CARET,Cast(Integer,ht.hItem))
		Case WM_DROPFILES
			id=0
			lret=TRUE
			fCtrl=(GetKeyState(VK_CONTROL) And &H80)<>0
			Do While lret
				lret=DragQueryFile(Cast(HDROP,wParam),id,sFile,SizeOf(sFile))
				If lret Then
					If (GetFileAttributes(sFile) And FILE_ATTRIBUTE_DIRECTORY)=0 Then
						If fProject Then
							If fCtrl<>FALSE And GetFileImg(sFile)=1 Then
								' Module
								AddProjectFile(sFile,TRUE)
							Else
								AddProjectFile(sFile,FALSE)
							EndIf
						Else
							' Open single file
							OpenTheFile(sFile,FALSE)
						EndIf
					EndIf
				EndIf
				id+=1
			Loop
			'
		Case Else
			Return CallWindowProc(lpOldProjectProc,hWin,uMsg,wParam,lParam)
			'
	End Select
	Return 0

End Function

' ---------------------------------------------------------------------
' TYPE: MODULEPATH
' helper to handle the paths in project panel in folder view
' ---------------------------------------------------------------------

Sub MODULEPATH.SetPath(path As String, setmembers As Integer)
	relpath = path
	If setmembers = 1 Then 
		currentpath = relpath
		dim count As Integer = 0
		Dim path_length As Integer = Len(relpath)
		
		For i As Integer = 0 To path_length-1
			If Asc(relpath, i+1) = Asc("\") Then
				count+=1
			EndIf 
		Next i
		currentdepth = 0
		maxdepth = count
	EndIf
End Sub

Function MODULEPATH.GetNextFolder() As String
	Dim As String fold, current
	Dim position As Integer
	
	current = currentpath
	If currentdepth < maxdepth Then
		position = InStr(current, "\")
		If position>0 Then 
			fold = Left(current, position-1)
			current = Mid(current, position+1)
			currentpath = current
		EndIf
	EndIf

	currentdepth+=1
	Return fold
End Function

Function MODULEPATH.GetPathFromProjectFile(hwndtv As HWND, itemid As HTREEITEM) As String
	Dim tvi As TVITEM
	Dim As String spath
	Dim As ZString *260 path
	Dim As HTREEITEM hbase, hparent
	
	hparent = itemid
	hbase = Cast(HTREEITEM,SendMessage(hwndtv,TVM_GETNEXTITEM,TVGN_CHILD, 0))
	Do
		tvi.hItem=hparent
		tvi.mask=TVIF_HANDLE Or TVIF_TEXT
		tvi.pszText=@path
		tvi.cchTextMax=SizeOf(path)
		SendMessage(hwndtv,TVM_GETITEM,0,Cast(LPARAM,@tvi))
		
		spath = path + "\" + spath
		
		hparent=Cast(HTREEITEM,SendMessage(hwndtv,TVM_GETNEXTITEM,TVGN_PARENT,Cast(LPARAM,hparent)))
	Loop While hparent <> hbase
	Return Left( spath, Len(spath)-1 )
End Function 

Function MODULEPATH.GetPathName() As String
	Return currentpath
End Function
