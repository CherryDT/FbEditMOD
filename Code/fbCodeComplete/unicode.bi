#Ifdef UNICODE
	#Define TString WString
	#Define TStr WStr
	#Define TChar UShort
	#Define toTLower towlower
	#Define toTUpper towupper
	#Define isTLower iswlower
	#Define isTUpper iswupper
#Else
	#Define TString ZString
	#Define TStr Str
	#Define TChar UByte
	#Define toTLower tolower
	#Define toTUpper toupper
	#Define isTLower islower
	#Define isTUpper isupper
#EndIf
