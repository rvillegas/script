
--Actualizar_Horometros

-- =============================================
-- Author:		Ramiro Villegas
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[Actualizar_Horometros] 

AS
BEGIN
UPDATE [llantas].[dbo].[historia]
   SET [equipo] = REPLACE(equipo,' ','-'),
       ID=REPLACE(ID,'-','')
UPDATE [llantas].[dbo].[historia]
   SET  ID=REPLACE(ID,' ','')   
    

     
   
UPDATE [llantas].[dbo].[historia]
   SET horometro= horometros.Horometros
   from historia
inner join 
      horometros
 on
      historia.equipo = horometros.equipo AND historia.Fecha = horometros.fecha
END


