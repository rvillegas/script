SELECT referencias.codigo, referencias.descripcion, referencias.clase, referencias.contable, referencias.grupo, 
       referencias.subgrupo, referencias.valor_unitario, referencias.porcentaje_iva, referencias.costo_unitario, 
       referencias.maneja_inventario, referencias.fecha_creacion, referencias.ref_comercial

FROM   dms_condor.dbo.referencias referencias
WHERE   (charindex('*1',codigo)=0)