SELECT [id_actividad]
      ,[seq]
      ,[hora_inicial]
      ,[hora_final]
      ,[estado]
      ,[codigo_estado]
      ,[contabilizado]
      ,[notas]
      ,[operario]
      ,[valor]
      ,convert(VARCHAR(19),[fecha],120) as fecha
      ,[horas]
      ,convert(VARCHAR(19),[fecha_sistema],120) as fecha_sistema
  FROM [dbo].[flt_actividad_equipos_lin]
where year(fecha)=@@1 and month(fecha)=@@2