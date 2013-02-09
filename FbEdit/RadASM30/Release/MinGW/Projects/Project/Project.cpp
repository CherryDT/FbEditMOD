#include "project.h"

int WinMain(HINSTANCE hInst,HINSTANCE hPrevInst,LPSTR lpCmdLine,int iShowCmd)
{
	hInstance = hInst;
	InitCommonControls();
	DialogBoxParam(hInst,MAKEINTRESOURCE(IDD_MAINDLG),0,(DLGPROC)DlgProc,0);
	return 0;
}

int DlgProc(HWND hWnd,UINT uMsg,WPARAM wParam,LPARAM lParam)
{
	int cx,cy;
	RECT rc;
	
	switch (uMsg)
	{
		case WM_INITDIALOG:
			GetClientRect(hWnd,&rc);
			cx = (GetSystemMetrics(SM_CXSCREEN) / 2) - ((rc.right - rc.left) / 2); 
			cy = (GetSystemMetrics(SM_CYSCREEN) / 2) - ((rc.bottom - rc.top) / 2);
			SetWindowPos(hWnd,HWND_TOP,cx,cy,0,0,SWP_NOSIZE);
			break;
		case WM_CLOSE:
			EndDialog(hWnd,0);
			break;
		default:
			return 0;
	}
	return 1;
}