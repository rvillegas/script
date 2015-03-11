SELECT referencias.codigo, REPLACE(REPLACE(referencias.descripcion,CHAR(10),' '),CHAR(13),'') as descripcion , referencias.clase, referencias.contable, referencias.grupo, 
       referencias.subgrupo, referencias.valor_unitario, referencias.porcentaje_iva, referencias.costo_unitario, 
       referencias.maneja_inventario, referencias.fecha_creacion

FROM   dms_condor.dbo.referencias referencias
WHERE   (charindex('*1',codigo)=0)