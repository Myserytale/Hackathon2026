FROM nginx:alpine

# Install OpenSSL for certificate generation
RUN apk add --no-cache openssl

# Copy config and cert generation script
COPY nginx.conf /etc/nginx/nginx.conf
COPY html /usr/share/nginx/html
COPY generate-certs.sh /docker-entrypoint.d/00-generate-certs.sh
RUN sed -i 's/\r$//' /docker-entrypoint.d/00-generate-certs.sh && chmod +x /docker-entrypoint.d/00-generate-certs.sh

EXPOSE 80 443
