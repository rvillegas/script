

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