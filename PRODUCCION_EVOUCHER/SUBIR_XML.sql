

SELECT * FROM comprobante c WHERE c.comprobanteatsid = 4922


SELECT lo_export(c.comprobante , '/tmp/comprobanteats') FROM comprobante c WHERE c.comprobanteatsid = 4922

--UPDATE comprobante SET comprobante = lo_import('/tmp/comprobanteats.xml') WHERE comprobanteatsid = 4922

