SELECT referencias.codigo, REPLACE(REPLACE(referencias.descripcion,CHAR(10),' '),CHAR(13),'') as descripcion , 
	referencias.clase,
       referencias.contable, 
	referencias.grupo, 
	referencias.ref_comercial,
       referencias.subgrupo, 
       referencias.valor_unitario, referencias.porcentaje_iva, referencias.costo_unitario, 
       referencias.maneja_inventario,
	convert(VARCHAR(19),referencias.fecha_creacion ,120) as fecha_creacion

FROM   dms_condor.dbo.referencias referencias
