main
sub main()   
   Dim cn,rs,cd, sql,dir, sqlfile,dr, res

   dr="C:\Users\jose.villegas\Documents\Script\"
      sqlfile=dr & Wscript.Arguments(0)
      res="C:\Users\jose.villegas\Documents\resultados\" & Wscript.Arguments(0) & ".csv"
   set cn =CreateObject("ADODB.Connection")
   set rs= CreateObject("ADODB.Recordset")
   'cn.connectionString="Provider=SQLOLEDB;server=PC-RAMIRO\SQLEXPRESS;Database=dbST;Integrated Security=SSPI;"
                '& "DataTypeCompatibility=80; MARS Connection=True"
    cn.connectionString="Provider=SQLOLEDB;server=cchehet\mssqlserverco;Database=dms_condor;Integrated Security=SSPI;"
 
   cn.open
   '�
   sql=LeerArchivo(sqlfile)
    set fs=CreateObject("Scripting.FileSystemObject")
    If Not fs.FileExists(res) Then
        fs.CreateTextFile res
    End If       
    Set f=fs.GetFile(res)
    Set s=f.OpenAsTextStream(2,0)
    'Abre consulta leida de archivo
    rs.open sql,cn
    'Escribe encabezado
    s.Write rs.fields(0).name
    For j= 1 To  rs.Fields.Count-1
        s.Write  "�" & rs.fields(j).name 
    Next
    s.WriteLine
    'Escribe datos
    rs.MoveFirst
    Do While Not rs.EOF
        s.Write rs.fields(0).value & "�"
        For j= 1 To  rs.Fields.Count-1
            s.Write rs.fields(j).value & "�"
        Next            
        s.WriteLine
        rs.MoveNext            
    Loop
    
   rs.close
   cn.close
end sub
 
function LeerArchivo(File)
    dim texto
    texto=""
    set fs=CreateObject("Scripting.FileSystemObject")
    if fs.fileExists(File) then
        Set f=fs.GetFile(File)
        Set s=f.OpenAsTextStream(1,0)
                      
        Do While Not s.AtEndOfStream
            texto=texto & " " & s.readline
        Loop
        LeerArchivo=texto
    Else
        WScript.Quit(1)
    End if  
end function
 

Function MDA(fecha)
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
    MDA=MM& "/" & DD & "/" & Year(fecha)
End Function
