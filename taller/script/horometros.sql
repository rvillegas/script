select fa.equipo,  CONVERT(VARCHAR(10), fecha, 103) as sFecha,horometro_final
from flt_actividad_equipos fa
where fecha>='01-01-2014'
and fa.equipo between ('') and ('zzzzzzzzz')
order by fa.equipo
