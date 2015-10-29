SELECT referencias_sto.ano, referencias_sto.mes,
       referencias_sto.codigo, referencias_sto.can_ini+referencias_sto.can_ent- referencias_sto.can_sal as saldo,
       REPLACE(REPLACE(referencias.descripcion,CHAR(10),' '),CHAR(13),'') as descripcion,


 referencias_sto.bodega, referencias.grupo, CONVERT(VARCHAR(10),u.ult_fecha,103) AS Fecha_ult_ingreso
       
FROM   dms_condor.dbo.referencias_sto referencias_sto
		left outer  JOIN dbo.referencias ON replace(referencias_sto.codigo,'*1','') = referencias.codigo LEFT OUTER JOIN
                      dbo.v_fecha_ultimo_ingreso2 AS u ON u.codigo = referencias_sto.codigo AND u.bodega = referencias_sto.bodega

WHERE (referencias_sto.can_ini+referencias_sto.can_ent- referencias_sto.can_sal<>$0) AND (referencias_sto.ano=@@1) AND (referencias_sto.mes=@@2)


order by referencias_sto.codigo, referencias_sto.bodega
