-- Medical Camp Feedback Portal - MySQL schema
-- Run once:  mysql -u root -p < sql/schema.sql
-- (The app also creates these tables automatically on startup if they are missing.)

CREATE DATABASE IF NOT EXISTS medcamp_feedback
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE medcamp_feedback;

CREATE TABLE IF NOT EXISTS admins (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    username      VARCHAR(50)  NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS feedback (
    id                 INT AUTO_INCREMENT PRIMARY KEY,
    participant_name   VARCHAR(100) NOT NULL,
    age                TINYINT UNSIGNED NOT NULL,
    gender             VARCHAR(20)  NOT NULL,
    phone              VARCHAR(15)  NOT NULL,
    email              VARCHAR(120) NULL,
    camp_name          VARCHAR(120) NOT NULL,
    visit_date         DATE         NOT NULL,
    rating_doctor      TINYINT NOT NULL,
    rating_medicine    TINYINT NOT NULL,
    rating_cleanliness TINYINT NOT NULL,
    rating_staff       TINYINT NOT NULL,
    rating_waiting     TINYINT NOT NULL,
    feedback_type      VARCHAR(20)  NOT NULL,
    comments           TEXT NULL,
    submitted_at       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_r1 CHECK (rating_doctor      BETWEEN 1 AND 5),
    CONSTRAINT chk_r2 CHECK (rating_medicine    BETWEEN 1 AND 5),
    CONSTRAINT chk_r3 CHECK (rating_cleanliness BETWEEN 1 AND 5),
    CONSTRAINT chk_r4 CHECK (rating_staff       BETWEEN 1 AND 5),
    CONSTRAINT chk_r5 CHECK (rating_waiting     BETWEEN 1 AND 5),
    INDEX idx_camp (camp_name),
    INDEX idx_submitted (submitted_at)
) ENGINE=InnoDB;

-- Default admin (admin / admin123) is created automatically by the app on first
-- startup with a securely hashed password. CHANGE IT after first login.
