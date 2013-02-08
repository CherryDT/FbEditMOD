'#Define UNICODE

#Include "../unicode.bi"
#Include "windows.bi"
#Include "win/commctrl.bi"
#Include "../fbCodeCompleteApi.bi"

/'
Dim hDll As HANDLE
hDll = LoadLibrary(@"..\fbCodeComplete.dll")

Print hDll

Dim install As Sub (hInst As HINSTANCE, fGlobal As Integer)

install = GetProcAddress(hDll, @"InstallRACodeComplete")
Print install





FreeLibrary(hDll)
'/


Function WndProc (hWnd As HWND, uMsg As UINT, wParam As WPARAM, lparam As LPARAM) As LRESULT
	
	Select Case uMsg
		
		Case WM_CREATE
			Asm nop
		
		Case WM_DESTROY
			PostQuitMessage(0)
			Return 0
		
	End Select
	
	Return DefWindowProc(hWnd, uMsg, wParam, lParam)
End Function


#If (RA)
	#Undef InstallfbCodeComplete
	#Undef UninstallFBCodeComplete
	#Undef szCCLBClassName
	#Undef szCCTTClassName
	Declare Sub InstallfbCodeComplete Alias "InstallRACodeComplete" (hInst As HINSTANCE, fGlobal As Integer)
	Declare Sub UninstallFBCodeComplete Alias "UnInstallRACodeComplete" ()
	Const szCCLBClassName = TStr("RACodeComplete")
	Const szCCTTClassName = TStr("RAToolTip")
#EndIf

InstallfbCodeComplete(GetModuleHandle(0), 0)

Dim wc As WNDCLASS
Dim As HINSTANCE hinst = GetModuleHandle(0)

wc.lpfnWndProc = @WndProc
wc.lpszClassName = @TStr("MYWIN")
wc.hInstance = hInst
wc.style = 0
wc.hbrBackground = GetStockObject(GRAY_BRUSH)
Print TStr("RegisterClass: "); RegisterClass(@wc)

Dim As HWND hwnd = CreateWindow(@TStr("MYWIN"), @TStr("MyWin"), WS_OVERLAPPEDWINDOW, 0, 0, 500, 450, 0, 0, hInst, 0)

ShowWindow(hWnd, SW_SHOW)


' ############################### FBCodeComplete ################################


Dim As HWND hwndCC = CreateWindow(@szCCLBClassName, @TStr("CC"), STYLE_USEIMAGELIST Or WS_CHILD, 10, 10, 200, 320, hWnd, 0, hInst, 0)
Print TStr("CC hWnd: "); hWndCC

SendMessage(hWndCC, WM_SETFONT, GetStockObject(DEFAULT_GUI_FONT), TRUE)


SendMessage(hWndCC, CCM_ADDITEM, 9, @TStr("Test9"))
SendMessage(hWndCC, CCM_ADDITEM, 16, @TStr("Test16"))
SendMessage(hWndCC, CCM_ADDITEM, 10, @TStr("Test10"))

SendMessage(hWndCC, CCM_CLEAR, 0, 0)


Dim As TString Ptr a = @TStr("Test0")
SendMessage(hWndCC, CCM_ADDITEM, 0, a)
SendMessage(hWndCC, CCM_ADDITEM, 1, @TStr("Test1"))
SendMessage(hWndCC, CCM_ADDITEM, 2, @TStr("Test2"))
SendMessage(hWndCC, CCM_ADDITEM, 3, @TStr("Test3"))
SendMessage(hWndCC, CCM_ADDITEM, 4, @TStr("Test4"))
SendMessage(hWndCC, CCM_ADDITEM, 5, @TStr("Test5"))
SendMessage(hWndCC, CCM_ADDITEM, 6, @TStr("Test6"))
SendMessage(hWndCC, CCM_ADDITEM, 7, @TStr("Test7"))
SendMessage(hWndCC, CCM_ADDITEM, 8, @TStr("Test8"))
SendMessage(hWndCC, CCM_ADDITEM, 9, @TStr("Test9"))
SendMessage(hWndCC, CCM_ADDITEM, 16, @TStr("Test16"))
SendMessage(hWndCC, CCM_ADDITEM, 10, @TStr("Test10"))
SendMessage(hWndCC, CCM_ADDITEM, 11, @TStr("Test11"))
SendMessage(hWndCC, CCM_ADDITEM, 12, @TStr("Test12"))
SendMessage(hWndCC, CCM_ADDITEM, 13, @TStr("Test13"))
SendMessage(hWndCC, CCM_ADDITEM, 14, @TStr("Test14"))
SendMessage(hWndCC, CCM_ADDITEM, 15, @TStr("Test15"))


SendMessage(hWndCC, CCM_DELITEM, 10, 0)

Print TStr("Item [Test2]: "); *Cast(TString Ptr, SendMessage(hWndCC, CCM_GETITEM, 2, 0))

Print TStr("Cnt [16]: "); SendMessage(hWndCC, CCM_GETCOUNT, 0, 0)

Print TStr("MaxWid: "); SendMessage(hWndCC, CCM_GETMAXWIDTH, 0, 0)


SendMessage(hWndCC, CCM_SETCURSEL, 4, 0)

Print TStr("CurSel [4]: "); SendMessage(hWndCC, CCM_GETCURSEL, 0, 0)


Print TStr("TopIdx: "); SendMessage(hWndCC, CCM_GETTOPINDEX, 0, 0)

SendMessage(hWndCC, CCM_SETTOPINDEX, 3, 0)


Dim rc As RECT
SendMessage(hWndCC, CCM_GETITEMRECT, 15, @rc)
Print TStr("ItemRect: l:"); rc.left; ", t:"; rc.top; ", r:"; rc.right; ", b:"; rc.bottom


SendMessage(hWndCC, CCM_SETVISIBLE, 0, 0)



Print TStr("Find [1]: "); SendMessage(hWndCC, CCM_FINDSTRING, 0, @TStr("test1"))
Print TStr("Find [10]: "); SendMessage(hWndCC, CCM_FINDSTRING, 4, @TStr("test1"))
Print TStr("Find [-1]: "); SendMessage(hWndCC, CCM_FINDSTRING, 4, @TStr("test123"))
Print TStr("Find [-1]: "); SendMessage(hWndCC, CCM_FINDSTRING, 4, @TStr("hallo"))


Dim col As CC_COLOR

SendMessage(hWndCC, CCM_GETCOLOR, 0, @col)
Print TStr("Cols: text: "); Hex(col.text); TStr(", back: "); Hex(col.back)

col.text = 0
col.back = &HDDFFEE
SendMessage(hWndCC, CCM_SETCOLOR, 0, @col)

SendMessage(hWndCC, CCM_GETCOLOR, 0, @col)
Print TStr("Cols: text: "); Hex(col.text); TStr(", back: "); Hex(col.back)



'"bcdefghijk   ,  Test2,Test3 Test3"
Dim ccal As CC_ADDLIST
ccal.lpszList = @TStr("bcdefghijk,Test1234,bcTest")
ccal.lpszFilter = @TStr("bc")
ccal.nType = 0
SendMessage(hWndCC, CCM_ADDLIST, 0, @ccal)


SendMessage(hWndCC, CCM_ADDITEM, 15, @TStr("纵有千间房，睡觉只需一张床。"))
SendMessage(hWndCC, CCM_ADDITEM, 15, @TStr("호랑이도 제 말하면 온다."))

ShowWindow(hWndCC, SW_SHOW)


' ############################### FBToolTip ################################


Dim As HWND hwndTT = CreateWindow(@szCCTTClassName, @TStr("TT"), STYLE_USEIMAGELIST Or WS_CHILD, 10, 360, 200, 40, hWnd, 0, hInst, 0)
Print TStr("TT hWnd: "); hWndCC

SendMessage(hwndTT, WM_SETFONT, GetStockObject(DEFAULT_GUI_FONT), TRUE)

Dim tti As TTITEM
/'
	lpszApi As TString Ptr						' Pointer to api string
	lpszParam As TString Ptr					' Pointer to comma separated parameters string
	nitem As Integer									' Item to hilite
	lpszRetType As TString Ptr				' Pointer to return type string
	lpszDesc As TString Ptr						' Pointer to item description
	novr As Integer										' Totals of functions
	nsel As Integer										' Actual function
	nwidth As Integer									' Width of tooltip
'/
tti.lpszApi = @TStr("ƁƧąve")
tti.lpszParam = @TStr("ByRef filename:String,去る者日々に疎し。:Any Ptr,size:Integer=0")
tti.nitem = 1
tti.lpszRetType = @TStr("IntƐƓƐr")
tti.lpszDesc = @TStr("My long description is really short. 頭隠して尻隠さず。")
tti.novr = 2
tti.nsel = 1
tti.nwidth = 200
SendMessage(hwndTT, TTM_SETITEM, 0, @tti)






ShowWindow(hwndTT, SW_SHOW)


' ###############################  ################################


Dim wMsg As MSG
Do While GetMessage(@wMsg, null, 0, 0) <> 0
	TranslateMessage(@wMsg)
	DispatchMessage(@wMsg)
Loop


UnregisterClass(@TStr("MYWIN"), hInst)


ImageList_Create(0, 0, 0, 0, 0)



'CreateWindow(@



UninstallfbCodeComplete()
