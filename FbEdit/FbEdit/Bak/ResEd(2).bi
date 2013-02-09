

Type FBCUSTSTYLE
	lpszStyle	        As ZString Ptr
	nValue		        As Integer
	nMask	    		As Integer
End Type

Type FBRSTYPE
	lpsztype	    	As ZString Ptr
	nid			        As Integer
	lpszext	    	    As ZString Ptr
	lpszedit	    	As ZString Ptr
End Type


#Define IDD_DLGRESED            1300


Declare Function ResEdProc (ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer

Extern ressize As WINSIZE


