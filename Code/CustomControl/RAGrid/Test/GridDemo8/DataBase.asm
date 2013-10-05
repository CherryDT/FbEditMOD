;--------------------------------------------------------------------------------
;NOTE:	In parts based on MsdnHelp by Qweerdy
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
						.if eax==SQL_CHAR || eax==SQL_VARCHAR || eax==SQL_INTEGER || eax==SQL_SMALLINT || eax==SQL_REAL || eax==SQL_NUMERIC || eax==SQL_DOUBLE || eax==SQL_TYPE_TIMESTAMP || eax==65535 || eax==65529
							mov		eax,nCol
							mov		[edi].SQLCOL.nCol,eax
							inc		nCol
						.else
							;Unknown data type
							PrintDec eax
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
	LOCAL	ninx:DWORD
	LOCAL	nmemo[32]:DWORD
	LOCAL	pmemo[32]:DWORD

	invoke RtlZeroMemory,addr nmemo,sizeof nmemo
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
			mov		ninx,0
			.while [esi].SQLCOL.szName
				inc		nInx
				movsx	eax,[esi].SQLCOL.wType
				.if eax==SQL_CHAR || eax==SQL_VARCHAR
					invoke SQLBindCol,hStmt,nInx,SQL_CHAR,edi,256,addr len
					mov		[ebx],edi
					add		ebx,4
					add		edi,256
				.elseif eax==SQL_INTEGER
					invoke SQLBindCol,hStmt,nInx,SQL_INTEGER,ebx,4,addr len
					add		ebx,4
				.elseif eax==SQL_SMALLINT
					invoke SQLBindCol,hStmt,nInx,SQL_SMALLINT,ebx,2,addr len
					add		ebx,4
				.elseif eax==SQL_REAL
					invoke SQLBindCol,hStmt,nInx,SQL_REAL,ebx,4,addr len
					add		ebx,4
				.elseif eax==SQL_NUMERIC
					invoke SQLBindCol,hStmt,nInx,SQL_NUMERIC,edi,8,addr len
					mov		[ebx],edi
					add		ebx,4
					add		edi,8
				.elseif eax==SQL_DOUBLE
					invoke SQLBindCol,hStmt,nInx,SQL_DOUBLE,edi,8,addr len
					mov		[ebx],edi
					add		ebx,4
					add		edi,8
				.elseif eax==SQL_TYPE_TIMESTAMP
					invoke SQLBindCol,hStmt,nInx,SQL_TYPE_TIMESTAMP,edi,8,addr len
					mov		[ebx],edi
					add		ebx,4
					add		edi,8
				.elseif eax==SQL_LONGVARCHAR
					;Memo
					mov		ecx,ninx
					mov		pmemo[ecx*4],edi
					mov		eax,nInx
					mov		nmemo[ecx*4],eax
					mov		[ebx],edi
					add		ebx,4
					add		edi,4096
					inc		ninx
				.elseif eax==SQL_BIT
					invoke SQLBindCol,hStmt,nInx,SQL_BIT,ebx,1,addr len
					add		ebx,4
				.endif
				lea		esi,[esi+sizeof SQLCOL]
			.endw
		  @@:
			lea		ebx,rowdta
			mov		esi,lpCols
			.while [esi].SQLCOL.szName
				movsx	eax,[esi].SQLCOL.wType
				.if eax==SQL_CHAR || eax==SQL_VARCHAR
					mov		edi,[ebx]
					mov		byte ptr [edi],0
					add		ebx,4
				.elseif eax==SQL_INTEGER
					mov		dword ptr [ebx],0
					add		ebx,4
				.elseif eax==SQL_SMALLINT
					mov		dword ptr [ebx],0
					add		ebx,4
				.elseif eax==SQL_REAL
					mov		dword ptr [ebx],0
					add		ebx,4
				.elseif eax==SQL_NUMERIC
					mov		edi,[ebx]
					mov		dword ptr [edi],0
					mov		dword ptr [edi+4],0
					add		ebx,4
				.elseif eax==SQL_DOUBLE
					mov		edi,[ebx]
					mov		dword ptr [edi],0
					mov		dword ptr [edi+4],0
					add		ebx,4
				.elseif eax==SQL_TYPE_TIMESTAMP
					mov		edi,[ebx]
					mov		dword ptr [edi],0
					mov		dword ptr [edi+4],0
					add		ebx,4
				.elseif eax==SQL_LONGVARCHAR
					mov		edi,[ebx]
					mov		byte ptr [edi],0
					add		ebx,4
				.elseif eax==SQL_BIT
					mov		dword ptr [ebx],0
					add		ebx,4
				.endif
				lea		esi,[esi+sizeof SQLCOL]
			.endw
			invoke SQLFetch,hStmt
			.if ax==SQL_SUCCESS || ax==SQL_SUCCESS_WITH_INFO
				lea		ebx,nmemo
				lea		edi,pmemo
				.while dword ptr [ebx]
					invoke SQLGetData,hStmt,[ebx],SQL_C_CHAR,[edi],256,addr len
					add		ebx,4
					add		edi,4
				.endw
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

