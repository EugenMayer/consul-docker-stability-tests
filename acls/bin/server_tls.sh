#!/bin/sh

set -e

if [ -z "$1" ]; then
    echo "please pass the ip as the first parameter"
    exit 1
fi

ip=$1
# Specify where we will install
# the xip.io certificate
SSL_DIR="/consul/config"

# A blank passphrase
PASSPHRASE=""

# Set our CSR variables
SUBJ="
C=DE
ST=Niedersachsen
O=KontextWork
localityName=Hannover
commonName=$ip
organizationalUnitName=Consul
emailAddress=info@company.tld
"

# Create our SSL directory
# in case it doesn't exist
mkdir -p "$SSL_DIR"

# Generate our Private Key, CSR and Certificate
openssl genrsa -out "$SSL_DIR/tls.key" 2048
openssl req -new -subj "$(echo -n "$SUBJ" | tr "\n" "/")" -key "$SSL_DIR/tls.key" -out "$SSL_DIR/cert.csr" -passin pass:$PASSPHRASE
openssl x509 -req -days 365 -in "$SSL_DIR/cert.csr" -signkey "$SSL_DIR/tls.key" -out "$SSL_DIR/cert.crt"

chown consul:consul $SSL_DIR/tls.key
chmod 400 $SSL_DIR/tls.key
chown consul:consul $SSL_DIR/cert.crt

echo "{\"key_file\":\"/consul/config/tls.key\", \"cert_file\": \"/consul/config/cert.crt\"}" > /consul/config/tls.json