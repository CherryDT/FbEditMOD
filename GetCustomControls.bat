@echo off

Set outd=.\Build\

Copy Code\FbEditDLL\Dll\FbEdit.dll %outd%

Copy Code\RACodeComplete\Dll\RACodeComplete.dll %outd%
Copy Code\RAFile\Dll\RAFile.dll %outd%
Copy Code\RAGrid\Dll\RAGrid.dll %outd%
Copy Code\RAProperty\Dll\RAProperty.dll %outd%
Copy Code\RAResEd\Dll\RAResEd.dll %outd%
Copy Code\RAEdit\Dll\RAEdit.dll %outd%
Copy Code\RAHexEd\Dll\RAHexEd.dll %outd%
Copy Code\Other\SpreadSheet\SprSht.dll %outd%

Copy Code\Samples\CustCtrl\FBEPictView\FBEPictView.dll %outd%
Copy Code\Samples\CustCtrl\FBEVideo\FBEVideo.dll %outd%
Copy Code\Samples\CustCtrl\FBEWeb\FBEWeb.dll %outd%
