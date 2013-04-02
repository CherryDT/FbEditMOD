@echo off

Set outd=.\Build\

MkDir %outd%\Addins
Mkdir %outd%\Addins\Help

Copy Code\Addins\Beautify\Beautify.dll %outd%\Addins\
Copy Code\Addins\Beautify\Beautify.txt %outd%\Addins\Help\

Copy Code\Addins\AdvEdit\AdvEdit.dll %outd%\Addins\
Copy Code\Addins\AdvEdit\AdvEdit.txt %outd%\Addins\Help\

Copy Code\Addins\SnipletAddin\SnipletAddin.dll %outd%\Addins\
Copy Code\Addins\SnipletAddin\SnipletAddin.txt %outd%\Addins\Help\

Copy Code\Addins\CustomFontAddin\CustomFontAddin.dll %outd%\Addins\
Copy Code\Addins\CustomFontAddin\CustomFontAddin.txt %outd%\Addins\Help\

Copy Code\Addins\FBFileAssociation\FBFileAssociation.dll %outd%\Addins\
Copy Code\Addins\FBFileAssociation\FBFileAssociation.txt %outd%\Addins\Help\

Copy Code\Addins\FileTabStyle\FileTabStyle.dll %outd%\Addins\
Copy Code\Addins\FileTabStyle\src\FileTabStyle.txt %outd%\Addins\Help\

Copy Code\Addins\Toolbar\Toolbar.dll %outd%\Addins\
Copy Code\Addins\Toolbar\Toolbar.txt %outd%\Addins\Help\

Copy Code\Addins\TortoiseSVN\TortoiseSVN.dll %outd%\Addins\
Copy Code\Addins\TortoiseSVN\TortoiseSVN.txt %outd%\Addins\Help\

Copy "Code\Addins\Base Calc\Base Calc.dll" %outd%\Addins\
Copy "Code\Addins\Base Calc\Base Calc.txt" %outd%\Addins\Help\

Copy Code\Addins\FbShowVars\Build\FbShowVars.dll %outd%\Addins\
Copy Code\Addins\FbShowVars\FbShowVars.txt %outd%\Addins\Help\

Copy Code\Addins\Toolbar\Toolbar.dll %outd%\Addins\
Copy Code\Addins\Toolbar\Toolbar.txt %outd%\Addins\Help\

Copy Code\Addins\ProjectZip\ProjectZip.dll %outd%\Addins\
Copy Code\Addins\ProjectZip\ProjectZip.txt %outd%\Addins\Help\

Copy Code\Addins\ReallyRad\ReallyRad.dll %outd%\Addins\
Copy Code\Addins\ReallyRad\ReallyRad.txt %outd%\Addins\Help\

Copy Code\Addins\QuickEval\QuickEval.dll %outd%\Addins\
Copy Code\Addins\QuickEval\QuickEval.txt %outd%\Addins\Help\

Copy Code\Addins\FbDebug\FbDebug.dll %outd%\Addins\
Copy Code\Addins\FbDebug\FbDebug.txt %outd%\Addins\Help\

Copy Code\Addins\HelpAddin\HelpAddin.dll %outd%\Addins\
Copy Code\Addins\HelpAddin\HelpAddin.txt %outd%\Addins\Help\

Copy Code\Addins\FbEditLite\FbEditLite.dll %outd%\Addins\
Copy Code\Addins\FbEditLite\FbEditLite.txt %outd%\Addins\Help\

Copy Code\Addins\UndoSave\UndoSave.dll %outd%\Addins\
Copy Code\Addins\UndoSave\UndoSave.txt %outd%\Addins\Help\

Copy Code\Addins\UpdateChecker\UpdateChecker.dll %outd%\Addins\
Copy Code\Addins\UpdateChecker\UpdateChecker.txt %outd%\Addins\Help\

Copy Code\Addins\ChartabDBCS\ChartabDBCS.dll %outd%\Addins\
Copy Code\Addins\ChartabDBCS\ChartabDBCS.txt %outd%\Addins\Help\
