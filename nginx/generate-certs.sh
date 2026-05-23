#!/bin/sh
set -e

CERT_DIR="/etc/nginx/certs"
mkdir -p "${CERT_DIR}"

# Generate self-signed certificate valid for 365 days
openssl req -x509 -nodes \
  -days 365 \
  -newkey rsa:2048 \
  -keyout "${CERT_DIR}/server.key" \
  -out "${CERT_DIR}/server.crt" \
  -subj "/C=RO/ST=Bucharest/L=Bucharest/O=DigitalRomania/OU=Farm/CN=localhost" \
  -addext "subjectAltName=DNS:localhost,DNS:farm.local,IP:127.0.0.1"

echo "Self-signed certificates generated in ${CERT_DIR}"
