CREATE DATABASE NEURO_PERFORMANCE_DB;

USE NEURO_PERFORMANCE_DB;

CREATE TABLE clients(
	client_id INT PRIMARY KEY AUTO_INCREMENT,
	first_name VARCHAR(100) NOT NULL,
	last_name VARCHAR(100) NOT NULL,
	date_of_birth DATE NOT NULL,
	gender ENUM('Male', 'Female', 'Non-Binary', 'Prefer not to say'),
	email VARCHAR(100) UNIQUE NOT NULL,
	phone varchar(20),
	primary_goals TEXT,
	consent_signed BOOLEAN DEFAULT FALSE
);

CREATE TABLE genetic_profiles(
	profile_id INT PRIMARY KEY AUTo_INCREMENT,
	client_id INT UNIQUE NOT NULL,
	test_date DATE NOT NULL,
	comt_genotype ENUM('Val/Val', 'Val/Met', 'Met/Met', 'Unknown'),
    mthfr_c677t ENUM('CC', 'CT', 'TT', 'Unknown'),
    apoe_genotype ENUM('e2/e2', 'e2/e3', 'e2/e4', 'e3/e3', 'e3/e4', 'e4/e4', 'Unknown'),
    actn3_r577x ENUM('RR', 'RX', 'XX', 'Unknown'),
    additional_markers JSON,
    FOREIGN KEY (client_id) REFERENCES clients(client_id) ON DELETE CASCADE
);

CREATE TABLE intervention_categories(
	category_id INT PRIMARY KEY AUTO_INCREMENT,
	category_name VARCHAR(100) UNIQUE NOT NULL,
	parent_category_id INT,
	decription TEXT,
	FOREIGN KEY(parent_category_id) REFERENCES intervention_categories(category_id)
);

CREATE TABLE interventions(
	intervention_id INT PRIMARY KEY AUTO_INCREMENT,
	intervention_name VARCHAR(200) NOT NULL,
	category_id INT NOT NULL,
	intervention_type ENUM('Supplement','Peptide', 'Therapy', 'Procedure', 'Device', 'Lifestyle') NOT NULL,
	standard_dosage VARCHAR(100),
	dosage_unit VARCHAR(50),
	administration_route VARCHAR(100),
	primary_benefits TEXT,
	mechanism_of_action TEXT,
	FOREIGN KEY(category_id) REFERENCES intervention_categories(category_id)
);

CREATE TABLE client_protocols(
	protocol_id INT PRIMARY KEY AUTO_INCREMENT,
	client_id INT NOT NULL,
	intervention_id INT NOT NULL,
	start_date DATE NOT NULL,
	end_date DATE,
	status ENUM('Active', 'Completed', 'Discontinued', 'Paused') DEFAULT 'Active',
	prescribed_dosage DECIMAL(10,2) NOT NULL,
	frequency VARCHAR(100) NOT NULL,
	FOREIGN KEY(client_id) REFERENCES clients(client_id) ON DELETE CASCADE,
	FOREIGN KEY(intervention_id) REFERENCES interventions(intervention_id)
);

CREATE TABLE protocol_logs(
	log_id INT PRIMARY KEY AUTO_INCREMENT,
	protocol_id INT NOT NULL,
	log_date DATE NOT NULL,
	dosage_taken DECIMAL(10,2),
	taken_as_prescribed BOOLEAN DEFAULT TRUE,
	subjective_effects TEXT,
	FOREIGN KEY(protocol_id) REFERENCES client_protocols(protocol_id) ON DELETE CASCADE
);

CREATE TABLE biomarker_types (
    biomarker_id INT PRIMARY KEY AUTO_INCREMENT,
    biomarker_name VARCHAR(200) UNIQUE NOT NULL,
    biomarker_category ENUM('Blood', 'Hormone', 'Neurotransmitter', 'Metabolic', 'Inflammatory', 'Cognitive', 'Physical', 'Other') NOT NULL,
    measurement_unit VARCHAR(50),
    optimal_min DECIMAL(10,4),
    optimal_max DECIMAL(10,4),
    description TEXT
);

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