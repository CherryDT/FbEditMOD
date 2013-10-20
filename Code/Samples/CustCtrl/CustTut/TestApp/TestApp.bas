''
'' Dialog Example, by fsw
''
'' compile with:	fbc -s gui TestApp.rc TestApp.bas
''
''
'option explicit

#include once "windows.bi"

#define IDD_DLG1 1000 
#define IDC_BTN1 1001

declare function DlgProc(byval hWnd as HWND, byval uMsg as UINT, byval wParam as WPARAM, byval lParam as LPARAM) as integer

'''
''' Program start
'''

	''
	'' Create the Dialog
	''

	dim hLib as HMODULE 

	hLib=LoadLibrary("DemoCtrl.dll")
	if hLib then
		DialogBoxParam (GetModuleHandle (NULL), MAKEINTRESOURCE (IDD_DLG1), NULL, @DlgProc, NULL)
		FreeLibrary(hLib)
	else
		MessageBox(NULL,StrPtr("Could not find DemoCtrl.dll"),StrPtr("Custom Control Test"),MB_OK or MB_ICONERROR)
	endif
	''
	'' Program has ended
	''

	ExitProcess(0)
	end

'''
''' Program end
'''
function DlgProc(byval hDlg as HWND, byval uMsg as UINT, byval wParam as WPARAM, byval lParam as LPARAM) as integer
	dim as long id, event, x, y
	dim hBtn as HWND
	dim rect as RECT

	select case uMsg
		case WM_INITDIALOG
			'
		case WM_CLOSE
			EndDialog(hDlg, 0)
			'
		case WM_COMMAND
			id=loword(wParam)
			event=hiword(wParam)
			select case id
				case IDC_BTN1
					EndDialog(hDlg, 0)
					'
			end select
		case WM_SIZE
			GetClientRect(hDlg,@rect)
			hBtn=GetDlgItem(hDlg,IDC_BTN1)
			x=rect.right-100
			y=rect.bottom-35
			MoveWindow(hBtn,x,y,97,31,TRUE)
			'
		case else
			return FALSE
			'
	end select
	return TRUE

end function
