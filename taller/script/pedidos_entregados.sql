
SELECT [sw]
      ,[bodega]
      ,[numero]
      ,[fecha]
      ,[condicion]
      ,[fecha_hora]
      ,[anulado]
      ,REPLACE(REPLACE(notas,CHAR(10),' '),CHAR(13),'') as notas
      ,[duracion]
      ,[concepto]
      ,[despacho]
      ,[fecha_hora_entrega]
      ,[documento]
      ,[autorizacion]
      ,[compra_directa]
      ,[tipo_orden]
      ,[numeroHN]
      ,[id]
      ,[id_referencias]
  FROM [dbo].[documentos_ped]

where fecha_hora_entrega>=dateadd(day,-30,getdate()) 