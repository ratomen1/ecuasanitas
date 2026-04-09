

SELECT * FROM comprobante c WHERE c.id = 9730610


SELECT lo_export(c.comprobante , '/tmp/liquidacionPancho33') FROM comprobante c WHERE c.id = 9730610

UPDATE comprobante SET comprobante = lo_import('/tmp/liquidacionPancho3311.xml') WHERE id = 9730610

--UPDATE comprobante SET comprobante = lo_import('/tmp/comprobanteats.xml') WHERE comprobanteatsid = 4922

SELECT ENCODE(LO_GET(comprobante), 'escape')::TEXT
FROM comprobante
WHERE id = 9730610;