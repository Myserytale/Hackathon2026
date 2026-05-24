# 🚀 Hackathon Startup Guide

This guide will walk you through starting the entire infrastructure locally, including the backend API, the 3 Flutter portals, and the Nginx reverse proxy.

## 1. Boot up the infrastructure

Everything is containerized and orchestrated via Docker Compose. Open a terminal in the root of the repository and run:

```bash
docker-compose up -d --build
```

This will build and start:
- PostgreSQL Database (`db`)
- Redis Cache (`redis`)
- Spring Boot Backend (`backend`)
- Farmer Portal Flutter Web App (`farmer-frontend`)
- Vet Portal Flutter Web App (`vet-frontend`)
- Admin/APIA Portal Flutter Web App (`admin-frontend`)
- Nginx Reverse Proxy (`nginx`)

*To view the logs and ensure no errors occurred during startup, run:*
```bash
docker-compose logs -f
```

## 2. Access the Application

We use **HTTPS** for realism and to ensure modern web features (like geolocation or secure cookies) work locally. Because we use a self-signed certificate, your browser will show a warning.

1. Navigate to **https://localhost/** in your browser.
2. You will see "Your connection is not private".
3. Click **Advanced** -> **Proceed to localhost (unsafe)**.

### Portal Links
Once you accept the certificate, you will see the Digital Romania Landing Page. From there, you can navigate to:
- 🚜 **Farmer Portal**: `https://localost/farmer/`
- 🩺 **Veterinary Portal**: `https://localhost/vet/`
- 🏛️ **Admin/APIA Portal**: `https://localhost/admin/`

### Backend API & Monitoring
- **Backend REST API**: `https://localhost/api/`
- **Grafana Dashboards**: `http://localhost:3000` (Default login: `admin` / `admin`)
- **pgAdmin**: `http://localhost:5050` (Default login: `admin@farm.ro` / `admin`)

## 3. Testing the Application Flow

1. **Farmer (Dev 1)**: Go to the Farmer Portal, login with `test_farmer` / `password123`. Look at the backend console for the OTP code, verify it, and then try uploading a Document or starting a Funding Application.
2. **Vet (Dev 2)**: Go to the Vet Portal, locate an animal, and upload a Health Certificate.
3. **Admin (Dev 2)**: Go to the Admin Portal, review the "Pending Subsidies" and check the Immutable Ledger to see all cross-portal actions verified.
