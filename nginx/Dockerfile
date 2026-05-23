FROM nginx:alpine

# Install OpenSSL for certificate generation
RUN apk add --no-cache openssl

# Copy config and cert generation script
COPY nginx.conf /etc/nginx/nginx.conf
COPY generate-certs.sh /docker-entrypoint.d/00-generate-certs.sh
RUN chmod +x /docker-entrypoint.d/00-generate-certs.sh

EXPOSE 80 443
