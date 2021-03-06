SELECT referencias_sto.ano, referencias_sto.mes,
       referencias_sto.codigo, referencias_sto.can_ini+referencias_sto.can_ent- referencias_sto.can_sal as saldo,
       referencias.descripcion as descripcion, referencias_sto.bodega, referencias.grupo, u.ult_fecha AS Fecha_ult_ingreso
       
FROM   dms_condor.dbo.referencias_sto referencias_sto
		INNER JOIN dbo.referencias ON referencias_sto.codigo = referencias.codigo LEFT OUTER JOIN
                      dbo.v_fecha_ultimo_ingreso2 AS u ON u.codigo = referencias_sto.codigo AND u.bodega = referencias_sto.bodega

WHERE referencias_sto.can_ini+referencias_sto.can_ent- referencias_sto.can_sal<>$0) AND (referencias_sto.ano=@@1) AND (referencias_sto.mes=@@2)


order by referencias_sto.codigo, referencias_sto.bodega