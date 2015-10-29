Dim ano,mes
Public sFLd,dFld,fs
Public objShell
main
Sub main()
	ano=Year(Now)
	mes=Month(Now)
	
	
	
	Set objShell = WScript.CreateObject("WScript.Shell")
	Set fs=CreateObject("Scripting.FileSystemObject")
	
	sFld="D:\Taller\resultados\"
	dFld="\\tsclient\D\datos\csv\"
	
	
	Debug.WriteLine "copiar Archivo de inventarios..." & ano & " " & mes
	objShell.Run "D:\Taller\script\dms2csv.vbs inventario1.sql " & ano & " " & mes,1,True
	fs.CopyFile sFld & "inventario1.sql.csv", dFld & "inventario" & (ano*100+mes) & ".sql.csv"

	objShell.Run "D:\Taller\script\dms2csv.vbs v_inv_doc_lin.sql " & ano & " " & mes,1,True
	fs.CopyFile sFld & "v_inv_doc_lin.sql.csv", dFld & "v_inv_doc_lin" & (ano*100+mes) & ".sql.csv"



	objShell.Run "D:\Taller\script\dms2csv.vbs v_ref_total.sql " & ano & " " & mes,1,True
	fs.CopyFile sFld & "v_ref_total.sql.csv", dFld & "v_ref_total" & (ano*100+mes) & ".sql.csv"		
	
	runCopy "combustible_srv.sql", ""
	runCopy "bodegas.sql",""
	
	runCopy "referencias.sql","1900-01-01 00:00:00"
	runCopy "uso_referencias.sql","20090101 " & ano & "1231"
	runCopy "pedidos.sql",""
	runCopy "pedidos_entregados.sql",""
	runCopy "pedidos_lin.sql",""
	runCopy "horometros.sql",""
	' Using Set is mandatory
	'Set objShell = Nothing
End Sub

Sub runCopy(archivo, parametros )
	objShell.Run "D:\Taller\script\dms2csv.vbs " & archivo & " "  & parametros,1,True
	fs.CopyFile sFld & archivo & ".csv", dFld & archivo & ".csv"
End Sub

