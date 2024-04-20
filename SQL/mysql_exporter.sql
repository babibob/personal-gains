
CREATE USER 'exporter'@'%' IDENTIFIED BY '<PASSWORD>' WITH MAX_USER_CONNECTIONS 3;
GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'%';
FLUSH PRIVILEGES;

SELECT User,Host,Process_priv,Repl_client_priv,max_user_connections FROM mysql.user;
