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

select clonarcostotarifario('8690', '2025-06-30', 3.5);
select clonarcostotarifario('8707', '2025-06-30', 3.5);
select clonarcostotarifario('8697', '2025-06-30', 3.5);
select clonarcostotarifario('8687', '2025-06-30', 3.5);
select clonarcostotarifario('8708', '2025-06-30', 3.5);
select clonarcostotarifario('8702', '2025-06-30', 3.5);
select clonarcostotarifario('8694', '2025-06-30', 3.5);
select clonarcostotarifario('8698', '2025-06-30', 3.5);
select clonarcostotarifario('8696', '2025-06-30', 3.5);
select clonarcostotarifario('8695', '2025-06-30', 3.5);
select clonarcostotarifario('8692', '2025-06-30', 3.5);
select clonarcostotarifario('8701', '2025-06-30', 3.5);
select clonarcostotarifario('8693', '2025-06-30', 3.5);
select clonarcostotarifario('8683', '2025-06-30', 3.5);
select clonarcostotarifario('8691', '2025-06-30', 3.5);
select clonarcostotarifario('8704', '2025-06-30', 3.5);
select clonarcostotarifario('8684', '2025-06-30', 3.5);
select clonarcostotarifario('8700', '2025-06-30', 3.5);
select clonarcostotarifario('8711', '2025-06-30', 3.5);
select clonarcostotarifario('8709', '2025-06-30', 3.5);
select clonarcostotarifario('8713', '2025-06-30', 3.5);
select clonarcostotarifario('8706', '2025-06-30', 3.5);
select clonarcostotarifario('8710', '2025-06-30', 3.5);
select clonarcostotarifario('8703', '2025-06-30', 3.5);
select clonarcostotarifario('8685', '2025-06-30', 3.5);
select clonarcostotarifario('8712', '2025-06-30', 3.5);
select clonarcostotarifario('8699', '2025-06-30', 3.5);
select clonarcostotarifario('8688', '2025-06-30', 3.5);
select clonarcostotarifario('8689', '2025-06-30', 3.5);
select clonarcostotarifario('8705', '2025-06-30', 3.5);
--Segundo cambio
select clonarcostotarifario('980', '2025-06-30', 3.5);
select clonarcostotarifario('7049', '2025-06-30', 3.5);
select clonarcostotarifario('7116', '2025-06-30', 3.5);
select clonarcostotarifario('7301', '2025-06-30', 3.5);
select clonarcostotarifario('7305', '2025-06-30', 3.5);
select clonarcostotarifario('7322', '2025-06-30', 3.5);
select clonarcostotarifario('7324', '2025-06-30', 3.5);
select clonarcostotarifario('7329', '2025-06-30', 3.5);
select clonarcostotarifario('7330', '2025-06-30', 3.5);
select clonarcostotarifario('7342', '2025-06-30', 3.5);
select clonarcostotarifario('7343', '2025-06-30', 3.5);
select clonarcostotarifario('7344', '2025-06-30', 3.5);
select clonarcostotarifario('7345', '2025-06-30', 3.5);
select clonarcostotarifario('7347', '2025-06-30', 3.5);
select clonarcostotarifario('7353', '2025-06-30', 3.5);
select clonarcostotarifario('7354', '2025-06-30', 3.5);
select clonarcostotarifario('7355', '2025-06-30', 3.5);
select clonarcostotarifario('7375', '2025-06-30', 3.5);
select clonarcostotarifario('7376', '2025-06-30', 3.5);
select clonarcostotarifario('7377', '2025-06-30', 3.5);
select clonarcostotarifario('7378', '2025-06-30', 3.5);
select clonarcostotarifario('7379', '2025-06-30', 3.5);
select clonarcostotarifario('7393', '2025-06-30', 3.5);
select clonarcostotarifario('7394', '2025-06-30', 3.5);
select clonarcostotarifario('7395', '2025-06-30', 3.5);
select clonarcostotarifario('7396', '2025-06-30', 3.5);
select clonarcostotarifario('7411', '2025-06-30', 3.5);
select clonarcostotarifario('7412', '2025-06-30', 3.5);
select clonarcostotarifario('7414', '2025-06-30', 3.5);
select clonarcostotarifario('7416', '2025-06-30', 3.5);
select clonarcostotarifario('7418', '2025-06-30', 3.5);
select clonarcostotarifario('7419', '2025-06-30', 3.5);
select clonarcostotarifario('7420', '2025-06-30', 3.5);
select clonarcostotarifario('7423', '2025-06-30', 3.5);
select clonarcostotarifario('7429', '2025-06-30', 3.5);
select clonarcostotarifario('7430', '2025-06-30', 3.5);
select clonarcostotarifario('7431', '2025-06-30', 3.5);
select clonarcostotarifario('7432', '2025-06-30', 3.5);
select clonarcostotarifario('7454', '2025-06-30', 3.5);
select clonarcostotarifario('7455', '2025-06-30', 3.5);
select clonarcostotarifario('7456', '2025-06-30', 3.5);
select clonarcostotarifario('7601', '2025-06-30', 3.5);
select clonarcostotarifario('7603', '2025-06-30', 3.5);
select clonarcostotarifario('7604', '2025-06-30', 3.5);
select clonarcostotarifario('7605', '2025-06-30', 3.5);
select clonarcostotarifario('7606', '2025-06-30', 3.5);
select clonarcostotarifario('7608', '2025-06-30', 3.5);
select clonarcostotarifario('7610', '2025-06-30', 3.5);
select clonarcostotarifario('7611', '2025-06-30', 3.5);
select clonarcostotarifario('7613', '2025-06-30', 3.5);
select clonarcostotarifario('7621', '2025-06-30', 3.5);
select clonarcostotarifario('7622', '2025-06-30', 3.5);
select clonarcostotarifario('7940', '2025-06-30', 3.5);
select clonarcostotarifario('7941', '2025-06-30', 3.5);
select clonarcostotarifario('7942', '2025-06-30', 3.5);
select clonarcostotarifario('7943', '2025-06-30', 3.5);
select clonarcostotarifario('8878', '2025-06-30', 3.5);
select clonarcostotarifario('8879', '2025-06-30', 3.5);

