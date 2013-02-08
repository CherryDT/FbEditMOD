
Type CC_MEM
	txt As TString Ptr
	ninx As Integer
End Type


Type fbCC
	style As Integer
	backcolor As Integer
	textcolor As Integer
	hfont As HFONT
	fredraw As Integer
	itemheight As Integer
	cursel As Integer
	count As Integer
	topindex As Integer
	hmem As HGLOBAL
	lpmem As CC_MEM Ptr
	cbsize As Integer
	himl As HIMAGELIST
End Type

Type fbTT
	backcolor As Integer
	textcolor As Integer
	apicolor As Integer
	hilitecolor As Integer
	hfont As HFONT
	tti As TTITEM
	nleft As Integer
	nlen As Integer
End Type



#Define DLGC_CODE		DLGC_WANTCHARS Or DLGC_WANTARROWS Or DLGC_WANTALLKEYS


Const szByVal = TStr("byval ")
Const szByRef = TStr("byref ")
Const szFmt = TStr("%d of %d")


Dim Shared hInstance As HINSTANCE
Dim Shared findBuff As TString*64
Dim Shared findTime As UInteger
Dim Shared ItemBuff As TString*256
