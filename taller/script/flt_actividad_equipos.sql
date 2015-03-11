SELECT [id]
      ,[equipo]
      ,CONVERT(VARCHAR(19),[fecha],120) as fecha
      ,[horometro_inicial]
      ,[horometro_final]
      ,[hora_inicial]
      ,[hora_final]
      ,[finalizo_inspeccion]
      ,[notas]
      ,[operario]
      ,[horas_produccion]
      ,[turno]
      ,[kilometraje_inicial]
      ,[kilometraje_final]
      ,[Fecha_Fin]
      ,[bodega]
      ,[horas_disponible]
      ,[laboro]
      ,[fecha_sistema]
  FROM [dbo].[flt_actividad_equipos]
where year(fecha)=@@1 and month(fecha)=@@2


