select * from costo where tarifario_id in (
select id from tarifario where id in (
select DISTINCT tarifario_id from nivel where id in (
2495, 3287, 4275,3382,3286,4269,3247,3295,4282,
2496,3294,3940,4061,2498,3296,2479,3289,  4281,
3383,3288,4270, 3249,3298,4277,2486,3297, 3942,
4060, 2487, 3299, 4401, 3384, 4259, 4276, 3385,
4260, 4288, 3300, 4261
    )))
and servicio_id = 54


select DISTINCT concat('select clonarcostotarifario(',codigo,', ''2025-06-30'', 3);') from tarifario where id in (
    select DISTINCT tarifario_id from nivel where id in (
                                                         2495, 3287, 4275,3382,3286,4269,3247,3295,4282,
                                                         2496,3294,3940,4061,2498,3296,2479,3289,  4281,
                                                         3383,3288,4270, 3249,3298,4277,2486,3297, 3942,
                                                         4060, 2487, 3299, 4401, 3384, 4259, 4276, 3385,
                                                         4260, 4288, 3300, 4261
        ))
and codigo <> '8690'

select clonarcostotarifario('8690', '2025-06-30', 3);
select clonarcostotarifario('8697', '2025-06-30', 3);
select clonarcostotarifario('8707', '2025-06-30', 3);
select clonarcostotarifario('8687', '2025-06-30', 3);
select clonarcostotarifario('8708', '2025-06-30', 3);
select clonarcostotarifario('8702', '2025-06-30', 3);
select clonarcostotarifario('8694', '2025-06-30', 3);
select clonarcostotarifario('8698', '2025-06-30', 3);
select clonarcostotarifario('8696', '2025-06-30', 3);
select clonarcostotarifario('8695', '2025-06-30', 3);
select clonarcostotarifario('8692', '2025-06-30', 3);
select clonarcostotarifario('8701', '2025-06-30', 3);
select clonarcostotarifario('8693', '2025-06-30', 3);
select clonarcostotarifario('8683', '2025-06-30', 3);
select clonarcostotarifario('8691', '2025-06-30', 3);
select clonarcostotarifario('8704', '2025-06-30', 3);
select clonarcostotarifario('8684', '2025-06-30', 3);
select clonarcostotarifario('8700', '2025-06-30', 3);
select clonarcostotarifario('8711', '2025-06-30', 3);
select clonarcostotarifario('8709', '2025-06-30', 3);
select clonarcostotarifario('8713', '2025-06-30', 3);
select clonarcostotarifario('8706', '2025-06-30', 3);
select clonarcostotarifario('8710', '2025-06-30', 3);
select clonarcostotarifario('8703', '2025-06-30', 3);
select clonarcostotarifario('8685', '2025-06-30', 3);
select clonarcostotarifario('8712', '2025-06-30', 3);
select clonarcostotarifario('8699', '2025-06-30', 3);
select clonarcostotarifario('8688', '2025-06-30', 3);
select clonarcostotarifario('8689', '2025-06-30', 3);
select clonarcostotarifario('8705', '2025-06-30', 3);
