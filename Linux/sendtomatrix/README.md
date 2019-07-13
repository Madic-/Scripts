# sendtomatrix

Linux shell script to send a (multiline) message to a [matrix room](https://matrix.org) hosted on a [synapse server](https://github.com/matrix-org/synapse).

## Usage

This script expects data to be piped in on STDIN.

```bash
COMMAND | sendtomatrix [OPTION]
```

## Options

* -u Matrix User Name
* -p Matrix User Password
* -s Matrix Server FQDN
* -r Matrix RoomID
* -f Optional configuration file
* -h Show help message

### Examples

```bash
echo "Testmessage 1" | sendtomatrix -f /etc/sendtomatrix.conf
echo "Testmessage 2" | sendtomatrix -f /etc/sendtomatrix.conf -r "\!QtykxKocfZaZOUrTwp:matrix.org"
```

Please keep an eye on the format of the RoomID!

## Configuration file

The configuration file can contain the following values.

```bash
MATRIX_USER=TestUser
MATRIX_PASS=TestPassword
MATRIX_SERVER=matrix.org
# RoomID from the #matrix:matrix.org Channel
MATRIX_ROOM_ID="!QtykxKocfZaZOUrTwp:matrix.org"
```

These values can be overriden by command line parameters.

## Cron Job

It's also possible to use this script to send the output of a cronjob to a matrix room.

Example:

```bash
0 4 * * * root /usr/local/sbin/random_script | sendtomatrix -f /etc/sendtomatrix.conf
```
