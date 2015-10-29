SELECT        	documentos_lin_ped.sw, 
              	documentos_lin_ped.bodega, 
  		documentos_lin_ped.numero, 
		documentos_lin_ped.codigo, 
		documentos_lin_ped.id, 
                documentos_lin_ped.seq, 
		documentos_lin_ped.cantidad, 
		documentos_lin_ped.cantidad_despachada, 
		documentos_lin_ped.valor_unitario, 
		documentos_lin_ped.und, 
               	documentos_lin_ped.cantidad_und, 
		documentos_lin_ped.adicional, 
		documentos_lin_ped.despacho_virtual, 
		documentos_lin_ped.id_original, 
                
		convert(VARCHAR(10),documentos_lin_ped.fecha_prometida ,101) as fecha_prometida,
		documentos_lin_ped.cantidad_original, 
		documentos_lin_ped.valor_original, 
		convert(VARCHAR(10),documentos_lin_ped.fecha_entrega ,101) as fecha_entrega

FROM            documentos_lin_ped LEFT OUTER JOIN
                         documentos_ped ON documentos_lin_ped.numero = documentos_ped.numero AND documentos_lin_ped.bodega = documentos_ped.bodega
WHERE        (documentos_ped.fecha>=dateadd(day,-30,getdate()) ) and  documentos_lin_ped.sw=1