
Sub DumpStrings()
	Dim buff As ZString*256
	Dim nInx As Integer
	Dim szID As ZString*256

	nInx=0
	SendMessage(hEdt,EM_REPLACESEL,FALSE,Cast(LPARAM,StrPtr(!"[Strings]\13\10")))
	while nInx<65536
		If LoadString(hInstance,nInx,@buff,SizeOf(buff)) Then
			ConvertTo(@buff)
			szID=Str(nInx)
			SendMessage(hEdt,EM_REPLACESEL,FALSE,Cast(LPARAM,@szID))
			SendMessage(hEdt,EM_REPLACESEL,FALSE,Cast(LPARAM,StrPtr("=")))
			SendMessage(hEdt,EM_REPLACESEL,FALSE,Cast(LPARAM,@buff))
			SendMessage(hEdt,EM_REPLACESEL,FALSE,Cast(LPARAM,StrPtr(!"\13\10")))
		EndIf
		nInx+=1
	Wend
	SendMessage(hEdt,EM_REPLACESEL,FALSE,Cast(LPARAM,@szDivider))

End Sub

