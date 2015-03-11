'Cambios de VBA a VBScript
'En Dim se quita el tipo de variable
'En Next se quita la variable
'Exit Sub se reem´plaza por WScript.Quit
'Set var=new adodb.
Dim fs,File, tiempoInicio, Lapso
tiempoInicio=Timer()
Set fs = CreateObject("Scripting.FileSystemObject")
Do While Not fs.FileExists("\\Tsclient\c\Planta\almacen.mdb")

Lapso=Timer()-tiempoInicio
If Lapso>60 Then
	MsgBox "Paso mas de 1 minuto y el servidor no encuentra la base de datos, volver a intentar"
	WScript.Quit
End If
Loop

Dim InTrans, Vcodigo, Vcosto

Dim i, nreg, CodigoCta,nit, Origen,  VtipoDcto, VcodInt, vTipoMvto,dfecha
Dim errores(100),fte,Catalogo
Dim Dbs, db, rs
Dim DaoTrans, primerRegistro, sa, dt, st, sd
Dim NroDoc
DaoTrans=True
If WScript.Arguments.Count < 2 Then
	'MsgBox "Faltan Argumentos"
	'WScript.Quit
Else	
	fte=WScript.Arguments.Item(0)
	Catalogo=WScript.Arguments.Item(1)
End If
fte="Combustible"
Catalogo="Pruebas"
dfecha = Int(Now)
NroDoc=0

'Informacion de ADO para vbs en http://www.w3schools.com/ado/
'CursorTypeEnum Values
'adOpenUnspecified,	-1	Unspecified type of cursor
'adOpenForwardOnly	0	Default. A forward-only cursor. This improves performance when you need to make only one pass
'				through a Recordset
'adOpenKeyset		1	A keyset cursor. Like a dynamic cursor, except that you can't see records that other users add,
'				although 'records that other users delete are inaccessible from your Recordset. Data changes by '	'				other users are still visible.
'adOpenDynamic	2		A dynamic cursor. Additions, changes, and deletions by other users are visible, and all types of '	'				movement 'through the Recordset are allowed
'adOpenStatic	3		A static cursor. A static copy of a set of records that you can use to find data or generate
'				reports. 'Additions, changes, or deletions by other users are not visible.


'LockTypeEnum Values

'adLockUnspecified	-1	Unspecified type of lock. Clones inherits lock type from the original Recordset.
'adLockReadOnly	1	Default. Read-only records
'adLockPessimistic	2	Pessimistic locking, record by record. The provider lock records immediately after editing
'adLockOptimistic	3	Optimistic locking, record by record. The provider lock records only when calling update
'adLockBatchOptimistic	4	Optimistic batch updates. Required for batch update mode

'CommandTypeEnum Values


'adCmdUnspecified	-1	Unspecified type of command
'adCmdText	1		Evaluates CommandText as a textual definition of a command or stored procedure call
'adCmdTable	2		Evaluates CommandText as a table name whose columns are returned by an SQL query
'adCmdStoredProc	4	Evaluates CommandText as a stored procedure name
'adCmdUnknown	8	Default. Unknown type of command
'adCmdFile	256		Evaluates CommandText as the file name of a persistently stored Recordset. Used with 
'				Recordset.Open or Requery only.
'adCmdTableDirect	512	Evaluates CommandText as a table name whose columns are all returned. Used with
'				Recordset.Open or Requery only. To use the Seek method, the Recordset must be opened
' 				with adCmdTableDirect. Cannot be 'combined with the ExecuteOptionEnum value
'				 adAsyncExecute.

'

Const dbOpenTable=1

dim adOpenUnspecified, adOpenForwardOnly, adOpenKeyset, adOpenDynamic, adOpenStatic

adOpenUnspecified=-1: adOpenForwardOnly=0: adOpenKeyset=1: adOpenDynamic=2: adOpenStatic=3

dim adLockUnspecified, adLockReadOnly, adLockPessimistic, adLockOptimistic, adLockBatchOptimistic

adLockUnspecified=-1: adLockReadOnly=1: adLockPessimistic=2: adLockOptimistic=3: adLockBatchOptimistic=4

dim adCmdUnspecified, adCmdText, adCmdTable, adCmdStoredProc, adCmdUnknown, adCmdFile, adCmdTableDirect

adCmdUnspecified=1: adCmdText=1: adCmdTable=2: adCmdStoredProc=4: adCmdUnknown=8: adCmdFile=256
adCmdTableDirect=512


Dim cnn, mtm, mtl, sal, cen

set cnn=CreateObject("ADODB.Connection")
set con=CreateObject("ADODB.recordset")
set tra=CreateObject("ADODB.recordset")
set mvt=CreateObject("ADODB.recordset")
set cst=CreateObject("ADODB.recordset")

'cnn.Open "PROVIDER=sqloledb ; Data Source=ADMCORP1\PROCOPAL;Initial Catalog=Procopal;Integrated Security=sspi;"
'objRecordset.Open source,actconn,cursortyp,locktyp,opt

cnn.Open "PROVIDER=sqloledb ; Data Source=ADMCORP2;Initial Catalog=" & Catalogo & ";Integrated Security=sspi;"
tra.Open "trade", cnn, adOpenKeyset, adLockOptimistic, adCmdTableDirect
mvt.Open "mvtrade", cnn, adOpenKeyset, adLockOptimistic, adCmdTableDirect
con.Open "consecut", cnn, adOpenKeyset, adLockOptimistic, adCmdTableDirect


Set Dbs = CreateObject("DAO.DBEngine.36")
'Dim ws As Workspace: Set ws = DBEngine.Workspaces(0)
Set db = Dbs.OpenDatabase("\\Tsclient\c\Planta\almacen.mdb")



Set sa = db.OpenRecordset("salalm", dbOpenTable)
Set dt = db.OpenRecordset("detsalalm", dbOpenTable)
Set st = db.OpenRecordset("SalTipoDcto", dbOpenTable)
Set sd = db.OpenRecordset("SELECT SalAlm.Id, SalAlm.Fecha, SalAlm.Fecha_Envio_Ofimatica, SalAlm.Fuente, SalAlm.Datos_Adicionales, " & _
" DetSalAlm.TipoDcto, DetSalAlm.Item, DetSalAlm.Codigo, DetSalAlm.CodLote, DetSalAlm.CC, DetSalAlm.CodOriginal, " & _
" Sum(DetSalAlm.cnt) AS cnttot, DetSalAlm.Und, DetSalAlm.Nombre FROM SalAlm INNER JOIN DetSalAlm ON SalAlm.Id = DetSalAlm.Id " & _
" GROUP BY SalAlm.Id, SalAlm.Fecha, SalAlm.Fuente, SalAlm.Fecha_Envio_Ofimatica, DetSalAlm.TipoDcto, DetSalAlm.Item, DetSalAlm.Codigo, SalAlm.Datos_Adicionales, " & _
" DetSalAlm.CodLote, DetSalAlm.CC, DetSalAlm.CodOriginal, DetSalAlm.Und, DetSalAlm.Nombre" & _
" HAVING (((SalAlm.Fecha_Envio_Ofimatica) = #1/1/1900#) and SalAlm.Fuente='" & fte & "') ORDER BY SalAlm.Id, DetSalAlm.TipoDcto, DetSalAlm.Item")





sa.Index = "PrimaryKey"
dt.Index = "PrimaryKey"
st.Index = "PrimaryKey"

If sd.EOF And sd.BOF Then
    MsgBox ("No hay registros pendientes por enviar a Ofimatica")
    'Exit Sub
    WScript.Quit
End If

InTrans = False
cnn.BeginTrans
Dbs.BeginTrans
InTrans = True: DaoTrans = True


CodigoCta = "130505"
nit = "213001"
Origen = "INV"
sd.MoveFirst

VtipoDcto = sd("TipoDcto")
VId = sd("id")
primerRegistro = True

'Se tiene que generar antes el registro en trade
Do While Not sd.EOF
    If (VtipoDcto <> sd("TipoDcto")) Or (VId <> sd("id")) Or primerRegistro Then
        
        If (VId <> sd("id")) Or primerRegistro Then
            sa.Seek "=", sd("id")
            If sa.NoMatch Then
            InTrans = False
            DaoTrans = False
            MsgBox "No se encontro la id de SalAlm:" & sd("id")
            nerr = nerr + 1
            errores(nerr) = "No se encontro la id de SalAlm:" & sd("id")

            Else
                sa.Edit
                sa("Fecha_Envio_Ofimatica") = Now
                sa.Update
            End If
            primerRegistro = False
        End If
        'Lee consecutivo del tipo de dcto y lo actualiza con el numero siguiente
        Set con = Nothing
        Set con = CreateObject("ADODB.recordset")
        con.Open "Select * from consecut where CODIGOCONS = 'I" & sd("TipoDcto") & "'", cnn, adOpenKeyset, adLockOptimistic
        If con.BOF And con.EOF Then
            InTrans = False
            DaoTrans = False
            MsgBox "No se encontro " & sd("TipoDcto") & " en archivo consecut, item " & sd("item")
            nerr = nerr + 1
            errores(nerr) = "No se encontro " & sd("TipoDcto") & " en archivo consecut, item " & sd("item")
            'WScript.Quit
        Else
            con.MoveFirst
            'MsgBox "con(CONSECUT):" & con("CONSECUT")
            NroDoc = CLng(con("CONSECUT")) + 1
            VcodInt = CLng(con("CODINT"))
            vTipoMvto = con("CODINT") 'Se quita la funcion str?, posiblemente siempre entre como str
            'Acutaliza el consecutivo sumandole 1
            con("CONSECUT") = NroDoc
            con.Update
        End If
        con.Close
        'Actualiza el archivo saltipodcto
        st.Seek "=", sd("id"), sd("TipoDcto")
        If st.NoMatch Then
            st.AddNew
            st("Id") = sd("Id")
            st("TipoDcto") = sd("TipoDcto")
            st("Numero") = NroDoc
            st("Fuente") = fte
            st.Update
        Else
            InTrans = False
            DaoTrans = False
            MsgBox "El movimiento Id " & sd("Id") & ", con el tipo de documento :" & sd("TipoDcto") & "."
            nerr = nerr + 1
            errores(nerr) = "El movimiento Id " & sd("Id") & ", con el tipo de documento :" & sd("TipoDcto") & "."
        End If
        
        VtipoDcto = sd("TipoDcto")
        VId = sd("id")
        '2. Agrega trade
        tra.AddNew

        tra("aprueba") = ""
        tra("autorizado") = ""
        tra("bancoprv") = ""
        tra("calretica") = False
        tra("ciudadcli") = ""
        tra("codcc") = "0"
        tra("codctacxp") = ""
        tra("codtcxp") = ""
        tra("coniva") = 0
        tra("consinv") = 0
        tra("dctoord") = ""
        tra("dctopmp") = ""
        tra("dctoprv") = NroDoc     'ok
        tra("dctorcm") = ""
        tra("dctorequi") = ""
        tra("dctoreser") = ""
        tra("dir") = ""
        tra("enviadoa") = ""
        tra("fechaing") = #1/1/1900# 'ok
        tra("fechamod") = #1/1/1900# 'ok
        tra("fhautoriza") = #1/1/1900#
        tra("formapago") = ""
        tra("importac") = ""
        tra("marcdist") = ""
        tra("nitcaja") = ""
        If fte = "Mantenimiento" Then
            tra("nota") = sd("Datos_Adicionales") & " " & Sheets("Mantenimiento").Cells(3, 5)
        Else
            tra("nota") = ""
        End If
        tra("nrosoli") = ""
        tra("numerocrp") = ""
        tra("orden") = ""
        tra("passwordau") = ""
        tra("passwordmo") = ""
        tra("pesodolar") = ""
        tra("prioridad") = 0
        tra("remifact") = ""
        tra("remision") = ""
        tra("siniva") = 0
        tra("tcambio") = 0
        tra("tcambiomm") = 0
        tra("tipodctopc") = ""
        tra("tipodctore") = ""
        tra("tipodctotr") = ""
        tra("tope") = 0
        tra("transporta") = ""
        tra("undtribu") = 0
        tra("vipconsu") = 0
        tra("vretiva") = 0
        tra("activa") = False
        tra("Aprobado") = False
        tra("apagar") = ""
        tra("autorequi") = False
        tra("autoret") = False
        tra("autoriza") = False
        tra("autretfac") = False
        tra("calica") = False
        tra("calrete") = False
        tra("cargada") = False
        tra("contado") = False
        tra("ctrlcorig") = True
        tra("ctrtopes") = False
        tra("descargado") = False
        tra("facturado") = False
        tra("impreso") = False
        tra("integrado") = False
        tra("multimon") = False
        tra("planeado") = False
        tra("regsimp") = False
        tra("reservado") = False
        tra("respica") = False
        tra("resprete") = False
        tra("codcaja") = "0"
        tra("codica") = ""          'ok
        tra("codmoneda") = "0"
        tra("nitresp") = "0"
        tra("d1fecha1") = 0
        tra("d1fecha2") = 0
        tra("d1fecha3") = 0
        tra("d2fecha1") = 0
        tra("d2fecha2") = 0
        tra("d2fecha3") = 0
        tra("d3fecha1") = 0
        tra("d3fecha2") = 0
        tra("d3fecha3") = 0
        tra("decimales") = 0
        tra("descecol") = 0
        tra("desctopp") = 0
        tra("descuento") = 0
        tra("diaspdpp") = 0
        tra("diasplazo") = 0
        tra("dsctocom") = 0
        tra("fletes") = 0
        tra("ivabruto") = 0
        tra("numcuotas") = 0
        tra("pgiva") = 0
        tra("poraiu") = 0
        tra("preteniva") = 0
        tra("pretica") = 0
        tra("pretiva") = 0
        tra("reteval") = 0
        tra("rtefte") = 0
        tra("valorplan") = 0
        tra("vlretfte") = 0
        tra("vrecica") = 0
        tra("vreteniva") = 0
        tra("vretica") = 0
        tra("vretivasim") = 0
        tra("vrteftea") = 0
        tra("xbaseiva") = 0
        tra("xbruto") = 0
        tra("xconiva") = 0
        tra("xdescuento") = 0
        tra("xfletes") = 0
        tra("xivabruto") = 0
        tra("xrecica") = 0
        tra("xreteniva") = 0
        tra("xretica") = 0
        tra("xretiva") = 0
        tra("xretivasim") = 0
        tra("xsiniva") = 0
        tra("xvlretfte") = 0
        tra("xvrteftea") = 0
        tra("zbaseiva") = 0
        tra("zbruto") = 0
        tra("zconiva") = 0
        tra("zdescuento") = 0
        tra("zfletes") = 0
        tra("zivabruto") = 0
        tra("zrecica") = 0
        tra("zretiva") = 0
        tra("zreteniva") = 0
        tra("zretica") = 0
        tra("zretivasim") = 0
        tra("zsiniva") = 0
        tra("zvlretfte") = 0
        tra("zvrteftea") = 0
        tra("baseiva") = 0
        tra("bruto") = 0                'Ok
        tra("codigocta") = Trim(CodigoCta)    'Ok
        tra("nit") = Trim(nit)                'Ok
        tra("nrodcto") = NroDoc         'ok
        tra("fecha") = dfecha              'ok
        tra("fecha1") = #1/1/1900#      'ok
        tra("fecha2") = #1/1/1900#      'ok
        tra("fecha3") = #1/1/1900#      'ok
        tra("fecing") = dfecha             'ok
        tra("origen") = Origen          'ok
        tra("pais") = ""                'ok
        tra("codrete") = "0"            'ok
        tra("tipocar") = "0"            'ok
        tra("Tipomoneda") = ""          'ok
        tra("Tipoper") = ""             'ok
        tra("HORA") = Time()            'ok
        tra("tipomvto") = Trim(vTipoMvto)   'ok
        tra("tiporeq") = "0"            'ok
        tra("tipovta") = "0"            'ok
        tra("tipodcto") = VtipoDcto     'ok
        tra("otramon") = ""             'ok
        tra("codven") = "0"             'ok
        tra("mediopag") = ""            'ok
        tra("tipocxp") = "0"            'ok
        tra("vigente") = False          'ok
        tra("upac") = False             'ok
        'tra("Valorplan") = 0
        tra("codint") = VcodInt           'ok
        tra("factorsus") = 0            'ok
        tra("feccaja") = #1/1/1900#     'ók
        tra("fecmod") = dfecha          'ok
        tra("passwordin") = "AFERNAND"  'ok
        tra("tipodctosi") = ""          'ok
        tra("tcr") = 0                  'ok
        tra("aporte1") = False
        tra("aporte2") = False
        tra("aporte3") = False
        tra("autretica") = False
        tra.Update
    End If
    
    '3. Averigua ultimo costo de referencia
    Vcodigo = sd("Codigo")
    cst.Open "Select * from coSTOINV where CODIGO ='" & Vcodigo & "' ORDER BY ANO DESC, PERIODO DESC", _
                    cnn, adOpenKeyset, adLockOptimistic
    If cst.EOF And cst.BOF Then
        InTrans = False
        DaoTrans = False
        MsgBox "No existe el articulo:" & Vcodigo & " en el item" & sd("Item") & ". No se hara la transaccion"
        'no exite el articulo, se debe ir a error sin hacer ninguna transaccion
        nerr = nerr + 1
        errores(nerr) = "No existe el articulo:" & Vcodigo & " en el item" & sd("Item") & ". No se hara la transaccion"
    Else
        cst.MoveFirst
        Vcosto = cst("HCOSTO")
    End If
    cst.Close
    
    '4.Agrega mvTrade
    mvt.AddNew
    mvt("cantempaq") = 0            'ok
    mvt("cantorig") = 0             'ok
    mvt("cantremis") = 0            'ok
    mvt("canventa") = sd("cnttot")  'ok
    mvt("codcc") = sd("CC")         'ok
    mvt("codigocta") = "0"          'ok
    mvt("codint") = VcodInt         'ok
    mvt("codrete") = "0"            'ok
    mvt("codretica") = "0"          'ok
    mvt("codtras") = 0              'ok
    mvt("codubica") = "0"           'ok
    mvt("consecut") = NroDoc        'ok
    mvt("costeo") = False           'ok
    mvt("costo") = Vcosto           'ok
    mvt("descfinan") = 0            'ok
    mvt("descuento") = 0            'ok
    mvt("dsctofinan") = 0           'ok
    mvt("facturado") = False        'ok
    mvt("fecing") = dfecha          'ok
    mvt("fecmod") = dfecha          'ok
    mvt("fhcompra") = dfecha        'ok
    mvt("hcosto") = Vcosto          'ok
    mvt("hvalunid") = Vcosto        'ok
    mvt("idpedord") = 0             'ok
    mvt("idremis") = 0              'ok
    mvt("idreqord") = 0             'ok
    mvt("integrado") = False        'ok
    mvt("integtall") = False        'ok
    mvt("ordenado") = False         'ok
    If IsNull(sd("CodLote")) Then
        mvt("Ordennro") = 0
    Else
        mvt("Ordennro") = sd("CodLote")  'ok
    End If
    mvt("ordenprv") = "0"           'ok
    mvt("Pasaterord") = False       'ok
    mvt("passwordin") = "AFERNAND"  'ok
    mvt("porete") = 0               'ok
    mvt("porica") = 0               'ok
    mvt("pretfte") = 0              'ok
    mvt("producto") = sd("Codigo")   'ok
    mvt("SERFLETES") = False        'ok
    mvt("traslado") = False         'ok
    mvt("Undbase") = sd("und")     'ok
    mvt("undventa") = sd("und")  'ok
    mvt("valorunit") = 0            'ok
    mvt("vlrventa") = Vcosto        'ok
    mvt("valunid") = Vcosto         'ok
    mvt("xcosto") = Vcosto          'ok
    mvt("xvalorun") = 0             'ok
    mvt("xvalunid") = Vcosto        'ok
    mvt("zvalorunit") = 0           'OK
    mvt("iva") = 0                  'ok
    mvt("nit") = "0"                'ok
    mvt("base") = 0                 'ok
    mvt("bodega") = "BODEPROC"      'ok
    mvt("cantidad") = sd("cnttot")   'ok
    mvt("fecent") = dfecha          'ok
    mvt("fecha") = dfecha           'ok
    mvt("nombre") = sd("Nombre")     'ok
    mvt("nrodcto") = NroDoc         'ok
    mvt("origen") = Origen          'ok
    mvt("tipomvto") = Trim(vTipoMvto)   'ok
    mvt("tipodcto") = VtipoDcto       'ok
    mvt("notas") = ""  'ok
    mvt("Cargoa") = ""              'ok
    mvt("ctavta") = ""              'ok
    mvt("detalle") = ""             'ok
    mvt("importac") = ""            'ok
    mvt("incidente") = ""           'ok
    mvt("ipconsumo") = 0            'ok
    mvt("login") = ""               'ok
    mvt("mvtotras") = ""            'ok
    mvt("Norden") = ""              'ok
    mvt("nota") = sd("CodOriginal")
    mvt("npedido") = ""             'ok
    mvt("nrobono") = 0              'ok
    mvt("nrofactura") = ""          'ok
    mvt("nroorden") = ""            'ok
    mvt("nrosoli") = ""             'ok
    mvt("numfactnc") = ""           'ok
    mvt("passwordmo") = ""          'OK
    mvt("pesodolar") = ""           'ok
    mvt("remifact") = ""            'ok
    mvt("sucursal") = "0"           'ok
    mvt("tipodctonc") = ""          'ok
    mvt("tipodctopc") = ""          'ok
    mvt("tipodctore") = ""          'ok
    mvt("tipodctosi") = ""          'ok
    mvt("tipodctotr") = ""          'ok
    mvt("tipodctofa") = ""          'ok
    mvt("toprete") = 0              'ok
    mvt("topretica") = 0            'ok
    mvt("vendedor") = "0"           'ok
    'mvt("fechapante") = #1/1/1900#  'ok
    mvt("baseimpor") = 0 'ok
    mvt("bivaimpor") = 0 'ok
    
    
        
    mvt.Update
    sd.MoveNext
Loop


'Actualiza consecutivos el ultimo registro no queda dentro del loop

If nerr > 0 Then
    Dim msgerr
    msgerr = "Se generaron los siguientes errores, por lo tanto no se cargaran las salidas de almacen a Ofimatica" & vbCrLf
    For i = 1 To nerr
        msgerr = msgerr & errores(i) & vbCrLf
    Next
    MsgBox msgerr
    
Else
    If InTrans And DaoTrans Then
    'UPDATE SalAlm SET SalAlm.Fecha_Envio_Ofimatica = #1/1/1990#
    'WHERE (((SalAlm.Fecha_Envio_Ofimatica)=#12/10/2010#));
    	'en vbscript Cambia format por Formatdatetime
        db.Execute ("UPDATE SalAlm SET SalAlm.Fecha_Envio_Ofimatica = #" & FormatDateTime(Now, vbGeneralDate) & "# WHERE (((SalAlm.Fecha_Envio_Ofimatica)=#1/1/1900#))and Fuente='" & fte & "'")
        cnn.CommitTrans
        Dbs.CommitTrans
        InTrans = False
    Else
        cnn.RollbackTrans
        Dbs.Rollback
    End If
    If fte = "Repuestos" Then
        'CopiarRepuestos
        'BorrarRepuestos
    ElseIf fte = "Combustible" Then
        'CopiarCombustible
        'BorrarCombustible
    ElseIf fte = "Mantenimiento" Then
        'copiarMantenimiento
        'borrarMantenimiento
    End If
End If
'GoTo final
'errmsg:
'If InTrans Then
'    cnn.RollbackTrans
'    Dbs.Rollback
'End If
'Lo demas para ver el error, y decir que no se cargo el archivo. y no se borra
'final: