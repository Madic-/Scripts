# Backupmysql

Does a MySQL Backup, writes logs and optionally sends an e-mail on error. On debian the script can use the credentials from the debian-sys-maint user so you can put the script in a cronjob and forget about it. If you don't want to use the debian-sys-maint user modify the MUSER and MPASS variables.

## Important Variables

* STORAGEDIR = Folder where the script stores your backup.
* LOGDIR = Folder where the script stores the logfiles
* IGNOREDB = List of Databases to ignore.
* ROTATION = Number of days the backup should rotate. Default is 7.
* MUSER = MySQL Username
* MPASS = MySQL Password
* SENMAIL = Set to 1 to send an e-mail on error
* MAILREC = Mail recipient who should get the notification e-mail

## Example cron

Create a full backup every day at 2am

```
0 2 * * * root /usr/local/sbin/backupmysql
```

Written by [webstylr](http://www.webstylr.com/2012/09/10/simples-shellscript-fr-mysql-backup/)

Extended by Madic- - madic@geekbundle.org
