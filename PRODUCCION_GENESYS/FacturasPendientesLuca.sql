-- VALIDAR FACTURAS PENDIENTES LUCA
select c.voucher, c.date_, c.clientidentificationnumber ruc, c.creationdate, c.electronicauthstatus, c.*
from irs.salevoucher c
where c."type" in ('INVOICE', 'CREDITNOTE')   -- 'INVOICE', 'CREDITNOTE'
  and (c.electronicauthstatus not in ('AUTORIZADO', 'ANULADO') or c.electronicauthstatus is null )
  and c.financialstatuscode = 'VALID'
  and to_char(date(c.date_) , 'yyyy-MM') = '2024-12' -- el mes actual
  and c.date_ <= '2024-12-08' -- poner un dia antes del date
  and (electronicauthstatus = 'XML GENERADO' or electronicauthstatus is null )
--and c.electronicauthstatus is null
order by c.date_, c.voucher;