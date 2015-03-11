SELECT  flt_actividad_equipos_consumos.id_actividad, 
	flt_actividad_equipos_consumos.id_tipo_componente, 
	flt_actividad_equipos_consumos.Com_Lub, 
	flt_actividad_equipos_consumos.tipo_consumido, 
        flt_actividad_equipos_consumos.cantidad_consumida
FROM            flt_actividad_equipos_consumos RIGHT OUTER JOIN
                         flt_actividad_equipos ON flt_actividad_equipos_consumos.id_actividad = flt_actividad_equipos.id
where year(flt_actividad_equipos.fecha)=@@1 and month(flt_actividad_equipos.fecha)=@@2
