

#Include Once "windowsUR.bi"


Declare Sub SetHiliteWords (ByVal hWin As HWND)
Declare Sub SetHiliteWordsFromApi (ByVal hWin As HWND)
Declare Sub AddApiFile (Byref sFile As zString, ByVal nType As Integer)
Declare Sub LoadApiFiles ()


Type EDITOPTION
	tabsize			As Integer
	expand			As Integer
	hiliteline		As Integer
	autoindent		As Integer
	hilitecmnt		As Integer
	linenumbers		As Integer
	backup			As Integer
	bracematch		As Integer
	AutoBrace		As Integer
	autocase		As Integer
	autoblock		As Integer
	autoformat		As Integer
	codecomplete	As Integer
	autosave		As Integer
	autoload		As Integer
	autowidth		As Integer
	autoinclude		As Integer
	closeonlocks	As Integer
	tooltip			As Integer
	smartmath		As Integer
	ExtraLineSpace  As Integer        '0.25 LF steps
End Type


Common Shared edtopt     As EDITOPTION             ' = (3,0,0,1,0,0,3,1,1,1,1,1,1,0,0,0,1,1,1,0,0)
Common Shared sCodeFiles As ZString * 260          'sCodeFiles is LCASE p.def. - forced on every I/O



