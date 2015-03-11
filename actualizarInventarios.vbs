includeFile "D:\datos\script\encabezado.vbs"



'Dim conexion, Campos(1000), nombre(1000), n


'Dim csq, rsq

'Set csq = CreateObject("ADODB.Connection")
'Set rsq = CreateObject("ADODB.recordset")
'Set fs = CreateObject("Scripting.FileSystemObject")

conexion= "Provider=SQLNCLI11;" _
& "Server=SISTEMAS-PC\SQLEXPRESS;" _
& "Database=analisisInventarios;" _
& "Integrated Security=SSPI;" _
& "DataTypeCompatibility=80;" _
& "MARS Connection=True;"

Set cnn=CreateObject("ADODB.Connection")
	cnn.Open conexion
	'Archivo="D:\datos\csv\inventario2.sql.csv"
    Archivo="D:\datos\csv\inventario" & (Year(Now)*100+Month(Now)) & ".sql.csv"
	Set fso= CreateObject("Scripting.FileSystemObject")
	If Not fso.FileExists(Archivo) Then 
		'MsgBox "No exite el archivo " & Archivo
		WScript.Quit
	End If


'For i=12 To 11
	'borrar datos del mes, actualizar por los nuevos
    'sql="delete  from inventarios where ano=2015 and mes=2" 
    sql="delete  from inventarios where ano=" & Year(Now) & " and mes=" & Month(Now)
	cnn.Execute(sql)
	CopiarCVS2SQL Archivo, "inventarios",conexion

'Next 
	If fso.FileExists("D:\datos\csv\referencias.sql.csv") Then 
    	sql="delete  from referencias"
		cnn.Execute(sql)
		CopiarCVS2SQL "D:\datos\csv\referencias.sql.csv", "referencias",conexion
	End If

	If fso.FileExists("D:\datos\csv\uso_referencias.sql.csv") Then 	
    	sql="delete  from uso_referencias"
		cnn.Execute(sql)
		CopiarCVS2SQL "D:\datos\csv\uso_referencias.sql.csv", "uso_referencias",conexion
	End If
	
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
		'MsgBox "No exite el archivo " & Archivo
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
				
					If campo(k)="" Then
						rs(nombre(k))=0
					Else
						rs(nombre(k))=CDbl(campo(k))
					End If
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


Sub includeFile(fSpec)
    executeGlobal CreateObject("Scripting.FileSystemObject").openTextFile(fSpec).readAll()
End Sub





















