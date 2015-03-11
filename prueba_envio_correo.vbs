envio_email("ramiro")

Sub envio_email(destinatario)
	Set objMessage = CreateObject("CDO.Message") 
	objMessage.Subject = "Example CDO Message" 
	objMessage.From = "elcondorequipos@gmx.com"
	objMessage.To = "ramiro.villegas@elcondor.com" 
	objMessage.TextBody = "This is some sample message text 465."
	
	'==This section provides the configuration information for the remote SMTP server.
	'==Normally you will only change the server name or IP.
	objMessage.Configuration.Fields.Item _
	("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2 
	
	'Name or IP of Remote SMTP Server
	objMessage.Configuration.Fields.Item _
	("http://schemas.microsoft.com/cdo/configuration/smtpserver") = "smtp.gmx.net"
	
	'Server port (typically 25)
	objMessage.Configuration.Fields.Item _
	("http://schemas.microsoft.com/cdo/configuration/smtpserverport") =465
	objMessage.Configuration.Fields.Item _
	("http://schemas.microsoft.com/cdo/configuration/smtpauthenticate") = 1
	objMessage.Configuration.Fields.Item _
	("http://schemas.microsoft.com/cdo/configuration/smtpusessl") = True
	objMessage.Configuration.Fields.Item _
	("http://schemas.microsoft.com/cdo/configuration/smtpconnectiontimeout") = 60
	objMessage.Configuration.Fields.Item _
	("http://schemas.microsoft.com/cdo/configuration/sendusername") = "elcondorequipos@gmx.com"
	objMessage.Configuration.Fields.Item _
	("http://schemas.microsoft.com/cdo/configuration/sendpassword") = "elcondor2014+"	
	
	objMessage.Configuration.Fields.Update
	
	'==End remote SMTP server configuration section==
	
	objMessage.Send
End Sub
