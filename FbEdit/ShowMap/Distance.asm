
.const

rad2deg			REAL8 57.29577951308232088
deg2rad			REAL8 0.017453292519943334
deg2metres		REAL8 111194.92664455897
half			REAL8 0.5
dqdiv			REAL8 1000000.0
dq180			REAL8 180.0

.code

Distance proc latA:REAL8,lonA:REAL8,latB:REAL8,lonB:REAL8,lpfDist:DWORD

	fld     REAL8 ptr [latB]
	fadd    REAL8 ptr [latA]
	fmul    REAL8 ptr [half]
	fmul    REAL8 ptr [deg2rad]
	fcos
	fld     REAL8 ptr [lonA]
	fsub    REAL8 ptr [lonB]
	fmulp   st(1),st
	fmul    REAL8 ptr [deg2metres]
	fmul    st(0),st
	fld     REAL8 ptr [latA]
	fsub    REAL8 ptr [latB]
	fmul    REAL8 ptr [deg2metres]
	fmul    st(0),st
	faddp   st(1),st
	fsqrt
	mov		eax,lpfDist
	fstp	REAL10 ptr [eax]
	ret

Distance endp

;Bearing=ATAN2(SIN(lon2-lon1)*COS(lat2),COS(lat1)*SIN(lat2)-SIN(lat1)*COS(lat2)*COS(lon2-lon1)
Bearing proc latA:REAL8,lonA:REAL8,latB:REAL8,lonB:REAL8,lpfBear:DWORD

	;Convert to radians
	fld     REAL8 ptr [latA]
	fmul    REAL8 ptr [deg2rad]
	fstp	REAL8 ptr [latA]
	fld     REAL8 ptr [latB]
	fmul    REAL8 ptr [deg2rad]
	fstp	REAL8 ptr [latB]
	fld     REAL8 ptr [lonA]
	fmul    REAL8 ptr [deg2rad]
	fstp	REAL8 ptr [lonA]
	fld     REAL8 ptr [lonB]
	fmul    REAL8 ptr [deg2rad]
	fstp	REAL8 ptr [lonB]

	;x=SIN(lonB-lonA)*COS(latB)
	fld     REAL8 ptr [lonB]
	fsub    REAL8 ptr [lonA]
	fsin
	fld		REAL8 ptr [latB]
	fcos
	fmulp	st(1),st
	;y=COS(latA)*SIN(latB)-SIN(latA)*COS(latB)*COS(lonB-lonA)
	fld     REAL8 ptr [latA]
	fcos
	fld     REAL8 ptr [latB]
	fsin
	fmulp	st(1),st
	fld     REAL8 ptr [latA]
	fsin
	fld     REAL8 ptr [latB]
	fcos
	fmulp	st(1),st
	fld     REAL8 ptr [lonB]
	fsub    REAL8 ptr [lonA]
	fcos
	fmulp	st(1),st
	fsubp	st(1),st
	;ATAN2(x,y) NOTE this will fail if y=0
	fdivp	st(1),st
	fld1
	fpatan
	;Convert to degrees
	fld		REAL8 ptr [rad2deg]
	fmulp	st(1),st
	;Set result
	mov		edx,lpfBear
	fstp	REAL10 ptr [edx]
	ret

Bearing endp

;In:  Integer Longitude,Lattitude
;Out: REAL10 distance and bearing
BearingDistanceInt proc iLonA:DWORD,iLatA:DWORD,iLonB:DWORD,iLatB:DWORD,lpfDist:DWORD,lpfBear:DWORD
	LOCAL	fLatA:REAL8
	LOCAL	fLonA:REAL8
	LOCAL	fLatB:REAL8
	LOCAL	fLonB:REAL8

	;Convert to decimal by dividing with 1 000 000
	fild	iLonA
	fdiv	dqdiv
	fstp	fLonA
	fild	iLatA
	fdiv	dqdiv
	fstp	fLatA
	fild	iLonB
	fdiv	dqdiv
	fstp	fLonB
	fild	iLatB
	fdiv	dqdiv
	fstp	fLatB
	;Get distance
	invoke Distance,fLatA,fLonA,fLatB,fLonB,lpfDist
	;Get Bearing
	invoke Bearing,fLatA,fLonA,fLatB,fLonB,lpfBear
	mov		eax,lpfBear
	fld		REAL10 PTR [eax]
	mov		ecx,iLonA
	mov		edx,iLatA
	.if ecx<=iLonB
		;0 to 180
		.if edx>iLatB
			;90 to 180
			fadd	REAL8 ptr [dq180]
		.endif
	.else
		;180 to 360
		fadd	REAL8 ptr [dq180]
		.if edx<=iLatB
			;270 to 360
			fadd	REAL8 ptr [dq180]
		.endif
	.endif
	fstp	REAL10 PTR [eax]
	ret

BearingDistanceInt endp
