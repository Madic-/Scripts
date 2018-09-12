# Java KeyStore Importer / Exporter
This script will either extract all certificates from a java keystore to the folder ./cacerts_export or import all certificates from the folder ./cacerts_export into the supplied keystore.

## Usage

Import
```
cacerts_build.sh IMPORT ./cacerts
```

Export
```
cacerts_build.sh EXPORT ./cacerts
```

## Variables

Name | Value
---|---
DEST | ./cacerts_export
STOREPASS | changeit
KEYSTORE | Provided via command line