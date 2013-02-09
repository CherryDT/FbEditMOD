

#Define IDD_DLGLANGUAGE		1200
#Define IDC_LSTLANGUAGE		1003
#Define BMPMARGIN			3
#Define TEXTMARGIN			26

Common Shared hLngDlg  As HWND
Common Shared Language As ZString * 260


Declare Sub TranslateDialog (ByVal hWin As HWND, ByVal id As Integer)
Declare Sub TranslateAddinDialog (ByVal hWin As HWND, ByRef sID As zString)
Declare Function GetInternalString (ByVal id As Integer) As String
Declare Function FindString (ByVal hMem As HGLOBAL, ByRef szApp As zString, ByRef szKey As ZString) As String
Declare Sub GetLanguageFile ()

Declare Function LanguageDlgProc (ByVal hWin As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As Integer


/'	FbEdit strings

	1-			Critical messages
	100-		Main window
	1000-		Find dialog / messages
	1100-		Menu options dialog
	1200-		New project dialog
	1300-		Project tab main window
	2000-		File open / save dialogs
	3000-		Messageboxes
	4000-		Resource editor options
	5000-		RAEdit tooltips
	5010-		RAFile tooltips
'/

#DEFINE IS_COULD_NOT_FIND               1
#define IS_EXITFULLSCREEN               2
#DEFINE IS_FILE                         100
#DEFINE IS_PROJECT                      101
#DEFINE IS_FIND                         1000
#DEFINE IS_NEXT                         1001
#DEFINE IS_PREVIOUS                     1002
#DEFINE IS_REPLACE                      1003
#DEFINE IS_REGION_SEARCHED              1004
#DEFINE IS_REPLACEMENTS_DONE            1005
#DEFINE IS_PROJECT_FILES_SEARCHED       1006
#DEFINE IS_REGION_SEARCHED_INFO         1007
#DEFINE IS_PROJECT_FILES_SEARCHED_INFO  1008
#Define IS_OPEN_FILES_SEARCHED_INFO  	1009
#Define IS_SEARCH_CANCELLED             1010
#Define IS_COMPILER_INCPATH_SEARCHED    1011
#DEFINE IS_TOOLS_MENU_OPTION            1100
#Define IS_HELP_MENU_OPTION             1101
#DEFINE IS_BUILD_OPTIONS                1102
#DEFINE IS_PROJECT_BUILD_OPTIONS        1103
#DEFINE IS_IMPORT_BUILD_OPTION          1104
#Define IS_REGEX_LIB                    1105
#Define IS_MODULE_BUILD_OPTIONS         1106
#DEFINE IS_FILES                        1200
#DEFINE IS_TEMPLATE                     1201
#DEFINE IS_BROWSE_FOR_FOLDER            1202
#DEFINE IS_BASIC_SOURCE                 1300
#DEFINE IS_INCLUDE                      1301
#DEFINE IS_RESOURCE                     1302
#DEFINE IS_MISC                         1303
#Define IS_BASIC_MODULE                 1304
#Define IS_SCRIPT                       1305
#DEFINE IS_ADD_NEW_FILE                 2000
#DEFINE IS_ADD_EXISTING_FILE            2001
#DEFINE IS_ADD_NEW_MODULE               2002
#DEFINE IS_ADD_EXISTING_MODULE          2003
#DEFINE IS_OPEN_PROJECT                 2004
#DEFINE IS_FILE_EXISTS_IN_PROJECT       3000
#DEFINE IS_REMOVE_FILE_FROM_PROJECT     3001
#DEFINE IS_FAILED_TO_CREATE_THE_FOLDER  3002
#DEFINE IS_FOLDER_EXISTS                3003
#DEFINE IS_PROJECT_FILE_EXISTS          3004
#DEFINE IS_FAILED_TO_CREATE_THE_FILE    3005
#DEFINE IS_WANT_TO_SAVE_CHANGES         3006
#DEFINE IS_FILE_CHANGED_OUTSIDE_EDITOR  3007
#DEFINE IS_REOPEN_THE_FILE              3008
#DEFINE IS_RESOURCEOPT1                 4010
#DEFINE IS_RESOURCEOPT2                 4020
#DEFINE IS_RESOURCEOPT3                 4030
#DEFINE IS_RESOURCEOPT3HDR1             4031
#DEFINE IS_RESOURCEOPT3HDR2             4032
#Define IS_RESOURCEOPT4                 4040
#DEFINE IS_RESOURCEOPT4HDR1             4041
#DEFINE IS_RESOURCEOPT4HDR2             4042
#DEFINE IS_RESOURCEOPT4HDR3             4043
#Define IS_RESOURCEOPT5                 4050
#DEFINE IS_RESOURCEOPT5HDR1             4051
#DEFINE IS_RESOURCEOPT5HDR2             4052
#DEFINE IS_RESOURCEOPT5HDR3             4053
#DEFINE IS_RESOURCEOPT5HDR4             4054
#Define IS_RAEDIT_BASE                  5000
#DEFINE IS_RAEDIT1                      IS_RAEDIT_BASE + 1
#DEFINE IS_RAEDIT2                      IS_RAEDIT_BASE + 2
#DEFINE IS_RAEDIT3                      IS_RAEDIT_BASE + 3
#DEFINE IS_RAEDIT4                      IS_RAEDIT_BASE + 4
#DEFINE IS_RAEDIT5                      IS_RAEDIT_BASE + 5
#DEFINE IS_RAEDIT6                      IS_RAEDIT_BASE + 6
#DEFINE IS_RAFILE1                      5011
#DEFINE IS_RAFILE2                      5012
#DEFINE IS_RAPROPERTY1                  5021
#DEFINE IS_RAPROPERTY2                  5022
#DEFINE IS_RAPROPERTY3                  5023
#DEFINE IS_RAPROPERTY4                  5024
#DEFINE IS_RAPROPERTY5                  5025

Const InternalStrings=	!"\13\10" & _
								!"[Internal]\13\10" & _
								!"1=Could not find\13\10" & _
								!"2=Exit Fullscreen\9Ctrl+W\13\10" & _
								!"100=File\13\10" & _
								!"101=Project\13\10" & _
								!"1000=Find\13\10" & _
								!"1001=Next\13\10" & _
								!"1002=Previous\13\10" & _
								!"1003=Replace...\13\10" & _
								!"1004=Region searched\13\10" & _
								!"1005=Replacements done.\13\10" & _
								!"1006=Project Files searched\13\10" & _
								!"1007=Region searched%c%cFind%c  Founds: %d%c  Repeats: %d%c%cBuild%c  Errors: %d%c  Warnings: %d\13\10" & _
								!"1008=Project Files searched%c%cFind%c  Files: %d%c  Founds: %d%c  Repeats: %d%c%cBuild%c  Errors: %d%c  Warnings: %d\13\10" & _
								!"1009=Open Files searched%c%cFind%c  Files: %d%c  Founds: %d%c  Repeats: %d%c%cBuild%c  Errors: %d%c  Warnings: %d\13\10" & _
								!"1010=Search cancelled\13\10" & _
								!"1011=Compiler Include Path searched\13\10" & _
								!"1100=Tools Menu Option\13\10" & _
								!"1101=Help Menu Option\13\10" & _
								!"1102=Build Options\13\10" & _
								!"1103=Project Build Option\13\10" & _
								!"1104=Import Build Option\13\10" & _
								!"1105=RegExp Library\13\10" & _
			                    !"1106=Module Build Option\13\10" & _
								!"1200=Files\13\10" & _
								!"1201=Template\13\10" & _
								!"1202=Browse For Folder\13\10" & _
								!"1300=Basic Source\13\10" & _
								!"1301=Include\13\10" & _
								!"1302=Resource\13\10" & _
								!"1303=Misc\13\10" & _
								!"1304=Basic Module\13\10" & _
								!"1305=Scripts\13\10" & _
								!"2000=Add New File\13\10" & _
								!"2001=Add Existing File\13\10" & _
								!"2002=Add New Module\13\10" & _
								!"2003=Add Existing Module\13\10" & _
								!"2004=Open Project\13\10" & _
								!"3000=File exists in project.\13\10" & _
								!"3001=Remove file from project?\13\10" & _
								!"3002=Failed to create the folder:\13\10" & _
								!"3003=Folder exists. Create project anyway?\13\10" & _
								!"3004=Project file exists. Create project anyway?\13\10" & _
								!"3005=Failed to create the file:\13\10" & _
								!"3006=Want to save changes?\13\10" & _
								!"3007=File changed outside editor!\13\10" & _
								!"3008=Reopen the file?\13\10" & _
								!"4010=Exports\13\10" & _
								!"4020=Behaviour\13\10" & _
								!"4030=Custom controls\13\10" & _
								!"4031=Custom control\13\10" & _
								!"4032=Style mask\13\10" & _
								!"4040=Custom styles\13\10" & _
								!"4041=Style\13\10" & _
								!"4042=Value\13\10" & _
								!"4043=Mask\13\10" & _
								!"4050=Resource types\13\10" & _
								!"4051=Name\13\10" & _
								!"4052=Value\13\10" & _
								!"4053=Files\13\10" & _
								!"4054=Editor\13\10" & _
								!"5001=Changed state\13\10" & _
								!"5002=Splitter Bar\13\10" & _
								!"5003=Show/Hide Linenumbers\13\10" & _
								!"5004=Expand all\13\10" & _
								!"5005=Collapse all\13\10" & _
								!"5006=Lock/Unlock Tab\13\10" & _
								!"5011=Up One Level\13\10" & _
								!"5012=File Filter\13\10" & _
								!"5021=Current file\13\10" & _
								!"5022=All Open files\13\10" & _
								!"5023=All Project files\13\10" & _
								!"5024=Sorry, not implemented\13\10" & _
								!"5025=Refresh\13\10"
