SELECT referencias.codigo, referencias.descripcion, referencias.clase, referencias.contable, referencias.grupo, 
       referencias.subgrupo, referencias.valor_unitario, referencias.porcentaje_iva, referencias.costo_unitario, 
       referencias.maneja_inventario, referencias.fecha_creacion

FROM   dms_condor.dbo.referencias referencias
WHERE    (referencias.grupo='02') AND (charindex('*1',codigo)=0) AND (referencias.fecha_creacion>'@@1') 
      OR (referencias.grupo='04') AND (charindex('*1',codigo)=0) AND (referencias.fecha_creacion>'@@1') 
      OR (referencias.grupo='05') AND (charindex('*1',codigo)=0) AND (referencias.fecha_creacion>'@@1') 
      OR (referencias.grupo='06') AND (charindex('*1',codigo)=0) AND (referencias.fecha_creacion>'@@1') 
      OR (referencias.grupo='07') AND (charindex('*1',codigo)=0) AND (referencias.fecha_creacion>'@@1') 
      OR (referencias.grupo='08') AND (charindex('*1',codigo)=0) AND (referencias.fecha_creacion>'@@1') 
      OR (referencias.grupo='10') AND (charindex('*1',codigo)=0) AND (referencias.fecha_creacion>'@@1') 
      OR (referencias.grupo='13') AND (charindex('*1',codigo)=0) AND (referencias.fecha_creacion>'@@1') 
      OR (referencias.grupo='14') AND (charindex('*1',codigo)=0) AND (referencias.fecha_creacion>'@@1')