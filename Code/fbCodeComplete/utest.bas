
#Define unicode

#Include "unicode.bi"


Dim s As TString Ptr = Allocate(6 * SizeOf(TChar))
*s = TStr("Hallo")

Print *s

DeAllocate(s)

Sleep
