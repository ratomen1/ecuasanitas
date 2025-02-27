--PASO 1
select vouchernumberreference, financialstatuscode,incometype, subtotal, total, SPLIT_PART(aditionalinfo, '==', 2) contrato, * from income.receiptreport r
where id in (
    select receiptreport_id from income.payment p
    where p.referenceid in (5588,5582,5580,5584,5583,5594,5585,5586,5587,5589,5590,5591)
      and value_ = 20.81
)and aditionalinfo not ilike '%574275%'
order by id;

--PASO 2
select id, i.value_, i.total, servicedate, description, * from irs.item i
where i.salevoucher_id = (select id from irs.salevoucher s where s.voucher = '001-086-001654266') --and servicedate  = '2025-03-01'
order by i.servicedate;

--EJECUTAR
--primero
delete from irs.taxitem t where t.item_id in (
                                              10945142,
                                              10945149,
                                              10945148,
                                              10945150
    );

--segundo
delete from irs.item i where i.id in (
                                      10945142,
                                      10945149,
                                      10945148,
                                      10945150
    );

--tercero
update irs.item i set value_ = 107.34, total = 107.34 where i.id in (
    10945145
    );

--PASO 3
update irs.taxitem t set base = 107.34 where t.salevoucher_id  = (select id from irs.salevoucher s where s.voucher = '001-086-001654266')
                                         and t.base = 107.32;