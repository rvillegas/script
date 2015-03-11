

Const adFldIsNullable = 32
Const adFldMayBeNull = 64

'adArray	0x2000	Combine with another data type to indicate that the other data type is an array
Const adBigInt= 20
Const adBinary= 128
Const adBoolean= 11
Const adBSTR= 8
Const adChapter= 136
Const adChar= 129
Const adCurrency= 6
Const adDate= 7
Const adDBDate= 133
Const adDBFileTime= 137
Const adDBTime= 134
Const adDBTimeStamp= 135
Const adDecimal= 14
Const adDouble= 5
Const adEmpty= 0
Const adError= 10
Const adFileTime= 64
Const adGUID= 72
Const adIDispatch= 9
Const adInteger= 3
Const adIUnknown= 13
Const adLongVarBinary= 205
Const adLongVarChar= 201
Const adLongVarWChar= 203
Const adNumeric= 131
Const adPropVariant= 138
Const adSingle= 4
Const adSmallInt= 2
Const adTinyInt= 16
Const adUnsignedBigInt= 21
Const adUnsignedInt= 19
Const adUnsignedSmallInt= 18
Const adUnsignedTinyInt= 17
Const adUserDefined= 132
Const adVarBinary= 204
Const adVarChar= 200
Const adVariant= 12
Const adVarNumeric= 139
Const adVarWChar= 202
Const adWChar= 130

Dim adOpenUnspecified, adOpenForwardOnly, adOpenKeyset, adOpenDynamic, adOpenStatic

adOpenUnspecified=-1: adOpenForwardOnly=0: adOpenKeyset=1: adOpenDynamic=2: adOpenStatic=3

Dim adLockUnspecified, adLockReadOnly, adLockPessimistic, adLockOptimistic, adLockBatchOptimistic

adLockUnspecified=-1: adLockReadOnly=1: adLockPessimistic=2: adLockOptimistic=3: adLockBatchOptimistic=4

Dim adCmdUnspecified, adCmdText, adCmdTable, adCmdStoredProc, adCmdUnknown, adCmdFile, adCmdTableDirect

adCmdUnspecified=1: adCmdText=1: adCmdTable=2: adCmdStoredProc=4: adCmdUnknown=8: adCmdFile=256
adCmdTableDirect=512
Const FOR_READING = 1
Const FOR_WRITING = 2

