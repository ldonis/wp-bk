![LesliTech logo](https://cdn.lesli.tech/assets/logos/LesliTech/LesliTech-logo-noborder-200.png "LesliTech logo")

### Script to create backup of WordPress websites  
---

Version 1.0.0 alpha

#### Installation
--------
* Clone the repo: `git clone https://github.com/ldonis/wp-bk.git`.
* Add exec privileges to sh files chmod +x wp-bk.sh  
* Add a cron job to run the backups every time you want a backup of your website  
* 0 1 * * 3,5 /var/www/wp-backup/wp-bk.sh  


#### Features
--------
* Automatic backup of WordPress core  
* Automatic backup of uploads folder
* Automatic backup of installed themes
* Automatic backup of apache settings
* Send backups to amazon S3 instance


#### Website & documentation
--------

WP-BK is completely free and open source

* Issue tracker: [https://github.com/ldonis/wp-bk/issues](https://github.com/ldonis/wp-bk/issues)


#### License
--------

Software desarrollado en [Guatemala](http://visitguatemala.com/) distribuido bajo *Licencia Publica General v 3.0* (*General Public License GPLv3*)  puedes leer la licencia completa [aqui](http://www.gnu.org/licenses/gpl-3.0.html)
