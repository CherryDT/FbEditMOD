

Type FIND
    Engine                  As Integer                      ' MOD 16.2.2012  0=STD, 1=RegEx
    fdir					As Integer						' 0=All, 1=Down, 2=Up
    fsearch			    	As Integer						' 0=Procedure, 1=Module, 2=Open Files, 3=Project, 4=Selection
    fpro					As Integer
    ffileno				    As Integer
    chrginit				As CHARRANGE					' Position at startup
    chrgrange			    As CHARRANGE					' Range to search
    fr						As Integer						' Find flags
    ft						As FINDTEXTEX
    findbuff				As ZString * 260
    replacebuff			    As ZString * 260
    nreplacecount		    As Integer
    fskipcommentline	    As Integer
    flogfind				As Integer
    fonlyonetime		    As Integer                      ' Flag set only on first hit per file, used for logging filename
    fnoproc				    As Boolean						' Flag to handle no procedure
    fnoreset				As Boolean						' Flag to handle opening a new file
    listoffiles			    As String
    listidx                 As Integer                      ' char index walks through listoffiles
    nlinesout			    As Integer                      ' unused
    fres					As Integer						' Find result
    RegEx                   As regex_t                      ' MOD 16.2.2012
    Busy                    As BOOLEAN                      ' MOD 28.3.2012 lenghty op is running, clear to stop it
    LoadForSearch           As ZString * 260                ' list of extensions, matching project files are loaded for searching
    SaveOnExit              As BOOL                         ' FALSE skips saving of dialogbox data (cancel button)
    FoundAny                As BOOL                         ' FALSE if nothing found in searched file
    KeepLoaded              As BOOL                         ' if FALSE all loaded files during project wide search are unloaded if nothing found
End Type


Enum FindMode
    FM_DIR_ALL        = 0
    FM_DIR_DOWN
    FM_DIR_UP
    FM_ENGINE_STD     = 0
    FM_ENGINE_REGEX
    FM_RANGE_PROC     = 0
    FM_RANGE_SELTAB
    FM_RANGE_ALLTABS
    FM_RANGE_PROJECT
    FM_RANGE_COMPILERINCPATH
    FM_RANGE_SELECTION
End Enum

Extern f     As FIND
Extern fsave As FIND


Declare Sub FindReadIni ()
Declare Sub FindWriteIni ()
Declare Function Find (ByVal hWin As HWND,ByVal frType As Integer) As Integer
Declare Sub ResetFind ()
Declare Sub UpDateFind (ByVal hWin As HWND,ByVal cpMin As Integer,ByVal fChanged As Integer)
Declare Function FindDlgProc (ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As LRESULT
Declare Function IsFileSearchable (ByVal pFileSpec As ZString Ptr) As BOOL

#Define NOT_FOUND                           -1

#Define IDD_DLG_FIND						2500
#Define IDC_CBO_FINDTEXT					2001
#Define IDC_EDT_REPLACETEXT 				2002
#Define IDC_CHK_MATCHCASE					2003
#Define IDC_CHK_WHOLEWORD					2007
#Define IDC_BTN_REPLACEALL					2008
#Define IDC_STC_REPLACE  					2009
#Define IDC_BTN_REPLACE						2010
#Define IDC_CHK_USE_REGEX                   2011         ' MOD 16.2.2012 add
#Define IDC_BTN_REGEX_HELP                  2012         ' MOD 16.2.2012 add
#Define IDC_CHK_SKIPCOMMENTS				2013
#Define IDC_CHK_LOGFIND						2014
#Define IDC_BTN_FINDALL						2015
#Define IDC_BTN_CLR_OUTPUT                  2016         ' MOD 15.2.2012 add
#Define IDC_BTN_REGEX_LIB                   2020
#Define IDC_EDT_LOADFORSEARCH               2021
#Define IDC_CHK_KEEPLOADED                  2022

' Messages
#Define IDC_IMG_FINDMSG                     2017
#Define IDC_TXT_FINDMSG                     2018
' Direction
#Define IDC_RBN_ALL							2004
#Define IDC_RBN_DOWN						2005
#Define IDC_RBN_UP							2006
' Search
#Define IDC_RBN_PROCEDURE					2502
#Define IDC_RBN_CURRENTFILE				    2503
#Define IDC_RBN_OPENFILES			    	2504
#Define IDC_RBN_SELECTION					2505
#Define IDC_RBN_PROJECTFILES				2507
#Define IDC_RBN_INCLUDEPATH 				2508         ' MOD 1.3.2012 add


