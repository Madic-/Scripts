# Backuppsql

Does a Postgres SQL Backup, writes logs and optionally sends an e-mail on error.

## Important Parameters

* USER = The User who should create the backups and has access to the database (default is postgres)
* SENDMAIL = Set to 1 to send an e-mail on error
* BASE_DIR = Folder where the script stores your backup
* LOGDIR = Folder where the script stores the logfiles
* MAILREC = Mail recipient who should get the notification e-mail
* ROTATION = Number of days the backup should rotate (default is 7)

## Example cron

Create a full backup every day at 2am

```
0 2 * * * root /usr/local/sbin/backupmysql
```

## Restoring backup

Restore needs to be done as user postgres for the following command.

```
su - postgres
psql
create database DATABASE owner OWNER;
\q
pg_restore -d DATABASE -j 4 /opt/backup/postgres/DATABASE.dump
```

Written by [Craig Sanders](https://github.com/ulmen/backup_postgresql/blob/master/backup-postgresql.sh), this script is public domain. Feel free to use or modify as you like.

Modified by Madic - madic@geekbundle.org
