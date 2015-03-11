select 	e.bodega, e.equipo, r.descripcion, un.descripcion as Ubicacion,  ee.descripcion as Estado, 							
	vh.placa, vh.ano as modelo,vh.serie,vh.motor
from 								
		flt_datos_adicionales e 						
		left join referencias r	on e.equipo = r.codigo					
                left join referencias_imp i on e.equipo=i.codigo								
		left join bodegas b on e.bodega = b.bodega						
		left  join flt_equipos_estados ee on ee.codigo = e.estado						
		left join unidades_negocio un on b.unidad_negocio = un.codigo						
		left join  v_vh_vehiculos vh on e.equipo=vh.codigo						
where e.equipo LIKE ('[A-Z][A-Z]%') 								
and  e.bodega is not null 								
and (r.ref_anulada='N' or r.ref_anulada='' or r.ref_anulada=null or r.ref_anulada is null)								
order by e.bodega, e.equipo	
