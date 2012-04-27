
Sub SaveToIni(ByVal lpszApp As ZString Ptr,ByVal lpszKey As ZString Ptr,ByVal lpszTypes As ZString Ptr,ByVal lpDta As Any Ptr,ByVal fProject As Boolean)
	Dim value As ZString*4096
	Dim i As Integer
	Dim ofs As Integer
	Dim tmp As ZString*260
	Dim v As Integer
	Dim p As ZString Ptr

	For i=0 To lstrlen(lpszTypes)-1
		v=0
		Select Case lpszTypes[i]-48
			Case 0
				' String
				RtlMoveMemory(@p,lpDta+ofs,4)
				value=value & ","
				lstrcat(@value,p)
				ofs=ofs+4
			Case 1
				' Byte
				RtlMoveMemory(@v,lpDta+ofs,1)
				ofs=ofs+1
				value=value & "," & Str(v)
			Case 2
				' Word
				RtlMoveMemory(@v,lpDta+ofs,2)
				ofs=ofs+2
				value=value & "," & Str(v)
			Case 4
				' DWord
				RtlMoveMemory(@v,lpDta+ofs,4)
				ofs=ofs+4
				value=value & "," & Str(v)
		End Select
	Next i
	value=Mid(value,2)
	If fProject Then
		tmp=ad.ProjectFile
	Else
		tmp=ad.IniFile
	EndIf
	WritePrivateProfileString(lpszApp,lpszKey,@value,@tmp)
End Sub

Function LoadFromIni(ByVal lpszApp As ZString Ptr,ByVal lpszKey As ZString Ptr,ByVal szTypes As String,ByVal lpDta As Any Ptr,ByVal fProject As Boolean) As Boolean
	Dim i As Integer
	Dim ofs As Integer
	Dim tmp As ZString*256
	Dim v As Integer
	Dim p As ZString Ptr
	Dim szDta As ZString*4096

	If fProject Then
		tmp=ad.ProjectFile
	Else
		tmp=ad.IniFile
	EndIf
	If GetPrivateProfileString(lpszApp,lpszKey,@szNULL,@szDta,4096,@tmp) Then
		For i=1 To Len(szTypes)
			v=0
			Select Case Asc(szTypes,i)-48
				Case 0
					' String
					RtlMoveMemory(@p,lpDta+ofs,4)
					If InStr(szDta,",") Then
						tmp=Left(szDta,InStr(szDta,",")-1)
					Else
						tmp=szDta
					EndIf
					lstrcpy(p,@tmp)
					ofs=ofs+4
				Case 1
					' Byte
					If Len(szDta) Then
						v=Val(szDta)
						RtlMoveMemory(lpDta+ofs,@v,1)
					EndIf
					ofs=ofs+1
				Case 2
					' Word
					If Len(szDta) Then
						v=Val(szDta)
						RtlMoveMemory(lpDta+ofs,@v,2)
					EndIf
					ofs=ofs+2
				Case 4
					' DWord
					If Len(szDta) Then
						v=Val(szDta)
						RtlMoveMemory(lpDta+ofs,@v,4)
					EndIf
					ofs=ofs+4
			End Select
			If InStr(szDta,",") Then
				szDta=Mid(szDta,InStr(szDta,",")+1)
			Else
				szDta=""
			EndIf
		Next i
	Else
		Return FALSE
	EndIf
	Return TRUE

End Function
