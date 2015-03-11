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
'Dim conexion, Campos(1000), nombre(1000), n


'Dim csq, rsq

'Set csq = CreateObject("ADODB.Connection")
'Set rsq = CreateObject("ADODB.recordset")
'Set fs = CreateObject("Scripting.FileSystemObject")

conexion= "Provider=SQLNCLI11;" _
& "Server=SISTEMAS-PC\SQLEXPRESS;" _
& "Database=dbEquipos;" _
& "Integrated Security=SSPI;" _
& "DataTypeCompatibility=80;" _
& "MARS Connection=True;"


delete_records "D:\datos\csv\flt_actividad_equipos.sql.csv","Fecha", "flt_actividad_equipos",conexion
CopiarCVS2SQL "D:\datos\csv\flt_actividad_equipos.sql.csv", "flt_actividad_equipos",conexion
Set cnx=CreateObject("ADODB.Connection")
cnx.Open conexion
sql="delete from bodegas"
cnx.Execute(sql )
cnx.Close

CopiarCVS2SQL "D:\datos\csv\bodegas.sql.csv", "bodegas",conexion

Sub delete_records(Archivo, campo, tabla, conexion)
    cmp_min=Null
   cmp_max=Null
	Set fso= CreateObject("Scripting.FileSystemObject")
	If Not fso.FileExists(Archivo) Then 
		MsgBox "No exite el archivo " & Archivo
		WScript.Quit
	End If
	Set f= fso.OpenTextFile(Archivo,FOR_READING)
	'Obtener nombre de campos
	linea = f.ReadLine

	nombre=Split(linea,"æ")
	k=-9999
    For i=0 To UBound(nombre)
    	If UCase(nombre(i))=UCase(campo) Then 
    	    k=i
    	    Exit for
    	End If
     Next
     
     If k=-9999 Then
      	MsgBox "El campo no se encuentra"
      	WScript.Quit
     End If
	linea = f.ReadLine
	Campo=Split(linea,"æ")
	cmp_min=campo(k)
	cmp_max=campo(k)
	Do While f.AtEndOfStream = False
		linea = f.ReadLine
		If Right(linea,1)<>"æ" Then
			linea=linea & f.ReadLine
		End If
		Campo=Split(linea,"æ")
        If campo(k)>cmp_max Then cmp_max=campo(k)
        If campo(k)<cmp_min Then cmp_min=campo(k) 
    Loop  
    Set cnn=CreateObject("ADODB.Connection")
    cnn.Open conexion
    sql="delete  from " & tabla & " where " & nombre(k) & ">='" & cmp_min & "' and " & nombre(k) & "<='" & cmp_max & "'"
    cnn.Execute(sql )
End Sub

Sub CopiarCVS2SQL(Archivo, tabla, Strcnn)
	Dim i, linea, texto, j , k, l
	Set cnn=CreateObject("ADODB.Connection")
	Set rs=CreateObject("ADODB.recordset")
	Set cm=CreateObject("ADODB.command")	
	cnn.Open Strcnn
	'Por el momento en prueba borra todo, pero debe dejar los que se han metido pero no se han enviado a dms
    
	rs.Open tabla, cnn, adOpenKeyset, adLockOptimistic, adCmdTableDirect
	Set fso= CreateObject("Scripting.FileSystemObject")
	If Not fso.FileExists(Archivo) Then 
		MsgBox "No exite el archivo " & Archivo
		WScript.Quit
	End If
	Set f= fso.OpenTextFile(Archivo,FOR_READING)
	'Obtener nombre de campos
	linea = f.ReadLine

	nombre=Split(linea,"æ")
	't_cmp=UBound(cmp)
	nl=1
	Do While f.AtEndOfStream = False
		nl=nl+1
		linea = f.ReadLine
		If Right(linea,1)<>"æ" Then
			linea=linea & f.ReadLine
		End If
		Campo=Split(linea,"æ")
		'If (UBound(nombre)<=UBound(Campos)) Then
			rs.AddNew
			cumple=True
			For k=0 To UBound(nombre)
			    EsNulo=False
			    PermiteNulo=True
'			    If nombre(k)="id_actividad" Then
'			      If rs(nombre(k)).attributes
'			    End if
				
			    If rs(nombre(k)).Type=adBoolean Or rs(nombre(k)).Type=adBinary Then
		    		If UCase(Campo(k))="TRUE" Or UCase(Campo(k))="VERDADERO" Then
		    			rs(nombre(k))=True
		    		Else
		    		    rs(nombre(k))=False
		    		End If
		    	ElseIf Campo(k)<>"" Then
					rs(nombre(k))=Campo(k) 
				Else 
				    EsNulo=True
				    If (rs(nombre(k)).attributes And adFldMayBeNull)=adFldMayBeNull Then
						If rs(nombre(k)).Type=adChar Then
							rs(nombre(k))=""
						End If
						permiteNulo=True
					Else
						permiteNulo=False
					End If
				End If
				'Validar decimales
				If rs(nombre(k)).Type=adDecimal Or rs(nombre(k)).Type=adDouble Or rs(nombre(k)).Type=adNumeric Then
					rs(nombre(k))=CDbl(campo(k))
				
				
				End If
				'Es nulo y no se permite nulo, no guarda
				If (esnulo And Not permitenulo) then
					cumple=cumple And False 
					
				End If
			Next
			If cumple Then
				rs.Update
			Else
			    rs.cancelupdate
				cumple=False
			End If
		'Else
		'	MsgBox "Hay error en la linea " & nl & ", no coincide el numero de campos" 
		'End If
	Loop
End Sub

'Function fecha2SQL(fecha)
'	n=Split(fecha,"/")
'	return n[0]
'End Function