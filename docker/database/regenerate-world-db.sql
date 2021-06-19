DROP DATABASE mangos;
CREATE DATABASE mangos DEFAULT CHARSET utf8 COLLATE utf8_general_ci;
GRANT ALL PRIVILEGES ON *.* TO 'mangos'@'%' IDENTIFIED BY 'mangos';
flush privileges;
grant all on mangos.* to mangos@'localhost' with grant option;
flush privileges;
