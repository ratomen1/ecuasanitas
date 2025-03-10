------- acceder por terminal a las base de pruebas ----

ssh root@192.168.40.128
pass: Passw0rd

psql -U postgres

--1---------------------------TERMINAR SESIONES-------------------------------
SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pid <> pg_backend_pid() and datname = 'genesys' ;
SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pid <> pg_backend_pid() and datname = 'luca' ;

--2--------------------------- RENOMBRAR GENESYS y LUCA ACTUAL ---------------------------
ALTER DATABASE genesys rename to genesys_old1612;
ALTER DATABASE luca rename to luca_old1612;

--3--------------------------- RENOMBRAR LUCA NUEVA BASE ---------------------------
ALTER DATABASE "genesys16Diciembre" rename to genesys;
\c genesys
VACUUM (VERBOSE, ANALYZE);

--4--------------------------- ACTUALIAR CORREOS PRUEBAS ---------------------------
update entidad set email = 'pruebasgenesys9@gmail.com' where email is not null;
update contrato set correo = 'pruebasgenesys9@gmail.com' where correo is not null;


\c postgres

--5--------------------------- RENOMBRAR LUCA NUEVA BASE ---------------------------
SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pid <> pg_backend_pid() and datname = 'luca16Diciembre' ;
ALTER DATABASE "luca16Diciembre" rename to luca;
\c luca
VACUUM (VERBOSE, ANALYZE);

--6--------------------------- ACTUALIZAR ENTORNO FACTURACION LUCA A PRUEBAS---------------------------
update irs.settingcompany set environmenttype_id = 1 where id = 1;


-- salir
\q

