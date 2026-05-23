# 🚀 Phase 3: The "Digital Bureaucracy Killer" (Document Management & APIA Integration)

Welcome to Phase 3 of the Digitalization Hackathon! Now that the core architecture is stable, this phase focuses on the absolute most valuable feature for farmers and civil servants: **eliminating paperwork**. 

We need to manage digital animal passports, veterinary health certificates, and APIA (Agenția de Plăți și Intervenție pentru Agricultură) funding eligibility based on those documents.

Here is the strategic breakdown for a team of 4 developers to build a winning, cohesive feature set:

---

## 📱 Developer 1: Frontend (Farmer App) - The Digital Wallet
**Focus:** Building a seamless, user-friendly mobile/web interface for farmers to digitize their physical documents and track their animals.

*   `[ ]` **Animal Digital Wallet UI:** Create a "Document Vault" page for each animal. Farmers should be able to upload pictures/PDFs of:
    *   *Animal Passport (Pașaportul animalului)*
    *   *Movement Documents (Formular de mișcare)*
*   `[ ]` **APIA Readiness Checker:** Build a visual progress bar or checklist for each animal showing if it is "APIA Ready". (e.g., Red "Missing Passport", Green "Ready for Subsidy").
*   `[ ]` **Status Timeline View:** Create a beautiful timeline/stepper UI for an animal's life cycle (e.g., Registered ➔ Vaccinated ➔ Quarantined ➔ APIA Approved).
*   `[ ]` **Offline-First Mode (Bonus):** Use local caching (like Hive or sqflite) so farmers can view their animal statuses even when they are out in the field without internet.

---

## 🖥️ Developer 2: Frontend (Admin & Vet Dashboard) - Validation & Subsidies
**Focus:** Creating powerful, data-dense interfaces for civil servants (APIA) and Veterinarians to process the data the farmers upload.

*   `[ ]` **APIA Subsidy Dashboard:** Create a grid/table view for Civil Servants to review "Pending Subsidy Applications". It should display the farmer's details alongside clickable links to view the uploaded animal passports.
*   `[ ]` **Veterinary Health Portal:** Create a UI for Vets to upload official *Health Certificates (Certificat Sanitar-Veterinar)* directly to an animal's profile.
*   `[ ]` **One-Click Status Overrides:** Give Vets a prominent button to instantly change an animal's status across the whole system (e.g., "Mark as Quarantined" or "Declare Deceased"). This should instantly lock the animal out of APIA subsidies.
*   `[ ]` **PDF Report Generator (Frontend):** Allow the Admin to export a generated "Official Farm Status Report" (using a library like `pdf` or `printing` in Flutter/React) to hand to physical auditors.

---

## ⚙️ Developer 3: Backend Core - Storage & APIA Rules Engine
**Focus:** Handling multipart file uploads, linking documents to database entities, and enforcing strict bureaucratic rules.

*   `[ ]` **Document Storage API:** Implement `DocumentController` with endpoints to `POST` (upload) and `GET` (download/view) files. Store the actual files in a local directory (e.g., `/uploads`) and save the file path/metadata in a new `Document` SQL table linked to the `Animal` entity.
*   `[ ]` **The APIA Eligibility Engine:** Write a service layer method that evaluates an animal for subsidies. 
    *   *Rule 1:* Animal must have an uploaded "Passport".
    *   *Rule 2:* Animal must have a "Health Certificate" less than 6 months old.
    *   *Rule 3:* Animal status must NOT be "SICK" or "QUARANTINED".
*   `[ ]` **Strict State Machine:** Refactor the `Animal` model to use a strict Enum for statuses (`REGISTERED`, `HEALTHY`, `SICK`, `QUARANTINED`, `SOLD`, `DECEASED`). Prevent illegal state changes (e.g., a `DECEASED` animal cannot become `HEALTHY`).
*   `[ ]` **Audit Logging for Documents:** Ensure that every time a document is uploaded, verified, or rejected, it writes an immutable cryptographic log to the `AuditLog` table.

---

## 🤖 Developer 4: Backend AI & Integrations - The "Wow" Factor
**Focus:** Adding advanced tech integrations that will blow the judges away and prove this is a next-generation platform.

*   `[ ]` **OCR Ear-Tag Extraction (AI):** When a farmer uploads an Animal Passport photo to the `/api/documents/upload` endpoint, integrate an OCR library (like Tesseract OR mock a call to Google Vision API). Auto-extract the Ear Tag number (e.g., *RO123456789*) from the image and compare it to the database to prevent manual entry typos.
*   `[ ]` **Automated Expiry Cron Jobs:** Write a Spring `@Scheduled` job that runs every night at 2:00 AM. It should scan the database for Health Certificates expiring in the next 30 days and flag the animals as `VET_VISIT_REQUIRED`.
*   `[ ]` **Mock SMS/Email Alerts:** Integrate a mock notification service (or free SendGrid/Twilio tier). When the Cron Job flags an animal, or when APIA approves a subsidy, fire an email/SMS directly to the Farmer's registered contact info.
*   `[ ]` **Document Backup Strategy:** Update the `docker-compose.yml` to automatically back up the `/uploads` directory to a compressed tarball, just like the database backup, ensuring no farmer documents are ever lost to hardware failure.
