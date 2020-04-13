#! /bin/bash
#### Description: Does a Postgres SQL Backup, writes logs and optionally sends an e-mail on error
####
#### Important Parameters:
#### USER = The User who should create the backups and has access to the database (default is postgres)
#### SENDMAIL = Set to 1 to send an e-mail on error
#### BASE_DIR = Folder where the script stores your backup
#### LOGDIR = Folder where the script stores the logfiles
#### MAILREC = Mail recipient who should get the notification e-mail
#### ROTATION = Number of days the backup should rotate (default is 7)
####
#### Written by Craig Sanders (https://github.com/ulmen/backup_postgresql/blob/master/backup-postgresql.sh)
#### this script is public domain.  feel free to use or modify as you like.
#### Modified by Madic - madic@geekbundle.org

USER=postgres
DUMPALL="sudo -u $USER $(which pg_dumpall)"
PGDUMP="sudo -u $USER $(which pg_dump)"
PSQL="sudo -u $USER $(which psql)"

SENDMAIL="0"
MAILREC="madic@geekbundle.org"
MACHINE=$(hostname)@$(hostname -d)
FQDN=$(hostname -f)

# directory to save backups in, must be rwx by postgres user
YMD=$(date "+%Y-%m-%d")
BASE_DIR="/srv/backup/postgres"
LOGDIR="/var/log/backup/"
DIR="$BASE_DIR/$YMD"
LOG="$LOGDIR/$YMD-psql-backup.log"
ROTATION=7 # Number of days the backup should rotate. Default is 7

DIRS="$LOGDIR $DIR"
set -- $DIRS
for i in "$@"; do
	if [ ! -d "$i" ]; then mkdir -p "$i"; fi
	if [ ! "$?" = "0" ]; then echo "Error: Couldn't create folder $i. Check folder permissions and/or disk quota!" >>"/tmp/$YMD-psql-backup.log"; fi
done

# Write to $LOGDIR
exec &>"$LOG"

# get list of databases in system , exclude the template dbs
DBS=$($PSQL -l -t | egrep -v 'template[01]' | awk '{print $1}' | grep -v "|")

# next dump globals (roles and tablespaces) only
echo -e "Info: Backing up globals"
$DUMPALL -g >"$DIR/globals.sql"
if [ "$?" = "0" ]; then
	echo "Info: Globals backed up successful to $DIR/globals.sql."
else
	echo "Error: Couldn't backup globals to $DIR/globals.sql. Maybe check file or database permissions"
fi

# now loop through each individual database and backup the schema and data separately
for database in $DBS; do
	DATA=$DIR/$database.dump

	echo -e "\nInfo: Backing up $database"
	$PGDUMP -Fc $database >$DATA
	if [ "$?" = "0" ]; then
		echo "Info: $database backed up successful to $DATA."
	else
		echo "Error: Couldn't backup $database to $DATA. Maybe check file or database permissions"
	fi
done

# delete backup files older than X days
OLD=$(find $BASE_DIR -type d -mtime +$ROTATION)
if [ -n "$OLD" ]; then
	echo "Info: Deleting dirs older than $ROTATION day(s)."
	echo $OLD | xargs rm -rfv
	if [ "$?" = "0" ]; then
		echo "Info: Backup successful. Deleted $OLD."
	else
		DIRLIST=$(ls -lRh "$BASE_DIR")
		echo "Error couldn't delete oldest dir."
		echo "Contents of current Backup at $BASE_DIR:"
		echo " "
		echo $DIRLIST
	fi
fi

if [ "$SENDMAIL" == "1" ]; then
	if grep -q 'Error' "$LOG" || grep -q 'Error' "/tmp/$YMD-pysql-backup.log" &>/dev/null; then
		IFS=
		MESSAGE=$(cat "$LOG" && cat "/tmp/$YMD-psql-backup.log")
		echo $MESSAGE | mail -s "$FQDN - Postgres SQL Backuplog" "$MAILREC"
		#           echo $ MESSAGE | mail -a "From: $MACHINE" -s "$FQDN - Postgres SQL Backuplog" "$MAILREC"
	fi
fi
