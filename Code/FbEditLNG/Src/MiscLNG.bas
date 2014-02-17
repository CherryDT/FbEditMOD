
Sub GetFilePath(ByVal sFile As String)
	Dim x As Integer

	x=Len(sFile)
	While x
		If Asc(sFile,x)=Asc("\") Then
			sFile=Left(sFile,x-1)
			Exit While
		EndIf
		x=x-1
	Wend

End Sub

Sub ConvertTo(ByVal buff As ZString ptr)
	Dim x As Integer

	x=1
	While x
		x=InStr(*buff,!"\9")
		If x Then
			*buff=Left(*buff,x-1) & "\t" & Mid(*buff,x+1)
		EndIf
	Wend	
	x=1
	While x
		x=InStr(*buff,!"\13")
		If x Then
			*buff=Left(*buff,x-1) & "\r" & Mid(*buff,x+1)
		EndIf
	Wend	
	x=1
	While x
		x=InStr(*buff,!"\10")
		If x Then
			*buff=Left(*buff,x-1) & "\n" & Mid(*buff,x+1)
		EndIf
	Wend	

End Sub

Sub ConvertFrom(ByVal buff As ZString ptr)
	Dim x As Integer

	x=1
	While x
		x=InStr(*buff,"\t")
		If x Then
			*buff=Left(*buff,x-1) & !"\9" & Mid(*buff,x+2)
		EndIf
	Wend	
	x=1
	While x
		x=InStr(*buff,"\r")
		If x Then
			*buff=Left(*buff,x-1) & !"\13" & Mid(*buff,x+2)
		EndIf
	Wend	
	x=1
	While x
		x=InStr(*buff,"\n")
		If x Then
			*buff=Left(*buff,x-1) & !"\10" & Mid(*buff,x+2)
		EndIf
	Wend	

End Sub

Function FindString2(ByVal szApp As String,ByVal szKey As String) As String
	Dim hMem As HGLOBAL
	Dim buff As ZString*512
	Dim As Integer x,y,z
	Dim lp As ZString Ptr

	hMem=GlobalAlloc(GMEM_FIXED Or GMEM_ZEROINIT,64*1024)
	SendMessage(hEdt,WM_GETTEXT,64*1024,Cast(LPARAM,hMem))
	buff=!"\13\10[" & szApp & !"]\13\10"
	lp=hMem
	x=InStr(*lp,buff)
	If x Then
		z=InStr(x+1,*lp,!"\13\10[")
		If z=0 Then
			z=65535
		EndIf
		buff=!"\13\10" & szKey & "="
		x=InStr(x,*lp,buff)
		If x<>0 And x<z Then
			x=x+Len(buff)
			y=InStr(x,*lp,!"\13")
			buff=Mid(*lp,x,y-x)
			ConvertFrom(@buff)
		Else
			buff=""
		EndIf
	Else
		buff=""
	EndIf
	GlobalFree(hMem)
	Return buff

End Function

