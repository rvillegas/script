
--hor

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[hor]
(
	@eq varchar(20),
	@fe datetime
	
)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @hor int
	set @hor=isnull((SELECT TOP 1 [horometro_final]
				FROM [dbInvLlantas].[dbo].[horometros] 
				where equipo=@eq and sfecha<@fe and horometro_final>=0 order by equipo, sfecha desc),0)
	RETURN @hor

END



--actualizaMovInv

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[actualizaMovInv](
	@fi datetime,
	@ff datetime
)
AS
BEGIN
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tmp]') AND type in (N'U'))
DROP TABLE [dbo].[tmp]


SELECT DISTINCT [equipo], [tipo_llanta], max(fecha) over(partition by equipo,tipo_llanta) as fecha into tmp
FROM [dbInvLlantas].[dbo].[salidas] where fecha<@ff

delete from dbo.inventario

--generera la información general del inventario desde el archivo de salidas

insert into dbo.inventario (equipo,tipo_llanta,fecha,prom_tendido,horometro,pc_vida)
select t.equipo, t.tipo_llanta, t.fecha,  isnull(s.prom_tendido,1500.0), s.horometro_final, s.pc_vida  from tmp t
inner join [dbInvLlantas].[dbo].[salidas] s on t.equipo=s.equipo and t.fecha=s.fecha and t.tipo_llanta=s.tipo_llanta
where t.fecha<@fi

drop table [dbInvLlantas].[dbo].tmp
  --actualiza los datos de horometros iniciales y finales
  UPDATE [dbo].[inventario]
   SET [fec_ini] = @fi
      ,[hor_ini] = dbo.hor(equipo,@fi)
      ,[fec_fin] = @ff
      ,[hor_fin] = dbo.hor(equipo,@ff)

--Valores iniciales
UPDATE [dbo].[inventario]
	set vid_ini=0, cnt=0, vid_fin=0, consumo=0,duracion=1500,horas_uso=0

--calcula las cantidades que entran entre las dos fechas
UPDATE [dbo].[inventario]
set cnt= s1.cant 
from  [dbo].[inventario] as i
inner join (select  equipo, tipo_llanta, sum(cnt) as cant from dbo.salidas where fecha>=@fi and fecha<@ff 
		group by equipo,tipo_llanta) as s1
on i.equipo=s1.equipo and i.tipo_llanta=s1.tipo_llanta


--calcula el % de vida final teniendo en cuenta las fechas y la duracion final del tendido.



SELECT DISTINCT [equipo], [tipo_llanta], max(fecha) over(partition by equipo,tipo_llanta) as fecha into tmp
FROM [dbInvLlantas].[dbo].[salidas] where fecha<@ff and fecha>=@fi


UPDATE [dbo].[inventario]
set vid_fin=
(select s.pc_vida-([dbInvLlantas].dbo.hor(t.equipo, @ff)-s.horometro_final)/
   (case when isnull(s.prom_tendido,1500.0)>4000 then 1500.0
		when isnull(s.prom_tendido,1500.0)<1000 then 1500.0 
		else  isnull(s.prom_tendido,1500.0) end)
from tmp t
inner join [dbInvLlantas].[dbo].[salidas] s on t.equipo=s.equipo and t.fecha=s.fecha and t.tipo_llanta=s.tipo_llanta
where inventario.equipo= t.equipo and t.tipo_llanta=inventario.tipo_llanta),
duracion=
   (select (case when isnull(s.prom_tendido,1500.0)>4000 then 1500.0
		when isnull(s.prom_tendido,1500.0)<1000 then 1500.0 
		else  isnull(s.prom_tendido,1500.0) end)
from tmp t
inner join [dbInvLlantas].[dbo].[salidas] s on t.equipo=s.equipo and t.fecha=s.fecha and t.tipo_llanta=s.tipo_llanta
where inventario.equipo= t.equipo and t.tipo_llanta=inventario.tipo_llanta)



--Calcula el % de vida inicial y final cuando no se han cambiado llantas, horas de uso
UPDATE [dbo].[inventario]
 set horas_uso=hor_fin-hor_ini, 
	 vid_ini = case when (prom_tendido>4000 or prom_tendido<1000 or prom_tendido is null) then  
					pc_vida-convert(numeric(18,4),(hor_ini-horometro))/1500.0
			   else  pc_vida-convert(numeric(18,4),(hor_ini-horometro)/prom_tendido) end,
	duracion=case when (prom_tendido>4000 or prom_tendido<1000 or prom_tendido is null) then  1500
				else prom_tendido end
				

UPDATE [dbo].[inventario]
 set vid_fin = case when (prom_tendido>4000 or prom_tendido<1000 or prom_tendido is null) then  
					pc_vida-convert(numeric(18,4),(hor_fin-horometro))/1500.0
			   else  pc_vida-convert(numeric(18,4),(hor_fin-horometro)/prom_tendido) end
		where cnt=0




--Ajusta datos que quedaron fuera del intervlo normal de vida 0 a 1

UPDATE [dbo].[inventario]
	set vid_ini=case when vid_ini<0 then 0 when vid_ini>1 then  1 else vid_ini  end,
	vid_fin=case when vid_fin<0 then 0 when vid_fin>1 then  1 else vid_fin  end

--Actualiza consumo con la siguiente formula
-- consumo=(%vida_inicial-%vida_final)*num_llantas(8 traccion, 2 direccion)+cnt

UPDATE [dbo].[inventario]
	set consumo=(vid_ini-vid_fin)*dbo.n_llantas(tipo_llanta)+cnt


END



--prom

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION prom 
(
	@n1 numeric(18,6),
	@n2 numeric(18,6),
	@n3 numeric(18,6)
)
RETURNS numeric(18,6)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @ResultVar numeric(18,6), @den numeric(18,6)
	set @resultVar=isnull(@n1,0)+isnull(@n2,0)+isnull(@n3,0)
	set @den=0
	if not(@n1 is null) set @den=@den+1
	if not(@n2 is null) set @den=@den+1
	if not(@n3 is null) set @den=@den+1

	if @den>0 
		set @ResultVar=@resultvar/@den
	else
		set @ResultVar=0
		
	RETURN @ResultVar

END



--crear_ajustes

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[crear_ajustes]
	@t_ajuste varchar(20),
	@ano int,
	@mes int
AS
BEGIN

if @t_ajuste='Revisión' or @t_ajuste='Rotacion'
begin
delete from ajustes where tipo_ajuste=@t_ajuste and year(fecha)=@ano and month(fecha)=@mes
insert into ajustes
		SELECT  h.equipo,
			case	when h.Ubicacion<=2 then 'DIRECCION'
					when h.Ubicacion>2 and  h.Ubicacion<=10 then 'TRACCION'
					else 'REPUESTO' end  as tipo_llanta,  
					h.Fecha, h.Horometro as Horometro_final, sum(1) as cnt, operacion as tipo_ajuste,
					dbo.maximo(avg((dbo.prom(h.prof_1, h.prof_2, h.prof_3) - r.prof_min)/(r.prof_max-r.prof_min)),0) AS pc_vida,h.bodega


		FROM        (select distinct [marca-referencia],prof_max,prof_min from ref_llantas) AS r LEFT OUTER JOIN
                    llantas AS ll ON r.[marca-referencia] = ll.[marca-referencia] left OUTER JOIN
                    historia AS h ON ll.id = h.id

			where operacion=@t_ajuste and year(h.fecha)=@ano and month(fecha)=@mes
		group by    h.equipo, case	when h.Ubicacion<=2 then 'DIRECCION'

					when h.Ubicacion>2 and  h.Ubicacion<=10 then 'TRACCION'
					else 'REPUESTO' end, h.fecha, h.Horometro,operacion,bodega

end

END



--maximo

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION maximo
(
	@a numeric(18,6),
	@b numeric(18,6)

)
RETURNS numeric(18,6)
AS
BEGIN
	declare @res numeric(18,6)
	if (@a>@b)
		set @res=@a
	else
		set @res=@b
return @res
END



--n_llantas

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION n_llantas
(
	@tipo_llanta varchar(20)
)
RETURNS INT
AS
BEGIN
	declare @n_ll int
	set @n_ll=8
	if (@tipo_llanta='DIRECCION')
		set @n_ll= 2
    return @n_ll
END



--inventario_llantas_equipo

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[inventario_llantas_equipo] 
(
	@equ varchar(20),
	@f_c_ini datetime,
	@f_c_fin datetime,
	@tipo_llanta varchar(20)
)
RETURNS 
@inv TABLE 
(
	-- Add the column definitions for the TABLE variable here
	bod     int,
	f_cam datetime,
	c_cam int,
	pv_cam numeric(18,4),
	h_ini numeric(18,0),
	pc_v_ini numeric(18,4),
	d_ini numeric(18,0),
	cnt numeric(18,0),
	h_fin numeric(18,0),
	pc_v_fin numeric(18,4),
	d_fin numeric(18,0),
	h_cam numeric(18,0),
	con numeric(18,4),
	h_per numeric(18,0)
)

AS
BEGIN

declare @p_v_ini as numeric(18,6), @h_ini as numeric(18,2), @d_ini as numeric(18,2), @f_ini datetime
declare @p_v_fin numeric(18,6), @h_fin as numeric(18,2), @d_fin as numeric(18,2), @f_fin datetime
declare @hor_0 as numeric(18,2),@hor_1 as numeric(18,2),@bod int, @f_cam datetime, @c_cam int
declare @pc_v_0 as numeric(18,6), @pc_v_1 as numeric(18,6), @pv_cam as numeric(18,6)
declare @cnt as numeric(18,0), @n_ll int,@h_cam numeric(18,0),@con numeric(18,4)

--Calcula numero de llantas para calcular el consumo
if @tipo_llanta='DIRECCION'
	set @n_ll=2
else
	set @n_ll=8

--Busca el ultimo dato cierto de vida de las llantas para la fecha inicial
SELECT  top 1 
        @bod=bodega,
		@f_ini=[fecha]
		,@h_ini=horometro_final
      ,@d_ini=isnull([prom_tendido],1500)
      ,@p_v_ini=[pc_vida]
  FROM [dbo].[salidas] where equipo=@equ and tipo_llanta=@tipo_llanta and  fecha<@f_c_ini order by fecha desc
--Busca el ultimo dato cierto de vida para las llantas para la fecha final
SELECT  top 1 @f_fin=[fecha]
       ,@h_fin=dbo.hor(@equ,@f_c_fin)
	   ,@h_fin=horometro_final
      ,@d_fin=isnull([prom_tendido],1500)
      ,@p_v_fin=[pc_vida]
  FROM [dbo].[salidas] where equipo=@equ and tipo_llanta=@tipo_llanta and  fecha<=@f_c_fin order by fecha desc

--Austa los datos de duración de llantas a valores mas reales
if @d_ini<1000 
	set @d_ini=1000
if @d_ini>2000 
	set @d_ini=2000

if @d_fin<1000 
	set @d_fin=1000
if @d_fin>2000 
	set @d_fin=2000




--Busca los horometros para la fecha inicial y final
select top 1 @hor_0=horometro_final  from horometros where sfecha<@f_c_ini and equipo=@equ order by sfecha desc
select top 1 @hor_1=horometro_final  from horometros where sfecha<@f_c_fin and equipo=@equ order by sfecha desc

--Suma la cantidad de llantas que se intalaron entre las dos fechas

select @cnt=sum(cnt) from salidas  where equipo=@equ and tipo_llanta=@tipo_llanta and fecha<=@f_c_fin and fecha>=@f_c_ini and (tipo='SALIDA' or tipo='INICIO')


set @cnt=isnull(@cnt,0)

--busca ultimo cambio de llantas, por el momento no importa la cantidad

SELECT  top 1
       @h_cam=[horometro_final], @f_cam=fecha, @c_cam=cnt, @pv_cam=pc_vida
  FROM [dbo].[salidas] where equipo=@equ and tipo_llanta=@tipo_llanta and  fecha<=@f_c_fin and (tipo='SALIDA' or tipo='INICIO') order by fecha desc


--Si por algun calculo raro da un valor de vida fuera de 0,1 lo ajsuta

set @pc_v_0 = @p_v_ini - (@hor_0-@h_ini) / @d_ini

if @pc_v_0<0
	set @pc_v_0=0
if @pc_v_0>1
	set @pc_v_0=1

set @pc_v_1 = @p_v_fin-(@hor_1-@h_fin)/@d_fin

if @pc_v_1<0
	set @pc_v_1=0
if @pc_v_1>1
	set @pc_v_1=1

set @con=(-@pc_v_1+@pc_v_0)*@n_ll+@cnt

if @con<0
	set @con=0

  insert into @inv(bod,   f_cam, c_cam, pv_cam,   h_ini,  pc_v_ini, d_ini,  cnt,	h_fin,	pc_v_fin, d_fin , h_cam,  con,	h_per) values(
		           @bod, @f_cam,@c_cam, @pv_cam,  @hor_0, @pc_v_0,  @d_ini, @cnt, @hor_1, @pc_v_1,  @d_fin, @h_cam, @con, (@hor_1-@hor_0))

	-- Fill the table variable with the rows for your result set
	
	RETURN 
END



--inventario_llantas

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[inventario_llantas]
(	
	@f_c_ini datetime,
	@f_c_fin datetime)
RETURNS TABLE 
AS
RETURN 
(

--bod	h_ini	pc_v_ini	d_ini	cnt	h_fin	pc_v_fin	d_fin	h_cam	con	h_per
--1103	9487	0.3059	1978	0	9681	0.2078	9681	1567	-0.7846	194
	-- Add the SELECT statement with parameter references here
SELECT DISTINCT s.equipo, s.tipo_llanta, ll.bod, ll.f_cam, ll.h_cam, ll.pv_cam, ll.c_cam, ll.h_ini, ll.pc_v_ini, ll.d_ini,	
				ll.cnt,	ll.h_fin,	ll.pc_v_fin, 	ll.d_fin,		ll.con,	ll.h_per
FROM            salidas as s CROSS apply
                         dbo.inventario_llantas_equipo(s.equipo,@f_c_ini,@f_c_fin,s.tipo_llanta) AS ll
where s.tipo_llanta in ('DIRECCION','TRACCION')


)



--inv_lla_eq

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create FUNCTION [dbo].[inv_lla_eq] 
(
	@equ varchar(20),
	@f_c_ini datetime,
	@f_c_fin datetime,
	@tipo_llanta varchar(20)
)
RETURNS 
@inv TABLE 
(
	-- Add the column definitions for the TABLE variable here
	bod     int,
	h_ini numeric(18,0),
	pc_v_ini numeric(18,4),
	d_ini numeric(18,0),
	cnt numeric(18,0),
	h_fin numeric(18,0),
	pc_v_fin numeric(18,4),
	d_fin numeric(18,0),
	h_cam numeric(18,0),
	con numeric(18,4),
	h_per numeric(18,0)
)

AS
BEGIN

declare @p_v_ini as numeric(18,6), @h_ini as numeric(18,2), @d_ini as numeric(18,2), @f_ini datetime
declare @p_v_fin numeric(18,6), @h_fin as numeric(18,2), @d_fin as numeric(18,2), @f_fin datetime
declare @hor_0 as numeric(18,2),@hor_1 as numeric(18,2),@bod int
declare @pc_v_0 as numeric(18,6), @pc_v_1 as numeric(18,6)
declare @cnt as numeric(18,0), @n_ll int,@h_cam numeric(18,0),@con numeric(18,4)

--Calcula numero de llantas para calcular el consumo
if @tipo_llanta='DIRECCION'
	set @n_ll=2
else
	set @n_ll=8

--Busca el ultimo dato cierto de vida de las llantas para la fecha inicial
SELECT  top 1 
        @bod=bodega,
		@f_ini=[fecha]
       ,@h_ini=[horometro_final]
      ,@d_ini=isnull([prom_tendido],1500)
      ,@p_v_ini=[pc_vida]
  FROM [dbo].[salidas] where equipo=@equ and tipo_llanta=@tipo_llanta and  fecha<=@f_c_ini order by fecha desc

--Busca el ultimo dato cierto de vida para las llantas para la fecha final
SELECT  top 1 @f_fin=[fecha]
       ,@h_fin=[horometro_final]
      ,@d_fin=isnull([prom_tendido],1500)
      ,@p_v_fin=[pc_vida]
  FROM [dbo].[salidas] where equipo=@equ and tipo_llanta=@tipo_llanta and  fecha<=@f_c_fin order by fecha desc




--Busca los horometros para la fecha inicial y final
select top 1 @hor_0=horometro_final  from horometros where sfecha<=@f_c_ini and equipo=@equ order by sfecha desc
select top 1 @hor_1=horometro_final  from horometros where sfecha<=@f_c_fin and equipo=@equ order by sfecha desc

--Suma la cantidad de llantas que se intalaron entre las dos fechas

select @cnt=sum(cnt) from salidas  where equipo=@equ and tipo_llanta=@tipo_llanta and fecha<=@f_c_fin and fecha>=@f_c_ini

set @cnt=isnull(@cnt,0)
--busca ultimo cambio de llantas, por el momento no importa la cantidad

SELECT  top 1
       @h_cam=@hor_1-[horometro_final]
  FROM [dbo].[salidas] where equipo=@equ and tipo_llanta=@tipo_llanta and  fecha<=@f_c_fin and tipo='SALIDA' order by fecha desc


--Si por algun calculo raro da un valor de vida fuera de 0,1 lo ajsuta
set @pc_v_0 = @p_v_ini - (@hor_0-@h_ini) / @d_ini

if @pc_v_0<0
	set @pc_v_0=0
if @pc_v_0>1
	set @pc_v_0=1

set @pc_v_1 = @p_v_fin-(@hor_1-@h_fin)/@d_fin

if @pc_v_1<0
	set @pc_v_1=0
if @pc_v_1>1
	set @pc_v_1=1

set @con=(@pc_v_1-@pc_v_0)*@n_ll+@cnt

  insert into @inv(bod,h_ini ,pc_v_ini,d_ini,cnt,	h_fin,	pc_v_fin,d_fin ,h_cam,con ,	h_per) values(
		@bod,@hor_0,@pc_v_0,@d_ini,@cnt,@hor_1,@pc_v_1, @hor_1,@h_cam,@con,(@hor_1-@hor_0))

	-- Fill the table variable with the rows for your result set
	
	RETURN 
END



--equipos_para_rotacion

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[equipos_para_rotacion]
(

)
RETURNS 

@eq_rot TABLE 
(
   bodega int,
   equipo varchar(20),
   fecha datetime,
   horas int
)
AS
BEGIN
	declare @equipos  table (eq varchar(20),fecha datetime)
	declare @hoy datetime
	set @hoy=getdate()
	insert into @equipos (eq,fecha)
	select distinct equipo,max(fecha)
	from [dbInvLlantas].[dbo].[salidas]
	where fecha>='2015-01-01' and tipo_llanta='TRACCION' and tipo in('SALIDA','Rotacion') and cnt>=4
	group by equipo

insert into @eq_rot
select 
(select top 1 bodega from [dbInvLlantas].[dbo].[salidas] where equipo=e.eq order by fecha desc) as bodega,
e.eq as equipo,
e.fecha as fecha, 
dbo.hor(eq,@hoy)- dbo.hor(eq,fecha) as horas
from @equipos e
where dbo.hor(eq,@hoy)- dbo.hor(eq,fecha)>250 and dbo.hor(eq,@hoy)- dbo.hor(eq,fecha)<750
--order by bodega, dbo.hor(eq,@hoy)- dbo.hor(eq,fecha) desc
	-- Fill the table variable with the rows for your result set
	
	RETURN 
END



--estado_llanta

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION estado_llanta 
(
	@id varchar(15)
)
RETURNS varchar(20)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @ResultVar varchar(20)
	declare @eq varchar(20), @op varchar(20)

	SELECT top 1 @eq=equipo, @op=operacion FROM [dbInvLlantas].[dbo].[historia]
  where id=@id order by fecha desc


  if  @eq is null
		set @ResultVar='NO EXISTE'

 else 
		set @resultvar=@eq
		
  if @op='Desmontaje'
		set @ResultVar='DESMONTADA'		
	-- Return the result of the function
	RETURN @ResultVar

END



--crear_ajustes_v2

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[crear_ajustes_v2]
	@t_ajuste varchar(20),
	@ano int,
	@mes int
AS
BEGIN
IF OBJECT_ID('dbo.tmp', 'U') IS NOT NULL
  DROP TABLE dbo.tmp; 
select * into tmp from (SELECT  h.equipo,
			case	when h.Ubicacion<=2 then 'DIRECCION'
					when h.Ubicacion>2 and  h.Ubicacion<=10 then 'TRACCION'
					else 'REPUESTO' end  as tipo_llanta,  
					h.Fecha, h.Horometro as Horometro_final, sum(1) as cnt, operacion as tipo_ajuste,
					dbo.maximo(avg((dbo.prom(h.prof_1, h.prof_2, h.prof_3) - r.prof_min)/(r.prof_max-r.prof_min)),0) AS pc_vida,h.bodega


		FROM        (select distinct [marca-referencia],prof_max,prof_min from ref_llantas) AS r LEFT OUTER JOIN
                    llantas AS ll ON r.[marca-referencia] = ll.[marca-referencia] left OUTER JOIN
                    historia AS h ON ll.id = h.id

			where operacion=@t_ajuste and year(h.fecha)=@ano and month(fecha)=@mes
		group by    h.equipo, case	when h.Ubicacion<=2 then 'DIRECCION'

					when h.Ubicacion>2 and  h.Ubicacion<=10 then 'TRACCION'
					else 'REPUESTO' end, h.fecha, h.Horometro,operacion,bodega ) as t
					
if @t_ajuste='Revisión' or @t_ajuste='Rotacion'
	begin
		delete from ajustes where tipo_ajuste=@t_ajuste and year(fecha)=@ano and month(fecha)=@mes
		insert into ajustes
		select * from dbo.tmp
		delete from salidas where tipo=@t_ajuste and year(fecha)=@ano and month(fecha)=@mes
		insert into salidas (equipo,tipo_llanta,fecha,horometro_final,cnt,tipo,pc_vida,bodega,prom,prom_tendido)
		select equipo,tipo_llanta,fecha,horometro_final,cnt,tipo_ajuste,pc_vida,bodega,1500,1500 from tmp

		

end

END


