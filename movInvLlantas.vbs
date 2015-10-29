
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
& "Server=PC-RAMIRO\SQLEXPRESS;" _
& "Database=dbInvLlantas;" _
& "Integrated Security=SSPI;" _
& "DataTypeCompatibility=80;" _
& "MARS Connection=True;"
cnn.Open conexion


If Wscript.Arguments.Count=0 Then
	WScript.Quit
End If
fini=Wscript.Arguments(0)
ffin=Wscript.Arguments(1)

mov_inv fini, ffin

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
		
			If pt>3000.0  Then
				dur=3000.0
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
