#!/bin/bash
#
# WP-BK ~ Script to create backup of WordPress websites
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
# 
# Author   Luis Gdonis <emc2@ldonis.com>
# License  GPLv3 http://www.gnu.org/licenses/gpl-3.0.en.html
# Version  GIT: 1.0.0 alpha
# Link     https://www.ldonis.com
#
# -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-
#
# Shell script for automatic backup process of WordPress
# STEPS
#       Set up  variables
#       MySQL dump backup
#       WordPress backup
#       GZip backups
#       Delete temp backup folders
#       Send to AWS
#       Create log
#
# Installation:
#   Clone the repo: `git clone https://github.com/ldonis/wp-bk.git`.
#   Add exec privileges to sh files chmod +x wp-bk.sh  
#   Add a cron job to run the backups every time you want a backup of your website  
#   0 1 * * 3,5 /var/www/wp-backup/wp-bk.sh  

# Setting up  variables
# -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-


# // Global information
CurrentDate=`date +"%Y%m%d"`
BackupPathRoot="/var/www/wp-bk/backups/"
BackupPath=${BackupPathRoot}${CurrentDate}"/"
BackupFolder="BK-"${CurrentDate}


# // MySQL information
MySQLBKName="DataBase.sql"
MySQLSERVER=127.0.0.1
MySQLDATA=database_name
MySQLUSER=database_user
MySQLPASS=database_password


# // WordPress Theme information
WPPath="/var/www/wordpress/"


# Create folder structure
# -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-
function create_folders(){

	mkdir -p ${BackupPath}

}

# Create folder structure - end
# -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-
# -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-


# MySQL dump
# -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-
function data_export(){

    # Export database
    # si el password tiene algun caracter del shell se debe escapar
    # ej "Pssword$password" = "Pssword\$password"

    mkdir -p ${BackupPath}"DATA/"
    mysqldump --opt --user=${MySQLUSER} --password=${MySQLPASS} ${MySQLDATA} > ${BackupPath}"DATA/"${MySQLBKName}

}

# MySQL dump - end
# -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-
# -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-



# WordPress backup
# -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-
function wordpress_backup(){

    _fr=${WPPath}
    _to=${BackupPath}"WP"

    mkdir -p ${_to}
    rsync -avz --exclude '*git*' ${_fr} ${_to}

}

# WordPress backup - end
# -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-
# -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-


# GZip backups
# -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-
function compress_folders(){

    # Folders to zip
    for folder in "DATABASE" "WP"
    do
        # Compressing folders
       	tar -zcvf ${BackupPath}${folder}".tar.gz" ${BackupPath}${folder}
        rm -rf ${BackupPath}${folder}

    done

}

# GZip backups - end
# -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-
# -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-



# Send backup to amazon
# -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-
function sendto_aws(){

    aws s3 cp ${BackupPath} s3://my-sss-instance/${BackupFolder} --recursive
    
}

# Send backup to amazon - end
# -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-
# -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-



# Delete backups folders
# -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-
function delete_temp(){

    rm -rf ${BackupPath}

}

# Delete backups folders - end
# -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-
# -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-



# Creating log file
# -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-
function log_file(){
    
    backupSize=`du -hs "${BackupPath}"`
    echo "Backup " ${CurrentDate} " - " ${backupSize} " completed." >> ${BackupPathRoot}${WebsiteName}"/history.log"

}

# Creating log file - end
# -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-
# -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-



# Executing functions
# -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-
create_folders
data_export
wordpress_backup
compress_folders
delete_temp
sendto_aws
log_file

# Executing functions - end
# -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-
# -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-  -·-


# End of process
