SELECT *
FROM comprobante
WHERE estado = 'AUTORIZADO'
  AND tipocomprobante = 'FACTURA'
  AND comprobante.comprobanteautorizado IS NOT NULL
ORDER BY 1 DESC
LIMIT 500;


SELECT ENCODE(LO_GET(comprobanteautorizado), 'escape')::TEXT
FROM comprobante
WHERE id = 6379749;

UPDATE comprobante SET comprobanteautorizado = lo_import('/tmp/factura12.xml') WHERE id = 6379751;

select * from comprobante where id = 6379751;

SELECT

select * from comprobantexml;

SELECT *
FROM comprobante
WHERE id = 6377271;





