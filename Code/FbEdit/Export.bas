

#Include Once "windows.bi"

#Include Once "Inc\RAEdit.bi"
#Include Once "Inc\RAProperty.bi"

#Include Once "Inc\Addins.bi"
#Include Once "Inc\FbEdit.bi"
#Include Once "Inc\GUIHandling.bi"
#Include Once "Inc\Language.bi"
#Include Once "Inc\Resource.bi"
#Include Once "Inc\ZStringHandling.bi"

#Include Once "Inc\Export.bi"



Sub ExportFunctions()
	Dim lret As ZString Ptr

	lret=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_FINDFIRST,Cast(Integer,StrPtr("p")),Cast(Integer,StrPtr(""))))
	Do While lret
		SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,lret))
		lret=lret+Len(*lret)+1
		If IsZStrNotEmpty (*lret) Then
			' Parameters
			SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,StrPtr(",")))
			SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,lret))
			lret=lret+Len(*lret)+1
			If IsZStrNotEmpty (*lret) Then
				' Return type
				SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,StrPtr("|")))
				SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,lret))
				lret=lret+Len(*lret)+1
			Else
				' Skip return type
				lret=lret+1
			EndIf
		Else
			' Skip parameters
			lret=lret+1
			If IsZStrNotEmpty (*lret) Then
				' Return type
				SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,StrPtr("|")))
				SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,lret))
				lret=lret+Len(*lret)+1
			Else
				' Skip return type
				lret=lret+1
			EndIf
		EndIf
		If IsZStrNotEmpty (*lret) Then
			' Locals
			SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,StrPtr(" L:")))
			SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,lret))
		EndIf
		SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,StrPtr(CR)))
		lret=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_FINDNEXT,0,0))
	Loop

End Sub

Sub ExportConstants()
	Dim lret As ZString Ptr

	lret=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_FINDFIRST,Cast(Integer,StrPtr("c")),Cast(Integer,StrPtr(""))))
	Do While lret
		SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,lret))
		SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,StrPtr(CR)))
		lret=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_FINDNEXT,0,0))
	Loop

End Sub

Sub ExportData()
	Dim lret As ZString Ptr

	lret=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_FINDFIRST,Cast(Integer,StrPtr("d")),Cast(Integer,StrPtr(""))))
	Do While lret
		SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,lret))
		SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,StrPtr(",")))
		lret=lret+Len(*lret)+1
		SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,lret))
		SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,StrPtr(CR)))
		lret=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_FINDNEXT,0,0))
	Loop

End Sub

Sub ExportUDTs()
	Dim lret As ZString Ptr

	lret=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_FINDFIRST,Cast(Integer,StrPtr("s")),Cast(Integer,StrPtr(""))))
	Do While lret
		SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,lret))
		SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,StrPtr(",")))
		lret=lret+Len(*lret)+1
		SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,lret))
		SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,StrPtr(CR)))
		lret=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_FINDNEXT,0,0))
	Loop

End Sub

Sub ExportEnums()
	Dim lret As ZString Ptr

	lret=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_FINDFIRST,Cast(Integer,StrPtr("e")),Cast(Integer,StrPtr(""))))
	Do While lret
		SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,lret))
		SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,StrPtr(",")))
		lret=lret+Len(*lret)+1
		SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,lret))
		SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,StrPtr(CR)))
		lret=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_FINDNEXT,0,0))
	Loop

End Sub

Sub ExportNamespaces()
	Dim lret As ZString Ptr

	lret=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_FINDFIRST,Cast(Integer,StrPtr("n")),Cast(Integer,StrPtr(""))))
	Do While lret
		SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,lret))
		SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,StrPtr(CR)))
		lret=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_FINDNEXT,0,0))
	Loop

End Sub

Sub ExportMacros()
	Dim lret As ZString Ptr

	lret=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_FINDFIRST,Cast(Integer,StrPtr("m")),Cast(Integer,StrPtr(""))))
	Do While lret
		SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,lret))
		SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,StrPtr(",")))
		lret=lret+Len(*lret)+1
		SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,lret))
		SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,StrPtr(CR)))
		lret=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_FINDNEXT,0,0))
	Loop

End Sub

Sub ExportConstructors()
	Dim lret As ZString Ptr

	lret=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_FINDFIRST,Cast(Integer,StrPtr("x")),Cast(Integer,StrPtr(""))))
	Do While lret
		SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,lret))
		lret=lret+Len(*lret)+1
		If IsZStrNotEmpty (*lret) Then
			SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,StrPtr(",")))
			SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,lret))
		EndIf
		SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,StrPtr(CR)))
		lret=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_FINDNEXT,0,0))
	Loop

End Sub

Sub ExportDestructors()
	Dim lret As ZString Ptr

	lret=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_FINDFIRST,Cast(Integer,StrPtr("y")),Cast(Integer,StrPtr(""))))
	Do While lret
		SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,lret))
		lret=lret+Len(*lret)+1
		If IsZStrNotEmpty (*lret) Then
			SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,StrPtr(",")))
			SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,lret))
		EndIf
		SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,StrPtr(CR)))
		lret=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_FINDNEXT,0,0))
	Loop

End Sub

Sub ExportProperties()
	Dim lret As ZString Ptr

	lret=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_FINDFIRST,Cast(Integer,StrPtr("z")),Cast(Integer,StrPtr(""))))
	Do While lret
		SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,lret))
		lret=lret+Len(*lret)+1
		If IsZStrNotEmpty (*lret) Then
			SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,StrPtr(",")))
			SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,lret))
		EndIf
		SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,StrPtr(CR)))
		lret=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_FINDNEXT,0,0))
	Loop

End Sub

Sub ExportOperators()
	Dim lret As ZString Ptr

	lret=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_FINDFIRST,Cast(Integer,StrPtr("o")),Cast(Integer,StrPtr(""))))
	Do While lret
		SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,lret))
		lret=lret+Len(*lret)+1
		If IsZStrNotEmpty (*lret) Then
			SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,StrPtr(",")))
			SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,lret))
		EndIf
		SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,StrPtr(CR)))
		lret=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_FINDNEXT,0,0))
	Loop

End Sub

Sub ExportMessages()
	Dim lret As ZString Ptr

	lret=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_FINDFIRST,Cast(Integer,StrPtr("M")),Cast(Integer,StrPtr(""))))
	Do While lret
		SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,lret))
		lret=lret+Len(*lret)+1
		If IsZStrNotEmpty (*lret) Then
			' Parameters
			SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,StrPtr(",")))
			SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,lret))
			lret=lret+Len(*lret)+1
			If IsZStrNotEmpty (*lret) Then
				' Return type
				SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,StrPtr("|")))
				SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,lret))
			EndIf
		Else
			' Skip parameters
			lret=lret+1
			If IsZStrNotEmpty (*lret) Then
				' Return type
				SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,StrPtr("|")))
				SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,lret))
			EndIf
		EndIf
		SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,StrPtr(CR)))
		lret=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_FINDNEXT,0,0))
	Loop

End Sub

Function ExportDlgProc(ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer
    
    Dim PropertyButton As Integer = Any 
	
	Select Case uMsg
		Case WM_INITDIALOG
			TranslateDialog(hWin,IDD_DLGEXPORT)
			PropertyButton = SendMessage (ah.hpr, PRM_GETSELBUTTON, 0, 0)    ' numbered base 1
			buff = "Scope: " + GetInternalString(IS_RAPROPERTY1 + PropertyButton - 1)
			SendDlgItemMessage hWin, IDC_STC_SCOPE, WM_SETTEXT, 0, Cast (LPARAM, @buff)
			'
		Case WM_CLOSE
			EndDialog(hWin, 0)
			'
		Case WM_COMMAND
			Select Case LoWord(wParam)
				Case IDOK
					ShowOutput(TRUE)
					SendMessage(ah.hwnd,IDM_OUTPUT_CLEAR,0,0)
					If IsDlgButtonChecked(hWin,IDC_CHKFUN) Then
						ExportFunctions
					EndIf
					If IsDlgButtonChecked(hWin,IDC_CHKCON) Then
						ExportConstants
					EndIf
					If IsDlgButtonChecked(hWin,IDC_CHKVAR) Then
						ExportData
					EndIf
					If IsDlgButtonChecked(hWin,IDC_CHKUDT) Then
						ExportUDTs
					EndIf
					If IsDlgButtonChecked(hWin,IDC_CHKENU) Then
						ExportEnums
					EndIf
					If IsDlgButtonChecked(hWin,IDC_CHKNME) Then
						ExportNamespaces
					EndIf
					If IsDlgButtonChecked(hWin,IDC_CHKMAC) Then
						ExportMacros
					EndIf
					If IsDlgButtonChecked(hWin,IDC_CHKCNS) Then
						ExportConstructors
					EndIf
					If IsDlgButtonChecked(hWin,IDC_CHKDES) Then
						ExportDestructors
					EndIf
					If IsDlgButtonChecked(hWin,IDC_CHKPRO) Then
						ExportProperties
					EndIf
					If IsDlgButtonChecked(hWin,IDC_CHKOPR) Then
						ExportOperators
					EndIf
					If IsDlgButtonChecked(hWin,IDC_CHKMSG) Then
						ExportMessages
					EndIf
					'
				Case IDCANCEL
					EndDialog(hWin, 0)
					'
			End Select
		Case Else
			Return FALSE
			'
	End Select
	Return TRUE

End Function
