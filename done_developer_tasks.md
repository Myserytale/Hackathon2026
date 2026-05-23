# Completed Hackathon Tasks

This document tracks all the tasks that have been successfully implemented and tested.

## 🧑‍💻 Developer 3: Backend Core - Data & Business Logic
*   `[x]` **Mock Data Seeding:** Implement a `DataSeeder` (using Spring `@Component` + `@PostConstruct` or Flyway) to automatically populate the database with realistic Romanian farm data, users, and historical audit logs upon startup.
*   `[x]` **Strict Data Ownership:** Update the Repositories and Controllers so that `FARMER` users can *only* GET/PUT data belonging to their specific `ownerId`/`farmerId`.
*   `[x]` **Document Upload Handling:** Enhance the `DocumentController` to accept `multipart/form-data` file uploads (storing them locally in a Docker volume or mocking an S3 bucket upload) instead of just accepting URL strings.
*   `[x]` **Integration Tests:** Write 2-3 automated Spring Boot tests proving the 2FA flow works and the Audit Log catches deletions. Run these during the presentation!

## 👨‍🔧 Developer 4: DevOps, Integrations & Polish
*   `[x]` **2FA Notification Mocking:** Hook up the `AuthController` to a real email sandbox (like Mailtrap) or SMS API (like Twilio trial) so the 2FA code is actually delivered to a phone/email during the live demo, replacing the hardcoded `123456`.
*   `[x]` **External System Integration (SYSTEM Role):** Create a mock external endpoint (or use a public API) to simulate checking an animal's tag number against a European registry, utilizing the `SYSTEM` role.
*   `[x]` **Docker Optimization:** Update `docker-compose.yml` to include `pgadmin4` (so judges can look at the raw database easily) and optionally a Redis container for caching to show performance optimization.
*   `[x]` **Live Deployment:** Set up a CI/CD pipeline or manually deploy the Dockerized backend to a free cloud host (e.g., Render, Railway, Fly.io) so the judges can access the API from their own phones.
