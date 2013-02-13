
IDD_DLGCHECK_UPDATE				equ 8000
IDC_EDTVERSION					equ 1001
IDC_BTNDOWNLOAD					equ 1008
IDC_EDTDLPATH					equ 1006
IDC_BTNDLPATH					equ 1007
IDC_BTNUNZIP					equ 1009
IDC_BTNVIEW						equ 1011
IDC_BTNUPDATE					equ 1002

IDD_DLGDOWNLOAD					equ 8100
IDC_STCDOWNLOADING				equ 1001
IDC_STCFILESIZE					equ 1003
IDC_PGB1						equ 1002

.const

szBackSlash						db '\',0
szTemp							db '\ResEd_Update',0
szAllFiles						db '\*.*',0
szCRLF							db 13,10,0
AppName							db 'UpdateChecker',0
szWhatsNew						db '\WhatsNew.txt',0
szResEdexe						db '\ResEd.exe',0
szUnzip							db 13,10,'Push [Unzip] to continue.',0
szDone							db 'Done!',13,10,13,10,'Push [Update] to continue.',0
szClose							db 'Close',0

szFmtVersion					db 'Your current version:',9,'%s',13,10,'Version at sourceforge:',9,'%s',13,10,13,10,'Push [Download] to continue.',0
szWarning						db 13,10,13,10,'WARNING!',13,10,'Changes to your current project will be lost if you update.',13,10,'It is recomended that you close the project.',0
szUrlVersion					db 'https://fbedit.svn.sourceforge.net/svnroot/fbedit/ResEd22/ReleaseVersion.txt',0
szUrlFile						db 'https://fbedit.svn.sourceforge.net/svnroot/fbedit/ResEd22/',0

szDownloading					db 'Downloading: ',0
szFmtFilesize					db 'Filesize: %d bytes',0
szIDEFile						db 'ResEd.zip',0
szFmtDownloaded					db 'Downloded %s %s',13,10,0
szSuccess						db 'successfully.',0

szINetErr1						db 'InternetOpen failed.',0
szINetErr2						db 'InternetOpenUrl failed.',0
szINetErr3						db 'HttpQueryInfo failed',0
szINetErr4						db 'InternetReadFile failed',0
szINetErr5						db 'CreateFile failed',0
szINetErr6						db 'Canceled.',0
szFmtErrNotEmpty				db 'The folder %s exists and is not empty.',13,10,'All files in the folder will be moved to Recycle Bin.',13,10,13,10,'Continue?',0
szFmtUpdateBat					db ':AGAIN',13,10
								db 'copy %s%s %s',13,10
								db 'IF ERRORLEVEL 1 GOTO AGAIN',13,10
								db 'copy %s%s %s',13,10
								db 'FOR %s IN (%s%s) DO DEL %s',13,10
								db 'rd %s',13,10
								db 'ResEd.exe /Updated',13,10
								db 'del update.bat',13,10,0
szUpdateBat						db 'Update.bat',0
szPPA							db '%%A',0

.data?

szDLFileName					db MAX_PATH dup(?)
szDLPath						db MAX_PATH dup(?)
hDLThread						dd ?
nDLThread						dd ?
fDLCancel						dd ?
nDLErrors						dd ?
tempbuff						db 2048 dup(?)
