
SELECT     	p.descripcion , l.bodega,   l.fec, l.codigo,r.descripcion, l.tipo, l.numero, Cast((l.cantidad+0.5) as int) as cnt,l.destino  
                FROM dbo.documentos_lin AS l  
                LEFT OUTER JOIN dbo.v_destino_padre_gto_generales_AMV_UNION AS p ON l.destino = p.Destino 
                LEFT OUTER JOIN                        dbo.referencias AS r ON l.codigo = r.codigo 
                LEFT OUTER JOIN                        dbo.referencias_gru AS g ON r.grupo = g.grupo 
                LEFT OUTER JOIN                        dbo.V_REFERENCIAS_ALT AS a ON r.codigo = a.CODIGO 
                LEFT OUTER JOIN                        dbo.bodegas AS b ON l.bodega = b.bodega  
                WHERE  l.bodega in (1,2,3,4,5,6,7,8,9,10,11,12,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,1100,1103,1106)   
                and g.grupo ='03'     
                and l.fec  >= '@@1' 
                and l.fec <=  '@@2'   
                and l.sw = case when  l.maneja_inventario = 'N' then '3' else '11' end  
		and l.sw = case when  l.maneja_inventario <> 'N' then '11' else '3' end  
		ORDER BY    l.bodega,p.descripcion, b.descripcion, g.descripcion, l.fec, r.descripcion  
