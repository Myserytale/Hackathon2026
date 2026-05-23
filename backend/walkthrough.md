# Farm Animal Management Backend Walkthrough

The backend for the **Digitalize Romania - Farm Animal Management** hackathon project is now fully set up. We've built a solid foundation using Java 21 and Spring Boot, focusing on a clean RESTful API to satisfy the core requirements identified on the whiteboard.

## Architecture & Tech Stack

- **Framework:** Spring Boot 3.x (Java 21)
- **Database:** H2 In-Memory Database (No setup required, perfect for hackathon speed).
- **API Documentation:** Swagger / OpenAPI via `springdoc-openapi`.
- **Build Tool:** Maven.

## Implemented Features

I've translated the whiteboard requirements into the following domain entities, each complete with a Spring Data JPA Repository and a REST Controller for CRUD operations:

1. **`Animal` (Health status for animals):** 
   - Manage animal details, including species, breed, birth date, and overall `healthStatus`.
2. **`Document` (Digital docs. for each animal):**
   - Attach digital documents like passports or vaccination records to an `animalId`.
3. **`FundingApplication` (Ways to apply for government funding):**
   - Submit and track the `status` (Pending, Approved, Rejected) of subsidy applications for farmers.
4. **`Incident` (Incident alerts):**
   - Log critical events like disease outbreaks or missing animals, optionally tied to specific animals, and track resolution.
5. **`VeterinaryConsultation` (Veterinary help):**
   - Record vet visits, diagnoses, prescriptions, and notes for individual animals.

## How to Run

To start the server locally, open your terminal, navigate to the `backend` directory, and run the Maven wrapper:

```bash
cd /home/lev/UNI/Hackathon2026/backend
./mvnw spring-boot:run
```

## Useful Links & Tools

Once the server is running, you can access the following useful endpoints:

> [!TIP]
> **Swagger UI (Interactive API Documentation)**
> Navigate to [https://localhost/api/swagger-ui.html](https://localhost/api/swagger-ui.html) in your browser. This will give you an interface to test all the API endpoints (create animals, upload documents, log incidents) without writing a frontend or using Postman.

> [!NOTE]
> **H2 Database Console**
> Navigate to [https://localhost/api/h2-console](https://localhost/api/h2-console).
> - **JDBC URL:** `jdbc:h2:mem:farmdb`
> - **Username:** `sa`
> - **Password:** *(leave blank)*
> This allows you to inspect the raw database tables.
