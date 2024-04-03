
CREATE USER '<username>'@'%' IDENTIFIED BY '<pass>' ;

GRANT ALL ON <databasename>.* TO '<username>'@'%' ;
GRANT SELECT on *.* TO '<username>'@'%' identified BY '<pass>';
GRANT SELECT on <databasename>.* TO '<username>'@'%' identified BY '<pass>';


FLUSH PRIVILEGES ;
SHOW GRANTS FOR <username>;
# Show current user
SELECT user,host FROM mysql.user;

# Revoke privileges and delete user
REVOKE ALL PRIVILEGES, GRANT OPTION FROM '<username>'@'%';
DROP USER '<username>'@'%';
