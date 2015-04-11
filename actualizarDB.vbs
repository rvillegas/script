Dim objShell
Set objShell = Wscript.CreateObject("WScript.Shell")
'MsgBox("Arranco el proceso")
objShell.Run "D:\datos\script\conectarse_dms.RDP",1,True
objShell.Run "D:\datos\script\cargarTanqueosdms.vbs",1,True
objShell.Run "D:\datos\script\actualizarInventarios.vbs" ,1,True
objShell.Run "D:\datos\script\actualizarv_ref_total.vbs" ,1,True
objShell.Run "D:\datos\script\actualizarPedidos.vbs" ,1,True
objShell.Run "D:\datos\script\actualizarHorometros.vbs" ,1,True 
objShell.Run "D:\datos\script\guardarRutinasSQLSERVER.vbs" ,1,True 
' Using Set is mandatory
Set objShell = Nothing



