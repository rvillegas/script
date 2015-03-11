SELECT        tall_operarios.nit, tall_operarios.escalafon, tall_operarios.actividad, tall_operarios.bodega, tall_operarios.contratista, tall_operarios.patio, tall_operarios.codigo_op, tall_operarios.activo, terceros.nombres
FROM            tall_operarios LEFT OUTER JOIN
                         terceros ON tall_operarios.nit = terceros.nit