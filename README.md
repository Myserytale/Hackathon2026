# Digitalize Romania: Farm Animal Management Backend

This project represents the backend infrastructure for the **Farm Animal Management** system, built for the "Digitalize Romania" hackathon.

Our solution tackles bureaucratic frustrations head-on by building a high-performance, secure, and transparent API.

## Core Technical Solutions & Architecture

### 1. Data Integrity & Immutable Audit Trail (Ledger Simulation)
We've addressed the challenge of data manipulation and accidental deletion by implementing a dual-strategy:
*   **Soft Deletes**: Native entities (like `Animal` or `FundingApplication`) use Hibernate's `@SQLDelete` and `@SQLRestriction` to ensure that standard "DELETE" requests only flip a `deleted = true` flag. No record is ever truly destroyed from the database.
*   **Immutable Audit Log**: We leverage a JPA `@EntityListeners(AuditListener.class)` that acts as a custom Ledger. Every state change (CREATE, UPDATE, DELETE) is intercepted. A cryptographic hash (SHA-256) of the entity's state and timestamp is generated and saved to the `audit_log` table. This simulates a blockchain/distributed ledger, proving that the data sequence has not been tampered with.

### 2. Identity Simulation: "ROeID" & 2FA Flow
We implemented a strict, two-step authentication system mirroring national ID solutions (ROeID):
*   **Step 1:** The user posts their username and password to `/api/auth/login`. Instead of granting full access, the system returns a *temporary JWT* strictly limited to validating the 2FA step.
*   **Step 2:** The user must pass this token along with an OTP (One-Time Password) to `/api/auth/verify-2fa`. Only upon successful validation does the system grant the full Access Token (JWT) with encoded roles. *(For the hackathon demo, the mock OTP is `123456`).*

### 3. Role-Based Access Control (RBAC)
We've built a strict, tiered authorization layer using Spring Security's `@PreAuthorize`:
*   **CITIZEN**: Can view public or personal data but cannot make administrative modifications.
*   **CIVIL_SERVANT**: Has elevated permissions to create records, update statuses, and verify documents.
*   **SYSTEM**: Reserved for external API integrations (e.g., verifying microchip numbers against EU databases).

### 4. High-Performance & Dockerized Deployment
*   The application is fully containerized using **Docker** and **Docker Compose**, running a local **PostgreSQL 15** instance. 
*   This mimics the robust relational data features of platforms like Supabase while ensuring perfect reliability for offline hackathon demos.
*   **Accessibility Ready**: The JSON structures returned by our API are semantically structured, ensuring the frontend team can easily map them to ARIA labels and accessibility standards.

## How to Run

1. Make sure you have Docker and Docker Compose installed.
2. In this directory, run:
   ```bash
   docker-compose up --build
   ```
3. The API will be available at `https://localhost/api/`.
4. Access the **Interactive Swagger UI** at `https://localhost/api/swagger-ui.html`.
