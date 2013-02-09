
#Ifdef __FB_WIN32__
    #Pragma push(msbitfields)
#EndIf

#Inclib "Htmlhelp"

' /****************************************************************************
' *                                                                           *
' * HtmlHelp.h                                                                *
' *                                                                           *
' * Copyright (c) 1996-1997, Microsoft Corp. All rights reserved.             *
' *                                                                           *
' ****************************************************************************/
' 
' #if _MSC_VER > 1000
' #pragma once
' #endif

#Ifndef __HTMLHELP_H__
    #Define __htmlhelp_h__
    
    ' #ifdef __cplusplus
    ' extern "C" {
    ' removed "extern" line
    ' #endif
    
    ' Defines for Win64
    ' #ifndef _WIN64
    ' #define DWORD_PTR DWORD
    ' #endif
    
    ' // Commands to pass to HtmlHelp()
    #Define HH_DISPLAY_TOPIC                &h0000
    #Define HH_HELP_FINDER                  &h0000      ' WinHelp equivalent
    #Define HH_DISPLAY_TOC                  &h0001
    #Define HH_DISPLAY_INDEX                &h0002
    #Define HH_DISPLAY_SEARCH               &h0003
    #Define HH_SET_WIN_TYPE                 &h0004
    #Define HH_GET_WIN_TYPE                 &h0005
    #Define HH_GET_WIN_HANDLE               &h0006
    #Define HH_ENUM_INFO_TYPE               &h0007      ' Get Info type name, call repeatedly to enumerate, -1 at end
    #Define HH_SET_INFO_TYPE                &h0008      ' Add Info type to filter.
    #Define HH_SYNC                         &h0009
    #Define HH_RESERVED1                    &h000A
    #Define HH_RESERVED2                    &h000B
    #Define HH_RESERVED3                    &h000C
    #Define HH_KEYWORD_LOOKUP               &h000D
    #Define HH_DISPLAY_TEXT_POPUP           &h000E      ' display string resource id or text in a popup window
    #Define HH_HELP_CONTEXT                 &h000F      ' display mapped numeric value in dwData
    #Define HH_TP_HELP_CONTEXTMENU          &h0010      ' text popup help, same as WinHelp HELP_CONTEXTMENU
    #Define HH_TP_HELP_WM_HELP              &h0011      ' text popup help, same as WinHelp HELP_WM_HELP
    #Define HH_CLOSE_ALL                    &h0012      ' close all windows opened directly or indirectly by the caller
    #Define HH_ALINK_LOOKUP                 &h0013      ' ALink version of HH_KEYWORD_LOOKUP
    #Define HH_GET_LAST_ERROR               &h0014      ' not currently implemented // See HHERROR.h
    #Define HH_ENUM_CATEGORY                &h0015      ' Get category name, call repeatedly to enumerate, -1 at end
    #Define HH_ENUM_CATEGORY_IT             &h0016      ' Get category info type members, call repeatedly to enumerate, -1 at end
    #Define HH_RESET_IT_FILTER              &h0017      ' Clear the info type filter of all info types.
    #Define HH_SET_INCLUSIVE_FILTER         &h0018      ' set inclusive filtering method for untyped topics to be included in display
    #Define HH_SET_EXCLUSIVE_FILTER         &h0019      ' set exclusive filtering method for untyped topics to be excluded from display
    #Define HH_INITIALIZE                   &h001C      ' Initializes the help system.
    #Define HH_UNINITIALIZE                 &h001D      ' Uninitializes the help system.
    #Define HH_PRETRANSLATEMESSAGE          &h00FD      ' Pumps messages. (NULL, NULL, MSG*). 
    #Define HH_SET_GLOBAL_PROPERTY          &h00FC      ' Set a global property. (NULL, NULL, HH_GPROP)
    #Define HHWIN_PROP_TAB_AUTOHIDESHOW     (1 SHL 0)   ' Automatically hide/show tri-pane window
    #Define HHWIN_PROP_ONTOP                (1 SHL 1)   ' Top-most window
    #Define HHWIN_PROP_NOTITLEBAR           (1 SHL 2)   ' no title bar
    #Define HHWIN_PROP_NODEF_STYLES         (1 SHL 3)   ' no default window styles (only HH_WINTYPE.dwStyles)
    #Define HHWIN_PROP_NODEF_EXSTYLES       (1 SHL 4)   ' no default extended window styles (only HH_WINTYPE.dwExStyles)
    #Define HHWIN_PROP_TRI_PANE             (1 SHL 5)   ' use a tri-pane window
    #Define HHWIN_PROP_NOTB_TEXT            (1 SHL 6)   ' no text on toolbar buttons
    #Define HHWIN_PROP_POST_QUIT            (1 SHL 7)   ' post WM_QUIT message when window closes
    #Define HHWIN_PROP_AUTO_SYNC            (1 SHL 8)   ' automatically ssync contents and index
    #Define HHWIN_PROP_TRACKING             (1 SHL 9)   ' send tracking notification messages
    #Define HHWIN_PROP_TAB_SEARCH           (1 SHL 10)  ' include search tab in navigation pane
    #Define HHWIN_PROP_TAB_HISTORY          (1 SHL 11)  ' include history tab in navigation pane
    #Define HHWIN_PROP_TAB_FAVORITES        (1 SHL 12)  ' include favorites tab in navigation pane
    #Define HHWIN_PROP_CHANGE_TITLE         (1 SHL 13)  ' Put current HTML title in title bar
    #Define HHWIN_PROP_NAV_ONLY_WIN         (1 SHL 14)  ' Only display the navigation window
    #Define HHWIN_PROP_NO_TOOLBAR           (1 SHL 15)  ' Don't display a toolbar
    #Define HHWIN_PROP_MENU                 (1 SHL 16)  ' Menu
    #Define HHWIN_PROP_TAB_ADVSEARCH        (1 SHL 17)  ' Advanced FTS UI.
    #Define HHWIN_PROP_USER_POS             (1 SHL 18)  ' After initial creation, user controls window size/position
    #Define HHWIN_PROP_TAB_CUSTOM1          (1 SHL 19)  ' Use custom tab #1
    #Define HHWIN_PROP_TAB_CUSTOM2          (1 SHL 20)  ' Use custom tab #2
    #Define HHWIN_PROP_TAB_CUSTOM3          (1 SHL 21)  ' Use custom tab #3
    #Define HHWIN_PROP_TAB_CUSTOM4          (1 SHL 22)  ' Use custom tab #4
    #Define HHWIN_PROP_TAB_CUSTOM5          (1 SHL 23)  ' Use custom tab #5
    #Define HHWIN_PROP_TAB_CUSTOM6          (1 SHL 24)  ' Use custom tab #6
    #Define HHWIN_PROP_TAB_CUSTOM7          (1 SHL 25)  ' Use custom tab #7
    #Define HHWIN_PROP_TAB_CUSTOM8          (1 SHL 26)  ' Use custom tab #8
    #Define HHWIN_PROP_TAB_CUSTOM9          (1 SHL 27)  ' Use custom tab #9
    #Define HHWIN_TB_MARGIN                 (1 SHL 28)  ' the window type has a margin
    #Define HHWIN_PARAM_PROPERTIES          (1 SHL 1)   ' valid fsWinProperties
    #Define HHWIN_PARAM_STYLES              (1 SHL 2)   ' valid dwStyles
    #Define HHWIN_PARAM_EXSTYLES            (1 SHL 3)   ' valid dwExStyles
    #Define HHWIN_PARAM_RECT                (1 SHL 4)   ' valid rcWindowPos
    #Define HHWIN_PARAM_NAV_WIDTH           (1 SHL 5)   ' valid iNavWidth
    #Define HHWIN_PARAM_SHOWSTATE           (1 SHL 6)   ' valid nShowState
    #Define HHWIN_PARAM_INFOTYPES           (1 SHL 7)   ' valid apInfoTypes
    #Define HHWIN_PARAM_TB_FLAGS            (1 SHL 8)   ' valid fsToolBarFlags
    #Define HHWIN_PARAM_EXPANSION           (1 SHL 9)   ' valid fNotExpanded
    #Define HHWIN_PARAM_TABPOS              (1 SHL 10)  ' valid tabpos
    #Define HHWIN_PARAM_TABORDER            (1 SHL 11)  ' valid taborder
    #Define HHWIN_PARAM_HISTORY_COUNT       (1 SHL 12)  ' valid cHistory
    #Define HHWIN_PARAM_CUR_TAB             (1 SHL 13)  ' valid curNavType
    #Define HHWIN_BUTTON_EXPAND             (1 SHL 1)   ' Expand/contract button
    #Define HHWIN_BUTTON_BACK               (1 SHL 2)   ' Back button
    #Define HHWIN_BUTTON_FORWARD            (1 SHL 3)   ' Forward button
    #Define HHWIN_BUTTON_STOP               (1 SHL 4)   ' Stop button
    #Define HHWIN_BUTTON_REFRESH            (1 SHL 5)   ' Refresh button
    #Define HHWIN_BUTTON_HOME               (1 SHL 6)   ' Home button
    #Define HHWIN_BUTTON_BROWSE_FWD         (1 SHL 7)   ' not implemented
    #Define HHWIN_BUTTON_BROWSE_BCK         (1 SHL 8)   ' not implemented
    #Define HHWIN_BUTTON_NOTES              (1 SHL 9)   ' not implemented
    #Define HHWIN_BUTTON_CONTENTS           (1 SHL 10)  ' not implemented
    #Define HHWIN_BUTTON_SYNC               (1 SHL 11)  ' Sync button
    #Define HHWIN_BUTTON_OPTIONS            (1 SHL 12)  ' Options button
    #Define HHWIN_BUTTON_PRINT              (1 SHL 13)  ' Print button
    #Define HHWIN_BUTTON_INDEX              (1 SHL 14)  ' not implemented
    #DEFINE HHWIN_BUTTON_SEARCH             (1 SHL 15)  ' not implemented
    #Define HHWIN_BUTTON_HISTORY            (1 SHL 16)  ' not implemented
    #Define HHWIN_BUTTON_FAVORITES          (1 SHL 17)  ' not implemented
    #Define HHWIN_BUTTON_JUMP1              (1 SHL 18)
    #Define HHWIN_BUTTON_JUMP2              (1 SHL 19)
    #Define HHWIN_BUTTON_ZOOM               (1 SHL 20)
    #Define HHWIN_BUTTON_TOC_NEXT           (1 SHL 21)
    #Define HHWIN_BUTTON_TOC_PREV           (1 SHL 22)
    
    #Define HHWIN_DEF_BUTTONS (HHWIN_BUTTON_EXPAND  Or _
                               HHWIN_BUTTON_BACK    Or _
                               HHWIN_BUTTON_OPTIONS Or _
                               HHWIN_BUTTON_PRINT)
    
    ' Button IDs
    #Define IDTB_EXPAND                     200
    #Define IDTB_CONTRACT                   201
    #Define IDTB_STOP                       202
    #Define IDTB_REFRESH                    203
    #Define IDTB_BACK                       204
    #Define IDTB_HOME                       205
    #Define IDTB_SYNC                       206
    #Define IDTB_PRINT                      207
    #Define IDTB_OPTIONS                    208
    #Define IDTB_FORWARD                    209
    #Define IDTB_NOTES                      210         ' not implemented
    #Define IDTB_BROWSE_FWD                 211
    #Define IDTB_BROWSE_BACK                212
    #Define IDTB_CONTENTS                   213         ' not implemented
    #Define IDTB_INDEX                      214         ' not implemented
    #Define IDTB_SEARCH                     215         ' not implemented
    #Define IDTB_HISTORY                    216         ' not implemented
    #Define IDTB_FAVORITES                  217         ' not implemented
    #Define IDTB_JUMP1                      218
    #Define IDTB_JUMP2                      219
    #Define IDTB_CUSTOMIZE                  221
    #Define IDTB_ZOOM                       222
    #Define IDTB_TOC_NEXT                   223
    #Define IDTB_TOC_PREV                   224
    
    ' Notification codes
    #Define HHN_FIRST                       (0U - 860U)
    #Define HHN_LAST                        (0U - 879U)
    #Define HHN_NAVCOMPLETE                 (HHN_FIRST)
    #Define HHN_TRACK                       (HHN_FIRST - 1)
    #Define HHN_WINDOW_CREATE               (HHN_FIRST - 2)
    
    Type tagHHN_NOTIFY
        hdr    As NMHDR
        pszUrl As PCSTR               ' Multi-byte, null-terminated string
    End Type
    
    Type HHN_NOTIFY As tagHHN_NOTIFY 

    Type tagHH_POPUP
        cbStruct      As INTEGER      ' sizeof this structure                                                         
        hinst         As HINSTANCE    ' instance handle for string resource                                           
        idString      As UINT         ' string resource id, or text id if pszFile is specified in HtmlHelp call       
        pszText       As LPCTSTR      ' used if idString is zero                                                      
        pt            As POINT        ' top center of popup window                                                    
        clrForeground As COLORREF     ' use -1 for default                                                            
        clrBackground As COLORREF     ' use -1 for default                                                            
        rcMargins     As RECT         ' amount of space between edges of window and text, -1 for each member to ignore
        pszFont       As LPCTSTR      ' facename, point size, char set, BOLD ITALIC UNDERLINE                         
    End Type
    
    Type HH_POPUP As tagHH_POPUP 

    Type tagHH_AKLINK
        cbStruct      As Integer      ' sizeof this structure                                                       
        fReserved     As BOOL         ' must be FALSE (really!)                                                     
        pszKeywords   As LPCTSTR      ' semi-colon separated keywords                                               
        pszUrl        As LPCTSTR      ' URL to jump to if no keywords found (may be NULL)                           
        pszMsgText    As LPCTSTR      ' Message text to display in MessageBox if pszUrl is NULL and no keyword match
        pszMsgTitle   As LPCTSTR      ' Message text to display in MessageBox if pszUrl is NULL and no keyword match
        pszWindow     As LPCTSTR      ' Window to display URL in                                                    
        fIndexOnFail  As BOOL         ' Displays index if keyword lookup fails.                                     
    End Type
    
    Type HH_AKLINK As tagHH_AKLINK 
    
    Enum 
        HHWIN_NAVTYPE_TOC
        HHWIN_NAVTYPE_INDEX
        HHWIN_NAVTYPE_SEARCH
        HHWIN_NAVTYPE_FAVORITES
        HHWIN_NAVTYPE_HISTORY         ' not implemented
        HHWIN_NAVTYPE_AUTHOR
        HHWIN_NAVTYPE_CUSTOM_FIRST = 11
    End Enum
    
    Enum 
        IT_INCLUSIVE
        IT_EXCLUSIVE
        IT_HIDDEN
    End Enum
    
    Type tagHH_ENUM_IT
        cbStruct         AS INTEGER   ' size of this structure                                                                         
        iType            AS INTEGER   ' the type of the information type ie. Inclusive, Exclusive, or Hidden                           
        pszCatName       AS LPCSTR    ' Set to the name of the Category to enumerate the info types in a category; else NULL           
        pszITName        AS LPCSTR    ' volitile pointer to the name of the infotype. Allocated by call. Caller responsible for freeing
        pszITDescription AS LPCSTR    ' volitile pointer to the description of the infotype.                                           
    End Type
    
    Type HH_ENUM_IT  As tagHH_ENUM_IT 
    Type PHH_ENUM_IT As tagHH_ENUM_IT Ptr 
    
    Type tagHH_ENUM_CAT
        cbStruct          As INTEGER  ' size of this structure                       
        pszCatName        As LPCSTR   ' volitile pointer to the category name        
        pszCatDescription As LPCSTR   ' volitile pointer to the category description 
    End Type
    
    Type HH_ENUM_CAT  As tagHH_ENUM_CAT 
    Type PHH_ENUM_CAT As tagHH_ENUM_CAT Ptr 
    
    Type tagHH_SET_INFOTYPE
        cbStruct        As INTEGER    ' the size of this structure                                    
        pszCatName      As LPCSTR     ' the name of the category, if any, the InfoType is a member of.
        pszInfoTypeName As LPCSTR     ' the name of the info type to add to the filter                
    End Type
    
    Type HH_SET_INFOTYPE  As tagHH_SET_INFOTYPE 
    Type PHH_SET_INFOTYPE As tagHH_SET_INFOTYPE Ptr 
    
    Type HH_INFOTYPE  As DWORD
    Type PHH_INFOTYPE As HH_INFOTYPE Ptr 
    
    Enum 
        HHWIN_NAVTAB_TOP
        HHWIN_NAVTAB_LEFT
        HHWIN_NAVTAB_BOTTOM
    End Enum

    #Define HH_MAX_TABS         19    ' maximum number of tabs
    
    Enum 
        HH_TAB_CONTENTS
        HH_TAB_INDEX
        HH_TAB_SEARCH
        HH_TAB_FAVORITES
        HH_TAB_HISTORY
        HH_TAB_AUTHOR
        HH_TAB_CUSTOM_FIRST = 11
        HH_TAB_CUSTOM_LAST  = HH_MAX_TABS
    End Enum
    
    #Define HH_MAX_TABS_CUSTOM          (HH_TAB_CUSTOM_LAST - HH_TAB_CUSTOM_FIRST + 1)
    
    ' HH_DISPLAY_SEARCH Command Related Structures and Constants
    #Define HH_FTS_DEFAULT_PROXIMITY    (-1)
        
    Type tagHH_FTS_QUERY
        cbStruct        As Integer    ' Sizeof structure in bytes.         
        fUniCodeStrings As BOOL       ' TRUE if all strings are unicode.   
        pszSearchQuery  As LPCTSTR    ' String containing the search query.
        iProximity      As Long       ' Word proximity.                    
        fStemmedSearch  As BOOL       ' TRUE for StemmedSearch only.       
        fTitleOnly      As BOOL       ' TRUE for Title search only.        
        fExecute        As BOOL       ' TRUE to initiate the search.       
        pszWindow       As LPCTSTR    ' Window to display in               
    End Type
    
    Type HH_FTS_QUERY As tagHH_FTS_QUERY 
    
    ' HH_WINTYPE Structure
    Type tagHH_WINTYPE
        cbStruct                           As Integer         ' IN: size of this structure including all Information Types
        fUniCodeStrings                    As BOOL            ' IN/OUT: TRUE if all strings are in UNICODE                
        pszType                            As LPCTSTR         ' IN/OUT: Name of a type of window                          
        fsValidMembers                     As DWORD           ' IN: Bit flag of valid members (HHWIN_PARAM_)              
        fsWinProperties                    As DWORD           ' IN/OUT: Properties/attributes of the window (HHWIN_)      
        
        pszCaption                         As LPCTSTR         ' IN/OUT: Window title                        
        dwStyles                           As DWORD           ' IN/OUT: Window styles                       
        dwExStyles                         As DWORD           ' IN/OUT: Extended Window styles              
        rcWindowPos                        As RECT            ' IN: Starting position, OUT: current position
        nShowState                         As Integer         ' IN: show state (e.g., SW_SHOW)              
        
        hwndHelp                           As HWND            ' OUT: window handle         
        hwndCaller                         As HWND            ' OUT: who called this window
        
        paInfoTypes                        As HH_INFOTYPE Ptr ' IN: Pointer to an array of Information Types
        
        ' The following members are only valid if HHWIN_PROP_TRI_PANE is set
        hwndToolBar                        As HWND            ' OUT: toolbar window in tri-pane window        
        hwndNavigation                     As HWND            ' OUT: navigation window in tri-pane window     
        hwndHTML                           As HWND            ' OUT: window displaying HTML in tri-pane window
        iNavWidth                          As Integer         ' IN/OUT: width of navigation window            
        rcHTML                             As RECT            ' OUT: HTML window coordinates                  
       
        pszToc                             As LPCTSTR         ' IN: Location of the table of contents file                         
        pszIndex                           As LPCTSTR         ' IN: Location of the index file                                     
        pszFile                            As LPCTSTR         ' IN: Default location of the html file                              
        pszHome                            As LPCTSTR         ' IN/OUT: html file to display when Home button is clicked           
        fsToolBarFlags                     As DWORD           ' IN: flags controling the appearance of the toolbar                 
        fNotExpanded                       As BOOL            ' IN: TRUE/FALSE to contract or expand, OUT: current state           
        curNavType                         As Integer         ' IN/OUT: UI to display in the navigational pane                     
        tabpos                             As Integer         ' IN/OUT: HHWIN_NAVTAB_TOP, HHWIN_NAVTAB_LEFT, or HHWIN_NAVTAB_BOTTOM
        idNotify                           As Integer         ' IN: ID to use for WM_NOTIFY messages                               
        tabOrder(0 To HH_MAX_TABS + 1 - 1) As Byte            ' IN/OUT: tab order: Contents, Index, Search, History, Favorites, Reserved 1-5, Custom tabs
        cHistory                           As Integer         ' IN/OUT: number of history items to keep (default is 30)
        pszJump1                           As LPCTSTR         ' Text for HHWIN_BUTTON_JUMP1                            
        pszJump2                           As LPCTSTR         ' Text for HHWIN_BUTTON_JUMP2                            
        pszUrlJump1                        As LPCTSTR         ' URL for HHWIN_BUTTON_JUMP1                             
        pszUrlJump2                        As LPCTSTR         ' URL for HHWIN_BUTTON_JUMP2                             
        rcMinSize                          As RECT            ' Minimum size for window (ignored in version 1)         
        cbInfoTypes                        As Integer         ' size of paInfoTypes;                                   
        pszCustomTabs                      As LPCTSTR         ' multiple zero-terminated strings                       
    End Type
    
    Type HH_WINTYPE  As tagHH_WINTYPE     
    Type PHH_WINTYPE As tagHH_WINTYPE Ptr 
    
    Enum 
        HHACT_TAB_CONTENTS
        HHACT_TAB_INDEX
        HHACT_TAB_SEARCH
        HHACT_TAB_HISTORY
        HHACT_TAB_FAVORITES
        
        HHACT_EXPAND
        HHACT_CONTRACT
        HHACT_BACK
        HHACT_FORWARD
        HHACT_STOP
        HHACT_REFRESH
        HHACT_HOME
        HHACT_SYNC
        HHACT_OPTIONS
        HHACT_PRINT
        HHACT_HIGHLIGHT
        HHACT_CUSTOMIZE
        HHACT_JUMP1
        HHACT_JUMP2
        HHACT_ZOOM
        HHACT_TOC_NEXT
        HHACT_TOC_PREV
        HHACT_NOTES
        
        HHACT_LAST_ENUM
    End Enum
    
    Type tagHHNTRACK
        hdr        As NMHDR          
        pszCurUrl  As PCSTR           ' Multi-byte, null-terminated string 
        idAction   As Integer         ' HHACT_ value                       
        phhWinType As HH_WINTYPE Ptr  ' Current window type structure      
    End Type
    
    Type HHNTRACK As tagHHNTRACK 
    
    Declare Function HtmlHelpA StdCall Alias "HtmlHelpA" (ByVal hwndCaller As HWND, ByVal pszFile As LPCSTR, ByVal uCommand As UINT, ByVal dwData As DWORD) As HWND
    Declare Function HtmlHelpW StdCall Alias "HtmlHelpW" (BYVAL hwndCaller As HWND, ByVal pszFile As LPCWSTR, ByVal uCommand As UINT, ByVal dwData As DWORD) As HWND
    
    #Ifdef UNICODE
        #Define HtmlHelp HtmlHelpW
    #Else
        #Define HtmlHelp HtmlHelpA
    #EndIf
    
    
    ' Use the following for GetProcAddress to load from hhctrl.ocx
    #Define ATOM_HTMLHELP_API_ANSI    Cast (LPTSTR, CUInt (14))
    #Define ATOM_HTMLHELP_API_UNICODE Cast (LPTSTR, CUInt (15))
    
    
    ' Global Control Properties. 
    Enum tagHH_GPROPID
        HH_GPROPID_SINGLETHREAD     = 1     ' VARIANT_BOOL: True for single thread                  
        HH_GPROPID_TOOLBAR_MARGIN   = 2     ' Long: Provides a left/right margin around the toolbar.
        HH_GPROPID_UI_LANGUAGE      = 3     ' Long: LangId of the UI.                               
        HH_GPROPID_CURRENT_SUBSET   = 4     ' BSTR: Current subset.                                 
        HH_GPROPID_CONTENT_LANGUAGE = 5     ' Long: LandId for desired content.                     
    End Enum
    
    Type HH_GPROPID As tagHH_GPROPID 
    

    ' Global Property structure
    #Ifdef __oaidl_h__
        ' #pragma pack(push, 8)
        
        Type tagHH_GLOBAL_PROPERTY
            id  As HH_GPROPID 
            Var As VARIANT  
        End Type
        
        Type HH_GLOBAL_PROPERTY As tagHH_GLOBAL_PROPERTY 
        
        ' #pragma pack(pop)
    #EndIf ' __oaidl_h__
    
    ' #ifdef __cplusplus
    ' } from removed "extern" block
    ' #endif

#EndIf ' __HTMLHELP_H__

#Ifdef __FB_WIN32__
    #Pragma pop(msbitfields)
#EndIf 

' Translated at 12-09-09 12:56:37, by h_2_bi (version 0.2.1,
' released under GPLv3 by Thomas[ dot ]Freiherr{ at }gmx[ dot ]net)
