ALTER USER genesys WITH PASSWORD 'genesys';


SELECT usename FROM pg_user WHERE usename = 'genesys';

SELECT datname FROM pg_database WHERE datname = 'genesys';

GRANT ALL PRIVILEGES ON DATABASE genesys TO genesys;

SELECT version();

select * from direccion
