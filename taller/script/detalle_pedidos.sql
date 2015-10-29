SELECT 	p.sw, 			
	p.numero, 			
	p.bodega, 			
	p.nit, 			
	p.estado, 			
	p.fecha, 			
	p.codigo, 			
	p.id, 			
	p.descripcion,usuarioP = '', 			
	p.adicional , 			
	p.seq,  			
	p.cantidad_pedida/p.cantidad_und as cantidad, 			
	p.cantidad as cantidad_autorizada, 			
	p.valor_unitario, 			
	p.fecha_autorizado, 			
	p.usuario_autoriza, 			
	p.fecha_aprobado, 			
	p.usuario_aprueba,  			
	p.fecha_orden, 			
	p.usuario, 			
	p.numero_orden, 			
	p.bodega_orden, 			
	p.tipo_traslado, 			
	p.numero_traslado,			
	p.fecha_finalizado, 			
	p.usuario_finaliza   , 			
	isnull(p.nombresp,'') as nombresp , 			
	fecha_preaprobacion1 , 			
	usuario_preaprobacion1 , 			
	fecha_preaprobacion2 , 			
	usuario_preaprobacion2   ,			
	p.destino, descripcioncd  ,			
	cl.fec as Fecha_documento, 			
	cl.tipo as tipo_compra, 			
	cl.numero as numero_compra,  			
	cl.cantidad as CantidadLLego,  			
	tl1.fec as fecha_traslado1, 			
	tl1.tipo as tipo_traslado1, 			
	tl1.numero as numero_traslado1,  			
	tl1.cantidad as cantidad_traslado1,  			
	tl2.fec as fecha_traslado2, 			
	tl2.tipo as tipo_traslado2, 			
	tl2.numero as numero_traslado2,  			
	tl2.Cantidad As cantidad_traslado2  ,			
	ct.fecha_cotizacion,ct.usuario_cotiza  ,			
	p.notas_rechazo_cotizacion   ,			
	p.notas_autorizacion_pedidos   			
FROM  documentos_lin_ped p   				
JOIN usuarios_bod ub ON  p.bodega = ub.bodega and ub.usuario = 'R.VILLEGAS' 				
LEFT JOIN documentos_lin cl  ON p.bodega_orden = cl.bodega AND p.numero_orden = cl.pedido and p.codigo = cl.codigo  AND p.id_orden = cl.seq_cargado 				
LEFT JOIN documentos_lin tl1  ON cl.tipo  = tl1.tipo_cargado AND cl.numero = tl1.numero_cargado and cl.seq = tl1.seq_cargado and tl1.sw = 16  				
LEFT JOIN documentos_lin tl2  ON tl1.tipo  = tl2.tipo_cargado AND tl1.numero = tl2.numero_cargado and tl1.seq = tl2.seq_cargado and tl2.sw = 16  				
LEFT JOIN autorizacion_pedidos_cot ct On ct.id_pedido_lin = p.id and ct.estado = 'A' 				
				
WHERE 	p.sw = 1 and 			
	p.estado <>'B'  AND 			
	p.fecha >= '20150101' AND 			
	p.fecha <= '20150420 23:59:59' AND 			
	p.bodega = 1118 AND 			
	p.numero = '308' AND 			
	NOT EXISTS(	SELECT Top 1	ap.id 	
			FROM autorizacion_pedidos ap 	
			WHERE 	ap.numero = p.numero AND 
				ap.bodega = p.bodega AND 
				ap.id = p.id AND ap.estado = 'F') 
ORDER BY p.codigo 				
