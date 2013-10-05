/'
	FbEdit language translation tool
'/

#Include Once "windows.bi"
#Include Once "win/commdlg.bi"

#Include "Language.bi"
#Include "FbEditLNG.bi"
#Include "MiscLNG.bas"
#Include "MenuLNG.bas"
#Include "DialogLNG.bas"
#Include "StringLNG.bas"

Function OpenProject(ByVal hWin As HWND) As Boolean
	Dim ofn As OPENFILENAME
	Dim buff As ZString*260
	Dim hFile As HANDLE
	Dim hMem As HGLOBAL
	Dim nSize As Integer

	ofn.lStructSize=SizeOf(OPENFILENAME)
	ofn.hwndOwner=hWin
	ofn.hInstance=hInstance
	ofn.lpstrInitialDir=@szAppPath
	buff=String(260,0)
	ofn.lpstrFile=@buff
	ofn.nMaxFile=260
	ofn.lpstrFilter=StrPtr(LNGFilterString)
	ofn.lpstrTitle=StrPtr("Open Project")
	ofn.Flags=OFN_FILEMUSTEXIST Or OFN_HIDEREADONLY Or OFN_PATHMUSTEXIST Or OFN_EXPLORER
	If GetOpenFileName(@ofn) Then
		hFile=CreateFile(buff,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0)
		If hFile<>INVALID_HANDLE_VALUE Then
			hMem=GlobalAlloc(GMEM_FIXED Or GMEM_ZEROINIT,256*1024)
			nSize=GetFileSize(hFile,NULL)
			ReadFile(hFile,hMem,nSize,@nSize,0)
			SendMessage(hEdt,WM_SETTEXT,0,Cast(LPARAM,hMem))
			CloseHandle(hFile)
			szFileName=buff
			GlobalFree(hMem)
			SetDlgItemText(hWin,IDC_EDTLNGFILE,@szFileName)
			SendMessage(hEdt,EM_SETMODIFY,FALSE,0)
		EndIf
		Return TRUE
	EndIf
	Return FALSE

End Function

Function SaveFileAs(ByVal hWin As HWND) As Boolean
	Dim ofn As OPENFILENAME
	Dim buff As ZString*260
	Dim hFile As HANDLE
	Dim hMem As HGLOBAL
	Dim nSize As Integer

	ofn.lStructSize=SizeOf(OPENFILENAME)
	ofn.hwndOwner=hWin
	ofn.hInstance=hInstance
	buff=szFileName
	ofn.lpstrFile=StrPtr(buff)
	ofn.nMaxFile=260
	ofn.lpstrDefExt=StrPtr("lng")
	ofn.lpstrFilter=StrPtr(LNGFilterString)
	ofn.Flags=OFN_HIDEREADONLY Or OFN_PATHMUSTEXIST Or OFN_OVERWRITEPROMPT
	If GetSaveFileName(@ofn) Then
		hFile=CreateFile(buff,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0)
		If hFile<>INVALID_HANDLE_VALUE Then
			hMem=GlobalAlloc(GMEM_FIXED Or GMEM_ZEROINIT,256*1024)
			SendMessage(hEdt,WM_GETTEXT,256*1024,Cast(LPARAM,hMem))
			nSize=lstrlen(hMem)
			WriteFile(hFile,hMem,nSize,@nSize,NULL)
			CloseHandle(hFile)
			szFileName=buff
			GlobalFree(hMem)
			SetDlgItemText(hWin,IDC_EDTLNGFILE,@szFileName)
			SendMessage(hEdt,EM_SETMODIFY,FALSE,0)
		EndIf
		Return TRUE
	EndIf
	Return FALSE

End Function

Function WantToSave(ByVal hWin As HWND) As Boolean
	Dim lRet As Integer

	If SendMessage(hEdt,EM_GETMODIFY,0,0) Then
		lRet=MessageBox(hWin,"Save changes?",szAppName,MB_YESNOCANCEL)
		If lRet=IDYES Then
			Return SaveFileAs(hWin)
		ElseIf lRet=IDNO Then
			Return TRUE
		Else
			Return FALSE
		EndIf
	EndIf
	Return TRUE

End Function

Sub UpdateList(ByVal hWin As HWND)
	Dim lp As ZString Ptr
	Dim nInx As Integer

	lp=@szList
	While Asc(*lp)
		nInx=SendDlgItemMessage(hWin,IDC_LSTLNGDIALOG,LB_ADDSTRING,0,Cast(LPARAM,lp))
		lp+=1
		SendDlgItemMessage(hWin,IDC_LSTLNGDIALOG,LB_SETITEMDATA,nInx,Cast(LPARAM,Val(*lp)))
		lp=lp+lstrlen(lp)+1
	Wend
End Sub

Function DlgProc(ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer
	Dim As Long id, Event
	Dim lp As ZString Ptr
	Dim hMem As HGLOBAL
	Dim hFile As HANDLE
	Dim szFile As ZString*260

	Select Case uMsg
		Case WM_INITDIALOG
			hWnd=hWin
			hEdt=GetDlgItem(hWin,IDC_EDTLNGLANG)
			UpdateList(hWin)
			'
		Case WM_CLOSE
			If WantToSave(hWin) Then
				EndDialog(hWin, 0)
			EndIf
			'
		Case WM_COMMAND
			id=LoWord(wParam)
			Event=HiWord(wParam)
			Select Case Event
				Case BN_CLICKED
					Select Case id
						Case IDC_BTNLNGNEW
							If WantToSave(hWin) Then
								SendMessage(hEdt,WM_SETTEXT,0,0)
								SendMessage(hEdt,EM_REPLACESEL,FALSE,Cast(LPARAM,@szDivider))
								SendMessage(hEdt,EM_REPLACESEL,FALSE,Cast(LPARAM,@szNew))
								SendMessage(hEdt,EM_REPLACESEL,FALSE,Cast(LPARAM,@szDivider))
								id=1
								While id<30000
									DialogBoxParam(hInstance,Cast(ZString Ptr,id),hWin,@DumpDlgProc,id)
									id+=1
								Wend
								DumpMenu(10000)
								DumpMenu(20000)
								DumpStrings
								lp=@InternalStrings+2
								SendMessage(hEdt,EM_REPLACESEL,FALSE,Cast(LPARAM,lp))
								SendMessage(hEdt,EM_REPLACESEL,FALSE,Cast(LPARAM,@szDivider))
								szFile=szAppPath & "\Addins.txt"
								hFile=CreateFile(@szFile,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL)
								If hFile<>INVALID_HANDLE_VALUE Then
									hMem=GlobalAlloc(GMEM_FIXED Or GMEM_ZEROINIT,64*1024)
									ReadFile(hFile,hMem,65535,@id,NULL)
									SendMessage(hEdt,EM_REPLACESEL,FALSE,Cast(LPARAM,hMem))
									GlobalFree(hMem)
									CloseHandle(hFile)
									SendMessage(hEdt,EM_REPLACESEL,FALSE,Cast(LPARAM,@szDivider))
								EndIf
							EndIf
							SetFocus(hEdt)
						Case IDC_BTNFILE
							If WantToSave(hWin) Then
								OpenProject(hWin)
							EndIf
							SetFocus(hEdt)
						Case IDC_BTNLNGSAVE
							SaveFileAs(hWin)
							SetFocus(hEdt)
					End Select
				Case LBN_DBLCLK
					id=SendDlgItemMessage(hWin,IDC_LSTLNGDIALOG,LB_GETCURSEL,0,0)
					id=SendDlgItemMessage(hWin,IDC_LSTLNGDIALOG,LB_GETITEMDATA,id,0)
					Select Case id
						Case 10000,20000
							DialogBoxParam(hInstance,Cast(ZString Ptr,IDD_DLGMENU),hWin,@DlgMenuProc,id)
							SetFocus(hEdt)
						Case 99999
						Case Else
							DialogBoxParam(hInstance,Cast(ZString Ptr,id),hWin,@TestDlgProc,id)
							SetFocus(hEdt)
					End Select
			End Select
		Case Else
			Return FALSE
			'
	End Select
	Return TRUE

End Function

'''
''' Program start
'''

	''
	'' Create the Dialog
	''
	hInstance=GetModuleHandle(NULL)
	' Get AppPath
	GetModuleFileName(NULL,@szAppPath,260)
	GetFilePath(szAppPath)
	SetCurrentDirectory(@szAppPath)

	hRichEditDll=LoadLibrary("riched20.dll")
	hFbEditDll=LoadLibrary("FbEdit.dll")
	If hFbEditDll Then
		DialogBoxParam(hInstance,Cast(ZString Ptr,IDD_DLGLNG),NULL,@DlgProc,NULL)
		FreeLibrary(hFbEditDll)
	Else
		MessageBox(NULL,StrPtr("Could not find FbEdit.dll"),@szAppName,MB_OK Or MB_ICONERROR)
	EndIf
	FreeLibrary(hRichEditDll)

	''
	'' Program has ended
	''

	ExitProcess(0)
	End

'''
''' Program end
'''
