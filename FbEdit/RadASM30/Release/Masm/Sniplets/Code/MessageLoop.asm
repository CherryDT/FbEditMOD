	.while TRUE
		invoke GetMessage,addr msg,NULL,0,0
	  .break .if !eax
		;invoke IsDialogMessage,hModelessDialog,addr msg
		;.if !eax
			;invoke TranslateAccelerator,hWnd,hAccel,addr msg
			;.if !eax
				invoke TranslateMessage,addr msg
				invoke DispatchMessage,addr msg
			;.endif
		;.endif
	.endw
