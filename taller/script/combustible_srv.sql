
SELECT     	substring(p.descripcion,1,10) as equipo , l.bodega,convert(VARCHAR(19), l.fec ,120) as fecha, l.codigo,r.descripcion, l.tipo, l.numero, CONVERT(decimal(18, 2), l.cantidad) as cnt ,l.destino  
                FROM dbo.documentos_lin AS l  
                LEFT OUTER JOIN dbo.v_destino_padre_gto_generales_AMV_UNION AS p ON l.destino = p.Destino 
                LEFT OUTER JOIN                        dbo.referencias AS r ON l.codigo = r.codigo 
                LEFT OUTER JOIN                        dbo.referencias_gru AS g ON r.grupo = g.grupo 
                LEFT OUTER JOIN                        dbo.V_REFERENCIAS_ALT AS a ON r.codigo = a.CODIGO 
                LEFT OUTER JOIN                        dbo.bodegas AS b ON l.bodega = b.bodega  
                WHERE  
                    g.grupo ='03'     
                and l.fec  >=dateadd(day,-30,getdate()) 
                and l.sw = case when  l.maneja_inventario = 'N' then '3' else '11' end  
		and l.sw = case when  l.maneja_inventario <> 'N' then '11' else '3' end  
		ORDER BY    l.bodega,p.descripcion, b.descripcion, g.descripcion, l.fec, r.descripcion  
