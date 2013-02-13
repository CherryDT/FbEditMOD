

#Include Once "windows.bi"

#Include Once "Inc\RAProperty.bi"

#Include Once "Inc\Addins.bi"
#Include Once "Inc\FbEdit.bi"
#Include Once "Inc\FileIO.bi"
#Include Once "Inc\Project.bi"
#Include Once "Inc\SpecHandling.bi"
#Include Once "Inc\TabTool.bi"

#Include Once "Inc\Property.bi"
#Include Once "Inc\showvars.bi"


Sub SetPropertyDirty (ByVal hWin As HWND)
    
    If GetWindowLong (hWin, GWL_ID) = IDC_CODEED Then
    	SetWindowLong hWin, GWL_USERDATA, 2
    	PO_Changed = TRUE 
    EndIf
    
End Sub

Function ParseFile OverLoad (ByVal hEdit As HWND) As Integer
    
    Dim Success  As Integer = FALSE
    Dim EditMode As Long    = Any
    Dim hMem     As HGLOBAL = Any 
        
	EditMode = GetWindowLong (hEdit, GWL_ID)
	
	If EditMode = IDC_CODEED Then
		hMem = GetFileMem (hEdit)
		If hMem Then
			SetWindowLong hEdit, GWL_USERDATA, 0
			SendMessage ah.hpr, PRM_PARSEFILE, Cast (WPARAM, hEdit), Cast (LPARAM, hMem)
			GlobalFree hMem
		    Success = TRUE 
		EndIf 
	EndIf
    
    Return Success

End Function

Function ParseFile OverLoad (ByRef sFile As ZString) As Integer

	Dim hMem     As HGLOBAL = Any 
	Dim hEdit    As HWND    = Any 
	Dim FileID   As Integer = Any 
    Dim Success  As Integer = FALSE

	hEdit = GetEditWindowBySpec (sFile)
	
	If hEdit Then
	    Success = ParseFile (hEdit)
	Else    
		hMem = GetFileMem (sFile)
		If hMem Then
			FileID = GetFileID (sFile)
			' FileID = 0 -> no project file and not loaded (should never happen)
			If FileID = 0 Then FileID = -1 
			SendMessage ah.hpr, PRM_PARSEFILE, FileID, Cast (LPARAM, hMem)
			GlobalFree hMem
			Success = TRUE 
		EndIf
	EndIf
    
    Return Success

End Function

Sub UpdateProperty
	
	Dim    tci           As TCITEM
	Dim    EditMode      As Long               = Any
	Dim    nLen          As Integer            = Any
	Dim    hMem          As HGLOBAL            = Any 
	Dim    i             As Integer            = Any 
	Dim    FileSpec      As ZString * MAX_PATH = Any
	Dim    nInx          As Integer            = Any
	Dim    nMiss         As Integer            = Any
	Dim    BaseIdx       As Integer            = Any
    Dim    Success       As Integer            = Any  
	Dim    hEdit         As HWND               = Any 
	Dim    Owner         As HWND               = Any 
	Dim    Changed       As BOOL               = FALSE  
	       
	
	Select Case SendMessage (ah.hpr, PRM_GETSELBUTTON, 0, 0)
	Case 1   ' current tab
        If POL_Changed Then                                             ' OpenProject clears word list (LoadApiFiles)
  		    SendMessage ah.hpr, PRM_DELPROPERTY, 0, 0
    	    If GetWindowLong (ah.hred, GWL_ID) = IDC_CODEED Then 
		        ParseFile ah.hred
    	    EndIf		
    	    SendMessage ah.hpr, PRM_SELOWNER, Cast (WPARAM, ah.hred), 0
        Else
    	    If GetWindowLong (ah.hred, GWL_ID) = IDC_CODEED Then 
    	        If GetWindowLong (ah.hred, GWL_USERDATA) = 2 _
    	        OrElse SendMessage (ah.hpr, PRM_GETCURRENTOWNER, 0, 0) <> ah.hred Then
    	            SendMessage ah.hpr, PRM_DELPROPERTY, 0, 0           ' Cast (WPARAM, ah.hred), 0
    		        ParseFile ah.hred
    		        SendMessage ah.hpr, PRM_SELOWNER, Cast (WPARAM, ah.hred), 0
    	        'Else 
    	        '   Properties ok, nothing to do
    	        EndIf    
    	    Else
        	    SendMessage ah.hpr, PRM_DELPROPERTY, 0, 0               ' Cast (WPARAM, ah.hred), 0
        	    SendMessage ah.hpr, PRM_SELOWNER, 0, 0                  ' Cast (WPARAM, ah.hred), 0
    	    EndIf		
        EndIf
	Case 2   ' all CODEED tabs
        
        If POL_Changed Then
   		    SendMessage ah.hpr, PRM_DELPROPERTY, 0, 0
    		tci.mask = TCIF_PARAM
    		For i = 0 To 999
    			If SendMessage (ah.htabtool, TCM_GETITEM, i, Cast (LPARAM, @tci)) Then
            	    If GetWindowLong (pTABMEM->hedit, GWL_ID) = IDC_CODEED Then
        				Success = ParseFile (pTABMEM->hedit)
        				If Success = FALSE Then Exit For
            	    EndIf    
    			Else
    				Exit For
    			EndIf
    		Next
    		SendMessage ah.hpr, PRM_SELOWNER, 0, 0
        Else
    		If PO_Changed Then
        		tci.mask = TCIF_PARAM
        		For i = 0 To 999
        			If SendMessage (ah.htabtool, TCM_GETITEM, i, Cast (LPARAM, @tci)) Then
                	    If GetWindowLong (pTABMEM->hedit, GWL_ID) = IDC_CODEED Then
                	        If GetWindowLong (pTABMEM->hedit, GWL_USERDATA) = 2 Then 
                                SendMessage ah.hpr, PRM_DELPROPERTY, Cast (WPARAM, pTABMEM->hedit), 0
                				Changed = TRUE 
                				Success = ParseFile (pTABMEM->hedit)
                				If Success = FALSE Then Exit For
                	        EndIf
                	    EndIf    
        			Else
        				Exit For
        			EndIf
        		Next
        		If Changed Then SendMessage ah.hpr, PRM_SELOWNER, 0, 0
    		EndIf
        EndIf

	Case 3	 ' all project files (incl. not loaded)
 		
 		If POL_Changed Then
		    SendMessage ah.hpr, PRM_DELPROPERTY, 0, 0
 		    If fProject Then
                For BaseIdx = 0 To 1000 Step 1000    
                    nMiss = 0
                	For nInx = BaseIdx + 1 To BaseIdx + 256
                		
                		GetPrivateProfileString @"File", Str (nInx), NULL, @FileSpec, SizeOf (FileSpec), @ad.ProjectFile
                                    
                		If FileSpec[0] Then
                            FileSpec = MakeProjectFileName (FileSpec)
                	        hEdit = GetEditWindowBySpec (FileSpec)
    
                	        If hEdit Then        ' loaded
                        	    If GetWindowLong (hEdit, GWL_ID) = IDC_CODEED Then
                    				Success = ParseFile (hEdit)
                    				If Success = FALSE Then Exit For, For 
                        	    EndIf 
                	        Else                 ' not loaded
            				    If GetFBEFileType (FileSpec) = FBFT_CODE Then                      
                                    Success = ParseFile (FileSpec)
                                    If Success = FALSE Then Exit For, For
            				    EndIf
                	        EndIf    
        				    
                            nMiss = 0
                		Else
                	        If nMiss > MAX_MISS Then Exit For
                		    nMiss += 1
                		EndIf 
                	Next
                Next
    		EndIf
    		SendMessage ah.hpr, PRM_SELOWNER, 0, 0
 		Else
 		    If PO_Changed Then
        		tci.mask = TCIF_PARAM
        		For i = 0 To 999
        			If SendMessage (ah.htabtool, TCM_GETITEM, i, Cast (LPARAM, @tci)) Then
                	    If pTABMEM->profileinx  Then 
                    	    If GetWindowLong (pTABMEM->hedit, GWL_ID) = IDC_CODEED Then
                    	        If GetWindowLong (pTABMEM->hedit, GWL_USERDATA) = 2 Then 
                                    SendMessage ah.hpr, PRM_DELPROPERTY, Cast (WPARAM, pTABMEM->hedit), 0
                    				Changed = TRUE 
                    				Success = ParseFile (pTABMEM->hedit)
                    				If Success = FALSE Then Exit For
                    	        EndIf
                    	    EndIf    
                        EndIf 
        			Else
        				Exit For
        			EndIf
        		Next
        		If Changed Then SendMessage ah.hpr, PRM_SELOWNER, 0, 0
    		EndIf
 		EndIf
	End Select
	
	POL_Changed = FALSE	
    PO_Changed = FALSE         ' scope is rescanned 
    
End Sub

'Sub UpdateFileProperty
'	Dim nInx As Integer
'
'	If fProject Then
'		nInx=GetFileID(ad.filename)
'		If nInx Then
'			SendMessage(ah.hpr,PRM_SELOWNER,nInx,0)
'		Else
'		    If ah.hred Then
'		    	SendMessage(ah.hpr,PRM_SELOWNER,Cast(Integer,ah.hred),0)
'		    Else
'		    	SendMessage(ah.hpr,PRM_SELOWNER,-1,0)
'		    EndIf 	
'		EndIf 	
'	Else
'		SendMessage(ah.hpr,PRM_SELOWNER,Cast(Integer,ah.hred),0)
'	EndIf
'    
'    SendMessage(ah.hpr,PRM_REFRESHLIST,0,0)
'
'End Sub

