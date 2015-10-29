
'On Error Resume Next

includeFile "D:\datos\script\encabezado.vbs"

Debug.WriteLine now

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
Set cmd=CreateObject("ADODB.Command")
    cnn.CommandTimeout=600
	cnn.Open conexion
	cmd.ActiveConnection =  cnn
	cmd.CommandTimeout=900


'si es falso actualiza el ultimo mes y ultimo ano, si es verdadero es para actualizar en grupo
If true Then

	ano=2015
	For i=8 To 10
    	sql="delete  from compras_inventarios where ano=" &  ano & " and mes=" & i 'where ano=2015 and mes=" & Month(Now)
    	archivo="D:\datos\csv\compras_inventarios"  & (ano*100+i) & ".sql.csv"
    	'sql="delete  from v_ref_total where ano=" &  Year(Now) & " and mes=" & Month(Now) 'where ano=2015 and mes=" & Month(Now)
		cnn.Execute(sql)
		CopiarCVS2SQL Archivo, "compras_inventarios",conexion
	Next
Else
    Archivo="D:\datos\csv\compras_inventarios"  & (Year(Now)*100+Month(Now)) & ".sql.csv"
	Set fso= CreateObject("Scripting.FileSystemObject")
	If Not fso.FileExists(Archivo) Then 
		'MsgBox "No exite el archivo " & Archivo
		WScript.Quit
	End If
	'borrar datos del mes, actualizar por los nuevos
    sql="delete  from compras_inventarios where ano=" &  Year(Now) & " and mes=" & Month(Now) 'where ano=2015 and mes=" & Month(Now)
	cnn.Execute(sql)
	CopiarCVS2SQL Archivo, "compras_inventarios",conexion
    Archivo="D:\datos\csv\v_inv_doc_lin"  & (Year(Now)*100+Month(Now)) & ".sql.csv"
	If Not fso.FileExists(Archivo) Then 
		'MsgBox "No exite el archivo " & Archivo
		WScript.Quit
	End If
End If
Debug.WriteLine Time

'Next 
'Abril 23 2015 Se agrega actualizacion de vista v_inv_doc_lin con el fin de poder rasrtrear las entradas a inventarios que si sean compras.

	
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
				'Debug.Write k,rs(nombre(k)).Type
			    If rs(nombre(k)).Type=adDBTimeStamp Or rs(nombre(k)).Type=adDBTime Or  _
				   rs(nombre(k)).Type=adDBDate Or rs(nombre(k)).Type=adDate Then
				   'Debug.WriteLine nombre(k)& "=" & campo(k)
				   If campo(k)<>"" Then
				   	rs(nombre(k))=DMA2MDA(campo(k))
				   End if
				   'rs(nombre(k)=Month(rs(nombre(k))) & "/" & Day(rs(nombre(k))) & "/" &year(rs(nombre(k))) 
			    End If	
			    
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

Function DMA2MDA(fecha)

fecha=Replace(LCase(fecha),"jan","01")
fecha=Replace(LCase(fecha),"feb","02")
fecha=Replace(LCase(fecha),"mar","03")
fecha=Replace(LCase(fecha),"apr","04")
fecha=Replace(LCase(fecha),"may","05")
fecha=Replace(LCase(fecha),"jun","06")
fecha=Replace(LCase(fecha),"jul","07")
fecha=Replace(LCase(fecha),"aug","08")
fecha=Replace(LCase(fecha),"sep","09")
fecha=Replace(LCase(fecha),"oct","10")
fecha=Replace(LCase(fecha),"nov","11")
fecha=Replace(LCase(fecha),"dec","12")

Dim MM, DD, AAAA
Dim M,D
MM=""
DD=""
M=Mid(fecha,4,2)
D=Mid(fecha,1,2)
A=Mid(fecha,7,4)
'If M<10 Then 
'	MM="0" & M
'Else
'	MM=M
'End If
'If D<10 Then
'	DD="0" & D
'Else
'	DD=D
'End If
MDA=MM& "/" & DD & "/" & Year(fecha)
End Function


Sub actualizar_v_inv_doc_lin()
    ano=2015
    For mes=1 To 3
    	Archivo="D:\datos\csv\v_inv_doc_lin" + Right("0" & mes,2) & ".sql.csv"

    	sql="delete  from v_inv_doc_lin where ano=" &  ano & " and mes=" & mes 'where ano=2015 and mes=" & Month(Now)
		cnn.Execute(sql)
		CopiarCVS2SQL Archivo, "v_inv_doc_lin",conexion
	Next 

End Sub


Sub includeFile(fSpec)
    executeGlobal CreateObject("Scripting.FileSystemObject").openTextFile(fSpec).readAll()
End Sub





















