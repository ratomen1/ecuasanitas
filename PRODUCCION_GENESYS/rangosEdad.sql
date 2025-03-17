CREATE TABLE rangos_edad (
                             id SERIAL PRIMARY KEY,
                             descripcion VARCHAR(50) NOT NULL,
                             edad_minima INTEGER NOT NULL,
                             edad_maxima INTEGER NOT NULL
);

INSERT INTO rangos_edad (descripcion, edad_minima, edad_maxima) VALUES
                                                                    ('De 0 a 1 año', -1, 1),
                                                                    ('De 2 a 15 años', 2, 15),
                                                                    ('De 16 a 30 años', 16, 30),
                                                                    ('De 31 a 49 años', 31, 49),
                                                                    ('De 50 a 60 años', 50, 60),
                                                                    ('De 61 a 65 años', 61, 65),
                                                                    ('De 66 a 70 años', 66, 70),
                                                                    ('De 71 a 80 años', 71, 80),
                                                                    ('De 81 a 90 años', 81, 90),
                                                                    ('De 91 a 100 años', 91, 100);

select * from rangos_edad ORDER BY 1 ASC