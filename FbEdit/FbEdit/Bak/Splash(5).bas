

#Include Once "windowsUR.bi"

#Include Once "Inc\FbEdit.bi"
#Include Once "Inc\Addins.bi"


#Define IDD_SPLASH          1500
#Define IDC_SPLASH_IMG      1501

 
Sub SplashScreen ()	
	
	Dim hSplashWin   As HWND = Any
	Dim SplashRECT   As RECT = Any 
	Dim AdoptRECT    As RECT = Any 

	hSplashWin = CreateDialog (hInstance, MAKEINTRESOURCE (IDD_SPLASH), NULL, NULL)    ' style: NOT visible

	GetWindowRect ah.hshp,    @AdoptRECT              ' adoptive parent screen coords
	GetClientRect hSplashWin, @SplashRECT             ' only size
	
	With SplashRECT
		.Left = AdoptRECT.Left + (AdoptRECT.Right  - AdoptRECT.Left - .Right ) \ 2
		.Top  = AdoptRECT.Top  + (AdoptRECT.Bottom - AdoptRECT.Top  - .Bottom) \ 2
		
		SetWindowPos hSplashWin, HWND_TOPMOST, .Left, .Top, 0, 0, SWP_NOSIZE Or SWP_SHOWWINDOW Or SWP_NOACTIVATE
		UpdateWindow hSplashWin
	End With 
	
	Sleep 1000
    AnimateWindow hSplashWin, 1000, AW_BLEND Or AW_HIDE
	DestroyWindow hSplashWin

End Sub
