'Este proceso debe correr cada 15 minutos
'1- Verifica cual es la ultima fecha de aviso de fallas
'2- desde la ultima fecha verifica que nuevas fallas de han aparecido
'3- De cada equipo, falla verifica ultima fecha de aviso, si es mayor de 24 horas, avisa

'4-Cuando haya cambio de dia, envia correo de resumen de fallas del dia


'1-Ejecuta la siguiente consulta para conocer la lultima fecha de falla avisada

'  ultimafecha=SELECT top 1 [UltimaFecha] FROM [dbST].[dbo].[avisoFalla] order by ultimafecha desc

Dim adOpenUnspecified, adOpenForwardOnly, adOpenKeyset, adOpenDynamic, adOpenStatic
adOpenUnspecified=-1: adOpenForwardOnly=0: adOpenKeyset=1: adOpenDynamic=2: adOpenStatic=3
Dim adLockUnspecified, adLockReadOnly, adLockPessimistic, adLockOptimistic, adLockBatchOptimistic
adLockUnspecified=-1: adLockReadOnly=1: adLockPessimistic=2: adLockOptimistic=3: adLockBatchOptimistic=4
Dim adCmdUnspecified, adCmdText, adCmdTable, adCmdStoredProc, adCmdUnknown, adCmdFile, adCmdTableDirect
adCmdUnspecified=1: adCmdText=1: adCmdTable=2: adCmdStoredProc=4: adCmdUnknown=8: adCmdFile=256
adCmdTableDirect=512
Const FOR_READING = 1
Const FOR_WRITING = 2

conexion= "Provider=SQLNCLI11;" _
& "Server=SISTEMAS-PC\SQLEXPRESS;" _
& "Database=dbST;" _
& "Integrated Security=SSPI;" _
& "DataTypeCompatibility=80;" _
& "MARS Connection=True;"

Set cnx=CreateObject("ADODB.Connection")
Set cmd=CreateObject("ADODB.Command")
Set rst=CreateObject("ADODB.recordset")
Set rs2=CreateObject("ADODB.recordset")
Set rs3=CreateObject("ADODB.recordset")
Set rs4=CreateObject("ADODB.recordset")
cnx.Open conexion
sql="SELECT top 1 [UltimaFecha] FROM [dbST].[dbo].[avisoFalla] order by ultimafecha desc"
cmd.ActiveConnection=cnx
cmd.CommandText=sql
Set rst=cmd.Execute
ultimafecha=rst(0)

Debug.WriteLine rst(0)
rst.close
'2-Hace la siguiente consulta para seleccionar las fallas que todavia no se han avisaDO

sql="SELECT [Matricula],[FMI],[CodigoError],max(fecha) as ultfecha,count(*)  FROM [dbo].[fallas] where fecha> '" & MDAHHMMSS(UltimaFecha) & "' " & _
"group by matricula,codigoerror,fmi order by matricula,codigoerror,fmi"
	Debug.WriteLine SQL
rst.Open sql,cnx,adOpenDynamic,adLockOptimistic
Debug.WriteLine RST.EOF, rst.RecordCount
Do While Not rst.EOF 
    sql="SELECT [Matricula],[UltimaFecha],[spn],[fmi] FROM [dbo].[avisoFalla] " & _
	" where matricula='" & rst("Matricula") & "' and spn=" & rst("codigoError") & _
	" and fmi=" & rst("fmi") & " and fechaAviso>=dateadd(day,-1,getdate())"
    Debug.WriteLine sql
	rs2.Open  sql,cnx,adOpenDynamic,adLockOptimistic
'3-Esta consulta se hace a cada equipo, falla, si aparece por lo menos un registro quiere decir que ya se aviso een las ultimas 24 horas	
	sql="SELECT top 1 [equipo],[bodega],count(*) FROM [dbo].[Tanqueos_dms] " & _
		" where equipo='" & rst("matricula") &"' and fecha>=dateadd(day,-60,getdate()) " & _
		" group by equipo,bodega order by count(*) desc "
'5-Verificar donde esta el equipo:
	rs4.Open  sql,cnx,adOpenDynamic,adLockOptimistic
	
	If Not (rs4.EOF And rs4.BOF) Then
		bodega=rs4("bodega")	
	
	Else
		bodega=0
	End If
	
	rs4.close
	If (rs2.EOF And rs2.BOF) Then
		'Hay que avisar
			Debug.WriteLine "Enviar correo" ,rst(0), rst(1),rst(2),rst(3)
			rs3.Open "select * from avisoFalla",  cnx,adOpenDynamic,adLockOptimistic
			rs3.AddNew
			rs3("Matricula")=rst("Matricula")
			rs3("spn")=rst("codigoError")
			rs3("fmi")=rst("fmi")
			rs3("UltimaFecha")=rst("ultfecha")
			rs3("fechaAviso")=Now
		  	rs3("email")="pendiente"
		  	rs3("bodega")=bodega		
			rs3.Update
			rs3.close
	End If
    rs2.close
	rst.MoveNext
Loop
rst.Close

'Organiza por bodega y equipo y envia los emails
sql= 	"SELECT avisoFalla.Matricula, avisoFalla.UltimaFecha, avisoFalla.FechaAviso, avisoFalla.email, avisoFalla.spn, avisoFalla.fmi, " & _
		" avisoFalla.bodega, fmi.descripcion AS fmi_, spn.descripcion AS spn_, emails.email AS emails, fallas.Fecha, fallas.MIL, fallas.Warning, " & _
		" fallas.Protect, fallas.Stop " & _
		" FROM avisoFalla LEFT OUTER JOIN fallas ON avisoFalla.fmi = fallas.FMI AND avisoFalla.spn = fallas.CodigoError AND " & _
		" avisoFalla.UltimaFecha = fallas.Fecha AND avisoFalla.Matricula = fallas.Matricula LEFT OUTER JOIN " & _
		" spn ON avisoFalla.spn = spn.codigo LEFT OUTER JOIN emails ON avisoFalla.bodega = emails.bodega LEFT OUTER JOIN " & _
        " fmi ON avisoFalla.fmi = fmi.codigo " & _
        " WHERE        (avisoFalla.email = 'pendiente') " & _
        " ORDER BY avisoFalla.bodega, avisoFalla.Matricula "
 
res="C:\Users\sistemas\Desktop\logemails.txt" 
set fs=CreateObject("Scripting.FileSystemObject")
    If Not fs.FileExists(res) Then
        fs.CreateTextFile res
    End If       
    Set f=fs.GetFile(res)
    Set s=f.OpenAsTextStream(8,0)
s.WriteLine 
s.WriteLine 
s.WriteLine 
s.WriteLine "<html><body>"     
s.WriteLine "Fecha:" & Now  & "</BR>"
rst.Open sql,cnx,adOpenDynamic,adLockOptimistic
bodega=-9999
equipo="sdsdssw"
If Not(rst.EOF And rst.BOF) Then
	rst.MoveFirst
	Do While Not rst.EOF
		If bodega<>rst("bodega") Then
			bodega=rst("bodega")
			s.WriteLine "para:" & rst("emails")& "</BR>"
			s.WriteLine "de: skytracking"& "</BR>"
			s.WriteLine"Asunto: Fallas en equipos de la bodega " & rst("bodega")& "</BR>"
			s.WriteLine 
			s.WriteLine "Se han presentado las siguientes fallas:"& "</BR>"
			s.WriteLine "<TABLE border='1'>"			
			s.WriteLine	"<TR><TH>Equipo</TH><TH>Fecha</TH><TH>spn</TH><TH>fmi</TH><TH>descripcion</TH><TH>MI</TH><TH>Warning</TH><TH>protect</TH><TH>stop</TH></TR>"
		End If		
		
		s.WriteLine "<TR><td>" &  rst("matricula") & "</td><td>" & rst("UltimaFecha") & "</td><td>" & rst("spn") & "</td><td>" & rst("fmi") & "</td><td>" & trim(rst("spn_")) & " - " & trim(rst("fmi_")) & "</td><td>" &  rst("MIL") & "</td><td>" &  rst("Warning") & "</td><td>" &  rst("protect") & "</td><td>" & rst("stop") & "</td></tr>"
		rst.MoveNext
		
		If rst.EOF Then
			s.WriteLine	 "</table>"
			s.WriteLine	 "saludos y find de l archivo"& "</BR>"
			s.WriteLine	"----------------------------------------------------------"& "</BR>"
		Elseif	bodega<>rst("bodega") Then
			s.WriteLine	
			s.WriteLine	 "saludos y find de l archivo"
			s.WriteLine	"----------------------------------------------------------"& "</BR>"
			 
		End if
	Loop
End If
s.WriteLine "</body></html>" 
s.Close
'Actualiza emails en avisoFallas

cmd.ActiveConnection=cnx



sql="UPDATE [dbo].[avisoFalla] SET [email] =(Select top 1 email from emails where bodega=dbo.avisofalla.bodega) WHERE email='pendiente'"
cmd.CommandText=sql
cmd.Execute

Sub envio_email(destinatario)
	Set objMessage = CreateObject("CDO.Message") 
	objMessage.Subject = "Example CDO Message" 
	objMessage.From = "ramirovilegasisaza@gmail.com" 
	objMessage.To = "ramiro.villegas@elcondor.com" 
	objMessage.TextBody = "This is some sample message text."
	
	'==This section provides the configuration information for the remote SMTP server.
	'==Normally you will only change the server name or IP.
	objMessage.Configuration.Fields.Item _
	("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2 
	
	'Name or IP of Remote SMTP Server
	objMessage.Configuration.Fields.Item _
	("http://schemas.microsoft.com/cdo/configuration/smtpserver") = "smtp.gmail.com"
	
	'Server port (typically 25)
	objMessage.Configuration.Fields.Item _
	("http://schemas.microsoft.com/cdo/configuration/smtpserverport") =465 
	objMessage.Configuration.Fields.Item _ 
	("http://schemas.microsoft.com/cdo/configuration/smtpusessl") = True 
	objMessage.Configuration.Fields.Item _
	("http://schemas.microsoft.com/cdo/configuration/smtpauthenticate") = 1
	objMessage.Configuration.Fields.Item _
	("http://schemas.microsoft.com/cdo/configuration/smtpusessl") = True
	objMessage.Configuration.Fields.Item _
	("http://schemas.microsoft.com/cdo/configuration/smtpconnectiontimeout") = 60
	objMessage.Configuration.Fields.Item _
	("http://schemas.microsoft.com/cdo/configuration/sendusername") = "elcondorequipos@gmail.com"
	objMessage.Configuration.Fields.Item _
	("http://schemas.microsoft.com/cdo/configuration/sendpassword") = "elcondor2014+"
	
	
	
	objMessage.Configuration.Fields.Update
	
	'==End remote SMTP server configuration section==
	
	objMessage.Send
End Sub

Function DMA(fecha)
Dim MM, DD, AAAA
Dim M,D
MM=""
DD=""
M=Month(fecha)
D=Day(fecha)
A=Year(fecha)
If M<10 Then 
	MM="0" & M
Else
	MM=M
End If
If D<10 Then
	DD="0" & D
Else
	DD=D
End If
DMA=DD& "/" & MM & "/" & Year(fecha)
End Function

Function MDAHHMMSS(fecha)
	Dim MM, DD, AAAA
	Dim M,D
	MM=""
	DD=""
	M=Month(fecha)
	D=Day(fecha)
	A=Year(fecha)
	H=Hour(fecha)
	N=Minute(fecha)
	S=Second(fecha)
	
	If M<10 Then 
		MM="0" & M
	Else
		MM=M
	End If
	
	If D<10 Then
		DD="0" & D
	Else
		DD=D
	End If
	
	If H<10 Then
		HH="0" & H
	Else
		HH=H
	End If
	
	If N<10 Then
		NN="0" & N
	Else
		NN=N
	End If
	
	If S<10 Then
		SS="0" & S
	Else
		SS=S
	End If
	
	
	MDAHHMMSS=MM & "/" & DD & "/" & Year(fecha) & " " & HH & ":" & NN & ":" & SS 
End Function

Function AMDHMS(fecha)
	Dim MM, DD, AAAA
	Dim M,D
	MM=""
	DD=""
	M=Month(fecha)
	D=Day(fecha)
	A=Year(fecha)
	H=Hour(fecha)
	N=Minute(fecha)
	S=Second(fecha)
	
	If M<10 Then 
		MM="0" & M
	Else
		MM=M
	End If
	
	If D<10 Then
		DD="0" & D
	Else
		DD=D
	End If
	
	If H<10 Then
		HH="0" & H
	Else
		HH=H
	End If
	
	If N<10 Then
		NN="0" & N
	Else
		NN=N
	End If
	
	If S<10 Then
		SS="0" & S
	Else
		SS=S
	End If
	
	
	AMDHMS=Year(fecha) & "-" & MM & "-" & DD & " " & HH & ":" & NN & ":" & SS 
End Function