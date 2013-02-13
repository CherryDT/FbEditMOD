
include		windows.inc
include		kernel32.inc
include		user32.inc
include		Comctl32.inc
include		shell32.inc

includelib	kernel32.lib
includelib	user32.lib
includelib	Comctl32.lib
includelib	shell32.lib

;VKim Debug
include masm32.inc
include \RadASM\masm\inc\debug.inc
includelib masm32.lib
includelib \RadASM\masm\lib\debug.lib

include ..\RAProperty.inc

DlgProc			PROTO	:HWND,:UINT,:WPARAM,:LPARAM

.const

IDD_MAIN		equ 101
szLib			db 'RAProperty.dll',0
szCode			db 'Code',0
szConst			db 'Const',0
szData			db 'Data',0
szStruct		db 'Struct',0

szApiFile		db '\RadASM\masm\masmApiCall.api',0
szParseFile		db '\FbEdit\Projects\Applications\FbEdit\RadASM\Projects\Debug\TestDebug.asm',0
defgen			DEFGEN <'comment+',<0>,';',<27h,22h>,'\'>
szIgnore1		db 'option',0
szIgnore2		db 'include',0
szIgnore3		db 'includelib',0
szIgnore4		db '@@:',0
szIgnore5		db 'uses',0
szIgnore6		db 'eax',0
szIgnore7		db 'ebx',0
szIgnore8		db 'ecx',0
szIgnore9		db 'edx',0
szIgnore10		db 'esi',0
szIgnore11		db 'edi',0
szIgnore12		db 'ebp',0
szIgnore13		db 'esp',0

deftypeproc		DEFTYPE <TYPE_NAMEFIRST,DEFTYPE_PROC,'p',4,'proc'>
deftypeendp		DEFTYPE <TYPE_OPTNAMEFIRST,DEFTYPE_ENDPROC,'p',4,'endp'>

deftypeconst	DEFTYPE <TYPE_NAMEFIRST,DEFTYPE_CONST,'c',3,'equ'>
deftypelocal	DEFTYPE <TYPE_NAMESECOND,DEFTYPE_LOCALDATA,'l',5,'local'>

;#########################################################################

.data

szp				db 'Pp',0
szNULL			db 0
crlf			db 13,10,0

CharTab			db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;00
				db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;10
				;    ! " # $ % & ' ( ) * + , - . /
				db 0,2,5,3,2,2,2,5,2,2,2,2,2,2,3,2		;20
				;  0 1 2 3 4 5 6 7 8 9 : ; < = > ?
				db 1,1,1,1,1,1,1,1,1,1,2,4,2,2,2,3		;30
				;  @ A B C D E F G H I J K L M N O
				db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1		;40
				;  P Q R S T U V W X Y Z [ \ ] ^ _
				db 1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,1		;50
				;  ` a b c d e f g h i j k l m n o
				db 0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1		;60
				;  p q r s t u v w x y z { | } ~
				db 1,1,1,1,1,1,1,1,1,1,1,2,2,2,0,0		;70

				db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;80
				db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;90
				db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;A0
				db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;B0
				db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;C0
				db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;D0
				db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;E0
				db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;F0

CaseTab			db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;00
				db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;10
				db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;20
				db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;30
				db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;40
				db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;50
				db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;60
				db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;70
				db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;80
				db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;90
				db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;A0
				db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;B0
				db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;C0
				db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;D0
				db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;E0
				db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0		;F0

.data?

hInstance		dd ?
hLib			dd ?

;#########################################################################
