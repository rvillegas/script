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
    Archivo="D:\datos\csv\pedidos.sql.csv"
	Set fso= CreateObject("Scripting.FileSystemObject")
	If Not fso.FileExists(Archivo) Then 
		'MsgBox "No exite el archivo " & Archivo
		WScript.Quit
		
	Else
	    sql="delete  from ped_tmp"
		cnn.Execute(sql)
		CopiarCVS2SQL Archivo, "ped_tmp",conexion
	End if
	
    Archivo="D:\datos\csv\pedidos_lin.sql.csv"
	Set fso= CreateObject("Scripting.FileSystemObject")
	If Not fso.FileExists(Archivo) Then 
		'MsgBox "No exite el archivo " & Archivo
		WScript.Quit
		
	Else
	    sql="delete  from lin_ped_tmp"
		cnn.Execute(sql)
		CopiarCVS2SQL Archivo, "lin_ped_tmp",conexion
	End If
    



'	If fso.FileExists("D:\datos\csv\referencias.sql.csv") Then 
'    	sql="delete  from referencias"
'		cnn.Execute(sql)
'		CopiarCVS2SQL "D:\datos\csv\referencias.sql.csv", "referencias",conexion
'	End If

'	If fso.FileExists("D:\datos\csv\uso_referencias.sql.csv") Then 	
'    	sql="delete  from uso_referencias"
'		cnn.Execute(sql)
'		CopiarCVS2SQL "D:\datos\csv\uso_referencias.sql.csv", "uso_referencias",conexion
'	End If
	
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
'			    If k=3 Then
'			    Debug.WriteLine nombre(k),campo(k),rs(nombre(k)).Type
'			     i=i
			    'End if
			    EsNulo=False
			    PermiteNulo=True
'			    If nombre(k)="id_actividad" Then
'			      If rs(nombre(k)).attributes
'			    End if
				If rs(nombre(k)).Type=adDBTimeStamp Or rs(nombre(k)).Type=adDBTime Or  _
				   rs(nombre(k)).Type=adDBDate Or rs(nombre(k)).Type=adDate Then
				   'Debug.WriteLine nombre(k)& "=" & campo(k)
				   If campo(k)<>"" Then
				   	rs(nombre(k))=txt2Ado(campo(k))
				   End if
				   'rs(nombre(k)=Month(rs(nombre(k))) & "/" & Day(rs(nombre(k))) & "/" &year(rs(nombre(k))) 
				
			    ElseIf rs(nombre(k)).Type=adBoolean Or rs(nombre(k)).Type=adBinary Then
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

Function txt2Ado(sFecha)
    'primero divide entre fecha y hora
    
    p=Split(sfecha," ")
    'Segundo divide entre mes,dia, año
    s=Split(p(0),"/")
    mes=s(0)
    dia=s(1)
    ano=s(2)
    
    txt2Ado=dia & "/" & mes & "/" & ano
    
    If UBound(p)>=1 Then
    	txt2Ado=txt2Ado+" "+p(1)
    End if
     If UBound(p)>=2 Then
    	txt2Ado=txt2Ado+" "+p(2)
    End if   
    
    
    
'	n=Split(fecha,"/")
'	return n[0]
End Function


Sub includeFile(fSpec)
    executeGlobal CreateObject("Scripting.FileSystemObject").openTextFile(fSpec).readAll()
End Sub





















