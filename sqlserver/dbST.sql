
--ultimoNivel

-- =============================================
-- Author:        Ramiro Villegas
-- Create date: 30-08-2013
-- Description:   Ultimo nivel antes de fecha
-- =============================================
create FUNCTION [dbo].[ultimoNivel]
(
      -- Add the parameters for the function here
      @equipo varchar(10),
      @fecha datetime
)
RETURNS numeric(5,2)
AS
BEGIN
      -- Declare the return variable here
      DECLARE @Result numeric(5,2)
      set @result=(SELECT top 1 [nivel] FROM [dbST].[dbo].[datosCAN]
                             where matricula=@equipo and fecultpos<@fecha and not nivel is null
                             order by fecultpos desc)
      -- Return the result of the function
      RETURN @Result
 
END



--nivel_tanqueado

-- =============================================
-- Author:        Ramiro Villegas
-- Create date: 30-08-2013
-- Description:   Cuando se detecta un cambio de nivel de tanqueo se verifica que el nivel sea
-- el maximo y que no coja lecturas intermedias
-- =============================================
create FUNCTION [dbo].[nivel_tanqueado]
(
      -- Add the parameters for the function here
      @equipo varchar(10),
      @fecha datetime
)
RETURNS numeric(5,2)
AS
BEGIN
      -- Declare the return variable here
      DECLARE @Result numeric(5,2)
      set @result=     (Select MAX(q.nivel) from (SELECT     TOP (3) Matricula, nivel
                             FROM   datosCAN
                             WHERE     (fecUltPos >= @fecha) and(Matricula = @equipo)
                                   AND (nivel <> 0) AND (NOT (nivel IS NULL))
                             order by fecUltPos asc) q)
      RETURN @Result
 
END





--kilometraje

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[kilometraje]

(
	
	@matricula varchar(20),
	@fecha datetime    
)
RETURNS numeric(18,1)
AS
BEGIN
	declare @resultado numeric(18,1)
	set @resultado=(SELECT TOP 1 kms from dbo.datoscan  where matricula=@matricula and fecultpos>@fecha)
	RETURN @resultado

END



--nivel_antes_tanqueado

-- =============================================
-- Author:        Ramiro Villegas
-- Create date: 30-08-2013
-- Description:   Cuando se detecta un cambio de nivel de tanqueo se verifica que el nivel sea
-- el maximo y que no coja lecturas intermedias
-- =============================================
create FUNCTION [dbo].[nivel_antes_tanqueado]
(
      -- Add the parameters for the function here
      @equipo varchar(10),
      @fecha datetime
)
RETURNS numeric(5,2)
AS
BEGIN
      -- Declare the return variable here
      DECLARE @Result numeric(5,2)
      set @result=     (Select MIN(q.nivel) from
                                         (SELECT     TOP (3) Matricula, nivel
                                                           FROM   datosCAN
                                               WHERE     (fecultpos <= @fecha) and(Matricula = @equipo)
                                               AND (nivel <> 0) AND (NOT (nivel IS NULL))
                                               order by fecultpos desc) q)
      RETURN @Result
 
END



--consumoFechas_old

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
create FUNCTION [dbo].[consumoFechas_old]
(
	@matricula varchar(10), 
	@fecha_ini datetime,
	@fecha_fin datetime
)
RETURNS numeric(18,2)
AS
BEGIN
	declare @acum_g as numeric(18,2), @aComTot as numeric(18,2), @uComTot as numeric(18,2) 
	declare @ufecha as datetime, @afecha as datetime, @thr as numeric(18,2),@consumo as numeric(18,2)
	set @acum_g=0
	set @uComTot=0

	--Se agrega en abr 10 2015: Se calcula consumo entre los extremos, si esta en un rango de 1 a 10 gph 
	--lo considera que esta bien, de lo contrario hace el calculo registro por registro

	--SELECT top 1 @uComTot=[Combustible_Total],@uFecha=FecUltPos
	--	FROM [dbo].[datosCAN]  where EstadoMotor=1
	--	--and [FecUltPos]>=@fecha_ini
	--	and [FecUltPos]<=@fecha_fin
	--	and matricula=@matricula
	--	order by [FecUltPos] desc
	--SELECT top 1 @aComTot=[Combustible_Total],@aFecha=FecUltPos
	--	FROM [dbo].[datosCAN]  where EstadoMotor=1
	--	and [FecUltPos]>=@fecha_ini
	--	--and [FecUltPos]<=@fecha_fin
	--	and matricula=@matricula
	--	order by [FecUltPos] asc


	--  set @thr=datediff(hour,@aFecha,@uFecha)


	--  if (@thr>0)
	--	begin
	--		set @consumo=(@uComTot-@aComTot)/(@thr)
	--		if (@uComTot> @aComTot) AND (not @uComTot is null ) 
	--			AND (not @aComTot is null)
	--			and @consumo>5 and @consumo<40
	--			begin
	--				return (@uComTot-@aComTot)/3.785
	--			end
	--	END





DECLARE skt_cursor CURSOR FOR
SELECT [Combustible_Total],FecUltPos
  FROM [dbo].[datosCAN]
  where EstadoMotor=1
  and [FecUltPos]>=@fecha_ini
  and [FecUltPos]<=@fecha_fin
  and matricula=@matricula
  order by [FecUltPos] asc

OPEN skt_cursor;

-- Perform the first fetch.
FETCH NEXT FROM skt_cursor into @aComTot,@aFecha
-- Check @@FETCH_STATUS to see if there are any more rows to fetch.
WHILE @@FETCH_STATUS = 0
	BEGIN
   -- This is executed as long as the previous fetch succeeds.
      FETCH NEXT FROM skt_cursor into @uComTot,@uFecha
	  set @thr=datediff(hour,@aFecha,@uFecha)


	  if (@thr>0)
		begin
			set @consumo=(@uComTot-@aComTot)/(@thr)
		end
	  else
		begin
			set @consumo=(@uComTot-@aComTot)
		end


	  if (@uComTot> @aComTot) AND (not @uComTot is null ) AND (not @aComTot is null)
		 and @consumo<100
		begin
		   set @acum_g=@acum_g+@uComTot-@aComTot
		   set @aComTot=@uComTot
		   set @afecha=@ufecha
		end
		
	END

CLOSE skt_cursor;
DEALLOCATE skt_cursor;
set @acum_g =@acum_g / 3.785
return @acum_g

END



--tanqueos

-- =============================================
-- Author:		Ramiro Villegas
-- Create date: 16/10/2014
-- Description:	Genera tanqueos entre fechas
-- =============================================
CREATE FUNCTION [dbo].[tanqueos] 
(
	-- Add the parameters for the function here
	@matricula varchar(10), 
	@fecha_ini datetime,
	@fecha_fin datetime
)
RETURNS 
@tq_res table (	f datetime, 
			dNiv numeric(18,2), 
			dTpo numeric(18,2), 
			n_ini numeric(18,2),
			n_fin numeric(18,2),
			g_dms numeric(18,2),
			km    numeric(18,1),
			hrs   int,
			Lat numeric(18,5),
			Lon numeric(18,5),
			g_skt numeric(18,2),
			bod int
			 )

AS
BEGIN

declare  @pFecha as datetime, @f_tq as datetime
declare @d1 as table(n numeric(18,1), f datetime, km numeric(18,1), hrs int, lat  numeric(18,5), lon  numeric(18,5))
declare @d2 as table(n numeric(18,1), f datetime, km numeric(18,1), hrs int, lat  numeric(18,5), lon  numeric(18,5))
declare @dNiv as numeric(18,2), @dTpo as numeric(18,2)
declare @f1 as datetime, @f2 as datetime, @fecha_tmp as datetime
declare @nf as numeric(18,2), @ni  as numeric(18,2)
declare @tq table (	f datetime, 
			dNiv numeric(18,2), 
			dTpo numeric(18,2), 
			n_ini numeric(18,2),
			n_fin numeric(18,2),
			g_dms numeric(18,2),
			km    numeric(18,1),
			hrs   int,
			Lat numeric(18,5),
			Lon numeric(18,5),
			g_skt numeric(18,2),
			bod int
			 )
--SET NOCOUNT ON
set @fecha_tmp=@fecha_ini
set @pfecha=@fecha_ini
--Hace el ciclo hasta que llegue a la fecha final, va saltando y comparando en periodos de 15 min, 
--de acuerdo a la instruccion set @pFecha=DATEADD(minute,15,(select f from @d1))
while (@fecha_ini<@fecha_fin)
	begin
		delete from @d1
		delete from @d2
		--Mueve la fecha inicial a la anterior del ciclo anterior
		set @fecha_ini=@pFecha
		--En tabla @d1 mete los datos de nivel en tiempo 1
		insert into @d1
		    --Busca el proximo registro que cumpla las siguientes condiciones:
			--		1. La fecha sea la siguiente a 15 min de la anterior
			--		2. El motor este enciendido
			--		3. El nivel sea mayor que cero para evitar ruidos
			SELECT top 1 nivel,FecUltPos,kms,Horas_Motor,Lat,Lon from [dbST].[dbo].[datosCAN]
			where	FecUltPos>@fecha_ini 
					--and EstadoMotor=1 
					and matricula=@matricula
					AND nivel>0
					--and nivel is not null
					
			order by FecUltPos asc
        --Recalcula la fecha final agregando 15 minutos a la fecha anterior
		--feb 26 @f_tq es la fecha y hora precisa de tanqueo
		set @f_tq=(select f from @d1)
		set @pFecha=DATEADD(minute,15,(select f from @d1))
		--Mete en tabla @d2 en nivel del tanque en el tiempo 2
		insert into @d2
		    
			SELECT top 1 nivel,FecUltPos,kms,Horas_Motor,Lat,Lon from [dbST].[dbo].[datosCAN]
			where	FecUltPos>@pFecha 
					--and EstadoMotor=1 
					and matricula=@matricula 
					AND nivel>0					
					--and nivel is not null
			order by FecUltPos asc


		--set @pFecha=(select f from @d2)
		set @nf=(select  n from @d2)
		set @ni=(select  n from @d1)
		--Calcula el delta de nivel y el delta del tiempo
		--delta de nivel=Nivel en t2 -nivel en t1
		set @dNiv = (select  n from @d2)-(select  n from @d1)
		
		--(select  n,f from @d1)
		--(select  n,f from @d2)
		--Las condiciones que se deben cumplir para saber si es un cambio de nivel por tanqueo son las siguientes:
		--	1.	Las diferencia entre los dos niveles deben ser mayores de 20%
		--  2.  El nivel debe quedar superior a 80%
		--  3.  Que ninguno de el nivel inicial no sea 0 ya que puede ser un error en la medición. 
		--Si la dif de niveles es mayor que 20% y el nivel esta sobre 80%, considera que es un tanqueo
		if ( @dniv>20.0 and @nf > 80 )
			begin
				set @f1=(select  f from @d1)
				set @f2=(select  f from @d2)
				set @dTpo= DATEDIFF ( minute ,@f1  , @f2 )
				--feb 24 2015 en where equipo=@matricula and fecha=convert(date,@FechaIni) se cambio ,@FechaIni x @pFecha
				--feb 26 se cambia la fecha por @Fecha ini en values y en el where
				insert into @tq
				(f, dNiv,dTpo, n_ini, n_fin, km, hrs, lat, lon, g_dms,bod) values
				(@f_tq,@dNiv,@dTpo,
					(select  n from @d1),
					(select  n from @d2),
					(select km from @d2),
					(select hrs from @d2),
					(select lat from @d2),
					(select lon from @d2),
					(select sum(cnt) from dbst.dbo.Tanqueos_dms 
					where equipo=@matricula and fecha=convert(date,@f_tq)
					group by equipo,fecha),
					(select top 1 bodega from dbst.dbo.Tanqueos_dms where equipo=@matricula and fecha=convert(date,@fecha_ini))  )
			    delete from @d1
				delete from @d2
			end
	end
	
	insert into @tq_res (f,g_dms, bod)
	SELECT Tanqueos_dms.fecha, Tanqueos_dms.cnt, Tanqueos_dms.bodega  FROM     dbST.dbo.Tanqueos_dms LEFT OUTER JOIN
                         @tq t ON convert(date,Tanqueos_dms.fecha) = convert(date,t.f)
	where equipo=@matricula and fecha>=@fecha_tmp and fecha<@fecha_fin and t.f is null
	      and UPPER(Tanqueos_dms.descripcion) not like '%GASOLINA%'
   
   insert into @tq_res (f, dNiv, dTpo, n_ini ,n_fin,g_dms ,km,hrs,Lat,Lon,g_skt,bod)
   select * from @tq
   delete from @tq
   insert into @tq (f, dNiv, dTpo, n_ini ,n_fin,g_dms ,km,hrs,Lat,Lon,g_skt,bod)
   select * from @tq_res order by f
   delete from @tq_res




   --recorre registro por registro calculando el tanqueo por skt, sino hay datos de skt lo calcula a las 00:00
   declare @fant as datetime, @fpos as datetime
   set @fant = (select top 1 f from @tq)
   DECLARE skt_cursor CURSOR FOR
	SELECT f from  @tq where not (g_dms is null)

	OPEN skt_cursor;

-- Perform the first fetch.
--  Salto el primero para que el campo quede nulo
	FETCH NEXT FROM skt_cursor into @fpos
-- Check @@FETCH_STATUS to see if there are any more rows to fetch.
	WHILE @@FETCH_STATUS = 0
	 BEGIN
		-- This is executed as long as the previous fetch succeeds
		if @fpos>@fant
			begin
				UPDATE @tq
				SET g_skt = (SELECT [dbo].[consumoFechas] (@matricula,@fant,@fpos))
				where f=@fpos
			end	
		set @fant=@fpos	
		FETCH NEXT FROM skt_cursor into @fpos
		--if   @@FETCH_STATUS < 0 BREAK
	END
	--Por alguna razon no calcula en ultimo, toca entonces hacerlo manual


	CLOSE skt_cursor
	DEALLOCATE skt_cursor

   insert into @tq_res (f, dNiv, dTpo, n_ini ,n_fin,g_dms ,km,hrs,Lat,Lon, g_skt,bod)
   select * from @tq



	
	RETURN 
END





--query_bodegas

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION bodegas
(	
	@fecha_ini datetime,
	@fecha_fin datetime
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	SELECT [bodega] FROM [dbo].[Tanqueos_dms]
	where fecha>=@fecha_ini and fecha<=@fecha_fin
	group by bodega

)



--bodega_equipo

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[bodega_equipo]
(	
	@fecha_ini datetime,
	@fecha_fin datetime
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
SELECT Tanqueos_dms.bodega as bodega, Tanqueos_dms.equipo as equipo, bodegas.descripcion as descripcion
FROM   Tanqueos_dms LEFT OUTER JOIN
       bodegas ON Tanqueos_dms.bodega = bodegas.bodega

where  equipo is not null and Tanqueos_dms.bodega is not null and Tanqueos_dms.bodega<>3
	   and fecha>=@fecha_ini and fecha<=@fecha_fin and
	   (SELECT Matricula
		FROM            datosCAN
		where fecUltPos>=@fecha_ini and fecUltPos<=@fecha_fin and matricula=equipo
		group by matricula) is not null
group by Tanqueos_dms.bodega,equipo,bodegas.descripcion

)



--consumoFechas

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[consumoFechas]
(
	@matricula varchar(10), 
	@fecha_ini datetime,
	@fecha_fin datetime
)
RETURNS numeric(18,2)
AS
BEGIN
	declare @acum_g as numeric(18,2), @aComTot as numeric(18,2), @uComTot as numeric(18,2) 
	declare @ufecha as datetime, @afecha as datetime, @thr as numeric(18,2),@consumo as numeric(18,2)
	set @acum_g=0
	set @uComTot=0

	--Se agrega en abr 10 2015: Se calcula consumo entre los extremos, si esta en un rango de 1 a 10 gph 
	--lo considera que esta bien, de lo contrario hace el calculo registro por registro

	SELECT top 1 @uComTot=[Combustible_Total],@uFecha=FecUltPos
		FROM [dbo].[datosCAN]  where  --velocidad>0 --EstadoMotor=1 and
		 [FecUltPos]>=@fecha_ini
		and [FecUltPos]<=@fecha_fin
		and matricula=@matricula
		order by [FecUltPos] desc

	SELECT top 1 @aComTot=[Combustible_Total],@aFecha=FecUltPos
		FROM [dbo].[datosCAN]  where --velocidad>0 --EstadoMotor=1 and
		 [FecUltPos]>=@fecha_ini
		and [FecUltPos]<=@fecha_fin
		and matricula=@matricula
		order by [FecUltPos] asc


	  set @thr=datediff(hour,@aFecha,@uFecha)


	  if (@thr>0)
		begin
			set @consumo=(@uComTot-@aComTot)/(@thr)
			if (@uComTot> @aComTot) AND (not @uComTot is null ) 
				AND (not @aComTot is null)
				and @consumo>5 and @consumo<40
				begin
					return (@uComTot-@aComTot)/3.785
				end
		END





DECLARE skt_cursor CURSOR FOR
SELECT [Combustible_Total],FecUltPos
  FROM [dbo].[datosCAN]
  where --velocidad>0 --EstadoMotor=1 and
   [FecUltPos]>=@fecha_ini
  and [FecUltPos]<=@fecha_fin
  and matricula=@matricula
  order by [FecUltPos] asc

OPEN skt_cursor;

-- Perform the first fetch.
FETCH NEXT FROM skt_cursor into @aComTot,@aFecha
-- Check @@FETCH_STATUS to see if there are any more rows to fetch.
WHILE @@FETCH_STATUS = 0
	BEGIN
   -- This is executed as long as the previous fetch succeeds.
      FETCH NEXT FROM skt_cursor into @uComTot,@uFecha
	  set @thr=datediff(hour,@aFecha,@uFecha)


	  if (@thr>0)
		begin
			set @consumo=(@uComTot-@aComTot)/(@thr)
		end
	  else
		begin
			set @consumo=(@uComTot-@aComTot)
		end


	  if (@uComTot> @aComTot) AND (not @uComTot is null ) AND (not @aComTot is null)
		 and @consumo<100
		begin
		   set @acum_g=@acum_g+@uComTot-@aComTot
		   set @aComTot=@uComTot
		   set @afecha=@ufecha
		end
		
	END

CLOSE skt_cursor;
DEALLOCATE skt_cursor;
set @acum_g =@acum_g / 3.785
return @acum_g

END



--ultimosDatos

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ultimosDatos]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
declare @tbl table(tabla varchar(100), Nreg int, ultima_fecha datetime)

insert into @tbl (tabla,Nreg,ultima_fecha)
select 'Fallas' as tabla,count(*), max(fecha) from fallas
insert into @tbl (tabla,Nreg,ultima_fecha)
select 'DatosCan' as tabla,count(*), max(FecUltPos) from datosCAN
insert into @tbl (tabla,Nreg,ultima_fecha)
select 'Tanqueos_dms' as tabla, count(*), max(Fecha) from Tanqueos_dms
insert into @tbl (tabla,Nreg,ultima_fecha)
select 'ped_tmp' as tabla, count(*), max(fecha_hora) from analisisInventarios.dbo.ped_tmp
insert into @tbl (tabla,Nreg,ultima_fecha) 
SELECT 'llantas', count(*), max(fecha)  FROM [dbInvLlantas].[dbo].salidas

select * from @tbl
END


