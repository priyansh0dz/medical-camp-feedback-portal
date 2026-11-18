# Medical Camp Feedback Portal

A web application (Java JSP + Servlets + JDBC + MySQL) for collecting and analysing feedback from people who attend
medical camps. Supports **UN Sustainable Development Goal 3 - Good Health and Well-being** by replacing paper forms
and showing organisers which services need improvement.

## Features

**Participants (public)**
- Enter personal details (name, age, gender, phone, optional email), camp name and visit date
- Rate 5 services from 1 to 5 stars: doctor consultation, medicine availability, cleanliness, staff behaviour, waiting time
- Choose a feedback type (Appreciation / Suggestion / Complaint / General) and write comments
- Server-side validation with the form re-filled on errors

**Admin (login required)**
- Dashboard with total responses, overall rating, complaint and suggestion counts
- Average rating per service as bar charts and a 1-5 star distribution
- **Areas needing improvement**: every service averaging below 3.5 is flagged (red below 3.0)
- Search and filter by text, camp, feedback type and rating band; paginated table
- Download the filtered results as CSV (opens in Excel), print view, delete a record

**Security**
- Prepared statements everywhere (no SQL injection), all output escaped with `<c:out>` (no XSS)
- PBKDF2 password hashing, session-fixation protection, login lockout after 5 failures (5 min per IP)
- CSRF tokens on every POST form, `/admin/*` protected by a filter, no-cache headers on admin pages
- CSV export neutralises spreadsheet formula injection

## Tech stack

Java 11+, Servlet 4.0 / JSP 2.3 / JSTL 1.2, JDBC with MySQL Connector/J 8, MySQL 8, Maven, Apache Tomcat 9.

> Tomcat **9** is required (the `javax.*` namespace). Tomcat 10+ uses `jakarta.*` and needs a code migration.

## Project structure

```
medical-camp-feedback-portal/
├── pom.xml
├── sql/schema.sql                      database + tables
└── src/main
    ├── java/com/medcamp
    │   ├── model/    Feedback, Stats
    │   ├── dao/      FeedbackDAO, AdminDAO        (all JDBC code)
    │   ├── servlet/  FeedbackServlet, LoginServlet, DashboardServlet,
    │   │             DeleteServlet, ExportServlet, AppInitListener
    │   ├── filter/   AuthFilter                   (protects /admin/*)
    │   └── util/     DBUtil, PasswordUtil, Csrf, Constants
    ├── resources/db.properties                    DB connection settings
    └── webapp
        ├── index.jsp, error.jsp, css/style.css
        └── WEB-INF/ web.xml, views/ (feedback, thankyou, login, dashboard + header/footer fragments)
```

## Setup

1. **Install** JDK 11+, Maven 3.6+, MySQL 8 and Apache Tomcat 9.
2. **Database** (optional, the app creates the database and tables on first start if they are missing):
   ```bash
   mysql -u root -p < sql/schema.sql
   ```
3. **Configure** `src/main/resources/db.properties` (URL, user, password), or set the environment variables
   `MEDCAMP_DB_URL`, `MEDCAMP_DB_USER`, `MEDCAMP_DB_PASSWORD`.
4. **Build**:
   ```bash
   mvn clean package
   ```
5. **Deploy**: copy `target/medcamp.war` into Tomcat's `webapps/` folder and start Tomcat
   (or in your IDE: add the project to a Tomcat 9 server).
6. **Open** <http://localhost:8080/medcamp/>

| Page | URL |
|------|-----|
| Home | `/medcamp/` |
| Feedback form | `/medcamp/feedback` |
| Admin login | `/medcamp/login` |
| Dashboard | `/medcamp/admin/dashboard` |

**Default admin:** `admin` / `admin123`, created automatically on first startup when no admin exists.
Change it right away, for example:

```sql
-- generate a hash by temporarily changing admin.default.password and wiping the admins table, or
-- add a new admin through a small Java/JShell call to PasswordUtil.hash("your-new-password"), then:
UPDATE admins SET password_hash = '<hash from PasswordUtil.hash>' WHERE username = 'admin';
```

Before going live also serve the site over HTTPS and set a strong `db.password` (use environment variables, not the file).

## Database

- `admins(id, username, password_hash, created_at)`
- `feedback(id, participant_name, age, gender, phone, email, camp_name, visit_date, rating_doctor, rating_medicine,
  rating_cleanliness, rating_staff, rating_waiting, feedback_type, comments, submitted_at)`

## Ideas for extension

Per-camp trend charts, multi-language forms (English / Kannada / Hindi), QR code at camp exit linking to the form,
SMS/email acknowledgement, role-based admin accounts.
