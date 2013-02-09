
.const

FontCharset			dd FC00,FC01,FC02,FC03,FC04,FC05,FC06,FC07,FC08,FC09,FC0A,FC0B,FC0C,FC0D,FC0E,FC0F
					dd FC10,FC11,FC12,FC13,FC14,FC15,FC16,FC17,FC18,FC19,FC1A,FC1B,FC1C,FC1D,FC1E,FC1F
					dd FC20,FC21,FC22,FC23,FC24,FC25,FC26,FC27,FC28,FC29,FC2A,FC2B,FC2C,FC2D,FC2E,FC2F
					dd FC30,FC31,FC32,FC33,FC34,FC35,FC36,FC37,FC38,FC39,FC3A,FC3B,FC3C,FC3D,FC3E,FC3F
					dd FC40,FC41,FC42,FC43,FC44,FC45,FC46,FC47,FC48,FC49,FC4A,FC4B,FC4C,FC4D,FC4E,FC4F
					dd FC50,FC51,FC52,FC53,FC54,FC55,FC56,FC57,FC58,FC59,FC5A,FC5B,FC5C,FC5D,FC5E,FC5F
					dd FC60,FC61,FC62,FC63,FC64,FC65,FC66,FC67,FC68,FC69,FC6A,FC6B,FC6C,FC6D,FC6E,FC6F
					dd FC70,FC71,FC72,FC73,FC74,FC75,FC76,FC77,FC78,FC79,FC7A,FC7B,FC7C,FC7D,FC7E,FC7F
					dd FC80,FC81,FC82,FC83,FC84,FC85,FC86,FC87,FC88,FC89,FC8A,FC8B,FC8C,FC8D,FC8E,FC8F
					dd FC90,FC91,FC92,FC93,FC94,FC95,FC96,FC97,FC98,FC99,FC9A,FC9B,FC9C,FC9D,FC9E,FC9F
					dd FCA0,FCA1,FCA2,FCA3,FCA4,FCA5,FCA6,FCA7,FCA8,FCA9,FCAA,FCAB,FCAC,FCAD,FCAE,FCAF
					dd FCB0,FCB1,FCB2,FCB3,FCB4,FCB5,FCB6,FCB7,FCB8,FCB9,FCBA,FCBB,FCBC,FCBD,FCBE,FCBF
					dd FCC0,FCC1,FCC2,FCC3,FCC4,FCC5,FCC6,FCC7,FCC8,FCC9,FCCA,FCCB,FCCC,FCCD,FCCE,FCCF
					dd FCD0,FCD1,FCD2,FCD3,FCD4,FCD5,FCD6,FCD7,FCD8,FCD9,FCDA,FCDB,FCDC,FCDD,FCDE,FCDF
					dd FCE0,FCE1,FCE2,FCE3,FCE4,FCE5,FCE6,FCE7,FCE8,FCE9,FCEA,FCEB,FCEC,FCED,FCEE,FCEF
					dd FCF0,FCF1,FCF2,FCF3,FCF4,FCF5,FCF6,FCF7,FCF8,FCF9,FCFA,FCFB,FCFC,FCFD,FCFE,FCFF

;00h
FC00				db 0,0
FC01				db 0,0
FC02				db 0,0
FC03				db 0,0
FC04				db 0,0
FC05				db 0,0
FC06				db 0,0
FC07				db 0,0
FC08				db 0,0
FC09				db 0,0
FC0A				db 0,0
FC0B				db 0,0
FC0C				db 0,0
FC0D				db 0,0
FC0E				db 0,0
FC0F				db 0,0
;10h
FC10				db 0,0
FC11				db 0,0
FC12				db 0,0
FC13				db 0,0
FC14				db 0,0
FC15				db 0,0
FC16				db 0,0
FC17				db 0,0
FC18				db 0,0
FC19				db 0,0
FC1A				db 0,0
FC1B				db 0,0
FC1C				db 0,0
FC1D				db 0,0
FC1E				db 0,0
FC1F				db 0,0
;20h
FC20				db 0,0
FC21				db 4,1,4,8,0,4,11,4,11,0,0
FC22				db 3,1,3,3,0,5,1,5,3,0,0
FC23				db 2,1,2,11,0,6,1,6,11,0,1,3,7,3,0,1,9,7,9,0,0
FC24				db 1,9,2,10,6,10,7,9,7,7,6,6,2,6,1,5,1,3,2,2,6,2,7,3,0,4,1,4,11,0,0
FC25				db 2,1,3,1,4,2,4,3,3,4,2,4,1,3,1,2,2,1,0,7,2,1,10,0,5,8,6,8,7,9,7,10,6,11,5,11,4,10,4,9,5,8,0,0
FC26				db 7,11,1,3,1,2,2,1,3,1,4,2,4,3,3,4,1,8,1,10,2,11,4,11,7,6,0,0
FC27				db 5,1,4,3,0,0
FC28				db 5,1,3,4,3,8,5,11,0,0
FC29				db 3,1,5,4,5,8,3,11,0,0
FC2A				db 2,5,6,5,4,5,4,3,4,5,2,7,4,5,6,7,0,0
FC2B				db 4,3,4,7,4,5,2,5,6,5,0,0
FC2C				db 4,9,3,11,0,0
FC2D				db 2,5,6,5,0,0
FC2E				db 4,10,5,10,5,11,4,11,4,10,0,0
FC2F				db 7,1,1,11,0,0
;30h
FC30				db 3,1,5,1,7,5,7,7,5,11,3,11,1,7,1,5,3,1,0,0
FC31				db 3,3,5,1,5,11,0,0
FC32				db 1,2,2,1,6,1,7,2,7,5,1,9,1,11,7,11,0,0
FC33				db 1,2,2,1,6,1,7,2,7,5,6,6,5,6,6,6,7,7,7,10,6,11,2,11,1,10,0,0
FC34				db 6,1,6,11,0,6,1,1,7,7,7,0,0
FC35				db 7,1,1,1,1,5,6,5,7,6,7,10,6,11,2,11,1,10,0,0
FC36				db 7,1,4,1,1,4,1,10,2,11,6,11,7,10,7,6,6,5,1,5,0,0
FC37				db 1,1,7,1,4,6,4,11,0,0
FC38				db 2,1,6,1,7,2,7,5,6,6,2,6,1,5,1,2,2,1,0,2,6,1,7,1,10,2,11,6,11,7,10,7,7,6,6,0,0
FC39				db 7,7,2,7,1,6,1,2,2,1,6,1,7,2,7,8,4,11,1,11,0,0
FC3A				db 4,4,4,4,0,4,10,4,10,0,0
FC3B				db 4,7,4,7,0,4,9,3,11,0,0
FC3C				db 7,2,1,6,7,10,0,0
FC3D				db 1,4,7,4,0,1,7,7,7,0,0
FC3E				db 1,2,7,6,1,10,0,0
FC3F				db 1,2,2,1,6,1,7,2,7,5,6,6,4,8,4,9,0,4,11,4,11,0,0
;40h
FC40				db 7,4,6,4,5,5,5,6,6,7,7,7,7,2,6,1,2,1,1,2,1,10,2,11,6,11,7,10,0,0
FC41				db 1,11,1,4,4,1,7,4,7,11,7,8,1,8,0,0
FC42				db 1,11,1,1,6,1,7,2,7,5,6,6,1,6,6,6,7,7,7,10,6,11,1,11,0,0
FC43				db 7,9,7,10,6,11,2,11,1,10,1,2,2,1,6,1,7,2,7,3,0,0
FC44				db 2,11,2,1,1,1,6,1,7,2,7,10,6,11,1,11,0,0
FC45				db 7,11,1,11,1,6,5,6,1,6,1,1,7,1,0,0
FC46				db 1,11,1,6,5,6,1,6,1,1,7,1,0,0
FC47				db 4,8,7,8,7,10,6,11,2,11,1,10,1,2,2,1,6,1,7,2,7,3,0,0
FC48				db 1,11,1,1,1,6,7,6,7,1,7,11,0,0
FC49				db 2,11,6,11,4,11,4,1,2,1,6,1,0,0
FC4A				db 1,10,2,11,4,11,5,10,5,1,3,1,7,1,0,0
FC4B				db 1,11,1,1,1,6,7,1,1,6,7,11,0,0
FC4C				db 7,11,1,11,1,1,0,0
FC4D				db 1,11,1,1,4,5,7,1,7,11,0,0
FC4E				db 1,11,1,1,7,11,7,1,0,0
FC4F				db 1,10,1,2,2,1,6,1,7,2,7,10,6,11,2,11,1,10,0,0
;50h
FC50				db 1,11,1,1,6,1,7,2,7,5,6,6,1,6,0,0
FC51				db 1,10,1,2,2,1,6,1,7,2,7,9,6,10,5,9,7,11,6,10,5,11,2,11,1,10,0,0
FC52				db 1,11,1,1,6,1,7,2,7,5,6,6,1,6,3,6,7,11,0,0
FC53				db 1,10,2,11,6,11,7,10,7,7,6,6,2,6,1,5,1,2,2,1,6,1,7,2,0,0
FC54				db 4,11,4,1,1,1,7,1,0,0
FC55				db 1,1,1,10,2,11,6,11,7,10,7,1,0,0
FC56				db 1,1,1,8,4,11,7,8,7,1,0,0
FC57				db 1,1,1,10,2,11,4,8,6,11,7,10,7,1,0,0
FC58				db 1,1,7,11,4,6,7,1,1,11,0,0
FC59				db 1,1,4,5,7,1,4,5,4,11,0,0
FC5A				db 1,1,7,1,1,11,7,11,0,0
FC5B				db 6,11,2,11,2,1,6,1,0,0
FC5C				db 1,1,7,11,0,0
FC5D				db 2,11,6,11,6,1,2,1,0,0
FC5E				db 2,5,4,1,6,5,0,0
FC5F				db 1,11,7,11,0,0
;60h
FC60				db 3,1,4,3,0,0
FC61				db 1,4,6,4,7,5,7,11,0,7,9,5,11,2,11,1,10,1,8,2,7,7,7,0,0
FC62				db 1,1,1,11,1,9,3,11,6,11,7,10,7,6,6,5,3,5,1,7,0,0
FC63				db 7,10,6,11,2,11,1,10,1,6,2,5,6,5,7,6,0,0
FC64				db 7,9,5,11,2,11,1,10,1,6,2,5,5,5,7,7,0,7,1,7,11,0,0
FC65				db 1,8,7,8,7,7,6,5,2,5,1,7,1,10,2,11,6,11,7,10,0,0
FC66				db 3,11,3,2,4,1,6,1,7,2,0,1,6,5,6,0,0
FC67				db 2,15,6,15,7,14,7,5,0,7,9,5,11,2,11,1,10,1,6,2,5,5,5,7,7,0,0
FC68				db 1,11,1,1,0,1,7,3,5,6,5,7,6,7,11,0,0
FC69				db 4,11,4,4,0,4,1,4,1,0,0
FC6A				db 5,4,5,14,4,15,2,15,1,14,0,5,1,5,1,0,0
FC6B				db 1,11,1,1,0,7,11,2,8,7,5,0,0
FC6C				db 4,1,4,11,0,0
FC6D				db 1,11,1,5,1,6,2,5,6,5,7,6,7,11,0,4,5,4,11,0,0
FC6E				db 1,11,1,5,1,7,3,5,6,5,7,6,7,11,0,0
FC6F				db 1,10,1,6,2,5,6,5,7,6,7,10,6,11,2,11,1,10,0,0
;70h
FC70				db 1,15,1,5,0,1,7,3,5,6,5,7,6,7,10,6,11,3,11,1,9,0,0
FC71				db 7,15,7,5,0,7,9,5,11,2,11,1,10,1,6,2,5,5,5,7,7,0,0
FC72				db 1,11,1,5,1,7,3,5,6,5,7,6,0,0
FC73				db 1,11,6,11,7,10,7,9,6,8,2,8,1,7,1,6,2,5,7,5,0,0
FC74				db 3,1,3,10,4,11,6,11,7,10,0,1,5,5,5,0,0
FC75				db 1,5,1,10,2,11,5,11,7,9,7,5,7,11,0,0
FC76				db 1,5,4,11,7,5,0,0
FC77				db 1,5,1,10,2,11,4,9,6,11,7,10,7,5,0,0
FC78				db 1,5,7,11,0,7,5,1,11,0,0
FC79				db 2,15,6,15,7,14,7,5,0,1,5,1,10,2,11,5,11,7,9,0,0
FC7A				db 1,5,7,5,1,11,7,11,0,0
FC7B				db 5,11,4,11,3,10,3,6,2,6,3,6,3,2,4,1,5,1,0,0
FC7C				db 4,1,4,11,0,0
FC7D				db 2,11,3,11,4,10,4,6,5,6,4,6,4,2,3,1,2,1,0,0
FC7E				db 1,6,2,5,6,7,7,6,0,0
FC7F				db 0,0
;80h
FC80				db 0,0
FC81				db 0,0
FC82				db 0,0
FC83				db 0,0
FC84				db 0,0
FC85				db 0,0
FC86				db 0,0
FC87				db 0,0
FC88				db 0,0
FC89				db 0,0
FC8A				db 0,0
FC8B				db 0,0
FC8C				db 0,0
FC8D				db 0,0
FC8E				db 0,0
FC8F				db 0,0
;90h
FC90				db 0,0
FC91				db 0,0
FC92				db 0,0
FC93				db 0,0
FC94				db 0,0
FC95				db 0,0
FC96				db 0,0
FC97				db 0,0
FC98				db 0,0
FC99				db 0,0
FC9A				db 0,0
FC9B				db 0,0
FC9C				db 0,0
FC9D				db 0,0
FC9E				db 0,0
FC9F				db 0,0
;A0h
FCA0				db 0,0
FCA1				db 0,0
FCA2				db 0,0
FCA3				db 0,0
FCA4				db 0,0
FCA5				db 0,0
FCA6				db 0,0
FCA7				db 0,0
FCA8				db 0,0
FCA9				db 0,0
FCAA				db 0,0
FCAB				db 0,0
FCAC				db 0,0
FCAD				db 0,0
FCAE				db 0,0
FCAF				db 0,0
;B0h
FCB0				db 0,0
FCB1				db 0,0
FCB2				db 0,0
FCB3				db 0,0
FCB4				db 0,0
FCB5				db 0,0
FCB6				db 0,0
FCB7				db 0,0
FCB8				db 0,0
FCB9				db 0,0
FCBA				db 0,0
FCBB				db 0,0
FCBC				db 0,0
FCBD				db 0,0
FCBE				db 0,0
FCBF				db 0,0
;C0h
FCC0				db 0,0
FCC1				db 0,0
FCC2				db 0,0
FCC3				db 0,0
FCC4				db 0,0
FCC5				db 0,0
FCC6				db 0,0
FCC7				db 0,0
FCC8				db 0,0
FCC9				db 0,0
FCCA				db 0,0
FCCB				db 0,0
FCCC				db 0,0
FCCD				db 0,0
FCCE				db 0,0
FCCF				db 0,0
;D0h
FCD0				db 0,0
FCD1				db 0,0
FCD2				db 0,0
FCD3				db 0,0
FCD4				db 0,0
FCD5				db 0,0
FCD6				db 0,0
FCD7				db 0,0
FCD8				db 0,0
FCD9				db 0,0
FCDA				db 0,0
FCDB				db 0,0
FCDC				db 0,0
FCDD				db 0,0
FCDE				db 0,0
FCDF				db 0,0
;E0h
FCE0				db 0,0
FCE1				db 0,0
FCE2				db 0,0
FCE3				db 0,0
FCE4				db 0,0
FCE5				db 0,0
FCE6				db 0,0
FCE7				db 0,0
FCE8				db 0,0
FCE9				db 0,0
FCEA				db 0,0
FCEB				db 0,0
FCEC				db 0,0
FCED				db 0,0
FCEE				db 0,0
FCEF				db 0,0
;F0h
FCF0				db 0,0
FCF1				db 0,0
FCF2				db 0,0
FCF3				db 0,0
FCF4				db 0,0
FCF5				db 0,0
FCF6				db 0,0
FCF7				db 0,0
FCF8				db 0,0
FCF9				db 0,0
FCFA				db 0,0
FCFB				db 0,0
FCFC				db 0,0
FCFD				db 0,0
FCFE				db 0,0
FCFF				db 0,0

