Dim aInt As Integer
Dim Shared aSInt As Integer

Sub aSub (aParam As Integer) 
	
End Sub

Function aFunc(aParam As Integer) As integer
	Static aLocalStatic As Integer
	Dim aLocal As Integer
	
End Function

Type aType
	
	Private:
	a As Integer
	
	Public:
	b As Integer
	c As ZString ptr
	
End Type

#Define aDef test


Dim aTypeInst As aType

aTypeInst.b = 1

Dim aTypePtr As aType Ptr


Type aPType As Integer

Const aConst = 1

Static aStatic As integer

Union aUnion
 a As Integer
End Union

Namespace aNamespace
	Dim aVar As Integer
End Namespace

Dim aPtr As Integer Ptr

Dim aDelegate As Function(a As Integer) As Integer

Scope
	Dim aScropeVar As Integer
	
End Scope


#Macro amacro()
	
#EndMacro

Enum aEnum
	a = 1
	b = 2
End Enum


