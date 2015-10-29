Const strComputer = "." 
Set WshShell = CreateObject("WScript.Shell")
Dim objWMIService, colProcessList
Set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
Set colProcessList = objWMIService.ExecQuery("SELECT * FROM Win32_Process WHERE Name = 'mstsc.exe'") '
For Each objProcess in colProcessList 
   Debug.WriteLine objProcess.Name,"  " ,objProcess.ProcessId 
  WshShell.Exec "PSKill " & objProcess.ProcessId 
Next