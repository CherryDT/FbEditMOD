''
''
'' windows -- header translated with help of SWIG FB wrapper
''
'' NOTICE: This file is part of the FreeBASIC Compiler package and can't
''         be included in other distributions without authorization.
''
''
#Ifndef __windows_bi__
    #Define __windows_bi__
    
    #Define _X86_
    #Define WINVER &h0501             ' Win XP
    
    #Include Once "win/windef.bi"
    #Include Once "win/wincon.bi"
    #Include Once "win/winbaseUR.bi"  ' modified
    #Include Once "win/wingdiUR.bi"   ' modified
    #Include Once "win/winuserUR.bi"  ' modified
    #Include Once "win/winnls.bi"
    #Include Once "win/winver.bi"
    #Include Once "win/winnetwk.bi"
    #Include Once "win/winreg.bi"
    #Include Once "win/winsvc.bi"
    
    #Ifdef WIN_INCLUDEALL
        #Include Once "win/cderr.bi"
        #Include Once "win/dde.bi"
        #Include Once "win/ddeml.bi"
        #Include Once "win/dlgs.bi"
        #Include Once "win/imm.bi"
        #Include Once "win/lzexpand.bi"
        #Include Once "win/mmsystem.bi"
        #Include Once "win/nb30.bi"
        #Include Once "win/rpc.bi"
        #Include Once "win/shellapi.bi"
        #Include Once "win/winperf.bi"
        #Include Once "win/commdlg.bi"
        #Include Once "win/winspool.bi"
        #IfDef __USE_W32_SOCKETS
            #Include Once "win/winsock2.bi"
        #EndIf
        #Include Once "win/ole2.bi"
    #EndIf
#EndIf
