#Include "windows.bi"
#Include "win/commctrl.bi"
#Include "crt/string.bi"

#Include "fbCodeCompleteApi.bi"
#Include "fbCodeComplete.bi"

#Define IDB_TYPES		110

Declare Function CodeCompleteProc (hWnd As HWND, uMsg As UINT, wParam As WPARAM, lparam As LPARAM) As LRESULT
Declare Function ToolTipProc (hWnd As HWND, uMsg As UINT, wParam As WPARAM, lparam As LPARAM) As LRESULT


#Define GET_Y_LPARAM(lp) (Cast(Integer, HiWord(lp) And &HFFFF)) 

#Define SZPTR		SizeOf(Any Ptr)


Sub InstallfbCodeComplete (hInst As HINSTANCE, fGlobal As Integer) Export
	Dim wc As WNDCLASSEX
	hInstance = hInst
	
	With wc
		.cbSize = SizeOf(WNDCLASSEX)
		.style = CS_HREDRAW Or CS_VREDRAW Or CS_PARENTDC Or CS_DBLCLKS
		.lpfnWndProc = @CodeCompleteProc
		.cbWndExtra = 4
		.hInstance = hInst
		.lpszClassName = StrPtr(szCCLBClassName)
		.hCursor = LoadCursor(0, IDC_ARROW)
	End With
	If (fGlobal) Then wc.style or= CS_GLOBALCLASS
	RegisterClassEx(@wc)
	
	' Create a windowclass for the tooltip control
	With wc
		.style = CS_HREDRAW Or CS_VREDRAW Or CS_PARENTDC
		.lpfnWndProc = @ToolTipProc
		.lpszClassName = StrPtr(szCCTTClassName)
	End With
	If (fGlobal) Then wc.style or= CS_GLOBALCLASS
	RegisterClassEx(@wc)

	'OutputDebugString(@"Installed fbCodeComplete")

End Sub

Sub UninstallfbCodeComplete () Export
	
End Sub


Function CompareStr(a As Ubyte ptr, b As UByte ptr) As Integer
	Dim q As Integer = 0
	Do
		If a[q] = 0 OrElse b[q] = 0 Then Exit Do
		If a[q] <> b[q] Then Return 0
		q += 1
	Loop
	Return -1
End Function


Function CodeCompleteProc (hWnd As HWND, uMsg As UINT, wParam As WPARAM, lparam As LPARAM) As LRESULT
	Dim ps As PAINTSTRUCT
	Dim pt As Point
	Dim rc As RECT
	Dim si As SCROLLINFO
	Dim ninx As Integer
	
	Dim fbcc As FBCC Ptr
	
	Select Case uMsg
		
		Case CCM_ADDITEM
			fbcc = GetWindowLong(hWnd, 0)
			If fbcc->count*(2*SZPTR) >= fbcc->cbsize Then
				GlobalUnlock(fbcc->hmem)
				fbcc->cbsize += 1024*32
				fbcc->hmem = GlobalReAlloc(fbcc->hmem, fbcc->cbsize, GMEM_MOVEABLE)
				fbcc->lpmem = GlobalLock(fbcc->hmem)
			EndIf
			*Cast(Integer Ptr, fbcc->lpmem+fbcc->count*(2*SZPTR)) = lParam
			*Cast(Integer Ptr, fbcc->lpmem+fbcc->count*(2*SZPTR)+SZPTR) = wParam
			fbcc->count+=1
			If fbcc->fRedraw Then
				InvalidateRect(hWnd, NULL, TRUE)
			EndIf
			Return 0
			
		Case CCM_ADDLIST
			fbcc = GetWindowLong(hWnd, 0)
			Dim cc As CC_ADDLIST Ptr = Cast(CC_ADDLIST Ptr, lParam)
			Dim s As UByte Ptr = cc->lpszList
			Dim sa As ubyte Ptr
			
			Do
				sa = s
				While s[0] <> Asc(",") AndAlso s[0] <> 0
					s+=1
				Wend
				If s[0] = Asc(",") Then
					s[0] = 0
					s += 1
					If CompareStr(sa, cc->lpszFilter) Then
						SendMessage(hWnd, CCM_ADDITEM, cc->nType, sa)
					EndIf
				Else
					Exit Do
				EndIf
			Loop
			If sa[0] <> 0 Then
				If CompareStr(sa, cc->lpszFilter) Then
					SendMessage(hWnd, CCM_ADDITEM, cc->nType, sa)
				EndIf
			EndIf
			If fbcc->fRedraw Then
				InvalidateRect(hWnd, NULL, TRUE)
			EndIf
			Return 0
			
		Case CCM_DELITEM
			fbcc = GetWindowLong(hWnd, 0)
			If wParam < fbcc->count Then
				'For q As Integer = wParam To fbcc->count-1
				'	*Cast(LongInt Ptr, fbcc->lpmem + q*(2*SZPTR)) = *Cast(LongInt Ptr, fbcc->lpmem + (q+1)*(2*SZPTR))
				'Next
				memmove(fbcc->lpmem + wParam*(2*SZPTR), fbcc->lpmem + (wParam+1)*(2*SZPTR), (fbcc->count-wParam)*(2*SZPTR))
				fbcc->count -= 1
				If fbcc->fRedraw Then
					InvalidateRect(hWnd, NULL, TRUE)
				EndIf
			EndIf
			Return 0
			
		Case CCM_GETITEM
			fbcc = GetWindowLong(hWnd, 0)
			If wParam < fbcc->count Then
				Return fbcc->lpmem + wParam*(2*SZPTR)
			EndIf
			Return 0
			
		Case CCM_GETCOUNT
			fbcc = GetWindowLong(hWnd, 0)
			Return fbcc->count
			
		Case CCM_GETMAXWIDTH
			fbcc = GetWindowLong(hWnd, 0)
			ps.hdc = GetDC(hWnd)
			Dim oldObj As HGDIOBJ = SelectObject(ps.hdc, fbcc->hFont)
			
			GetClientRect(hWnd, @rc)
			If rc.right > 0 AndAlso rc.bottom > 0 Then
				si.cbSize = SizeOf(si)
				si.fMask = SIF_ALL
				si.nPage = rc.bottom \ fbcc->itemheight
				si.nMin = 0
				si.nMax = IIf(fbcc->count > 0, fbcc->count - 1, 0)
				si.nPos = fbcc->topIndex
				SetScrollInfo(hWnd, SB_VERT, @si, TRUE)
			EndIf
			
			si.cbSize = SizeOf(si)
			si.fMask = SIF_PAGE Or SIF_RANGE
			GetScrollInfo(hWnd, SB_VERT, @si)
			ninx = 0
			If si.nMax >= si.nPage Then
				ninx = GetSystemMetrics(SM_CXVSCROLL)
			EndIf
			rc.left = 0
			rc.top = 0
			Dim maxW As UInteger = 0
			For q As Integer = 0 To fbcc->count -1
				DrawText(ps.hdc, *Cast(ZString Ptr Ptr, fbcc->lpmem + q*(2*SZPTR)), -1, @rc, DT_SINGLELINE Or DT_CALCRECT)
				rc.right += ninx
				If fbcc->style And STYLE_USEIMAGELIST Then rc.right += 19
				If rc.right > maxW Then maxW = rc.right
			Next
			SelectObject(ps.hdc, oldObj)
			ReleaseDC(hWnd, ps.hdc)
			Return maxW
			
		Case CCM_CLEAR
			fbcc = GetWindowLong(hWnd, 0)
			fbcc->count = 0
			fbcc->topIndex = 0
			fbcc->curSel = -1
			If fbcc->fRedraw Then
				InvalidateRect(hWnd, NULL, TRUE)
			EndIf
			Return 0
			
		Case CCM_SETCURSEL
			fbcc = GetWindowLong(hWnd, 0)
			If fbcc->fRedraw Then
				SendMessage(hWnd, CCM_GETITEMRECT, fbcc->cursel, @(ps.rcPaint))
				InvalidateRect(hWnd, @(ps.rcPaint), TRUE)
			EndIf
			If wParam < fbcc->count Then
				fbcc->cursel = wParam
				If fbcc->fRedraw Then
					SendMessage(hWnd, CCM_GETITEMRECT, fbcc->cursel, @(ps.rcPaint))
					InvalidateRect(hWnd, @(ps.rcPaint), TRUE)
				EndIf
			Else
				fbcc->cursel = -1
			EndIf
			Return 0
			
		Case CCM_GETCURSEL
			fbcc = GetWindowLong(hWnd, 0)
			Return fbcc->cursel
			
		Case CCM_GETTOPINDEX
			fbcc = GetWindowLong(hWnd, 0)
			Return fbcc->topIndex
			
		Case CCM_SETTOPINDEX
			fbcc = GetWindowLong(hWnd, 0)
			fbcc->topIndex = min(fbcc->count-1, max(0, wParam))
			If fbcc->fRedraw Then
				InvalidateRect(hWnd, NULL, TRUE)
			EndIf
			Return 0
			
		Case CCM_GETITEMRECT
			fbcc = GetWindowLong(hWnd, 0)
			GetClientRect(hWnd, @rc)
			Dim rcp As RECT Ptr = Cast(RECT Ptr, lParam)
			rcp->Left = 0
			rcp->Right = rc.right
			rcp->top = (wParam - fbcc->topIndex) * fbcc->itemHeight
			rcp->bottom = rcp->top + fbcc->itemHeight
			Return 0
			
		Case CCM_SETVISIBLE
			fbcc = GetWindowLong(hWnd, 0)
			SendMessage(hWnd, CCM_GETITEMRECT, fbcc->cursel, @(ps.rcPaint))
			GetClientRect(hWnd, @rc)
			If ps.rcPaint.top < 0 Then
				If fbcc->cursel < fbcc->count Then
					fbcc->topIndex = fbcc->cursel
				EndIf
			ElseIf ps.rcPaint.bottom > rc.bottom Then
				fbcc->topIndex = max(0, fbcc->cursel +1 - (rc.bottom \ fbcc->itemHeight))
			EndIf
			If fbcc->fRedraw Then
				InvalidateRect(hWnd, NULL, TRUE)
			EndIf
			Return 0
			
		Case CCM_FINDSTRING
			For q As Integer = wParam-1 To fbcc->count-1
				If CompareStr(fbcc->lpmem+q*(2*SZPTR), lParam) Then Return q 
			Next
			Return -1
			
		Case CCM_SORT
			'TODO !!
			
		Case CCM_GETCOLOR
			fbcc = GetWindowLong(hWnd, 0)
			Dim cc As CC_COLOR Ptr = Cast(CC_COLOR Ptr, lParam)
			cc->back = fbcc->backColor
			cc->text = fbcc->textColor
			Return 0
		
		Case CCM_SETCOLOR
			fbcc = GetWindowLong(hWnd, 0)
			Dim cc As CC_COLOR Ptr = Cast(CC_COLOR Ptr, lParam)
			fbcc->backColor = cc->back
			fbcc->textColor = cc->text
			If fbcc->fRedraw Then
				InvalidateRect(hWnd, NULL, TRUE)
			EndIf
			Return 0
		
		Case WM_PAINT
			fbcc = GetWindowLong(hWnd, 0)
			
			GetClientRect(hWnd, @rc)
			If rc.right > 0 AndAlso rc.bottom > 0 Then
				si.cbSize = SizeOf(si)
				si.fMask = SIF_ALL
				si.nPage = rc.bottom \ fbcc->itemheight
				si.nMin = 0
				si.nMax = IIf(fbcc->count > 0, fbcc->count - 1, 0)
				si.nPos = fbcc->topIndex
				SetScrollInfo(hWnd, SB_VERT, @si, TRUE)
			EndIf
			
			BeginPaint(hWnd, @ps)
			Dim col As Integer = fbcc->backcolor
			If col And &H80000000 Then col = GetSysColor(col And &H7FFFFFFF)
			Dim hBr As HBRUSH = CreateSolidBrush(col)
			FillRect(ps.hdc, @ps.rcPaint, hBr)
			DeleteObject(hBr)
			
			SetBkMode(ps.hdc, TRANSPARENT)
			Dim oldObj As HGDIOBJ = SelectObject(ps.hdc, fbcc->hFont)
			pt.y = 0
			
			For q As Integer = fbcc->topIndex To fbcc->count-1
				If pt.y > ps.rcPaint.bottom Then Exit For
				If pt.y+fbcc->itemheight > ps.rcPaint.top Then
					If q = fbcc->cursel Then
						rc.top = pt.y 
						rc.bottom = rc.top + fbcc->itemHeight
						hBr = CreateSolidBrush(GetSysColor(COLOR_HIGHLIGHT))
						FillRect(ps.hdc, @rc, hBr)
						DeleteObject(hBr)
						If hWnd = GetFocus() Then
							SetTextColor(ps.hdc, 0)
							DrawFocusRect(ps.hdc, @rc)
						EndIf
						SetTextColor(ps.hdc, GetSysColor(COLOR_HIGHLIGHTTEXT))
					Else
						col = fbcc->textcolor
						If col And &H80000000 Then col = GetSysColor(col And &H7FFFFFFF)
						SetTextColor(ps.hdc, col)
					EndIf
					
					Dim txt As ZString Ptr =  *Cast(ZString Ptr Ptr, fbcc->lpMem + q * (2*SZPTR))
					ninx = *Cast(Integer Ptr, fbcc->lpMem + q * (2*SZPTR) + SZPTR)
					If fbcc->style And STYLE_USEIMAGELIST Then
						TextOut(ps.hdc, 19, pt.y, txt, Len(txt))
						ImageList_Draw(fbcc->himl, ninx, ps.hdc, 1, pt.y, ILD_NORMAL)
					Else
						TextOut(ps.hdc, 1, pt.y, txt, Len(txt))
					EndIf
				EndIf
				pt.y += fbcc->itemheight
			Next
			SelectObject(ps.hdc, oldObj)
			EndPaint(hWnd, @ps)
			Return 0
		
		Case WM_CREATE
			fbcc = HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, SizeOf(FBCC))
			SetWindowLong(hWnd, 0, fbcc)
			fbcc->cbsize = 1024*32
			fbcc->hmem = GlobalAlloc(GMEM_MOVEABLE, fbcc->cbsize)
			fbcc->lpmem = GlobalLock(fbcc->hmem)
			fbcc->cursel = -1
			fbcc->backcolor = &h80000000 Or COLOR_WINDOW
			fbcc->textcolor = &h80000000 Or COLOR_WINDOWTEXT
			fbcc->style = GetWindowLong(hWnd, GWL_STYLE)
			fbcc->fRedraw = TRUE
			fbcc->itemheight = 16
			
			'Create ImageList for property types
			fbcc->himl = ImageList_Create(16, 16, ILC_MASK Or ILC_COLOR8, 16, 0)
			Dim hBmpTmp As HBITMAP
			hInstance = 0
			hBmpTmp = LoadBitmap(hInstance, MAKEINTRESOURCE(IDB_TYPES))
			ImageList_AddMasked(fbcc->himl, hBmpTmp, &h0FF00FF)
			DeleteObject(hBmpTmp)
			Return 0
			
		Case WM_DESTROY
			fbcc = GetWindowLong(hWnd, 0)
			GlobalUnlock(fbcc->hmem)
			GlobalFree(fbcc->hmem)
			ImageList_Destroy(fbcc->himl)
			HeapFree(GetProcessHeap(), 0, fbcc)
			Return 0
			
		Case WM_SETFONT
			fbcc = GetWindowLong(hWnd, 0)
			fbcc->hfont = wParam
			ps.hdc = GetDC(hWnd)
			Dim hPrevObj As HGDIOBJ = SelectObject(ps.hdc, fbcc->hfont)
			GetTextExtentPoint32(ps.hdc, @"a", 1, @pt)
			SelectObject(ps.hdc, hPrevObj)
			ReleaseDC(hWnd, ps.hdc)
			pt.y += 2
			fbcc->itemheight = IIf(pt.y < 17, 17, pt.y)
			If lParam Then
				InvalidateRect(hWnd, NULL, TRUE)
			EndIf
			Return 0
			
		Case WM_LBUTTONDOWN
			SetFocus(hWnd)
			SetCapture(hWnd)
			PostMessage(hWnd, WM_MOUSEMOVE, wParam, lParam)
			Return 0
		
		'Scroll using mouse dragging
		Case WM_MOUSEMOVE
			If GetCapture() = hWnd Then
				fbcc = GetWindowLong(hWnd, 0)
				GetClientRect(hWnd, @rc)
				Dim cntVisibleItems As Integer = (rc.bottom \ fbcc->itemHeight)
				rc.bottom = cntVisibleItems * fbcc->itemHeight
				If GET_Y_LPARAM(lParam) < 0 Then
					If fbcc->topIndex > 0 Then
						fbcc->topIndex -= 1
						fbcc->curSel = fbcc->topIndex
						InvalidateRect(hWnd, NULL, TRUE)
					EndIf
				ElseIf GET_Y_LPARAM(lParam) > rc.bottom then
					If fbcc->topIndex + cntVisibleItems < fbcc->count Then
						fbcc->curSel = fbcc->topIndex + cntVisibleItems
						fbcc->topIndex += 1
						InvalidateRect(hWnd, NULL, TRUE)
					EndIf
				Else
					Dim clickedItem As Integer = fbcc->topIndex + GET_Y_LPARAM(lParam) \ fbcc->itemHeight
					If clickedItem < fbcc->count AndAlso clickedItem <> fbcc->cursel Then
						SendMessage(hWnd, CCM_GETITEMRECT, fbcc->cursel, @rc)
						fbcc->cursel = clickedItem
						InvalidateRect(hWnd, @rc, TRUE)
						SendMessage(hWnd, CCM_GETITEMRECT, clickedItem, @rc)
						InvalidateRect(hWnd, @rc, TRUE)
					EndIf
				EndIf
			EndIf
			Return 0
			
		Case WM_SETFOCUS, WM_KILLFOCUS
			fbcc = GetWindowLong(hWnd, 0)
			If fbcc->cursel >= 0 Then
				SendMessage(hWnd, CCM_GETITEMRECT, fbcc->cursel, @rc)
				InvalidateRect(hWnd, @rc, TRUE)
			EndIf
			Return 0
			
		Case WM_LBUTTONUP
			If GetCapture() = hWnd Then
				ReleaseCapture()
			EndIf
			Return 0
			
		Case WM_KEYDOWN
			fbcc = GetWindowLong(hWnd, 0)
			If fbcc->count > 0 Then
				GetClientRect(hWnd, @rc)
				Dim keyCode As Integer = wParam
				Dim scanCode As Integer = (lParam Shr 16) And &HFF		'scancode (0-7)
				Dim isExtended As Integer = (lParam Shr 24) And &H1
				
				'Down
				If keyCode = VK_DOWN AndAlso scanCode = &H50 Then
					If fbcc->cursel + 1 < fbcc->count Then
						fbcc->cursel += 1
						SendMessage(hWnd, CCM_SETVISIBLE, 0, 0)
					EndIf
				'Up
				ElseIf keyCode = VK_UP AndAlso scanCode = &H48 Then
					If fbcc->cursel > 0 AndAlso fbcc->cursel < fbcc->count Then
						fbcc->cursel -= 1
						SendMessage(hWnd, CCM_SETVISIBLE, 0, 0)
					EndIf
				'PgUp
				ElseIf keyCode = VK_PRIOR AndAlso scanCode = &H49 Then
					fbcc->cursel -= rc.bottom \ fbcc->itemheight
					If fbcc->cursel < 0 Then fbcc->cursel = 0
					SendMessage(hWnd, CCM_SETVISIBLE, 0, 0)
				'PgDown
				ElseIf keyCode = VK_NEXT AndAlso keyCode = &H51 Then
					fbcc->cursel += rc.bottom \ fbcc->itemheight
					If fbcc->cursel >= fbcc->count Then fbcc->cursel = fbcc->count - 1
					SendMessage(hWnd, CCM_SETVISIBLE, 0, 0)
				'Home
				ElseIf keyCode = VK_HOME AndAlso keyCode = &H47 then
					fbcc->cursel = 0
					SendMessage(hWnd, CCM_SETVISIBLE, 0, 0)
				'End
				ElseIf keyCode = VK_END AndAlso keyCode = &H4F Then
					fbcc->cursel = fbcc->count - 1
					SendMessage(hWnd, CCM_SETVISIBLE, 0, 0)
				EndIf
				
			EndIf
			Return 0
			
		Case WM_CHAR
			fbcc = GetWindowLong(hWnd, 0)
			Dim curTime As UInteger = GetTickCount()
			Dim chPos As Integer = 0
			
			If curTime - findTime <= 1000 Then
				chPos = Len(findBuff)
			EndIf
			
			findBuff[chPos] = wParam And &HFF
			Dim dispPos As Integer = SendMessage(hWnd, CCM_FINDSTRING, -1, @findBuff)
			If dispPos <> -1 Then
				SendMessage(hWnd, CCM_SETCURSEL, dispPos, 0)
				SendMessage(hWnd, CCM_SETVISIBLE, 0, 0)
			Else
'TODO !!
				If Len(findBuff) = 2 AndAlso findBuff[0] = findBuff[1] Then
					findBuff[1] = 0
					dispPos = SendMessage(hWnd, CCM_FINDSTRING, fbcc->cursel, @findBuff)
					If dispPos <> -1 Then
						SendMessage(hWnd, CCM_SETCURSEL, dispPos, 0)
						SendMessage(hWnd, CCM_SETVISIBLE, 0, 0)
					EndIf
				EndIf
			EndIf
			Return 0
		
		Case WM_VSCROLL
			fbcc = GetWindowLong(hWnd, 0)
			si.cbSize = SizeOf(si)
			si.fMask = SIF_ALL
			GetScrollInfo(hWnd, SB_VERT, @si)
			
			Dim scrPos As Integer = fbcc->topindex
			Select Case wParam And &HFF
				Case SB_THUMBTRACK, SB_THUMBPOSITION
					scrPos = si.nTrackPos
				Case SB_LINEDOWN
					scrPos += 1
					If scrPos > si.nMax - si.nPage + 1 Then scrPos = si.nMax - si.nPage + 1
				Case SB_LINEUP
					If scrPos > 0 Then scrPos -= 1
				Case SB_PAGEDOWN
					scrPos += si.nPage
					If scrPos > si.nMax - si.nPage + 1 Then scrPos = si.nMax - si.nPage + 1
				Case SB_PAGEUP
					If scrPos >= si.nPage Then
						scrPos -= si.nPage
					Else
						scrPos = 0
					End If
				Case SB_BOTTOM
					scrPos = si.nMax
				Case SB_TOP
					scrPos = 0
			End Select
			
			If scrPos <> si.nPos Then
				si.nPos = scrPos
				fbcc->topindex = scrPos
				InvalidateRect(hWnd, NULL, TRUE)
			EndIf
			
			Return 0
			
		Case WM_GETDLGCODE
			Return DLGC_CODE
			
		Case WM_SETREDRAW
			fbcc = GetWindowLong(hWnd, 0)
			wParam = DefWindowProc(hWnd, uMsg, wParam, lParam)
			fbcc->fRedraw = wParam
			If wParam > 0 Then
				
				GetClientRect(hWnd, @rc)
				If rc.right > 0 AndAlso rc.bottom > 0 Then
					si.cbSize = SizeOf(si)
					si.fMask = SIF_ALL
					si.nPage = rc.bottom \ fbcc->itemheight
					si.nMin = 0
					si.nMax = IIf(fbcc->count > 0, fbcc->count - 1, 0)
					si.nPos = fbcc->topIndex
					SetScrollInfo(hWnd, SB_VERT, @si, TRUE)
				EndIf
				
				InvalidateRect(hWnd, NULL, TRUE)
			EndIf
			Return 0
			
	End Select
	
	Return DefWindowProc(hWnd, uMsg, wParam, lParam)
	
End Function


Function SkipScope(lpszBuff As ubyte Ptr) As ZString Ptr 'Integer
	If lpszBuff[0] = Asc("(") OrElse lpszBuff[0] = Asc("[") Then
		Dim cntSub As Integer
		Dim sPos As Integer
		While lpszBuff[sPos]
			If lpszBuff[sPos] = Asc("(") OrElse lpszBuff[sPos] = Asc("[") Then
				cntSub+=1
			ElseIf lpszBuff[sPos] = Asc(")") OrElse lpszBuff[sPos] = Asc("]") Then
				cntSub-=1
				If cntSub = 0 Then Exit While
			EndIf
			sPos += 1
		Wend
		If lpszBuff[sPos] = Asc(")") OrElse lpszBuff[sPos] = Asc("]") Then sPos += 1
		Return Cast(ZString Ptr, lpszBuff + sPos)
		'Return sPos
	EndIf
	Return 0
End Function




Function ToolTipProc (hWnd As HWND, uMsg As UINT, wParam As WPARAM, lparam As LPARAM) As LRESULT
	Dim ps As PAINTSTRUCT
	Dim rc As RECT
	dim rc1 As RECT
	Dim rgt As TCHAR
	Dim style As DWORD
	Dim fbtt As fbTT ptr
	
	Select Case uMsg
		
		Case WM_PAINT
			BeginPaint(hWnd, @ps)
			fbtt = GetWindowLong(hWnd, 0)
			style = GetWindowLong(hWnd, GWL_STYLE)
			Dim As HGDIOBJ oldObj = SelectObject(ps.hdc, fbtt->hfont)
			Dim As HBRUSH hBr = CreateSolidBrush(fbtt->backcolor)
			FillRect(ps.hdc, @(ps.rcPaint), hBr)
			DeleteObject(hBr)
			SetBkMode(ps.hdc, TRANSPARENT)
			
			rc.left = 1
			rc.top = 0
			rc.right = 0
			rc.bottom = 0
			
			If fbtt->tti.lpszApi Then
				If fbtt->tti.novr > 1 Then
					wsprintf(StrPtr(findbuff), StrPtr(szFmt), fbtt->tti.nsel+1, fbtt->tti.novr)
					DrawText(ps.hdc, StrPtr(findBuff), -1, @rc, DT_CALCRECT Or DT_SINGLELINE Or DT_NOPREFIX Or DT_LEFT)
					' more space for extreme overload function
					' 34=24+10(extra space)
					rc.right += 34
					SetTextColor(ps.hdc, fbtt->textcolor)
					DrawText(ps.hdc, StrPtr(findBuff), -1, @rc, DT_SINGLELINE Or DT_NOPREFIX Or DT_CENTER)
					Dim rcBak As Integer = rc.right
					rc.right = rc.left + 9
					DrawFrameControl(ps.hdc, @rc, DFC_SCROLL, DFCS_SCROLLUP Or DFCS_FLAT)
					rc.right = rcBak
					rcBak = rc.left
					rc.left = rc.right - 9
					DrawFrameControl(ps.hdc, @rc, DFC_SCROLL, DFCS_SCROLLDOWN Or DFCS_FLAT)
					rc.left = rcBak
					' 6=1+5(space between api and graph)
					rc.left = rc.right + 6
				EndIf
				
				SetTextColor(ps.hdc, fbtt->apicolor)
				DrawText(ps.hdc, fbtt->tti.lpszApi, -1, @rc, DT_CALCRECT Or DT_SINGLELINE Or DT_NOPREFIX Or DT_LEFT)
				DrawText(ps.hdc, fbtt->tti.lpszApi, -1, @rc, DT_SINGLELINE Or DT_NOPREFIX Or DT_LEFT)
				rc.left = rc.right
				SetTextColor(ps.hdc, fbtt->textcolor)
				If style And STYLE_USEPARANTESES Then
					rgt = Asc("(")
				Else
					rgt = Asc(",")
				EndIf
				DrawText(ps.hdc, @rgt, 1, @rc, DT_CALCRECT Or DT_SINGLELINE Or DT_NOPREFIX Or DT_LEFT)
				DrawText(ps.hdc, @rgt, 1, @rc, DT_SINGLELINE Or DT_NOPREFIX Or DT_LEFT)
				rc.left = rc.right
				rgt = rc.right
				If fbtt->tti.lpszParam Then
					SetTextColor(ps.hdc, fbtt->textcolor)
					DrawText(ps.hdc, fbtt->tti.lpszParam, -1, @rc, DT_CALCRECT Or DT_SINGLELINE Or DT_NOPREFIX Or DT_LEFT)
					DrawText(ps.hdc, fbtt->tti.lpszParam, -1, @rc, DT_SINGLELINE Or DT_NOPREFIX Or DT_LEFT)
					If fbtt->nlen Then
						SetTextColor(ps.hdc, fbtt->hilitecolor)
						If fbtt->nleft Then
							DrawText(ps.hdc, fbtt->tti.lpszParam, fbtt->nleft, @rc, DT_CALCRECT Or DT_SINGLELINE Or DT_NOPREFIX Or DT_LEFT)
						Else
							rc.right = rc.left
						EndIf
						TextOut(ps.hdc, rc.right, 0, fbtt->tti.lpszParam + fbtt->nleft, fbtt->nlen)
					EndIf
				EndIf
				rc.left = rgt
				If style And STYLE_USEPARANTESES Then
					SetTextColor(ps.hdc, fbtt->textcolor)
					DrawText(ps.hdc, fbtt->tti.lpszParam, -1, @rc, DT_CALCRECT Or DT_SINGLELINE Or DT_NOPREFIX Or DT_LEFT)
					rc.left = rc.right
					rgt = Asc(")")
					DrawText(ps.hdc, @rgt, 1, @rc, DT_CALCRECT Or DT_SINGLELINE Or DT_NOPREFIX Or DT_LEFT)
					DrawText(ps.hdc, @rgt, 1, @rc, DT_SINGLELINE Or DT_NOPREFIX Or DT_LEFT)
					rc.left = rc.right					
				EndIf				
				If fbtt->tti.lpszRetType Then
					If fbtt->tti.lpszRetType[0] Then
						rc.left += 5
						SetTextColor(ps.hdc, fbtt->apicolor)
						DrawText(ps.hdc, fbtt->tti.lpszRetType, -1, @rc, DT_CALCRECT Or DT_SINGLELINE Or DT_NOPREFIX Or DT_LEFT)
						DrawText(ps.hdc, fbtt->tti.lpszRetType, -1, @rc, DT_SINGLELINE Or DT_NOPREFIX Or DT_LEFT)
					EndIf
				EndIf
				If fbtt->tti.lpszDesc Then
					rc.left = 1
					rc.top = rc.bottom
					rc.bottom = 99
					rc.right = 512
					SetTextColor(ps.hdc, fbtt->textcolor)
					DrawText(ps.hdc, fbtt->tti.lpszDesc, -1, @rc, DT_SINGLELINE Or DT_NOPREFIX Or DT_LEFT)
				EndIf
			EndIf
			SelectObject(ps.hdc, oldObj)
			EndPaint(hWnd, @ps)
			Return 0			
			
		Case WM_CREATE
			fbtt = HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, SizeOf(fbTT))
			SetWindowLong(hWnd, 0, fbtt)
			fbtt->backcolor = &HC0FFFF
			fbtt->textcolor = 0
			fbtt->apicolor = &H60
			fbtt->hilitecolor = &HC00000
			Return 0
			
		Case WM_SETFONT
			fbtt = GetWindowLong(hWnd, 0)
			fbtt->hfont = wParam
			Return 0
			
		Case WM_ACTIVATE
			Return 0
			
		Case WM_MOUSEACTIVATE
			Return 0
			
		Case WM_SETCURSOR
			Return 0
			
		Case TTM_SETITEM
			fbtt = GetWindowLong(hWnd, 0)
			style = GetWindowLong(hWnd, GWL_STYLE)
			Dim tti As TTITEM Ptr = Cast(TTITEM Ptr, lParam)
		
			fbtt->tti = *tti
			
			Dim s As UByte Ptr = fbtt->tti.lpszParam
			If fbtt->tti.nitem = 0 Then
				While s[0] <> Asc(",") AndAlso s[0] <> 0
					Dim sTmp As UByte Ptr = SkipScope(s)
					If sTmp Then
						s = sTmp
					Else
						s += 1
					EndIf
				Wend
				fbtt->nleft = 0
				fbtt->nlen = s - Cast(UByte Ptr, fbtt->tti.lpszParam)
			Else
				Dim nItm As Integer = fbtt->tti.nitem
				While nItm
					While s[0] <> Asc(",") AndAlso s[0] <> 0
						Dim sTmp As UByte Ptr = SkipScope(s)
						If sTmp Then
							s = sTmp
						Else
							s += 1
						EndIf
					Wend
					If s[0] = Asc(",") Then s += 1
					nitm -= 1
					If s[0] = 0 Then Exit While
				Wend
				fbtt->nleft = s - Cast(UByte Ptr, fbtt->tti.lpszParam)
				While s[0] <> Asc(",") AndAlso s[0] <> 0
					Dim sTmp As UByte Ptr = SkipScope(s)
					If sTmp Then
						s = sTmp
					Else
						s += 1
					EndIf
				Wend
				fbtt->nlen = s - Cast(UByte Ptr, fbtt->tti.lpszParam) - fbtt->nleft
			EndIf
			
			ps.hdc = GetDC(hWnd)
			Dim oldObj As HGDIOBJ = SelectObject(ps.hdc, fbtt->hfont)
			rc.left = 0
			rc.right = 0
			rc.top = 0
			rc.bottom = 0
			
			If fbtt->tti.novr > 1 Then
				wsprintf(StrPtr(findBuff), StrPtr(szFmt), fbtt->tti.nsel+1, fbtt->tti.novr)
				DrawText(ps.hdc, StrPtr(findBuff), -1, @rc, DT_CALCRECT Or DT_SINGLELINE Or DT_NOPREFIX Or DT_LEFT)
				' 40=25+10(extra space)+5(space between api and graph)
				rc.left = rc.right + 40
			EndIf
			If fbtt->tti.lpszApi Then
				DrawText(ps.hdc, fbtt->tti.lpszApi, -1, @rc, DT_CALCRECT Or DT_SINGLELINE Or DT_NOPREFIX Or DT_LEFT)
				rc.left = rc.right
				If style And STYLE_USEPARANTESES Then
					rgt = Asc("(")
				Else
					rgt = Asc(",")
				EndIf
				DrawText(ps.hdc, @rgt, 1, @rc, DT_CALCRECT Or DT_SINGLELINE Or DT_NOPREFIX Or DT_LEFT)
				rc.left = rc.right
			EndIf
			If fbtt->tti.lpszParam AndAlso fbtt->nleft Then
				DrawText(ps.hdc, fbtt->tti.lpszParam, fbtt->nleft, @rc, DT_CALCRECT Or DT_SINGLELINE Or DT_NOPREFIX Or DT_LEFT)
			EndIf
			rgt = rc.right
			If fbtt->tti.lpszParam Then
				DrawText(ps.hdc, fbtt->tti.lpszParam, -1, @rc, DT_CALCRECT Or DT_SINGLELINE Or DT_NOPREFIX Or DT_LEFT)
				rc.left = rc.right
				If style And STYLE_USEPARANTESES Then
					DrawText(ps.hdc, @")", 1, @rc, DT_CALCRECT Or DT_SINGLELINE Or DT_NOPREFIX Or DT_LEFT)
					rc.left = rc.right
				EndIf
			EndIf
			If fbtt->tti.lpszRetType Then
				If fbtt->tti.lpszRetType[0] Then
					rc.left += 5
					DrawText(ps.hdc, fbtt->tti.lpszRetType, -1, @rc, DT_CALCRECT Or DT_SINGLELINE Or DT_NOPREFIX Or DT_LEFT)
				EndIf
			EndIf
			rc.right += 4
			If tti->lpszDesc Then
				rc1.left = 4
				rc1.top = 0
				DrawText(ps.hdc, fbtt->tti.lpszDesc, -1, @rc1, DT_CALCRECT Or DT_SINGLELINE Or DT_NOPREFIX Or DT_LEFT)
				If rc1.right > rc.right Then
					rc.right = rc1.right
				EndIf
				rc.bottom Shl= 1
			EndIf
			rc.bottom += 3
			SelectObject(ps.hdc, oldObj)
			ReleaseDC(hWnd, ps.hdc)
			SetWindowPos(hWnd, 0, 0, 0, rc.right, rc.bottom, SWP_NOACTIVATE Or SWP_NOMOVE Or SWP_NOZORDER)
			fbtt->tti.nwidth = rc.right
			Return rgt
			
		Case TTM_GETCOLOR
			fbtt = GetWindowLong(hWnd, 0)
			Dim ttcol As TT_COLOR Ptr = Cast(TT_COLOR Ptr, lParam)
			ttcol->back = fbtt->backcolor
			ttcol->text = fbtt->textcolor
			ttcol->api = fbtt->apicolor
			ttcol->hilite = fbtt->hilitecolor
			InvalidateRect(hWnd, NULL, TRUE)
			Return 0
			
		Case TTM_SETCOLOR
			fbtt = GetWindowLong(hWnd, 0)
			Dim ttcol As TT_COLOR Ptr = Cast(TT_COLOR Ptr, lParam)
			fbtt->backColor = ttcol->back
			fbtt->textColor = ttcol->text
			fbtt->apiColor = ttcol->api
			fbtt->hiliteColor = ttcol->hilite
			InvalidateRect(hWnd, NULL, TRUE)
			Return 0
			
		Case TTM_GETITEMNAME
			fbtt = GetWindowLong(hWnd, 0)
			Dim tti As TTITEM Ptr = lParam
			Dim s As UByte Ptr = tti->lpszParam
			Dim nItm As Integer = tti->nitem
			While nItm
				While s[0] <> Asc(",") AndAlso s[0] <> 0
					Dim sTmp As UByte Ptr = SkipScope(s)
					If sTmp Then
						s = sTmp
					Else
						s += 1
					EndIf
				Wend
				If s[0] = Asc(",") Then s += 1
				nItm -= 1
				If s[0] = 0 Then Exit While
			Wend
			While s[0] = Asc(" ")
				s += 1
			Wend
			If lstrcmpi(s, StrPtr(szByVal)) Or lstrcmpi(s, StrPtr(szByRef)) Then
				s += 6
			EndIf
			While s[0] = Asc(" ")
				s += 1
			Wend
			Dim sPos As Integer = 0
			While s[0] <> 0 AndAlso s[0] <> Asc(",") AndAlso s[0] <> Asc(":") AndAlso s[0] <> Asc("(") AndAlso s[0] <> Asc("[") AndAlso s[0] <> Asc(" ")
				ItemBuff[sPos] = s[0]
				sPos += 1
				s += 0
			Wend
			ItemBuff[sPos] = 0
			Return StrPtr(ItemBuff)
			
		Case TTM_GETITEMTYPE
			fbtt = GetWindowLong(hWnd, 0)
			Dim tti As TTITEM Ptr = lParam
			Dim s As UByte Ptr = tti->lpszParam
			Dim nItm As Integer = tti->nitem
			While nItm
				While s[0] <> Asc(",") AndAlso s[0] <> 0
					Dim sTmp As UByte Ptr = SkipScope(s)
					If sTmp Then
						s = sTmp
					Else
						s += 1
					EndIf
				Wend
				If s[0] = Asc(",") Then s += 1
				nItm -= 1
				If s[0] = 0 Then Exit While
			Wend
			While s[0] = Asc(" ")
				s += 1
			Wend
			If lstrcmpi(s, StrPtr(szByVal)) Or lstrcmpi(s, StrPtr(szByRef)) Then
				s += 6
			EndIf
			While s[0] = Asc(" ")
				s += 1
			Wend
			
			While s[0] <> Asc(",") AndAlso s[0] <> Asc(",") AndAlso s[0] <> 0
				Dim sTmp As UByte Ptr = SkipScope(s)
				If sTmp Then
					s = sTmp
				Else
					s += 1
				EndIf
			Wend
			
			Dim sPos As Integer = 0
			If s[0] = Asc(":") Then
				While s[0] <> 0 AndAlso s[0] <> Asc(",") AndAlso s[0] <> Asc(":") AndAlso s[0] <> Asc("(") AndAlso s[0] <> Asc(" ")
					ItemBuff[sPos] = s[0]
					sPos += 1
					s += 1
				Wend
			EndIf
			ItemBuff[sPos] = 0
			Return StrPtr(ItemBuff)
			
		Case TTM_SCREENFITS
			fbtt = GetWindowLong(hWnd, 0)
			Dim scrWid As Integer = GetSystemMetrics(SM_CXFULLSCREEN)
			Dim ptp As Point Ptr = Cast(Point Ptr, lParam)
			If ptp->x < 0 Then
				ptp->x = 0
			EndIf
			If ptp->x + fbtt->tti.nwidth > scrWid Then
				ptp->x = scrWid-fbtt->tti.nwidth
			EndIf
			Return 0
		
	End Select
	
	Return DefWindowProc(hWnd, uMsg, wParam, lParam)
	
End Function



Sub SetScroll(hWnd As HWND) 
	Dim rc As RECT

End sub
