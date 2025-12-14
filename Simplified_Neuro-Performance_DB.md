# Simplified Neuro-Performance & Biohacking Optimization Platform Database

This document presents a simplified version of the Neuro-Performance & Biohacking Optimization Platform database. The original design was comprehensive, and this version has been streamlined for a more focused university project.

The key changes are:
- The number of tables has been reduced from 17 to 13.
- The number of attributes (columns) in each table has been reduced to between 4 and 10, making the schema easier to manage.
- The focus is on the core functionality: tracking clients, interventions, and their outcomes.

## Simplified Database Schema

Here are the 13 tables in the simplified schema:

### 1. `clients`

Stores core information about each client.

```sql
CREATE TABLE clients (
    client_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('Male', 'Female', 'Non-binary', 'Prefer not to say'),
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    primary_goals TEXT,
    consent_signed BOOLEAN DEFAULT FALSE
);
```

### 2. `genetic_profiles`

Stores key genetic markers for each client, which can influence biohacking protocols.

```sql
CREATE TABLE genetic_profiles (
    profile_id INT PRIMARY KEY AUTO_INCREMENT,
    client_id INT UNIQUE NOT NULL,
    test_date DATE NOT NULL,
    comt_genotype ENUM('Val/Val', 'Val/Met', 'Met/Met', 'Unknown'),
    mthfr_c677t ENUM('CC', 'CT', 'TT', 'Unknown'),
    apoe_genotype ENUM('e2/e2', 'e2/e3', 'e2/e4', 'e3/e3', 'e3/e4', 'e4/e4', 'Unknown'),
    actn3_r577x ENUM('RR', 'RX', 'XX', 'Unknown'),
    additional_markers JSON,
    FOREIGN KEY (client_id) REFERENCES clients(client_id) ON DELETE CASCADE
);
```

### 3. `intervention_categories`

A simple table to categorize interventions.

```sql
CREATE TABLE intervention_categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) UNIQUE NOT NULL,
    parent_category_id INT,
    description TEXT,
    FOREIGN KEY (parent_category_id) REFERENCES intervention_categories(category_id)
);
```

### 4. `interventions`

A catalog of all available biohacking interventions.

```sql
CREATE TABLE interventions (
    intervention_id INT PRIMARY KEY AUTO_INCREMENT,
    intervention_name VARCHAR(200) NOT NULL,
    category_id INT NOT NULL,
    intervention_type ENUM('Supplement', 'Peptide', 'Therapy', 'Procedure', 'Device', 'Lifestyle') NOT NULL,
    standard_dosage VARCHAR(100),
    dosage_unit VARCHAR(50),
    administration_route VARCHAR(100),
    primary_benefits TEXT,
    mechanism_of_action TEXT,
    FOREIGN KEY (category_id) REFERENCES intervention_categories(category_id)
);
```

### 5. `client_protocols`

Links clients to the interventions they are undergoing.

```sql
CREATE TABLE client_protocols (
    protocol_id INT PRIMARY KEY AUTO_INCREMENT,
    client_id INT NOT NULL,
    intervention_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    status ENUM('Active', 'Completed', 'Discontinued', 'Paused') DEFAULT 'Active',
    prescribed_dosage DECIMAL(10,2) NOT NULL,
    frequency VARCHAR(100) NOT NULL,
    FOREIGN KEY (client_id) REFERENCES clients(client_id) ON DELETE CASCADE,
    FOREIGN KEY (intervention_id) REFERENCES interventions(intervention_id)
);
```

### 6. `protocol_logs`

Tracks a client's adherence and feedback for a specific protocol.

```sql
CREATE TABLE protocol_logs (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    protocol_id INT NOT NULL,
    log_date DATE NOT NULL,
    dosage_taken DECIMAL(10,2),
    taken_as_prescribed BOOLEAN DEFAULT TRUE,
    subjective_effects TEXT,
    FOREIGN KEY (protocol_id) REFERENCES client_protocols(protocol_id) ON DELETE CASCADE
);
```

### 7. `biomarker_types`

Defines the different kinds of biomarkers that can be tracked.

```sql
CREATE TABLE biomarker_types (
    biomarker_id INT PRIMARY KEY AUTO_INCREMENT,
    biomarker_name VARCHAR(200) UNIQUE NOT NULL,
    biomarker_category ENUM('Blood', 'Hormone', 'Neurotransmitter', 'Metabolic', 'Inflammatory', 'Cognitive', 'Physical', 'Other') NOT NULL,
    measurement_unit VARCHAR(50),
    optimal_min DECIMAL(10,4),
    optimal_max DECIMAL(10,4),
    description TEXT
);
```

### 8. `biomarker_readings`

Stores the actual biomarker measurements for a client over time.

```sql
CREATE TABLE biomarker_readings (
    reading_id INT PRIMARY KEY AUTO_INCREMENT,
    client_id INT NOT NULL,
    biomarker_id INT NOT NULL,
    reading_date DATE NOT NULL,
    value DECIMAL(12,4) NOT NULL,
    testing_facility VARCHAR(200),
    flag ENUM('Low', 'Normal', 'High', 'Critical Low', 'Critical High'),
    FOREIGN KEY (client_id) REFERENCES clients(client_id) ON DELETE CASCADE,
    FOREIGN KEY (biomarker_id) REFERENCES biomarker_types(biomarker_id)
);
```

### 9. `performance_metrics`

Records client performance data, from cognitive tests or subjective ratings.

```sql
CREATE TABLE performance_metrics (
    metric_id INT PRIMARY KEY AUTO_INCREMENT,
    client_id INT NOT NULL,
    metric_date DATE NOT NULL,
    reaction_time_ms INT,
    memory_score DECIMAL(5,2),
    focus_duration_minutes INT,
    energy_level_score TINYINT,
    mood_score TINYINT,
    stress_level_score TINYINT,
    data_source ENUM('Manual', 'Cognitive Test', 'Assessment') DEFAULT 'Manual',
    FOREIGN KEY (client_id) REFERENCES clients(client_id) ON DELETE CASCADE
);
```

### 10. `adverse_events`

Logs any adverse reactions or side effects a client experiences.

```sql
CREATE TABLE adverse_events (
    event_id INT PRIMARY KEY AUTO_INCREMENT,
    client_id INT NOT NULL,
    protocol_id INT,
    event_date DATE NOT NULL,
    severity ENUM('Mild', 'Moderate', 'Severe', 'Life-threatening') NOT NULL,
    symptoms TEXT NOT NULL,
    suspected_intervention_id INT,
    action_taken TEXT,
    outcome ENUM('Resolved', 'Ongoing', 'Hospitalized', 'Fatal'),
    FOREIGN KEY (client_id) REFERENCES clients(client_id) ON DELETE CASCADE,
    FOREIGN KEY (protocol_id) REFERENCES client_protocols(protocol_id),
    FOREIGN KEY (suspected_intervention_id) REFERENCES interventions(intervention_id)
);
```

### 11. `contraindications`

Stores information about potentially dangerous combinations of interventions.

```sql
CREATE TABLE contraindications (
    contraindication_id INT PRIMARY KEY AUTO_INCREMENT,
    intervention_id_1 INT NOT NULL,
    intervention_id_2 INT,
    contraindication_type ENUM('Absolute', 'Relative', 'Drug Interaction', 'Condition-based', 'Genetic') NOT NULL,
    description TEXT NOT NULL,
    severity ENUM('Critical', 'High', 'Moderate', 'Low') NOT NULL,
    FOREIGN KEY (intervention_id_1) REFERENCES interventions(intervention_id),
    FOREIGN KEY (intervention_id_2) REFERENCES interventions(intervention_id)
);
```

### 12. `providers`

Stores information about the professionals who administer protocols.

```sql
CREATE TABLE providers (
    provider_id INT PRIMARY KEY AUTO_INCREMENT,
    provider_type ENUM('Physician', 'Naturopath', 'Nutritionist', 'Performance Coach', 'Other') NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    credentials VARCHAR(200),
    specialization TEXT,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20)
);
```

### 13. `wearable_data`

Stores data imported from wearable devices like smartwatches.

```sql
CREATE TABLE wearable_data (
    data_id INT PRIMARY KEY AUTO_INCREMENT,
    client_id INT NOT NULL,
    data_date DATE NOT NULL,
    device_type ENUM('Oura', 'Whoop', 'Apple Watch', 'Garmin', 'Fitbit', 'CGM', 'Other') NOT NULL,
    total_sleep_minutes INT,
    hrv DECIMAL(6,2),
    resting_hr INT,
    steps INT,
    active_calories INT,
    FOREIGN KEY (client_id) REFERENCES clients(client_id) ON DELETE CASCADE
);
```

## Removed Tables

The following tables from the original design have been removed to simplify the project:

-   **`research_references`**: While useful, managing a library of research papers is not core to the application's primary function for a university project.
-   **`audit_logs`**: Audit trails are an advanced feature for ensuring compliance and security in production systems. They add significant complexity that is not essential for a student project.
-   **`protocol_templates` & `template_interventions`**: These tables were designed to create reusable protocol templates. While this is a valuable feature for a real-world application, it's not essential for demonstrating the core functionality of the database. Protocols can be created on a per-client basis.

This simplified schema should provide a solid foundation for your project, allowing you to focus on the most important features.
