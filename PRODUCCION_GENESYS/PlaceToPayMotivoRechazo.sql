SELECT * FROM solicitud s WHERE id = -220163301


INSERT INTO public.solicitud (id, codigosede, cuotasinimpuestos, enefectivo, fecha, fechapago, numero, valor, descuento, recievableid, tipo) VALUES(-220163301, 1, 137.00, true, '2024-09-02', '2024-09-02', 3947800, 137.69, 0.00, NULL, 'VN');

SELECT * FROM DetalleOrdenRecaudacionDebitoTerceroPlaceToPay WHERE placetopay_collect_request_id IS NULL

SELECT * FROM DetalleOrdenRecaudacionDebitoTerceroPlaceToPay ORDER BY 1 DESC

SELECT * FROM DetalleOrdenRecaudacionDebitoTerceroPlaceToPay WHERE id = 67184

SELECT x.* FROM placetopay.collectrequest x WHERE id = 75430

SELECT x.* FROM placetopay.collectresponse x WHERE id = 75430


SELECT cr.jsonresponserequest
FROM placetopay.collectresponse cr
         JOIN placetopay.collectrequest cq ON cr.id = cq.id
         JOIN DetalleOrdenRecaudacionDebitoTerceroPlaceToPay d ON cq.id = d.placetopay_collect_request_id
WHERE d.id = 67184;



SELECT
    cr.jsonresponserequest::jsonb -> 'payment' AS reason
FROM
    DetalleOrdenRecaudacionDebitoTerceroPlaceToPay d
        JOIN
    placetopay.collectrequest cq ON d.placetopay_collect_request_id = cq.id
        JOIN
    placetopay.collectresponse cr ON cq.id = cr.id
WHERE
    d.id = 67184;


SELECT
    (cr.jsonresponserequest::json -> 'payment' -> 'status'->>'reason') AS status
FROM
    DetalleOrdenRecaudacionDebitoTerceroPlaceToPay d
        JOIN
    placetopay.collectrequest cq ON d.placetopay_collect_request_id = cq.id
        JOIN
    placetopay.collectresponse cr ON cq.id = cr.id
WHERE
    d.id = 67184


SELECT
    d.id,
    concat('UPDATE DetalleOrdenRecaudacionDebitoTerceroPlaceToPay SET motivo_rechazo = ',(payment_element->'status'->>'reason'),' - ',(payment_element->'status'->>'message'),' WHERE id =',d.id,';') AS message
FROM
    DetalleOrdenRecaudacionDebitoTerceroPlaceToPay d
        JOIN
    placetopay.collectrequest cq ON d.placetopay_collect_request_id = cq.id
        JOIN
    placetopay.collectresponse cr ON cq.id = cr.id,
    jsonb_array_elements(cr.jsonresponserequest::jsonb->'payment') AS payment_element
WHERE
    d.placetopay_collect_request_id IS NOT NULL
--AND d.id = 67184




SELECT
    concat('UPDATE DetalleOrdenRecaudacionDebitoTerceroPlaceToPay SET motivo_rechazo = ',(payment_element->'status'->>'reason'),' - ',(payment_element->'status'->>'message'),' WHERE id =',d.id,';') AS message
FROM
    DetalleOrdenRecaudacionDebitoTerceroPlaceToPay d
        JOIN
    placetopay.collectrequest cq ON d.placetopay_collect_request_id = cq.id
        JOIN
    placetopay.collectresponse cr ON cq.id = cr.id,
    LATERAL jsonb_array_elements(CASE WHEN jsonb_typeof(cr.jsonresponserequest::jsonb->'payment') = 'array' THEN cr.jsonresponserequest::jsonb->'payment' ELSE '[]'::jsonb END) AS payment_element
WHERE
    d.placetopay_collect_request_id IS NOT NULL;


