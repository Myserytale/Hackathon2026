# Hackathon Execution Plan: Developer Tasks

This document breaks down the remaining work into distinct, assignable tracks for a **4-person development team**. The goal is to maximize parallel work and ensure a polished, fully functioning prototype for the hackathon presentation.

---

## 👩‍💻 Developer 1: Frontend - Farmer Portal & Accessibility
**Focus:** Building a seamless, highly accessible interface specifically for the `FARMER`.
*   `[ ]` **Frontend Skeleton:** Initialize the frontend app (e.g., Next.js, React, or Vue) with a modern styling library (e.g., Tailwind CSS).
*   `[ ]` **ROeID Login Flow:** Build the UI for the 2-step authentication process (Username/Password screen -> 2FA OTP screen).
*   `[ ]` **Farmer Dashboard ("My Farm"):** Create a view where a farmer can manage their registered animals, view their active incidents, and upload required documents.
*   `[ ]` **Funding Application UI:** Build a wizard-style form for farmers to easily apply for government agricultural subsidies.
*   `[ ]` **Accessibility Audit:** Ensure all forms and tables strictly follow WCAG 2.1 AA standards (ARIA labels, keyboard navigation, high contrast). *This is a major judging criteria.*

---

## 👨‍💻 Developer 2: Frontend - Vet & Admin Dashboards
**Focus:** Building dedicated views for the `VET` and `CIVIL_SERVANT`, and showcasing the ledger to the judges.
*   `[ ]` **Veterinary Dashboard:** Create a view for the `VET` role to log `VeterinaryConsultation`s, issue health certificates, and flag potential biological incidents (disease outbreaks).
*   `[ ]` **Civil Servant Dashboard:** Build UI tables allowing admins (`CIVIL_SERVANT`) to review, approve, or reject pending `FundingApplication` requests.
*   `[ ]` **Ledger / Audit Log Viewer:** Build a specialized "Transparency" page that queries the `AuditLog` endpoint. This must visually highlight the cryptographic hashes to prove data immutability to the judges.
*   `[ ]` **Data Visualization:** Implement simple charts (e.g., using Chart.js or Recharts) showing statistics like "Incidents by Region", "Vaccination Rates", or "Funding Distribution."

---

## 🧑‍💻 Developer 3: Backend Core - Data & Business Logic
**Focus:** Fleshing out the Spring Boot backend, ensuring security tightens, and making the demo look real.
*   `[ ]` **Mock Data Seeding:** Implement a `DataSeeder` (using Spring `@Component` + `@PostConstruct` or Flyway) to automatically populate the database with realistic Romanian farm data, users, and historical audit logs upon startup.
*   `[ ]` **Strict Data Ownership:** Update the Repositories and Controllers so that `FARMER` users can *only* GET/PUT data belonging to their specific `ownerId`/`farmerId`.
*   `[ ]` **Document Upload Handling:** Enhance the `DocumentController` to accept `multipart/form-data` file uploads (storing them locally in a Docker volume or mocking an S3 bucket upload) instead of just accepting URL strings.
*   `[ ]` **Integration Tests:** Write 2-3 automated Spring Boot tests proving the 2FA flow works and the Audit Log catches deletions. Run these during the presentation!

---

## 👨‍🔧 Developer 4: DevOps, Integrations & Polish
**Focus:** Deployment, infrastructure, and making the architecture look enterprise-ready.
*   `[ ]` **2FA Notification Mocking:** Hook up the `AuthController` to a real email sandbox (like Mailtrap) or SMS API (like Twilio trial) so the 2FA code is actually delivered to a phone/email during the live demo, replacing the hardcoded `123456`.
*   `[ ]` **External System Integration (SYSTEM Role):** Create a mock external endpoint (or use a public API) to simulate checking an animal's tag number against a European registry, utilizing the `SYSTEM` role.
*   `[ ]` **Docker Optimization:** Update `docker-compose.yml` to include `pgadmin4` (so judges can look at the raw database easily) and optionally a Redis container for caching to show performance optimization.
*   `[ ]` **Live Deployment:** Set up a CI/CD pipeline or manually deploy the Dockerized backend to a free cloud host (e.g., Render, Railway, Fly.io) so the judges can access the API from their own phones.
