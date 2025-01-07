SELECT
    s.id,
    *
FROM sede s
         left join divisionterritorial dt on dt.id = s.divisionterritorial_id;



SELECT
    c.sede_id,c.*
FROM contrato c
WHERE c.numero IN (581381,581429,581674,581707,581721,581788,581797,581877,581880,581885,581926,581931,
                   581936,582122);


SELECT
    *
FROM contrato c
         left join sede s on s.id = c.sede_id
         LEFT JOIN divisionterritorial dt ON dt.id = s.divisionterritorial_id
WHERE c.numero IN (
    581381,581429,581674,581707,581721,581788,581797,581877,581880,581885,581926,581931,
581936,582122);--contrato9s erco

      /*(290711,
                   304996,511466,301972,302255,306223,248853,502803,290749,296777,296070,
                   508617,303062,510356,503796,505198,506289,300107,295750,217848,500031,
                   511926,305989,292731,305902,303433,299054,504499
    )*/--contratos ibarra 2

SELECT * from cuotapendiente order by 1 desc

select * from nivel where nombre ilike '%erco%'





