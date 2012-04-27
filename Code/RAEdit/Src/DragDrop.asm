;MK_ALT						equ 20h

DROPEFFECT_NONE				equ	0
DROPEFFECT_COPY				equ	1
DROPEFFECT_MOVE				equ	2
;DROPEFFECT_LINK			equ	4
;DROPEFFECT_SCROLL			equ	80000000h

TYMED_HGLOBAL				equ	1
;TYMED_FILE					equ	2
;TYMED_ISTREAM				equ	4
;TYMED_ISTORAGE				equ	8
;TYMED_GDI					equ	16
;TYMED_MFPICT				equ	32
;TYMED_ENHMF				equ	64
;TYMED_NULL					equ	0

DATADIR_GET					equ	1
DATADIR_SET					equ	2

STDMETHOD MACRO name,argl:VARARG
    LOCAL	@tmp_a
    LOCAL	@tmp_b
    @tmp_a TYPEDEF PROTO this_:DWORD,argl
    @tmp_b TYPEDEF PTR @tmp_a
    name @tmp_b ?
ENDM

;Structures	used by	an IDataObject
STGMEDIUM struct
	tymed					dd ?
	hGlobal					dd ?
	pUnkForRelease			dd ?
STGMEDIUM ends

FORMATETC struct
	cfFormat				dd ?
	lptd					dd ?
	dwAspect				dd ?
	lindex					dd ?
	tymed					dd ?
FORMATETC ends

;--------------------------------------------------------------------------------
;IUnknown
;--------------------------------------------------------------------------------
IUnknown struct
	STDMETHOD QueryInterface,:DWORD,:DWORD
	STDMETHOD AddRef
	STDMETHOD Release
IUnknown ends

;--------------------------------------------------------------------------------
;IDropTarget
;--------------------------------------------------------------------------------
IDropTarget	struct
	;IUnknown methods
	iu						IUnknown <?>
	;IDropTarget methods
	STDMETHOD DragEnter,:DWORD,:DWORD,:DWORD,:DWORD
	STDMETHOD DragOver,:DWORD,:DWORD,:DWORD
	STDMETHOD DragLeave
	STDMETHOD Drop,:DWORD,:DWORD,:DWORD,:DWORD
	;Additional	data
	refcount				dd ?
	valid					dd ?
	hwnd					dd ?
	cp						dd ?
IDropTarget	ends

;--------------------------------------------------------------------------------
;IDropSource
;--------------------------------------------------------------------------------
IDropSource	struct
	;IUnknown methods
	iu						IUnknown <?>
	;IDropSource methods
	STDMETHOD QueryContinueDrag,:DWORD,:DWORD
	STDMETHOD GiveFeedback,:DWORD
	;Additional	data
	refcount				dd ?
IDropSource	ends

;--------------------------------------------------------------------------------
;IDataObject
;--------------------------------------------------------------------------------
IDataObject	struct
	;IUnknown methods
	iu						IUnknown <?>
	;IDataObject methods
	STDMETHOD GetData,:DWORD,:DWORD
	STDMETHOD GetDataHere,:DWORD,:DWORD
	STDMETHOD QueryGetData,:DWORD
	STDMETHOD GetCanonicalFormatEtc,:DWORD,:DWORD
	STDMETHOD SetData,:DWORD,:DWORD,:DWORD
	STDMETHOD EnumFormatEtc,:DWORD,:DWORD
	STDMETHOD DAdvise,:DWORD,:DWORD,:DWORD,:DWORD
	STDMETHOD DUnadvise,:DWORD
	STDMETHOD EnumDAdvise,:DWORD
	;Additional	data
	refcount				dd ?
IDataObject	ends

;--------------------------------------------------------------------------------
;IEnumFORMATETC
;--------------------------------------------------------------------------------
IEnumFORMATETC struct
	;IUnknown methods
	iu						IUnknown <?>
	;IEnumFORMATETC	methods
	STDMETHOD Next,:DWORD,:DWORD,:DWORD
	STDMETHOD Skip,:DWORD
	STDMETHOD Reset
	STDMETHOD Clone,:DWORD
	;Additional	data
	refcount				dd ?
	ifmt					dd ?
	ifmtmax					dd ?
IEnumFORMATETC ends

.const

IID_IUnknown				GUID <000000000H,00000H,00000H,<0C0H,000H,000H,000H,000H,000H,000H,046H>>
IID_IDropTarget				GUID <000000122H,00000H,00000H,<0C0H,000H,000H,000H,000H,000H,000H,046H>>
IID_IDropSource				GUID <000000121H,00000H,00000H,<0C0H,000H,000H,000H,000H,000H,000H,046H>>
IID_IDataObject				GUID <00000010EH,00000H,00000H,<0C0H,000H,000H,000H,000H,000H,000H,046H>>
IID_IEnumFORMATETC			GUID <000000103H,00000H,00000H,<0C0H,000H,000H,000H,000H,000H,000H,046H>>

.data

vtIDropTarget				IDropTarget	<<IDropTarget_QueryInterface,IDropTarget_AddRef,IDropTarget_Release>,IDropTarget_DragEnter,IDropTarget_DragOver,IDropTarget_DragLeave,IDropTarget_Drop,0,0,0,0>
pIDropTarget				dd vtIDropTarget

vtIDropSource				IDropSource	<<IDropSource_QueryInterface,IDropSource_AddRef,IDropSource_Release>,IDropSource_QueryContinueDrag,IDropSource_GiveFeedback,0>
pIDropSource				dd vtIDropSource

vtIDataObject				IDataObject	<<IDO_QueryInterface,IDO_AddRef,IDO_Release>,IDO_GetData,IDO_GetDataHere,IDO_QueryGetData,IDO_GetCanonicalFormatEtc,IDO_SetData,IDO_EnumFormatEtc,IDO_DAdvise,IDO_DUnadvise,IDO_EnumDAdvise,0>
pIDataObject				dd vtIDataObject

vtIEnumFORMATETC			IEnumFORMATETC <<IEnumFORMATETC_QueryInterface,IEnumFORMATETC_AddRef,IEnumFORMATETC_Release>,IEnumFORMATETC_Next,IEnumFORMATETC_Skip,IEnumFORMATETC_Reset,IEnumFORMATETC_Clone,0,0,1>
pIEnumFORMATETC				dd vtIEnumFORMATETC

.code

IsEqualGUID	proc uses ecx esi edi,rguid1,rguid2

	xor		eax,eax
	mov		esi,rguid1
	mov		edi,rguid2
	mov		ecx,sizeof GUID/4
	repe	cmpsd
	setz	al
	ret

IsEqualGUID	endp

;IDropTarget methods
IDropTarget_QueryInterface proc	pthis,iid,ppvObject

;PrintText 'IDropTarget_QueryInterface'
	invoke IsEqualGUID,iid,offset IID_IDropTarget
	.if	!eax
		invoke IsEqualGUID,iid,offset IID_IUnknown
	.endif
	mov		edx,ppvObject
	.if	eax
		mov		eax,pthis
		mov		[edx],eax
		mov		edx,[eax]
		invoke [edx].IDropTarget.iu.AddRef,eax
		mov		eax,S_OK
	.else
		mov		dword ptr [edx],0
		mov		eax,E_NOINTERFACE
	.endif
	ret

IDropTarget_QueryInterface endp

IDropTarget_AddRef proc	pthis

;PrintText 'IDropTarget_AddRef'
	mov		eax,pthis
	mov		edx,[eax]
	inc		[edx].IDropTarget.refcount
	mov		eax,[edx].IDropTarget.refcount
	ret

IDropTarget_AddRef endp

IDropTarget_Release	proc pthis

;PrintText 'IDropTarget_Release'
	mov		eax,pthis
	mov		edx,[eax]
	.if [edx].IDropTarget.refcount
		dec		[edx].IDropTarget.refcount
	.endif
	mov		eax,[edx].IDropTarget.refcount
	ret

IDropTarget_Release	endp

IDropTarget_DragEnter proc uses	ebx	esi	edi,pthis,lpDataObject,grfKeyState,pt:POINT,lpdwEffect
	LOCAL	medium:STGMEDIUM
	LOCAL	fmte:FORMATETC

;PrintText 'IDropTarget_DragEnter'
	mov		esi,lpDataObject
	mov		ebx,lpdwEffect
	mov		edi,pthis
	mov		edi,[edi]

	mov		dword ptr [ebx],DROPEFFECT_NONE
	mov		[edi].IDropTarget.valid,FALSE
	mov		eax,E_INVALIDARG
	.if esi
		invoke WindowFromPoint,pt.x,pt.y
		push	eax
		mov		edx,eax
		invoke ScreenToClient,edx,addr pt
		pop		eax
		invoke ChildWindowFromPoint,eax,pt.x,pt.y
		mov		ebx,eax
		invoke GetWindowLong,ebx,0
		.if eax
			mov		[edi].IDropTarget.hwnd,ebx
			mov		ebx,eax
			.if !([ebx].EDIT.fstyle & STYLE_READONLY)
				mov		fmte.cfFormat,CF_TEXT
				mov		fmte.lptd,NULL
				mov		fmte.dwAspect,DVASPECT_CONTENT
				mov		fmte.lindex,-1
				mov		fmte.tymed,TYMED_HGLOBAL
				mov		edx,[esi]
				invoke [edx].IDataObject.GetData,esi,addr fmte,addr medium
				.if eax==S_OK
					mov		ebx,lpdwEffect
					.if grfKeyState & MK_CONTROL
						mov		dword ptr [ebx],DROPEFFECT_COPY 
					.else
						mov		dword ptr [ebx],DROPEFFECT_MOVE
					.endif
					mov		[edi].IDropTarget.valid,TRUE
					mov		eax,medium.pUnkForRelease
					.if eax
						mov		edx,[eax]
						invoke [edx].IDataObject.iu.Release,eax
					.else
						invoke GlobalFree,medium.hGlobal
					.endif
				.endif
			.endif
		.endif
		mov		eax,S_OK
	.endif
	ret

IDropTarget_DragEnter endp

IDropTarget_DragOver proc uses ebx esi edi,pthis,grfKeyState,pt:POINT,lpdwEffect
	LOCAL	rect:RECT

;PrintText 'IDropTarget_DragOver'
	mov		edi,pthis
	mov		edi,[edi]
	mov		edx,lpdwEffect
	mov		dword ptr [edx],DROPEFFECT_NONE
	.if [edi].IDropTarget.valid
		invoke WindowFromPoint,pt.x,pt.y
		push	eax
		mov		edx,eax
		invoke ScreenToClient,edx,addr pt
		pop		eax
		invoke ChildWindowFromPoint,eax,pt.x,pt.y
		mov		ebx,eax
		invoke GetWindowLong,ebx,0
		.if eax
			mov		[edi].IDropTarget.hwnd,ebx
			mov		ebx,eax
			invoke SetFocus,[edi].IDropTarget.hwnd
			mov		eax,[edi].IDropTarget.hwnd
			.if eax==[ebx].EDIT.edta.hwnd
				lea		esi,[ebx].EDIT.edta
			.else
				lea		esi,[ebx].EDIT.edtb
			.endif
			invoke GetClientRect,[edi].IDropTarget.hwnd,addr rect
			mov		ecx,[ebx].EDIT.fntinfo.fntht
			shr		ecx,1
			mov		eax,pt.y
			lea		edx,[eax+ecx]
			.if eax<ecx
				invoke SendMessage,[edi].IDropTarget.hwnd,WM_VSCROLL,SB_LINEUP,[esi].RAEDT.hvscroll
			.elseif edx>rect.bottom
				invoke SendMessage,[edi].IDropTarget.hwnd,WM_VSCROLL,SB_LINEDOWN,[esi].RAEDT.hvscroll
			.else
				mov		eax,pt.x
				lea		edx,[eax+32]
				mov		ecx,[ebx].EDIT.selbarwt
				add		ecx,[ebx].EDIT.linenrwt
				.if eax<ecx
					invoke SendMessage,[edi].IDropTarget.hwnd,WM_HSCROLL,SB_LINEUP,[ebx].EDIT.hhscroll
				.elseif edx>rect.right
					invoke SendMessage,[edi].IDropTarget.hwnd,WM_HSCROLL,SB_LINEDOWN,[ebx].EDIT.hhscroll
				.endif
			.endif
			invoke GetCharFromPos,ebx,[esi].RAEDT.cpy,pt.x,pt.y
			mov		edx,eax
			mov		[edi].IDropTarget.cp,eax
			invoke GetPosFromChar,ebx,edx,addr pt
			mov		eax,pt.x
			sub		eax,[ebx].EDIT.cpx
			mov		edx,pt.y
			sub		edx,[esi].RAEDT.cpy
			invoke SetCaretPos,eax,edx
			invoke ShowCaret,[edi].IDropTarget.hwnd
			mov		[ebx].EDIT.fCaretHide,FALSE
			mov		edx,lpdwEffect
			.if grfKeyState & MK_CONTROL
				mov		dword ptr [edx],DROPEFFECT_COPY
			.else
				mov		dword ptr [edx],DROPEFFECT_MOVE
			.endif
		.endif
	.endif
	mov		eax,S_OK
	ret

IDropTarget_DragOver endp

IDropTarget_DragLeave proc uses ebx edi,pthis

;PrintText 'IDropTarget_DragLeave'
	mov		edi,pthis
	mov		edi,[edi]
	.if [edi].IDropTarget.hwnd
		invoke GetWindowLong,[edi].IDropTarget.hwnd,0
		.if eax
			mov		ebx,eax
			.if ![ebx].EDIT.fCaretHide
				invoke HideCaret,[edi].IDropTarget.hwnd
				mov		[ebx].EDIT.fCaretHide,TRUE
			.endif
		.endif
		mov		[edi].IDropTarget.hwnd,0
	.endif
	mov		eax,S_OK
	ret

IDropTarget_DragLeave endp

IDropTarget_Drop proc uses ebx esi edi,pthis,lpDataObject,grfKeyState,pt:POINT,lpdwEffect
	LOCAL	medium:STGMEDIUM
	LOCAL	fmte:FORMATETC

;PrintText 'IDropTarget_Drop'
	mov		esi,lpDataObject
	mov		ebx,lpdwEffect
	mov		edi,pthis
	mov		edi,[edi]
	mov		eax,E_INVALIDARG
	mov		dword ptr [ebx],DROPEFFECT_NONE
	mov		[edi].IDropTarget.valid,FALSE
	.if esi && [edi].IDropTarget.hwnd
		invoke GetWindowLong,[edi].IDropTarget.hwnd,0
		.if eax
			mov		ebx,eax
			mov		fmte.cfFormat,CF_TEXT
			mov		fmte.lptd,NULL
			mov		fmte.dwAspect,DVASPECT_CONTENT
			mov		fmte.lindex,-1
			mov		fmte.tymed,TYMED_HGLOBAL
			mov		edx,[esi]
			invoke [edx].IDataObject.GetData,esi,addr fmte,addr medium
			.if eax==S_OK
				mov		eax,[edi].IDropTarget.cp
				mov		edx,[edi].IDropTarget.hwnd
				mov		edx,hDragWin
				;Test if Drop is on top of Drag
				.if (edx!=[ebx].EDIT.edta.hwnd && edx!=[ebx].EDIT.edtb.hwnd) || eax<=cpDragSource.cpMin || eax>=cpDragSource.cpMax
					mov		[ebx].EDIT.cpMin,eax
					mov		[ebx].EDIT.cpMax,eax
					.if eax<=cpDragSource.cpMin && (edx==[ebx].EDIT.edta.hwnd || edx==[ebx].EDIT.edtb.hwnd)
						mov		ecx,cpDragSource.cpMax
						sub		ecx,cpDragSource.cpMin
						add		cpDragSource.cpMin,ecx
						add		cpDragSource.cpMax,ecx
					.endif
					invoke Paste,ebx,[edi].IDropTarget.hwnd,medium.hGlobal
					mov		edx,lpdwEffect
					.if grfKeyState & MK_CONTROL
						mov		dword ptr [edx],DROPEFFECT_COPY
					.else
						mov		dword ptr [edx],DROPEFFECT_MOVE
					.endif
				.endif
				mov		[edi].IDropTarget.valid,TRUE
				mov		eax,medium.pUnkForRelease
				.if eax
					mov		edx,[eax]
					invoke [edx].IDataObject.iu.Release,eax
				.else
					invoke GlobalFree,medium.hGlobal
				.endif
				invoke [edi].IDropTarget.DragLeave,pthis
				mov		eax,S_OK
			.endif
		.else
			mov		eax,E_INVALIDARG
		.endif
	.endif
	ret

IDropTarget_Drop endp

;IDropSource methods
IDropSource_QueryInterface proc	pthis,iid,ppvObject

;PrintText 'IDropSource_QueryInterface'
	invoke IsEqualGUID,iid,offset IID_IDropSource
	.if	!eax
		invoke IsEqualGUID,iid,offset IID_IUnknown
	.endif
	mov		edx,ppvObject
	.if	eax
		mov		eax,pthis
		mov		[edx],eax
		mov		edx,[eax]
		invoke [edx].IDropSource.iu.AddRef,eax
		mov		eax,S_OK
	.else
		mov		dword ptr [edx],0
		mov		eax,E_NOINTERFACE
	.endif
	ret

IDropSource_QueryInterface endp

IDropSource_AddRef proc	pthis

;PrintText 'IDropSource_AddRef'
	mov		eax,pthis
	mov		edx,[eax]
	inc		[edx].IDropSource.refcount
	mov		eax,[edx].IDropSource.refcount
	ret

IDropSource_AddRef endp

IDropSource_Release	proc pthis

;PrintText 'IDropSource_Release'
	mov		eax,pthis
	mov		edx,[eax]
	.if [edx].IDropTarget.refcount
		dec		[edx].IDropTarget.refcount
	.endif
	mov		eax,[edx].IDropTarget.refcount
	ret

IDropSource_Release	endp

IDropSource_QueryContinueDrag proc pthis,fEscapePressed,grfKeyState

;PrintText 'IDropSource_QueryContinueDrag'
	.if	fEscapePressed
		mov		eax,DRAGDROP_S_CANCEL
	.elseif	!(grfKeyState &	MK_LBUTTON)
		mov		eax,DRAGDROP_S_DROP
	.else
		mov		eax,S_OK
	.endif
	ret

IDropSource_QueryContinueDrag endp

IDropSource_GiveFeedback proc pthis,dwEffect

;PrintText 'IDropSource_GiveFeedback'
	mov		eax,DRAGDROP_S_USEDEFAULTCURSORS
	ret

IDropSource_GiveFeedback endp

;IDataObject methods
IDO_QueryInterface proc	pthis,iid,ppvObject

;PrintText 'IDataObject_QueryInterface'
	invoke IsEqualGUID,iid,offset IID_IDataObject
	.if	!eax
		invoke IsEqualGUID,iid,offset IID_IUnknown
	.endif
	mov		edx,ppvObject
	.if	eax
		mov		eax,pthis
		mov		[edx],eax
		mov		edx,[eax]
		invoke [edx].IDataObject.iu.AddRef,eax
		mov		eax,S_OK
	.else
		mov		dword ptr [edx],0
		mov		eax,E_NOINTERFACE
	.endif
	ret

IDO_QueryInterface endp

IDO_AddRef proc	pthis

;PrintText 'IDataObject_AddRef'
	mov		eax,pthis
	mov		edx,[eax]
	inc		[edx].IDataObject.refcount
	mov		eax,[edx].IDataObject.refcount
	ret

IDO_AddRef endp

IDO_Release	proc pthis

;PrintText 'IDataObject_Release'
	mov		eax,pthis
	mov		edx,[eax]
	.if	[edx].IDataObject.refcount
		dec		[edx].IDataObject.refcount
	.endif
	mov		eax,[edx].IDataObject.refcount
	ret

IDO_Release	endp

IDO_GetData	proc uses ebx esi,pthis,pFormatetc,pmedium
	LOCAL	hCMem:DWORD

;PrintText 'IDataObject_GetData'
	mov		esi,pFormatetc
	.if [esi].FORMATETC.cfFormat==CF_TEXT
		.if [esi].FORMATETC.dwAspect==DVASPECT_CONTENT
			.if [esi].FORMATETC.lindex==-1
				.if [esi].FORMATETC.tymed==TYMED_HGLOBAL
					mov		ebx,hDragSourceMem
					mov		eax,[ebx].EDIT.cpMin
					sub		eax,[ebx].EDIT.cpMax
					.if sdword ptr eax<0
						neg		eax
					.endif
					shl		eax,1
					inc		eax
					invoke xGlobalAlloc,GMEM_SHARE or GMEM_MOVEABLE or GMEM_ZEROINIT,eax
					mov     hCMem,eax
					invoke GlobalLock,hCMem
					invoke EditCopy,ebx,eax
					invoke GlobalUnlock,hCMem
					mov		edx,pmedium
					mov		[edx].STGMEDIUM.tymed,TYMED_HGLOBAL
					mov		eax,hCMem
					mov		[edx].STGMEDIUM.hGlobal,eax
					mov		[edx].STGMEDIUM.pUnkForRelease,NULL
					mov		eax,S_OK
				.else
					mov		eax,DV_E_TYMED
				.endif
			.else
				mov		eax,DV_E_LINDEX
			.endif
		.else
			mov		eax,DV_E_DVASPECT
		.endif
	.else
		mov		eax,DV_E_CLIPFORMAT
	.endif
	ret

IDO_GetData	endp

IDO_GetDataHere	proc uses ebx,pthis,pFormatetc,pmedium

;PrintText 'IDataObject_GetDataHere'
	mov		eax,E_NOTIMPL
	ret

IDO_GetDataHere	endp

IDO_QueryGetData proc uses ebx,pthis,pFormatetc

;PrintText 'IDataObject_QueryGetData'
	mov		ebx,pFormatetc
	.if [ebx].FORMATETC.cfFormat==CF_TEXT
		.if [ebx].FORMATETC.dwAspect==DVASPECT_CONTENT
			.if [ebx].FORMATETC.lindex==-1
				.if [ebx].FORMATETC.tymed==TYMED_HGLOBAL
					mov		eax,S_OK
				.else
					mov		eax,DV_E_TYMED
				.endif
			.else
				mov		eax,DV_E_LINDEX
			.endif
		.else
			mov		eax,DV_E_DVASPECT
		.endif
	.else
		mov		eax,DV_E_CLIPFORMAT
	.endif
	ret

IDO_QueryGetData endp

IDO_GetCanonicalFormatEtc proc uses	esi	edi,pthis,pFormatetcIn,pFormatetcOut

;PrintText 'IDataObject_GetCanonicalFormatEtc'
	mov		esi,pFormatetcIn
	mov		edi,pFormatetcOut
	mov		ecx,sizeof FORMATETC
	rep		movsb
	mov		[edi].FORMATETC.lptd,NULL
	mov		eax, DATA_S_SAMEFORMATETC
	ret

IDO_GetCanonicalFormatEtc endp

IDO_SetData	proc pthis,pFormatetc,pmedium,fRelease

;PrintText 'IDataObject_SetData'
	mov		eax,E_NOTIMPL
	ret

IDO_SetData	endp

IDO_EnumFormatEtc proc pthis,dwDirection,ppenumFormatetc

;PrintText 'IDataObject_EnumFormatEtc'
	.if	dwDirection==DATADIR_GET
		mov		eax,offset pIEnumFORMATETC
		mov		edx,ppenumFormatetc
		mov		[edx],eax
		mov		eax,S_OK
	.else
		mov		eax,E_NOTIMPL
	.endif
	ret

IDO_EnumFormatEtc endp

IDO_DAdvise	proc pthis,pFormatetc,advf,pAdvSink,pdwConnection

;PrintText 'IDataObject_DAdvise'
	mov		eax,E_NOTIMPL
	ret

IDO_DAdvise	endp

IDO_DUnadvise proc pthis,dwConnection

;PrintText 'IDataObject_DUnadvise'
	mov		eax,E_NOTIMPL
	ret

IDO_DUnadvise endp

IDO_EnumDAdvise	proc pthis,ppenumAdvise

;PrintText 'IDataObject_EnumDAdvise'
	mov		eax,E_NOTIMPL
	ret

IDO_EnumDAdvise	endp

;IEnumFORMATETC	methods
IEnumFORMATETC_QueryInterface proc pthis,iid,ppvObject

;PrintText 'IEnumFORMATETC_QueryInterface'
	invoke IsEqualGUID,iid,offset IID_IEnumFORMATETC
	.if	!eax
		invoke IsEqualGUID,iid,offset IID_IUnknown
	.endif
	mov		edx,ppvObject
	.if	eax
		mov		eax,pthis
		mov		[edx],eax
		mov		edx,[eax]
		invoke [edx].IEnumFORMATETC.iu.AddRef,eax
		mov		eax,S_OK
	.else
		mov		dword ptr [edx],0
		mov		eax,E_NOINTERFACE
	.endif
	ret

IEnumFORMATETC_QueryInterface endp

IEnumFORMATETC_AddRef proc pthis

;PrintText 'IEnumFORMATETC_AddRef'
	mov		eax,pthis
	mov		edx,[eax]
	inc		[edx].IEnumFORMATETC.refcount
	mov		eax,[edx].IEnumFORMATETC.refcount
	ret

IEnumFORMATETC_AddRef endp

IEnumFORMATETC_Release proc	pthis

;PrintText 'IEnumFORMATETC_Release'
	mov		eax,pthis
	mov		edx,[eax]
	.if [edx].IEnumFORMATETC.refcount
		dec		[edx].IEnumFORMATETC.refcount
	.endif
	.if ![edx].IEnumFORMATETC.refcount
		mov		[edx].IEnumFORMATETC.ifmt,0
	.endif
	mov		eax,[edx].IEnumFORMATETC.refcount
	ret

IEnumFORMATETC_Release	endp

IEnumFORMATETC_Next	proc pthis,celt,rgelt,pceltFetched

;PrintText 'IEnumFORMATETC_Next'
	xor		edx,edx
	mov		eax,pthis
	mov		eax,[eax]
	mov		ecx,[eax].IEnumFORMATETC.ifmt
	.if	ecx<[eax].IEnumFORMATETC.ifmtmax
		inc		edx
		inc		ecx
		mov		[eax].IEnumFORMATETC.ifmt,ecx
		mov		eax,rgelt
		mov		[eax].FORMATETC.cfFormat,CF_TEXT
		mov		[eax].FORMATETC.lptd,NULL
		mov		[eax].FORMATETC.dwAspect,DVASPECT_CONTENT
		mov		[eax].FORMATETC.lindex,-1
		mov		[eax].FORMATETC.tymed,TYMED_HGLOBAL
	.endif
	mov		eax,pceltFetched
	.if	eax
		mov		[eax],edx
	.endif
	.if	edx==celt
		mov		eax,S_OK
	.else
		mov		eax,S_FALSE
	.endif
	ret

IEnumFORMATETC_Next	endp

IEnumFORMATETC_Skip	proc pthis,celt

;PrintText 'IEnumFORMATETC_Skip'
	mov		eax,E_NOTIMPL
	ret

IEnumFORMATETC_Skip	endp

IEnumFORMATETC_Reset proc pthis

;PrintText 'IEnumFORMATETC_Reset'
	mov		eax,pthis
	mov		edx,[eax]
	mov		[edx].IEnumFORMATETC.ifmt,0
	mov		eax,S_OK
	ret

IEnumFORMATETC_Reset endp

IEnumFORMATETC_Clone proc pthis,ppenum

;PrintText 'IEnumFORMATETC_Clone'
	mov		eax,E_NOTIMPL
	ret

IEnumFORMATETC_Clone endp

