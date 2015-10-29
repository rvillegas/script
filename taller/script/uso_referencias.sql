SELECT      
	l.codigo,
	convert(VARCHAR(19), max(l.fec) ,120) as ultima_fecha,
 	p.codigo_interno as destino
FROM     documentos_lin l left join terceros t on l.nit=t.nit join conceptos_distribucion p   on l.destino = p.codigo   
left join referencias r   on l.codigo = r.codigo   
left join referencias_gru g   on r.grupo = g.grupo   
left join V_REFERENCIAS_ALT a   on r.codigo = a.codigo          
left join bodegas b   on l.bodega = b.bodega    
WHERE l.fec  >= '@@1' and l.fec <= '@@2' and p.codigo_interno like '[A-Z][A-Z]%' and  sw = 11
group by l.codigo,p.codigo_interno
ORDER BY  l.codigo,p.codigo_interno
