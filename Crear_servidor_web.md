# Crear servidor web en Ububtu server 2014.04

Debido a la necesidad de actualizar el servidor web a una version que este soportada por canonical, hay que actualizar el servidor de la version 10.04 a la 14.04.

La pagina anterior que utilizaba para crear los servidores [Instalar servidor Ubuntu server Forat](http://www.forat.info/2008/08/servidor-en-linux-ubuntu-server-manual-completo/) es muy completa y precisa, pero con la varsión 14 hay algunos cambios que no estan incluidos.


##VirtualBox.

Se baja [virtualbox](https://www.virtualbox.org/wiki/Downloads), mejor la opción de 64 bits

##Ubuntu 14.04 64 bits

Se baja [Ubuntu Server 64 bits](http://releases.ubuntu.com/14.04/ubuntu-14.04.2-server-amd64.iso).

##Instalación de ubuntu server 14.04 en virtualbox.

En la instalación se sigue el procedimiento de la pagina de [Forat](http://www.forat.info/2008/08/servidor-en-linux-ubuntu-server-manual-completo/) 

**1-**Se instala ubuntu server con ssh lamp samba cut print.

**2-**Se ajusta la red con adaptador puente, la tarjeta de red que se usa.

**3-**Se cambia /etc/network/interfaces

	auto eth0
	iface eth0 inet static

	address 192.168.5.145
	netmask 255.255.255.0
	gateway 192.168.5.1
	dns-nameservers 8.8.8.8 8.8.4.4

referencia:[dns-nameservers](http://askubuntu.com/questions/465729/ping-unknown-host-google-com-in-ubuntu-server)
Estas direcciones son especificas para el servidor en una red especifica (192.168.5.xxx)

**4-**Se configura **LAMP** (Linux-Apache-Mysql-Php,Python,Perl)

**4.1-** Configurar apache2.

En la versión 14.04 en mas complicado, los cambios hay que hacerlos en varios archivos

**4.1.1-** Copia el archivo de configuación del directorio raiz al nuevo sitio

	sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/minuevositio.conf

**4.1.2-** En el nuevo sitio cambia el archivo raiz asi:

	sudo nano /etc/apache2/sites-available/minuevositio.conf

Cambia la linea 

	DocumentRoot /home/ramiro/web 

y guarda (F2)

Ejecuta

	sudo a2ensite mynewsite.conf
	sudo a2dissite 000-default.conf
	sudo service apache2 reload

Edita el archivo **apache2.conf** :

	sudo nano /etc/apache2/apache2.conf

Cambia el nombre del servidor de instalación **\var\www** por **\home\ramiro\web** 

	<Directory \home\ramiro\web>
		Options Indexes FollowSymLinks
		AllowOverride None
		Require all granted
	</Directory>

Se guarda (F2) y se reinicia el servidor


	sudo service apache2 restart

referencias:
[Askubuntu](http://askubuntu.com/questions/413887/403-forbidden-after-changing-documentroot-directory-apache-2-4-6)
[ubuntu](https://help.ubuntu.com/14.04/serverguide/httpd.html#http-configuration)

**4.2-** Se verifica que este funcionando el servidor apache:
 
 Se crea el archivo test.html:
 
 	sudo nano /home/ramiro/web/test.html
 	
 Se agrega el siguiente texto:
 
 	<html>
 	  <body>
 	    Trabaja...
	  </body>
	 </html>

 En el explorador se escribe: [http://192.168.5.145/test.html](http://192.168.5.145/test.html) para este caso.
 
**4.3** - Verificar que este funcionando PHP

Se crea el archivo prueba.php en /home/ramiro/web/:

	sudo nano /home/ramiro/web/prueba.php
	
Se escribe le siguiente codigo:

	<?php
	echo 'Probando PHP!!!'
	?>


Se escribe en el explorador: [http://192.168.5.145/prueba.php](http://192.168.5.145/prueba.php)

Si muestra ***Probando PHP!!!***, esta ok

**4.4-** Configurar mysql:

en  /etc/mysql/my.cnf se busca **bind-address = 127.0.0.1**  y se cambia por **bind-address = 192.168.5.145**


4.5 Se instala proftpd

apt-get install proftpd  -> independiente   

en /etc/proftpd/proftpd.conf se escribe al final **DefaultRoot ~ **

sudo /etc/init.d/proftpd restart

##Configuración de SQL SERVER para que pueda ser accesado desde el servidor.


##Instalacion y configuración de freetds para que se pueda accesar sql server con php.
