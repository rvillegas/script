
--codigo_eq

-- =============================================
-- Author:		Ramiro Villegas
-- Create date: 20-09-2013
-- Description:	Codigo Equivalente
-- =============================================
CREATE FUNCTION [dbo].[codigo_eq] 
(
	-- Add the parameters for the function here
	@codigo varchar(20)
)
RETURNS varchar(20)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @equivalente varchar(20)
	 set @equivalente=isnull((select codigo_equivalente from dbo.codigo_equivalente where codigo=@codigo),@codigo)

	-- Return the result of the function
	RETURN @equivalente

END



--optimizacion

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[optimizacion] 
(
	@codigo varchar(20),
	@ano int,
	@mes int
	
)
RETURNS
@tbl table(	cod  varchar(15), 
			dsc varchar(100), 
			bod int, 
			can numeric(18,6), 
			anomes int, 
			tipo varchar(20), 
			sxm numeric(18,3),
			vlr money)
AS
BEGIN

declare  @anomes_max int, @anomes_min int
declare @serial int, @codigo1 varchar(17)
set @serial=@ano*12+@mes
set @anomes_max=cast((@serial-4)/12 as int)*100+(@serial-4) % 12
set @anomes_min=cast((@serial-7)/12 as int)*100+(@serial-7) % 12
declare @ref_ccial varchar(50), @tsal numeric(18,4)
declare @nreg int
set @codigo1=@codigo+'*1'
select @ref_ccial=ref_comercial from referencias where codigo=@codigo

insert into @tbl (cod,dsc,bod,can,anomes)
SELECT i.codigo,r.descripcion, i.bodega
      ,i.can_ini+i.can_ent-i.can_sal as saldo,
	   isnull((SELECT [dbo].[Ultimo_movimiento] (i.codigo,i.bodega)),200901) as ultimo_movimiento
  FROM [dbo].[inventarios] i left outer join
    referencias r on replace(i.codigo,'*1','')=r.codigo
  where (i.codigo=@codigo or i.codigo=@codigo1
         or (not (r.ref_comercial is null) and r.ref_comercial=@ref_ccial) and r.ref_comercial<>'Nulo') 
		 and ano=@ano and mes=@mes and [can_ini]+can_ent-can_sal>0
  order by   (SELECT [dbo].[Ultimo_movimiento] (i.codigo,i.bodega)) asc

select @nreg=count(*) from @tbl

if @nreg=0
	begin
		insert into @tbl (cod,dsc,bod,can,anomes)
		select codigo,descripcion,0,0,200901 from referencias
		where codigo=@codigo
	end

update @tbl
	set vlr=(select  CASE 
				WHEN valor_unitario= 0 THEN costo_unitario
                 else valor_unitario
   END 
	 from referencias  r where cod=r.codigo)
update @tbl
	set sxm=(select sum(can_sal)/7 from dbo.inventarios i 
	              where i.codigo=cod  and ano*100+mes>@anomes_min and i.bodega=bod)

update @tbl
	set 
	tipo='Sin rotar'
	where anomes<@anomes_min

update @tbl
	set 
	tipo='Poca rotacion'
	where anomes>=@anomes_min	
update @tbl
	set 
	tipo='Con rotacion'
	where anomes>=@anomes_max		
	 
	-- Fill the table variable with the rows for your result set
	
	RETURN 
END



--movimiento_inventario

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE movimiento_inventario
	-- Add the parameters for the stored procedure here
	@anoini int,
	@mesini int,
	@anofin int,
	@mesfin int

AS
BEGIN
--declare @anoini as int, @mesini as int, @anofin as int, @mesfin as int
declare @ini as int, @fin as int, @anosig as int, @messig as int, @sig as int

--set @anoini=2012
--set @mesini=1
--set @anofin=2012
--set @mesfin=10
set @ini=@anoini*100+@mesini
set @fin=@anofin*100+@mesfin

if (@mesfin=12)
  begin
  set @messig=1
  set @anosig=@anofin+1
  end
else
	begin
  set @messig=@mesfin+1
  set @anosig=@anofin	 
end

print @anosig  
Print @messig
SELECT     
			inventarios.bodega, ' ' + inventarios.codigo AS codigo, 
			isnull((select can_ini from inventarios inv2 where (inventarios.codigo=inv2.codigo and inventarios.bodega=inv2.bodega and inv2.ano=@anoini and inv2.mes=@mesini)),0) as cnt_ini,
			SUM(inventarios.can_ent) AS entradas, SUM(inventarios.can_sal) AS salidas, 
			isnull((select can_ini from inventarios inv2 where (inventarios.codigo=inv2.codigo and inventarios.bodega=inv2.bodega and inv2.ano=@anosig and inv2.mes=@messig)),0) as cnt_saldo,

			isnull((select cos_ini from inventarios inv2 where (inventarios.codigo=inv2.codigo and inventarios.bodega=inv2.bodega and inv2.ano=@anoini and inv2.mes=@mesini)),0) as cos_ini,			
			SUM(inventarios.cos_ent) AS costo_entradas, SUM(inventarios.cos_sal) AS costo_salidas, referencias.descripcion, referencias.grupo, grupos.rotacion, grupos.descripcion AS descripcion                     
FROM         inventarios  LEFT OUTER JOIN
                      grupos RIGHT OUTER JOIN
                      referencias ON grupos.grupo = referencias.grupo ON inventarios.codigo = referencias.codigo
WHERE     (inventarios.ano*100+inventarios.mes >= @ini) AND 
          (inventarios.ano*100+inventarios.mes <= @fin) AND 
          (inventarios.can_ent + inventarios.can_sal > 0)
GROUP BY inventarios.bodega, inventarios.codigo, referencias.descripcion, referencias.grupo, grupos.rotacion, grupos.descripcion
HAVING      (grupos.rotacion IS NOT NULL)
ORDER BY inventarios.bodega, codigo
END



--obras

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[obras] 
(
)
RETURNS
@bod table (o varchar(20), b int)

AS
BEGIN
insert into @bod (o,b) values ('ASJ',60)
insert into @bod (o,b) values ('AV. COLON',84)
insert into @bod (o,b) values ('CCND',47)
insert into @bod (o,b) values ('CESAR G3',1118)
insert into @bod (o,b) values ('CESAR G3',1121)
insert into @bod (o,b) values ('DABEIBA',1100)
insert into @bod (o,b) values ('BODEGA2',2)
insert into @bod (o,b) values ('BODEGA2',8)
insert into @bod (o,b) values ('FOND. ADAPTACION',1106)
insert into @bod (o,b) values ('MONTERIA',85)
insert into @bod (o,b) values ('PACIFICO 3',1112)
insert into @bod (o,b) values ('SAN MARCOS',91)
insert into @bod (o,b) values ('SAN MARCOS',1103)
insert into @bod (o,b) values ('TALLER',3)
insert into @bod (o,b) values ('URABA',88)
insert into @bod (o,b) values ('URABA',96)
insert into @bod (o,b) values ('URABA',1109)
insert into @bod (o,b) values ('VIAS',35)
insert into @bod (o,b) values ('MARGINAL',52)
insert into @bod (o,b) values ('TUMACO',74)

insert into @bod (o,b) values ('TODOS',60)
insert into @bod (o,b) values ('TODOS',84)
insert into @bod (o,b) values ('TODOS',1118)
insert into @bod (o,b) values ('TODOS',1121)
insert into @bod (o,b) values ('TODOS',1100)
insert into @bod (o,b) values ('TODOS',2)
insert into @bod (o,b) values ('TODOS',8)
insert into @bod (o,b) values ('TODOS',1106)
insert into @bod (o,b) values ('TODOS',85)
insert into @bod (o,b) values ('TODOS',1112)
insert into @bod (o,b) values ('TODOS',91)
insert into @bod (o,b) values ('TODOS',1103)
insert into @bod (o,b) values ('TODOS',3)
insert into @bod (o,b) values ('TODOS',88)
insert into @bod (o,b) values ('TODOS',96)
insert into @bod (o,b) values ('TODOS',1109)
insert into @bod (o,b) values ('TODOS',35)

insert into @bod (o,b) values ('NECOCLI',96)
insert into @bod (o,b) values ('COLDESA',1109)
insert into @bod (o,b) values ('CAREPA',88)

insert into @bod (o,b) values ('SAN MARTIN',1118)
insert into @bod (o,b) values ('COPEY',1121)


	RETURN 
END




--rotacion_inventario_old

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[rotacion_inventario]
	-- Add the parameters for the stored procedure here
	@anoini int,
	@mesini int,
	@anofin int,
	@mesfin int

AS
BEGIN
--declare @anoini as int, @mesini as int, @anofin as int, @mesfin as int
declare @ini as int, @fin as int, @anosig as int, @messig as int, @sig as int
declare @np as int
--Crea archivo de rotacion
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rotacion]') AND type in (N'U'))
DROP TABLE [dbo].[rotacion]
CREATE TABLE [dbo].[rotacion](
	[codigo] [varchar](20) NULL,
	[bodega] [int] NULL,
	grupo varchar(5) NULL,
	[periodo_ultimo] [int] NULL,
	[Saldo] [numeric](18, 4) NULL,
	[Entradas] [numeric](18, 4) NULL,
	[Salidas] [numeric](18, 4) NULL,
	[rotacion_permitida] [numeric](18, 4) NULL,
	[rotacion_calculada] [numeric](18, 4) NULL,
	[valor_Inventario] [numeric](18, 4) NULL,
	[valor_muerto] [numeric](18, 4) NULL
) ON [PRIMARY]





--Carga Entradas y Salidas del periodo del periodo

--set @anoini=2012
--set @mesini=1
--set @anofin=2012
--set @mesfin=10
set @ini=@anoini*100+@mesini
set @fin=@anofin*100+@mesfin
set @np=(@anofin-@anoini)*12+@mesfin-@mesini+1
if (@mesfin=12)
  begin
  set @messig=1
  set @anosig=@anofin+1
  end
else
	begin
  set @messig=@mesfin+1
  set @anosig=@anofin	 
end

print @anosig  
Print @messig
--Carga codigo, bodega, periodo ultimo movimiento
insert into rotacion (codigo,bodega,periodo_ultimo)
SELECT     codigo, bodega, MAX(ano * 100 + mes) AS anomes
FROM         inventarios
where ano * 100 + mes>=@ini and ano * 100 + mes<=@fin
GROUP BY codigo, bodega
ORDER BY bodega, codigo, MAX(ano * 100 + mes) DESC
print 'Tabla generada, codigo,bodega, periodo ultimo cargado.'

update rotacion
set 
saldo=0,
Entradas=0,
Salidas=0,
rotacion_permitida=0,
rotacion_calculada=0,
valor_inventario=0,
valor_muerto=0

--Carga ultimo saldo

--encuentra el saldo de la ultima fecha, suma entradas de ese periodo y resta salidas

update rotacion

set 
Saldo= (select isnull(can_ini,0) from inventarios 
			where bodega=rotacion.bodega and codigo=rotacion.codigo and periodo_ultimo=ano*100+mes)+
			isnull((select SUM(ISNULL(-can_vta,0)+isnull(can_dev_vta,0)
			                  +isnull(can_com,0)-isnull(can_dev_com,0)-isnull(can_otr_sal,0)
			                  +isnull(can_otr_ent-can_tra,0)) from v_inv_doc_lin
			where bodega=rotacion.bodega and codigo=rotacion.codigo and periodo_ultimo=ano*100+mes 
			group by bodega,codigo,ano,mes),0),	
salidas=ISNULL((select SUM(isnull(can_vta,0)-isnull(can_dev_vta,0)+isnull(can_otr_sal,0))  from v_inv_doc_lin
		where bodega=rotacion.bodega and codigo=rotacion.codigo and (ano*100+mes>=@ini) and (ano*100+mes<=@fin) 
		group by bodega,codigo),0),
Entradas=ISNULL((select SUM(isnull(can_com,0)-isnull(can_dev_com,0)+isnull(can_otr_ent,0))  from v_inv_doc_lin
		where bodega=rotacion.bodega and codigo=rotacion.codigo and (ano*100+mes>=@ini) and (ano*100+mes<=@fin) 
		group by bodega,codigo),0),
grupo=(select grupo from referencias where rotacion.codigo=codigo),
valor_Inventario=(select isnull(cos_ini,0) from inventarios 
			where bodega=rotacion.bodega and codigo=rotacion.codigo and periodo_ultimo=ano*100+mes)+
					isnull((select SUM(ISNULL(-cos_vta,0)+isnull(cos_dev_vta,0)
			        +isnull(cos_com,0)-isnull(cos_dev_com,0)-isnull(cos_otr_sal,0)
			        +isnull(cos_otr_ent-cos_tra,0)) from v_inv_doc_lin
			where bodega=rotacion.bodega and codigo=rotacion.codigo and periodo_ultimo=ano*100+mes 
			group by bodega,codigo,ano,mes),0)			
---
update rotacion
set 
rotacion_permitida=(select rotacion from grupos where  rotacion.grupo=grupo),
rotacion_calculada=case when Salidas>0 then saldo*@np/salidas else 9999 end

update rotacion
set
valor_muerto=case when (rotacion_calculada-rotacion_permitida>0) and Saldo>0 then
							(saldo-rotacion_permitida*Salidas/@np)*valor_Inventario/saldo
								else 0 end	
								
update rotacion
set grupo=cambio_refs.grupo
from 
cambio_refs LEFT OUTER JOIN
rotacion ON cambio_refs.codigo = rotacion.codigo

update rotacion
set bodega=203
where bodega=2 or bodega=3
delete from rotacion where grupo is null
delete from rotacion where not(bodega=203 or bodega=2 or bodega=3 or bodega=47 or bodega=52 or bodega=60 or bodega=74 or bodega=85 or bodega=88)	or
                           not (grupo='02' or grupo= '04'or grupo= '05' or grupo= '06' or grupo= '07' or grupo= '08' or grupo='10' or grupo='13' or grupo='14')  							



SELECT     bodega,  SUM(valor_Inventario) AS Inventario, SUM(valor_muerto) AS fuera_rotacion_lt_1, sum(case when SALIDAS=0 then valor_inventario else 0 END) as sin_mvto_gt_1
FROM         rotacion
GROUP BY bodega
ORDER BY BODEGA
									
END	


--gr_mecanica

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION gr_mecanica 
(
)
RETURNS
@gru table(g varchar(5),d varchar(50))

AS
BEGIN
    insert into @gru (g,d) values('02', 'REPUESTOS DE MAQUINARIA Y EQUIPO')
	insert into @gru (g,d) values('04', 'LUBRICANTES Y ADITIVOS PARA EQUIPOS')
	insert into @gru (g,d) values('05', 'FILTROS')
	insert into @gru (g,d) values('06', 'RODAJE')
	insert into @gru (g,d) values('07', 'ELEMENTOS DE DESGASTE')
	insert into @gru (g,d) values('08', 'SOLDADURA')
	insert into @gru (g,d) values('09', 'COMPONENTES STAND BY')
	insert into @gru (g,d) values('13', 'MATERIALES ELÉCTRICOS')
	insert into @gru (g,d) values('14', 'HERRAMIENTAS')

	
	RETURN 
END



--anomes_add_mes

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[anomes_add_mes] 
(
	-- Add the parameters for the function here
	@intervalo int,
	@anomes int
)
RETURNS int
AS
BEGIN
	declare @fecha datetime, @ano int, @mes int
	declare @res_anomes int
	-- Declare the return variable here
	set @ano=cast(@anomes / 100 as int)
	set @mes =@anomes-@ano*100
	set @fecha=(SELECT CAST(CAST(@ano AS VARCHAR(4)) + RIGHT('0' + CAST(@mes AS VARCHAR(2)), 2) + '01' AS DATETIME))
	set @res_anomes=year(dateadd(month,@intervalo,@fecha))*100+month(dateadd(month,@intervalo,@fecha))
	RETURN  @res_anomes

END



--calculo_indicador

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[calculo_indicador]
(	
	-- Add the parameters for the function here
	@anomes int,
	@obra   varchar(20),
	@tipo   varchar(3)

)
RETURNS 
@ind table
(	[fecha] [datetime] NULL,
	[anomes_ind] [int] NULL,
	[anomes] [int] NULL,
	[obra] [varchar](20) NULL,
	[ent_ind] [numeric](18, 2) NULL,
	[inv_tra_ini] [numeric](18, 2) NULL,
	[inv_tra_fin] [numeric](18, 2) NULL,
	[pc_ini] [numeric](18, 2) NULL,
	[pc_fin] [numeric](18, 2) NULL,
	[inv_res_ini] [numeric](18, 2) NULL,
	[inv_res_fin] [numeric](18, 2) NULL,
	[inv_l1a_ini] [numeric](18, 2) NULL,
	[inv_l1a_fin] [numeric](18, 2) NULL,
	[inv_g1a_ini] [numeric](18, 2) NULL,
	[inv_g1a_fin] [numeric](18, 2) NULL,
	[inv_ini] [numeric](18, 2) NULL,
	[inv_fin] [numeric](18, 2) NULL,
	tipo varchar(3) null
)

AS
BEGIN
declare @ano int, @mes int, @ano_ind int, @mes_ind int,@intervalo int, @fecha datetime
declare @am_ant int, @a_ind_a int, @m_ind_a int
declare @am_r1_ini int,@am_r1_fin int,@am_r2_ini int,@am_r2_fin int,@am_r3_ini int,@am_r3_fin int,@am_r4_ini int,@am_r4_fin int
--@am_r1_ini  añomes rango 1 inicial = @ano*100+@mes-@intervalo+1
--@am_r1_fin  añomes rango 1 final = @ano*100+@mes

declare @ent_ind numeric(18,2)
declare @inv_tra_ini numeric(18,2), @inv_res_ini  numeric(18,2),@inv_l1a_ini  numeric(18,2),@inv_g1a_ini  numeric(18,2), @inv_ini   numeric(18,2)
declare @inv_tra_fin numeric(18,2), @inv_res_fin  numeric(18,2),@inv_l1a_fin  numeric(18,2),@inv_g1a_fin  numeric(18,2), @inv_fin  numeric(18,2)

declare @gru table(g varchar(5),d varchar(50))
declare @bod table (o varchar(20), b int)

insert into @bod select * from dbo.obras()
IF @tipo='MEC'
	insert into @gru select * from dbo.gr_mecanica()
else
	insert into @gru select * from dbo.gr_civil()
declare @tmp varchar(20)
set @intervalo=3
set @ano=cast(@anomes/100 as int)
set @mes=@anomes-@ano*100
set @fecha=(SELECT CAST(CAST(@ano AS VARCHAR(4)) + RIGHT('0' + CAST(@mes AS VARCHAR(2)), 2) + '01' AS DATETIME))
--select @fecha
set @am_ant=(SELECT [dbo].[anomes_add_mes] (-1,@anomes))

set @am_r1_ini=(SELECT [dbo].[anomes_add_mes] (-@intervalo+1,@anomes))
set @am_r1_fin=@anomes

set @am_r2_ini=(SELECT [dbo].[anomes_add_mes] (-@intervalo,@anomes))
set @am_r2_fin=(SELECT [dbo].[anomes_add_mes] (-@intervalo,@anomes))
set @am_r3_ini=(SELECT [dbo].[anomes_add_mes] (-12,@anomes))
set @am_r3_fin=(SELECT [dbo].[anomes_add_mes] (-@intervalo-1,@anomes))

set @am_r4_ini=(SELECT [dbo].[anomes_add_mes] (-100,@anomes))
set @am_r4_fin=(SELECT [dbo].[anomes_add_mes] (-13,@anomes))

--select @am_r1_ini,@am_r1_fin, @am_r2_ini, @am_r2_fin, @am_r3_ini,@am_r3_fin, @am_r4_ini, @am_r4_fin


--set @ano_ant=year(dateadd(month,-1,@fecha))
--set @mes_ant=month(dateadd(month,-1,@fecha))
--set @ano_ind=year(dateadd(month,-@intervalo,@fecha))
--set @mes_ind=month(dateadd(month,-@intervalo,@fecha))
--set @a_ind_a=year(dateadd(month,-@intervalo-1,@fecha))
--set @m_ind_a=month(dateadd(month,-@intervalo-1,@fecha))


--	fecha	Fecha actual
--	ano_ind	Año del periodo que se evalua el indicador
--	mes_ind	Mes del periodo que se evalua el indicador
--	ano	año periodo actual
--	mes	mes periodo actual
--	obra	obra TODOS y BODEGA 2
--	ent_ind	Entradas del periodo que se evalua el indicador
--	inv_tra_ini	Inventario sin movimiento al incio de la fecha actual (3 meses)
--	inv_tra_fin	Inventario sin movimiento actual y al final de la fecha actual (3 meses)
--	pc_ini	Porcentaje al inicio
--	pc_fin	Porcentaje al final
--	inv_res_ini	 Inventario resiente de 0 a 2 meses de ultimo movimientos al inicial el periodo
--	inv_res_fin	 Inventario resiente de 0 a 2 meses de ultimo movimientos al finalizar el periodo
--	inv_l1a_ini	 Inventario mayor de 3 meses hasta 1 año (4-12 meses) de ultimo movimientos al inicio del periodo
--	inv_res_fin	 Inventario mayor de 3 meses hasta 1 año (4-12 meses) de ultimo movimientos al final del periodo
--	inv_g1a_ini	 Inventario mayor de 12 meses hasta (13- meses) de ultimo movimientos al inicio del periodo
--	inv_g1a_fin	 Inventario mayor de 12 meses hasta (13- meses) de ultimo movimientos al final del periodo
--  inv_ini Inventario inicial
--	inv_fin	Inventario actual
--	sal_ant_ind	Salidas del mes actual que entraron antes del periodo que se evalua
--	sal_ind	Salidas del mes actual que entraron en el periodo que se evalua
--	sal_des_ind	Salidas del mes actual que entraron despues del periodo que se evalua.
--	ent_act	Entradas del periodo actual
--  inv_ini=inv_res_ini+inv_tra_ini+inv_l1a_ini+inv_g1a_ini

--Inventario resiente
select @inv_res_ini=sum(costo_stock) from v_ref_total vrf
where ano*100+mes=@am_ant and (dbo.ult_ent_vrt(vrf.codigo,vrf.bodega,@am_r1_fin) between @am_r1_ini and @am_r1_fin) and
grupo in (select g from @gru) and bodega in (select b from @bod where o=@obra)

select @inv_res_fin=sum(costo_stock) from v_ref_total vrf
where ano*100+mes=@ano*100+@mes and (dbo.ult_ent_vrt(vrf.codigo,vrf.bodega,@ano*100+@mes) between @am_r1_ini and @am_r1_fin) and
grupo in (select g from @gru) and bodega in (select b from @bod where o=@obra)

--Inventario en transision de resiente a obsoleto
select @inv_tra_ini=sum(costo_stock) from v_ref_total vrf
where ano*100+mes=@am_ant and (dbo.ult_ent_vrt(vrf.codigo,vrf.bodega,@am_r1_fin)=@am_r2_ini) and
grupo in (select g from @gru) and bodega in (select b from @bod where o=@obra)

select @inv_tra_fin=sum(costo_stock) from v_ref_total vrf
where ano*100+mes=@ano*100+@mes and (dbo.ult_ent_vrt(vrf.codigo,vrf.bodega,@ano*100+@mes)=@am_r2_ini) and
grupo in (select g from @gru) and bodega in (select b from @bod where o=@obra)

--Inventario obsoleto de menos de un año y mas de 3 meses
select @inv_l1a_ini=sum(costo_stock) from v_ref_total vrf
where ano*100+mes=@am_ant and (dbo.ult_ent_vrt(vrf.codigo,vrf.bodega,@am_r1_fin) between @am_r3_ini and @am_r3_fin) and
grupo in (select g from @gru) and bodega in (select b from @bod where o=@obra)

select @inv_l1a_fin=sum(costo_stock) from v_ref_total vrf
where ano*100+mes=@ano*100+@mes and (dbo.ult_ent_vrt(vrf.codigo,vrf.bodega,@ano*100+@mes) between @am_r3_ini and @am_r3_fin) and
grupo in (select g from @gru) and bodega in (select b from @bod where o=@obra)

--Inventario obsoleto de mas de un año 
select @inv_g1a_ini=sum(costo_stock) from v_ref_total vrf
where ano*100+mes=@am_ant and 
(dbo.ult_ent_vrt(vrf.codigo,vrf.bodega,@am_r1_fin)<=@am_r4_fin or dbo.ult_ent_vrt(vrf.codigo,vrf.bodega,@am_r1_fin) is null) 
and grupo in (select g from @gru) and bodega in (select b from @bod where o=@obra)

select @inv_g1a_fin=sum(costo_stock) from v_ref_total vrf
where ano*100+mes=@ano*100+@mes and (dbo.ult_ent_vrt(vrf.codigo,vrf.bodega,@am_r1_fin)<=@am_r4_fin or dbo.ult_ent_vrt(vrf.codigo,vrf.bodega,@am_r1_fin) is null) and
grupo in (select g from @gru) and bodega in (select b from @bod where o=@obra)

--Total inventario
select @inv_ini=sum(costo_stock) from v_ref_total vrf
where ano*100+mes=@am_ant and
grupo in (select g from @gru) and bodega in (select b from @bod where o=@obra)

select @inv_fin=sum(costo_stock) from v_ref_total vrf
where ano*100+mes=@ano*100+@mes and 
grupo in (select g from @gru) and bodega in (select b from @bod where o=@obra)

select  @ent_ind=sum(cos_ent) from v_ref_total where 
 [dbo].[ult_ent_vrt] (codigo,bodega,@am_r2_ini)=@am_r2_ini  and
ano*100+mes=@am_r2_ini and
grupo in (select g from @gru) and bodega in (select b from @bod where o=@obra)

--select  grupo, codigo, descripcion , cos_ent from v_ref_total where 
-- [dbo].[ult_ent_vrt] (codigo,bodega,@am_r2_ini)=@am_r2_ini  and
--ano*100+mes=@am_r2_ini and
--grupo in (select g from @gru) and bodega in (select b from @bod where o=@obra)
--order by grupo

--select  grupo, codigo, descripcion , Costo_Stock from v_ref_total vrf
--where ano*100+mes=@ano*100+@mes and (dbo.ult_ent_vrt(vrf.codigo,vrf.bodega,@ano*100+@mes)=@am_r2_ini) and
--grupo in (select g from @gru) and bodega in (select b from @bod where o=@obra)



--select @inv_res_ini,@inv_res_fin,@inv_tra_ini,@inv_tra_fin,@inv_l1a_ini,@inv_l1a_fin,@inv_g1a_ini,@inv_g1a_fin,@inv_ini,@inv_fin


INSERT INTO @ind
           ([fecha]
           ,[anomes_ind]
           ,[anomes]
           ,[obra]
           ,[ent_ind]
           ,[inv_tra_ini]
           ,[inv_tra_fin]
           ,[pc_ini]
           ,[pc_fin]
           ,[inv_res_ini]
           ,[inv_res_fin]
           ,[inv_l1a_ini]
           ,[inv_l1a_fin]
           ,[inv_g1a_ini]
           ,[inv_g1a_fin]
           ,[inv_ini]
           ,[inv_fin]
		   ,tipo)
     VALUES
           (getdate(),@am_r2_ini,@anomes,@obra,isnull(@ent_ind,0),isnull(@inv_tra_ini,0),
		              isnull(@inv_tra_fin,0), isnull(@inv_tra_ini/@ent_ind,0),
		              isnull(@inv_tra_fin/@ent_ind,0), isnull(@inv_res_ini,0), 
					  isnull(@inv_res_fin,0), isnull(@inv_l1a_ini,0), isnull(@inv_l1a_fin,0), isnull(@inv_g1a_ini,0),
					  isnull(@inv_g1a_fin,0), isnull(@inv_ini,0),isnull( @inv_fin,0),@tipo)
	
	RETURN 
END



--actualizarIndicador

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[actualizarIndicador] 
	
AS
BEGIN
declare @anomes int
declare @ind table
(	[fecha] [datetime] NULL,
	[anomes_ind] [int] NULL,
	[anomes] [int] NULL,
	[obra] [varchar](20) NULL,
	[ent_ind] [numeric](18, 2) NULL,
	[inv_tra_ini] [numeric](18, 2) NULL,
	[inv_tra_fin] [numeric](18, 2) NULL,
	[pc_ini] [numeric](18, 2) NULL,
	[pc_fin] [numeric](18, 2) NULL,
	[inv_res_ini] [numeric](18, 2) NULL,
	[inv_res_fin] [numeric](18, 2) NULL,
	[inv_l1a_ini] [numeric](18, 2) NULL,
	[inv_l1a_fin] [numeric](18, 2) NULL,
	[inv_g1a_ini] [numeric](18, 2) NULL,
	[inv_g1a_fin] [numeric](18, 2) NULL,
	[inv_ini] [numeric](18, 2) NULL,
	[inv_fin] [numeric](18, 2) NULL,
	tipo varchar(3) null
)

set @anomes=year(GETDATE())*100+month(getdate())
		insert into @ind
		SELECT * FROM [dbo].[calculo_indicador] (@anomes,'VIAS','MEC')
		insert into @ind
		SELECT * FROM [dbo].[calculo_indicador] (@anomes,'URABA','MEC')
		insert into @ind
		SELECT * FROM [dbo].[calculo_indicador] (@anomes,'MONTERIA','MEC')
		insert into @ind
		SELECT * FROM [dbo].[calculo_indicador] (@anomes,'SAN MARCOS','MEC')
		insert into @ind
		SELECT * FROM [dbo].[calculo_indicador] (@anomes,'ASJ','MEC')
		insert into @ind
		SELECT * FROM [dbo].[calculo_indicador] (@anomes,'CESAR G3','MEC')
		insert into @ind
		SELECT * FROM [dbo].[calculo_indicador] (@anomes,'DABEIBA','MEC')
		insert into @ind
		SELECT * FROM [dbo].[calculo_indicador] (@anomes,'FOND. ADAPTACION','MEC')
		insert into @ind
		SELECT * FROM [dbo].[calculo_indicador] (@anomes,'TALLER','MEC')
		insert into @ind
		SELECT * FROM [dbo].[calculo_indicador] (@anomes,'MARGINAL','MEC')
		insert into @ind
		SELECT * FROM [dbo].[calculo_indicador] (@anomes,'TUMACO','MEC')
		insert into @ind
		SELECT * FROM [dbo].[calculo_indicador] (@anomes,'BODEGA2','MEC')
		insert into @ind
		SELECT * FROM [dbo].[calculo_indicador] (@anomes,'TODOS','MEC')
		insert into @ind
		SELECT * FROM [dbo].[calculo_indicador] (@anomes,'SAN MARTIN','MEC')
		insert into @ind
		SELECT * FROM [dbo].[calculo_indicador] (@anomes,'COPEY','MEC')
		insert into @ind
		SELECT * FROM [dbo].[calculo_indicador] (@anomes,'NECOCLI','MEC')
		insert into @ind
		SELECT * FROM [dbo].[calculo_indicador] (@anomes,'CAREPA','MEC')
		insert into @ind
		SELECT * FROM [dbo].[calculo_indicador] (@anomes,'COLDESA','MEC')

		insert into @ind
		SELECT * FROM [dbo].[calculo_indicador] (@anomes,'VIAS','CIV')
		insert into @ind
		SELECT * FROM [dbo].[calculo_indicador] (@anomes,'URABA','CIV')
		insert into @ind
		SELECT * FROM [dbo].[calculo_indicador] (@anomes,'MONTERIA','CIV')
		insert into @ind
		SELECT * FROM [dbo].[calculo_indicador] (@anomes,'SAN MARCOS','CIV')
		insert into @ind
		SELECT * FROM [dbo].[calculo_indicador] (@anomes,'ASJ','CIV')
		insert into @ind
		SELECT * FROM [dbo].[calculo_indicador] (@anomes,'CESAR G3','CIV')
		insert into @ind
		SELECT * FROM [dbo].[calculo_indicador] (@anomes,'DABEIBA','CIV')
		insert into @ind
		SELECT * FROM [dbo].[calculo_indicador] (@anomes,'FOND. ADAPTACION','CIV')
		insert into @ind
		SELECT * FROM [dbo].[calculo_indicador] (@anomes,'TALLER','CIV')
		insert into @ind
		SELECT * FROM [dbo].[calculo_indicador] (@anomes,'MARGINAL','CIV')
		insert into @ind
		SELECT * FROM [dbo].[calculo_indicador] (@anomes,'TUMACO','CIV')
		insert into @ind
		SELECT * FROM [dbo].[calculo_indicador] (@anomes,'BODEGA2','CIV')
		insert into @ind
		SELECT * FROM [dbo].[calculo_indicador] (@anomes,'TODOS','CIV')
		insert into @ind
		SELECT * FROM [dbo].[calculo_indicador] (@anomes,'SAN MARTIN','CIV')
		insert into @ind
		SELECT * FROM [dbo].[calculo_indicador] (@anomes,'COPEY','CIV')
		insert into @ind
		SELECT * FROM [dbo].[calculo_indicador] (@anomes,'NECOCLI','CIV')
		insert into @ind
		SELECT * FROM [dbo].[calculo_indicador] (@anomes,'CAREPA','CIV')
		insert into @ind
		SELECT * FROM [dbo].[calculo_indicador] (@anomes,'COLDESA','CIV')

	delete from indicador
	where anomes=@anomes

	insert into indicador
	select * from @ind

	select * from @ind
END



--detalle_indicador

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[detalle_indicador]
(
	-- Add the parameters for the function here
	@anomes int,
	@obra varchar(20),
	@tipo varchar(3)


)
RETURNS 
@res table(fecha datetime, anomes int, obra varchar(20), codigo varchar(20), descripcion varchar(80), stock numeric(18,4), costo_stock numeric(18,4), destino varchar(255),cos_des numeric(18,4),tipo varchar(3))
AS
BEGIN
declare  @anomes_ind int
declare @gru table(g varchar(5),d varchar(50))
declare @bod table (o varchar(20), b int)
declare @tmp table (d varchar(255), c money)


insert into @bod select * from dbo.obras()
if @tipo='MEC'
insert into @gru select * from dbo.gr_mecanica()
else
insert into @gru select * from dbo.gr_civil()

set @anomes_ind=[dbo].[anomes_add_mes] (-3,@anomes)
 
insert into @tmp
select  destino, SUM(Costo_Stock) from v_ref_total vrf
where ano*100+mes=@anomes and (dbo.ult_ent_vrt(vrf.codigo,vrf.bodega,@anomes)=@anomes_ind) and
grupo in (select g from @gru) and bodega in (select b from @bod where o=@obra) and costo_stock>0
GROUP BY destino
ORDER BY SUM(Costo_Stock) DESC

insert into @res
select  getdate(),@anomes, @obra, codigo, descripcion , stock, Costo_Stock,destino,v.c as cos_des,@tipo
 from v_ref_total vrf inner join
  @tmp v on vrf.destino=v.d
where ano*100+mes=@anomes and (dbo.ult_ent_vrt(vrf.codigo,vrf.bodega,@anomes)=@anomes_ind) and
grupo in (select g from @gru) and bodega in (select b from @bod where o=@obra) and costo_stock>0
order by v.c desc, Costo_Stock desc
	RETURN 
END



--actualizar_detalle_Indicador


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[actualizar_detalle_Indicador] 
	
AS
BEGIN
declare @anomes int
declare @ind table
(	fecha datetime null,
    anomes int null,
	obra varchar(20) null,
codigo varchar(20) null, 
descripcion varchar(80) null, 
stock numeric(18,4) null, 
costo_stock numeric(18,4) null, 
destino varchar(255) null,
cos_des numeric(18,4) null,
tipo varchar(3)
)

set @anomes=year(GETDATE())*100+month(getdate())
		insert into @ind
		SELECT * FROM [dbo].[detalle_indicador] (@anomes,'VIAS','MEC')
		insert into @ind
		SELECT * FROM [dbo].[detalle_indicador] (@anomes,'URABA','MEC')
		insert into @ind
		SELECT * FROM [dbo].[detalle_indicador] (@anomes,'MONTERIA','MEC')
		insert into @ind
		SELECT * FROM [dbo].[detalle_indicador] (@anomes,'SAN MARCOS','MEC')
		insert into @ind
		SELECT * FROM [dbo].[detalle_indicador] (@anomes,'ASJ','MEC')
		insert into @ind
		SELECT * FROM [dbo].[detalle_indicador] (@anomes,'CESAR G3','MEC')
		insert into @ind
		SELECT * FROM [dbo].[detalle_indicador] (@anomes,'DABEIBA','MEC')
		insert into @ind
		SELECT * FROM [dbo].[detalle_indicador] (@anomes,'FOND. ADAPTACION','MEC')
		insert into @ind
		SELECT * FROM [dbo].[detalle_indicador] (@anomes,'TALLER','MEC')
		insert into @ind
		SELECT * FROM [dbo].[detalle_indicador] (@anomes,'MARGINAL','MEC')
		insert into @ind
		SELECT * FROM [dbo].[detalle_indicador] (@anomes,'TUMACO','MEC')
		insert into @ind
		SELECT * FROM [dbo].[detalle_indicador] (@anomes,'BODEGA2','MEC')
		insert into @ind
		SELECT * FROM [dbo].[detalle_indicador] (@anomes,'TODOS','MEC')
		insert into @ind
		SELECT * FROM [dbo].[detalle_indicador] (@anomes,'SAN MARTIN','MEC')
		insert into @ind
		SELECT * FROM [dbo].[detalle_indicador] (@anomes,'COPEY','MEC')
		insert into @ind
		SELECT * FROM [dbo].[detalle_indicador] (@anomes,'NECOCLI','MEC')
		insert into @ind
		SELECT * FROM [dbo].[detalle_indicador] (@anomes,'CAREPA','MEC')
		insert into @ind
		SELECT * FROM [dbo].[detalle_indicador] (@anomes,'COLDESA','MEC')

		insert into @ind
		SELECT * FROM [dbo].[detalle_indicador] (@anomes,'VIAS','CIV')
		insert into @ind
		SELECT * FROM [dbo].[detalle_indicador] (@anomes,'URABA','CIV')
		insert into @ind
		SELECT * FROM [dbo].[detalle_indicador] (@anomes,'MONTERIA','CIV')
		insert into @ind
		SELECT * FROM [dbo].[detalle_indicador] (@anomes,'SAN MARCOS','CIV')
		insert into @ind
		SELECT * FROM [dbo].[detalle_indicador] (@anomes,'ASJ','CIV')
		insert into @ind
		SELECT * FROM [dbo].[detalle_indicador] (@anomes,'CESAR G3','CIV')
		insert into @ind
		SELECT * FROM [dbo].[detalle_indicador] (@anomes,'DABEIBA','CIV')
		insert into @ind
		SELECT * FROM [dbo].[detalle_indicador] (@anomes,'FOND. ADAPTACION','CIV')
		insert into @ind
		SELECT * FROM [dbo].[detalle_indicador] (@anomes,'TALLER','CIV')
		insert into @ind
		SELECT * FROM [dbo].[detalle_indicador] (@anomes,'MARGINAL','CIV')
		insert into @ind
		SELECT * FROM [dbo].[detalle_indicador] (@anomes,'TUMACO','CIV')
		insert into @ind
		SELECT * FROM [dbo].[detalle_indicador] (@anomes,'BODEGA2','CIV')
		insert into @ind
		SELECT * FROM [dbo].[detalle_indicador] (@anomes,'TODOS','CIV')
		insert into @ind
		SELECT * FROM [dbo].[detalle_indicador] (@anomes,'SAN MARTIN','CIV')
		insert into @ind
		SELECT * FROM [dbo].[detalle_indicador] (@anomes,'COPEY','CIV')
		insert into @ind
		SELECT * FROM [dbo].[detalle_indicador] (@anomes,'NECOCLI','CIV')
		insert into @ind
		SELECT * FROM [dbo].[detalle_indicador] (@anomes,'CAREPA','CIV')
		insert into @ind
		SELECT * FROM [dbo].[detalle_indicador] (@anomes,'COLDESA','CIV')

	delete from tbl_detalle_indicador


	insert into tbl_detalle_indicador
	select * from @ind

	select * from @ind
END




--detalle_pre_indicador

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[detalle_pre_indicador]
(
	-- Add the parameters for the function here
	@anomes int,
	@obra varchar(20),
	@tipo varchar(3),
	@delta int 


)
RETURNS 
@res table(fecha datetime, anomes int, obra varchar(20), codigo varchar(20), descripcion varchar(80), stock numeric(18,4), costo_stock numeric(18,4), destino varchar(255),cos_des numeric(18,4),tipo varchar(3))
AS
BEGIN
declare  @anomes_ind int
declare @gru table(g varchar(5),d varchar(50))
declare @bod table (o varchar(20), b int)
declare @tmp table (d varchar(255), c money)


insert into @bod select * from dbo.obras()
insert into @gru select * from dbo.gr_mecanica()

set @anomes_ind=[dbo].[anomes_add_mes] (-@delta,@anomes)
 
insert into @tmp
select  destino, SUM(Costo_Stock) from v_ref_total vrf
where ano*100+mes=@anomes and (dbo.ult_ent_vrt(vrf.codigo,vrf.bodega,@anomes)=@anomes_ind) and
grupo in (select g from @gru) and bodega in (select b from @bod where o=@obra) and costo_stock>0
GROUP BY destino
ORDER BY SUM(Costo_Stock) DESC

insert into @res
select  getdate(),@anomes, @obra, codigo, descripcion , stock, Costo_Stock,destino,v.c as cos_des, @tipo
 from v_ref_total vrf inner join
  @tmp v on vrf.destino=v.d
where ano*100+mes=@anomes and (dbo.ult_ent_vrt(vrf.codigo,vrf.bodega,@anomes)=@anomes_ind) and
grupo in (select g from @gru) and bodega in (select b from @bod where o=@obra) and costo_stock>0
order by v.c desc, Costo_Stock desc
	RETURN 
END



--actualizar_detalle_pre_Indicador


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[actualizar_detalle_pre_Indicador] 
	(@delta int)
AS
BEGIN
declare @anomes int
declare @ind table
(	fecha datetime null,
    anomes int null,
	obra varchar(20) null,
codigo varchar(20) null, 
descripcion varchar(80) null, 
stock numeric(18,4) null, 
costo_stock numeric(18,4) null, 
destino varchar(255) null,
cos_des numeric(18,4) null
)

set @anomes=year(GETDATE())*100+month(getdate())
		insert into @ind
		SELECT * FROM [dbo].[detalle_pre_indicador] (@anomes,'VIAS','MEC',@delta)
		insert into @ind
		SELECT * FROM [dbo].[detalle_pre_indicador] (@anomes,'URABA','MEC',@delta)
		insert into @ind
		SELECT * FROM [dbo].[detalle_pre_indicador] (@anomes,'MONTERIA','MEC',@delta)
		insert into @ind
		SELECT * FROM [dbo].[detalle_pre_indicador] (@anomes,'SAN MARCOS','MEC',@delta)
		insert into @ind
		SELECT * FROM [dbo].[detalle_pre_indicador] (@anomes,'ASJ','MEC',@delta)
		insert into @ind
		SELECT * FROM [dbo].[detalle_pre_indicador]  (@anomes,'CESAR G3','MEC',@delta)
		insert into @ind
		SELECT * FROM [dbo].[detalle_pre_indicador]  (@anomes,'DABEIBA','MEC',@delta)
		insert into @ind
		SELECT * FROM [dbo].[detalle_pre_indicador]  (@anomes,'FOND. ADAPTACION','MEC',@delta)
		insert into @ind
		SELECT * FROM [dbo].[detalle_pre_indicador]  (@anomes,'TALLER','MEC',@delta)
		insert into @ind
		SELECT * FROM [dbo].[detalle_pre_indicador] (@anomes,'MARGINAL','MEC',@delta)
		insert into @ind
		SELECT * FROM [dbo].[detalle_pre_indicador]  (@anomes,'TUMACO','MEC',@delta)
		insert into @ind
		SELECT * FROM [dbo].[detalle_pre_indicador]  (@anomes,'BODEGA2','MEC',@delta)
		SELECT * FROM [dbo].[detalle_pre_indicador] (@anomes,'TODOS','MEC',@delta)
		insert into @ind
		SELECT * FROM [dbo].[detalle_pre_indicador] (@anomes,'SAN MARTIN','MEC',@delta)
		insert into @ind
		SELECT * FROM [dbo].[detalle_pre_indicador] (@anomes,'COPEY','MEC',@delta)
		insert into @ind
		SELECT * FROM [dbo].[detalle_pre_indicador] (@anomes,'NECOCLI','MEC',@delta)
		insert into @ind
		SELECT * FROM [dbo].[detalle_pre_indicador] (@anomes,'CAREPA','MEC',@delta)
		insert into @ind
		SELECT * FROM [dbo].[detalle_pre_indicador] (@anomes,'COLDESA','MEC',@delta)



	delete from tbl_detalle_pre_indicador


	insert into tbl_detalle_pre_indicador
	select * from @ind

	select * from @ind
END




--gr_civil

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create FUNCTION [dbo].[gr_civil] 
(
)
RETURNS
@gru table(g varchar(5),d varchar(50))

AS
BEGIN



    insert into @gru (g,d) values('01', 'MATERIALES DIRECTOS')
	insert into @gru (g,d) values('03', 'COMBUSTIBLES')
	insert into @gru (g,d) values('10', 'FERRETERÍA')
	insert into @gru (g,d) values('100', 'ARENILLA')
	insert into @gru (g,d) values('101', 'ARENA LAVADA')
	insert into @gru (g,d) values('102', 'BASES GRANULARES')
	insert into @gru (g,d) values('103', 'TRITURADOS')
	insert into @gru (g,d) values('104', 'MEZCLA ASFALTICA')
	insert into @gru (g,d) values('105', 'ESCOMBROS')

    insert into @gru (g,d) values('106', 'PRODUCCION DE MATERIALES')
	insert into @gru (g,d) values('11', 'DOTACION LEGAL')
	insert into @gru (g,d) values('12', 'PRODUCTOS QUIMICOS')
	insert into @gru (g,d) values('13', 'MATERIALES ELECTRICOS')
	insert into @gru (g,d) values('14', 'HERRAMIENTAS')
	insert into @gru (g,d) values('15', 'EQUIPOS MENORES')
	insert into @gru (g,d) values('16', 'EQUIPOS DE MEDICION')
	insert into @gru (g,d) values('17', 'ENSERES Y EQUIPOS DE OFICINA')
	insert into @gru (g,d) values('18', 'PAPELERÍA')
	insert into @gru (g,d) values('19', 'OTROS IMPUESTOS')
	insert into @gru (g,d) values('20', 'SERVICIOS REPARACION MAQUINARIA Y EQUIPOS')
	insert into @gru (g,d) values('21', 'SERVICIO DE REPARACION DE VEHICULOS')
	insert into @gru (g,d) values('22', 'TRANSPORTE')
	insert into @gru (g,d) values('23', 'INGRESOS POR VENTAS')
	insert into @gru (g,d) values('24', 'ARRENDAMIENTOS')
	insert into @gru (g,d) values('25', 'PERFIL EQUIPOS')
	insert into @gru (g,d) values('26', 'IZAJE Y MOVIMIENTO DE CARGA')

	insert into @gru (g,d) values('27', 'SISO')
	insert into @gru (g,d) values('28', 'SERVICIOS DE METROLOGÍA')

	RETURN 
END



--ccial2dms

-- =============================================
-- Author:		ramiro villegas
-- Create date: 26-11-2014
-- Description:	Referencia comercial a dms
-- =============================================
CREATE FUNCTION [dbo].[ccial2dms] 
(
	-- Add the parameters for the function here
	@patron  varchar(50) 
	 
)
RETURNS 
@tbl TABLE 
(
	-- Add the column definitions for the TABLE variable here
	ref_comercial varchar(50),
	codigo varchar(20),
	descripcion varchar(80)
)
AS
BEGIN
  DECLARE @lpatron varchar(100)
  set @lpatron='%'+upper(@patron)+'%'
   insert into @tbl (ref_comercial,codigo,descripcion)
	SELECT [ref_comercial],[codigo],[descripcion]
      
  FROM [dbo].[referencias]
  where upper(ref_comercial) like @lpatron

	
	RETURN 
END



--Ultimo_movimiento

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[Ultimo_movimiento]
(
    @codigo varchar(20),
    @bodega int
)
RETURNS int
AS
BEGIN
declare @resultado int

set @resultado=(select top 1  ano*100+mes  from inventarios
where codigo=@codigo and bodega=@bodega and (can_sal>0 or can_ent>0)
order by ano desc,mes desc)
return @resultado
END



--Saldo_und

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[Saldo_und]
(
    @codigo varchar(20),
    @bodega int,
    @ano int,
    @mes int
    
)
RETURNS numeric(18,2)
AS
BEGIN
declare @resultado numeric(18,2)

set @resultado=(SELECT 
      [can_ini]+[can_ent]-[can_sal]
  FROM [analisisInventarios].[dbo].[inventarios]
  where codigo=@codigo and ano=@ano and mes=@mes and bodega=@bodega)
return @resultado
END


--rotacion_inventario

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[rotacion_inventario]
	-- Add the parameters for the stored procedure here
	@anoini int,
	@mesini int,
	@anofin int,
	@mesfin int

AS
BEGIN
--declare @anoini as int, @mesini as int, @anofin as int, @mesfin as int
declare @ini as int, @fin as int, @anosig as int, @messig as int, @sig as int
declare @np as int
--Crea archivo de rotacion
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rotacion]') AND type in (N'U'))
DROP TABLE [dbo].[rotacion]
CREATE TABLE [dbo].[rotacion](
	[codigo] [varchar](20) NULL,
	[bodega] [int] NULL,
	grupo varchar(5) NULL,
	[periodo_ultimo] [int] NULL,
	[anomes_primero] [int] null,
	[Saldo] [numeric](18, 4) NULL,
	[Entradas] [numeric](18, 4) NULL,
	[Salidas] [numeric](18, 4) NULL,
	[rotacion_permitida] [numeric](18, 4) NULL,
	[rotacion_calculada] [numeric](18, 4) NULL,
	[valor_Inventario] [numeric](18, 4) NULL,
	[valor_muerto] [numeric](18, 4) NULL
) ON [PRIMARY]

--Carga Entradas y Salidas del periodo del periodo

--set @anoini=2012
--set @mesini=1
--set @anofin=2012
--set @mesfin=10
set @ini=@anoini*100+@mesini
set @fin=@anofin*100+@mesfin
set @np=(@anofin-@anoini)*12+@mesfin-@mesini+1
if (@mesfin=12)
  begin
  set @messig=1
  set @anosig=@anofin+1
  end
else
	begin
  set @messig=@mesfin+1
  set @anosig=@anofin	 
end
set @sig=@anosig*100+@messig
print @sig
--Carga codigo, bodega, periodo ultimo movimiento
insert into rotacion (codigo,bodega,periodo_ultimo)
SELECT     codigo, bodega, MAX(ano * 100 + mes) AS anomes
FROM         inventarios
where ano * 100 + mes>=@ini and ano * 100 + mes<=@sig
GROUP BY codigo, bodega
ORDER BY bodega, codigo, MAX(ano * 100 + mes) DESC
print 'Tabla generada, codigo,bodega, periodo ultimo cargado.'

update rotacion
set 
saldo=0,
Entradas=0,
Salidas=0,
rotacion_permitida=0,
rotacion_calculada=0,
valor_inventario=0,
valor_muerto=0,
anomes_primero=@ini

--Carga ultimo saldo

--encuentra el saldo de la ultima fecha, suma entradas de ese periodo y resta salidas

update rotacion

set 
saldo= isnull((select can_ini from inventarios where ano*100+mes=@sig
				and bodega=rotacion.bodega and codigo=rotacion.codigo ),0),
--Saldo= (select isnull(can_ini,0) from inventarios 
--			where bodega=rotacion.bodega and codigo=rotacion.codigo and periodo_ultimo=ano*100+mes)+
--			isnull((select SUM(ISNULL(-can_vta,0)+isnull(can_dev_vta,0)
--			                  +isnull(can_com,0)-isnull(can_dev_com,0)-isnull(can_otr_sal,0)
--			                  +isnull(can_otr_ent-can_tra,0)) from v_inv_doc_lin
--			where bodega=rotacion.bodega and codigo=rotacion.codigo and periodo_ultimo=ano*100+mes 
--			group by bodega,codigo,ano,mes),0),	
salidas=ISNULL((select SUM(isnull(can_vta,0)-isnull(can_dev_vta,0)+isnull(can_otr_sal,0))  from v_inv_doc_lin
		where bodega=rotacion.bodega and codigo=rotacion.codigo and (ano*100+mes>=@ini) and (ano*100+mes<=@fin) 
		group by bodega,codigo),0),
Entradas=ISNULL((select SUM(isnull(can_com,0)-isnull(can_dev_com,0)+isnull(can_otr_ent,0))  from v_inv_doc_lin
		where bodega=rotacion.bodega and codigo=rotacion.codigo and (ano*100+mes>=@ini) and (ano*100+mes<=@fin) 
		group by bodega,codigo),0),
grupo=(select grupo from referencias where rotacion.codigo=codigo),
valor_Inventario= isnull((select cos_ini from inventarios where ano*100+mes=@sig
							and bodega=rotacion.bodega and codigo=rotacion.codigo ),0),
anomes_primero=(SELECT MIN(ano*100+mes) FROM [analisisInventarios].[dbo].[inventarios]
                where bodega=rotacion.bodega and codigo=rotacion.codigo and (ano*100+mes>=@ini) and (ano*100+mes<=@fin )       
				group by [codigo],[bodega])
							


--valor_Inventario=(select isnull(cos_ini,0) from inventarios 
--			where bodega=rotacion.bodega and codigo=rotacion.codigo and periodo_ultimo=ano*100+mes)+
--					isnull((select SUM(ISNULL(-cos_vta,0)+isnull(cos_dev_vta,0)
--			        +isnull(cos_com,0)-isnull(cos_dev_com,0)-isnull(cos_otr_sal,0)
--			        +isnull(cos_otr_ent-cos_tra,0)) from v_inv_doc_lin
--			where bodega=rotacion.bodega and codigo=rotacion.codigo and periodo_ultimo=ano*100+mes 
--			group by bodega,codigo,ano,mes),0)			
---
update rotacion
set 
rotacion_permitida=(select rotacion from grupos where  rotacion.grupo=grupo),
rotacion_calculada=case when Salidas>0			then saldo*@np/salidas 
                        when anomes_primero=@ini then 9999 else 
									ROUND(@fin/100,0)*12+@fin-FLOOR(@fin)-
									ROUND(anomes_primero/100,0)*12+anomes_primero-FLOOR(anomes_primero)
					    end

update rotacion
set
valor_muerto=case when (rotacion_calculada-rotacion_permitida>0) and Saldo>0 then
							(saldo-rotacion_permitida*Salidas/@np)*valor_Inventario/saldo
								else 0 end	
								

update rotacion
set grupo=cambio_refs.grupo
from 
cambio_refs LEFT OUTER JOIN
rotacion ON cambio_refs.codigo = rotacion.codigo

--update rotacion
--set bodega=203
--where bodega=2 or bodega=3
delete from rotacion where grupo is null
delete from rotacion where not(bodega=203 or bodega=2 or bodega=3 or bodega=47 or bodega=52 or bodega=60 or bodega=74 or bodega=85 or bodega=88)	or
                           not (grupo='02' or grupo= '04'or grupo= '05' or grupo= '06' or grupo= '07' or grupo= '08' or grupo='10' or grupo='13' or grupo='14')  							



SELECT     bodega,  SUM(valor_Inventario) AS Inventario, SUM(valor_muerto) AS fuera_rotacion_lt_1, sum(case when rotacion_calculada=9999 then valor_inventario else 0 END) as sin_mvto_gt_1
FROM         rotacion
GROUP BY bodega
ORDER BY BODEGA
									
END	


--Saldo_cos

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[Saldo_cos]
(
    @codigo varchar(20),
    @bodega int,
    @ano int,
    @mes int
    
)
RETURNS numeric(18,2)
AS
BEGIN
declare @resultado numeric(18,2)

set @resultado=(SELECT 
      [cos_ini]+[cos_ent]-[cos_sal]
  FROM [analisisInventarios].[dbo].[inventarios]
  where codigo=@codigo and ano=@ano and mes=@mes and bodega=@bodega)
return @resultado
END


--calculo_indicador2

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create FUNCTION [dbo].[calculo_indicador2]
(	
	-- Add the parameters for the function here
	@anomes int,
	@obra   varchar(20),
	@tipo   varchar(3)

)
RETURNS 
@ind table
(	[fecha] [datetime] NULL,
	[anomes_ind] [int] NULL,
	[anomes] [int] NULL,
	[obra] [varchar](20) NULL,
	[ent_ind] [numeric](18, 2) NULL,
	[inv_tra_ini] [numeric](18, 2) NULL,
	[inv_tra_fin] [numeric](18, 2) NULL,
	[pc_ini] [numeric](18, 2) NULL,
	[pc_fin] [numeric](18, 2) NULL,
	[inv_res_ini] [numeric](18, 2) NULL,
	[inv_res_fin] [numeric](18, 2) NULL,
	[inv_l1a_ini] [numeric](18, 2) NULL,
	[inv_l1a_fin] [numeric](18, 2) NULL,
	[inv_g1a_ini] [numeric](18, 2) NULL,
	[inv_g1a_fin] [numeric](18, 2) NULL,
	[inv_ini] [numeric](18, 2) NULL,
	[inv_fin] [numeric](18, 2) NULL,
	tipo varchar(3) null
)

AS
BEGIN
declare @ano int, @mes int, @ano_ind int, @mes_ind int,@intervalo int, @fecha datetime
declare @am_ant int, @a_ind_a int, @m_ind_a int
declare @am_r1_ini int,@am_r1_fin int,@am_r2_ini int,@am_r2_fin int,@am_r3_ini int,@am_r3_fin int,@am_r4_ini int,@am_r4_fin int
--@am_r1_ini  añomes rango 1 inicial = @ano*100+@mes-@intervalo+1
--@am_r1_fin  añomes rango 1 final = @ano*100+@mes

declare @ent_ind numeric(18,2)
declare @inv_tra_ini numeric(18,2), @inv_res_ini  numeric(18,2),@inv_l1a_ini  numeric(18,2),@inv_g1a_ini  numeric(18,2), @inv_ini   numeric(18,2)
declare @inv_tra_fin numeric(18,2), @inv_res_fin  numeric(18,2),@inv_l1a_fin  numeric(18,2),@inv_g1a_fin  numeric(18,2), @inv_fin  numeric(18,2)
declare @a_ant int, @m_ant int
declare @gru table(g varchar(5),d varchar(50))
declare @bod table (o varchar(20), b int)

insert into @bod select * from dbo.obras()
IF @tipo='MEC'
	insert into @gru select * from dbo.gr_mecanica()
else
	insert into @gru select * from dbo.gr_civil()
declare @tmp varchar(20)
set @intervalo=3
set @ano=cast(@anomes/100 as int)
set @mes=@anomes-@ano*100
set @fecha=(SELECT CAST(CAST(@ano AS VARCHAR(4)) + RIGHT('0' + CAST(@mes AS VARCHAR(2)), 2) + '01' AS DATETIME))
--select @fecha
set @am_ant=(SELECT [dbo].[anomes_add_mes] (-1,@anomes))
set @a_ant=cast(@am_ant/100 as int)
set @m_ant=@am_ant-@a_ant*100
set @am_r1_ini=(SELECT [dbo].[anomes_add_mes] (-@intervalo+1,@anomes))
set @am_r1_fin=@anomes

set @am_r2_ini=(SELECT [dbo].[anomes_add_mes] (-@intervalo,@anomes))
set @am_r2_fin=(SELECT [dbo].[anomes_add_mes] (-@intervalo,@anomes))
set @am_r3_ini=(SELECT [dbo].[anomes_add_mes] (-12,@anomes))
set @am_r3_fin=(SELECT [dbo].[anomes_add_mes] (-@intervalo-1,@anomes))

set @am_r4_ini=(SELECT [dbo].[anomes_add_mes] (-100,@anomes))
set @am_r4_fin=(SELECT [dbo].[anomes_add_mes] (-13,@anomes))

--Inventario resiente
select @inv_res_ini=sum(costo_stock) from v_ref_total vrf
where (ano=@a_ant and mes=@m_ant)
and (dbo.ult_ent_vrt(vrf.codigo,vrf.bodega,@am_r1_fin) between @am_r1_ini and @am_r1_fin) and
grupo in (select g from @gru) and bodega in (select b from @bod where o=@obra)

select @inv_res_fin=sum(costo_stock) from v_ref_total vrf
where (ano=@ano and mes=@mes) 
and (dbo.ult_ent_vrt(vrf.codigo,vrf.bodega,@ano*100+@mes) between @am_r1_ini and @am_r1_fin) and
grupo in (select g from @gru) and bodega in (select b from @bod where o=@obra)

--Inventario en transision de resiente a obsoleto
select @inv_tra_ini=sum(costo_stock) from v_ref_total vrf
where (ano=@a_ant and mes=@m_ant) 
and (dbo.ult_ent_vrt(vrf.codigo,vrf.bodega,@am_r1_fin)=@am_r2_ini) and
grupo in (select g from @gru) and bodega in (select b from @bod where o=@obra)

select @inv_tra_fin=sum(costo_stock) from v_ref_total vrf
where (ano=@ano and mes=@mes) 
and (dbo.ult_ent_vrt(vrf.codigo,vrf.bodega,@ano*100+@mes)=@am_r2_ini) and
grupo in (select g from @gru) and bodega in (select b from @bod where o=@obra)

--Inventario obsoleto de menos de un año y mas de 3 meses
select @inv_l1a_ini=sum(costo_stock) from v_ref_total vrf
where (ano=@a_ant and mes=@m_ant)
and (dbo.ult_ent_vrt(vrf.codigo,vrf.bodega,@am_r1_fin) between @am_r3_ini and @am_r3_fin) and
grupo in (select g from @gru) and bodega in (select b from @bod where o=@obra)

select @inv_l1a_fin=sum(costo_stock) from v_ref_total vrf
where (ano=@ano and mes=@mes) 
and (dbo.ult_ent_vrt(vrf.codigo,vrf.bodega,@ano*100+@mes) between @am_r3_ini and @am_r3_fin) and
grupo in (select g from @gru) and bodega in (select b from @bod where o=@obra)

--Inventario obsoleto de mas de un año 
select @inv_g1a_ini=sum(costo_stock) from v_ref_total vrf
where (ano=@a_ant and mes=@m_ant)
and (dbo.ult_ent_vrt(vrf.codigo,vrf.bodega,@am_r1_fin)<=@am_r4_fin or dbo.ult_ent_vrt(vrf.codigo,vrf.bodega,@am_r1_fin) is null) 
and grupo in (select g from @gru) and bodega in (select b from @bod where o=@obra)

select @inv_g1a_fin=sum(costo_stock) from v_ref_total vrf
where (ano=@ano and mes=@mes) 
and (dbo.ult_ent_vrt(vrf.codigo,vrf.bodega,@am_r1_fin)<=@am_r4_fin or dbo.ult_ent_vrt(vrf.codigo,vrf.bodega,@am_r1_fin) is null) and
grupo in (select g from @gru) and bodega in (select b from @bod where o=@obra)

--Total inventario
select @inv_ini=sum(costo_stock) from v_ref_total vrf
where (ano=@a_ant and mes=@m_ant)
 and grupo in (select g from @gru) and bodega in (select b from @bod where o=@obra)

select @inv_fin=sum(costo_stock) from v_ref_total vrf
where ano*100+mes=@ano*100+@mes and 
grupo in (select g from @gru) and bodega in (select b from @bod where o=@obra)

select  @ent_ind=sum(cos_ent) from v_ref_total where 
 [dbo].[ult_ent_vrt] (codigo,bodega,@am_r2_ini)=@am_r2_ini  and
ano*100+mes=@am_r2_ini and
grupo in (select g from @gru) and bodega in (select b from @bod where o=@obra)

--select  grupo, codigo, descripcion , cos_ent from v_ref_total where 
-- [dbo].[ult_ent_vrt] (codigo,bodega,@am_r2_ini)=@am_r2_ini  and
--ano*100+mes=@am_r2_ini and
--grupo in (select g from @gru) and bodega in (select b from @bod where o=@obra)
--order by grupo

--select  grupo, codigo, descripcion , Costo_Stock from v_ref_total vrf
--where ano*100+mes=@ano*100+@mes and (dbo.ult_ent_vrt(vrf.codigo,vrf.bodega,@ano*100+@mes)=@am_r2_ini) and
--grupo in (select g from @gru) and bodega in (select b from @bod where o=@obra)



--select @inv_res_ini,@inv_res_fin,@inv_tra_ini,@inv_tra_fin,@inv_l1a_ini,@inv_l1a_fin,@inv_g1a_ini,@inv_g1a_fin,@inv_ini,@inv_fin


INSERT INTO @ind
           ([fecha]
           ,[anomes_ind]
           ,[anomes]
           ,[obra]
           ,[ent_ind]
           ,[inv_tra_ini]
           ,[inv_tra_fin]
           ,[pc_ini]
           ,[pc_fin]
           ,[inv_res_ini]
           ,[inv_res_fin]
           ,[inv_l1a_ini]
           ,[inv_l1a_fin]
           ,[inv_g1a_ini]
           ,[inv_g1a_fin]
           ,[inv_ini]
           ,[inv_fin]
		   ,tipo)
     VALUES
           (getdate(),@am_r2_ini,@anomes,@obra,isnull(@ent_ind,0),isnull(@inv_tra_ini,0),
		              isnull(@inv_tra_fin,0), isnull(@inv_tra_ini/@ent_ind,0),
		              isnull(@inv_tra_fin/@ent_ind,0), isnull(@inv_res_ini,0), 
					  isnull(@inv_res_fin,0), isnull(@inv_l1a_ini,0), isnull(@inv_l1a_fin,0), isnull(@inv_g1a_ini,0),
					  isnull(@inv_g1a_fin,0), isnull(@inv_ini,0),isnull( @inv_fin,0),@tipo)
	
	RETURN 
END



--stock_antiguo_vrt

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================

--La diferencia de esta funcion con ultima_entrada es que no considera los inventarios mayores a una fecha,
--para poder evaluar periodos distintos al actual. Si por ejemplo la ultima entrada fue 2014 06, hay salidas en 2014 12, y se 
--quiere evaluar en 2014 10, debe devolver 2014 6 y no 2014 12  

CREATE FUNCTION [dbo].[stock_antiguo_vrt]
(
	@codigo varchar(20),
	@bodega int,
	@anomes int
)
RETURNS numeric(18,2)
AS
BEGIN
	-- Declare the return variable here
	--Se plantea una mejora: Para no tener que multiplicar y poder utilizar los indices, se separa año de mes
	--se utiliza las siguientes formulas 
	--am2>=am1	(a2>a1 or (a2=a1 and m2>=m1))
	--am2=am1	a2=a1 and m2=m1
	--am2<=am1	(a2<a1 or (a2=a1 and m2<=m1))

	DECLARE @ResultVar int
	--DECLARE @ano int, @mes int
	--set @ano=cast(@anomes/100 as int)
	--set @mes=@anomes-@ano*100
	--declare @anomes int
	--set @anomes=@ano*100+@mes
	set @ResultVar=(SELECT  costo_stock-cos_ent
					FROM [dbo].[v_ref_total]
					where codigo=@codigo and bodega=@bodega and (can_ent>0) and Costo_Stock>cos_ent
					      and ano*100+mes=@anomes
					  )
	RETURN @ResultVar

END



--cos_ent_vrt

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================

--La diferencia de esta funcion con ultima_entrada es que no considera los inventarios mayores a una fecha,
--para poder evaluar periodos distintos al actual. Si por ejemplo la ultima entrada fue 2014 06, hay salidas en 2014 12, y se 
--quiere evaluar en 2014 10, debe devolver 2014 6 y no 2014 12  

create FUNCTION [dbo].[cos_ent_vrt]
(
	@codigo varchar(20),
	@bodega int,
	@anomes int
)
RETURNS numeric(18,2)
AS
BEGIN
	-- Declare the return variable here
	--Se plantea una mejora: Para no tener que multiplicar y poder utilizar los indices, se separa año de mes
	--se utiliza las siguientes formulas 
	--am2>=am1	(a2>a1 or (a2=a1 and m2>=m1))
	--am2=am1	a2=a1 and m2=m1
	--am2<=am1	(a2<a1 or (a2=a1 and m2<=m1))

	DECLARE @ResultVar int
	--DECLARE @ano int, @mes int
	--set @ano=cast(@anomes/100 as int)
	--set @mes=@anomes-@ano*100
	--declare @anomes int
	--set @anomes=@ano*100+@mes
	set @ResultVar=(SELECT top 1 cos_ent
					FROM [dbo].[v_ref_total]
					where codigo=@codigo and bodega=@bodega and (can_ent>0)
					      and ano*100+mes<=@anomes
						  --and (ano<@ano or (ano=@ano and mes<=@mes))
					order by ano*100+mes desc
					  --order by ano desc, mes desc
					  )
	RETURN @ResultVar

END



--ultima_entrada

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION ultima_entrada
(
	@codigo varchar(20),
	@bodega int
)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @ResultVar int
	set @ResultVar=(SELECT top 1 ano*100+mes
					FROM [dbo].[inventarios]
					where codigo=@codigo and bodega=@bodega and (can_ent>0)
					order by ano*100+mes desc)
	RETURN @ResultVar

END



--analisis_x_referencias



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[analisis_x_referencias]
	-- Add the parameters for the stored procedure here
	@anoini int,
	@mesini int,
	@anofin int,
	@mesfin int
AS
BEGIN
--declare @anoini as int, @mesini as int, @anofin as int, @mesfin as int
declare @ini as VARCHAR(6), @fin as VARCHAR(6), @anosig as int, @messig as int, @sig as int
declare @np as int
declare @cmd nvarchar(4000)
set @ini=cast((@anoini*100+@mesini) as varchar(6))
set @fin=cast((@anofin*100+@mesfin) as varchar(6))
--Crea archivo de analisisxreferencias
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[analisisxReferencias]') AND type in (N'U'))
DROP TABLE [dbo].[analisisxReferencias]
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tmp]') AND type in (N'U'))
DROP TABLE [dbo].[tmp]
CREATE TABLE [dbo].[analisisxReferencias](
	bodega int NULL,
	grupo varchar(5) null,
	[codigo] [varchar](20) NULL,
	[descripcion] [varchar](80) NULL,
	[saldo_actual] [numeric](18, 2) NULL,
	[saldo_anterior] [numeric](18, 2) NULL,
	[relacion] [numeric](18, 2) NULL,
	[tipo] [varchar](30) NULL
) ON [PRIMARY]

CREATE TABLE [dbo].[tmp](
	bodega int NULL,
	[codigo] [varchar](20) NULL,
	[suma_salidas] [numeric](18, 2) NULL
) ON [PRIMARY]


--Si la suma de las salidas es cero, garantiza que no hubo movimiento




set @cmd= 'insert into analisisxReferencias(bodega,grupo,codigo,descripcion,saldo_actual,saldo_anterior)
		   select bodega,grupo,codigo, descripcion, [' + @fin +'] as saldo_actual,[' + @ini + '] 
		   as saldo_anterior
		   from
		   (SELECT     inventarios.cos_ini, inventarios.bodega, referencias_actualizada.grupo, inventarios.codigo, referencias_actualizada.descripcion, 
                      inventarios.ano * 100 + inventarios.mes AS anomes
			FROM         inventarios LEFT OUTER JOIN
                      referencias_actualizada ON inventarios.codigo = referencias_actualizada.codigo) p
			Pivot
			(sum(cos_ini) for anomes in ([' + @fin +'],[' + @ini + '])) as pvt
			where not(([' + @fin +'] is null) and ([' + @ini + '] is null)) 
			order by bodega,grupo,codigo '

--		   SELECT   inventarios.bodega, referencias_actualizada.grupo, inventarios.codigo, 
--                    inventarios.cos_ini, referencias_actualizada.descripcion
--           FROM     inventarios LEFT OUTER JOIN
--                    referencias_actualizada ON inventarios.codigo = referencias_actualizada.codigo  
--           where    ano=@anofin and mes=@mesfin  
--		            and not (referencias_actualizada.grupo is null)
--           order by bodega,grupo,codigo 

execute (@cmd)

update analisisxReferencias
set
relacion=0,
tipo=''

--update analisisxReferencias
--set
--	saldo_anterior=inventarios.cos_ini
--from
--	inventarios 
--	where    ano=@anoini and mes=@mesini 
--	     and inventarios.bodega=analisisxReferencias.bodega
--		 and inventarios.codigo=analisisxReferencias.codigo
	           

UPDATE analisisxReferencias
 set
 saldo_anterior=0
 where saldo_anterior is null
 
 UPDATE analisisxReferencias
 set
 saldo_actual=0
 where saldo_actual is null
 
delete from analisisxReferencias where (saldo_actual=0 and saldo_anterior=0) and 
										not (saldo_actual is null  and saldo_anterior is null)	

update analisisxReferencias
set
relacion= case when saldo_anterior=0 then 9999 else saldo_actual/saldo_anterior end

update analisisxReferencias
set
tipo= case when relacion=9999 then '3-Nuevo'
		   when relacion=1 then '1-Sin Movimiento'
		   when relacion>1 then '2-Aumento Inventario'
		   else '0-Disminuyo Inventario'
	  end
		 
		 
		 
		 
		   
--update rotacion
--set bodega=203
--where bodega=2 or bodega=3
delete from analisisxReferencias where grupo is null
delete from analisisxReferencias where not(bodega=203 or bodega=2 or bodega=3 or bodega=47 or bodega=52 or bodega=60 or bodega=74 or bodega=85 or bodega=88 or bodega=1100 or bodega=96 or bodega=91)	or
                           not (grupo='01' or grupo='02' or grupo= '04'or grupo= '05' or grupo= '06' or grupo= '07' or grupo= '08' or grupo='10' or grupo='11' or grupo='12' or grupo='13' or grupo='14' or grupo='15'or grupo='16' or grupo='27')  							



--S-ELECT     bodega,  SUM(valor_Inventario) AS Inventario, SUM(valor_muerto) AS fuera_rotacion_lt_1, sum(case when rotacion_calculada=9999 then valor_inventario else 0 END) as sin_mvto_gt_1
--FROM         rotacion
--GROUP BY bodega
--ORDER BY BODEGA

insert into tmp (bodega,codigo,suma_salidas) 
SELECT       inventarios.bodega,  inventarios.codigo, SUM(inventarios.cos_sal) AS suma_salidas
FROM         inventarios RIGHT OUTER JOIN
                      analisisxReferencias ON inventarios.bodega = analisisxReferencias.bodega AND inventarios.codigo = analisisxReferencias.codigo
WHERE     (ano>= @anoini) AND (mes >= @mesini) AND (ano <=@anofin) AND (mes <= @mesfin) AND (inventarios.mes <= 2) AND (analisisxReferencias.relacion = 1)
GROUP BY inventarios.codigo, inventarios.bodega
HAVING      (SUM(inventarios.cos_sal) <> 0)
 


SELECT     analisisxReferencias.bodega, analisisxReferencias.grupo, grupos.descripcion, 
			SUM(analisisxReferencias.saldo_actual) AS Saldo_Actual, 
            SUM(analisisxReferencias.saldo_anterior) AS Saldo_Anterior, analisisxReferencias.tipo, COUNT(*) as count
FROM         analisisxReferencias LEFT OUTER JOIN
                      grupos ON analisisxReferencias.grupo = grupos.grupo
GROUP BY analisisxReferencias.bodega, analisisxReferencias.grupo, analisisxReferencias.tipo, grupos.descripcion
ORDER BY analisisxReferencias.bodega, analisisxReferencias.grupo, analisisxReferencias.tipo									
END	




--ultima_compra

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================

--La diferencia de esta funcion con ultima_entrada es que no considera los inventarios mayores a una fecha,
--para poder evaluar periodos distintos al actual. Si por ejemplo la ultima entrada fue 2014 06, hay salidas en 2014 12, y se 
--quiere evaluar en 2014 10, debe devolver 2014 6 y no 2014 12  

create FUNCTION [dbo].[ultima_compra]
(
	@codigo varchar(20),
	@centro int,
	@anomes int
)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	--Se plantea una mejora: Para no tener que multiplicar y poder utilizar los indices, se separa año de mes
	--se utiliza las siguientes formulas 
	--am2>=am1	(a2>a1 or (a2=a1 and m2>=m1))
	--am2=am1	a2=a1 and m2=m1
	--am2<=am1	(a2<a1 or (a2=a1 and m2<=m1))

	DECLARE @ResultVar int
	--DECLARE @ano int, @mes int
	--set @ano=cast(@anomes/100 as int)
	--set @mes=@anomes-@ano*100
	--declare @anomes int
	--set @anomes=@ano*100+@mes
	set @ResultVar=(SELECT top 1 ano*100+mes
					FROM [dbo].[compras_inventarios]
					where codigo=@codigo and centro=@centro and (compras+Entrada_Traslado>0)
					      and ano*100+mes<=@anomes
						  --and (ano<@ano or (ano=@ano and mes<=@mes))
					order by ano*100+mes desc
					  --order by ano desc, mes desc
					  )
	RETURN @ResultVar

END



--traslados_posibles

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[traslados_posibles]
(
	@bodega smallint,
	@pedido int
)
RETURNS
	@tbl table (	cod varchar(20),
					dsc varchar(200),
					cnt decimal(18,6),
					vlr decimal(18,6)) 

AS
BEGIN

declare @cod varchar(20), @cnt decimal(18,6), @cnt_dis decimal(18,6), @pre as money
declare @ano int, @mes int, @serial int, @anomes_min int, @dsc varchar(200)

set @ano=year(getdate())
set @mes=month(getdate())
set @serial=@ano*12+@mes
set @anomes_min=cast((@serial-2)/12 as int)*100+(@serial-2) % 12

DECLARE skt_cursor CURSOR FOR
	select codigo, sum(cantidad) as cantidad
	from dbo.lin_ped_tmp where bodega=@bodega and numero=@pedido
	group by codigo order by codigo
	OPEN skt_cursor;


-- Perform the first fetch.
FETCH NEXT FROM skt_cursor into @cod,@cnt
-- Check @@FETCH_STATUS to see if there are any more rows to fetch.
WHILE @@FETCH_STATUS = 0
	BEGIN
   -- This is executed as long as the previous fetch succeeds.
	    
		select @cnt_dis=sum(can) from dbo.optimizacion(@cod,@ano,@mes)
		where can/(sxm+0.0001)>2 and anomes<@anomes_min
		select top 1 @pre=case 
							when valor_unitario=0 then costo_unitario 
							else valor_unitario 
						   end,
				     @dsc=descripcion 
				from dbo.referencias where codigo=@cod
		if  (@cnt_dis<@cnt)
			begin
				set @cnt=@cnt_dis
			end
		if (@cnt_dis>0)
		begin
		 insert into @tbl (cod,dsc,cnt,vlr) values (@cod,@dsc,@cnt,@pre)
		end
		      FETCH NEXT FROM skt_cursor into @cod,@cnt		
	END


close skt_cursor
DEALLOCATE  skt_cursor
	
RETURN 
END



--ahorro_traslados

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[ahorro_traslados]
(
	@bodega smallint,-- Add the parameters for the function here
	@pedido int
)
RETURNS money
AS
BEGIN
	-- Declare the return variable here
	DECLARE @ResultVar  money
	SELECT @ResultVar=isnull(sum(cnt*vlr),0) FROM [dbo].[traslados_posibles] (@bodega,@pedido)


	-- Return the result of the function
	RETURN @ResultVar

END



--minimo

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION minimo
(
  @a decimal(18,6),
  @b decimal(18,6)
)
RETURNS decimal(18,6)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @ResultVar decimal(18,6)

	if (@a>@b)
		set @ResultVar=@b
	else
		set @ResultVar=@a
		
	return 	@ResultVar	


END



--maximo

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[maximo]
(
  @a decimal(18,6),
  @b decimal(18,6)
)
RETURNS decimal(18,6)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @ResultVar decimal(18,6)

	if (@a<@b)
		set @ResultVar=@b
	else
		set @ResultVar=@a
		
	return 	@ResultVar	


END



--traslados_str

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create FUNCTION [dbo].[traslados_str]
 
(
			@ano int,
			@mes int,
			@codigo varchar(20),
			@bod_des int
)
RETURNS varchar(200)
AS
BEGIN
	-- Declare the return variable here
	declare  @bod_tra int, @bod_fue int,@cos_ent numeric(18,2), @bod_ini int
	declare @tipo_ent varchar(15), @num_ent int
	declare @tipo_tra varchar(15), @num_tra int
	declare @resultado as nchar(200)
	--busca el tipo, numero y valor del movimiento por el que entró a la bodega destino
	SELECT top 1 @tipo_ent=[tipo]
      ,@num_ent=[numero]
	  ,@cos_ent=cos_otr_ent
	FROM [analisisInventarios].[dbo].[v_inv_doc_lin]
	where codigo=@codigo and bodega=@bod_des and ano=@ano and mes=@mes and cos_otr_ent>0
	--Busca la bodega intermedia de este traslado
	select @bod_tra=bodega
    FROM [analisisInventarios].[dbo].[v_inv_doc_lin]
    where tipo=@tipo_ent and numero=@num_ent and bodega<>@bod_des and codigo=@codigo and cos_tra=@cos_ent


	--Se busca la bodega desde donde se traslado a la bodega de traslado
	select @tipo_tra=tipo,@num_tra=numero
	FROM [analisisInventarios].[dbo].[v_inv_doc_lin]
	where bodega=@bod_tra and codigo=@codigo and tipo<>@tipo_ent and cos_otr_ent=@cos_ent 
	--
	select @bod_fue=bodega 
	FROM [analisisInventarios].[dbo].[v_inv_doc_lin]
	where bodega<>@bod_tra and codigo=@codigo and tipo<>@tipo_ent and numero=@num_tra

	set @resultado=cast(@bod_fue as varchar(5))+'->'+  @tipo_tra+' '+cast(@num_tra as varchar(5))+' ->'
	                            +cast(@bod_tra as varchar(10))+' ->' 
	                            + @tipo_ent + ' ' + cast(@num_ent as varchar(5))+'->'
								+ cast(@bod_des as varchar(5))

	-- Return the result of the function
	RETURN @resultado

END



--traslados

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[traslados]
(
			@ano int,
			@mes int,
			@codigo varchar(20),
			@bod_des int
)
RETURNS 
@tbl table ( tipo varchar(15),bod_fue int,bod_des int, num int,costo int)

AS
BEGIN
declare @costo numeric(18,6), @i int, @bod_fue int, @num int, @tipo varchar(15)
declare  @bod_ini int

set @bod_ini=@bod_des



--encuentra moviento de entrada tipo y numero
  	SELECT
	  @costo=cos_otr_ent+cos_com
	FROM [analisisInventarios].[dbo].[v_inv_doc_lin]
	where codigo=@codigo and bodega=@bod_des and ano=@ano and mes=@mes and cos_otr_ent+cos_com>0

	set @i=0
	set @bod_fue=@bod_des
	set @bod_des=0
	While (@bod_fue<>@bod_des and @i<20)
	begin
		--primer ciclo
		set @bod_des=@bod_fue
		SELECT @tipo=[tipo],@num=[numero]
		FROM [analisisInventarios].[dbo].[v_inv_doc_lin]
		where codigo=@codigo and bodega=@bod_des and ano=@ano and mes=@mes and cos_otr_ent+cos_com=@costo 
		--SELECT [tipo],[numero],cos_otr_ent
		--FROM [analisisInventarios].[dbo].[v_inv_doc_lin]
		--where codigo=@codigo and bodega=@bod_des and ano=@ano and mes=@mes and cos_otr_ent=@costo 
		--encuentra bodega fuente

		select @bod_fue=bodega
		FROM [analisisInventarios].[dbo].[v_inv_doc_lin]
		where tipo=@tipo and numero=@num and bodega<>@bod_des and codigo=@codigo and cos_tra=@costo

		
		if (@bod_des<>@bod_fue)
		begin
			insert into @tbl (tipo,bod_fue,bod_des,num,costo) values (@tipo,@bod_fue,@bod_des,@num,@costo)

		end
		--inserta registro de moviento de las dos bodegas
		if ((select count(*)
				FROM [analisisInventarios].[dbo].[v_inv_doc_lin]
				where tipo=@tipo and numero=@num and bodega<>@bod_des and codigo=@codigo and cos_tra=@costo)=0)
			begin
			 insert into @tbl (tipo,bod_des,num,costo) values (@tipo,@bod_des,@num,@costo)
			 --set @i=10
		end
		if (@bod_fue=@bod_ini)
			begin
				set @i=20
			end

		set @i=@i+1
		
    END	
	RETURN 
END



--traslados1

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create FUNCTION [dbo].[traslados1]
(
			@ano int,
			@mes int,
			@codigo varchar(20),
			@bod_des int
)
RETURNS 
@tbl table ( tipo varchar(15),bod_fue int,bod_des int, num int,costo int)

AS
BEGIN
declare @costo numeric(18,6), @i int, @bod_fue int, @num int, @tipo varchar(15)






--encuentra moviento de entrada tipo y numero
  	SELECT
	  @costo=cos_otr_ent
	FROM [analisisInventarios].[dbo].[v_inv_doc_lin]
	where codigo=@codigo and bodega=@bod_des and ano=@ano and mes=@mes and cos_otr_ent>0
	set @i=0
	set @bod_fue=@bod_des
	set @bod_des=0
	While (@bod_fue<>@bod_des and @i<5)
	begin
		--primer ciclo
		set @bod_des=@bod_fue
		SELECT @tipo=[tipo],@num=[numero]
		FROM [analisisInventarios].[dbo].[v_inv_doc_lin]
		where codigo=@codigo and bodega=@bod_des and ano=@ano and mes=@mes and cos_otr_ent=@costo 
		--SELECT [tipo],[numero],cos_otr_ent
		--FROM [analisisInventarios].[dbo].[v_inv_doc_lin]
		--where codigo=@codigo and bodega=@bod_des and ano=@ano and mes=@mes and cos_otr_ent=@costo 
		--encuentra bodega fuente

		select @bod_fue=bodega
		FROM [analisisInventarios].[dbo].[v_inv_doc_lin]
		where tipo=@tipo and numero=@num and bodega<>@bod_des and codigo=@codigo and cos_tra=@costo

		--inserta registro de moviento de las dos bodegas
		if (@bod_des<>@bod_fue)
		begin
			insert into @tbl (tipo,bod_fue,bod_des,num,costo) values (@tipo,@bod_fue,@bod_des,@num,@costo)
		end
		set @i=@i+1
		
    END	
	RETURN 
END



--indicador_naslly

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[indicador_naslly] 
(
	@anomes int,
	@centro int,
	@tipo varchar(3)

)
RETURNS 
@stk_sal TABLE 
(
	ano smallint,
	mes smallint,
	codigo varchar(20),
	centro int,
	tipo  varchar(3),
	costo_promedio decimal(19,3),
	stk0 decimal(18,3),
	sal0 decimal(18,3),
	stk1 decimal(18,3),
	sal1 decimal(18,3),
	stk2 decimal(18,3),
	sal2 decimal(18,3),
	stk3 decimal(18,3),
	sal3 decimal(18,3)
)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
	declare @gru table(g varchar(5),d varchar(50))
declare @am0 int, @am1 int, @am2 int, @am3 int

--
if (@tipo='MEC')
	insert into @gru
	select *  from dbo.gr_mecanica() 
else
	begin
		set @tipo='CIV'
		insert into @gru
		select *  from dbo.gr_civil() 
	end
	 
set @am0=@anomes
set @am1 = dbo.anomes_add_mes(1,@am0)
set @am2 = dbo.anomes_add_mes(2,@am0)
set @am3 = dbo.anomes_add_mes(3,@am0)

--Inserta todos los registros de compras y el primer mes.

insert into @stk_sal
--SELECT      m0.ano, m0.mes, m0.codigo, m0.bodega, m0.centro, @tipo, m0.costo_promedio,
--usar el primero cuando se organice x bodega
SELECT      ano, m0.mes, m0.codigo, m0.centro, @tipo, m0.costo_promedio,
			--stock=compras+traslados
			(m0.Compras + m0.Entrada_Traslado) as stk0,
			--salidas_totales=salidas+devoluciones+salidas_traslados
			--salidas=min((salidas_Totales,stock))
			dbo.minimo((m0.Salidas+m0.Dev_compra+m0.Salida_Traslado),
						(m0.Compras + m0.Entrada_Traslado)) as Sal0,
						Cast( 0.0 as decimal(18,3)) as Stk1,
						Cast( 0.0 as decimal(18,3)) as Sal1,
						Cast( 0.0 as decimal(18,3)) as Stk2,
						Cast( 0.0 as decimal(18,3)) as Sal2,
						Cast( 0.0 as decimal(18,3)) as Stk3,
						Cast( 0.0 as decimal(18,3)) as Sal3
FROM            compras_inventarios AS m0 
WHERE        (m0.ano*100+m0.mes=@am0) AND (m0.Compras > 0) AND (m0.centro = @centro) and m0.Familia in (select g from @gru)

update @stk_sal
set stk1=stk0-sal0,
	stk2=stk0-sal0,
	stk3=stk0-sal0

--Inserta el segundo mes
update @stk_sal
Set         --stock=max(0,Stock_antrior-Salidas_anteriores) o sea que si da negativo queda en 0
			Stk1=dbo.maximo(0,m0.stk0-m0.Sal0),
			--salidas_totales=m1.Salidas-m1.Dev_compra-m1.Salida_Traslado
			--salidas=min((stk1), salidas_totales)
			Sal1=dbo.minimo(dbo.maximo(0,dbo.maximo(0,m0.stk0-m0.Sal0)),
						(m1.Salidas+m1.Dev_compra+m1.Salida_Traslado))
			from @stk_sal as m0
left outer join
                compras_inventarios AS m1 ON m0.codigo = m1.codigo AND m0.centro = m1.centro  --and m0.bod=m1.bodega--and 
where m1.ano*100+m1.mes=@am1

update @stk_sal
set stk2=stk1-sal1,
	stk3=stk1-sal1

--Inserta el tercer mes
update @stk_sal
Set     
			Stk2=dbo.maximo(0,m0.stk1-m0.Sal1),
			--               stk_ini_1-  
			Sal2=dbo.minimo(dbo.maximo(0,dbo.maximo(0,m0.stk1-m0.Sal1)),
						(m1.Salidas+m1.Dev_compra+m1.Salida_Traslado))
			from @stk_sal as m0
left outer join
            compras_inventarios AS m1 ON m0.codigo = m1.codigo AND m0.centro = m1.centro   --and m0.bod=m1.bodega --and m1.ano*100+m1.mes=@am2

where m1.ano*100+m1.mes=@am2
--Inserta el cuarto mes

update @stk_sal
Set stk3=stk2-sal2

update @stk_sal
Set     
			Stk3=dbo.maximo(0,m0.stk2-m0.Sal2),
			--               stk_ini_1-  
			Sal3=dbo.minimo(dbo.maximo(0,dbo.maximo(0,m0.stk2-m0.Sal2)),
						(m1.Salidas+m1.Dev_compra+m1.Salida_Traslado))
			from @stk_sal as m0
left outer join
            compras_inventarios AS m1 ON m0.codigo = m1.codigo AND m0.centro = m1.centro   --and m0.bod=m1.bodega --and m1.ano*100+m1.mes=@am3
where m1.ano*100+m1.mes=@am3
	RETURN 
END



--indicador_naslly_ano

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[indicador_naslly_ano]
(
	-- Add the parameters for the function here
	@ano int,
	@centro int,
	@tipo varchar(3)
)
RETURNS 
@tbl TABLE 
(
	ano int,
	mes int,
	pm0 decimal(18,6),
	pm1 decimal(18,6),
	pm2 decimal(18,6),
	pm3 decimal(18,6),
	pm4 decimal(18,6),
	com decimal(18,6),
	me0 decimal(18,6),
	me1 decimal(18,6),
	me2 decimal(18,6),
	me3 decimal(18,6),
	me4 decimal(18,6)
)
AS
BEGIN
	declare @um int,@i int, @anomes int
	-- Fill the table variable with the rows for your result set
	-- Averigua cual es el maximo mes
	set @um = (SELECT max(mes) FROM [dbo].[compras_inventarios] where ano=@ano)
	set @i=1
	while @i<=@um
		begin
			set @anomes=@ano*100+@i	

			insert into @tbl (ano,mes,pm0,pm1,pm2,pm3,pm4,com,me0,me1,me2,me3,me4)
			SELECT @ano,@i,
				sum(sal0*costo_promedio)/(sum(stk0*costo_promedio)+0.001),
				sum(sal1*costo_promedio)/(sum(stk0*costo_promedio) +0.001),
				sum(sal2*costo_promedio)/(sum(stk0*costo_promedio) +0.001),
				sum(sal3*costo_promedio)/(sum(stk0*costo_promedio) +0.001),
				sum((stk3-sal3)*costo_promedio)/(sum(stk0*costo_promedio)+0.001),
				sum(stk0*costo_promedio),
				sum(sal0*costo_promedio),
				sum(sal1*costo_promedio),
				sum(sal2*costo_promedio),
				sum(sal3*costo_promedio),
				sum((stk3-sal3)*costo_promedio)
			FROM [dbo].[indicador_naslly] (@anomes,@centro,@tipo)
			set @i=@i+1
		end



	-- Hace el ciclo y recoge los datos, va agregando a 

	
	RETURN 
END



--inv_sin_movimiento

-- =============================================
-- Author:		ramiro villegas
-- Create date: 27-02-2015
-- Description:	Calcula inventario obsoleto vs Entradas
-- =============================================

-- parametros: ano_eval: es el año en donde se calcula lo comprado que no se ha movido
--             mes_eval: es el año en donde se calcula lo comprado que no se ha movido 
--             ano: ano de la fecha a evaluar
--             mes: mes de la fecha a evaluar, inicialmente es 3 meses antes de fecha_eval
--             obra: Es el grupo de bodegas a evaluar, se consideran las bodegas de transito.
-- resultado:  El resultado es una tabla con los siguientes datos:
--             grupo: Es el grupo que se ananliza
--             entradas: entradas (+-compras) de ese grupo en ano, mes
--			   sinmover: es el total de entradas de ese mes que no se han movido en fecha_eval
--             se debe incluir un grupo con valor totalizado


CREATE FUNCTION [dbo].[inv_sin_movimiento] 
(
	-- Add the parameters for the function here
	@ano_eval int, 
	@mes_eval  int,
	@ano int, 
	@mes  int, 
	@obra  varchar(20)

)
RETURNS 
@res table(	ano_eval  int,
			mes_eval  int, 
			ano  int, 
			mes  int, 
			grupo  varchar(5),
			entradas numeric(18,4), 
			sinmover numeric(18,4))
AS
BEGIN
	declare  @anomes as int

	declare @gru table(g varchar(5),d varchar(50))
	declare @bod table (o varchar(20), b int)
	set @anomes=@ano*100+@mes
		--grupos seleccionados
	insert into @gru (g,d) values('02', 'REPUESTOS DE MAQUINARIA Y EQUIPO')
	insert into @gru (g,d) values('04', 'LUBRICANTES Y ADITIVOS PARA EQUIPOS')
	insert into @gru (g,d) values('05', 'FILTROS')
	insert into @gru (g,d) values('06', 'RODAJE')
	insert into @gru (g,d) values('07', 'ELEMENTOS DE DESGASTE')
	insert into @gru (g,d) values('08', 'SOLDADURA')
	insert into @gru (g,d) values('09', 'COMPONENTES STAND BY')
	insert into @gru (g,d) values('13', 'MATERIALES ELÉCTRICOS')
	insert into @gru (g,d) values('14', 'HERRAMIENTAS')


		--tabla con datos de obras
		insert into @bod (o,b) values ('ASJ',60)
		insert into @bod (o,b) values ('AV. COLON',84)
		insert into @bod (o,b) values ('CCND',47)
		insert into @bod (o,b) values ('CESAR G3',1118)
		insert into @bod (o,b) values ('DABEIBA',1100)
		insert into @bod (o,b) values ('FOND. ADAPTACION',1106)
		insert into @bod (o,b) values ('MONTERIA',85)
		insert into @bod (o,b) values ('PACIFICO 3',1112)
		insert into @bod (o,b) values ('SAN MARCOS',91)
		insert into @bod (o,b) values ('SAN MARCOS',1103)
		insert into @bod (o,b) values ('TALLER',2)
		insert into @bod (o,b) values ('TALLER',3)
		insert into @bod (o,b) values ('URABA',88)
		insert into @bod (o,b) values ('URABA',96)
		insert into @bod (o,b) values ('URABA',1109)
		insert into @bod (o,b) values ('VIAS',35)



	if @obra!='TODOS'
	begin




		insert into @res(ano_eval, mes_eval, ano, mes, grupo,entradas, sinmover) 
		SELECT     @ano_eval, @mes_eval, i.ano, i.mes,  r.grupo, SUM(i.cos_ent),
	       --calcula inventario sin mover. suma el valor de todos los  
           (SELECT  top 1   SUM(i2.cos_ini)-sum(i2.cos_sal)
			FROM       inventarios i2 INNER JOIN
					   referencias r2 ON i2.codigo = r2.codigo
			where      bodega in (select b from @bod where o=@obra) and i2.ano=@ano_eval and mes=@mes_eval
					and r2.grupo =r.grupo and dbo.ultima_entrada2(i2.codigo, i2.bodega, @mes_eval,@ano_eval)=@anomes 
			)                                   	
		FROM		inventarios i INNER JOIN
					referencias r ON i.codigo = r.codigo
		where      bodega in (select b from @bod where o=@obra) and ano=@ano and mes=@mes
           and grupo in (select g from @gru)                                     
		GROUP BY   i.mes, i.ano, r.grupo
		order by   ano,mes,grupo
	end
	else
	--
	begin
		insert into @res(ano_eval, mes_eval, ano, mes, grupo,entradas, sinmover) 
		SELECT     @ano_eval, @mes_eval, i.ano, i.mes,  r.grupo, SUM(i.cos_ent),
	       --calcula inventario sin mover. suma el valor de todos los  
           (SELECT  top 1   SUM(i2.cos_ini)-sum(i2.cos_sal)
			FROM       inventarios i2 INNER JOIN
					   referencias r2 ON i2.codigo = r2.codigo
			where      bodega in (select b from @bod ) and i2.ano=@ano_eval and mes=@mes_eval and r2.grupo =r.grupo and 
					dbo.ultima_entrada2(i2.codigo, i2.bodega, @mes_eval,@ano_eval)=@anomes 
			)                                   	
		FROM		inventarios i INNER JOIN
					referencias r ON i.codigo = r.codigo
		where       bodega in (select b from @bod ) and ano=@ano and mes=@mes
           and grupo in (select g from @gru)                                     
		GROUP BY   i.mes, i.ano, r.grupo
		order by   ano,mes,grupo
	end

	RETURN 
END



--ultima_entrada2

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================

--La diferencia de esta funcion con ultima_entrada es que no considera los inventarios mayores a una fecha,
--para poder evaluar periodos distintos al actual. Si por ejemplo la ultima entrada fue 2014 06, hay salidas en 2014 12, y se 
--quiere evaluar en 2014 10, debe devolver 2014 6 y no 2014 12  

CREATE FUNCTION [dbo].[ultima_entrada2]
(
	@codigo varchar(20),
	@bodega int,
	@mes int,
	@ano int
)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @ResultVar int
	declare @anomes int
	set @anomes=@ano*100+@mes
	set @ResultVar=(SELECT top 1 ano*100+mes
					FROM [dbo].[inventarios]
					where codigo=@codigo and bodega=@bodega and (can_ent>0)
					      and ano*100+mes<=@anomes
					order by ano*100+mes desc)
	RETURN @ResultVar

END



--stockMinimo

-- =============================================
-- Author:		Ramiro Villegas
-- Create date: 16-sep-2013
-- Description:	Stock Minimopor bodega
-- =============================================
CREATE PROCEDURE stockMinimo 
	-- Add the parameters for the stored procedure here
	@bodega int = 85, 
	@factorDS numeric(5,2) = 0,
	@ano int=2012,
	@mes int=8
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
SELECT     r.codigo, ROUND(r.promedio - 0.5 * r.stdDv + 0.5, 0) AS sm, referencias_actualizada.descripcion, referencias_actualizada.grupo, 
                      referencias_actualizada.costo_unitario
FROM         (SELECT     codigo, bodega, AVG(can_sal) AS promedio, STDEV(can_sal) AS stdDv, COUNT(*) AS n
                       FROM          inventarios
                       WHERE      (ano * 100 + mes >= @ano*100+@mes)
                       GROUP BY codigo, bodega
                       HAVING      (bodega = @bodega) AND (AVG(can_sal) <> 0)) AS r LEFT OUTER JOIN
                      referencias_actualizada ON r.codigo = referencias_actualizada.codigo
WHERE     (NOT (r.stdDv IS NULL)) AND (ROUND(r.promedio - @factorDS * r.stdDv + 0.5, 0) > 0)
			AND NOT referencias_actualizada.descripcion IS NULL
ORDER BY r.codigo
END



--ult_ent_vrt

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================

--La diferencia de esta funcion con ultima_entrada es que no considera los inventarios mayores a una fecha,
--para poder evaluar periodos distintos al actual. Si por ejemplo la ultima entrada fue 2014 06, hay salidas en 2014 12, y se 
--quiere evaluar en 2014 10, debe devolver 2014 6 y no 2014 12  

CREATE FUNCTION [dbo].[ult_ent_vrt]
(
	@codigo varchar(20),
	@bodega int,
	@anomes int
)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	--Se plantea una mejora: Para no tener que multiplicar y poder utilizar los indices, se separa año de mes
	--se utiliza las siguientes formulas 
	--am2>=am1	(a2>a1 or (a2=a1 and m2>=m1))
	--am2=am1	a2=a1 and m2=m1
	--am2<=am1	(a2<a1 or (a2=a1 and m2<=m1))

	DECLARE @ResultVar int
	--DECLARE @ano int, @mes int
	--set @ano=cast(@anomes/100 as int)
	--set @mes=@anomes-@ano*100
	--declare @anomes int
	--set @anomes=@ano*100+@mes
	set @ResultVar=(SELECT top 1 ano*100+mes
					FROM [dbo].[v_ref_total]
					where codigo=@codigo and bodega=@bodega and (can_ent>0)
					      and ano*100+mes<=@anomes
						  --and (ano<@ano or (ano=@ano and mes<=@mes))
					order by ano*100+mes desc
					  --order by ano desc, mes desc
					  )
	RETURN @ResultVar

END



--detalle_indicador_n

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[detalle_indicador_n]
(
	-- Add the parameters for the function here
	@anomes int,
	@centro int,
	@tipo varchar(3)


)
RETURNS TABLE 
AS
RETURN 
(

select j.destino, j.cos_des,k.codigo,k.descripcion,k.costo_stock,k.stock 
from
(select  i.destino, sum(i.costo) as cos_des 
from
(select	dbo.destino(@anomes,@centro,codigo) as destino ,costo_promedio*stk3 as costo
FROM	[dbo].[indicador_naslly] (@anomes,@centro,@tipo) where stk3>0 ) as i
group by i.destino) as j
inner join
(select	dbo.destino(@anomes,@centro,i.codigo) as destino , i.codigo, r.descripcion, stk3*costo_promedio as costo_stock, stk3 as stock
FROM	[dbo].[indicador_naslly] (@anomes,@centro,@tipo) as i
left join referencias as r
on   i.codigo=r.codigo
 where stk3>0 ) as k
 on j.destino=k.destino

)



--inv_sin_mov_vrt

-- =============================================
-- Author:		ramiro villegas
-- Create date: 27-02-2015
-- Description:	Calcula inventario obsoleto vs Entradas
-- =============================================

-- parametros: ano_eval: es el año en donde se calcula lo comprado que no se ha movido
--             mes_eval: es el año en donde se calcula lo comprado que no se ha movido 
--             ano: ano de la fecha a evaluar
--             mes: mes de la fecha a evaluar, inicialmente es 3 meses antes de fecha_eval
--             obra: Es el grupo de bodegas a evaluar, se consideran las bodegas de transito.
-- resultado:  El resultado es una tabla con los siguientes datos:
--             grupo: Es el grupo que se ananliza
--             entradas: entradas (+-compras) de ese grupo en ano, mes
--			   sinmover: es el total de entradas de ese mes que no se han movido en fecha_eval
--             se debe incluir un grupo con valor totalizado


CREATE FUNCTION [dbo].[inv_sin_mov_vrt] 
(
	-- Add the parameters for the function here
	@ano_eval int, 
	@mes_eval  int,
	@ano int, 
	@mes  int, 
	@obra  varchar(20)

)
RETURNS 
@res table(	ano_eval  int,
			mes_eval  int, 
			ano  int, 
			mes  int, 
			grupo  varchar(5),
			inventario    numeric(18,4),
			inv_obs  numeric(18,4),
			entradas numeric(18,4), 
			sinmover numeric(18,4))
AS
BEGIN
	declare  @anomes as int

	declare @gru table(g varchar(5),d varchar(50))
	declare @bod table (o varchar(20), b int)
	set @anomes=@ano*100+@mes
		--grupos seleccionados
	insert into @bod select * from dbo.obras()
	insert into @gru select * from dbo.gr_mecanica()



	if @obra!='TODOS'
	begin
		insert into @res(ano_eval, mes_eval, ano, mes, grupo,inventario, inv_obs,   entradas, sinmover) 
		SELECT     @ano_eval, @mes_eval, i.ano, i.mes,  i.grupo,
		--inventario: Inventario en fecha de evaluacion 
		 (select sum(costo_stock) from v_ref_total i2
		    where bodega in (select b from @bod  where o=@obra) 
			 and ano=@ano_eval and mes=@mes_eval and i2.grupo =i.grupo),
		--inventario obsoleto: Inventario en fecha de evaluacion que es tiene entradas antes de fecha corte 
		 (select sum(costo_stock) from v_ref_total i2
		    where bodega in (select b from @bod  where o=@obra) 
			 and ano=@ano_eval and mes=@mes_eval and i2.grupo =i.grupo and
			  dbo.ult_ent_vrt(i2.codigo, i2.bodega, @mes_eval,@ano_eval)<@anomes),
         --entrada:calcula las entradas de la fecha de corte
		    SUM(i.cos_ent),
	       --sinmover: calcula el que va a entrar inventario obsoleto.  
           (SELECT  top 1   SUM(i2.cos_ini)-sum(i2.cos_sal)
			FROM       v_ref_total i2
			where      bodega in (select b from @bod where o=@obra) and i2.ano=@ano_eval and mes=@mes_eval
					and i2.grupo =i.grupo and dbo.ult_ent_vrt(i2.codigo, i2.bodega, @mes_eval,@ano_eval)=@anomes 
			)
			                                   	
		FROM		v_ref_total i 
		where      bodega in (select b from @bod where o=@obra) and ano=@ano and mes=@mes
           and grupo in (select g from @gru)                                     
		GROUP BY   i.mes, i.ano, i.grupo
		order by   ano,mes,grupo
	end
	else
	--
	begin
		insert into @res(ano_eval, mes_eval, ano, mes, grupo,inventario, inv_obs, entradas, sinmover) 
		SELECT     @ano_eval, @mes_eval, i.ano, i.mes,  i.grupo,

		--inventario: Inventario en fecha de evaluacion 		   
		   (select sum(costo_stock) from v_ref_total i2
		    where --bodega in (select b from @bod ) and 
			      ano=@ano_eval and mes=@mes_eval and i2.grupo =i.grupo),

		--inventario obsoleto: Inventario en fecha de evaluacion que es tiene entradas antes de fecha corte 
		 (select sum(costo_stock) from v_ref_total i2
		    where 
			 --bodega in (select b from @bod) and
			 ano=@ano_eval and mes=@mes_eval and i2.grupo =i.grupo and
			  dbo.ult_ent_vrt(i2.codigo, i2.bodega, @mes_eval,@ano_eval)<@anomes),

         --entrada:calcula las entradas de la fecha de corte
			SUM(i.cos_ent),
	       --calcula inventario sin mover. suma el valor de todos los  
           (SELECT  top 1   SUM(i2.cos_ini)-sum(i2.cos_sal)
			FROM       v_ref_total i2
			where     
			   -- bodega in (select b from @bod ) and 
			   i2.ano=@ano_eval and mes=@mes_eval and i2.grupo =i.grupo and 
					dbo.ult_ent_vrt(i2.codigo, i2.bodega, @mes_eval,@ano_eval)=@anomes 
			)                                   	
		FROM		v_ref_total i
		where      
		-- bodega in (select b from @bod ) and 
		ano=@ano and mes=@mes
           and grupo in (select g from @gru)                                     
		GROUP BY   i.mes, i.ano, i.grupo
		order by   ano,mes,grupo
	end

	RETURN 
END



--destino

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[destino]
(
	@anomes int,
	@centro int,
	@codigo varchar(20)	
)
RETURNS varchar(255)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @res varchar(255)
set @res=isnull((select top 1 destino  from v_ref_total as r
			left join bodegas as b
			on b.bodega=r.bodega 
			where 
			codigo=@codigo and ano*100+mes=@anomes and not destino like '%GASTO%' and b.centro=@centro),'Sin destino...')
return @res

END


