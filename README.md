# Nexus Commerce Cloud — Design 01: Electric Cyber-Pop & Obsidian Glass

Nexus Commerce Cloud Design 01 is a Java/Spring Boot + PostgreSQL commerce MVP with an Electric Cyber-Pop / Obsidian Glass storefront inspired by the first concept in the supplied UI reference. It brings a Flash quick-commerce lane for grocery/daily essentials together with a Mega Mall lane for standard warehouse items, a local wishlist, mixed-source cart checkout, product administration, inventory, optional Razorpay Checkout integration, delivery-partner management with opt-in browser GPS, toast alerts and customer feedback/support records. The package also documents a future microservices target architecture.

> **Scope and safety:** this is a runnable **modular-monolith development MVP**, not a production-complete deployment of every microservice in the blueprint. The local code includes database-backed registration/login, JWT authentication, role-based endpoint rules, BCrypt password hashing, product image upload, catalog, inventory, demo checkout/payment, delivery assignment workflows, and feedback/support records. Keycloak/OIDC integration, verified production operations, Kafka workflows, Redis/PostGIS/OpenSearch, native/background mobile GPS, route-based ETA, live email/SMS/push delivery, Kubernetes deployment, and separately deployable microservices remain **architecture targets**. Optional Razorpay code is included but is disabled by default and must be configured and tested with provider test credentials before any live mode is considered. The JWT secret and demo accounts are development-only; rotate secrets, harden access controls, and complete security testing before any public deployment. Never use live payment details in local development; begin with provider test credentials only.

## The product experience you asked for

- **Design 01 storefront:** obsidian-dark surfaces, violet lighting, neon-mint Flash accents, warm-gold Mega Mall accents, photo-led product cards, responsive layout, wishlist controls, split sourcing cues, animated details, focus states, drawers and toast alerts.
- **Customer storefront:** department navigation, product search, image-first cards, current/compare-at price, discount display, detail view, locally persisted wishlist, cart, checkout and Flash/Mega Mall/combined shopping modes.
- **Product admin / seller workspace:** create, edit and deactivate products; SKU, name, brand, category, department/type, price, compare-at price, short/full description, featured setting, image upload or image URL, image preview, and initial inventory location/quantity. A successfully published active product is loaded from the backend and appears in the storefront.
- **Image upload:** upload JPEG, PNG or WebP, up to 8 MB; files are stored under the local `uploads/products` directory and served from `/media/products/...`. This is a development storage strategy; replace it with S3/MinIO + image processing + CDN for production.
- **Operations dashboard:** inspect orders, inventory, stores, delivery partners and delivery assignments; register a delivery partner, verify partners, assign eligible orders, and progress through offered/accepted/picked-up/delivered states.
- **Partner GPS:** a verified partner can explicitly start browser geolocation sharing from the Rider Portal. The browser shows a location-permission prompt, then the page sends the latest latitude/longitude to the backend approximately every 12 seconds while the page session is active. The customer order-tracking modal polls the assignment endpoint about every 12 seconds and can show the latest saved coordinate on an OpenStreetMap embed. Browser GPS requires user consent and localhost/HTTPS, needs a network connection for map tiles, and is not guaranteed background tracking; native mobile tracking, routing and ETA calculation are future work.
- **Feedback & help:** submit product, delivery, store, general, complaint or support feedback, optionally link to a product/order, and view/update feedback ticket status.
- **Payment options:** checkout presents UPI, card, net banking, wallet and cash on delivery. The default local mode uses a success/failure simulator. An optional server-side Razorpay Orders/Checkout integration, signature verification, provider-side payment/order/amount/currency/captured-status checks, signed `payment.captured` webhook validation, and gateway refund request path are included. The integration is disabled by default, has not been verified with your credentials here, and requires your Razorpay test keys and an end-to-end test before any live use. Never place gateway secrets in frontend variables or source control. COD remains a local workflow.
- **Popup alerts:** in-app toast alerts appear for success/error/state changes and auto-dismiss. Email, SMS and push delivery are not configured; notification database records and architecture are included.
- **Backend APIs:** product, store, inventory, customer, cart, checkout, orders, simulated payment/refund, delivery partner/assignment, reviews, feedback and notifications.
- **Demo data:** migrations seed products, a dark store, a warehouse, stock, a demo customer and a demo rider. Product sample images are external Unsplash URLs; newly uploaded product images are served locally.

## Technology stack

### Runnable now in the local MVP
- Java 25
- Spring Boot 4.1.1, Spring MVC, Spring Data JPA, Hibernate
- PostgreSQL 17
- Flyway database migrations
- Jakarta Bean Validation
- Spring Boot Actuator
- React 19 + TypeScript + Vite 8 + CSS
- Maven, Eclipse/Spring Tools, Postman
- Optional Docker and Docker Compose

### Target architecture documented for later phases
- Next.js + React + TypeScript + Tailwind CSS + shadcn/ui
- Keycloak + OpenID Connect/OAuth 2.0 + Spring Security
- Spring Cloud Gateway, OpenFeign, Resilience4j
- Kafka, transactional outbox and idempotent consumers
- Redis, PostGIS, OpenSearch, S3-compatible object storage and CDN
- JUnit, Mockito, Testcontainers, Playwright
- GitHub Actions, OpenTelemetry, Prometheus, Grafana and container orchestration

## Folder map

```text
Nexus-Commerce-Cloud-Design-01/
├── pom.xml
├── Dockerfile
├── docker-compose.yml
├── database/create_database.sql
├── frontend/                        # React + TypeScript customer/ops MVP
├── uploads/products/                # local uploads created at runtime; do not commit
├── src/main/java/com/nexus/commerce/
│   ├── controller/                  # REST controllers
│   ├── dto/                         # request/response shapes and validation
│   ├── entity/                      # JPA entities
│   ├── repository/                  # database access
│   ├── service/                     # checkout workflow
│   ├── media/                       # local product-image storage and endpoint
│   ├── config/                      # CORS and local media serving
│   └── exception/                   # consistent API errors
├── src/main/resources/db/migration/ # Flyway V1–V8
├── src/test/                        # backend test starting point
├── architecture/                    # microservices, security and system design
├── services/                        # future service boundaries/contracts
├── docs/                             # API, DB, product UX and test guides
├── scripts/                          # Windows environment/smoke checks
└── .github/workflows/ci.yml          # CI template
```

## Windows setup: Eclipse + existing PostgreSQL

### 1. Extract into a new folder

Extract the ZIP. In Eclipse choose **File → Import → Maven → Existing Maven Projects** and select this folder (the one containing `pom.xml`). Import this as a separate project from the earlier `Nexus-Commerce-Cloud-Complete` project. Stop the old Spring Boot process first so only one server uses port 8080.

### 2. Configure PostgreSQL

Open `src/main/resources/application.properties`. Set the database URL to your existing database if you want to continue with it, and set the password to your real PostgreSQL password:

```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/nexus_commerce_cloud_clean
spring.datasource.username=postgres
spring.datasource.password=YOUR_ACTUAL_POSTGRES_PASSWORD
spring.jpa.hibernate.ddl-auto=validate
spring.flyway.enabled=true
```

Do not use the text `YOUR_ACTUAL_POSTGRES_PASSWORD` literally. Do not commit your real password to GitHub. Environment variables (`DB_URL`, `DB_USERNAME`, `DB_PASSWORD`) override the defaults.

**Database migration note:** migrations V1–V6 are retained from the base Glass Edition. Migrations V7 and V8 extend the existing schema to accept `SPLIT` fulfillment and add optional payment-provider fields. If your current `nexus_commerce_cloud_clean` database already reached V6, Flyway should apply V7 and V8 only. Keep the database and existing data; do not drop it. If Flyway reports a checksum mismatch, stop and resolve the exact reported migration rather than deleting migration history.

### 3. Update Maven and run the backend

1. Right-click project → **Maven → Update Project**.
2. Use a compatible JDK 25 installation in Eclipse for this project's configured Java target.
3. Run `NexusCommerceCloudApplication.java` → **Run As → Spring Boot App**.
4. Confirm that Flyway validates/applies migrations, the JPA EntityManagerFactory initializes, and the console reports Tomcat started on port 8080.

Test these URLs:

- `http://localhost:8080/api/v1`
- `http://localhost:8080/actuator/health`
- `http://localhost:8080/api/v1/products?size=20`
- `http://localhost:8080/api/v1/stores`

The product repository in this release normalizes absent `search` and `category` parameters into empty Java strings before executing the query, avoiding the earlier `trim(bytea)` PostgreSQL failure.

### 4. Start the frontend

**Easy option:** double-click `START-FRONTEND.cmd` in the root of the extracted project. It navigates into the correct frontend folder, installs dependencies on the first run, and starts Vite.

**Manual option:** open a second PowerShell window and run the commands below. If you extracted somewhere else, update the path:

```powershell
cd "$HOME\Downloads\Nexus-Commerce-Cloud-Design-01\frontend"
npm.cmd install
npm.cmd run dev
```

Use `npm.cmd` in Windows PowerShell if the execution policy blocks `npm.ps1`. Open `http://localhost:5173/`. Keep this PowerShell window and Eclipse backend running while you use the UI.

### 5. Publish a product with an image

1. Open the storefront at `http://localhost:5173/`.
2. Select **Product admin** in the header.
3. Select **Add new product**.
4. Enter SKU, product name, brand, category/type, description, selling price and optional compare-at price.
5. Upload a JPEG/PNG/WebP image or use an image URL; review the preview.
6. Select an initial inventory location and set starting stock if appropriate.
7. Select **Publish product**.
8. Return to the storefront or refresh it. The app reloads the active catalog from the backend; the new product should appear with its image.

If it does not appear, check the toast message, browser DevTools Network tab, Spring Boot console, and whether initial stock failed separately. Product publishing and initial stock creation are separate backend operations.

### 6. Try checkout

The cart is stored in the browser until checkout, then the UI builds server-side cart lines from available stock and submits checkout. Choose **Smart split** for one checkout containing grocery items sourced from available dark-store stock and other items sourced from available warehouse stock. The backend still validates availability and creates order lines against their chosen locations; if any required source has no sufficient stock, checkout is rejected rather than silently using the wrong source. This release creates one parent order and delivery assignment; independent shipment groups, separate delivery timelines and split tracking are future work. By default online payment is simulated. For optional Razorpay test checkout, follow the separate setup below; do not switch to live keys until test payments, cancellations, reconciliation and refunds have been verified.

### 7.1 Optional Razorpay test integration (disabled by default)

The included gateway integration is opt-in. Start with Razorpay test-mode credentials only. You must configure the Spring Boot process (not just the React app) with:

```text
RAZORPAY_ENABLED=true
RAZORPAY_KEY_ID=rzp_test_...
RAZORPAY_KEY_SECRET=...
RAZORPAY_WEBHOOK_SECRET=...
RAZORPAY_API_BASE_URL=https://api.razorpay.com/v1
```

For an Eclipse launch, open **Run Configurations → Environment** and add these variables there. Alternatively, for Docker Compose, copy the root `.env.example` to `.env` and fill the test credentials there; Compose passes them only to the backend container. Never commit `.env` or share the key secret. The frontend only needs `VITE_PAYMENT_MODE=RAZORPAY` in `frontend/.env` (copy from `frontend/.env.example`) plus `VITE_API_URL=http://localhost:8080/api/v1`. Restart both backend and Vite after changing variables.

When enabled, the backend creates a provider order, and the frontend opens Razorpay's hosted Checkout. The backend verifies the returned HMAC, fetches the payment from Razorpay and checks order reference, paise amount, INR currency and captured status before confirming the order. The webhook endpoint is `POST /api/v1/payments/razorpay/webhook`; configure the webhook secret separately in the Razorpay dashboard and subscribe to `payment.captured`. A provider cannot reach `localhost` directly, so testing webhooks from your own machine requires a secure HTTPS development tunnel or a reachable test deployment. Keep the gateway disabled until you have tested payment success, failure/dismissal, duplicate callbacks, refund behavior and stock release with test credentials. The optional code has not been run against your provider account in this build environment.

**Do not set live credentials to test the project.** A successful local build does not mean payment processing has been certified for production. Live payments require provider account approval, public HTTPS, webhook operations, reconciliation, refund lifecycle verification and a security/compliance review.

### 7. Delivery and feedback

Go to **Delivery operations** to register a partner, view demo orders and assignments, assign an eligible confirmed/ready order, and advance assignment status through the allowed transitions. Go to **Feedback & help** to submit a feedback or complaint and inspect/update support status.

### 8. Optional Docker Compose

Docker is optional when using the locally installed PostgreSQL server. If using the supplied Compose configuration instead, it creates a separate PostgreSQL container on host port `5433` and an API container on `8080`; data is kept in a Docker volume. Review `.env`/`POSTGRES_PASSWORD` before using it.

## Local demo accounts

The application seeds these local-only accounts on startup. Use them only on your own development machine and change/remove them before any public deployment. Passwords are hashed with BCrypt in the database; these are convenience demo credentials, not production secrets.

| Role | Email | Local demo password |
|---|---|---|
| Platform admin | `admin@nexus.local` | `NexusAdmin!2026` |
| Catalog manager | `catalog@nexus.local` | `NexusCatalog!2026` |
| Inventory manager | `inventory@nexus.local` | `NexusInventory!2026` |
| Dispatch manager | `dispatch@nexus.local` | `NexusDispatch!2026` |
| Support agent | `support@nexus.local` | `NexusSupport!2026` |
| Finance operator | `finance@nexus.local` | `NexusFinance!2026` |
| Customer | `seeded.customer@nexus.local` | `NexusCustomer!2026` |
| Verified demo rider | `rider@nexus.local` | `NexusRider!2026` |

## API map

Base URL: `http://localhost:8080/api/v1`

| Domain | Endpoint examples |
|---|---|
| Catalog | `GET /products?size=20`, `GET /products/{id}`, `POST /products`, `PUT /products/{id}`, `DELETE /products/{id}` |
| Product media | `POST /media/products` with multipart field `file` |
| Stores | `GET /stores`, `POST /stores` |
| Inventory | `GET /inventory`, `GET /inventory/store/{storeId}`, `POST /inventory`, `PATCH /inventory/{id}/quantity?quantity=...` |
| Customers | `GET /customers`, `POST /customers`, `GET /customers/{id}` |
| Cart | `GET /cart/{customerId}`, `POST /cart/{customerId}/items`, delete line/cart endpoints |
| Checkout/orders | `POST /checkout/{customerId}`, `GET /orders`, `GET /orders/{id}`, `GET /orders/{id}/items` |
| Payments | `GET /payments/order/{id}`, `POST /payments/order/{id}/simulate`, `POST /payments/order/{id}/razorpay-order`, `POST /payments/order/{id}/verify-razorpay`, `POST /payments/order/{id}/cancel`, `POST /payments/order/{id}/refund`, `POST /payments/razorpay/webhook` |
| Delivery | `/delivery-partners`, `/delivery-assignments` |
| Reviews/feedback | `/reviews`, `/feedback`, `PATCH /feedback/{id}/status?value=IN_PROGRESS` |
| Notifications | `/notifications/customer/{id}`, `PATCH /notifications/{id}/read` |

Import `docs/postman/Nexus-Commerce-Cloud.postman_collection.json` into Postman. Use actual IDs returned by the API when testing.

## Architecture and scope status

Read these first:
- `docs/REAL_WORLD_FEATURES_GPS_PAYMENTS_ALERTS.md` — payment sandbox, browser GPS consent, live tracking refresh and alert boundaries.
- `architecture/MICROSERVICES_BLUEPRINT.md` — service boundaries, databases, APIs and event design.
- `architecture/SECURITY_MODEL.md` — identity, roles, ownership checks and security requirements.
- `docs/DETAILED_SYSTEM_ARCHITECTURE.md` — end-to-end diagrams, service contracts, flows and evolution plan.
- `docs/PRODUCT_ADMIN_AND_STOREFRONT.md` — product editor, image lifecycle and customer storefront behavior.
- `docs/FEATURE_MATRIX.md` — distinguishes implemented, partial and planned features.
- `docs/DATABASE_DESIGN.md` — tables, relationships, constraints and scale notes.

## Limitations / safety

- Local JWT authentication and role-based endpoint rules are implemented, but they are not a substitute for production security review. Rotate the default JWT secret, remove seeded demo accounts, add rate limiting, review ownership checks, configure HTTPS/secure deployment secrets, and run security testing before public deployment.
- The local simulator remains the default payment mode. Optional Razorpay API/Checkout endpoints are included, but gateway test runs must be completed with your own Razorpay test account before the integration can be considered verified. Webhook-based reconciliation, refund lifecycle processing and production settlement reconciliation need further hardening.
- Local image upload is development-only; it is not a hardened public upload service or object-storage pipeline.
- The target microservices stack is documented but not all services are separately deployable in this release. Kafka, Redis, OpenSearch, PostGIS, Keycloak, native background GPS, route/ETA services, CDN, real payment provider and production deployment need their own implementation and tests.
- A Maven build and frontend dependency build could not be executed in the artifact creation environment because dependency download was unavailable. Check builds in your Windows environment and share the first compiler/build error if one appears.
