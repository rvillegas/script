
SELECT [sw]
      ,[bodega]
      ,[numero]
      ,convert(VARCHAR(10), fecha ,101) as fecha
      ,[condicion]
      ,convert(VARCHAR(10), fecha_hora ,101) as fecha_hora
      ,[anulado]
      ,REPLACE(REPLACE(notas,CHAR(10),' '),CHAR(13),'') as notas
      ,[duracion]
      ,[concepto]
      ,[despacho]
      ,convert(VARCHAR(10), fecha_hora_entrega ,101) as fecha_hora_entrega
      ,[documento]
      ,[autorizacion]
      ,[compra_directa]
      ,[tipo_orden]
      ,[numeroHN]
      ,[id]
      ,[id_referencias]
  FROM [dbo].[documentos_ped]
	
where fecha>=dateadd(day,-30,getdate()) and documentos_ped.sw=1