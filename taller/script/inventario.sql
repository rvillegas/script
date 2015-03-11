SELECT referencias_sto.bodega, referencias_sto.codigo, referencias_sto.ano, referencias_sto.mes, referencias_sto.can_ini, 
       referencias_sto.can_ent, referencias_sto.can_sal, referencias_sto.cos_ini, referencias_sto.cos_ent, referencias_sto.cos_sal, 
       referencias_sto.can_com, referencias_sto.cos_com, referencias_sto.can_dev_com, referencias_sto.cos_dev_com, 
       referencias_sto.can_otr_ent, referencias_sto.cos_otr_ent, referencias_sto.can_otr_sal, referencias_sto.cos_otr_sal, 
       referencias_sto.can_tra, referencias_sto.cos_tra, referencias_sto.sub_cos, referencias_sto.nro_com, referencias_sto.nro_dev_com, 
       referencias_sto.cos_ini_aju, referencias_sto.cos_ent_aju, referencias_sto.cos_sal_aju

FROM   dms_condor.dbo.referencias_sto referencias_sto

WHERE (referencias_sto.can_ent<>$0) AND (referencias_sto.ano=@@1) AND (referencias_sto.mes=@@2) AND (charindex('*1',codigo)=0) 
       OR (referencias_sto.ano=@@1) AND (referencias_sto.mes=@@2) AND (charindex('*1',codigo)=0) AND (referencias_sto.can_sal<>$0) 
       OR (referencias_sto.ano=@@1) AND (referencias_sto.mes=@@2) AND (charindex('*1',codigo)=0) AND (referencias_sto.can_ini<>$0)
  
