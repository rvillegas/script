SELECT        flt_actividad_equipos_inspeccion.id_actividad, flt_actividad_equipos_inspeccion.id_inspeccion_lin, flt_actividad_equipos_inspeccion.notas, flt_actividad_equipos_inspeccion.estado, 
                         flt_actividad_equipos_inspeccion.id_Nota
FROM            flt_actividad_equipos_inspeccion RIGHT OUTER JOIN
                         flt_actividad_equipos ON flt_actividad_equipos_inspeccion.id_actividad = flt_actividad_equipos.id
where year(flt_actividad_equipos.fecha)=@@1 and month(flt_actividad_equipos.fecha)=@@2
