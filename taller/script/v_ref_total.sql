SELECT distinct vrf.codigo
      ,vrf.bodega
      ,vrf.ano
      ,vrf.mes
      ,REPLACE(REPLACE(vrf.descripcion,CHAR(10),' '),CHAR(13),'') as descripcion
      ,vrf.can_ini
      ,vrf.can_ent
      ,vrf.can_sal
      ,vrf.cos_ini
      ,vrf.cos_ent
      ,vrf.cos_sal
      ,vrf.Stock
      ,vrf.Costo_Stock
      ,vrf.ultima_com
      ,vrf.costo_estandar
      ,vrf.grupo
      ,vrf.unidad
      ,vrf.fec_ult_Salida
     ,z.Descripcion AS destino
  FROM dbo.v_ref_total as vrf  LEFT OUTER JOIN
  dbo.v_fecha_ultimo_ingreso2 AS u ON u.codigo = vrf.codigo AND u.bodega = vrf.bodega LEFT OUTER JOIN
  dbo.conceptos_distribucion AS z ON u.destino = z.Codigo
 where vrf.ano=@@1 and vrf.mes=@@2 and vrf.stock>0