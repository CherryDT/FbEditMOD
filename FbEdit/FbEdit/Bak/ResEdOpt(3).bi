

#Include Once "windowsUR.bi"


Declare Sub SetDialogOptions(ByVal hWin As HWND)


Type NAMEEXPORT
	nType				As Integer
	nOutput	    		As Integer
	fAuto				As Integer
	szFileName	    	As ZString Ptr
End Type

Type GRIDSIZE
	x					As Integer
	y					As Integer
	show				As Integer
	snap				As Integer
	tips				As Integer
	Color				As Integer
	Line				As Integer
	stylehex			As Integer
	sizetofont		    As Integer
	nodefines   		As Integer
	simple		    	As Integer
	defstatic		    As Integer
End Type


Extern nmeexp  As NAMEEXPORT
Extern grdsize As GRIDSIZE
