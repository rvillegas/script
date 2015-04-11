includeFile "D:\datos\script\encabezado.vbs"


Function conectarDb(db)
	conectarDb= "Provider=SQLNCLI11;" _
	& "Server=SISTEMAS-PC\SQLEXPRESS;" _
	& "Database=" & db & ";" _
	& "Integrated Security=SSPI;" _
	& "DataTypeCompatibility=80;" _
	& "MARS Connection=True;"
	
End Function


Dim fld
Set cnn=CreateObject("ADODB.Connection")
Set cn2=CreateObject("ADODB.Connection")
Set cmd=CreateObject("ADODB.Command")
Set rs=CreateObject("ADODB.recordset")
Set rs2=CreateObject("ADODB.recordset")
Set rs3=CreateObject("ADODB.recordset")


    
fld="D:\datos\script\sqlserver\"
cnn.CommandTimeout=180
cnn.Open conectardB("master")
cmd.ActiveConnection =  cnn
cmd.CommandTimeout=900

rsStr="select name from master..sysdatabases where sid<>0x01"	
rs.Open rsstr, cnn    ',adOpenDynamic,adLockOptimistic
If rs.EOF And rs.BOF Then
Else
	rs.MoveFirst
	Do While Not rs.EOF
		cn2.Open conectardB(rs(0))
		cn2.CommandTimeout=180
		rsStr="select ROUTINE_NAME,ROUTINE_TYPE from " & Trim(rs(0)) & ".INFORMATION_SCHEMA.ROUTINES"
		rs2.Open rsstr, cn2
		If rs2.EOF And rs2.BOF Then
		Else
			set fs=CreateObject("Scripting.FileSystemObject")
            res=fld & rs(0) & ".sql"
			If Not fs.FileExists(res) Then
        		fs.CreateTextFile res
    		End If       
    		Set f=fs.GetFile(res)
    		Set s=f.OpenAsTextStream(2,0)
    
 

			rs2.MoveFirst
			Do While Not rs2.EOF
				txt= "exec sp_helptext N'" & rs(0)& ".dbo."  & rs2(0) & "'"
				'Debug.Write txt
				cmd.CommandText =txt
				cmd.CommandType=1
				cmd.ActiveConnection=cn2
				s.WriteLine
				s.WriteLine "--" & rs2(0)
				s.WriteLine
				Set rs3 = cmd.Execute
				
				If rs3.EOF And rs3.BOF Then
				Else
					Do While Not rs3.EOF
					    s.Write rs3(0)
						'Debug.WriteLine 
						rs3.MoveNext
					Loop
					s.WriteLine
					s.WriteLine
				End If
				rs2.MoveNext
			Loop
		End If
		rs.MoveNext
		Set fs=Nothing
		cn2.Close
	Loop 
End If    	

Sub includeFile(fSpec)
	ExecuteGlobal CreateObject("Scripting.FileSystemObject").openTextFile(fSpec).readAll()
End Sub






