
' FbEdit menu id's
#Define IDM_HELPF1							10231
#Define IDM_HELPCTRLF1						10232

' RAEdit commands
#Define REM_BASE								WM_USER+1000
#Define REM_GETWORD							REM_BASE+15		' wParam=BuffSize, lParam=lpBuff

Dim Shared hInstance As HINSTANCE
Dim Shared hooks As ADDINHOOKS
Dim Shared lpHandles As ADDINHANDLES Ptr
Dim Shared lpFunctions As ADDINFUNCTIONS Ptr
Dim Shared lpData As ADDINDATA Ptr

' fb keywords
Const fbwords=	" abs acos asin atan2 atn cos exp fix frac int log randomize rnd sgn sin sqr tan " & _
					"screenlist screenlock screenptr screenres screenset screensync screenunlock screen screencontrol screencopy screenevent screenglproc screeninfo " & _
					"and andalso delete eqv imp let mod new not or orelse procptr shl shr strptr varptr xor " & _
					"$dynamic $include $lang $static #define #else #elseif #endif #endmacro #error #if #ifdef #ifndef #inclib #include #lang #libpath #line #macro #pragma #print #undef " & _
					"cbyte cdbl cint clng clngint cptr cshort csign csng cubyte cuint culng culngint cunsg cushort cvd cvi cvl cvlongint cvs cvshort " & _
					"second seek setdate setenviron setmouse settime shell sizeof sleep space spc static stdcall stick stop str strig swap system scrn tab this threadcreate threadwait time timer timeserial timevalue to trans trim typeof ubound ucase union unlock unsigned until using va_arg va_first va_next val valint vallng valuint valulng var view wait wbin wchr weekday weekdayname whex width window windowtitle winput with woct write wspace wstr year " & _
					"access add alias allocate alpha append asc asm assert assertwarn beep bin binary bit bitreset bitset bload bsave call callocate cast cdecl chain chdir chr circle class clear close cls color command common condbroadcast condcreate conddestroy condsignal condwait continue csrlin curdir data date dateadd datediff datepart dateserial datevalue day deallocate defbyte defdbl defined defint deflng deflongint " & _
					"defshort defsng defstr defubyte defuint defulongint defushort dir draw dylibfree dylibload dylibsymbol encoding enum environ eof erase erfn erl ermn err error exec exepath exit export extern field fileattr filecopy filedatetime fileexists filelen flip format frac fre freefile get getjoystick getkey getmouse gosub goto hex hibyte hiword hour iif imageconvertrow imagecreate imagedestroy imageinfo import inkey inp input instr instrrev is isdate kill lbound lcase left len lib line lobyte loc local locate lock lof loword lpos lprint lset ltrim " & _
					"byref byval as shared cons gosub goto lpt mid minute mkd mkdir mki mkl mklongint mks mkshort month monthname multikey mutexcreate mutexdestroy mutexlock mutexunlock name nogosub nokeyword now oct offsetof on once open option out output overload paint palette pascal pcopy peek pipe pmap point pointer poke pos preserve preset print private private protected pset public put random read reallocate redim rem reset restore resume return rgb rgba right rmdir rset rtrim run sadd scope " & _
					"const case constructor declare destructor dim if then else elseif end endif for do loop while wend function namespace next operator property select step sub then type " & _
					"accelerators alt autocheckbox autoradiobutton begin bitmap block caption class combobox control cursor dialogex discardable edittext end exstyle false fileos filetype fileversion font groupbox icon listbox ltext menu menuitem noinvert null popup productversion pushbutton separator shift stringtable style true value versioninfo virtkey " & _
					"__date__ __fb_argc__ __fb_argv__ __fb_bigendian__ __fb_build_date__ __fb_cygwin__ __fb_debug__ __fb_dos__ __fb_err__ __fb_freebsd__ __fb_lang__ __fb_linux__ __fb_main__ __fb_min_version__ __fb_mt__ __fb_option_byval__ __fb_option_dynamic__ __fb_option_escape__ __fb_option_explicit__ __fb_option_gosub__ __fb_option_private__ __fb_out_dll__ __fb_out_exe__ __fb_out_lib__ __fb_out_obj__ __fb_signature__ __fb_sse__ __fb_ver_major__ __fb_ver_minor__ __fb_ver_patch__ __fb_version__ __fb_win32__ __fb_xbox__ __file__ __file_nq__ __function__ __function_nq__ __line__ __path__ __time__ " & _
					"byte double integer long longint short single string ubyte uinteger ulong ulongint ushort wstring zstring ptr any "
