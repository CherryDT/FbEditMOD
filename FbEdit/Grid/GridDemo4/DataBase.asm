;--------------------------------------------------------------------------------
;NOTE:	This demo will ony show SQL_CHAR, SQL_VARCHAR and SQL_INTEGER columns.
;		It will not work with unicode columns.
;		Add and edit has restrictions on PrimaryKey / Indexes types.
;		Will only work with AutoIncrement PrimaryKey or no PrimaryKey / Index at all.
;		In parts based on MsdnHelp by Qweerdy
;--------------------------------------------------------------------------------
;
; Macro for easier error messages, actually a CTEXT variation
Err MACRO y:VARARG
	LOCAL sym

CONST segment
	IFIDNI <y>,<>
		sym db 0
	ELSE
		sym db y,0
	ENDIF
CONST ends

	invoke MessageBox,hWnd,offset sym,offset szRAGridDLL,MB_OK
	mov 	eax,TRUE
endm

SQLTABLE struct
	szName	db 192 dup(?)	;Table name
	szType	db 64 dup(?)	;Table type
SQLTABLE ends

SQLCOL struct
	szName	db 192 dup(?)	;Column name
	wType	dw ?			;Column type
	nulls	dd ?			;Nullable
	update	dd ?			;Updatable
	autoinc	dd ?			;Autoincrement
	nCol	dd ?			;Column number in grid
SQLCOL ends

.data

szSemi		db ';',0
szConnect	db 'DRIVER={Microsoft Access Driver (*.mdb)};DBQ=',0
szSql		db 'SELECT * FROM ',0

.data?

hEnv		dd ?
hConn		dd ?

.code

;Connect to database
ODBCConnect proc uses esi edi,lpFilename:DWORD
	LOCAL	lnCon:DWORD

	invoke SQLAllocHandle,SQL_HANDLE_ENV,SQL_NULL_HANDLE,offset hEnv
	.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
		invoke SQLSetEnvAttr,hEnv,SQL_ATTR_ODBC_VERSION,SQL_OV_ODBC3,0
		.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
			invoke SQLAllocHandle,SQL_HANDLE_DBC,hEnv,offset hConn
			.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
				invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,1024
				mov		esi,eax
				invoke lstrcpy,esi,offset szConnect
				invoke lstrcat,esi,lpFilename
				invoke lstrcat,esi,offset szSemi
				invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,1024
				mov		edi,eax
				invoke lstrlen,esi
				mov		edx,eax
				invoke SQLDriverConnect,hConn,0,esi,edx,edi,1024,addr lnCon,SQL_DRIVER_COMPLETE
				.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
					xor eax,eax
				.else
					invoke SQLFreeHandle,SQL_HANDLE_DBC,hConn
					invoke SQLFreeHandle,SQL_HANDLE_ENV,hEnv
					mov		hConn,0
					mov		hEnv,0
					Err 'Unable to connect to the database.'
				.endif
				push	eax
				invoke GlobalFree,esi
				invoke GlobalFree,edi
				pop		eax
			.else
				invoke SQLFreeHandle,SQL_HANDLE_ENV,hEnv
				mov		hEnv,0
				Err 'Unable to allocate ODBC connection handle.'
			.endif
		.else
			invoke SQLFreeHandle,SQL_HANDLE_ENV,hEnv
			mov		hEnv,0
			Err 'Unable to set ODBC environment attributes.'
		.endif
	.else
		Err 'Unable to allocate ODBC environment handle.'
	.endif
	ret

ODBCConnect endp

;Disconnect from database
ODBCDisconnect proc

	.if hConn
		invoke SQLDisconnect,hConn
		invoke SQLFreeHandle,SQL_HANDLE_DBC,hConn
		invoke SQLFreeHandle,SQL_HANDLE_ENV,hEnv
		mov		hConn,0
		mov		hEnv,0
	.endif
	ret

ODBCDisconnect endp

;Get database tables
ODBCGetTables proc uses edi
	LOCAL	hStmt:DWORD
	LOCAL	len1:DWORD
	LOCAL	len2:DWORD

	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,64*1024
	invoke GlobalLock,eax
	push	eax
	mov		edi,eax
	invoke SQLAllocHandle,SQL_HANDLE_STMT,hConn,addr hStmt
	.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
		invoke SQLTables,hStmt,NULL,0,NULL,0,NULL,0,NULL,0
		.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
		  @@:
			invoke SQLBindCol,hStmt,3,SQL_C_CHAR,addr [edi].SQLTABLE.szName,sizeof SQLTABLE.szName,addr len1
			invoke SQLBindCol,hStmt,4,SQL_C_CHAR,addr [edi].SQLTABLE.szType,sizeof SQLTABLE.szType,addr len2
			invoke SQLFetch,hStmt
			.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
				lea		edi,[edi+sizeof SQLTABLE]
				jmp		@b
			.endif
		.else
			Err 'Unable to get tables.'
		.endif
		invoke SQLFreeHandle,SQL_HANDLE_STMT,hStmt
	.else
		Err 'Unable to allocate statement handle.'
	.endif
	pop		eax
	ret

ODBCGetTables endp

;Get the columns in a table
ODBCGetColumns proc uses edi,lpTable:DWORD
	LOCAL	hStmt:DWORD
	LOCAL	hStmt2:DWORD
	LOCAL	len:DWORD
	LOCAL	nInx:DWORD
	LOCAL	nCol:DWORD
	LOCAL	buffer[256]:BYTE

	mov		edi,offset dbCols
	mov		ecx,sizeof dbCols/4
	xor		eax,eax
	mov		nCol,eax
	mov		nInx,eax
	rep stosd
	mov		edi,offset dbCols
	invoke SQLAllocHandle,SQL_HANDLE_STMT,hConn,addr hStmt
	.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
		invoke SQLAllocHandle,SQL_HANDLE_STMT,hConn,addr hStmt2
		.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
			invoke lstrcpy,addr buffer,offset szSql
			invoke lstrcat,addr buffer,lpTable
			invoke lstrcat,addr buffer,offset szSemi
			invoke lstrlen,addr buffer
			invoke SQLExecDirect,hStmt2,addr buffer,eax
			.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
				invoke lstrlen,lpTable
				invoke SQLColumns,hStmt,NULL,0,NULL,0,lpTable,eax,NULL,0
				.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
				  @@:
					invoke SQLBindCol,hStmt,4,SQL_CHAR,addr [edi].SQLCOL.szName,sizeof SQLCOL.szName,addr len
					invoke SQLBindCol,hStmt,5,SQL_SMALLINT,addr [edi].SQLCOL.wType,sizeof SQLCOL.wType,addr len
					invoke SQLFetch,hStmt
					.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
						movzx	eax,[edi].SQLCOL.wType
						.if eax==SQL_CHAR || eax==SQL_VARCHAR || eax==SQL_INTEGER
							mov		eax,nCol
							mov		[edi].SQLCOL.nCol,eax
							inc		nCol
						.else
							mov		[edi].SQLCOL.nCol,-1
						.endif
						inc		nInx
						invoke SQLColAttribute,hStmt2,nInx,SQL_COLUMN_NULLABLE,NULL,NULL,NULL,addr [edi].SQLCOL.nulls
						invoke SQLColAttribute,hStmt2,nInx,SQL_COLUMN_UPDATABLE,NULL,NULL,NULL,addr [edi].SQLCOL.update
						invoke SQLColAttribute,hStmt2,nInx,SQL_COLUMN_AUTO_INCREMENT,NULL,NULL,NULL,addr [edi].SQLCOL.autoinc
						lea		edi,[edi+sizeof SQLCOL]
						jmp		@b
					.endif
				.else
					Err 'Unable to get columns.'
				.endif
			.else
				Err "Failed to execute query."
			.endif
			invoke SQLFreeHandle,SQL_HANDLE_STMT,hStmt2
		.else
			Err 'Unable to allocate statement handle.'
		.endif
		invoke SQLFreeHandle,SQL_HANDLE_STMT,hStmt
	.else
		Err 'Unable to allocate statement handle.'
	.endif
	ret

ODBCGetColumns endp

;Get all rows in a table
ODBCGetData proc uses ebx esi edi,lpTable:DWORD,lpCols:DWORD
	LOCAL	hStmt:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	rowdta[256]:DWORD
	LOCAL	nInx:DWORD
	LOCAL	len:DWORD

	invoke SQLAllocHandle,SQL_HANDLE_STMT,hConn,addr hStmt
	.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
		invoke SQLSetStmtAttr,hStmt,SQL_ATTR_CONCURRENCY,SQL_CONCUR_ROWVER,0
		invoke SQLSetStmtAttr,hStmt,SQL_ATTR_CURSOR_TYPE,SQL_CURSOR_KEYSET_DRIVEN,0
		invoke lstrcpy,addr buffer,offset szSql
		invoke lstrcat,addr buffer,lpTable
		invoke lstrcat,addr buffer,offset szSemi
		invoke lstrlen,addr buffer
		invoke SQLExecDirect,hStmt,addr buffer,eax
		.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
			invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,64*1024
			mov		edi,eax
			push	edi
			mov		nRows,0
			mov		nInx,0
			lea		ebx,rowdta
			mov		esi,lpCols
			.while [esi].SQLCOL.szName
				inc		nInx
				movzx	eax,[esi].SQLCOL.wType
				.if eax==SQL_CHAR || eax==SQL_VARCHAR
					invoke SQLBindCol,hStmt,nInx,SQL_CHAR,edi,256,addr len
					mov		[ebx],edi
					add		ebx,4
					add		edi,256
				.elseif eax==SQL_INTEGER
					invoke SQLBindCol,hStmt,nInx,SQL_INTEGER,ebx,4,addr len
					add		ebx,4
				.endif
				lea		esi,[esi+sizeof SQLCOL]
			.endw
		  @@:
			lea		ebx,rowdta
			mov		esi,lpCols
			.while [esi].SQLCOL.szName
				movzx	eax,[esi].SQLCOL.wType
				.if eax==SQL_CHAR || eax==SQL_VARCHAR
					mov		edi,[ebx]
					mov		byte ptr [edi],0
					add		ebx,4
				.elseif eax==SQL_INTEGER
					mov		dword ptr [ebx],0
					add		ebx,4
				.endif
				lea		esi,[esi+sizeof SQLCOL]
			.endw
			invoke SQLFetch,hStmt
			.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
				invoke SendMessage,hGrd,GM_ADDROW,0,addr rowdta
				inc		nRows
				cmp		nRows,32700
				jne		@b
			.endif
			pop		edi
			invoke GlobalFree,edi
		.else
			Err "Failed to execute query."
		.endif
		invoke SQLFreeHandle,SQL_HANDLE_STMT,hStmt
	.else
		Err 'Unable to allocate statement handle.'
	.endif
	ret

ODBCGetData endp

;Get single row in a table
ODBCGetRowData proc uses ebx esi edi,lpTable:DWORD,lpCols:DWORD,nRow:DWORD
	LOCAL	hStmt:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	rowdta[256]:DWORD
	LOCAL	nInx:DWORD
	LOCAL	len:DWORD

	mov		fNoUpdate,TRUE
	invoke SQLAllocHandle,SQL_HANDLE_STMT,hConn,addr hStmt
	.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
		invoke SQLSetStmtAttr,hStmt,SQL_ATTR_CONCURRENCY,SQL_CONCUR_ROWVER,0
		invoke SQLSetStmtAttr,hStmt,SQL_ATTR_CURSOR_TYPE,SQL_CURSOR_KEYSET_DRIVEN,0
		invoke lstrcpy,addr buffer,offset szSql
		invoke lstrcat,addr buffer,lpTable
		invoke lstrcat,addr buffer,offset szSemi
		invoke lstrlen,addr buffer
		invoke SQLExecDirect,hStmt,addr buffer,eax
		.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
			invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,64*1024
			mov		edi,eax
			push	edi
			mov		nInx,0
			lea		ebx,rowdta
			mov		esi,lpCols
			.while [esi].SQLCOL.szName
				inc		nInx
				movzx	eax,[esi].SQLCOL.wType
				.if eax==SQL_CHAR || eax==SQL_VARCHAR
					mov		byte ptr [edi],0
					invoke SQLBindCol,hStmt,nInx,SQL_CHAR,edi,256,addr len
					mov		[ebx],edi
					add		ebx,4
					add		edi,256
				.elseif eax==SQL_INTEGER
					mov		dword ptr [ebx],0
					invoke SQLBindCol,hStmt,nInx,SQL_INTEGER,ebx,4,addr len
					add		ebx,4
				.endif
				lea		esi,[esi+sizeof SQLCOL]
			.endw
			invoke SQLFetchScroll,hStmt,SQL_FETCH_ABSOLUTE,nRow
			.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
				lea		ebx,rowdta
				mov		esi,lpCols
				.while [esi].SQLCOL.szName
					movzx	eax,[esi].SQLCOL.wType
					.if eax==SQL_CHAR || eax==SQL_VARCHAR
						mov		ecx,nRow
						dec		ecx
						shl		ecx,16
						add		ecx,[esi].SQLCOL.nCol
						invoke SendMessage,hGrd,GM_SETCELLDATA,ecx,[ebx]
						add		ebx,4
					.elseif eax==SQL_INTEGER
						mov		edi,[ebx]
						mov		ecx,nRow
						dec		ecx
						shl		ecx,16
						add		ecx,[esi].SQLCOL.nCol
						invoke SendMessage,hGrd,GM_SETCELLDATA,ecx,ebx
						add		ebx,4
					.endif
					lea		esi,[esi+sizeof SQLCOL]
				.endw
			.else
				Err "Failed to get data."
			.endif
			pop		edi
			invoke GlobalFree,edi
		.else
			Err "Failed to execute query."
		.endif
		invoke SQLFreeHandle,SQL_HANDLE_STMT,hStmt
	.else
		Err 'Unable to allocate statement handle.'
	.endif
	mov		fNoUpdate,FALSE
	ret

ODBCGetRowData endp

;Update single row in a table
;NOTE: Do NOT attemt to change PrimaryKey
ODBCUpdateData proc uses ebx esi edi,lpTable:DWORD,lpCols:DWORD,nRow:DWORD
	LOCAL	hStmt:DWORD
	LOCAL	rowdta[256]:DWORD
	LOCAL	nInx:DWORD
	LOCAL	nCol:DWORD
	LOCAL	len:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	lret

	mov		lret,-1
	invoke SQLAllocHandle,SQL_HANDLE_STMT,hConn,addr hStmt
	.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
		invoke SQLSetStmtAttr,hStmt,SQL_ATTR_CONCURRENCY,SQL_CONCUR_ROWVER,0
		invoke SQLSetStmtAttr,hStmt,SQL_ATTR_CURSOR_TYPE,SQL_CURSOR_KEYSET_DRIVEN,0
		invoke lstrcpy,addr buffer,offset szSql
		invoke lstrcat,addr buffer,lpTable
		invoke lstrcat,addr buffer,offset szSemi
		invoke lstrlen,addr buffer
		invoke SQLExecDirect,hStmt,addr buffer,eax
		.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
			invoke SQLFetchScroll,hStmt,SQL_FETCH_ABSOLUTE,nRow
			.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
				mov		esi,lpCols
				invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,64*1024
				mov		edi,eax
				push	edi
				mov		nInx,0
				mov		nCol,0
				lea		ebx,rowdta
				.while [esi].SQLCOL.szName
					inc		nInx
					movzx	eax,[esi].SQLCOL.wType
					.if eax==SQL_CHAR || eax==SQL_VARCHAR
						.if [esi].SQLCOL.update
							invoke SQLBindCol,hStmt,nInx,SQL_CHAR,edi,256,ebx
							mov		ecx,nRow
							dec		ecx
							shl		ecx,16
							add		ecx,nCol
							invoke SendMessage,hGrd,GM_GETCELLDATA,ecx,edi
							invoke lstrlen,edi
							.if !eax
								inc		eax
							.endif
							mov		dword ptr [ebx],eax
							add		ebx,4
							add		edi,256
						.endif
						inc		nCol
					.elseif eax==SQL_INTEGER
						.if [esi].SQLCOL.update
							invoke SQLBindCol,hStmt,nInx,SQL_INTEGER,edi,4,ebx
							mov		ecx,nRow
							dec		ecx
							shl		ecx,16
							add		ecx,nCol
							invoke SendMessage,hGrd,GM_GETCELLDATA,ecx,edi
							mov		dword ptr [ebx],4
							add		ebx,4
							add		edi,4
						.endif
						inc		nCol
					.endif
					lea		esi,[esi+sizeof SQLCOL]
				.endw
				invoke SQLSetPos,hStmt,1,SQL_UPDATE,SQL_LOCK_NO_CHANGE
				.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
					mov		lret,0
				.else
					Err "Unable to update data."
				.endif
				pop		edi
				invoke GlobalFree,edi
			.else
				Err "Unable to fetch data."
			.endif
		.else
			Err "Failed to execute query."
		.endif
		invoke SQLFreeHandle,SQL_HANDLE_STMT,hStmt
	.else
		Err 'Unable to allocate statement handle.'
	.endif
	mov		eax,lret
	ret

ODBCUpdateData endp

;Add single row to a table
;NOTE: Does NOT work with PrimaryKeys other than AutoIncrement
ODBCAddData proc uses ebx esi edi,lpTable:DWORD,lpCols:DWORD,nRow:DWORD
	LOCAL	hStmt:DWORD
	LOCAL	rowdta[256]:DWORD
	LOCAL	nInx:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	lret:DWORD

	mov		lret,-1
	invoke SQLAllocHandle,SQL_HANDLE_STMT,hConn,addr hStmt
	.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
		invoke SQLSetStmtAttr,hStmt,SQL_ATTR_CONCURRENCY,SQL_CONCUR_ROWVER,0
		invoke SQLSetStmtAttr,hStmt,SQL_ATTR_CURSOR_TYPE,SQL_CURSOR_KEYSET_DRIVEN,0
		invoke lstrcpy,addr buffer,offset szSql
		invoke lstrcat,addr buffer,lpTable
		invoke lstrcat,addr buffer,offset szSemi
		invoke lstrlen,addr buffer
		invoke SQLExecDirect,hStmt,addr buffer,eax
		.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
			invoke SQLFetch,hStmt
			.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
				invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,64*1024
				mov		edi,eax
				push	edi
				mov		nInx,0
				lea		ebx,rowdta
				mov		esi,lpCols
				.while [esi].SQLCOL.szName
					inc		nInx
					movzx	eax,[esi].SQLCOL.wType
					.if eax==SQL_CHAR || eax==SQL_VARCHAR
						.if [esi].SQLCOL.update
							invoke SQLBindCol,hStmt,nInx,SQL_CHAR,edi,256,ebx
							mov		byte ptr [edi],0
							.if ![esi].SQLCOL.nulls
								mov		dword ptr [ebx],SQL_NULL_DATA
							.else
								mov		dword ptr [ebx],1
							.endif
							add		ebx,4
							add		edi,256
						.endif
					.elseif eax==SQL_INTEGER
						.if [esi].SQLCOL.update
							invoke SQLBindCol,hStmt,nInx,SQL_INTEGER,edi,4,ebx
							mov		dword ptr [edi],0
							.if ![esi].SQLCOL.nulls
								mov		dword ptr [ebx],SQL_NULL_DATA
							.else
								mov		dword ptr [ebx],4
							.endif
							add		ebx,4
							add		edi,4
						.endif
					.endif
					lea		esi,[esi+sizeof SQLCOL]
				.endw
				invoke SQLSetPos,hStmt,1,SQL_ADD,SQL_LOCK_NO_CHANGE
				.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
					mov		lret,0
				.else
					Err "Failed to add row."
				.endif
				pop		edi
				invoke GlobalFree,edi
			.else
				Err "Failed to fetch data."
			.endif
		.else
			Err "Failed to execute query."
		.endif
		invoke SQLFreeHandle,SQL_HANDLE_STMT,hStmt
	.else
		Err 'Unable to allocate statement handle.'
	.endif
	mov		eax,lret
	ret

ODBCAddData endp

;Delete single row from a table
ODBCDelete proc uses ebx esi edi,lpTable:DWORD,lpCols:DWORD,nRow:DWORD
	LOCAL	hStmt:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	len:DWORD
	LOCAL	lret:DWORD

	mov		lret,-1
	invoke SQLAllocHandle,SQL_HANDLE_STMT,hConn,addr hStmt
	.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
		invoke SQLSetStmtAttr,hStmt,SQL_ATTR_CONCURRENCY,SQL_CONCUR_ROWVER,0
		invoke SQLSetStmtAttr,hStmt,SQL_ATTR_CURSOR_TYPE,SQL_CURSOR_KEYSET_DRIVEN,0
		invoke lstrcpy,addr buffer,offset szSql
		invoke lstrcat,addr buffer,lpTable
		invoke lstrcat,addr buffer,offset szSemi
		invoke lstrlen,addr buffer
		invoke SQLExecDirect,hStmt,addr buffer,eax
		.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
			invoke SQLFetchScroll,hStmt,SQL_FETCH_ABSOLUTE,nRow
			.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
				invoke SQLSetPos,hStmt,1,SQL_DELETE,SQL_LOCK_NO_CHANGE
				.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
					mov		lret,0
				.else
					Err "Failed to delete data."
				.endif
			.else
				Err "Failed to fetch data."
			.endif
			pop		edi
			invoke GlobalFree,edi
		.else
			Err "Failed to execute query."
		.endif
		invoke SQLFreeHandle,SQL_HANDLE_STMT,hStmt
	.else
		Err 'Unable to allocate statement handle.'
	.endif
	mov		eax,lret
	ret

ODBCDelete endp

