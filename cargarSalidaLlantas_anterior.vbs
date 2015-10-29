
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
Set cnn=CreateObject("ADODB.Connection")
Set rs=CreateObject("ADODB.recordset")
Set rs1=CreateObject("ADODB.recordset")
Set rs2=CreateObject("ADODB.recordset")
Set rs3=CreateObject("ADODB.recordset")
'Dim conexion, Campos(1000), nombre(1000), n


'Dim csq, rsq


conexion= "Provider=SQLNCLI11;" _
& "Server=SISTEMAS-PC\SQLEXPRESS;" _
& "Database=dbInvLlantas;" _
& "Integrated Security=SSPI;" _
& "DataTypeCompatibility=80;" _
& "MARS Connection=True;"
cnn.Open conexion

'mov_inv "2015-01-01", "2015-08-01"

sql="delete from horometros where year(sFecha)=" & Year(Now) & " and month(sFecha)=" & Month(Now)
cnn.Execute(sql )
CopiarCVS2SQL "D:\datos\csv\horometros.sql.csv","horometros",conexion

sql="delete  from salidas"
cnn.Execute(sql)

CopiarCVS2SQL "D:\datos\csv\llantas.sql.csv","salidas",conexion
sql="update salidas set horometro_final=(select dbo.hor(equipo,fecha)), tipo='SALIDA', pc_vida=0"
cnn.Execute(sql)

sql="INSERT INTO [dbo].[salidas] ([equipo],[tipo_llanta],[fecha],[horometro_final],cnt,tipo,pc_vida,bodega) " & _
" select equipo,tipo_llanta,fecha,horometro_final,cnt,tipo_ajuste, pc_vida,bodega from ajustes "
cnn.Execute(sql)
'sql="UPDATE [dbo].[salidas] set tipo_llanta='TRACCION'"
'cnn.Execute(sql)	



sql="Delete from horometros_llanta"
cnn.Execute(sql)	
If rs.State=1 Then rs.close
rs.open "Select *  FROM [dbInvLlantas].[dbo].[salidas] order by equipo, tipo_llanta, fecha",cnn
If rs.EOF And rs.EOF Then
Else
	i=1
	rs.MoveFirst
	uEq="xsxs"
	uTi="fsahg"
	ufe=#1-1-1900#
	Do While Not rs.EOF
		If uEq=rs("equipo") And uTi=rs("tipo_llanta") And ufe=rs("fecha") Then
			'hay dos salidas el mismo dia al mismo equipo, las suma
			i=i-1
			rs("id")=i
			rs.MovePrevious
			rs("id")=-9999
			uCa=rs("cnt")
			rs.update
			rs.MoveNext
			rs("cnt")=rs("cnt")+uCa
		Else	
			
			rs("id")=i
			rs.Update
		End If
		uEq=rs("equipo")
		uTi=rs("tipo_llanta")
		ufe=rs("fecha")
		rs.MoveNext
		i=i+1
	Loop	 
End If
sql="Delete from salidas where id=-9999"
cnn.Execute(sql)
'calcular los horometros
generar_mtx_hr_llantas
'mov_inv "2015-01-01", "2015-08-01"


Sub vida_llantas(eq,t_ll, fe,dur, pc_vida, hf, hr, fecha,cnt,pv)
	sql="SELECT TOP 1 [fecha], [horometro_final],[cnt] ,[sumHor] ,[prom] ,[prom_tendido] ,[pc_vida] ,[tipo], " & _
	" dbInvLlantas.dbo.hor(equipo,'" & fe & "') as hor " & _
	" FROM [dbInvLlantas].[dbo].[salidas] where equipo='" & eq & "' and fecha<='" & fe & "' and tipo_llanta='" & t_ll &"' order by fecha desc"
	dur=0.0
	pc_vida=0.0	
	If rs.State=1 Then rs.Close
	rs.Open sql,cnn
	If rs.EOF And rs.BOF Then
		pc_vida=0.0
	Else
		rs.MoveFirst
		pv=CDbl(rs("pc_vida"))
		hr=CDbl(rs("hor"))
		hf=CDbl(rs("horometro_final"))
		cnt=CDbl(rs("cnt"))
		fecha=CDate(rs("fecha"))
		If IsNull(rs("prom_tendido")) Then
			dur=1500.0
		Else
			pt=CDbl(rs("prom_tendido"))
		
			If pt>2000.0  Then
				dur=2000.0
			ElseIf pt<1000.0 Then 
				dur=1000.0
			Else
				dur = pt
			End If
		End If		
		If rs("hor")<rs("horometro_final") Then
			pc_vida=CDbl(rs("pc_vida"))
		Else
			pc_vida=pv-(hr-hf)/dur
			If pc_vida>1.0 Then pc_vida=1.0
			If pc_vida<0.0 Then pc_vida=0.0
		End If
	End If
	rs.close	
	
	'Se haya el ultimo movimiento
	
End Sub

'Function cnt(eq,tr_ll,fini,ffin)
	
	'SELECT sum(isnull(cnt,0))
	
	' FROM [dbInvLlantas].[dbo].[salidas]
	'where fecha>='01-01-2014' and fecha<='12-31-2014' and equipo='VD-223' and tipo_llanta='TRACCION'
	
'End Function


Sub mov_inv(fini,ffin)
	sql="delete from inventario"
	cnn.Execute(sql)
	If rs1.State=1 Then rs1.Close
	If rs2.State=1 Then rs2.close
	rs2.Open "select * from inventario",cnn,adOpenDynamic,adLockOptimistic
	rs1.Open "SELECT distinct equipo,tipo_llanta FROM [dbInvLlantas].[dbo].[salidas]  order by equipo, tipo_llanta",cnn
	'saca todos los equipo, con tipo de llantas que existen en el archivo
	rs1.MoveFirst
	Do While Not rs1.EOF
		
		rs2.AddNew
		rs2("equipo")=rs1("equipo")
		rs2("tipo_llanta")=rs1("tipo_llanta")
		pt2=0:vi2=0:ho2=0:hi2=0:fe2=#1/1/1900#	
        du2=0:vf2=0:hf2=0:ca2=0:pv2=0:pv1=0.0
		vida_llantas rs1("equipo"), rs1("tipo_llanta"), fini, pt2, vi2, ho2,     hi2, fe2,  ca2, pv2
		ca2=0
		vida_llantas rs1("equipo"), rs1("tipo_llanta"), ffin, du2, vf2, hor_fin, hf2, fecha,ca2, pv1
		rs2("prom_tendido")=pt2
		rs2("vid_ini")=vi2
		rs2("horometro")=ho2
		rs2("hor_ini")=hi2
		rs2("fecha")=fe2
	    rs2("duracion")=du2
	    rs2("vid_fin")=vf2
	    rs2("hor_fin")=hf2
	    If rs3.State=1 Then rs3.Close
	    rs3.Open "SELECT isnull(sum([cnt]),0) frOM [dbo].[salidas] where equipo='" & rs1("equipo") & _
	              "' and tipo_llanta='" & rs1("tipo_llanta") & _
	              "' and fecha>='" & fini & "' and fecha<'" & ffin & "'",cnn
	              
		ca2=0
	    If rs3.EOF And rs3.BOF Then
		Else
			ca2=rs3(0)
		End If
        rs3.close	    
      	cons = (CDbl(vi2) - CDbl(vf2))*num_llantas(rs1("tipo_llanta"))+ca2	
		rs2("consumo")=cons
		rs2("cnt")=ca2
		rs2("fec_ini")=fini
		rs2("fec_fin")=ffin
		rs2("horas_uso")=hf2-hi2		
		rs2("pc_vida")=pv2
		rs2.Update
		rs1.MoveNext	
	Loop	
End Sub

Sub generar_mtx_hr_llantas()
	Dim aHr(20), n_ll
	i = 2
	cHor=0
	uEq = "XXXXSSS"
	uTi = "sdfsdfsd"
	vPv=0
	If rs.State=1 Then rs.close
	rs.open "Select *  FROM [dbInvLlantas].[dbo].[salidas] order by equipo, tipo_llanta, fecha",cnn,adOpenDynamic,adLockOptimistic
	If rs.BOF And rs.EOF Then
		Exit Sub
	End If
	rs.movefirst
	Do While Not rs.EOF
		uHo = rs("horometro_final")
		uCa = rs("cnt")
		If rs("tipo")="CAMBIOHOR" Then
			'cHor=rs("horometro_final")+cHor
		'ElseIf rs("tipo")="Revisión" Then		
			
		Else 		
			If uEq <> rs("equipo") Or uTi <> rs("tipo_llanta") Then

			    
				cHor=0		'ajuste por cambio de hormoimetro todavia no esta implementado
				n_ll = num_llantas(rs("tipo_llanta"))
				'Carga el primer horometro para todas las llantas
				If rs1.State=1 Then rs1.close
				rs1.Open "Select * from horometros_llanta",cnn,adOpenDynamic,adLockOptimistic
				For j = 1 To n_ll
					rs1.AddNew
					rs1("id")=rs("id")
					rs1("seq")=j
					rs1("hor")=uHo+cHor
					rs1.update
				Next
				sumHr=(uHO+cHor)*n_ll
				rs("sumHor")=sumHr
				rs.update
				rs1.Close
				
				sum_ll=0
				prom_t=0
				uEq = rs("equipo")
				uTi = rs("tipo_llanta")
				uPv=rs("pc_vida")	
		Else
				'Copia los horometros del ultimo cambio de llantas al nuevo registro
				Debug.WriteLine rs("id")
				sId_ant=rs("id")-1
				If rs1.State=1 Then rs1.Close    
				If rs2.State=1 Then rs2.Close   
				rs1.Open "Select * from horometros_llanta where id=" & sId_ant & " order by id, hor",cnn
				rs2.Open  "Select * from horometros_llanta",cnn,adOpenDynamic,adLockOptimistic
				For j = 1 To n_ll
					rs2.addnew
					rs2("id")=rs("id")
					rs2("seq")=j
					rs2("hor")=rs1("hor")
					rs2.Update
					rs1.MoveNext
				Next
				rs2.Close
				'Actualiza los horometros de las llantas nuevas por el ultimo hormometro
				rs2.Open "Select * from horometros_llanta where id=" & rs("id") & " order by id, hor",cnn,adOpenDynamic,adLockOptimistic        
				rs2.MoveFirst
				If uCa>n_ll Then uCa=n_ll
				For j = 1 To uCa
					rs2("hor")=uHO
					rs2.Update
					rs2.MoveNext
				Next
				rs2.Close
				rs2.Open  "SELECT sum(hor)FROM [dbo].[horometros_llanta] where id=" & rs("id"),cnn
				rs2.MoveFirst
				uSumHr=sumHr
				sumHr=rs2(0)
				       
				If rs("cnt")<>0 Then
					If Not IsNull(rs("prom")) Then
						uprom=rs("prom")
					End If
					prom=(sumHr-uSumHr)/rs("cnt")
					If prom<0 Then prom=0
				End If
				rs("sumHor")=rs2(0)
				If rs("tipo")="SALIDA" Then
					
					rs("prom")= prom
					sum_ll=sum_ll+rs("cnt")
					If sum_ll>=n_ll Then
						prom_t=(prom_t*(n_ll-rs("cnt"))+sumHr-uSumHr)/n_ll
						rs("prom_tendido")=prom_t
						rs("horas_uso")=n_ll*uHo-sumHr
						dur=prom_t
						If prom_t>2000 Then
							dur=2000
						ElseIf prom_t<1000 Then 
							dur=1000
						End If
						pcv=(1-(n_ll*uHo-sumHr)/n_ll/dur)
						If pcv>1 Then pcv=1
						If pcv<0 Then pcv=0
							rs("pc_vida")=pcv
						Else
							If sum_ll>0 Then
							prom_t=(prom_t*(sum_ll-rs("cnt"))+(sumHr-uSumHr))/sum_ll
						End If
					End If
				ElseIf  rs("tipo")="Revisión" Then
					If sum_ll>=n_ll Then
						'variación del % de vida entre las dos medidas
					    d_pv=(upv-rs("pc_vida"))
						uPv=rs("pc_vida")
						u_prom_t=prom_t
						If d_pv>0 Then
							prom_t=((sumHr-uSumHr)/n_ll)/dpv
						ElseIf d_pv=0 Then
							prom_t=u_prom_t
						Else
							'la vida aumentó
							'debe haber una marca en el registro para que se revise
							prom_t=u_prom_t
						End If
						rs("prom")= prom_t
						rs("prom_tendido")=prom_t
						rs("horas_uso")=n_ll*uHo-sumHr
					End If			
				End If
				rs.update
			End If
		End If
		rs.MoveNext
	Loop
End Sub

'Funcion define numero de llantas
Function num_llantas(tipo)

	If tipo = "TRACCION" Then
		num_llantas = 8.0
	ElseIf tipo = "DIRECCION" Then
		num_llantas = 2.0
	Else
		num_llantas = 0.0
	End If
	
End Function 

Sub CopiarCVS2SQL(Archivo, tabla, Strcnn)
	Dim i, linea, texto, j , k, l
	Set rs=CreateObject("ADODB.recordset")
	Set cm=CreateObject("ADODB.command")
	If cnn.State=1 Then cnn.close	
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
		'rs("id")=nl-1
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
			If (esnulo And Not permitenulo) Then
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

