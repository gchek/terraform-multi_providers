#cloud-config

packages:
  - httpd
  - mysql-client
  - libmysqlclient-dev
  - mysql-server
  - nmap

package-update: true
package_upgrade: all

runcmd:
 - service httpd start
 - chkconfig httpd on
 - echo "<html><h1>Hello This is WebServer 1</h1></html>" > /var/www/html/index.html
