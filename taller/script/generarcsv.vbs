Dim ano,mes
Public sFLd,dFld,fs
Public objShell
Set objShell = WScript.CreateObject("WScript.Shell")
'Corre el programa entre las 6:53 y 7:07, 10:53 y 11:07, 14:53 y 15:07, 18:53 y 19:07, 22:53 y 23:07
'espera 20 segundos antes de seguir, por si se genera un error se pueda cerrar el proceso manualmente 
WScript.Sleep 20000
tiempo=time
tiempo=DateAdd("n",7,tiempo)	
Debug.WriteLine Minute(tiempo)
Debug.Write tiempo
If (Hour(tiempo)-7) Mod 4=0 And Minute(tiempo)<=14 Then
	main
End If
Sub main()
	ano=Year(Now)
	mes=Month(Now)
	
	
	
	
	Set fs=CreateObject("Scripting.FileSystemObject")
	
	sFld="D:\Taller\resultados\"
	dFld="\\tsclient\D\datos\csv\"


	runCopy "horometros.sql", ano & " " & mes	


	objShell.Run "D:\Taller\script\dms2csv.vbs res_ae.sql " & ano & " " & mes,1,True
	'fs.CopyFile sFld & "res_ae.sql.csv", dFld & "res_ae" & (ano*100+mes) & ".sql.csv"
	fs.CopyFile sFld & "res_ae.sql.csv", dFld & "res_ae.sql.csv"

	
	
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
	' Using Set is mandatory
	'Set objShell = Nothing
	objShell.Run "shutdown.exe -l"
End Sub

Sub runCopy(archivo, parametros )
	objShell.Run "D:\Taller\script\dms2csv.vbs " & archivo & " "  & parametros,1,True
	fs.CopyFile sFld & archivo & ".csv", dFld & archivo & ".csv"
End Sub

